<script setup lang="ts">
import { useChatStore } from '@/stores/chat'

const store = useChatStore()
</script>

<template>
  <Transition name="toast-fade">
    <div
      v-if="store.isToastVisible"
      class="fixed top-8 left-1/2 -translate-x-1/2 z-50 px-5 py-2 rounded-xl bg-zinc-950/80 border border-emerald-500/30 text-zinc-200 text-sm font-medium"
    >
      {{ store.toastText }}
    </div>
  </Transition>
</template>

<style scoped>
.toast-fade-enter-active,
.toast-fade-leave-active {
  transition: opacity 0.3s ease;
}

.toast-fade-enter-from,
.toast-fade-leave-to {
  opacity: 0;
}
</style>
