local cooldowns = {}
local hooks = {}
local hookIdCounter = 0

local PRIORITY_ORDER <const> = {
    early = 0,
    normal = 1,
    late = 2,
}

--- Sanitize a string to prevent HTML/XSS injection.
---@param input string The raw string.
---@return string sanitized The escaped string.
function sanitize(input)
    return input
        :gsub('&', '&amp;')
        :gsub('<', '&lt;')
        :gsub('>', '&gt;')
        :gsub('"', '&quot;')
        :gsub("'", '&#39;')
end

--- Sort hooks by priority order.
local function sortHooks()
    table.sort(hooks, function(a, b)
        return PRIORITY_ORDER[a.priority] < PRIORITY_ORDER[b.priority]
    end)
end

--- Run all hooks against a message context.
---@param ctx table The message context { source, author, content, cancelled, metadata }.
---@return boolean allowed Whether the message should be sent (not cancelled).
local function runHooks(ctx)
    for i = 1, #hooks do
        if ctx.cancelled then return false end

        local hook <const> = hooks[i]
        local ok <const>, result = pcall(hook.handler, ctx)

        if not ok then
            print(('^3[gaia_chat] Hook \'%s\' from \'%s\' threw an error: %s^0'):format(hook.id, hook.resource, result))
        elseif result == false then
            ctx.cancelled = true
            return false
        end
    end

    return not ctx.cancelled
end

--- Send a warning message to a specific player.
---@param playerId number The player server ID.
---@param message string The warning message.
local function sendWarning(playerId, message)
    TriggerClientEvent('gaia_chat:client:receiveMessage', playerId, {
        author = '__system__',
        authorId = 0,
        content = message,
        type = 'warning',
    })
end

--- Register a hook to intercept, modify, or block chat messages.
--- Returns a hook ID that can be used to remove the hook later.
---
--- Usage from another resource:
---   local hookId = exports.gaia_chat:registerHook(function(ctx)
---       ctx.author = '[Admin] ' .. ctx.author
---   end, { priority = 'normal' })
---
--- Context fields:
---   ctx.source    (number)  — The player server ID.
---   ctx.author    (string)  — The player name (modifiable).
---   ctx.content   (string)  — The message content (modifiable).
---   ctx.cancelled (boolean) — Set to true or return false to block the message.
---   ctx.metadata  (table)   — Free table to pass data between hooks.
---
--- Priorities: 'early', 'normal' (default), 'late'
---@param handler function The hook handler function.
---@param options? table Hook options { priority? }.
---@return string hookId The unique hook ID.
exports('registerHook', function(handler, options)
    hookIdCounter = hookIdCounter + 1
    local id <const> = ('hook_%d'):format(hookIdCounter)
    local resource <const> = GetInvokingResource() or 'unknown'

    hooks[#hooks + 1] = {
        id = id,
        resource = resource,
        priority = (options and options.priority) or 'normal',
        handler = handler,
    }

    sortHooks()

    return id
end)

--- Remove a previously registered hook by its ID.
---@param hookId string The hook ID returned by registerHook.
---@return boolean removed Whether the hook was found and removed.
exports('removeHook', function(hookId)
    for i = #hooks, 1, -1 do
        if hooks[i].id == hookId then
            table.remove(hooks, i)
            return true
        end
    end
    return false
end)

AddEventHandler('onResourceStop', function(resourceName)
    for i = #hooks, 1, -1 do
        if hooks[i].resource == resourceName then
            table.remove(hooks, i)
        end
    end
end)

RegisterNetEvent('gaia_chat:server:sendMessage', function(content)
    local src <const> = source

    if type(content) ~= 'string' then return end

    local trimmed <const> = content:match('^%s*(.-)%s*$')
    if not trimmed or #trimmed == 0 then return end

    if ChatConfig.messageCooldown > 0 then
        local now <const> = GetGameTimer()
        local lastSent <const> = cooldowns[src]

        if lastSent and now - lastSent < ChatConfig.messageCooldown then
            local remaining <const> = math.ceil((ChatConfig.messageCooldown - (now - lastSent)) / 1000)
            sendWarning(src, T('message_too_fast', remaining))
            return
        end

        cooldowns[src] = now
    end

    local playerName <const> = GetPlayerName(tostring(src))
    if not playerName then return end

    if #trimmed > ChatConfig.maxMessageLength then
        sendWarning(src, T('message_too_long', ChatConfig.maxMessageLength))
        return
    end

    local ctx = {
        source = src,
        author = playerName,
        content = trimmed,
        cancelled = false,
        metadata = {},
    }

    if not runHooks(ctx) then return end

    TriggerClientEvent('gaia_chat:client:receiveMessage', -1, {
        author = sanitize(ctx.author),
        authorId = src,
        content = sanitize(ctx.content),
    })
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)
