-- Function to handle respawn
RegisterNetEvent('playerRespawn')
AddEventHandler('playerRespawn', function()
    local playerPed = PlayerPedId()
    if playerPed then
        -- Request respawn location from server
        TriggerServerEvent('getRespawnLocation')
    end
end)

-- Event to receive respawn location from server
RegisterNetEvent('respawnLocation')
AddEventHandler('respawnLocation', function(location)
    local playerPed = PlayerPedId()
    if playerPed then
        -- Set player position and health
        SetEntityCoordsNoOffset(playerPed, location.x, location.y, location.z, false, false, false)
        SetEntityHeading(playerPed, location.h)
        SetEntityHealth(playerPed, 200)
        -- Optional: Reset player inventory, armor, etc.
        TriggerEvent('playerSpawned')
    end
end)

-- Function to handle player spawning
RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
    local playerPed = PlayerPedId()
    if playerPed then
        -- Reset player health and status
        SetEntityHealth(playerPed, 200)
        -- Optional: Reset player inventory, armor, etc.
    end
end)

-- Function to apply damage from server event
RegisterNetEvent('playerTakeDamage')
AddEventHandler('playerTakeDamage', function(damage)
    local playerPed = PlayerPedId()
    if playerPed then
        local currentHealth = GetEntityHealth(playerPed)
        SetEntityHealth(playerPed, currentHealth - damage)
    end
end)
