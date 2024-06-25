-- Function to create the text label

    -- New example script written by wally
-- You can suggest changes with a pull request or something

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    -- Set Center to true if you want the menu to appear in the center
    -- Set AutoShow to true if you want the menu to appear when it is created
    -- Position and Size are also valid options here
    -- but you do not need to define them unless you are changing them :)

    Title = 'Real Aztup Hub ',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
    -- Creates a new tab titled Main
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Player')

-- We can also get our Main tab via the following code:
-- local LeftGroupBox = Window.Tabs.Main:AddLeftGroupbox('Groupbox')

-- Tabboxes are a tiny bit different, but here's a basic example:
--[[

local TabBox = Tabs.Main:AddLeftTabbox() -- Add Tabbox on left side

local Tab1 = TabBox:AddTab('Tab 1')
local Tab2 = TabBox:AddTab('Tab 2')

-- You can now call AddToggle, etc on the tabs you added to the Tabbox
]]
-- Define necessary variables and services
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

-- Function to check if a player has the tool "Talent:Voideye"
local function checkPlayerForTool(player)
    local character = player.Character
    if character then
        local backpack = player.Backpack
        local workspace = game:GetService("Workspace")

        -- Check if the player has the tool in their Backpack
        if backpack and backpack:FindFirstChild("Talent:Voideye") then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Notification";
                Text = player.Name .. " is a voidwalker!";
                Icon = ""; -- You can add an icon URL here if needed
                Duration = 5; -- Duration of the notification in seconds
            })
            return
        end

        -- Check if the player has the tool in their Character or its descendants
        local function checkDescendants(parent)
            for _, descendant in ipairs(parent:GetChildren()) do
                if descendant:IsA("Tool") and descendant.Name == "Talent:Voideye" then
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Notification";
                        Text = player.Name .. " is a voidwalker!";
                        Icon = ""; -- You can add an icon URL here if needed
                        Duration = 5; -- Duration of the notification in seconds
                    })
                    return
                end
                checkDescendants(descendant)
            end
        end

        -- Check the character and its descendants
        if character then
            checkDescendants(character)
        end

        -- Check the player's Backpack descendants
        if backpack then
            checkDescendants(backpack)
        end

        -- Check the player's PlayerGui descendants
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            checkDescendants(playerGui)
        end

        -- Check the player's Workspace descendants
        checkDescendants(workspace)
    end
end

-- Function to handle player added event
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        checkPlayerForTool(player)
    end)
end

-- Function to check all existing players periodically
local function checkExistingPlayers()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        checkPlayerForTool(player)
    end
end

-- Connect the player added event
game:GetService("Players").PlayerAdded:Connect(onPlayerAdded)

-- Check existing players immediately when the script runs
checkExistingPlayers()

loadstring(game:HttpGet("https://raw.githubusercontent.com/mac2115/Cool-private/main/ESP"))()


local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))();

-- Initial ESP settings
ESP.Enabled = false; -- Initially disabled
ESP.ShowBox = true;
ESP.BoxType = "2D";
ESP.ShowName = true;
ESP.ShowHealth = true;
ESP.ShowTracer = false;
ESP.ShowDistance = true;

local EspEnabled = false -- Initially disabled

-- Function to enable ESP for players
local function EnablePlayerESP()
    ESP.Enabled = true;
end

-- Function to disable ESP for players
local function DisablePlayerESP()
    ESP.Enabled = false;
end

-- Creating a toggle in SectiePlayer for Player ESP
LeftGroupBox:AddToggle('PlayerEspToggle', {
    Text = 'ESP Players',
    Default = false,
    Callback = function(NewValue)
        EspEnabled = NewValue
        if EspEnabled then
            EnablePlayerESP()
        else
            DisablePlayerESP()
        end
    end
})

local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local espEnabled = false -- Initial state of ESP (disabled)

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

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White color for text
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
            end
        end
    end
end)

-- Optionally, you can update ESP regularly to ensure all mobs are covered
runService.RenderStepped:Connect(updateESP)

-- Example of adding a toggle button (replace with your actual UI library or method)
LeftGroupBox:AddToggle('ToggleBillboards', {
    Text = "Enable Mob ESP",  -- Text displayed for the toggle
    Default = false,  -- Default state of the toggle (false means billboards are initially disabled)
    Callback = function(enabled)
        toggleESP(enabled)  -- Call toggleESP function with the enabled state
    end
})


-- Define the function to toggle NPC name billboards
local function toggleBillboards(enabled)
    -- Loop through each NPC in Workspace.NPCs
    for _, npc in pairs(workspace.NPCs:GetChildren()) do
        -- Check if the NPC has a Humanoid or a PrimaryPart
        if npc:IsA("Model") and (npc:FindFirstChild("Humanoid") or npc.PrimaryPart) then
            -- Find existing BillboardGui if it exists
            local billboard = npc:FindFirstChild("NPCBillboard")
            
            -- If enabled is true and BillboardGui doesn't exist, create it
            if enabled and not billboard then
                billboard = Instance.new("BillboardGui")
                billboard.Name = "NPCBillboard"
                billboard.Size = UDim2.new(3.5, 0, 1.5, 0)  -- Increase size for better visibility
                billboard.StudsOffset = Vector3.new(0, 3, 0) -- Offset above NPC's head

                -- Create a TextLabel inside BillboardGui
                local label = Instance.new("TextLabel")
                label.Text = "[" .. npc.Name .. "]"  -- Display NPC's name in []
                label.Size = UDim2.new(2, 0, 1.5, 0)
                label.TextScaled = true
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1, 1, 1)
                label.Font = Enum.Font.SourceSansBold
                label.Parent = billboard

                -- Attach BillboardGui to NPC's HumanoidRootPart or PrimaryPart
                if npc:FindFirstChild("HumanoidRootPart") then
                    billboard.Parent = npc.HumanoidRootPart
                elseif npc.PrimaryPart then
                    billboard.Parent = npc.PrimaryPart
                else
                    billboard.Parent = npc
                end

                -- Make sure the BillboardGui faces the camera
                billboard.AlwaysOnTop = true
                billboard.Enabled = true
                billboard.LightInfluence = 0
            elseif not enabled and billboard then
                -- If enabled is false and BillboardGui exists, remove it
                billboard:Destroy()
            end
        end
    end
end

-- Assuming LeftGroupBox:AddToggle is a function provided by a plugin GUI library
LeftGroupBox:AddToggle('ToggleBillboards', {
    Text = "Enable NPC ESP",  -- Text displayed for the toggle
    Default = false,  -- Default state of the toggle (false means billboards are initially disabled)
    Callback = function(enabled)
        toggleBillboards(enabled)  -- Call toggleBillboards function with the enabled state
    end
})




LeftGroupBox:AddDivider()

local Lighting = game:GetService("Lighting")
local fogEnabled = false
local renderSteppedConnection = nil

local function enableFog()
    -- Disable depth of field
    Lighting.DepthOfField.Enabled = false
    
    -- Define the function to handle the fog effect
    local function handleFog()
        Lighting.FogEnd = 1000000
        
        local atmosphere = Lighting:FindFirstChild("Atmosphere")
        if atmosphere then
            atmosphere.Density = 0
        end
    end
    
    -- Connect the handleFog function to RenderStepped
    renderSteppedConnection = game:GetService("RunService").RenderStepped:Connect(handleFog)
end

local function disableFog()
    -- Re-enable depth of field
    Lighting.DepthOfField.Enabled = true
    
    -- Disconnect any existing connections to RenderStepped
    if renderSteppedConnection then
        renderSteppedConnection:Disconnect()
        renderSteppedConnection = nil
    end
end

local function toggleFog(enabled)
    fogEnabled = enabled
    
    if fogEnabled then
        enableFog()
    else
        disableFog()
    end
end

-- Example usage with LeftGroupBox:AddToggle
LeftGroupBox:AddToggle('ToggleFog', {
    Text = "Enable No Fog",  -- Text displayed for the toggle
    Default = false,  -- Default state of the toggle (false means fog is initially disabled)
    Callback = function(enabled)
        toggleFog(enabled)  -- Call toggleFog function with the enabled state
    end
})


local NoClipEnabled = false
local InfiniteJumpEnabled = false
local infiniteJumpHeight = 50 -- Default jump height
local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Functions for NoClip
local function EnableNoClip()
    RunService.Stepped:Connect(function()
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
    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") and not v.CanCollide then
            v.CanCollide = true
        end
    end
end

-- Functions for Infinite Jump
local function infiniteJump(toggle)
    InfiniteJumpEnabled = toggle

    if not toggle then return end

    coroutine.wrap(function()
        while InfiniteJumpEnabled do
            local character = Player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if rootPart and UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:GetFocusedTextBox() then
                rootPart.Velocity = Vector3.new(rootPart.Velocity.X, infiniteJumpHeight, rootPart.Velocity.Z)
            end

            task.wait(0.1)
        end
    end)()
end

-- Functions for SpeedHack
local function ApplySpeed()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        if Settings.SpeedEnabled then
            Player.Character.Humanoid.WalkSpeed = Settings.Speed
        else
            Player.Character.Humanoid.WalkSpeed = 16 -- Default speed when disabled
        end
    end
end

local function SetupCharacter(character)
    character:WaitForChild("Humanoid")
    SpoofProp(character.Humanoid, "WalkSpeed")
    ApplySpeed()

    character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Settings.SpeedEnabled then
            character.Humanoid.WalkSpeed = Settings.Speed
        end
    end)
end

Player.CharacterAdded:Connect(SetupCharacter)

-- UI Elements
LeftGroupBox:AddToggle('NoClipToggle', {
    Text = 'NoClip',
    Default = false,
    Tooltip = 'This is noclips',
    Callback = function(NewValue)
        NoClipEnabled = NewValue
        if NoClipEnabled then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end
})

LeftGroupBox:AddLabel('NoClip Keybind'):AddKeyPicker('NoClipKeyPicker', {
    Default = 'K',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'NoClip Keybind',
    NoUI = false,
    Callback = function(value)
        NoClipEnabled = not NoClipEnabled
        if NoClipEnabled then
            EnableNoClip()
        else
            DisableNoClip()
        end
        Toggles.NoClipToggle:Set(NoClipEnabled)
    end,
})

LeftGroupBox:AddToggle('InfJumpToggle', {
    Text = 'Inf Jump',
    Default = false,
    Tooltip = 'Infinite Jump',
    Callback = function(NewValue)
        InfiniteJumpEnabled = NewValue
        infiniteJump(InfiniteJumpEnabled)
    end
})

LeftGroupBox:AddLabel('Inf Jump Keybind'):AddKeyPicker('InfJumpKeyPicker', {
    Default = 'J',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Inf Jump Keybind',
    NoUI = false,
    Callback = function(value)
        InfiniteJumpEnabled = not InfiniteJumpEnabled
        infiniteJump(InfiniteJumpEnabled)
        Toggles.InfJumpToggle:Set(InfiniteJumpEnabled)
    end,
})

LeftGroupBox:AddSlider('InfJumpHeightSlider', {
    Text = "Jump Height",
    Default = 50,
    Min = 50,
    Max = 150,
    Rounding = 5,
    Compact = false,
    Callback = function(value)
        infiniteJumpHeight = value
    end
})

-- Define necessary variables
local Player = game.Players.LocalPlayer
local Settings = {
    Speed = 16,
    SpeedEnabled = true
}

local Spoofed = {}
local Clone = game.Clone
local oldIdx
local oldNewIdx
local OldNC

local Methods = {
    "FindFirstChild",
    "FindFirstChildOfClass",
    "FindFirstChildWhichIsA"
}

-- Function to spoof property
local function SpoofProp(Instance, Property)
    local Cloned = Clone(Instance)

    table.insert(Spoofed, {
        Instance = Instance,
        Property = Property,
        ClonedInstance = Cloned
    })
end

-- Hook methods
oldIdx = hookmetamethod(game, "__index", function(self, key)
    for i, v in ipairs(Spoofed) do
        if self == v.Instance and key == v.Property and not checkcaller() then
            return oldIdx(v.ClonedInstance, key)
        end

        if key == "Parent" and (self == v.ClonedInstance or self == v.Instance) and checkcaller() == false then
            return oldIdx(v.Instance, key)
        end
    end

    return oldIdx(self, key)
end)

oldNewIdx = hookmetamethod(game, "__newindex", function(self, key, newval, ...)
    for i, v in ipairs(Spoofed) do
        if self == v.Instance and key == v.Property and not checkcaller() then
            return oldNewIdx(v.ClonedInstance, key, newval, ...)
        end
    end
    return oldNewIdx(self, key, newval, ...)
end)

OldNC = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()

    if not table.find(Methods, Method) or Player.Character == nil or self ~= Player.Character then
        return OldNC(self, ...)
    end

    local Results = OldNC(self, ...)

    if Results and Results:IsA("Humanoid") and Player.Character and self == Player.Character then
        for i, v in ipairs(Spoofed) do
            if v.Instance == Results then
                return v.ClonedInstance
            end
        end
    end
    return OldNC(self, ...)
end)

-- Hook functions for Methods
for i, Method in ipairs(Methods) do
    local Old

    Old = hookfunction(game[Method], function(self, ...)
        if not Player.Character or self ~= Player.Character then
            return Old(self, ...)
        end

        local Results = Old(self, ...)

        if Results and Results:IsA("Humanoid") and Player.Character and self == Player.Character then
            for i, v in ipairs(Spoofed) do
                if v.Instance == Results then
                    return v.ClonedInstance
                end
            end
        end
        return Old(self, ...)
    end)
end

-- Function to apply speed
local function ApplySpeed()
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        if Settings.SpeedEnabled then
            Player.Character.Humanoid.WalkSpeed = Settings.Speed
        else
            Player.Character.Humanoid.WalkSpeed = 16 -- Default speed when disabled
        end
    end
end

-- Spoof WalkSpeed property initially
local character = Player.Character
if character then
    SpoofProp(character.Humanoid, "WalkSpeed")
    character.Humanoid.WalkSpeed = Settings.Speed
end

-- Connect to WalkSpeed changes
if character then
    character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Settings.SpeedEnabled then
            character.Humanoid.WalkSpeed = Settings.Speed
        end
    end)
end

-- Handle new character addition
Player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    SpoofProp(character.Humanoid, "WalkSpeed")
    if Settings.SpeedEnabled then
        character.Humanoid.WalkSpeed = Settings.Speed
    else
        character.Humanoid.WalkSpeed = 16 -- Default speed when disabled
    end

    character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Settings.SpeedEnabled then
            character.Humanoid.WalkSpeed = Settings.Speed
        end
    end)
end)

-- Add Slider for Speed
LeftGroupBox:AddSlider('SpeedSlider', {
    Text = "Speed",
    Default = Settings.Speed,
    Min = 16,
    Max = 160,
    Rounding = 1,
    Compact = false,
    Callback = function(value)
        Settings.Speed = value
        ApplySpeed()
    end
})

-- Add Toggle for SpeedEnabled
LeftGroupBox:AddToggle('ToggleSpeed', {
    Text = "Enable Speed",
    Default = Settings.SpeedEnabled,
    Callback = function(enabled)
        Settings.SpeedEnabled = enabled
        ApplySpeed() -- Apply speed whenever toggle is changed
    end
})

-- Add Keybind for Speed toggle
LeftGroupBox:AddLabel('Speed Keybind'):AddKeyPicker('SpeedKeyPicker', {
    Default = 'L',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Speed Keybind',
    NoUI = false,
    Callback = function(value)
        Settings.SpeedEnabled = not Settings.SpeedEnabled
        ApplySpeed()
        Toggles.ToggleSpeed:Set(Settings.SpeedEnabled)
    end,
})

LeftGroupBox:AddDivider()


-- LocalScript in StarterPlayerScripts or StarterCharacterScripts

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESPEnabled = false
local ESPConnections = {}

-- Function to create a BillboardGui
local function createESP(part)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 50, 0, 25)  -- Smaller default size
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "[Lootbag]"
    textLabel.TextColor3 = Color3.new(1, 1, 1)  -- White color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    textLabel.Parent = billboard
    billboard.Parent = part
end

-- Function to update the size of the BillboardGui based on distance
local function updateESP()
    for _, obj in ipairs(Workspace.Thrown:GetChildren()) do
        if obj.Name == "BagDrop" then
            local billboard = obj:FindFirstChildOfClass("BillboardGui")
            if billboard then
                local distance = (Camera.CFrame.Position - obj.Position).Magnitude
                local scale = math.clamp(1 / distance * 100, 0.1, 1) -- Adjust scale based on distance
                billboard.Size = UDim2.new(0, 50 * scale, 0, 25 * scale)
            end
        end
    end
end

-- Function to find and apply ESP to BagDrop objects
local function applyESP()
    for _, obj in ipairs(Workspace.Thrown:GetChildren()) do
        if obj.Name == "BagDrop" then
            if not obj:FindFirstChildOfClass("BillboardGui") then
                createESP(obj)
            end
        end
    end
end

-- Function to enable ESP
local function enableESP()
    ESPConnections[#ESPConnections + 1] = Workspace.Thrown.ChildAdded:Connect(function(child)
        if child.Name == "BagDrop" then
            createESP(child)
        end
    end)

    ESPConnections[#ESPConnections + 1] = Workspace.Thrown.ChildRemoved:Connect(function(child)
        if child.Name == "BagDrop" and child:FindFirstChildOfClass("BillboardGui") then
            child:FindFirstChildOfClass("BillboardGui"):Destroy()
        end
    end)

    ESPConnections[#ESPConnections + 1] = game:GetService("RunService").RenderStepped:Connect(updateESP)

    applyESP()
end

-- Function to disable ESP
local function disableESP()
    for _, connection in ipairs(ESPConnections) do
        connection:Disconnect()
    end
    ESPConnections = {}

    -- Clean up all existing ESP
    for _, obj in ipairs(Workspace.Thrown:GetChildren()) do
        if obj.Name == "BagDrop" then
            local billboard = obj:FindFirstChildOfClass("BillboardGui")
            if billboard then
                billboard:Destroy()
            end
        end
    end
end

-- Toggle setup
LeftGroupBox:AddToggle('ESPToggle', {
    Text = 'Esp Lootbag',
    Default = false,
    Tooltip = 'Toggle lootbag ESP',
    Callback = function(NewValue)
        ESPEnabled = NewValue
        if ESPEnabled then
            enableESP()
        else
            disableESP()
        end
    end
})


-- Function to create a billboard for all instances named "Galewax" under Workspace.Ingredients
local function createGalewaxBillboards()
    local workspace = game:GetService("Workspace")
    local ingredientsFolder = workspace:FindFirstChild("Ingredients")

    if ingredientsFolder then
        local galewaxInstances = ingredientsFolder:GetDescendants()

        for _, instance in ipairs(galewaxInstances) do
            if instance.Name == "Galewax" then
                if Settings.BillboardEnabled then
                    -- Create BillboardGui
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 100, 0, 20)  -- Smaller size of the billboard
                    billboard.StudsOffset = Vector3.new(0, 2, 0)  -- Offset from the part it's attached to
                    billboard.AlwaysOnTop = true  -- Billboard is always on top (visible through walls)

                    -- Create TextLabel inside BillboardGui
                    local textLabel = Instance.new("TextLabel", billboard)
                    textLabel.Text = "[" .. instance.Name .. "]"  -- Display name in square brackets
                    textLabel.TextScaled = true  -- Auto scale text based on the size of the billboard
                    textLabel.Size = UDim2.new(1, 0, 1, 0)  -- Size of the text label (fill the billboard)
                    textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Green color for text
                    textLabel.BackgroundTransparency = 1  -- Make the background of the text label transparent

                    -- Position the billboard in the game world relative to the instance
                    billboard.Parent = instance
                    billboard.Adornee = instance
                else
                    -- Remove existing billboards if disabled
                    for _, child in ipairs(instance:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child:Destroy()
                        end
                    end
                end
            end
        end
    else
        warn("Ingredients folder not found under Workspace.")
    end
end

-- Function to toggle billboards on/off
local function toggleBillboards(enabled)
    Settings.BillboardEnabled = enabled
    createGalewaxBillboards()  -- Refresh billboards based on the new state
end

-- Example of how to create a toggle in Roblox GUI (assuming a UI library like RoStrap or similar)
LeftGroupBox:AddToggle('ToggleBillboards', {
    Text = "Enable Galewax ESP",
    Default = false,
    Callback = function(enabled)
        toggleBillboards(enabled)
    end
})

-- LocalScript in StarterPlayerScripts or StarterCharacterScripts

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESPEnabled = false
local ESPConnections = {}

-- Function to create a BillboardGui
local function createESP(part)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part.RootPart  -- Ensure the billboard is attached to the RootPart
    billboard.Size = UDim2.new(0, 50, 0, 25)  -- Smaller default size
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "[Chest]"
    textLabel.TextColor3 = Color3.new(1, 1, 1)  -- White color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    textLabel.Parent = billboard
    billboard.Parent = part
end

-- Function to update the size of the BillboardGui based on distance
local function updateESP()
    for _, obj in ipairs(Workspace.Thrown:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("RootPart") then
            local billboard = obj:FindFirstChildOfClass("BillboardGui")
            if billboard then
                local distance = (Camera.CFrame.Position - obj.RootPart.Position).Magnitude
                local scale = math.clamp(1 / distance * 100, 0.1, 1) -- Adjust scale based on distance
                billboard.Size = UDim2.new(0, 200 * scale, 0, 100 * scale)
            end
        end
    end
end

-- Function to find and apply ESP to qualifying models
local function applyESP()
    for _, obj in ipairs(Workspace.Thrown:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("RootPart")  then
            if not obj:FindFirstChildOfClass("BillboardGui") then
                createESP(obj)
            end
        end
    end
end

-- Function to enable ESP
local function enableESP()
    ESPConnections[#ESPConnections + 1] = Workspace.Thrown.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChild("RootPart")  then
            createESP(child)
        end
    end)

    ESPConnections[#ESPConnections + 1] = Workspace.Thrown.ChildRemoved:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChildOfClass("BillboardGui") then
            child:FindFirstChildOfClass("BillboardGui"):Destroy()
        end
    end)

    ESPConnections[#ESPConnections + 1] = game:GetService("RunService").RenderStepped:Connect(updateESP)

    applyESP()
end

-- Function to disable ESP
local function disableESP()
    for _, connection in ipairs(ESPConnections) do
        connection:Disconnect()
    end
    ESPConnections = {}

    -- Clean up all existing ESP
    for _, obj in ipairs(Workspace.Thrown:GetChildren()) do
        if obj:IsA("Model") then
            local billboard = obj:FindFirstChildOfClass("BillboardGui")
            if billboard then
                billboard:Destroy()
            end
        end
    end
end

-- Toggle setup
LeftGroupBox:AddToggle('ESPToggle', {
    Text = 'Esp Chest',
    Default = false,
    Tooltip = 'Toggle Chest ESP',
    Callback = function(NewValue)
        ESPEnabled = NewValue
        if ESPEnabled then
            enableESP()
        else
            disableESP()
        end
    end
})

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESPEnabled = false
local ESPConnections = {}

-- Function to create a BillboardGui
local function createESP(part)
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 50, 0, 25)  -- Smaller default size
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "[Lamp]"
    textLabel.TextColor3 = Color3.new(1, 1, 1)  -- White color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    textLabel.Parent = billboard
    billboard.Parent = part
end

-- Function to update the size of the BillboardGui based on distance
local function updateESP()
    for _, obj in ipairs(Workspace.Layer2Floor1:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("MeshPart") and obj:FindFirstChildWhichIsA("MeshPart").Name:lower():find("lamp") then
            local billboard = obj:FindFirstChildOfClass("BillboardGui")
            if billboard then
                local distance = (Camera.CFrame.Position - obj.PrimaryPart.Position).Magnitude
                local scale = math.clamp(1 / distance * 100, 0.1, 1) -- Adjust scale based on distance
                billboard.Size = UDim2.new(0, 50 * scale, 0, 25 * scale)
            end
        end
    end
end

-- Function to find and apply ESP to qualifying models
local function applyESP()
    for _, obj in ipairs(Workspace.Layer2Floor1:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("MeshPart") and obj:FindFirstChildWhichIsA("MeshPart").Name:lower():find("lamp") then
            if not obj:FindFirstChildOfClass("BillboardGui") then
                createESP(obj)
            end
        end
    end
end

-- Function to enable ESP
local function enableESP()
    ESPConnections[#ESPConnections + 1] = Workspace.Layer2Floor1.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChildWhichIsA("MeshPart") and child:FindFirstChildWhichIsA("MeshPart").Name:lower():find("lamp") then
            createESP(child)
        end
    end)

    ESPConnections[#ESPConnections + 1] = Workspace.Layer2Floor1.ChildRemoved:Connect(function(child)
        if child:IsA("Model") and child:FindFirstChildOfClass("BillboardGui") then
            child:FindFirstChildOfClass("BillboardGui"):Destroy()
        end
    end)

    ESPConnections[#ESPConnections + 1] = game:GetService("RunService").RenderStepped:Connect(updateESP)

    applyESP()
end

-- Function to disable ESP
local function disableESP()
    for _, connection in ipairs(ESPConnections) do
        connection:Disconnect()
    end
    ESPConnections = {}

    -- Clean up all existing ESP
    for _, obj in ipairs(Workspace.Layer2Floor1:GetChildren()) do
        if obj:IsA("Model") then
            local billboard = obj:FindFirstChildOfClass("BillboardGui")
            if billboard then
                billboard:Destroy()
            end
        end
    end
end

-- Toggle setup
LeftGroupBox:AddToggle('ESPToggle', {
    Text = 'ESP Lamp',
    Default = false,
    Tooltip = 'Toggle Lamp ESP',
    Callback = function(NewValue)
        ESPEnabled = NewValue
        if ESPEnabled then
            enableESP()
        else
            disableESP()
        end
    end
})


Library:SetWatermarkVisibility(false)

-- Example of dynamically-updating watermark with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('Rares Hub| %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs['UI Settings'])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
