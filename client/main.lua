local isChatOpen = false
local savedPassiveMode <const> = GetResourceKvpString('gaia_chat:passiveMode')
local savedHistory <const> = GetResourceKvpString('gaia_chat:commandHistory')
local commandHistory = savedHistory and json.decode(savedHistory) or {}
local currentPassiveMode = savedPassiveMode or PassiveConfig.mode
local lastToggleTime = 0

--- Save a command to the KVP history.
---@param command string The full command string including prefix.
local function saveCommandToHistory(command)
    for i = #commandHistory, 1, -1 do
        if commandHistory[i] == command then
            table.remove(commandHistory, i)
        end
    end

    commandHistory[#commandHistory + 1] = command

    if #commandHistory > HistoryConfig.maxCommands then
        table.remove(commandHistory, 1)
    end

    SetResourceKvp('gaia_chat:commandHistory', json.encode(commandHistory))
end

--- Send the full config to the NUI.
local function sendConfig()
    SendNUIMessage({
        action = 'setConfig',
        data = {
            commandPrefix = ChatConfig.commandPrefix,
            maxMessages = ChatConfig.maxMessages,
            maxMessageLength = ChatConfig.maxMessageLength,
            messageCooldown = ChatConfig.messageCooldown,
            passiveDuration = PassiveConfig.duration,
            passiveMode = currentPassiveMode,
            authorColor = ChatConfig.authorColor,
        },
    })
end

--- Send the command history to the NUI.
local function sendHistory()
    SendNUIMessage({
        action = 'setCommandHistory',
        data = commandHistory,
    })
end

--- Get the local player server ID.
---@return number serverId The local player server ID.
local function getLocalPlayerId()
    return GetPlayerServerId(PlayerId())
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    sendConfig()
end)

RegisterNetEvent('gaia_chat:client:addCommand', function(name, description)
    local cmdName <const> = name:sub(1, 1) == '/' and name:sub(2) or name
    SendNUIMessage({
        action = 'addCommand',
        data = { name = cmdName, help = description },
    })
end)

RegisterNetEvent('gaia_chat:client:addSuggestion', function(name, params)
    local cmdName <const> = name:sub(1, 1) == '/' and name:sub(2) or name
    SendNUIMessage({
        action = 'updateCommandParams',
        data = { name = cmdName, params = params or {} },
    })
end)

RegisterNetEvent('gaia_chat:client:removeCommand', function(name)
    local cmdName <const> = name:sub(1, 1) == '/' and name:sub(2) or name
    SendNUIMessage({
        action = 'removeCommand',
        data = { name = cmdName },
    })
end)

RegisterNetEvent('chat:addSuggestion', function(name, help, params)
    local cmdName <const> = name:sub(1, 1) == '/' and name:sub(2) or name
    TriggerEvent('gaia_chat:client:addCommand', cmdName, help)
    if params and #params > 0 then
        TriggerEvent('gaia_chat:client:addSuggestion', cmdName, params)
    end
end)

RegisterNetEvent('chat:removeSuggestion', function(name)
    TriggerEvent('gaia_chat:client:removeCommand', name)
end)

RegisterNetEvent('gaia_chat:client:addMessage', function(data)
    if not data or not data.content then return end
    SendNUIMessage({
        action = 'addMessage',
        data = {
            id = nil .. tostring(math.random(1000, 9999)),
            type = data.type or 'system',
            content = data.content,
            author = data.author,
            authorColor = data.authorColor,
            icon = data.icon,
            prefix = data.prefix,
            prefixColor = data.prefixColor,
            timestamp = nil,
        },
    })
end)

RegisterNetEvent('chat:addMessage', function(data)
    if type(data) == 'string' then
        TriggerEvent('gaia_chat:client:addMessage', { content = data })
        return
    end
    if data.args then
        local author = #data.args > 1 and data.args[1] or nil
        local content = #data.args > 1 and table.concat(data.args, ' ', 2) or (data.args[1] or '')
        TriggerEvent('gaia_chat:client:addMessage', {
            type = author and 'player' or 'system',
            content = content,
            author = author,
        })
    end
end)

RegisterNetEvent('gaia_chat:client:receiveMessage', function(data)
    local isLocal <const> = data.authorId == getLocalPlayerId()
    local msgType <const> = data.type or 'player'

    SendNUIMessage({
        action = 'addMessage',
        data = {
            id = nil .. tostring(data.authorId),
            type = msgType,
            author = msgType == 'player' and (isLocal and '__self__' or data.author) or nil,
            content = data.content,
            timestamp = nil,
        },
    })
end)

RegisterNetEvent('gaia_chat:client:clear', function()
    SendNUIMessage({ action = 'clearMessages', data = {} })
end)

RegisterNetEvent('chat:clear', function()
    SendNUIMessage({ action = 'clearMessages', data = {} })
end)

RegisterCommand('+gaia_chat_open', function()
    if isChatOpen then return end
    isChatOpen = true

    sendHistory()
    SendNUIMessage({ action = 'show', data = {} })
    SendNUIMessage({ action = 'focus', data = {} })
    SetNuiFocus(true, false)
end, false)

RegisterCommand('-gaia_chat_open', function() end, false)

RegisterKeyMapping('+gaia_chat_open', 'Open Chat', 'keyboard', KeybindsConfig.toggleKey)

RegisterCommand('+gaia_chat_toggle_passive', function()
    local now <const> = GetGameTimer()
    if now - lastToggleTime < 2000 then return end
    lastToggleTime = now

    currentPassiveMode = currentPassiveMode == 'dynamic' and 'hidden' or 'dynamic'
    SetResourceKvp('gaia_chat:passiveMode', currentPassiveMode)

    SendNUIMessage({
        action = 'setConfig',
        data = {
            commandPrefix = ChatConfig.commandPrefix,
            passiveMode = currentPassiveMode,
        },
    })

    SendNUIMessage({
        action = 'showToast',
        data = {
            text = currentPassiveMode == 'dynamic' and 'Chat: Dynamic' or 'Chat: Hidden',
        },
    })
end, false)

RegisterCommand('-gaia_chat_toggle_passive', function() end, false)

RegisterKeyMapping('+gaia_chat_toggle_passive', 'Toggle Chat Passive Mode', 'keyboard', KeybindsConfig.passiveToggleKey)

SetTimeout(500, function()
    TriggerEvent('chat:removeSuggestion', '/+gaia_chat_open')
    TriggerEvent('chat:removeSuggestion', '/-gaia_chat_open')
    TriggerEvent('chat:removeSuggestion', '/+gaia_chat_toggle_passive')
    TriggerEvent('chat:removeSuggestion', '/-gaia_chat_toggle_passive')
end)

RegisterNUICallback('chatMessage', function(data, cb)
    local message <const> = data.message and data.message:match('^%s*(.-)%s*$')

    if message and #message > 0 then
        if message:sub(1, #ChatConfig.commandPrefix) == ChatConfig.commandPrefix then
            saveCommandToHistory(message)
            isChatOpen = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'hide', data = {} })
            ExecuteCommand(message:sub(#ChatConfig.commandPrefix + 1))
        else
            TriggerServerEvent('gaia_chat:server:sendMessage', message)
        end
    end

    cb({})
end)

RegisterNUICallback('closeChat', function(_, cb)
    isChatOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide', data = {} })
    cb({})
end)
