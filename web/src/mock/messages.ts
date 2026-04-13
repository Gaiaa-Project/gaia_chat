import type { ChatMessage } from '@/types/chat'

export const mockMessages: ChatMessage[] = [
  {
    id: '1',
    type: 'system',
    content: 'Welcome to the server!',
    timestamp: new Date(),
  },
  {
    id: '2',
    type: 'player',
    author: 'John Smith',
    authorColor: '#34d399',
    content: 'Hey everyone, how is it going?',
    timestamp: new Date(),
  },
  {
    id: '3',
    type: 'player',
    author: 'Jane Doe',
    authorColor: '#60a5fa',
    content: 'Hey! Good and you?',
    timestamp: new Date(),
  },
  {
    id: '4',
    type: 'player',
    author: 'Mike Johnson',
    authorColor: '#f472b6',
    content: 'Anyone want to go to the mine?',
    timestamp: new Date(),
  },
  {
    id: '5',
    type: 'warning',
    content: 'The server will restart in 30 minutes.',
    timestamp: new Date(),
  },
  {
    id: '6',
    type: 'player',
    author: 'John Smith',
    authorColor: '#34d399',
    content: 'Alright, let us hurry then!',
    timestamp: new Date(),
  },
]
