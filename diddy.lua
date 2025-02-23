local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "DiddyHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest",
    IntroEnabled = false
})

OrionLib:MakeNotification({
	Name = "!Fat Daddy Join Up!",
	Content = "Join The Diddy Discord - https://discord.gg/cUjbFJydgJ",
	Image = "rbxassetid://4483345998",
	Time = 5
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ESPEnabled = false
local NigBotEnabled = false
local AimLocked = false

-- Function to create ESP
local function applyESP(player)
    if player ~= LocalPlayer then
        local function setupCharacter(character)
            if character and not character:FindFirstChild("GoonESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "GoonESP"
                highlight.Parent = character
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
                highlight.FillTransparency = 0.2
                highlight.OutlineTransparency = 0
            end
        end

        -- Apply ESP if character exists
        if player.Character then
            setupCharacter(player.Character)
        end

        -- Reapply ESP when player respawns
        player.CharacterAdded:Connect(setupCharacter)
    end
end

-- Remove ESP
local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("GoonESP") then
        player.Character.GoonESP:Destroy()
    end
end

-- Toggle ESP for all players
local function toggleESP(enable)
    ESPEnabled = enable
    for _, player in pairs(Players:GetPlayers()) do
        if enable then
            applyESP(player)
        else
            removeESP(player)
        end
    end
end

-- Update ESP for new players joining
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        applyESP(player)
    end
end)

-- Find closest player to crosshair
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local distance = (Vector2.new(targetPos.X, targetPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Aimlock function (Instant Lock-On)
local function aimlock()
    if not NigBotEnabled or not AimLocked then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end
end

-- Detect Right Click Hold for Aimlock
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right Mouse Button
        AimLocked = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimLocked = false
    end
end)

-- Update loop (Aimlock runs every frame)
RunService.RenderStepped:Connect(aimlock)

-- UI: Features Tab
local FeaturesTab = Window:MakeTab({
    Name = "Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FeaturesTab:AddToggle({
    Name = "GoonESP",
    Default = false,
    Callback = function(Value)
        toggleESP(Value)
    end    
})

FeaturesTab:AddToggle({
    Name = "NigBot",
    Default = false,
    Callback = function(Value)
        NigBotEnabled = Value
    end    
})

OrionLib:Init()
