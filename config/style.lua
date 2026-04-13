StyleConfig = {
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

    --- Chat background color
    ---
    --- The background color of the chat window.
    --- Uses CSS rgba format for transparency support.
    ---
    --- Default: 'rgba(0,10,8,0.85)'
    backgroundColor = 'rgba(0,10,8,0.85)',

    --- Chat border color (normal mode)
    ---
    --- The border color of the chat in normal mode.
    --- Uses hexadecimal with optional opacity (e.g., '#34d39950' for 50% opacity).
    ---
    --- Default: '#34d39950'
    borderColor = '#34d39950',

    --- Chat border color (staff mode)
    ---
    --- The border color of the chat when staff mode is active.
    ---
    --- Default: '#f43f5e80'
    staffBorderColor = '#f43f5e80',

    --- Staff prefix/role color
    ---
    --- The color used for the "STAFF" prefix and role labels
    --- in staff chat messages.
    ---
    --- Default: '#f43f5e'
    staffColor = '#f43f5e',

    --- Empty state text color
    ---
    --- The color of placeholder text when there are no messages
    --- or no commands available.
    ---
    --- Default: '#ffffff'
    emptyTextColor = '#ffffff',

    --- Global text color
    ---
    --- The default color for message content text.
    ---
    --- Default: '#d4d4d8'
    textColor = '#d4d4d8',
}
