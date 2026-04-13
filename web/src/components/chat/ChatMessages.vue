<script setup lang="ts">
import { ref, nextTick, watch, onMounted } from 'vue'
import type { ChatMessage as ChatMessageType } from '@/types/chat'
import { useChatStore } from '@/stores/chat'
import ChatMessage from './ChatMessage.vue'

const props = defineProps<{
  messages: ChatMessageType[]
}>()

const store = useChatStore()
const container = ref<HTMLElement>()

const scrollToBottom = async () => {
  await nextTick()
  if (container.value) {
    container.value.scrollTop = container.value.scrollHeight
  }
}

watch(() => props.messages.length, scrollToBottom)
watch(
  () => store.isVisible,
  (visible) => {
    if (visible) scrollToBottom()
  },
)
onMounted(scrollToBottom)
</script>

<template>
  <div ref="container" class="flex-1 overflow-y-auto overflow-x-hidden py-2 scrollbar-thin">
    <div v-if="messages.length === 0" class="flex items-center justify-center h-full">
      <span class="text-xs" :style="{ color: store.emptyTextColor }">{{ $t('chat.noMessages') }}</span>
    </div>

    <template v-for="(message, index) in messages" :key="index">
      <div
        v-if="index > 0"
        class="mx-5 h-px bg-gradient-to-r from-transparent via-emerald-500/20 to-transparent"
      ></div>
      <ChatMessage :message="message" />
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
