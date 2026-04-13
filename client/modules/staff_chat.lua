local staffMode = false

function IsStaffMode()
    return staffMode
end

RegisterCommand('staffchat', function()
    if staffMode then return end
    TriggerServerEvent('gaia_chat:server:toggleStaffChat')
end, false)

-- === TESTSTAFF WITH GAIA ===
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= 'gaia_core' then return end

    print('[gaia_chat] DEBUG: onClientResourceStart fired for gaia_core')

    SetTimeout(2000, function()
        local Gaia <const> = GetGaia()

        if not Gaia then
            print('[gaia_chat] DEBUG: GetGaia() returned nil after 2000ms')
            return
        end

        print('[gaia_chat] DEBUG: GetGaia() OK')
        print('[gaia_chat] DEBUG: Gaia.command exists: ' .. tostring(Gaia.command ~= nil))
        print('[gaia_chat] DEBUG: Gaia.command.register exists: ' .. tostring(Gaia.command and Gaia.command.register ~= nil))

        Gaia.command.register('teststaff', function()
            print('[gaia_chat] DEBUG: teststaff command executed')

            TriggerEvent('gaia_chat:client:setStaffMode', true)

            TriggerEvent('gaia_chat:client:addStaffMessage', {
                type = 'system',
                icon = 'mdi-shield-check',
                content = 'Staff chat enabled — All messages will be sent to staff members only. Press ESC to exit.',
            })

            SetTimeout(1000, function()
                TriggerEvent('gaia_chat:client:staffMessage', {
                    author = 'John Admin',
                    authorId = 999,
                    content = 'Hey team, anyone online?',
                    role = 'Administrator',
                })
            end)

            SetTimeout(2500, function()
                TriggerEvent('gaia_chat:client:staffMessage', {
                    author = 'Sarah Mod',
                    authorId = 998,
                    content = 'Yes, just handled a report. All good now.',
                    role = 'Moderator',
                })
            end)

            SetTimeout(4000, function()
                TriggerEvent('gaia_chat:client:staffMessage', {
                    author = '__self__',
                    authorId = GetPlayerServerId(PlayerId()),
                    content = 'Nice, thanks for the update!',
                    role = 'Owner',
                })
            end)
        end, {
            description = 'Test staff chat with fake messages',
        })

        print('[gaia_chat] DEBUG: teststaff command registered via Gaia')
    end)
end)
-- === END TESTSTAFF WITH GAIA ===

SetTimeout(1500, function()
    TriggerEvent('gaia_chat:client:addCommand', 'staffchat', 'Toggle the staff chat channel')
    TriggerEvent('chat:removeSuggestion', '/staffchat')
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
