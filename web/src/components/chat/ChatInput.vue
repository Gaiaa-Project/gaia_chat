<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue'
import type { RegisteredCommand } from '@/types/chat'
import { useChatStore } from '@/stores/chat'

const props = defineProps<{
  commands: RegisteredCommand[]
}>()

const emit = defineEmits<{
  send: [message: string]
}>()

const store = useChatStore()
const input = ref('')
const selectedIndex = ref(0)
const inputRef = ref<HTMLInputElement>()

watch(
  () => store.isFocused,
  async (focused) => {
    if (focused) {
      await nextTick()
      inputRef.value?.focus()
    }
  },
)

const prefix = computed(() => store.commandPrefix)
const maxLength = computed(() => store.maxMessageLength)
let lastSentTime = 0
const isOnCooldown = ref(false)
const showSuggestions = computed(
  () => input.value.startsWith(prefix.value) && input.value.length >= 1,
)

const filteredCommands = computed(() => {
  const query = input.value.slice(prefix.value.length).toLowerCase()
  if (!query) return props.commands
  const cmdName = query.split(' ')[0] ?? ''
  return props.commands.filter((cmd) => cmd.name.toLowerCase().includes(cmdName))
})

const handleSend = () => {
  const trimmed = input.value.trim()
  if (!trimmed) return

  const now = Date.now()
  if (store.messageCooldown > 0 && now - lastSentTime < store.messageCooldown) {
    isOnCooldown.value = true
    setTimeout(
      () => {
        isOnCooldown.value = false
      },
      store.messageCooldown - (now - lastSentTime),
    )
    return
  }

  lastSentTime = now
  emit('send', trimmed)
  input.value = ''
  selectedIndex.value = 0
}

const handleSelect = (cmd: RegisteredCommand) => {
  input.value = `${prefix.value}${cmd.name} `
  selectedIndex.value = 0
}

const handleKeydown = (e: KeyboardEvent) => {
  if (showSuggestions.value) {
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      selectedIndex.value++
      return
    }
    if (e.key === 'ArrowUp') {
      e.preventDefault()
      selectedIndex.value = Math.max(0, selectedIndex.value - 1)
      return
    }
    if (e.key === 'Tab') {
      e.preventDefault()
      const cmds = filteredCommands.value
      if (cmds.length > 0) {
        const idx = ((selectedIndex.value % cmds.length) + cmds.length) % cmds.length
        handleSelect(cmds[idx]!)
      }
      return
    }
  }

  if (e.key === 'ArrowUp') {
    e.preventDefault()
    const cmd = store.navigateHistory('up')
    if (cmd !== null) input.value = cmd
    return
  }

  if (e.key === 'ArrowDown') {
    e.preventDefault()
    const cmd = store.navigateHistory('down')
    if (cmd !== null) input.value = cmd
    return
  }

  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    store.resetHistoryIndex()
    handleSend()
  }
}

defineExpose({ showSuggestions, input, selectedIndex, handleSelect })
</script>

<template>
  <div class="px-3 pb-3 pt-1">
    <div
      class="flex items-center gap-4 bg-zinc-900/60 border border-zinc-800/60 rounded-xl px-4 py-2.5 transition-colors duration-200 focus-within:border-emerald-500/30"
    >
      <input
        ref="inputRef"
        v-model="input"
        type="text"
        :placeholder="$t('chat.placeholder')"
        class="flex-1 bg-transparent text-sm text-zinc-300 placeholder-zinc-600 outline-none"
        @keydown="handleKeydown"
      />

      <span
        class="text-[10px] font-mono shrink-0 transition-colors duration-150"
        :class="input.length > maxLength ? 'text-red-400' : 'text-zinc-600'"
      >
        {{ input.length }}/{{ maxLength }}
      </span>

      <button
        class="shrink-0 transition-colors duration-150"
        :class="isOnCooldown ? 'text-red-400' : input.trim() ? 'text-white' : 'text-zinc-500'"
        :disabled="!input.trim() || isOnCooldown"
        @click="handleSend"
      >
        <v-icon size="18">{{ isOnCooldown ? 'mdi-timer-sand' : 'mdi-send' }}</v-icon>
      </button>
    </div>
  </div>
</template>
