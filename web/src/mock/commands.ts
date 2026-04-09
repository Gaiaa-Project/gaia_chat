import type { RegisteredCommand } from '@/types/chat'

export const mockCommands: RegisteredCommand[] = [
  {
    name: 'ooc',
    help: 'Send an out-of-character message',
    params: [{ name: 'message', help: 'The message to send', merge: true }],
  },
  {
    name: 'me',
    help: 'Perform a roleplay action',
    params: [{ name: 'action', help: 'The action your character performs', merge: true }],
  },
  {
    name: 'do',
    help: 'Describe an environment action',
    params: [{ name: 'description', help: 'What happens in the environment', merge: true }],
  },
  {
    name: 'whisper',
    help: 'Send a private message to a nearby player',
    params: [
      { name: 'player', help: 'The player ID to whisper to' },
      { name: 'message', help: 'The whispered message', merge: true },
    ],
  },
  {
    name: 'tp',
    help: 'Teleport to coordinates',
    params: [
      { name: 'x', help: 'X coordinate' },
      { name: 'y', help: 'Y coordinate' },
      { name: 'z', help: 'Z coordinate' },
    ],
  },
  { name: 'tpm', help: 'Teleport to map marker' },
  {
    name: 'heal',
    help: 'Heal a player',
    params: [{ name: 'player', help: 'The player ID to heal (self if empty)', optional: true }],
  },
  {
    name: 'revive',
    help: 'Revive a downed player',
    params: [{ name: 'player', help: 'The player ID to revive' }],
  },
  {
    name: 'kick',
    help: 'Kick a player from the server',
    params: [
      { name: 'player', help: 'The player ID to kick' },
      { name: 'reason', help: 'The kick reason', optional: true, merge: true },
    ],
  },
  {
    name: 'ban',
    help: 'Ban a player from the server',
    params: [
      { name: 'player', help: 'The player ID to ban' },
      { name: 'duration', help: 'Ban duration in minutes' },
      { name: 'reason', help: 'The ban reason', optional: true, merge: true },
    ],
  },
  {
    name: 'announce',
    help: 'Send a server-wide announcement',
    params: [{ name: 'message', help: 'The announcement message', merge: true }],
  },
  { name: 'car', help: 'Spawn a vehicle', params: [{ name: 'model', help: 'Vehicle model name' }] },
  { name: 'dv', help: 'Delete the nearest vehicle' },
  { name: 'noclip', help: 'Toggle noclip mode' },
  { name: 'coords', help: 'Show your current coordinates' },
  { name: 'clear', help: 'Clear the chat messages' },
]
