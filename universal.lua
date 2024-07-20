local lineESP = false
local lineColor = Color3.new(1, 0, 0)
local espColor = Color3.new(1, 0, 0)
local walkspeedNum = 16
local infJumpEnabled = false

-- Spinbot
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local spinSpeed = 10
local spinEnabled = false

local function spin()
    game:GetService("RunService").RenderStepped:Connect(function()
        if spinEnabled then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
        end
    end)
end

spin()

local lplr = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = camera.WorldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 1.5, 0)

local boxes = {}
local boxEnabled = false
local boxFill = false
local teamCheck = false

function createBox()
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = espColor
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    local boxFilled = Drawing.new("Square")
    boxFilled.Visible = false
    boxFilled.Color = espColor
    boxFilled.Thickness = 1
    boxFilled.Transparency = 0.35
    boxFilled.Filled = true

    return Box, boxFilled
end

local function boxesp(v)
    if not boxes[v] then
        boxes[v] = { createBox() }
    end
    local Box = boxes[v][1]
    local boxFilled = boxes[v][2]

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
                boxFilled.Size = Box.Size
                boxFilled.Position = Box.Position
                boxFilled.Visible = boxFill

                if teamCheck and v.Team == lplr.Team then
                    Box.Visible = false
                    boxFilled.Visible = false
                else
                    Box.Color = espColor
                    boxFilled.Color = espColor
                end
            else
                Box.Visible = false
                boxFilled.Visible = false
            end
        else
            Box.Visible = false
            boxFilled.Visible = false
        end
    end)

    v.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
            Box:Remove()
            boxFilled:Remove()
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

-- AIMBOT --
local dwCamera = workspace.CurrentCamera
local dwRunService = game:GetService("RunService")
local dwUIS = game:GetService("UserInputService")
local dwEntities = game:GetService("Players")
local dwLocalPlayer = dwEntities.LocalPlayer
local dwMouse = dwLocalPlayer:GetMouse()

local settings = {
    Aimbot = false,
    Aiming = false,
    Aimbot_AimPart = "Head",
    Aimbot_TeamCheck = false,
    Draw_Aimbot_FoV = false,
    FoV_Radius = 80,
    FoV_Color = Color3.fromRGB(255, 0, 0)
}

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = settings.Draw_Aimbot_FoV
fovCircle.Radius = settings.FoV_Radius
fovCircle.Color = settings.FoV_Color
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 1

fovCircle.Position = Vector2.new(dwCamera.ViewportSize.X / 2, dwCamera.ViewportSize.Y / 2)

dwUIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = true
    end
end)

dwUIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = false
    end
end)

dwRunService.RenderStepped:Connect(function()
    local dist = math.huge
    local closest_char = nil

    if settings.Aiming and settings.Aimbot then
        for _, v in pairs(dwEntities:GetPlayers()) do
            if v ~= dwLocalPlayer and
            v.Character and
            v.Character:FindFirstChild("HumanoidRootPart") and
            v.Character:FindFirstChild("Humanoid") and
            v.Character.Humanoid.Health > 0 then

                if (v.Team ~= dwLocalPlayer.Team or not settings.Aimbot_TeamCheck) then

                    local char = v.Character
                    local char_part_pos, is_onscreen = dwCamera:WorldToViewportPoint(char[settings.Aimbot_AimPart].Position)

                    if is_onscreen then
                        local mag = (Vector2.new(dwMouse.X, dwMouse.Y) - Vector2.new(char_part_pos.X, char_part_pos.Y)).Magnitude

                        if mag < dist and mag < settings.FoV_Radius then
                            dist = mag
                            closest_char = char
                        end
                    end
                end
            end
        end

        if closest_char and
        closest_char:FindFirstChild("HumanoidRootPart") and
        closest_char:FindFirstChild("Humanoid") and
        closest_char.Humanoid.Health > 0 then

            dwCamera.CFrame = CFrame.new(dwCamera.CFrame.Position, closest_char[settings.Aimbot_AimPart].Position)
        end
    end
end)

-- LINE ESP --
local tracers = {}

local function lineesp(v)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = lineColor
    Tracer.Thickness = 2
    Tracer.Transparency = 1

    tracers[v] = Tracer

    local connection
    connection = game:GetService("RunService").RenderStepped:Connect(function()
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local Vector, OnScreen = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)

            if OnScreen then
                Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                Tracer.To = Vector2.new(Vector.X, Vector.Y)

                if teamCheck and v.Team == lplr.Team then
                    Tracer.Visible = false
                else
                    Tracer.Visible = lineESP
                    Tracer.Color = lineColor
                end
            else
                Tracer.Visible = false
            end
        else
            Tracer.Visible = false
        end
    end)

    v.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
            Tracer:Remove()
            tracers[v] = nil
        end
    end)
end

for _, v in pairs(game.Players:GetPlayers()) do
    lineesp(v)
end

game.Players.PlayerAdded:Connect(function(v)
    lineesp(v)
end)

game.Players.PlayerRemoving:Connect(function(v)
    if tracers[v] then
        tracers[v]:Remove()
        tracers[v] = nil
    end
end)

-- Walkspeed and Infinite Jump
local humanoid = character:WaitForChild("Humanoid")
humanoid.WalkSpeed = walkspeedNum

local userInputService = game:GetService("UserInputService")

userInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- UI Library
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/qu1ver/Roblox-UI-Libraries/main/splixx-ui.lua')))()
local window = library:new({ textsize = 13.5, font = Enum.Font.RobotoMono, name = "Shit Cheat.cc", color = espColor })

local tab1 = window:page({ name = "Aimbot" })
local tab6 = window:page({ name = "Anti-aim" })
local tab2 = window:page({ name = "Visuals" })
local tab3 = window:page({ name = "Misc" })
local tab4 = window:page({ name = "Player" })
local tab5 = window:page({ name = "Settings" })

local section1 = tab1:section({ name = "Aimbot", side = "left", size = 250 })
local section6 = tab6:section({ name = "Anti-Aim", side = "left", size = 250 })
local section2 = tab2:section({ name = "ESP", side = "left", size = 250 })
local section3 = tab3:section({ name = "Misc", side = "left", size = 250 })
local section4 = tab4:section({ name = "Local Player", side = "left", size = 250 })
local section5 = tab5:section({ name = "UI", side = "left", size = 75 })

section1:toggle({ name = "Enabled", def = false, callback = function(boolean)
    settings.Aimbot = boolean
end })

section1:dropdown({ name = "Hitbox", def = "Head", options = { "Head", "HumanoidRootPart" }, callback = function(selectedOption)
    settings.Aimbot_AimPart = selectedOption
end })

section1:toggle({ name = "FoV Visible", def = false, callback = function(boolean)
    fovCircle.Visible = boolean
end })

section1:toggle({ name = "Team Check", def = false, callback = function(boolean)
    settings.Aimbot_TeamCheck = boolean
end })

section1:slider({ name = "FoV Size", def = 80, max = 360, min = 10, rounding = true, ticking = false, measuring = "", callback = function(value)
    fovCircle.Radius = value
end })

section1:colorpicker({ name = "FoV Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color)
    fovCircle.Color = color
end })

section6:toggle({ name = "Spinbot", def = false, callback = function(boolean)
    spinEnabled = boolean
end })

section6:slider({ name = "Spinbot Speed", def = 10, max = 500, min = 10, rounding = true, ticking = false, measuring = "", callback = function(value)
    spinSpeed = value
end })

section2:toggle({ name = "Enabled", def = false, callback = function(boolean)
    boxEnabled = boolean
end })

section2:toggle({ name = "Filled", def = false, callback = function(boolean)
    boxFill = boolean
end })

section2:toggle({ name = "Tracer", def = false, callback = function(boolean)
    lineESP = boolean
end })

section2:toggle({ name = "Team Check", def = false, callback = function(boolean)
    teamCheck = boolean
end })

section2:colorpicker({ name = "Box Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color)
    espColor = color
    for _, box in pairs(boxes) do
        box[1].Color = color
        box[2].Color = color
    end
end })

section2:colorpicker({ name = "Line Color", cpname = "Color Picker", def = Color3.fromRGB(255, 0, 0), callback = function(color)
    lineColor = color
    for _, tracer in pairs(tracers) do
        tracer.Color = color
    end
end })

section4:slider({ name = "Walkspeed", def = 16, max = 2450, min = 16, rounding = true, ticking = false, measuring = "", callback = function(value)
    walkspeedNum = value
    humanoid.WalkSpeed = value
end })

section4:toggle({ name = "+Inf jump", def = false, callback = function(boolean) -- New toggle for infinite jump
    infJumpEnabled = boolean
end })

section5:keybind({ name = "UI Bind", def = nil, callback = function(key)
    window.key = key
end })
