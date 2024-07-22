local Notification = sharedRequire('Notifications.lua');
local Players = game:GetService("Players")

local function checkPlayerForVoidwalker(player)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("Talent:Voideye")
        if tool then
            Notification.new({
                text = player.Name .. " is a voidwalker",
                duration = 5
            })
        end
    end
end

local function onPlayerAdded(player)
    -- Check the player when they join the game
    checkPlayerForVoidwalker(player)

    -- Also check when the player's backpack changes
    player.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then
            child.ChildAdded:Connect(function(tool)
                if tool.Name == "Talent:Voideye" then
                    Notification.new({
                        text = player.Name .. " is a voidwalker",
                        duration = 5
                    })
                end
            end)
        end
    end)
end

-- Connect to players already in the game
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Connect to players who join the game in the future
Players.PlayerAdded:Connect(onPlayerAdded)

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait -- Only returns if the GUI has not been terminated. For 'while Wait() do' loops

local Rares = library:CreateWindow({
    Name = "Real Aztup Hub",
        Themeable = {
            Background = "6280332781",
            Transparency = 0.5
        }
})

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local playerSpectating = nil
local playerSpectatingLabel = nil
local lastUpdateAt = 0
local spectateUpdateConn = nil

-- Function to set the camera subject
local function setCameraSubject(subject)
    if subject == LocalPlayer.Character then
        playerSpectating = nil
        CollectionService:RemoveTag(LocalPlayer, 'ForcedSubject')

        if playerSpectatingLabel then
            playerSpectatingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerSpectatingLabel = nil
        end

        -- Disconnect the spectate update connection if it exists
        if spectateUpdateConn then
            spectateUpdateConn:Disconnect()
            spectateUpdateConn = nil
        end

        -- Reset camera subject to LocalPlayer
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
        return
    end

    CollectionService:AddTag(LocalPlayer, 'ForcedSubject')
    workspace.CurrentCamera.CameraSubject = subject

    -- Spawn a new update loop for spectating
    spectateUpdateConn = task.spawn(function()
        while true do
            task.wait(1)  -- Adjust update rate as needed
            if tick() - lastUpdateAt < 5 then
                continue
            end
            lastUpdateAt = tick()

            -- Perform operations when spectating, such as streaming around the camera
            task.spawn(function()
                LocalPlayer:RequestStreamAroundAsync(workspace.CurrentCamera.CFrame.Position)
            end)
        end
    end)
end

-- Connect user input event for spectating
UserInputService.InputBegan:Connect(function(inputObject)
    -- Ensure left mouse click and relevant UI elements are present
    if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 or not LocalPlayer:FindFirstChild('PlayerGui') or not LocalPlayer.PlayerGui:FindFirstChild('LeaderboardGui') then
        return
    end

    local newPlayerSpectating
    local newPlayerSpectatingLabel

    -- Find the player to spectate in the leaderboard GUI
    for _, v in ipairs(LocalPlayer.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame:GetChildren()) do
        if v:IsA('Frame') and v:FindFirstChild('Player') and v.Player.TextTransparency ~= 0 then
            newPlayerSpectating = v.Player.Text
            newPlayerSpectatingLabel = v.Player
            break
        end
    end

    if not newPlayerSpectating then
        return
    end

    -- Update spectating label color
    if playerSpectatingLabel then
        playerSpectatingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    playerSpectatingLabel = newPlayerSpectatingLabel
    playerSpectatingLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

    -- Set camera subject based on the player being spectated
    if newPlayerSpectating == playerSpectating or newPlayerSpectating == LocalPlayer.Name then
        setCameraSubject(LocalPlayer.Character)
    else
        playerSpectating = newPlayerSpectating

        -- Find the player to spectate and set camera subject accordingly
        local player = Players:FindFirstChild(playerSpectating)

        if not player or not player.Character or not player.Character.PrimaryPart then
            setCameraSubject(LocalPlayer.Character)
            return
        end

        setCameraSubject(player.Character)
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/mac2115/Cool-private/main/ESP"))()


local MainTab = Rares:CreateTab({
        Name = "Main"
})
local EspTab = Rares:CreateTab({
    Name = "Esp"
})

local APTab = Rares:CreateTab({
    Name = "Visuals"
})

local APSect = APTab:CreateSection({
    Name = "Visuals"
})
local SectiePlayer = MainTab:CreateSection({
Name = "Player"
})
local SectieFarm = MainTab:CreateSection({
        Name = "Misc"
})
local SectieEsp = EspTab:CreateSection({
    Name = "ESPS"
})

local SectieVisual = APTab:CreateSection{
    Name = "Visual"
}

local Utility = {}
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Example flags module or table
local library = {
    flags = {
        flyHackValue = 40,  -- Example flag for fly hack velocity adjustment
        flySpeedMultiplier = 3,  -- Example flag for adjusting fly speed
        ascendSpeed = 1,  -- Example flag for ascend speed
        descendSpeed = 1 -- Example flag for descend speed
    }
}

-- Example utility function to get player data
function Utility.getPlayerData()
    -- Replace with actual implementation to get player data
    return {
        rootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.PrimaryPart,
        -- Assuming you want to use the character's primary part as rootPart
    }
end

-- Fly function without using maid
local flyBv = nil
local flyHackConnection = nil

function fly(toggle)
    if toggle then
        if flyHackConnection then
            return  -- Fly hack already connected
        end

        flyBv = Instance.new('BodyVelocity')
        flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

        flyHackConnection = RunService.Heartbeat:Connect(function()
            local playerData = Utility.getPlayerData()
            local rootPart, camera = playerData.rootPart, workspace.CurrentCamera
            if not (rootPart and camera) then
                return
            end

            if not CollectionService:HasTag(flyBv, 'AllowedBM') then
                CollectionService:AddTag(flyBv, 'AllowedBM')
            end

            flyBv.Parent = rootPart

            -- Calculate movement vector based on WASD and spacebar input
            local moveVector = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + Vector3.new(0, 0, -1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector + Vector3.new(0, 0, 1)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector + Vector3.new(-1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + Vector3.new(1, 0, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0) * library.flags.ascendSpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector + Vector3.new(0, -1, 0) * library.flags.descendSpeed
            end

            -- Apply velocity to the flyBv BodyVelocity instance
            flyBv.Velocity = camera.CFrame:VectorToWorldSpace(moveVector * library.flags.flyHackValue * library.flags.flySpeedMultiplier)
        end)
    else
        if not flyHackConnection then
            return  -- Fly hack not connected
        end

        flyHackConnection:Disconnect()
        flyHackConnection = nil

        if flyBv then
            flyBv:Destroy()
            flyBv = nil
        end
    end
end

-- Integration into the GUI toggle format for Fly
local flyEnabled = false

local function toggleFly(enable)
    flyEnabled = enable
    fly(flyEnabled)
end



-- Add Toggle for Fly
SectiePlayer:AddToggle({
    Name = 'Fly',
    Default = false,
    Keybind = {
        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
     },
    Callback = function(NewValue)
        toggleFly(NewValue)
    end
})

SectiePlayer:AddSlider({
    Name = 'Fly Velocity',
    Value = flyHackValue,
    Precise = 2,
    Min = 20,
    Max = 100,   
    Callback = function(newValue)
        library.flags.flyHackValue = newValue
    end
})

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local speedHackConnection
local speedHackBv
local speedHackEnabled = false
local speedHackValue = 50  -- Default speed value

-- Function to enable or disable speed hack
local function toggleSpeedHack(toggle)
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if toggle then
        if not speedHackEnabled and humanoid and rootPart then
            speedHackBv = Instance.new('BodyVelocity')
            speedHackBv.MaxForce = Vector3.new(100000, 0, 100000)
            speedHackBv.Velocity = Vector3.new(0, 0, 0)
            CollectionService:AddTag(speedHackBv, 'AllowedBM')
            speedHackBv.Parent = rootPart

            speedHackConnection = RunService.Heartbeat:Connect(function()
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    speedHackBv.Velocity = moveDirection * speedHackValue
                else
                    speedHackBv.Velocity = Vector3.new(0, 0, 0)
                end
            end)

            speedHackEnabled = true
        end
    else
        if speedHackConnection then
            speedHackConnection:Disconnect()
            speedHackConnection = nil
        end

        if speedHackBv then
            speedHackBv:Destroy()
            speedHackBv = nil
        end

        speedHackEnabled = false
    end
end

-- Add Toggle for Speed Hack
SectiePlayer:AddToggle({
    Name = 'Speed Hack',
    Default = false,
    Keybind = {
        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
     },
    Callback = function(NewValue)
        toggleSpeedHack(NewValue)
    end
})

-- Add Slider for Speed Hack Velocity
SectiePlayer:AddSlider({
    Name = 'Speed Hack Velocity',
    Value = speedHackValue,
    Precise = 2,
    Min = 16,
    Max = 160,   
    Callback = function(newValue)
        speedHackValue = newValue
    end
})


local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local espEnabled = false -- Initial state of ESP (disabled)
local espColor = Color3.fromRGB(255, 255, 255) -- Default ESP color (white)

-- Function to create a text label for a mob
local function createESP(mob)
    -- Check if the mob has a "Blood" value and exit if it does
    if mob:FindFirstChild("Blood") then
        return
    end

    -- Check if the mob already has a text label
    if not mob:FindFirstChild("BillboardGui") then
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "BillboardGui"
        billboardGui.Adornee = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the mob's head
        billboardGui.AlwaysOnTop = true
        billboardGui.Enabled = espEnabled -- Set initial visibility based on espEnabled

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = espColor -- Set the initial text color
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14
        textLabel.Parent = billboardGui

        billboardGui.Parent = mob

        -- Function to update the text label
        local function updateLabel()
            local humanoid = mob:FindFirstChildOfClass("Humanoid")
            if humanoid then
                textLabel.Text = string.format("[%d/%d] %s", humanoid.Health, humanoid.MaxHealth, mob.Name)
            else
                textLabel.Text = mob.Name
            end
        end

        -- Initial update
        updateLabel()

        -- Update the text label whenever the humanoid's health changes
        local humanoid = mob:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthChanged:Connect(updateLabel)
        end

        -- Listen for new children to handle dynamically added humanoids
        mob.ChildAdded:Connect(function(child)
            if child:IsA("Humanoid") then
                updateLabel()
                child.HealthChanged:Connect(updateLabel)
            end
        end)
    end
end

-- Function to update ESP for all mobs
local function updateESP()
    for _, mob in pairs(workspace.Live:GetChildren()) do
        if mob:IsA("Model") and not mob:FindFirstChildOfClass("Player") then
            createESP(mob)
        end
    end
end

-- Function to toggle the visibility of all ESPs
local function toggleESP(enabled)
    espEnabled = enabled
    for _, mob in pairs(workspace.Live:GetChildren()) do
        if mob:IsA("Model") and not mob:FindFirstChildOfClass("Player") then
            local billboardGui = mob:FindFirstChild("BillboardGui")
            if billboardGui then
                billboardGui.Enabled = enabled
            end
        end
    end
end

-- Function to update the color of all ESP text labels
local function updateESPColor(color)
    espColor = color
    for _, mob in pairs(workspace.Live:GetChildren()) do
        if mob:IsA("Model") and not mob:FindFirstChildOfClass("Player") then
            local billboardGui = mob:FindFirstChild("BillboardGui")
            if billboardGui then
                local textLabel = billboardGui:FindFirstChild("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = color
                end
            end
        end
    end
end

-- Run updateESP once at the beginning
updateESP()

-- Update ESP whenever new mobs are added
workspace.Live.ChildAdded:Connect(function(child)
    if child:IsA("Model") and not child:FindFirstChildOfClass("Player") then
        createESP(child)
        if espEnabled then
            local billboardGui = child:FindFirstChild("BillboardGui")
            if billboardGui then
                billboardGui.Enabled = true
                local textLabel = billboardGui:FindFirstChild("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = espColor
                end
            end
        end
    end
end)

-- Optional: Update ESP regularly to ensure all mobs are covered, but do this less frequently to reduce performance impact
runService.Heartbeat:Connect(updateESP)

-- Example of adding a toggle button (replace with your actual UI library or method)
SectieEsp:AddToggle({
    Name = "Mob ESP",  -- Text displayed for the toggle
    Default = false,  -- Default state of the toggle (false means billboards are initially disabled)
    Callback = function(enabled)
        toggleESP(enabled)  -- Call toggleESP function with the enabled state
    end
})

-- Example of adding a color picker (replace with your actual UI library or method)
SectieEsp:AddColorPicker({
    Name = "ESP Color",  -- Text displayed for the color picker
    Default = espColor,  -- Default color (white)
    Callback = function(color)
        updateESPColor(color)  -- Call updateESPColor function with the selected color
    end
})




local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local EspEnabled = false -- Initial state of ESP (disabled)
local EspColor = Color3.fromRGB(255, 255, 255) -- Default ESP color (white)

-- Function to create a text label for an NPC
local function createESP(npc)
    -- Check if the NPC already has a text label
    if not npc:FindFirstChild("BillboardGui") then
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "BillboardGui"
        billboardGui.Adornee = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the NPC's head
        billboardGui.AlwaysOnTop = true
        billboardGui.Enabled = EspEnabled -- Set initial visibility based on EspEnabled

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = EspColor -- Set the initial text color
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14
        textLabel.Text = npc.Name
        textLabel.Parent = billboardGui

        billboardGui.Parent = npc
    end
end

-- Function to update ESP for all NPCs
local function updateESP()
    for _, npc in pairs(Workspace.NPCs:GetChildren()) do
        if npc:IsA("Model") then
            createESP(npc)
        end
    end
end

-- Function to toggle the visibility of all ESPs
local function toggleESP(enabled)
    EspEnabled = enabled
    for _, npc in pairs(Workspace.NPCs:GetChildren()) do
        if npc:IsA("Model") then
            local billboardGui = npc:FindFirstChild("BillboardGui")
            if billboardGui then
                billboardGui.Enabled = enabled
            end
        end
    end
end

-- Function to update the color of all ESP text labels
local function updateESPColor(color)
    EspColor = color
    for _, npc in pairs(Workspace.NPCs:GetChildren()) do
        if npc:IsA("Model") then
            local billboardGui = npc:FindFirstChild("BillboardGui")
            if billboardGui then
                local textLabel = billboardGui:FindFirstChild("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = color
                end
            end
        end
    end
end

-- Run updateESP once at the beginning
updateESP()

-- Update ESP whenever new NPCs are added
Workspace.NPCs.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        createESP(child)
        if EspEnabled then
            local billboardGui = child:FindFirstChild("BillboardGui")
            if billboardGui then
                billboardGui.Enabled = true
            end
        end
    end
end)

-- Optional: Update ESP regularly to ensure all NPCs are covered, but do this less frequently to reduce performance impact
RunService.Heartbeat:Connect(updateESP)

-- Example of adding a toggle button (replace with your actual UI library or method)
SectieEsp:AddToggle({
    Name = "ESP NPCs",  -- Text displayed for the toggle
    Default = false,  -- Default state of the toggle (false means billboards are initially disabled)
    Callback = function(enabled)
        toggleESP(enabled)  -- Call toggleESP function with the enabled state
    end
})

-- Example of adding a color picker (replace with your actual UI library or method)
SectieEsp:AddColorPicker({
    Name = "ESP Color",  -- Text displayed for the color picker
    Default = EspColor,  -- Default color (white)
    Callback = function(color)
        updateESPColor(color)  -- Call updateESPColor function with the selected color
    end
})

local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local espEnabled = false -- Disable ESP by default
local espColor = Color3.fromRGB(255, 255, 255) -- Default ESP color (white)
local localPlayer = players.LocalPlayer

-- Function to create a text label for a model
local function createESP(model, label)
    -- Check if the model has a RootPart
    local rootPart = model:FindFirstChild("RootPart")
    if not rootPart then
        print("No RootPart found for model:", model.Name)
        return
    end

    -- Check if the model already has a text label
    if not model:FindFirstChild("BillboardGui") then
        print("Creating ESP for model:", model.Name)
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "BillboardGui"
        billboardGui.Adornee = rootPart
        billboardGui.Size = UDim2.new(0, 200, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above the model's head
        billboardGui.AlwaysOnTop = true
        billboardGui.Enabled = espEnabled -- Set initial visibility based on espEnabled

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = espColor -- Set the initial text color
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 14
        textLabel.Parent = billboardGui

        billboardGui.Parent = model

        -- Function to update the text label
        local function updateLabel()
            local playerRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if playerRootPart then
                local distance = (playerRootPart.Position - rootPart.Position).Magnitude
                textLabel.Text = string.format("[Chest][%.0f]", distance)
            else
                textLabel.Text = "[Chest][N/A]"
            end
        end

        -- Initial update
        updateLabel()

        -- Connect the update function to the RenderStepped event
        runService.RenderStepped:Connect(updateLabel)
    else
        print("ESP already exists for model:", model.Name)
    end
end

-- Function to create ESP for all models in a given parent
local function createESPForAll(parent, label)
    for _, model in ipairs(parent:GetChildren()) do
        createESP(model, label)
    end
end

-- Function to toggle ESP
local function toggleESP(enabled, parent, label)
    espEnabled = enabled
    for _, model in ipairs(parent:GetChildren()) do
        local billboardGui = model:FindFirstChild("BillboardGui")
        if billboardGui then
            billboardGui.Enabled = enabled
        else
            createESP(model, label)
        end
    end
end

-- Function to update ESP color
local function updateESPColor(color)
    espColor = color
    for _, model in ipairs(workspace.Thrown:GetChildren()) do
        local billboardGui = model:FindFirstChild("BillboardGui")
        if billboardGui then
            local textLabel = billboardGui:FindFirstChild("TextLabel")
            if textLabel then
                textLabel.TextColor3 = color
            end
        end
    end
end

-- Create ESP for existing models in Workspace.Thrown
createESPForAll(workspace.Thrown, "Chest")

-- Connect a function to handle new models being added to Workspace.Thrown
workspace.Thrown.ChildAdded:Connect(function(model)
    wait(0.1) -- Wait a brief moment to ensure the model is fully loaded
    createESP(model, "Chest")
end)

-- UI elements for toggles and color picker
-- Replace with your actual UI library or method
SectieEsp:AddToggle({
    Name = "Chest ESP",
    Default = false,
    Callback = function(enabled)
        toggleESP(enabled, workspace.Thrown, "Chest")
    end
})

SectieEsp:AddColorPicker({
    Name = "ESP Color",
    Default = espColor,
    Callback = function(color)
        updateESPColor(color)
    end
})



local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

--// Initial ESP settings
ESP.Enabled = true;
ESP.ShowBox = true;
ESP.BoxType = "2D";
ESP.ShowName = true;
ESP.ShowHealth = true;
ESP.ShowTracer = false;
ESP.ShowDistance = true;

local EspEnabled = true
local EspColor = Color3.fromRGB(255, 255, 255) -- Default ESP color (white)

-- Function to enable ESP
function EnableESP()
    ESP.Enabled = true;
end

-- Function to disable ESP
function DisableESP()
    ESP.Enabled = false;
end

-- Function to update ESP color
function UpdateESPColor(color)
    ESP.Color = color -- Assuming the ESP library supports setting a Color property
end

-- Creating a toggle in SectieEsp
SectieEsp:AddToggle({
    Name = "Esp Players",
    Default = EspEnabled,
    Callback = function(NewValue)
        EspEnabled = NewValue
        if EspEnabled then
            EnableESP()
        else
            DisableESP()
        end
    end
})



local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local infiniteJumpHeight = 50 -- Set your desired jump height here
local infiniteJumpEnabled = false

function infiniteJump(toggle)
    infiniteJumpEnabled = toggle

    if not toggle then return end

    coroutine.wrap(function()
        while infiniteJumpEnabled do
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if rootPart and UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:GetFocusedTextBox() then
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, infiniteJumpHeight, rootPart.Velocity.Z)
            end

            task.wait(0.1)
        end
    end)()
end

-- Adding the toggle to the GUI
SectiePlayer:AddToggle({
    Name = "Infinite Jump",
    Keybind = {
        Mode = "Dynamic", -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
    },
    Value = infiniteJumpEnabled,
    Callback = function(NewValue)
        infiniteJump(NewValue)
    end
})

local NoClipEnabled = false
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local connection -- Variable to store the RunService connection
local originalCollideStates = {} -- Table to store the original CanCollide states

local function EnableNoClip()
    -- Store the original CanCollide state of each BasePart
    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            originalCollideStates[v] = v.CanCollide
        end
    end
    
    connection = RunService.Stepped:Connect(function()
        if NoClipEnabled then
            for _, v in pairs(Player.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoClip()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    -- Restore the original CanCollide state of each BasePart
    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") and originalCollideStates[v] ~= nil then
            v.CanCollide = originalCollideStates[v]
        end
    end
    -- Clear the original states table
    originalCollideStates = {}
end

SectiePlayer:AddToggle({
    Name = "NoClip",
    Keybind = {
        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
    },
    Default = NoClipEnabled,
    Callback = function(NewValue)
        NoClipEnabled = NewValue
        if NoClipEnabled then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end
})

-- Ensure necessary services are initialized
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local LocalPlayer = Players.LocalPlayer

-- Configuration variables
local spoofingEnabled = false
local spoofingConnection = nil
local oldAgilityValue = nil
local agilitySpooferValue = 100 -- Default agility spoof value

-- Function to handle agility spoofing
local function setAgilitySpoofing(enabled)
    if not enabled then
        -- Stop spoofing
        if spoofingConnection then
            spoofingConnection:Disconnect()
            spoofingConnection = nil
        end

        -- Restore original agility value if it was changed
        if oldAgilityValue then
            local agility = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Agility')
            if agility then
                agility.Value = oldAgilityValue
            end
            oldAgilityValue = nil
        end
        return
    end

    -- Start spoofing
    spoofingConnection = RunService.Heartbeat:Connect(function()
        local agility = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Agility')
        if not agility then return end

        if not oldAgilityValue then
            oldAgilityValue = agility.Value
        end

        agility.Value = agilitySpooferValue
    end)
end

-- Add a toggle for agility spoofer
SectieFarm:AddToggle({
    Name = "Agility Spoofer",

    Default = false,  -- Default state of the toggle (false means agility spoofer is initially disabled)
    Callback = function(enabled)
        spoofingEnabled = enabled
        setAgilitySpoofing(spoofingEnabled)
    end
})

-- Add a slider for adjusting agility spoof value
SectieFarm:AddSlider({
    Name = "Agility Value",
    Flag = "AgilitySpooferValue",
    Value = agilitySpooferValue,  -- Default size value
    Min = 10,  -- Minimum size value
    Max = 100,  -- Maximum size value
    Precise = 2,
    Callback = function(value)
        agilitySpooferValue = value
        if spoofingEnabled then
            setAgilitySpoofing(false)  -- Stop and restart spoofing with the new value
            setAgilitySpoofing(true)
        end
    end
})



local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

local intelligenceFarmConnection

local function intelligenceFarm(toggle)
	if not toggle then
		if intelligenceFarmConnection then
			intelligenceFarmConnection:Disconnect()
			intelligenceFarmConnection = nil
		end
		return
	end

	local lastFarmRanAt = 0

	intelligenceFarmConnection = RunService.Heartbeat:Connect(function()
		if (tick() - lastFarmRanAt < 1) then return end
		lastFarmRanAt = tick()

		local tool = LocalPlayer.Backpack:FindFirstChild('Math Textbook') or LocalPlayer.Character:FindFirstChild('Math Textbook')
		if not tool then
			return ToastNotif.new({
				text = 'You need to have Math Textbook in your inventory for the farm to work',
				duration = 1
			})
		end

		tool.Parent = LocalPlayer.Character
		tool:Activate()

		local choicePrompt = LocalPlayer.PlayerGui:FindFirstChild('ChoicePrompt')
		if not choicePrompt then return end

		local question = choicePrompt.ChoiceFrame.DescSheet.Desc.Text:gsub('[^%w%p%s]', '')
		local operationType = question:match('%d+ (.-) ')

		local number1 = question:match('What is (.-) ')
		local number2 = question:match(operationType .. ' (.-)%?')

		number2 = number2:gsub('by', '')
		number1 = tonumber(number1)
		number2 = tonumber(number2)

		local result = 0

		if operationType == 'minus' then
			result = number1 - number2
		elseif operationType == 'divided' then
			result = number1 / number2
		elseif operationType == 'plus' then
			result = number1 + number2
		elseif operationType == 'times' then
			result = number1 * number2
		end

		for _, v in ipairs(choicePrompt.ChoiceFrame.Options:GetChildren()) do
			if not v:IsA('TextButton') then continue end

			if math.abs(tonumber(v.Name) - result) <= 1 then
				choicePrompt.Choice:FireServer(v.Name)
				break
			end
		end
	end)
end

-- UI Integration
SectieFarm:AddToggle({
    Name = 'Intelligence Farm',
    Default = false,
    Callback = function(NewValue)
        intelligenceFarm(NewValue)
    end
})
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local noWindConnection

local function noWind(t)
    if not t then
        if noWindConnection then
            noWindConnection:Disconnect()
            noWindConnection = nil
        end
        return
    end

    if noWindConnection then
        noWindConnection:Disconnect()
    end

    noWindConnection = RunService.Heartbeat:Connect(function()
        local player = Players.LocalPlayer
        if not player then return end

        local character = player.Character
        if not character then return end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local windPusher = rootPart:FindFirstChild('WindPusher')
        if windPusher then
            windPusher.Parent = Lighting
        end
    end)
end

SectieFarm:AddToggle({
    Name = 'No Wind',
     Default = false,
     Callback = function(value)
        noWind(value)
    end
})

local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

local LocalPlayer = Players.LocalPlayer

-- Function to calculate and execute tween teleportation
local function tweenTeleport(rootPart, position, noWait)
    if not rootPart or not position then
        warn("tweenTeleport: Missing rootPart or position")
        return
    end

    local distance = (rootPart.Position - position).Magnitude
    local tween = TweenService:Create(rootPart, TweenInfo.new(distance / 120, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(position)
    })

    tween:Play()

    if not noWait then
        tween.Completed:Wait()
    end

    return tween
end

-- Function to find the closest BloodJar with an ActivatedJar folder
local function closestBloodJar()
    local last = math.huge
    local closest

    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not rootPart then
        warn("closestBloodJar: No HumanoidRootPart found")
        return nil
    end

    local myPos = rootPart.Position
    local destructibles = Workspace:FindFirstChild('Destructibles')

    if not destructibles then
        warn("closestBloodJar: No Destructibles found in Workspace")
        return nil
    end

    for _, v in ipairs(destructibles:GetChildren()) do
        if v.Name == 'BloodJar' and v:FindFirstChild('ActivatedJar') then
            local pos = v:IsA('BasePart') and v.Position or v:GetPivot().Position

            if (pos - myPos).Magnitude < last then
                closest = v
                last = (pos - myPos).Magnitude
            end
        end
    end

    return closest
end

-- Function to teleport to the closest BloodJar
local function teleportToClosestBloodJar()
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not rootPart then
        warn("teleportToClosestBloodJar: No HumanoidRootPart found")
        return false
    end

    local jar = closestBloodJar()
    if not jar then
        warn("teleportToClosestBloodJar: No suitable BloodJar found")
        return false
    end

    local targetPosition = jar:IsA('BasePart') and jar.Position or jar:GetPivot().Position
    tweenTeleport(rootPart, targetPosition, true)
    return true
end

-- Toggle state variable
local isToggled = false

-- Function to enable or disable teleportation
local function toggleTeleportation(enabled)
    isToggled = enabled
    if isToggled then
        print("Teleportation Enabled")
        while isToggled do
            local teleported = teleportToClosestBloodJar()
            if not teleported then
                isToggled = false
                print("No more suitable BloodJars. Teleportation Disabled")
            end
            wait(0.1)  -- Adjust the wait time as needed
        end
    else
        print("Teleportation Disabled")
    end
end

-- SectiePlayer UI toggle for enabling teleportation
SectieFarm:AddToggle({
    Name = "Auto-BloodJars",
    Default = false,
    Keybind = {
        Mode = "Dynamic" -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
     },  -- Default state of the toggle (false means teleportation is initially disabled)
    Callback = function(enabled)
        toggleTeleportation(enabled)
    end
})
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = Players.LocalPlayer

local activeCirclets = {}
local contractorStrings = {}

-- Helper function to create a circlet
local function createCirclet(parent, weldPart, cframe, color)
    local circlet = game:GetObjects('rbxassetid://12562484379')[1]:Clone()
    circlet.Size = Vector3.new(1.372, 0.198, 1.396)
    circlet.Parent = parent

    if color then
        circlet.Color = color
    end

    local weld = Instance.new('Weld', circlet)
    weld.Part0 = weldPart
    weld.Part1 = circlet
    weld.C0 = cframe

    return circlet
end

-- Function to handle Lightborn Circlets
local function handleLightbornCirclets(enabled, variant)
    if not enabled then
        for _, circlet in ipairs(activeCirclets) do
            circlet:Destroy()
        end
        activeCirclets = {}
        return
    end

    local function onCharacterAdded(character)
        if not character then return end

        local circlets = {
            { partName = 'Head', cframe = CFrame.new(0, 1.5, 0) },
            { partName = 'Head', cframe = CFrame.new(0, -0.35, 0) },
            { partName = 'Right Arm', cframe = CFrame.new(0, -0.5, 0) },
            { partName = 'Left Arm', cframe = CFrame.new(0, -0.5, 0) }
        }

        local selectedCirclets = {}
        if variant == 1 then
            selectedCirclets = { circlets[1] }
        elseif variant == 2 then
            selectedCirclets = { circlets[2] }
        elseif variant == 3 then
            selectedCirclets = { circlets[3], circlets[4] }
        end

        for _, circletInfo in ipairs(selectedCirclets) do
            local part = character:FindFirstChild(circletInfo.partName)
            if part then
                local circlet = createCirclet(character, part, circletInfo.cframe, Color3.fromRGB(253, 234, 141))
                table.insert(activeCirclets, circlet)
            end
        end
    end

    onCharacterAdded(LocalPlayer.Character)
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Function to handle Lightborn Skin Color
local function handleLightbornSkinColor(enabled)
    local run = true
    if not enabled then
        run = false
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA('BasePart') and part.Name ~= 'LightbornCirclet' then
                    part.Color = Color3.fromRGB(255, 255, 255) -- Reset to original color
                end
            end
        end
        return
    end

    task.spawn(function()
        while run do
            task.wait(0.5) -- Reduced update frequency
            if not LocalPlayer.Character then continue end
            pcall(function()
                local faceMount = LocalPlayer.Character.Head:FindFirstChild("FaceMount")
                if faceMount then
                    faceMount.DGFace.Texture = "rbxassetid://6466188578"
                end
            end)
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA('BasePart') and part.Name ~= 'LightbornCirclet' then
                    part.Color = Color3.fromRGB(253, 234, 141)
                end
            end
        end
    end)
end

-- Function to handle Contractor
local function handleContractor(enabled)
    if not enabled then
        for _, str in ipairs(contractorStrings) do
            str:Destroy()
        end
        contractorStrings = {}
        return
    end

    local function onCharacterAdded(character)
        if not character then return end
        local hrp = character:WaitForChild('HumanoidRootPart', 10)
        if not hrp then return end

        local string = ReplicatedStorage.Assets.Effects.ContractorString

        local function createString(attachment0, attachment1)
            local clone = string:Clone()
            clone.Parent = hrp
            clone.Attachment0 = attachment0
            clone.Attachment1 = attachment1
            table.insert(contractorStrings, clone)
        end

        local attachment1 = Instance.new("Attachment", hrp)
        attachment1.Position = Vector3.new(1, 5, 0)
        attachment1.Name = "StringAttach1"
        local attachment2 = Instance.new("Attachment", character:FindFirstChild('RightHand'))
        if attachment2 then
            attachment2.Position = Vector3.new(0.5, 0, 0)
            attachment2.Name = "StringAttach2"
            createString(attachment1, attachment2)
        end

        attachment1 = Instance.new("Attachment", hrp)
        attachment1.Position = Vector3.new(-1, 5, 0)
        attachment1.Name = "StringAttach3"
        attachment2 = Instance.new("Attachment", character:FindFirstChild('LeftHand'))
        if attachment2 then
            attachment2.Position = Vector3.new(-0.5, 0, 0)
            attachment2.Name = "StringAttach4"
            createString(attachment1, attachment2)
        end

        attachment1 = Instance.new("Attachment", hrp)
        attachment1.Position = Vector3.new(0.5, 5, 0)
        attachment1.Name = "StringAttach5"
        attachment2 = character:FindFirstChild('Torso')
        if attachment2 then
            local collar = attachment2:FindFirstChild('RightCollarAttachment')
            if collar then
                attachment2 = collar
                attachment2.Name = "StringAttach6"
                createString(attachment1, attachment2)
            end
        end

        attachment1 = Instance.new("Attachment", hrp)
        attachment1.Position = Vector3.new(-1, 5, 0)
        attachment1.Name = "StringAttach7"
        attachment2 = character:FindFirstChild('Torso')
        if attachment2 then
            local collar = attachment2:FindFirstChild('LeftCollarAttachment')
            if collar then
                attachment2 = collar
                attachment2.Name = "StringAttach8"
                createString(attachment1, attachment2)
            end
        end
    end

    onCharacterAdded(LocalPlayer.Character)
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

-- Add toggles using SectieVisual:AddToggle
SectieVisual:AddToggle({
    Name = "Lightborn Circlets (Variant 1)",
    Default = false,
    Callback = function(enabled)
        handleLightbornCirclets(enabled, 1)
    end
})

SectieVisual:AddToggle({
    Name = "Lightborn Circlets (Variant 2)",
    Default = false,
    Callback = function(enabled)
        handleLightbornCirclets(enabled, 2)
    end
})

SectieVisual:AddToggle({
    Name = "Lightborn Circlets (Variant 3)",
    Default = false,
    Callback = function(enabled)
        handleLightbornCirclets(enabled, 3)
    end
})

SectieVisual:AddToggle({
    Name = "Lightborn Skin Color",
    Default = false,
    Callback = handleLightbornSkinColor
})

SectieVisual:AddToggle({
    Name = "Contractor",
    Default = false,
    Callback = handleContractor
})

-- Wait until the game is fully loaded
repeat
    task.wait()
until game:IsLoaded()

-- Function to clone a reference
local cloneref = cloneref or function(o) return o end

-- Services and references
local Players = cloneref(game:GetService("Players"))
local TextChatService = cloneref(game:GetService("TextChatService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local LocalPlayer = Players.LocalPlayer

-- Fake user ID for the local player
local FakeUserId = "RARES HUB BEST"

-- Streamer mode toggle
local streamerModeEnabled = false

-- Function to update player-related objects with fake user ID
local function UpdatePlayerUserId(Object, Property)
    if streamerModeEnabled then
        Object[Property] = Object[Property]:gsub(tostring(LocalPlayer.UserId), tostring(FakeUserId))
    else
        Object[Property] = Object[Property]:gsub(tostring(FakeUserId), tostring(LocalPlayer.UserId))
    end
end

-- Function to update specific types of objects
local function NewObject(Object)
    if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
        UpdatePlayerUserId(Object, "Text")
        Object:GetPropertyChangedSignal("Text"):Connect(function()
            UpdatePlayerUserId(Object, "Text")
        end)
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        UpdatePlayerUserId(Object, "Image")
        Object:GetPropertyChangedSignal("Image"):Connect(function()
            UpdatePlayerUserId(Object, "Image")
        end)
    end
end

-- Function to update all objects in the game
local function UpdateAllObjects()
    for _, Object in pairs(game:GetDescendants()) do
        NewObject(Object)
    end
end

-- Initial update of all objects
UpdateAllObjects()

-- Event handler for new objects being added to the game
game.DescendantAdded:Connect(NewObject)

-- Event handler for new players joining the game
Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Character)
        -- Wait for the character to load fully
        Character:WaitForChild("Humanoid")

        -- Update the player's objects
        for _, Object in pairs(Character:GetDescendants()) do
            NewObject(Object)
        end
    end)

    -- If the player is already in the game, update their objects
    if Player.Character then
        for _, Object in pairs(Player.Character:GetDescendants()) do
            NewObject(Object)
        end
    end
end)

-- Event handler for text chat messages (depending on TextChatService version)
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(MessageData)
        NewObject(MessageData)
    end)
else
    ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(MessageData)
        NewObject(MessageData)
    end)
end

-- Toggle for streamer mode
SectiePlayer:AddToggle({
    Name = "Streamer Mode",
    Keybind = {
        Mode = "Dynamic", -- Dynamic means to use the 'hold' method, if the user keeps the button pressed for longer than 0.65 seconds; else use toggle method
    },
    Value = streamerModeEnabled,
    Callback = function(NewValue)
        streamerModeEnabled = NewValue
        UpdateAllObjects()  -- Call this to update all objects with new mode
    end
})

