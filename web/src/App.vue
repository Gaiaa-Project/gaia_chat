<script setup lang="ts">
import BoilerplateView from './views/BoilerplateView.vue'
import ChatView from './views/ChatView.vue'
import ChatPassive from './components/chat/ChatPassive.vue'
import ChatToast from './components/chat/ChatToast.vue'

const isDevelopment = import.meta.env.DEV
</script>

<template>
  <VApp>
    <BoilerplateView v-if="isDevelopment" />
    <template v-if="!isDevelopment">
      <ChatView />
      <ChatPassive />
      <ChatToast />
    </template>
  </VApp>
</template>
