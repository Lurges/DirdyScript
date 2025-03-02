local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/refs/heads/main/source')))()
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
local AimlockEnabled = false
local NoCooldownEnabled = false
local FOVCircleEnabled = false
local HitboxSize = 5
local AimFOV = 100
local AimStrength = 100
local Friends = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local function updateFOV()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Radius = AimFOV
    FOVCircle.Visible = FOVCircleEnabled
end

local function removeCooldown()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and (rawget(v, "FireRate") or rawget(v, "Cooldown") or rawget(v, "LastShot")) then
            if NoCooldownEnabled then
                if rawget(v, "FireRate") then v.FireRate = math.huge end
                if rawget(v, "Cooldown") then v.Cooldown = 0 end
                if rawget(v, "LastShot") then v.LastShot = 0 end
            end
        end
    end
end

local function highlightPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild("Head")
            if targetPart and not player.Character:FindFirstChild("HitboxOutline") then
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
end

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
        expandHitbox(player, size)
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

    updateFOV()
end)

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

FeaturesTab:AddToggle({
    Name = "Aimlock",
    Default = false,
    Callback = function(Value)
        AimlockEnabled = Value
    end    
})

FeaturesTab:AddToggle({
    Name = "FOV Circle",
    Default = false,
    Callback = function(Value)
        FOVCircleEnabled = Value
        updateFOV()
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
