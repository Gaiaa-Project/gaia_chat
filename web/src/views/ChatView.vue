<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useChatStore } from '@/stores/chat'
import { sendNuiCallback } from '@/utils/nui'
import { mockCommands } from '@/mock/commands'
import { mockPrefix } from '@/mock/prefix'
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
  store.addMessage({
    id: '1',
    type: 'system',
    content: 'Bienvenue sur le serveur !',
    timestamp: new Date(),
  })
  store.addMessage({
    id: '2',
    type: 'player',
    author: 'John Smith',
    authorColor: '#34d399',
    content: 'Salut tout le monde, comment ça va ?',
    timestamp: new Date(),
  })
  store.addMessage({
    id: '3',
    type: 'player',
    author: 'Jane Doe',
    authorColor: '#60a5fa',
    content: 'Hey ! Bien et toi ?',
    timestamp: new Date(),
  })
  store.addMessage({
    id: '4',
    type: 'player',
    author: 'Mike Johnson',
    authorColor: '#f472b6',
    content: "Quelqu'un pour aller à la mine ?",
    timestamp: new Date(),
  })
  store.addMessage({
    id: '5',
    type: 'warning',
    content: 'Le serveur redémarrera dans 30 minutes.',
    timestamp: new Date(),
  })
  store.addMessage({
    id: '6',
    type: 'player',
    author: 'John Smith',
    authorColor: '#34d399',
    content: 'Ok on se dépêche alors !',
    timestamp: new Date(),
  })
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
    sendNuiCallback('closeChat')
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
      class="h-[340px] flex flex-col bg-[rgba(0,10,8,0.85)] border-2 border-emerald-500/30 rounded-2xl shadow-[0_16px_48px_rgba(0,0,0,0.5)] overflow-hidden"
    >
      <ChatMessages :messages="store.messages" />
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
