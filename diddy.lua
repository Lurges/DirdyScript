local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
  Name = "DiddyHub",
  HidePremium = false,
  SaveConfig = true,
  ConfigFolder = "OrionTest",
  IntroEnabled = false
})

local Players = game:GetService("Players")
local HighlightToggled = false

local function highlightPlayers(enable)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            
            -- Check if already has adornment
            if enable then
                if not root:FindFirstChild("HighlightBox") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "HighlightBox"
                    box.Parent = root
                    box.Adornee = root
                    box.Size = Vector3.new(4, 6, 4)
                    box.Color3 = Color3.fromRGB(255, 0, 0) -- Red
                    box.Transparency = 0.5
                    box.AlwaysOnTop = true
                    box.ZIndex = 2
                end
            else
                if root:FindFirstChild("HighlightBox") then
                    root:FindFirstChild("HighlightBox"):Destroy()
                end
            end
        end
    end
end

local Toggle = Window:MakeTab({
  Name = "ESP",
  Icon = "rbxassetid://4483345998",
  PremiumOnly = false
})

Toggle:AddToggle({
    Name = "Highlight Players",
    Default = false,
    Callback = function(Value)
        HighlightToggled = Value
        highlightPlayers(Value)
    end    
})

OrionLib:Init()
