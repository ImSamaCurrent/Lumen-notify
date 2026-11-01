-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  lumen-notify · client/main.lua                                  ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- ── KVP Keys ──────────────────────────────────────────────────────
local KVP_POSITION = 'lumen_notify_position'
local KVP_OPACITY  = 'lumen_notify_opacity'

-- ── Defaults (depuis config.lua) ──────────────────────────────────
local defaultPosition = Config.DefaultPosition or 'bottom-left'
local defaultOpacity  = Config.DefaultOpacity  or 1.0

-- ── Getters ───────────────────────────────────────────────────────
local function getPlayerPosition()
    local val = GetResourceKvpString(KVP_POSITION)
    if val and val ~= '' then return val end
    return defaultPosition
end

local function getPlayerOpacity()
    local val = GetResourceKvpFloat(KVP_OPACITY)
    if val and val > 0 then return val end
    return defaultOpacity
end

-- ── Setters ───────────────────────────────────────────────────────
local function setPlayerPosition(pos)
    local valid = {
        ['top-left'] = true, ['top-center'] = true, ['top-right'] = true,
        ['bottom-left'] = true, ['bottom-center'] = true, ['bottom-right'] = true,
    }
    if not valid[pos] then
        print('^1[lumen-notify] Invalid position: ' .. tostring(pos) .. '^0')
        return
    end
    SetResourceKvp(KVP_POSITION, pos)
    SendNUIMessage({ action = 'setPlayerPosition', position = pos })
end

local function setPlayerOpacity(opacity)
    opacity = tonumber(opacity) or 1.0
    if opacity < 0.1 then opacity = 0.1 end
    if opacity > 1.0 then opacity = 1.0 end
    SetResourceKvpFloat(KVP_OPACITY, opacity + 0.0)
    SendNUIMessage({ action = 'setPlayerOpacity', opacity = opacity })
end

-- ── Init NUI avec les préférences joueur ──────────────────────────
Citizen.CreateThread(function()
    Wait(500)
    SendNUIMessage({
        action               = 'initSettings',
        position             = getPlayerPosition(),
        opacity              = getPlayerOpacity(),
        defaultDuration      = Config.DefaultDuration       or 5000,
        defaultProgressColor = Config.DefaultProgressColor  or '#6366f1',
        maxVisible           = Config.MaxVisible            or 4,
    })
end)

-- ── Send Notify ───────────────────────────────────────────────────
local function sendNotify(data)
    -- Si la notif n'a pas de position définie, on utilise celle du joueur
    if not data.position then
        data.position = getPlayerPosition()
    end
    SendNUIMessage({
        action = 'notify',
        data   = data,
    })
end

-- ── Exports ───────────────────────────────────────────────────────

exports('notify', function(text, duration, position)
    sendNotify({
        type     = 'normal',
        text     = text,
        duration = duration or 5000,
        position = position or nil, -- nil = utilise la préférence joueur
    })
end)

exports('notifyAdvanced', function(options)
    sendNotify({
        type            = 'advanced',
        backgroundColor = options.backgroundColor or nil,
        progressColor   = options.progressColor   or nil,
        backgroundImage = options.backgroundImage or nil,
        logo            = options.logo or nil,
        title           = options.title or nil,
        subtitle        = options.subtitle or nil,
        text            = options.text or nil,
        duration        = options.duration or 5000,
        position        = options.position or nil,
    })
end)

exports('setNotifyPosition', function(pos)
    setPlayerPosition(pos)
end)

exports('getNotifyPosition', function()
    return getPlayerPosition()
end)

exports('setNotifyOpacity', function(opacity)
    setPlayerOpacity(opacity)
end)

exports('getNotifyOpacity', function()
    return getPlayerOpacity()
end)

-- ── Events client ─────────────────────────────────────────────────

RegisterNetEvent('lumen-notify:notify', function(text, duration, position)
    sendNotify({
        type     = 'normal',
        text     = text,
        duration = duration or 5000,
        position = position or nil,
    })
end)

RegisterNetEvent('lumen-notify:notifyAdvanced', function(options)
    sendNotify({
        type            = 'advanced',
        backgroundColor = options.backgroundColor or nil,
        progressColor   = options.progressColor   or nil,
        backgroundImage = options.backgroundImage or nil,
        logo            = options.logo or nil,
        title           = options.title or nil,
        subtitle        = options.subtitle or nil,
        text            = options.text or nil,
        duration        = options.duration or 5000,
        position        = options.position or nil,
    })
end)

RegisterNetEvent('lumen-notify:setPosition', function(pos)
    setPlayerPosition(pos)
end)

RegisterNetEvent('lumen-notify:setOpacity', function(opacity)
    setPlayerOpacity(opacity)
end)

-- ── Watcher minimap / bigmap ───────────────────────────────────────
local function getMapState()
    if IsBigmapActive() then return 'bigmap' end
    if IsMinimapRendering() then return 'minimap' end
    return 'normal'
end

local function buildOffsets(state)
    local cfg = Config.MinimapOffsets and Config.MinimapOffsets[state]
    if not cfg then return {} end
    return {
        ['top-left']      = cfg['top-left']      or 20,
        ['top-center']    = cfg['top-center']     or 20,
        ['top-right']     = cfg['top-right']      or 20,
        ['bottom-left']   = cfg['bottom-left']    or 20,
        ['bottom-center'] = cfg['bottom-center']  or 20,
        ['bottom-right']  = cfg['bottom-right']   or 20,
    }
end

Citizen.CreateThread(function()
    local lastState = nil
    while true do
        Wait(500)
        local state = getMapState()
        if state ~= lastState then
            lastState = state
            SendNUIMessage({
                action     = 'mapState',
                state      = state,
                offsets    = buildOffsets(state),
                hideAll    = (state == 'bigmap' and (Config.HideOnBigmap == true)),
            })
        end
    end
end)
