local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Utility = {}

local playersData = {}

function Utility:getCharacter(player)
    local playerData = playersData[player]
    if not playerData then
        return nil
    end
    
    return playerData.character, playerData.maxHealth, playerData.health, playerData.rootPart
end

function Utility:isTeamMate(player)
    local playerData = playersData[player]
    local localPlayer = Players.LocalPlayer
    if not playerData or not localPlayer then
        return false
    end
    
    return playerData.team == localPlayer.Team
end

function Utility:getRootPart(player)
    local playerData = playersData[player]
    if not playerData then
        return nil
    end
    
    return playerData.rootPart
end

function Utility:listenToChildAdded(folder, listener)
    folder.ChildAdded:Connect(function(child)
        listener(child)
    end)
end

function Utility:listenToDescendantAdded(folder, listener)
    folder.DescendantAdded:Connect(function(descendant)
        listener(descendant)
    end)
end

function Utility:listenToDescendantRemoving(folder, listener)
    folder.DescendantRemoving:Connect(function(descendant)
        listener(descendant)
    end)
end

function Utility:getPlayers()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(players, player)
    end
    return players
end

function Utility:onPlayerAdded(player)
    local playerData = {}
    playerData.team = player.Team
    playersData[player] = playerData
    
    player.CharacterAdded:Connect(function()
        -- Character added logic
    end)
end

function Utility:onPlayerRemoving(player)
    playersData[player] = nil
end

-- Example function to demonstrate usage
function Utility:getClosestPlayerToPosition(position)
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for player, playerData in pairs(playersData) do
        local character = playerData.character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local distance = (rootPart.Position - position).magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer, closestDistance
end

Players.PlayerAdded:Connect(function(player)
    Utility:onPlayerAdded(player)
end)

Players.PlayerRemoving:Connect(function(player)
    Utility:onPlayerRemoving(player)
end)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
    Utility:onPlayerAdded(player)
end

return Utility
