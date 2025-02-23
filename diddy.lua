local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
  Name = "DiddyHub",
  HidePremium = false,
  SaveConfig = true,
  ConfigFolder = "OrionTest",
  IntroEnabled = false
})

-- Notification
OrionLib:MakeNotification({
  Name = "Alert!",
  Content = "Remember To Join The Discord - https://discord.gg/cUjbFJydgJ",
  Image = "rbxassetid://10337369781",
  Time = 5
})

-- Create a Tab
local Tab = Window:MakeTab({
  Name = "Features",
  Icon = "rbxassetid://4483345998", -- Ensure this is a valid asset ID
  PremiumOnly = false
})

-- Button
Tab:AddButton({
  Name = "TestButton",
  Callback = function()
    print("DiddyHub TestButton")
  end    
})

-- Toggle
local CoolToggle = Tab:AddToggle({
  Name = "DiddyHubTestToggle",
  Default = false,
  Callback = function(Value)
    print(Value)
    CoolToggle:Set(true) -- This will set the toggle to true
  end    
})

-- Slider
local Slider = Tab:AddSlider({
  Name = "SlideMeYourShit",
  Min = 0,
  Max = 20,
  Default = 5,
  Color = Color3.fromRGB(255,16,240),
  Increment = 1,
  ValueName = "Baby Oil",
  Callback = function(Value)
    print(Value)
    Slider:Set(2) -- This will set the slider to 2
  end    
})

-- Label
Tab:AddLabel("This is a label little gooner")

-- Dropdown
Tab:AddDropdown({
  Name = "This is a fricking dropdown",
  Default = "Goon",
  Options = {"Goon", "Edge"},
  Callback = function(Value)
    print(Value)
  end    
})

-- Initialize Orion Library
OrionLib:Init()
