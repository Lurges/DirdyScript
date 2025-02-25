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
local SpinBotEnabled = false
local SpinSpeed = 50

local Friends = {}

-- add friend
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

local FriendsTab = Window:MakeTab({
    Name = "Friends",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FriendsTab:AddTextbox({
    Name = "Add Friend",
    Default = "",
    TextDisappear = true,
    Callback = function(username)
        addFriend(username)
    end
})

-- Function to perform SpinBot
local function spinbot()
    while SpinBotEnabled do
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Instantly snap to the enemy's head while spinning
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position) * CFrame.Angles(0, math.rad(SpinSpeed), 0)
        else
            -- If no target, just spin in place
            Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
        end
        task.wait(0.01) -- Small delay to prevent crashing
    end
end

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
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2) -- Center it properly
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

-- Hard Lock AimBot (Locks Instantly to Closest Head in FOV)
local function aimlock()
    if not NigBotEnabled then return end -- Only run if enabled

    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        -- Instantly snap to the enemy's head
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end

-- Get Closest Enemy Inside FOV Circle
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimFOV  -- Only check inside FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
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

-- Aimlock Activation (Hold Right Click)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        NigBotEnabled = true -- Enable aimbot when right-click is held
        FOVCircle.Visible = true
    end
end)

-- Aimlock Deactivation (Release Right Click)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        NigBotEnabled = false -- Disable aimbot when right-click is released
        FOVCircle.Visible = false
    end
end)

-- Constantly Run Aimlock (Every Frame)
RunService.RenderStepped:Connect(function()
    if NigBotEnabled then
        aimlock()
    end
    updateFOV()  -- Update FOV circle position
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Friends = {} -- Your list of friends, you can populate this as needed

-- Hitbox Expander Function (Non-Collidable)
local function expandHitbox(player, size)
    if player ~= LocalPlayer and not Friends[player.UserId] and player.Character then
        local targetPart = player.Character:FindFirstChild("HumanoidRootPart") 
            or player.Character:FindFirstChild("Torso") 
            or player.Character:FindFirstChild("UpperTorso") -- Use alternative parts

        if targetPart then
            targetPart.Size = Vector3.new(size, size, size)
            targetPart.Transparency = 0.5
            targetPart.Material = Enum.Material.ForceField

            -- Disable collision so it doesn't push you
            targetPart.CanCollide = false
            targetPart.CanTouch = false

            -- Green outline
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

-- Update Hitbox Expansion (Ensures all players get it)
local function updateHitboxes(size)
    HitboxSize = size
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not Friends[player.UserId] then
            expandHitbox(player, size)
        end
    end
end

-- Apply hitbox expansion when players spawn
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5) -- Give time for character to load
        if not Friends[player.UserId] then
            expandHitbox(player, HitboxSize)
        end
    end)
end)

-- Apply hitbox to all players (when feature is turned on)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and not Friends[player.UserId] then
        expandHitbox(player, HitboxSize)
    end
end

-- Constantly update the hitboxes for all players
RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not Friends[player.UserId] then
            expandHitbox(player, HitboxSize) -- Keep expanding hitbox
        end
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
    Max = 200,
    Default = 2,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Hitbox Size",
    Callback = function(Value)
        updateHitboxes(Value)
    end    
})


FeaturesTab:AddToggle({
    Name = "Enable SpinBot",
    Default = false,
    Callback = function(Value)
        SpinBotEnabled = Value
        if Value then
            task.spawn(spinbot) -- Start spinning
        end
    end    
})

FeaturesTab:AddSlider({
    Name = "Spin Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 5,
    ValueName = "Speed",
    Callback = function(Value)
        SpinSpeed = Value
    end    
})

OrionLib:Init()
