import { useChatStore } from '@/stores/chat'
import type { ChatMessage, RegisteredCommand } from '@/types/chat'

interface NuiEvent {
  action: string
  data: unknown
}

type NuiHandler = (data: unknown) => void

const handlers: Record<string, NuiHandler> = {}

const on = (action: string, handler: NuiHandler) => {
  handlers[action] = handler
}

export const initNuiListeners = () => {
  const store = useChatStore()

  window.addEventListener('message', (event: MessageEvent<NuiEvent>) => {
    const { action, data } = event.data
    if (handlers[action]) {
      handlers[action](data)
    }
  })

  on('show', () => {
    store.show()
  })

  on('hide', () => {
    store.hide()
  })

  on('focus', () => {
    store.focus()
  })

  on('addMessage', (data) => {
    store.addMessage(data as ChatMessage)
  })

  on('clearMessages', () => {
    store.clearMessages()
  })

  on('setCommands', (data) => {
    store.setCommands(data as RegisteredCommand[])
  })

  on('addCommand', (data) => {
    store.addCommand(data as RegisteredCommand)
  })

  on('removeCommand', (data) => {
    store.removeCommand((data as { name: string }).name)
  })

  on('updateCommandParams', (data) => {
    const { name, params } = data as { name: string; params: RegisteredCommand['params'] }
    store.updateCommandParams(name, params)
  })

  on('setConfig', (data) => {
    store.setConfig(data as { commandPrefix: string })
  })

  on('showToast', (data) => {
    store.showToast((data as { text: string }).text)
  })

  on('setCommandHistory', (data) => {
    store.setCommandHistory(data as string[])
  })

  on('setStaffMode', (data) => {
    store.isStaffMode = (data as { enabled: boolean }).enabled
  })

  on('addStaffMessage', (data) => {
    store.addStaffMessage(data as ChatMessage)
  })
}
