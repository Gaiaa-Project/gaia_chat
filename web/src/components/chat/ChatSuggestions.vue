<script setup lang="ts">
import { computed, watch, nextTick } from 'vue'
import type { RegisteredCommand } from '@/types/chat'
import { useChatStore } from '@/stores/chat'

const props = defineProps<{
  commands: RegisteredCommand[]
  input: string
  selectedIndex: number
}>()

const emit = defineEmits<{
  select: [command: RegisteredCommand]
}>()

const store = useChatStore()
const prefix = computed(() => store.commandPrefix)

const filtered = computed(() => {
  const query = props.input.slice(prefix.value.length).toLowerCase()
  if (!query) return props.commands
  const parts = query.split(' ')
  const cmdName = parts[0] ?? ''
  return props.commands.filter((cmd) => cmd.name.toLowerCase().includes(cmdName))
})

const clampedIndex = computed(() => {
  if (filtered.value.length === 0) return 0
  return (
    ((props.selectedIndex % filtered.value.length) + filtered.value.length) % filtered.value.length
  )
})

watch(clampedIndex, async () => {
  await nextTick()
  const el = document.querySelector(`[data-suggestion-index="${clampedIndex.value}"]`)
  el?.scrollIntoView({ block: 'nearest' })
})

const matchedCommand = computed(() => {
  const parts = props.input.slice(prefix.value.length).split(' ')
  const cmdName = parts[0]?.toLowerCase() ?? ''
  return props.commands.find((cmd) => cmd.name.toLowerCase() === cmdName) ?? null
})

const activeParamIndex = computed(() => {
  if (!matchedCommand.value?.params?.length) return -1
  const parts = props.input.slice(prefix.value.length).split(' ')
  const argCount = parts.length - 1
  if (argCount <= 0) return -1
  const params = matchedCommand.value.params
  const lastParam = params[params.length - 1]
  if (lastParam?.merge && argCount >= params.length) return params.length - 1
  if (argCount > params.length) return -1
  return argCount - 1
})

const getDescription = (cmd: RegisteredCommand) => {
  if (matchedCommand.value?.name === cmd.name && activeParamIndex.value >= 0) {
    const param = cmd.params?.[activeParamIndex.value]
    if (param?.help) return param.help
  }
  return cmd.help || ''
}
</script>

<template>
  <div
    class="max-h-[140px] overflow-y-auto rounded-xl bg-zinc-950/90 border-2 border-emerald-500/30 scrollbar-thin"
  >
    <div v-if="filtered.length === 0" class="flex items-center justify-center py-4">
      <span class="text-xs" :style="{ color: store.emptyTextColor }">{{ $t('chat.noCommands') }}</span>
    </div>

    <template v-else v-for="(cmd, index) in filtered" :key="cmd.name">
      <div
        v-if="index > 0"
        class="mx-3 h-px bg-gradient-to-r from-transparent via-emerald-700/60 to-transparent"
      ></div>
      <div
        :data-suggestion-index="index"
        class="flex items-center justify-between pl-5 pr-5 py-2 cursor-pointer transition-colors duration-100"
        :class="index === clampedIndex ? 'bg-emerald-500/10' : 'hover:bg-white/[0.03]'"
        @click="emit('select', cmd)"
      >
        <div class="flex items-center gap-2">
          <span class="text-emerald-500/60 text-xs font-mono">{{ prefix }}</span>
          <span class="text-zinc-300 text-sm">{{ cmd.name }}</span>
          <template v-if="cmd.params?.length">
            <span
              v-for="(param, pIndex) in cmd.params"
              :key="param.name"
              class="text-xs font-mono transition-colors duration-150"
              :class="
                matchedCommand?.name === cmd.name && activeParamIndex === pIndex
                  ? 'text-emerald-400'
                  : param.optional
                    ? 'text-zinc-600'
                    : 'text-zinc-500'
              "
            >
              {{ param.optional ? `[${param.name}]` : `<${param.name}>` }}
            </span>
          </template>
        </div>
        <span v-if="getDescription(cmd)" class="text-zinc-500 text-xs ml-4 shrink-0">
          {{ getDescription(cmd) }}
        </span>
      </div>
    </template>
  </div>
</template>

<style scoped>
.scrollbar-thin::-webkit-scrollbar {
  width: 4px;
}

.scrollbar-thin::-webkit-scrollbar-track {
  background: transparent;
}

.scrollbar-thin::-webkit-scrollbar-thumb {
  background: rgba(52, 211, 153, 0.15);
  border-radius: 9999px;
}

.scrollbar-thin::-webkit-scrollbar-thumb:hover {
  background: rgba(52, 211, 153, 0.3);
}
</style>
