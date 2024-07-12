local uiColor = Color3.fromRGB(255, 0, 0)

local lineESP = false
local aimbotColor = Color3.fromRGB(255, 0, 0)
local espColor = Color3.fromRGB(255, 0, 0)
local walkspeedNum = 16

local lplr = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = camera.worldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 1.5, 0)

local boxes = {}
local boxEnabled = false
local teamCheck = false

function createBox()
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = espColor
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    return Box
end

local function boxesp(v)
    if not boxes[v] then
        boxes[v] = { createBox() }
    end
    local Box = boxes[v][1]

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local RootPart = v.Character.HumanoidRootPart
            local Head = v.Character.Head
            local RootPosition, RootVis = worldToViewportPoint(camera, RootPart.Position)
            local HeadPosition = worldToViewportPoint(camera, Head.Position + HeadOff)
            local LegPosition = worldToViewportPoint(camera, RootPart.Position - LegOff)

            if RootVis and boxEnabled then
                Box.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                Box.Visible = true

                if teamCheck and v.TeamColor == lplr.TeamColor then
                    Box.Visible = false
                else
                    Box.Color = Color3.new(1, 0, 0)
                end
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end)

    v.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
            Box:Remove()
            boxes[v] = nil
        end
    end)
end

for _, v in pairs(game.Players:GetPlayers()) do
    boxesp(v)
end

game.Players.PlayerAdded:Connect(function(v)
    boxesp(v)
end)

game.Players.PlayerRemoving:Connect(function(v)
    if boxes[v] then
        boxes[v][1]:Remove()
        boxes[v] = nil
    end
end)

-- LINE ESP --

local function lineesp(v)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.new(1, 0, 0)
    Tracer.Thickness = 2
    Tracer.Transparency = 1

    game:GetService("RunService").RenderStepped:Connect(function()
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)

            if OnScreen then
                Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 1)
                Tracer.To = Vector2.new(Vector.X, Vector.Y)

                if teamCheck and v.TeamColor == lplr.TeamColor then
                    Tracer.Visible = false
                else
                    Tracer.Visible = lineESP
                end
            else
                Tracer.Visible = false
            end
        else
            Tracer.Visible = false
        end
    end)
end

for _, v in pairs(game.Players:GetPlayers()) do
    lineesp(v)
end

game.Players.PlayerAdded:Connect(function(v)
    lineesp(v)
end)

-- AIMBOT --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- AIMBOT SETTINGS
local TeamCheck = false
local AimbotEnabled = false
local AimPart = "Head"
local Sensitivity = 0

-- FOV CIRCLE SETTINGS

local CircleSides = 64
local CircleColor = aimbotColor
local CircleTransparency = 1
local CircleRadius = 80
local CircleFilled = false
local CircleVisible = false
local CircleThickness = 0

local FOVCIRCLE = Drawing.new("Circle")
FOVCIRCLE.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCIRCLE.Radius = CircleRadius
FOVCIRCLE.Filled = CircleFilled
FOVCIRCLE.Color = CircleColor
FOVCIRCLE.Visible = CircleVisible
FOVCIRCLE.Transparency = CircleTransparency
FOVCIRCLE.NumSides = CircleSides
FOVCIRCLE.Thickness = CircleThickness

local function GetClosestPlayer()
    local MaximumDistance = CircleRadius
    local Target = nil

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if TeamCheck then
                if v.Team ~= LocalPlayer.Team then
                    if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        local ScreenPoint = Camera:WorldToScreenPoint(v.Character:FindFirstChild("HumanoidRootPart").Position)
                        local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                        if VectorDistance < MaximumDistance then
                            MaximumDistance = VectorDistance
                            Target = v
                        end
                    end
                end
            else
                if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                    local ScreenPoint = Camera:WorldToScreenPoint(v.Character:FindFirstChild("HumanoidRootPart").Position)
                    local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                    if VectorDistance < MaximumDistance then
                        MaximumDistance = VectorDistance
                        Target = v
                    end
                end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCIRCLE.Position = UserInputService:GetMouseLocation()
    FOVCIRCLE.Radius = CircleRadius
    FOVCIRCLE.Filled = CircleFilled
    FOVCIRCLE.Color = CircleColor
    FOVCIRCLE.Visible = CircleVisible
    FOVCIRCLE.Transparency = CircleTransparency
    FOVCIRCLE.NumSides = CircleSides
    FOVCIRCLE.Thickness = CircleThickness

    if Holding and AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(AimPart) then
            local Tween = TweenService:Create(Camera, TweenInfo.new(Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[AimPart].Position) })
            Tween:Play()
        end
    end
end)

-- Local Player Walkspeed

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
humanoid.WalkSpeed = walkspeedNum

-- UI Integration
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/qu1ver/Roblox-UI-Libraries/main/splixx-ui.lua')))()
local window = library:new({ textsize = 13.5, font = Enum.Font.RobotoMono, name = "Skidded Sigma Universal Homo Cheat V2", color = uiColor })

local tab1 = window:page({ name = "Aimbot" })
local tab2 = window:page({ name = "Visuals" })
local tab3 = window:page({ name = "Misc" })
local tab4 = window:page({ name = "Settings" })

local section1 = tab1:section({ name = "Aimbot", side = "left", size = 250 })
local section2 = tab2:section({ name = "ESP", side = "left", size = 250 })
local section3 = tab3:section({ name = "Local Player", side = "left", size = 250 })
local section4 = tab4:section({ name = "UI", side = "left", size = 75 })

section1:toggle({ name = "Enabled", def = false, callback = function(boolean)
    AimbotEnabled = boolean
end })

section1:dropdown({ name = "Hitbox", def = "Head", options = { "Head", "HumanoidRootPart" }, callback = function(selectedOption)
    AimPart = selectedOption
end })

section1:toggle({ name = "FoV Visible", def = false, callback = function(boolean)
    CircleVisible = boolean
end })

section1:slider({ name = "FoV Size", def = 80, max = 360, min = 10, rounding = true, ticking = false, measuring = "", callback = function(value)
    CircleRadius = value
end })

section1:colorpicker({ name = "FoV Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color) CircleColor = color end })

section2:toggle({ name = "Enabled", def = false, callback = function(boolean)
    boxEnabled = boolean
end })

section2:toggle({ name = "Tracer", def = false, callback = function(boolean)
    lineESP = boolean
end })

section2:toggle({ name = "Team Check", def = false, callback = function(boolean)
    teamCheck = boolean
end })

section2:colorpicker({ name = "Box Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color) espColor = color end })

section3:slider({ name = "Walkspeed", def = 16, max = 2450, min = 16, rounding = true, ticking = false, measuring = "", callback = function(value)
    humanoid.WalkSpeed = value
end })

section4:keybind({ name = "UI Bind", def = nil, callback = function(key)
    window.key = key
end })

section4:colorpicker({ name = "UI Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color) uiColor = color end })

print("kaasgenieter skidded this")
