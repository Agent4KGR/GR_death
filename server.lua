-- Initialize player data
local playerData = {}

-- Define customizable respawn locations (example positions)
local respawnLocations = {
    { x = 200.0, y = -900.0, z = 30.0, h = 180.0 },
    { x = 400.0, y = -800.0, z = 35.0, h = 90.0 },
    { x = 600.0, y = -700.0, z = 40.0, h = 45.0 }
}

-- Discord webhook URL (replace with your actual webhook URL)
local discordWebhookURL = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL'

-- Function to log messages to the console and Discord
local function logMessage(message)
    print(message)
    
    -- Send log message to Discord
    PerformHttpRequest(discordWebhookURL, function(err, text, headers) 
        -- You can handle response or errors here if needed
    end, 'POST', json.encode({ 
        content = message,
        username = 'FiveM Server Logger'
    }), { ['Content-Type'] = 'application/json' })
end

-- Event when a player spawns
AddEventHandler('playerSpawned', function()
    local source = source
    playerData[source] = {
        health = 200, -- Max health for the player
        isAlive = true,
        respawnLocation = respawnLocations[math.random(#respawnLocations)] -- Random respawn location
    }
    TriggerClientEvent('chat:addMessage', source, {
        args = { "[INFO]", "Welcome! You have spawned with full health." }
    })
end)

-- Event when a player takes damage
RegisterNetEvent('playerTakeDamage')
AddEventHandler('playerTakeDamage', function(damage)
    local source = source
    if playerData[source] and playerData[source].isAlive then
        playerData[source].health = playerData[source].health - damage
        logMessage("Player " .. source .. " takes " .. damage .. " damage. Health: " .. playerData[source].health)
        if playerData[source].health <= 0 then
            playerData[source].health = 0
            playerData[source].isAlive = false
            logMessage("Player " .. source .. " has died.")
            TriggerClientEvent('chat:addMessage', source, {
                args = { "[INFO]", "You have died. Respawning..." }
            })
            TriggerEvent('playerDied', source)
        end
    end
end)

-- Event when a player dies
AddEventHandler('playerDied', function(playerId)
    -- Log and handle player death
    Citizen.Wait(10000)  -- Delay before respawn (10 seconds)
    -- Send respawn command to client
    TriggerClientEvent('playerRespawn', playerId)
end)

-- Command to apply damage for testing
RegisterCommand('damage', function(source, args, rawCommand)
    local damage = tonumber(args[1])
    if damage then
        TriggerEvent('playerTakeDamage', damage)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { "[ERROR]", "Invalid damage amount." }
        })
    end
end, false)

-- Command to heal a player for testing
RegisterCommand('heal', function(source, args, rawCommand)
    local healAmount = tonumber(args[1])
    if healAmount then
        local player = playerData[source]
        if player and player.isAlive then
            player.health = math.min(player.health + healAmount, 200)
            TriggerClientEvent('chat:addMessage', source, {
                args = { "[INFO]", "You have been healed by " .. healAmount .. ". Health: " .. player.health }
            })
            logMessage("Player " .. source .. " healed by " .. healAmount .. ". Health: " .. player.health)
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = { "[ERROR]", "You are not alive or invalid player data." }
            })
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { "[ERROR]", "Invalid heal amount." }
        })
    end
end, false)

-- Event to get respawn location
RegisterNetEvent('getRespawnLocation')
AddEventHandler('getRespawnLocation', function()
    local source = source
    if playerData[source] then
        TriggerClientEvent('respawnLocation', source, playerData[source].respawnLocation)
    end
end)
