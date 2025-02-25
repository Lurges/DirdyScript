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
local NigBotEnabled = false
local HitboxSize = 5
local JitterAmount = 1
local AimFOV = 100
local AimStrength = 100
local Friends = {}

-- Add friend function
local function addFriend(username)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name == username then
            Friends[player.UserId] = true
            OrionLib:MakeNotification({
                Name = "Friend Added",
                Content = username .. " has been added to your friend list!",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            return
        end
    end
    OrionLib:MakeNotification({
        Name = "Error",
        Content = "Player not found! Make sure they are in the game.",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

local FeaturesTab = Window:MakeTab({
    Name = "Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FeaturesTab:AddTextbox({
    Name = "Add Friend",
    Default = "",
    TextDisappear = true,
    Callback = function(username)
        addFriend(username)
    end
})

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = AimFOV
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false

local function updateFOV()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Radius = AimFOV
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
    if not NigBotEnabled then return end

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        NigBotEnabled = true
        FOVCircle.Visible = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        NigBotEnabled = false
        FOVCircle.Visible = false
    end
end)

RunService.RenderStepped:Connect(function()
    if NigBotEnabled then
        aimlock()
    end
    updateFOV()
end)

-- Hitbox Expander Function
local function expandHitbox(player, baseSize, jitter)
    if player ~= LocalPlayer and not Friends[player.UserId] and player.Character then
        local targetPart = player.Character:FindFirstChild("HumanoidRootPart") 
            or player.Character:FindFirstChild("Torso") 
            or player.Character:FindFirstChild("UpperTorso")

        if targetPart then
            local newSize = baseSize + (math.random(0, 1) * 2 - 1) * jitter
            targetPart.Size = Vector3.new(newSize, newSize, newSize)
            targetPart.Transparency = 0.5
            targetPart.Material = Enum.Material.ForceField
            targetPart.CanCollide = false
            targetPart.CanTouch = false

            if not targetPart:FindFirstChild("BigBackOutline") then
                local selectionBox = Instance.new("SelectionBox")
                selectionBox.Name = "BigBackOutline"
                selectionBox.Adornee = targetPart
                selectionBox.Parent = targetPart
                selectionBox.LineThickness = 0.05
                selectionBox.Color3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end

local function updateHitboxes(baseSize, jitter)
    HitboxSize = baseSize
    JitterAmount = jitter
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not Friends[player.UserId] then
            expandHitbox(player, baseSize, jitter)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not Friends[player.UserId] then
            expandHitbox(player, HitboxSize, JitterAmount)
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not Friends[player.UserId] then
            expandHitbox(player, HitboxSize, JitterAmount)
        end
    end
end)

FeaturesTab:AddToggle({
    Name = "GoonESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
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
    Max = 200,
    Default = 5,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Hitbox Size",
    Callback = function(Value)
        updateHitboxes(Value, JitterAmount)
    end    
})

OrionLib:Init()
