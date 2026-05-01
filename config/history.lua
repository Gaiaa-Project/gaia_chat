HistoryConfig = {
    --- Enable input history
    ---
    --- When true, every message and command sent by the player is recorded
    --- into a local history. The player can then navigate previous entries
    --- using the Up/Down arrow keys while focused on the chat input.
    ---
    --- Important: input history is only active when ChatConfig.inputMode is
    --- set to 'keyboard_mouse'. In keyboard-only mode the arrow keys are
    --- already used for navigating command suggestions, so the history is
    --- intentionally ignored even if this option is set to true.
    ---
    --- Default: true
    enable = true,

    --- History size
    ---
    --- The maximum number of entries kept in the input history.
    --- Once the limit is reached, the oldest entry is dropped to make room
    --- for the newest one (FIFO).
    ---
    --- Default: 20
    limit = 20,
}
