PassiveConfig = {
    --- Passive mode
    ---
    --- Controls how the passive chat behaves when messages are received
    --- while the chat is closed.
    ---
    --- 'dynamic': Messages appear in a mini chat overlay, stay for
    ---   passiveDuration ms, then fade out individually.
    ---
    --- 'hidden': No passive chat. Messages are only visible when
    ---   the player opens the chat manually.
    ---
    --- Default: 'dynamic'
    mode = 'dynamic',

    --- Passive message duration
    ---
    --- How long (in milliseconds) a message stays visible in the
    --- passive chat before fading out.
    --- Only applies when the chat is closed and mode is 'dynamic'.
    ---
    --- Default: 10000 (10 seconds)
    duration = 10000,
}
