-- Define necessary services
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- URL of the Maid.lua script for cleanup management
local maidUrl = "https://raw.githubusercontent.com/ModerkaScripts/Aztup-Hub-V3/master/files/utils/Maid.lua"

-- Function to load and return Maid class
local function loadMaid()
    local maidScript = HttpService:GetAsync(maidUrl)
    assert(maidScript, "Failed to fetch Maid.lua script")

    -- Load the script chunk
    local chunk = assert(loadstring(maidScript))
    local Maid = chunk() -- Execute the script and return the Maid class

    return Maid
end

-- Load Maid class
local Maid = loadMaid()

-- FPS Boost Configuration
local fpsBoostMaid = Maid.new()
local hooked = {}

local function enableRenderStep(connection)
    if connection and connection.Function then
        connection:Enable()
    end
end

local function disableRenderStep(connection)
    if connection and connection.Function then
        connection:Disable()
    end
end

local function setScriptes(script)
    -- Replace with your setscriptes logic if needed
end

-- Function to remove textures from parts
local function removeTexturesFromParts()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Texture = ""  -- Remove texture by setting Texture property to an empty string
        end
    end
end

-- Function to remove textures from GUI elements
local function removeTexturesFromGUI(guiElement)
    for _, child in ipairs(guiElement:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            child.Image = ""  -- Remove image source by setting Image property to an empty string
        end
    end
end

-- Main FPS Boost Function
local function fpsBoost(enable)
    for _, connection in ipairs(RunService.RenderStepped:GetConnections()) do
        local conScript = connection.Instance
        if conScript and conScript:IsA("Script") and conScript.Name == "YourScriptName" then
            if enable then
                enableRenderStep(connection)
                hooked[connection.Function] = true
                fpsBoostMaid[conScript] = nil

                fpsBoostMaid:addTask(function()
                    connection:Disconnect()
                end)

                fpsBoostMaid[conScript] = connection:Connect(function(_, dt)
                    if not connection.Function then
                        fpsBoostMaid[conScript] = nil
                        hooked[connection.Function] = nil
                        enableRenderStep(connection)
                        print('No more func!')
                        return
                    end

                    -- Simplified operation
                    pcall(connection.Function, dt)
                end)
            else
                disableRenderStep(connection)
            end
        end
    end
end

-- Example: Continuously check and apply FPS boost based on a flag
task.spawn(function()
    while true do
        local enableBoost = true -- Replace with your logic to enable/disable FPS boost
        fpsBoost(enableBoost)
        task.wait(1) -- Adjust wait time as needed
    end
end)

-- Example: Remove textures from parts and GUI elements
removeTexturesFromParts()
local guiElement = game.Players.LocalPlayer.PlayerGui.ScreenGuiNameHere -- Replace with your GUI element
removeTexturesFromGUI(guiElement)
