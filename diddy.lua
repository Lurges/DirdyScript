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
local AimBotEnabled = false
local HitboxSize = 2
local AimFOV = 100
local AimStrength = 100
local Friends = {}

-- Add Friend Function
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
    Callback = addFriend
})

-- FOV Circle
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
    if not AimBotEnabled then return end
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        AimBotEnabled = true
        FOVCircle.Visible = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimBotEnabled = false
        FOVCircle.Visible = false
    end
end)

RunService.RenderStepped:Connect(function()
    if AimBotEnabled then
        aimlock()
    end
    updateFOV()
end)

FeaturesTab:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
    end    
})

FeaturesTab:AddToggle({
    Name = "AimBot",
    Default = false,
    Callback = function(Value)
        AimBotEnabled = Value
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

OrionLib:Init()
