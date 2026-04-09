<script setup lang="ts">
import { useChatStore } from '@/stores/chat'
import ChatMessage from './ChatMessage.vue'

const store = useChatStore()
</script>

<template>
  <Transition name="passive-fade">
    <div v-if="store.isPassiveVisible" class="fixed top-4 left-1/2 -translate-x-1/2 z-30 w-[620px]">
      <div
        class="flex flex-col bg-[rgba(0,10,8,0.85)] border border-emerald-500/20 rounded-2xl overflow-hidden transition-all duration-300"
        :style="{ maxHeight: '340px' }"
      >
        <div class="overflow-y-auto py-2 scrollbar-thin">
          <TransitionGroup name="message-fade">
            <ChatMessage
              v-for="message in store.passiveMessages"
              :key="message.id"
              :message="message"
            />
          </TransitionGroup>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.passive-fade-enter-active,
.passive-fade-leave-active {
  transition: opacity 0.4s ease;
}

.passive-fade-enter-from,
.passive-fade-leave-to {
  opacity: 0;
}

.message-fade-enter-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.message-fade-leave-active {
  transition:
    opacity 0.3s ease,
    transform 0.3s ease;
}

.message-fade-enter-from {
  opacity: 0;
  transform: translateY(-8px);
}

.message-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

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
</style>
