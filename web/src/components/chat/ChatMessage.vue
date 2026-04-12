<script setup lang="ts">
import type { ChatMessage } from '@/types/chat'
import { useI18n } from 'vue-i18n'
import { useChatStore } from '@/stores/chat'

defineProps<{
  message: ChatMessage
}>()

const { locale } = useI18n()
const store = useChatStore()

const formatTime = (date: Date | string | null): string => {
  const d = date instanceof Date ? date : date ? new Date(date) : new Date()
  return d.toLocaleTimeString(locale.value, { hour: '2-digit', minute: '2-digit' })
}

const typeStyles: Record<string, string> = {
  system: 'text-emerald-400/80 italic',
  info: 'text-sky-400/80',
  success: 'text-emerald-400/80',
  warning: 'text-amber-400/80',
  error: 'text-red-400/80',
}
</script>

<template>
  <div class="flex items-center justify-between pl-5 pr-5 py-1.5">
    <div v-if="message.type === 'player'" class="flex flex-col min-w-0">
      <div class="flex items-center gap-2">
        <span class="text-xs font-semibold" :style="{ color: message.authorColor ?? store.getAuthorColor() }">
          {{ message.author === '__self__' ? $t('chat.you') : message.author }}
        </span>
        <span
          v-if="message.prefix"
          class="text-[10px] font-semibold"
          :style="{ color: message.prefixColor ?? '#a78bfa' }"
        >
          {{ message.prefix }}
        </span>
      </div>
      <span class="text-sm text-zinc-300 leading-relaxed break-words">
        {{ message.content }}
      </span>
    </div>

    <div v-else class="flex items-center gap-2 min-w-0">
      <v-icon v-if="message.icon" size="14" :class="typeStyles[message.type] ?? 'text-zinc-400'">
        {{ message.icon }}
      </v-icon>
      <div class="flex items-baseline gap-2 min-w-0">
        <span
          v-if="message.prefix"
          class="text-xs font-semibold shrink-0"
          :style="{ color: message.prefixColor ?? '#a78bfa' }"
        >
          {{ message.prefix }}
        </span>
        <span
          class="text-sm leading-relaxed break-words"
          :class="typeStyles[message.type] ?? 'text-zinc-400'"
        >
          {{ message.content }}
        </span>
      </div>
    </div>

    <span class="text-zinc-600 text-[10px] font-mono shrink-0 mt-0.5 ml-2">
      {{ formatTime(message.timestamp) }}
    </span>
  </div>
</template>
