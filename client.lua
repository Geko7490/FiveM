local permitted, open = false, false
local settings = {esp=false, god=false, speed=1.0, aim=false}
local markers = {}
local outlines = {}
local modules = {coords=false}
local function sendState()
    SendNUIMessage({type='state', settings=settings, maxSpeed=Config.MaxSpeed})
end
local function reset()
    settings = {esp=false, god=false, speed=1.0, aim=false}
    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    for _, blip in pairs(markers) do if DoesBlipExist(blip) then RemoveBlip(blip) end end
    markers = {}
    for ped in pairs(outlines) do if DoesEntityExist(ped) then SetEntityDrawOutline(ped, false) end end
    outlines = {}
    modules.coords = false
end
RegisterCommand(Config.Command, function()
    if open then
        open = false
        SetNuiFocus(false, false)
        SendNUIMessage({type='visible', value=false})
    else
        TriggerServerEvent('vex:requestAccess')
    end
end, false)
RegisterNetEvent('vex:access', function(ok)
    permitted = ok == true
    if not permitted then
        reset()
        print('[VEX] Access denied. Configure ACE permission.')
        return
    end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({type='visible', value=true})
    sendState()
end)
RegisterNetEvent('vex:applyState', function(name, value)
    if not permitted then return end
    settings[name] = value
    if name == 'god' then
        SetEntityInvincible(PlayerPedId(), value)
        SetPlayerInvincible(PlayerId(), value)
    elseif name == 'coords' then
        modules.coords = value
    elseif name == 'speed' then
        SetRunSprintMultiplierForPlayer(PlayerId(), value)
    end
    sendState()
end)
RegisterNUICallback('close', function(_, cb)
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({type='visible', value=false})
    cb({ok=true})
end)
RegisterNUICallback('change', function(data, cb)
    if not permitted or type(data) ~= 'table' then cb({ok=false}); return end
    TriggerServerEvent('vex:requestState', data.name, data.value)
    cb({ok=true})
end)
CreateThread(function()
    while true do
        Wait(500)
        if permitted and settings.god then
            SetEntityInvincible(PlayerPedId(), true)
            SetPlayerInvincible(PlayerId(), true)
        end
        if permitted and settings.esp then
            local ownPed = PlayerPedId()
            local pos = GetEntityCoords(ownPed)
            local active = {}
            local visiblePeds = {}
            for _, player in ipairs(GetActivePlayers()) do
                if player ~= PlayerId() then
                    local ped = GetPlayerPed(player)
                    if DoesEntityExist(ped) and #(GetEntityCoords(ped)-pos) < Config.EspDistance then
                        local id = GetPlayerServerId(player)
                        active[id] = true
                        visiblePeds[ped] = true
                        if not outlines[ped] then
                            SetEntityDrawOutlineColor(155, 100, 255, 220)
                            SetEntityDrawOutlineShader(1)
                            SetEntityDrawOutline(ped, true)
                            outlines[ped] = true
                        end
                        if not markers[id] or not DoesBlipExist(markers[id]) then
                            markers[id] = AddBlipForEntity(ped)
                            SetBlipSprite(markers[id], 1)
                            SetBlipColour(markers[id], 3)
                            SetBlipScale(markers[id], 0.7)
                        end
                    end
                end
            end
            for ped in pairs(outlines) do
                if not visiblePeds[ped] then
                    if DoesEntityExist(ped) then SetEntityDrawOutline(ped, false) end
                    outlines[ped] = nil
                end
            end
            for id, blip in pairs(markers) do
                if not active[id] then if DoesBlipExist(blip) then RemoveBlip(blip) end markers[id]=nil end
            end
        else
            for ped in pairs(outlines) do if DoesEntityExist(ped) then SetEntityDrawOutline(ped, false) end outlines[ped] = nil end
            for id, blip in pairs(markers) do if DoesBlipExist(blip) then RemoveBlip(blip) end markers[id]=nil end
        end
    end
end)
-- Aim training: a visible crosshair guide for manual NPC target practice, not automatic targeting.
CreateThread(function()
    while true do
        if permitted and settings.aim and IsPlayerFreeAiming(PlayerId()) then
            Wait(0)
            DrawRect(0.5,0.5,0.002,0.022,166,127,255,190)
            DrawRect(0.5,0.5,0.012,0.002,166,127,255,190)
        else Wait(250) end
    end
end)
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        reset()
        SetNuiFocus(false,false)
    end
end)
-- Built-in, reviewed Lua module: position HUD. Arbitrary uploaded Lua is not executed.
CreateThread(function()
    while true do
        if permitted and modules.coords then
            Wait(0)
            local p = GetEntityCoords(PlayerPedId())
            SetTextFont(4)
            SetTextScale(0.0, 0.34)
            SetTextColour(190, 160, 255, 240)
            SetTextOutline()
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(('X %.1f  Y %.1f  Z %.1f'):format(p.x,p.y,p.z))
            EndTextCommandDisplayText(0.02, 0.85)
        else Wait(300) end
    end
end)
