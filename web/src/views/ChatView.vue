<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useChatStore } from '@/stores/chat'
import { sendNuiCallback } from '@/utils/nui'
import { mockCommands } from '@/mock/commands'
import { mockPrefix } from '@/mock/prefix'
import { mockMessages } from '@/mock/messages'
import ChatMessages from '@/components/chat/ChatMessages.vue'
import ChatInput from '@/components/chat/ChatInput.vue'
import ChatSuggestions from '@/components/chat/ChatSuggestions.vue'

const props = withDefaults(
  defineProps<{
    forceVisible?: boolean
  }>(),
  {
    forceVisible: false,
  },
)

const store = useChatStore()
const chatInput = ref<InstanceType<typeof ChatInput>>()

if (import.meta.env.DEV) {
  store.setConfig({ commandPrefix: mockPrefix })
}

if (props.forceVisible) {
  mockMessages.forEach((msg) => store.addMessage(msg))
}

const commands = computed(() => {
  if (import.meta.env.DEV) return mockCommands
  return store.commands
})

const handleSend = (content: string) => {
  if (import.meta.env.DEV) {
    if (!content.startsWith(store.commandPrefix)) {
      store.addMessage({
        id: String(Date.now()),
        type: 'player',
        author: '__self__',
        authorColor: '#a78bfa',
        content,
        timestamp: new Date(),
      })
    }
    return
  }
  sendNuiCallback('chatMessage', { message: content })
}

const handleEscape = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && store.isVisible) {
    if (store.isStaffMode) {
      sendNuiCallback('exitStaffMode')
    } else {
      sendNuiCallback('closeChat')
    }
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleEscape)
})
</script>

<template>
  <div
    v-if="store.isVisible || props.forceVisible"
    class="fixed top-4 left-1/2 -translate-x-1/2 z-40 w-[620px] flex flex-col"
  >
    <div
      class="h-[340px] flex flex-col border-2 rounded-2xl shadow-[0_16px_48px_rgba(0,0,0,0.5)] overflow-hidden transition-colors duration-300"
      :style="{
        backgroundColor: store.backgroundColor,
        borderColor: store.isStaffMode ? store.staffBorderColor : store.borderColor,
      }"
    >
      <ChatMessages :messages="store.activeMessages" />
      <ChatInput ref="chatInput" :commands="commands" @send="handleSend" />
    </div>

    <ChatSuggestions
      v-show="chatInput?.showSuggestions"
      :commands="commands"
      :input="chatInput?.input ?? ''"
      :selected-index="chatInput?.selectedIndex ?? 0"
      class="mt-2"
      @select="(cmd) => chatInput?.handleSelect(cmd)"
    />
  </div>
</template>
