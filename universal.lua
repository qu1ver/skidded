local espColor = Color3.fromRGB(255, 0, 0) -- Define the default ESP color

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

-- Aimbot logic
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

local aimKey = Enum.KeyCode.E -- Example aim key, change as needed

dwUIS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == aimKey then
        settings.Aiming = not settings.Aiming -- Toggle the aiming state
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

local uis = game:GetService("UserInputService")

local infJump = false

uis.JumpRequest:Connect(function()
    if infJump then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- UI Integration
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'ShitSense.gay',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

local leftAimbotGroup = Tabs.Main:AddLeftGroupbox('Aimbot')
local leftOtherMisc = Tabs.Misc:AddLeftGroupbox('Other')
local leftLocalPlrMisc = Tabs.Misc:AddRightGroupbox('Local Player')
local leftVisuals = Tabs.Visuals:AddLeftGroupbox('ESP')

leftAimbotGroup:AddToggle('aimbotToggle', {
    Text = 'Enable',
    Default = false,
    Tooltip = 'Enables Aimbot',
    Callback = function(Value)
        settings.Aimbot = Value
    end
})

leftAimbotGroup:AddToggle('fovVisToggle', {
    Text = 'Show FoV',
    Default = false,
    Tooltip = 'Shows FoV',
    Callback = function(Value)
        settings.Draw_Aimbot_FoV = Value
        fovCircle.Visible = Value
    end
})

leftAimbotGroup:AddSlider('aimbotFov_Size', {
    Text = 'FoV Size',
    Default = 80,
    Min = 10,
    Max = 680,
    Rounding = 1,
    Callback = function(Value)
        settings.FoV_Radius = Value
        fovCircle.Radius = Value
    end
})

leftAimbotGroup:AddDropdown('aimPartDropdown', {
    Values = { 'Head', 'HumanoidRootPart' },
    Default = 1,
    Multi = false,
    Text = 'Aim part',
    Callback = function(Value)
        settings.Aimbot_AimPart = Value
    end
})

leftVisuals:AddToggle('boxToggle', {
    Text = 'Enable Box ESP',
    Default = false,
    Tooltip = 'Enables Box ESP',
    Callback = function(Value)
        boxEnabled = Value
    end
})

leftVisuals:AddToggle('boxFillToggle', {
    Text = 'Box Fill',
    Default = false,
    Tooltip = 'Enables Box Fill',
    Callback = function(Value)
        boxFill = Value
    end
})

leftVisuals:AddToggle('teamCheckToggle', {
    Text = 'Team Check',
    Default = false,
    Tooltip = 'Enables Team Check for ESP',
    Callback = function(Value)
        teamCheck = Value
    end
})

leftOtherMisc:AddToggle('hitsoundToggle', {
    Text = 'Hit sound',
    Default = false,
    Tooltip = 'Enables hitsound',
})

leftOtherMisc:AddDropdown('hitSound', {
    Values = { 'Rust', 'Mario' },
    Default = 1,
    Multi = false,
    Text = 'Hit sound'
})

local infJumpToggle = leftLocalPlrMisc:AddToggle('infJumpToggle', {
    Text = 'Infinite jump',
    Default = false,
    Tooltip = 'Enables infinite jump'
})

infJumpToggle:OnChanged(function(Value)
    infJump = Value
end)

Library.KeybindFrame.Visible = false

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Library.Unloaded = true
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Insert', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
SaveManager:SetFolder('ShitSense.gay/Arsenal')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
