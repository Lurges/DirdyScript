local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/refs/heads/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "DiddyHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest",
    IntroEnabled = false
})

OrionLib:MakeNotification({
    Name = "JOIN THE CORD NOW DUDE",
    Content = "Discord - https://discord.gg/cUjbFJydgJ",
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
local AimlockEnabled = false
local NoCooldownEnabled = false
local HitboxSize = 5
local AimFOV = 100
local AimStrength = 100
local Friends = {}

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local function removeCooldown()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "FireRate") then
            v.FireRate = NoCooldownEnabled and math.huge or v.FireRate
        end
        if type(v) == "table" and rawget(v, "Cooldown") then
            v.Cooldown = NoCooldownEnabled and 0 or v.Cooldown
        end
        if type(v) == "table" and rawget(v, "LastShot") then
            v.LastShot = NoCooldownEnabled and 0 or v.LastShot
        end
    end
end

local function updateFOV()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Radius = AimFOV
    FOVCircle.Visible = AimlockEnabled
end

local function isPlayerVisible(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local headPos = player.Character.Head.Position
        local ray = Ray.new(Camera.CFrame.Position, (headPos - Camera.CFrame.Position).unit * 500)
        local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        return part and part:IsDescendantOf(player.Character)
    end
    return false
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and isPlayerVisible(player) then
            local screenPosition, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)

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

local function aimlock()
    if not AimlockEnabled then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local headPosition = target.Character.Head.Position

        -- Only adjust the camera, not the player's movement
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, headPosition), AimStrength / 100)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimlockEnabled = true
        updateFOV()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimlockEnabled = false
        updateFOV()
    end
end)

RunService.RenderStepped:Connect(function()
    if AimlockEnabled then
        aimlock()
    end
    updateFOV()
end)

-- Hitbox Expander
local function expandHitbox(player, size)
    if player ~= LocalPlayer and not Friends[player.UserId] and player.Character then
        local targetPart = player.Character:FindFirstChild("HumanoidRootPart") 
            or player.Character:FindFirstChild("Torso") 
            or player.Character:FindFirstChild("UpperTorso")

        if targetPart then
            targetPart.Size = Vector3.new(size, size, size)
            targetPart.Transparency = 0.5
            targetPart.Material = Enum.Material.ForceField
            targetPart.CanCollide = false

            if not targetPart:FindFirstChild("HitboxOutline") then
                local selectionBox = Instance.new("SelectionBox")
                selectionBox.Name = "HitboxOutline"
                selectionBox.Adornee = targetPart
                selectionBox.Parent = targetPart
                selectionBox.LineThickness = 0.05
                selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end

local function updateHitboxes(size)
    HitboxSize = size
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not Friends[player.UserId] then
            expandHitbox(player, size)
        end
    end
end

-- ESP Functionality (Fixed)
local function highlightPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.Parent = player.Character
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if ESPEnabled then
        highlightPlayers()
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                if highlight then highlight:Destroy() end
            end
        end
    end

    if AimlockEnabled then
        aimlock()
    end
    updateFOV()
end)

-- UI Setup
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
    end    
})

FeaturesTab:AddToggle({
    Name = "No Cooldown",
    Default = false,
    Callback = function(Value)
        NoCooldownEnabled = Value
        removeCooldown()
    end    
})

FeaturesTab:AddSlider({
    Name = "Aimbot Strength",
    Min = 10,
    Max = 100,
    Default = 100,
    Color = Color3.fromRGB(77, 77, 255),
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
    Color = Color3.fromRGB(77, 77, 255),
    Increment = 10,
    ValueName = "FOV",
    Callback = function(Value)
        AimFOV = Value
        updateFOV()
    end    
})

FeaturesTab:AddSlider({
    Name = "Hitbox Expander",
    Min = 2,
    Max = 200,
    Default = 5,
    Color = Color3.fromRGB(77, 77, 255),
    Increment = 1,
    ValueName = "Hitbox Size",
    Callback = function(Value)
        updateHitboxes(Value)
    end    
})

OrionLib:Init()

