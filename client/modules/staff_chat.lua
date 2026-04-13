local staffMode = false
local STAFF_COLOR <const> = StyleConfig.staffColor

function IsStaffMode()
    return staffMode
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= 'gaia_core' then return end

    SetTimeout(2000, function()
        local Gaia <const> = GetGaia()
        if not Gaia then return end

        Gaia.command.register('staffchat', function()
            if staffMode then return end
            TriggerServerEvent('gaia_chat:server:toggleStaffChat')
        end, {
            description = 'Toggle the staff chat channel',
        })

    end)
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
            id = generateMessageId(),
            type = data.type or 'system',
            content = data.content,
            icon = data.icon,
            timestamp = nil,
        },
    })
end)

RegisterNetEvent('gaia_chat:client:staffMessage', function(data)
    local isLocal <const> = data.authorId == GetPlayerServerId(PlayerId())
    local id <const> = generateMessageId()
    local author <const> = isLocal and '__self__' or data.author

    SendNUIMessage({
        action = 'addStaffMessage',
        data = {
            id = id,
            type = 'player',
            author = author,
            content = data.content,
            prefix = data.role,
            prefixColor = STAFF_COLOR,
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
                prefixColor = STAFF_COLOR,
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
            id = generateMessageId(),
            type = 'system',
            icon = 'mdi-shield-off',
            content = T('staff_chat_disabled'),
            timestamp = nil,
        },
    })
    cb({})
end)
