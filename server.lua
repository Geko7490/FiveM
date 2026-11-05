local function authorized(src)
    return src > 0 and IsPlayerAceAllowed(src, Config.Ace)
end
RegisterNetEvent('vex:requestAccess', function()
    local src = source
    TriggerClientEvent('vex:access', src, authorized(src))
end)
RegisterNetEvent('vex:requestState', function(name, value)
    local src = source
    if not authorized(src) then return end
    if name ~= 'esp' and name ~= 'god' and name ~= 'speed' and name ~= 'aim' and name ~= 'coords' then return end
    if name == 'speed' then
        value = math.max(1.0, math.min(Config.MaxSpeed, tonumber(value) or 1.0))
    else
        value = value == true
    end
    TriggerClientEvent('vex:applyState', src, name, value)
end)