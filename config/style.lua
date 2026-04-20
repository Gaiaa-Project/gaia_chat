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

    --- Command suggestions border color
    ---
    --- The border color of the suggestions container.
    --- Uses hexadecimal with optional opacity (e.g., '#10b98150').
    ---
    --- Default: '#10b98150'
    commandBorderColor = '#10b98150',

    --- Command suggestions separator color
    ---
    --- The color of the separator line between two suggestions.
    ---
    --- Default: '#04785799'
    commandSeparatorColor = '#04785799',

    --- Command selected suggestion background
    ---
    --- The background color of the currently selected suggestion.
    ---
    --- Default: '#10b9811a'
    commandSelectedBgColor = '#10b9811a',

    --- Command prefix color
    ---
    --- The color of the prefix character ('/') displayed in each suggestion row.
    ---
    --- Default: '#10b98199'
    commandPrefixColor = '#10b98199',

    --- Command active parameter color
    ---
    --- The color of the parameter currently being filled in the chat input.
    ---
    --- Default: '#34d399'
    commandActiveParamColor = '#34d399',

    --- Command scrollbar color
    ---
    --- The color of the suggestions list scrollbar thumb.
    ---
    --- Default: '#34d39926'
    commandScrollbarColor = '#34d39926',

    --- Chat position
    ---
    --- The position of the chat window on screen.
    ---
    --- Available: 'top-left', 'top-center', 'top-right',
    ---            'center-left', 'center', 'center-right',
    ---            'bottom-left', 'bottom-center', 'bottom-right'
    ---
    --- Default: 'top-left'
    chatPosition = 'top-left',
}
