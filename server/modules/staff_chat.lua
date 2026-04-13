local STAFF_PERMISSION <const> = 'chat.staff'
local frameworkReady = false

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'gaia_core' then
        frameworkReady = true
    end
end)

--- Check if a player has staff chat access via the framework.
---@param sessionId number The player's server ID.
---@return boolean hasAccess Whether the player has staff chat permission.
function IsStaff(sessionId)
    if not frameworkReady then return false end

    local Gaia <const> = GetGaia()
    if not Gaia then return false end

    local character <const> = Gaia.cache.getCurrentCharacter(sessionId)
    if not character then return false end

    return character.hasPermission(STAFF_PERMISSION)
end

--- Send a staff message to all online staff members.
---@param data table The message data { author, authorId, content, role }.
local function broadcastToStaff(data)
    local Gaia <const> = GetGaia()
    if not Gaia then return end

    Gaia.cache.forEach(function(sessionId, user)
        local character <const> = user.currentCharacter
        if character and character.hasPermission(STAFF_PERMISSION) then
            TriggerClientEvent('gaia_chat:client:staffMessage', sessionId, data)
        end
    end)
end

RegisterNetEvent('gaia_chat:server:toggleStaffChat', function()
    local src <const> = source

    if not IsStaff(src) then return end

    TriggerClientEvent('gaia_chat:client:addStaffMessage', src, {
        type = 'system',
        icon = 'mdi-shield-check',
        content = 'Staff chat enabled — All messages will be sent to staff members only. Press ESC to exit.',
    })

    TriggerClientEvent('gaia_chat:client:setStaffMode', src, true)
end)

RegisterNetEvent('gaia_chat:server:staffMessage', function(content)
    local src <const> = source

    if not IsStaff(src) then return end

    if type(content) ~= 'string' then return end

    local trimmed <const> = content:match('^%s*(.-)%s*$')
    if not trimmed or #trimmed == 0 then return end

    local playerName <const> = GetPlayerName(tostring(src))
    if not playerName then return end

    local Gaia <const> = GetGaia()
    local roleName = nil
    if Gaia then
        local character <const> = Gaia.cache.getCurrentCharacter(src)
        if character then
            local role <const> = character.getPrimaryRole()
            if role then
                roleName = role.label
            end
        end
    end

    broadcastToStaff({
        author = playerName,
        authorId = src,
        content = trimmed,
        role = roleName,
    })
end)
