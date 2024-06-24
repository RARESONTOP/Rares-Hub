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
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Player variables
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- List of mob names to include
local mobNames = {
    "knight", "broodlord", "nautilodaunt", "owl",  "crocco", "crabbo", "gigamed", "avatar", "iceguy", "iceguybrute",
    "duke", "boneboy", "etrean", "chaser", "bounder", "ethiron", "diver", "bonekeeper", "carbuncle", "lionfish",
    "corrupted", "megalodaunt", "turtle", "monky", "immortal"
}

-- ESP Active flag
local ESPActive = false

-- Dictionary to store ESP objects
local espObjects = {}

-- Function to check if a mob's name is in the list
local function isTargetMob(name)
    for _, mobName in pairs(mobNames) do
        if string.find(string.lower(name), mobName) then
            return true
        end
    end
    return false
end

-- Function to add ESP for a mob
local function addESP(mob)
    if not mob:IsA("Model") then return end
    if not mob:FindFirstChild("HumanoidRootPart") or not mob:FindFirstChild("Humanoid") then return end

    -- Check if ESP is already added
    if espObjects[mob] then return end

    -- Billboard GUI setup
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 200, 0, 50) -- Adjusted size for better visibility
    billboard.Adornee = mob.HumanoidRootPart
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0) -- Adjust the offset as needed

    -- Text setup
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1) -- White color for text
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Text = ""
    textLabel.TextXAlignment = Enum.TextXAlignment.Left -- Align HP to the left
    textLabel.Parent = billboard

    -- Add to dictionary
    espObjects[mob] = {
        Billboard = billboard,
        TextLabel = textLabel
    }

    -- Update text size function
    local function updateTextSize()
        if not mob.Parent or not mob:FindFirstChild("HumanoidRootPart") then
            disconnectUpdateTextSize()
            return
        end
        
        local distance = (camera.CFrame.p - mob.HumanoidRootPart.CFrame.p).Magnitude
        local scaleFactor = math.clamp(1 - (distance - 8) / 40, 0.3, 1) -- Adjust as needed

        textLabel.TextSize = 14 * scaleFactor -- Base text size multiplied by the scaleFactor
    end

    -- Disconnect function for update text size
    local disconnectUpdateTextSize = function()
        if espObjects[mob] then
            espObjects[mob].TextLabel:Destroy()
            espObjects[mob].Billboard:Destroy()
            espObjects[mob] = nil
        end
    end

    -- Update text size initially
    updateTextSize()

    -- Update text size continuously
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if mob:FindFirstChild("Humanoid") then
            textLabel.Text = string.format("[%d/%d] %s", mob.Humanoid.Health, mob.Humanoid.MaxHealth, mob.Name)
            updateTextSize()
        else
            disconnectUpdateTextSize()
        end
    end)

    billboard.Parent = mob
end

-- Function to check for mobs in Workspace.Live
local function checkMobs()
    if not ESPActive then return end
    
    -- Iterate over Workspace.Live descendants to find eligible mobs
    for _, mob in pairs(Workspace.Live:GetDescendants()) do
        if mob:IsA("Model") and not espObjects[mob] and isTargetMob(mob.Name) then
            addESP(mob)
        end
    end
end

-- Activate ESP function
local function ActivateESP()
    ESPActive = true
    checkMobs()
    -- Update less frequently
    spawn(function()
        while ESPActive do
            checkMobs()
            wait(0.1) -- Update every 0.1 seconds
        end
    end)
end

-- Deactivate ESP function
local function DeactivateESP()
    ESPActive = false
    -- Remove all existing ESP
    for mob, esp in pairs(espObjects) do
        esp.TextLabel:Destroy()
        esp.Billboard:Destroy()
        espObjects[mob] = nil
    end
end

-- Example UI integration using your UI framework
LeftGroupBox:AddToggle('MobEspToggle', {
    Text = 'ESP Mobs',
    Default = false,
    Callback = function(NewValue)
        ESPActive = NewValue
        if ESPActive then
            ActivateESP()
        else
            DeactivateESP()
        end
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
                billboard.Size = UDim2.new(3, 0, 1, 0)  -- Increase size for better visibility
                billboard.StudsOffset = Vector3.new(0, 3, 0) -- Offset above NPC's head

                -- Create a TextLabel inside BillboardGui
                local label = Instance.new("TextLabel")
                label.Text = "[" .. npc.Name .. "]"  -- Display NPC's name in []
                label.Size = UDim2.new(1, 0, 1, 0)
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

    Library:SetWatermark(('LinoriaLib demo | %s fps | %s ms'):format(
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
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

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
