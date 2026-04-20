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
  const backgroundColor = ref('rgba(0,10,8,0.85)')
  const borderColor = ref('#34d39950')
  const staffBorderColor = ref('#f43f5e80')
  const staffColor = ref('#f43f5e')
  const emptyTextColor = ref('#ffffff')
  const textColor = ref('#d4d4d8')
  const commandBorderColor = ref('#10b98150')
  const commandSeparatorColor = ref('#04785799')
  const commandSelectedBgColor = ref('#10b9811a')
  const commandPrefixColor = ref('#10b98199')
  const commandActiveParamColor = ref('#34d399')
  const commandScrollbarColor = ref('#34d39926')
  const chatPosition = ref('top-left')

  const positionClasses = computed(() => {
    const map: Record<string, string> = {
      'top-left': 'top-4 left-4',
      'top-center': 'top-4 left-1/2 -translate-x-1/2',
      'top-right': 'top-4 right-4',
      'center-left': 'top-1/2 left-4 -translate-y-1/2',
      'center': 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2',
      'center-right': 'top-1/2 right-4 -translate-y-1/2',
      'bottom-left': 'bottom-4 left-4',
      'bottom-center': 'bottom-4 left-1/2 -translate-x-1/2',
      'bottom-right': 'bottom-4 right-4',
    }
    return map[chatPosition.value] || map['top-left']
  })

  const getAuthorColor = (): string => {
    if (authorColor.value === 'random') {
      const hue = Math.floor(Math.random() * 360)
      return `hsl(${hue}, 70%, 65%)`
    }
    return authorColor.value
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
    backgroundColor?: string
    borderColor?: string
    staffBorderColor?: string
    staffColor?: string
    emptyTextColor?: string
    textColor?: string
    commandBorderColor?: string
    commandSeparatorColor?: string
    commandSelectedBgColor?: string
    commandPrefixColor?: string
    commandActiveParamColor?: string
    commandScrollbarColor?: string
    chatPosition?: string
  }) => {
    commandPrefix.value = config.commandPrefix
    if (config.maxMessages) maxMessages.value = config.maxMessages
    if (config.maxMessageLength) maxMessageLength.value = config.maxMessageLength
    if (config.messageCooldown !== undefined) messageCooldown.value = config.messageCooldown
    if (config.passiveDuration) passiveDuration.value = config.passiveDuration
    if (config.passiveMode) passiveMode.value = config.passiveMode
    if (config.authorColor) authorColor.value = config.authorColor
    if (config.backgroundColor) backgroundColor.value = config.backgroundColor
    if (config.borderColor) borderColor.value = config.borderColor
    if (config.staffBorderColor) staffBorderColor.value = config.staffBorderColor
    if (config.staffColor) staffColor.value = config.staffColor
    if (config.emptyTextColor) emptyTextColor.value = config.emptyTextColor
    if (config.textColor) textColor.value = config.textColor
    if (config.commandBorderColor) commandBorderColor.value = config.commandBorderColor
    if (config.commandSeparatorColor) commandSeparatorColor.value = config.commandSeparatorColor
    if (config.commandSelectedBgColor) commandSelectedBgColor.value = config.commandSelectedBgColor
    if (config.commandPrefixColor) commandPrefixColor.value = config.commandPrefixColor
    if (config.commandActiveParamColor) commandActiveParamColor.value = config.commandActiveParamColor
    if (config.commandScrollbarColor) commandScrollbarColor.value = config.commandScrollbarColor
    if (config.chatPosition) chatPosition.value = config.chatPosition
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
    backgroundColor,
    borderColor,
    staffBorderColor,
    staffColor,
    emptyTextColor,
    textColor,
    commandBorderColor,
    commandSeparatorColor,
    commandSelectedBgColor,
    commandPrefixColor,
    commandActiveParamColor,
    commandScrollbarColor,
    positionClasses,
    addMessage,
    clearMessages,
    addCommand,
    removeCommand,
    setCommands,
    updateCommandParams,
    toastText,
    isToastVisible,
    showToast,
    show,
    hide,
    focus,
    blur,
    setConfig,
  }
})
