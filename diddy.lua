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
local HitboxSize = 2 -- Default hitbox expansion

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

        if player.Character then
            setupCharacter(player.Character)
        end

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
    if not NigBotEnabled then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
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

RunService.RenderStepped:Connect(aimlock)

-- Hitbox Expander Function
local function expandHitbox(player, size)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        root.Size = Vector3.new(size, size, size) -- Expands the hitbox
        root.Transparency = 0.5 -- Makes it semi-transparent
        root.Material = Enum.Material.ForceField

        -- Create a green outline box
        if not root:FindFirstChild("BigBackOutline") then
            local selectionBox = Instance.new("SelectionBox")
            selectionBox.Name = "BigBackOutline"
            selectionBox.Adornee = root
            selectionBox.Parent = root
            selectionBox.LineThickness = 0.05
            selectionBox.Color3 = Color3.fromRGB(0, 255, 0) -- Green
        end
    end
end

-- Apply hitbox expansion to all players
local function updateHitboxes(size)
    HitboxSize = size
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            expandHitbox(player, size)
        end
    end
end

-- Auto-update hitbox when new players join
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

FeaturesTab:AddSlider({
    Name = "BigBackExpander",
    Min = 2,
    Max = 20,
    Default = 2,
    Color = Color3.fromRGB(0, 255, 0), -- Green
    Increment = 1,
    ValueName = "Hitbox Size",
    Callback = function(Value)
        updateHitboxes(Value)
    end    
})

OrionLib:Init()
