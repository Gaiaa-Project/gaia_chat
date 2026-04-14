local isChatOpen = false
local savedPassiveMode <const> = GetResourceKvpString('gaia_chat:passiveMode')
local currentPassiveMode = savedPassiveMode or PassiveConfig.mode
local lastToggleTime = 0

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
            authorColor = StyleConfig.authorColor,
            backgroundColor = StyleConfig.backgroundColor,
            borderColor = StyleConfig.borderColor,
            staffBorderColor = StyleConfig.staffBorderColor,
            staffColor = StyleConfig.staffColor,
            emptyTextColor = StyleConfig.emptyTextColor,
            textColor = StyleConfig.textColor,
            chatPosition = StyleConfig.chatPosition,
        },
    })
end

--- Generate a unique message ID.
---@return string id The unique ID.
function generateMessageId()
    return tostring(GetGameTimer()) .. tostring(math.random(1000, 9999))
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
            id = generateMessageId(),
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
            id = generateMessageId(),
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
            text = T(currentPassiveMode == 'dynamic' and 'passive_mode_dynamic' or 'passive_mode_hidden'),
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
            isChatOpen = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'hide', data = {} })
            ExecuteCommand(message:sub(#ChatConfig.commandPrefix + 1))
        else
            if IsStaffMode and IsStaffMode() then
                TriggerServerEvent('gaia_chat:server:staffMessage', message)
            else
                TriggerServerEvent('gaia_chat:server:sendMessage', message)
            end
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
