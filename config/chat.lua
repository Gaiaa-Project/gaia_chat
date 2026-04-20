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

    --- Allow plain chat messages
    ---
    --- When true, players can send regular chat messages (normal behavior).
    --- When false, only commands (messages starting with commandPrefix) are allowed;
    --- plain messages are rejected with a warning.
    ---
    --- Default: true
    allowMessages = true,
}
