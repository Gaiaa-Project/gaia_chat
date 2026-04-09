ChatConfig = {
    --- Command prefix
    ---
    --- The character used to initiate a command in the chat.
    --- When a player types this character at the beginning of a message,
    --- the system treats it as a command instead of a regular message.
    ---
    --- Allowed characters: ? , ; . : / = + %
    ---
    --- Default: '/'
    commandPrefix = '/',

    --- Author name color
    ---
    --- The default color used for player names in chat messages.
    --- Only hexadecimal color codes are supported.
    ---
    --- '#34d399': A specific hex color for all player names.
    --- 'random': Each message gets a randomly generated color.
    ---
    --- This can be overridden per message via hooks or addMessage options.
    ---
    --- Default: '#34d399'
    authorColor = '#34d399',

    --- Max messages
    ---
    --- The maximum number of messages kept in the chat history.
    --- When the limit is reached, the oldest message is removed
    --- to make room for the new one.
    ---
    --- Default: 200
    maxMessages = 200,

    --- Max message length
    ---
    --- The maximum number of characters allowed in a single chat message.
    --- Messages exceeding this limit are rejected server-side with a warning.
    ---
    --- Default: 256
    maxMessageLength = 256,

    --- Message cooldown
    ---
    --- The minimum time (in milliseconds) between two messages from the same player.
    --- Messages sent before the cooldown has elapsed are silently dropped.
    --- Prevents chat flooding and spam.
    ---
    --- Set to 0 to disable cooldown.
    ---
    --- Default: 1000 (1 second)
    messageCooldown = 1000,
}
