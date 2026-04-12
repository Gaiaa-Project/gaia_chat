import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import type { ChatMessage, RegisteredCommand } from '@/types/chat'

interface PassiveEntry {
  message: ChatMessage
  timer: ReturnType<typeof setTimeout>
}

export const useChatStore = defineStore('chat', () => {
  const messages = ref<ChatMessage[]>([])
  const commands = ref<RegisteredCommand[]>([])
  const isVisible = ref(false)
  const isFocused = ref(false)
  const isStaffMode = ref(false)
  const staffMessages = ref<ChatMessage[]>([])
  const passiveEntries = ref<PassiveEntry[]>([])
  const commandPrefix = ref('/')
  const maxMessages = ref(200)
  const maxMessageLength = ref(256)
  const messageCooldown = ref(1000)
  const authorColor = ref('#34d399')

  const getAuthorColor = (): string => {
    if (authorColor.value === 'random') {
      const hue = Math.floor(Math.random() * 360)
      return `hsl(${hue}, 70%, 65%)`
    }
    return authorColor.value
  }
  const commandHistoryList = ref<string[]>([])
  const historyIndex = ref(-1)

  const setCommandHistory = (history: string[]) => {
    commandHistoryList.value = history
    historyIndex.value = -1
  }

  const navigateHistory = (direction: 'up' | 'down'): string | null => {
    if (commandHistoryList.value.length === 0) return null

    if (direction === 'up') {
      if (historyIndex.value < commandHistoryList.value.length - 1) {
        historyIndex.value++
      }
    } else {
      if (historyIndex.value > -1) {
        historyIndex.value--
      }
    }

    if (historyIndex.value === -1) return ''
    return (
      commandHistoryList.value[commandHistoryList.value.length - 1 - historyIndex.value] ?? null
    )
  }

  const resetHistoryIndex = () => {
    historyIndex.value = -1
  }
  const passiveDuration = ref(10000)
  const passiveMode = ref<'dynamic' | 'hidden'>('dynamic')

  const activeMessages = computed(() => (isStaffMode.value ? staffMessages.value : messages.value))

  const isPassiveVisible = computed(
    () => passiveMode.value === 'dynamic' && passiveEntries.value.length > 0,
  )
  const passiveMessages = computed(() => passiveEntries.value.map((e) => e.message))

  const removePassiveEntry = (id: string) => {
    const idx = passiveEntries.value.findIndex((e) => e.message.id === id)
    if (idx !== -1) {
      clearTimeout(passiveEntries.value[idx]!.timer)
      passiveEntries.value.splice(idx, 1)
    }
  }

  const addMessage = (message: ChatMessage) => {
    if (messages.value.length >= maxMessages.value) {
      messages.value.shift()
    }
    messages.value.push(message)

    if (!isVisible.value && passiveMode.value === 'dynamic') {
      const timer = setTimeout(() => {
        removePassiveEntry(message.id)
      }, passiveDuration.value)

      passiveEntries.value.push({ message, timer })
    }
  }

  const addStaffMessage = (message: ChatMessage) => {
    if (staffMessages.value.length >= maxMessages.value) {
      staffMessages.value.shift()
    }
    staffMessages.value.push(message)
  }

  const clearMessages = () => {
    messages.value = []
  }

  const addCommand = (command: RegisteredCommand) => {
    if (!commands.value.find((c) => c.name === command.name)) {
      commands.value.push(command)
    }
  }

  const removeCommand = (name: string) => {
    commands.value = commands.value.filter((c) => c.name !== name)
  }

  const setCommands = (cmds: RegisteredCommand[]) => {
    commands.value = cmds
  }

  const show = () => {
    isVisible.value = true
    for (const entry of passiveEntries.value) {
      clearTimeout(entry.timer)
    }
    passiveEntries.value = []
  }

  const hide = () => {
    isVisible.value = false
    isFocused.value = false
  }

  const focus = () => {
    isFocused.value = true
    isVisible.value = true
    for (const entry of passiveEntries.value) {
      clearTimeout(entry.timer)
    }
    passiveEntries.value = []
  }

  const blur = () => {
    isFocused.value = false
  }

  const updateCommandParams = (name: string, params: RegisteredCommand['params']) => {
    const cmd = commands.value.find((c) => c.name === name)
    if (cmd) {
      cmd.params = params
    }
  }

  const toastText = ref('')
  const isToastVisible = ref(false)
  let toastTimer: ReturnType<typeof setTimeout> | null = null

  const showToast = (text: string) => {
    toastText.value = text
    isToastVisible.value = true
    if (toastTimer) clearTimeout(toastTimer)
    toastTimer = setTimeout(() => {
      isToastVisible.value = false
      toastTimer = null
    }, 2500)
  }

  const setConfig = (config: {
    commandPrefix: string
    maxMessages?: number
    maxMessageLength?: number
    messageCooldown?: number
    passiveDuration?: number
    passiveMode?: 'dynamic' | 'hidden'
    authorColor?: string
  }) => {
    commandPrefix.value = config.commandPrefix
    if (config.maxMessages) maxMessages.value = config.maxMessages
    if (config.maxMessageLength) maxMessageLength.value = config.maxMessageLength
    if (config.messageCooldown !== undefined) messageCooldown.value = config.messageCooldown
    if (config.passiveDuration) passiveDuration.value = config.passiveDuration
    if (config.passiveMode) passiveMode.value = config.passiveMode
    if (config.authorColor) authorColor.value = config.authorColor
  }

  return {
    messages,
    commands,
    isVisible,
    isFocused,
    isStaffMode,
    activeMessages,
    addStaffMessage,
    isPassiveVisible,
    passiveMessages,
    commandPrefix,
    maxMessageLength,
    messageCooldown,
    getAuthorColor,
    addMessage,
    clearMessages,
    addCommand,
    removeCommand,
    setCommands,
    updateCommandParams,
    toastText,
    isToastVisible,
    showToast,
    setCommandHistory,
    navigateHistory,
    resetHistoryIndex,
    show,
    hide,
    focus,
    blur,
    setConfig,
  }
})
