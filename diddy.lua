local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "DiddyHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest",
    IntroEnabled = false
})

OrionLib:MakeNotification({
	Name = "JOIN THE CORD NOW DUDE",
	Content = "Discord -https://discord.gg/cUjbFJydgJ",
	Image = "rbxassetid://4483345998",
	Time = 5
})




local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local LocalPlayer = Players.LocalPlayer
local Players = game:GetService("Players")


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

-- Function to check if a player is visible
local function isPlayerVisible(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local headPos = player.Character.Head.Position
        local ray = Ray.new(Camera.CFrame.Position, (headPos - Camera.CFrame.Position).unit * 500)
        local part = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        return part and part:IsDescendantOf(player.Character)
    end
    return false
end

-- Function to get the closest visible player inside FOV
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

-- Function to apply ESP
local function applyESP(player)
    if player ~= LocalPlayer then -- Don't apply ESP to yourself
        local function setupCharacter(character)
            if character and not character:FindFirstChild("ESPBox") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPBox"
                highlight.Parent = character
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White
                highlight.FillTransparency = 0.2
                highlight.OutlineTransparency = 0

                -- Make sure we do NOT highlight the expanded hitbox
                local adorneePart = character:FindFirstChild("Head") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

                if adorneePart then
                    highlight.Adornee = adorneePart
                else
                    highlight:Destroy() -- Prevent broken ESP
                end
            end
        end

        if player.Character then
            setupCharacter(player.Character)
        end

        -- Apply ESP when they respawn
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5) -- Small delay to make sure character loads
            if ESPEnabled then
                setupCharacter(char)
            end
        end)
    end
end

local function removeESP(player)
    if player.Character and player.Character:FindFirstChild("ESPBox") then
        player.Character.ESPBox:Destroy()
    end
end

-- Constantly check and fix missing ESP
local function updateESP()
    while ESPEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if ESPEnabled then
                applyESP(player)
            else
                removeESP(player)
            end
        end
        task.wait(1) -- Check every second
    end
end

local function toggleESP(enable)
    ESPEnabled = enable
    if enable then
        updateESP() -- Start checking constantly
    else
        for _, player in pairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end

-- Ensure new players get ESP when they join
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        applyESP(player)
    end
end)

-- Aimbot Function (Now Locks to Head & Turns Off Correctly)
local function aimlock()
    if not NigBotEnabled then return end -- Only run if enabled

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        NigBotEnabled = true -- Enable aimbot when right-click is held
        FOVCircle.Visible = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        NigBotEnabled = false -- Disable aimbot when right-click is released
        FOVCircle.Visible = false
    end
end)


RunService.RenderStepped:Connect(function()
    if NigBotEnabled then
        aimlock()
    end
    updateFOV()
end)


-- Hitbox Expander Function (Non-Collidable)
local function expandHitbox(player, size)
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        root.Size = Vector3.new(size, size, size)
        root.Transparency = 0.5
        root.Material = Enum.Material.ForceField

        -- Disable collision so it doesn't push you
        root.CanCollide = false
        root.CanTouch = false

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

-- Update Hitbox Expansion (Excludes Local Player)
local function updateHitboxes(size)
    HitboxSize = size
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            expandHitbox(player, size)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        expandHitbox(player, HitboxSize)
    end
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
