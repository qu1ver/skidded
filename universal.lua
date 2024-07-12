local aimbotColor = Color3.fromRGB(255, 0, 0)
local espColor = Color3.fromRGB(255, 0, 0)
local walkspeedNum = 16

local lplr = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local worldToViewportPoint = camera.WorldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 1.5, 0)

local boxes = {}
local boxEnabled = false
local teamCheck = false

function createBox()
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = Color3.new(0, 0, 0)
    BoxOutline.Thickness = 3
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = espColor
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    return BoxOutline, Box
end

function boxesp(v)
    if not boxes[v] then
        boxes[v] = {createBox()}
    end
    local BoxOutline, Box = unpack(boxes[v])

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local RootPart = v.Character.HumanoidRootPart
            local Head = v.Character.Head
            local RootPosition, RootVis = worldToViewportPoint(camera, RootPart.Position)
            local HeadPosition = worldToViewportPoint(camera, Head.Position + HeadOff)
            local LegPosition = worldToViewportPoint(camera, RootPart.Position - LegOff)

            if RootVis and boxEnabled then
                BoxOutline.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                BoxOutline.Position = Vector2.new(RootPosition.X - BoxOutline.Size.X / 2, RootPosition.Y - BoxOutline.Size.Y / 2)
                BoxOutline.Visible = false

                Box.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                Box.Visible = true

                if teamCheck and v.TeamColor == lplr.TeamColor then
                    Box.Visible = false
                    BoxOutline.Visible = false
                else
                    Box.Color = Color3.new(1, 0, 0)
                end
            else
                BoxOutline.Visible = false
                Box.Visible = false
            end
        else
            BoxOutline.Visible = false
            Box.Visible = false
        end
    end)

    v.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
            BoxOutline:Remove()
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
        boxes[v][2]:Remove()
        boxes[v] = nil
    end
end)

--> AIMBOT <--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Holding = false

-- AIMBOT SETTINGS

_G.AimbotEnabled = false
_G.TweenCheck = true
_G.AimPart = "Head"
_G.Sensitivity = 0

-- FOV CIRCLE SETTINGS

_G.CircleSides = 64
_G.CircleColor = aimbotColor
_G.CircleTransparency = 1
_G.CircleRadius = 80
_G.CircleFilled = false
_G.CircleVisible = false
_G.CircleThickness = 0

local FOVCIRCLE = Drawing.new("Circle")
FOVCIRCLE.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCIRCLE.Radius = _G.CircleRadius
FOVCIRCLE.Filled = _G.CircleFilled
FOVCIRCLE.Color = _G.CircleColor
FOVCIRCLE.Visible = _G.CircleVisible
FOVCIRCLE.Transparency = _G.CircleTransparency
FOVCIRCLE.NumSides = _G.CircleSides
FOVCIRCLE.Thickness = _G.CircleThickness

local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil

    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= LocalPlayer.Name then
            if _G.TeamCheck == true then
                if v.Team ~= LocalPlayer.Team then
                    if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local ScreenPoint = Camera:WorldToScreenPoint(v.Character:FindFirstChild("HumanoidRootPart", true).Position)
                        local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                        if VectorDistance < MaximumDistance then
                            MaximumDistance = VectorDistance
                            Target = v
                        end
                    end
                end
            else
                if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local ScreenPoint = Camera:WorldToScreenPoint(v.Character:FindFirstChild("HumanoidRootPart", true).Position)
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
    FOVCIRCLE.Radius = _G.CircleRadius
    FOVCIRCLE.Filled = _G.CircleFilled
    FOVCIRCLE.Color = _G.CircleColor
    FOVCIRCLE.Visible = _G.CircleVisible
    FOVCIRCLE.Transparency = _G.CircleTransparency
    FOVCIRCLE.NumSides = _G.CircleSides
    FOVCIRCLE.Thickness = _G.CircleThickness

    if Holding and _G.AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(_G.AimPart) then
            local Tween = TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[_G.AimPart].Position)})
            Tween:Play()
        end
    end
end)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
humanoid.WalkSpeed = walkspeedNum



-- UI Integration
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/qu1ver/Roblox-UI-Libraries/main/splixx-ui.lua')))()
local window = library:new({ textsize = 13.5, font = Enum.Font.RobotoMono, name = "Skidded Sigma Universal Homo Cheat V2", color = Color3.fromRGB(255, 0, 0) })

local tab1 = window:page({ name = "Aimbot" })
local tab2 = window:page({ name = "Visuals" })
local tab3 = window:page({ name = "Misc" })

local section1 = tab1:section({ name = "Aimbot", side = "left", size = 250 })
local section2 = tab2:section({ name = "ESP", side = "left", size = 250 })
local section3 = tab3:section({ name = "Local Player", side = "Right", size = 250 })

section3:slider({ name = "Walkspeed", def = 16, max = 2450, min = 16, rounding = true, ticking = false, measuring = "", callback = function(value)
    humanoid.WalkSpeed = value
end })

section1:toggle({ name = "Enabled", def = false, callback = function(boolean)
    _G.AimbotEnabled = boolean
end })

section1:toggle({ name = "FoV Visible", def = false, callback = function(boolean)
    _G.CircleVisible = boolean
end})

section1:slider({ name = "FoV Size", def = 80, max = 360, min = 10, rounding = true, ticking = false, measuring = "", callback = function(value)
    _G.CircleRadius = value
end})

section1:colorpicker({name = "FoV Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color) _G.CircleColor = color end})

section2:toggle({ name = "Enabled", def = false, callback = function(boolean)
    boxEnabled = boolean
end})

section2:toggle({ name = "Team Check", def = false, callback = function(boolean)
    teamCheck = boolean
end})

section2:colorpicker({name = "Box Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color) espColor = color end})






print("kaasgenieter skidded this")
