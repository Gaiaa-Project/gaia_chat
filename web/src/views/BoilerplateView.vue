<script setup lang="ts">
import { ref } from 'vue'
import DevTopBar from '@/components/boilerplate/DevTopBar.vue'
import DevFab from '@/components/boilerplate/DevFab.vue'
import DevViewSelector from '@/components/boilerplate/DevViewSelector.vue'
import ChatView from '@/views/ChatView.vue'

const currentView = ref('none')
const views: string[] = ['Chat']

const handleSelectView = (view: string) => {
  currentView.value = view
}
</script>

<template>
  <div
    class="fixed inset-0 w-full h-full bg-contain bg-center bg-no-repeat bg-gray-900 sm:bg-contain md:bg-cover lg:bg-cover xl:bg-cover 2xl:bg-cover bg-[url('/boilerplate-background.jpg')] transition-all duration-300"
  >
    <div class="absolute inset-0 bg-black/20"></div>

    <DevTopBar v-if="currentView !== 'Chat'" />
    <DevFab :current-view="currentView" />
    <DevViewSelector :views="views" :current-view="currentView" @select-view="handleSelectView" />

    <ChatView v-if="currentView === 'Chat'" :force-visible="true" />
  </div>
</template>

<style scoped>
.v-enter-active,
.v-leave-active {
  transition: opacity 0.3s ease;
}

.v-enter-from,
.v-leave-to {
  opacity: 0;
}
</style>
