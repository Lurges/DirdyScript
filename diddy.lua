local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "DiddyHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest",
    IntroEnabled = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ESPEnabled = false
local NigBotEnabled = false
local HitboxSize = 2
local AimFOV = 100
local AimStrength = 100

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = AimFOV
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

-- Update FOV Circle Position
local function updateFOV()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = AimFOV
end

-- Function to get closest player inside FOV
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPosition, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)

            if onScreen then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- ESP Function (Tracks Players & Updates on Respawn)
local function applyESP(player)
    local function setupCharacter(character)
        if character and not character:FindFirstChild("GoonESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "GoonESP"
            highlight.Parent = character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.2
            highlight.OutlineTransparency = 0
        end
    end

    if player.Character then
        setupCharacter(player.Character)
    end

    player.CharacterAdded:Connect(setupCharacter)
end

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("GoonESP") then
        player.Character.GoonESP:Destroy()
    end
end

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

Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        applyESP(player)
    end
end)

-- Aimbot Function (Now Works Inside FOV & Respects Toggle)
local function aimlock()
    if not NigBotEnabled then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.Character.HumanoidRootPart.Position
        local direction = (targetPosition - Camera.CFrame.Position).Unit
        local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction * AimStrength / 100)
        
        Camera.CFrame = newCFrame
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        NigBotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        NigBotEnabled = false
    end
end)

RunService.RenderStepped:Connect(function()
    aimlock()
    updateFOV()
end)

-- Hitbox Expander Function
local function expandHitbox(player, size)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        root.Size = Vector3.new(size, size, size)
        root.Transparency = 0.5
        root.Material = Enum.Material.ForceField

        -- Green outline
        if not root:FindFirstChild("BigBackOutline") then
            local selectionBox = Instance.new("SelectionBox")
            selectionBox.Name = "BigBackOutline"
            selectionBox.Adornee = root
            selectionBox.Parent = root
            selectionBox.LineThickness = 0.05
            selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
        end
    end
end

-- Update Hitbox Expansion
local function updateHitboxes(size)
    HitboxSize = size
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            expandHitbox(player, size)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    expandHitbox(player, HitboxSize)
end)

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
        ESPEnabled = Value
        toggleESP(Value)
    end    
})

FeaturesTab:AddToggle({
    Name = "NigBot",
    Default = false,
    Callback = function(Value)
        NigBotEnabled = Value
        FOVCircle.Visible = Value
    end    
})

FeaturesTab:AddSlider({
    Name = "Aimbot Strength",
    Min = 10,
    Max = 100,
    Default = 100,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 5,
    ValueName = "Strength",
    Callback = function(Value)
        AimStrength = Value
    end    
})

FeaturesTab:AddSlider({
    Name = "FOV Circle Size",
    Min = 50,
    Max = 400,
    Default = 100,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 10,
    ValueName = "FOV",
    Callback = function(Value)
        AimFOV = Value
    end    
})

FeaturesTab:AddSlider({
    Name = "BigBackExpander",
    Min = 2,
    Max = 20,
    Default = 2,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Hitbox Size",
    Callback = function(Value)
        updateHitboxes(Value)
    end    
})

OrionLib:Init()
