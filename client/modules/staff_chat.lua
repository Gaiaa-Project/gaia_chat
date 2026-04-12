local staffMode = false

--- Check if the staff chat mode is active.
---@return boolean active Whether staff mode is active.
function IsStaffMode()
    return staffMode
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= 'gaia_core' then return end

    local Gaia <const> = GetGaia()
    if not Gaia then return end

    Gaia.command.register('staffchat', function()
        if staffMode then return end
        TriggerServerEvent('gaia_chat:server:toggleStaffChat')
    end, {
        description = 'Toggle the staff chat channel',
    })
end)

RegisterNetEvent('gaia_chat:client:setStaffMode', function(enabled)
    staffMode = enabled
    SendNUIMessage({ action = 'setStaffMode', data = { enabled = enabled } })

    if enabled then
        SendNUIMessage({ action = 'show', data = {} })
        SendNUIMessage({ action = 'focus', data = {} })
        SetNuiFocus(true, false)
    end
end)

RegisterNetEvent('gaia_chat:client:addStaffMessage', function(data)
    if not data or not data.content then return end
    SendNUIMessage({
        action = 'addStaffMessage',
        data = {
            id = tostring(GetGameTimer()) .. tostring(math.random(1000, 9999)),
            type = data.type or 'system',
            content = data.content,
            icon = data.icon,
            timestamp = nil,
        },
    })
end)

RegisterNetEvent('gaia_chat:client:staffMessage', function(data)
    local isLocal <const> = data.authorId == GetPlayerServerId(PlayerId())
    local id <const> = tostring(GetGameTimer()) .. tostring(data.authorId)
    local author <const> = isLocal and '__self__' or data.author

    SendNUIMessage({
        action = 'addStaffMessage',
        data = {
            id = id,
            type = 'player',
            author = author,
            content = data.content,
            prefix = data.role,
            prefixColor = '#f43f5e',
            timestamp = nil,
        },
    })

    if not staffMode then
        SendNUIMessage({
            action = 'addMessage',
            data = {
                id = id .. '_public',
                type = 'player',
                author = author,
                content = data.content,
                prefix = 'STAFF',
                prefixColor = '#f43f5e',
                timestamp = nil,
            },
        })
    end
end)

RegisterNUICallback('exitStaffMode', function(_, cb)
    staffMode = false
    SendNUIMessage({ action = 'setStaffMode', data = { enabled = false } })
    SendNUIMessage({
        action = 'addStaffMessage',
        data = {
            id = tostring(GetGameTimer()) .. tostring(math.random(1000, 9999)),
            type = 'system',
            icon = 'mdi-shield-off',
            content = 'Staff chat disabled — You are back to the public chat.',
            timestamp = nil,
        },
    })
    cb({})
end)
