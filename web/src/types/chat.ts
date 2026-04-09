export type MessageType = 'player' | 'system' | 'info' | 'success' | 'warning' | 'error'

export interface ChatMessage {
  id: string
  type: MessageType
  content: string
  author?: string
  authorColor?: string
  timestamp: Date | string
  icon?: string
  prefix?: string
  prefixColor?: string
}

export interface CommandParam {
  name: string
  help?: string
  optional?: boolean
  merge?: boolean
}

export interface RegisteredCommand {
  name: string
  help?: string
  params?: CommandParam[]
}
