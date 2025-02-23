local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "DiddyHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OrionTest",
    IntroEnabled = false
})

OrionLib:MakeNotification({
	Name = "Title!",
	Content = "Join The Diddy Discord - https://discord.gg/cUjbFJydgJ",
	Image = "rbxassetid://4483345998",
	Time = 5
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ESPEnabled = false

local function createESP(player)
    if player ~= Players.LocalPlayer and player.Character then
        local char = player.Character
        if not char:FindFirstChild("GoonESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "GoonESP"
            highlight.Parent = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
            highlight.FillTransparency = 0.2
            highlight.OutlineTransparency = 0
        end
    end
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
            createESP(player)
        else
            removeESP(player)
        end
    end
end

-- Keep updating ESP when players spawn
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            createESP(player)
        end
    end)
end)

local ESPTab = Window:MakeTab({
    Name = "Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ESPTab:AddToggle({
    Name = "GoonESP",
    Default = false,
    Callback = function(Value)
        toggleESP(Value)
    end    
})

OrionLib:Init()
