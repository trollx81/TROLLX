local notifyLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/dxhooknotify/src.lua", true))()
notifyLib:Notify("Authentication", "Initializing...", 3)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    local currentTime = os.date("%H:%M:%S")

    Library:SetWatermark(('Troll.cc | %s fps | %s ms | Time: %s'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()),
        currentTime
    ))
end)

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Plr = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local playerGui = Plr:WaitForChild("PlayerGui")
local lockedTarget = nil
local module = 'https://doitenroi.vercel.app'
loadstring(game:HttpGet(module .. "/module/adonis_bypass", true))()
local effectmodule = loadstring(game:HttpGet(module .. "/module/effectpro.lua", true))()

local Camlock = {
    Enabled = true,
    HorPrediction = 0.1,
    VertPrediction = 0.1,
    Smoothness = 1,
    AimPart = "Head",
    UnlockOnDeath = true
}

local TargetAim = {
    Enabled = true,
    HorPrediction = 0.1,
    VertPrediction = 0.1,
    AimPart = "Head",
    Method = "Index" -- Options: Index, Namecall
}

local HitSoundConfig = {
    Enabled = true,
    Current = "Skeet"
}

local HitSounds = {
    Click = "rbxassetid://4499400560",
    Bonk = "rbxassetid://6352582283",
    Minecraft = "rbxassetid://4018616850",
    Neverlose = "rbxassetid://6534948092",
    Fatality = "rbxassetid://6534947869",
    Skeet = "rbxassetid://5633695679",
    Rust = "rbxassetid://1255040462",
    Pop = "rbxassetid://198598793",
    Bubble = "rbxassetid://6534947588",
    Bruh = "rbxassetid://4275842574",
    UwU = "rbxassetid://8323804973",
    Gamesense = "rbxassetid://4817809188",
    Bameware = "rbxassetid://6565367558",
    COD = "rbxassetid://160432334"
}


local AutoAir = {
    Enabled = false,
    Delay = 0.05 
}

local Strafe = {
    Enabled = false,
    Distance = 6,
    Height = 0,
    Speed = 1.25
}

local Walkspeed = {
    Enabled = false,
    Bypass = false,
    Amount = 324,
    Key = Enum.KeyCode.Z
}

local JumpPower = {
    Enabled = false,
    Amount = 100,
    Key = Enum.KeyCode.X
}

local VisualToggles = {
    Highlight = false,
    Dot = false,
    --HitChams = false,
    HitSkeleton = false,
    HitEffect = false,
    CurrentHitEffect = "Nova"
}

local VisualColors = {
    --HitChams = Color3.fromRGB(255, 0, 0),
    HitSkeleton = Color3.fromRGB(255, 255, 255)
}

local lookat = {
    Enabled = false,
}

local HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.Volume = 1
HitSound.SoundId = HitSounds[HitSoundConfig.Current]
HitSound.Parent = game:GetService("CoreGui")
HitSound.PlayOnRemove = false

function getClosestPlayer()
    local closest, shortest = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= Plr and target.Character and target.Character:FindFirstChild(Camlock.AimPart) then
            local pos, visible = Camera:WorldToViewportPoint(target.Character[Camlock.AimPart].Position)
            if visible then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = target
                end
            end
        end
    end
    return closest
end

function playHitSound()
    if HitSoundConfig.Enabled then
        if HitSound.IsPlaying then HitSound:Stop() end
        HitSound:Play()
    end
    local hrp = lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart")
    if VisualToggles.HitEffect and hrp then
        task.spawn(function()
            effectmodule.run(VisualToggles.CurrentHitEffect, hrp.Position)
        end)
    end

    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }

    if VisualToggles.HitSkeleton and lockedTarget and lockedTarget.Character then
        local camera = workspace.CurrentCamera
        local drawings = {}

        for _, conn in ipairs(connections) do
            local part0 = lockedTarget.Character:FindFirstChild(conn[1])
            local part1 = lockedTarget.Character:FindFirstChild(conn[2])
            if part0 and part1 then
                local pos0, onScreen0 = camera:WorldToViewportPoint(part0.Position)
                local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)
                if onScreen0 and onScreen1 then
                    local line = Drawing.new("Line")
                    line.From = Vector2.new(pos0.X, pos0.Y)
                    line.To = Vector2.new(pos1.X, pos1.Y)
                    line.Thickness = 2
                    line.Transparency = 1
                    line.Color = VisualColors.HitSkeleton
                    line.Visible = true
                    table.insert(drawings, line)
                end
            end
        end

        task.delay(0.5, function()
            for _, line in ipairs(drawings) do
                line:Remove()
            end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if Camlock.Enabled and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild(Camlock.AimPart) then
        local hum = lockedTarget.Character:FindFirstChild("Humanoid")
        if Camlock.UnlockOnDeath and hum and hum.Health <= 0 then
            Camlock.Enabled = false
            lockedTarget = nil
            return
        end

        local aimPart = lockedTarget.Character[Camlock.AimPart]
        local hrp = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
        local velocity = hrp and hrp.Velocity or Vector3.zero

        local predicted = aimPart.Position + Vector3.new(
            velocity.X * Camlock.HorPrediction,
            velocity.Y * Camlock.VertPrediction,
            velocity.Z * Camlock.HorPrediction
        )

        local smooth = math.clamp(Camlock.Smoothness, 0, 1)
        if smooth <= 0 then return end

        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), smooth)
    end
end)

UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Keybind.Camlock then
        Camlock.Enabled = not Camlock.Enabled
        lockedTarget = Camlock.Enabled and getClosestPlayer() or nil
    elseif input.KeyCode == Keybind.TargetAim then
        TargetAim.Enabled = not TargetAim.Enabled
    elseif input.KeyCode == Enum.KeyCode.DPadUp and Camlock.Enabled then
        lockedTarget = getClosestPlayer()
    elseif input.KeyCode == Enum.KeyCode.DPadLeft and Walkspeed.Enabled then
        walkspeedToggled = not walkspeedToggled
        applyWalkspeed(walkspeedToggled)
    elseif input.KeyCode == Enum.KeyCode.DPadRight and JumpPower.Enabled then
        jumpToggled = not jumpToggled
        applyJumpPower(jumpToggled)
    end
end)


local lastTrackedTarget
local lastTrackedTarget
local lastAutoAirTime = 0

RunService.Heartbeat:Connect(function(dt)
    if lockedTarget and lockedTarget.Character then
        local hum = lockedTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and lockedTarget ~= lastTrackedTarget then
            lastTrackedTarget = lockedTarget
            local lastHealth = hum.Health
            hum.HealthChanged:Connect(function(newHealth)
                if newHealth < lastHealth then
                    playHitSound()
                end
                lastHealth = newHealth
            end)
        end
    end

    if Camlock.Enabled and AutoAir.Enabled and lockedTarget and lockedTarget.Character then
        local hum = lockedTarget.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.FloorMaterial == Enum.Material.Air then
            if tick() - lastAutoAirTime >= AutoAir.Delay then
                local tool = Plr.Character and Plr.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                lastAutoAirTime = tick()
            end
        end
    end
end)


local oldIndex = nil
local oldNamecall = nil

oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if TargetAim.Method == "Index" and not checkcaller() then
        if self:IsA("Mouse") and key == "Hit" and TargetAim.Enabled and lockedTarget and lockedTarget.Character then
            local part = lockedTarget.Character:FindFirstChild(TargetAim.AimPart)
            if part then
                local predicted = part.Position + (part.Velocity * TargetAim.HorPrediction)
                return CFrame.new(predicted)
            end
        end
    end
    return oldIndex(self, key)
end))

oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if TargetAim.Method == "Namecall" and not checkcaller() and method == "FireServer" and TargetAim.Enabled and lockedTarget and lockedTarget.Character then
        for i, v in pairs(args) do
            if typeof(v) == "Vector3" then
                local part = lockedTarget.Character:FindFirstChild(TargetAim.AimPart)
                if part then
                    args[i] = part.Position + (part.Velocity * TargetAim.HorPrediction)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end

    return oldNamecall(self, ...)
end))

local repo = 'https://raw.githubusercontent.com/VardySc/Pornhub/main/'
local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/VardySc/Pornhub/main/Library.lua'))()
local thememanager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local savemanager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

Library:SetWatermarkVisibility(true)

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "UIToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 70, 0, 50)
ToggleButton.Position = UDim2.new(1, -110, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Hide UI"
ToggleButton.Font = Enum.Font.Code
ToggleButton.TextSize = 14
ToggleButton.Parent = ToggleGui

local Outline = Instance.new("UIStroke")
Outline.Color = Color3.fromRGB(255, 255, 255)
Outline.Thickness = 1
Outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Outline.Parent = ToggleButton

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

local isVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    if library and library.Toggle then
        library:Toggle()
        isVisible = not isVisible
        ToggleButton.Text = isVisible and "Hide UI" or "Show UI"
    end
end)

local game_name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name


local Window = library:CreateWindow({
    Title = 'Pbass.cc',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "crosshair"),
	Visuals = Window:AddTab("Visuals", "eye"),
    Misc = Window:AddTab("Miscellaneous ", "wrench"),
    Settings = Window:AddTab("Settings", "settings")
}

local Groupboxes = { -- ngl the groupbox names look gpt af
    CamlockBox = Tabs.Main:AddLeftGroupbox('Camlock'),
    TargetAimBox = Tabs.Main:AddRightGroupbox('Target Aim'),
    AutoAirBox = Tabs.Main:AddLeftGroupbox('Auto Air'),
    TargetBox = Tabs.Main:AddRightGroupbox('Target Strafe'),
    HitSoundBox = Tabs.Misc:AddLeftGroupbox('Hit sounds'),
    HitEffectB = Tabs.Misc:AddRightGroupbox('Hit Effect'),
    MiscBox = Tabs.Misc:AddRightGroupbox('Utility'),
    VisualBox = Tabs.Visuals:AddLeftGroupbox('Highlight & Dot'),
}

Groupboxes.CamlockBox:AddToggle('CamlockToggle', {
    Text = 'Camlock Enabled',
    Default = Camlock.Enabled,
    Callback = function(val)
        Camlock.Enabled = val
        lockedTarget = val and getClosestPlayer() or nil
    end
})

Groupboxes.CamlockBox:AddButton('Create Button', function()
    if playerGui:FindFirstChild("DragGui") then return end

    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "DragGui"
    screenGui.ResetOnSpawn = true

    local gui = Instance.new("ScreenGui")
    local elysianButton = Instance.new("ImageButton")
    local button_corner = Instance.new("UICorner")

    
    local elysianButton = Instance.new("ImageButton", screenGui)
    elysianButton.Size = UDim2.new(0, 90, 0, 90)
    elysianButton.Position = UDim2.new(0.5, 0, 0.5, 0)
    elysianButton.AnchorPoint = Vector2.new(0.5, 0.5)
    elysianButton.AutoButtonColor = true
    elysianButton.Active = true
    elysianButton.Draggable = true
    local unlockedIcon = "rbxassetid://78029875561357"
    local lockedIcon = "rbxassetid://7"
    elysianButton.Image = unlockedIcon
    elysianButton.BackgroundTransparency = 0.350
		elysianButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

    Instance.new("UICorner", pbassButton).CornerRadius = UDim.new(0.2, 0)

    local dragging = false
local dragStart = Vector2.new()
local startPos = UDim2.new()
local activeInput = nil

local function isInJoystickArea(pos)
    return pos.X <= 150 and pos.Y >= workspace.CurrentCamera.ViewportSize.Y - 150
end

elysianButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if input.UserInputType == Enum.UserInputType.Touch and isInJoystickArea(input.Position) then
            return
        end

        dragging = true
        dragStart = input.Position
        startPos = elysianButton.Position
        activeInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                activeInput = nil
            end
        end)
    end
end)

UserInput.InputChanged:Connect(function(input)
    if dragging and input == activeInput and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)

        TweenService:Create(elysianButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = newPos
        }):Play()
    end
end)

    local isPopping = false
    elysianButton.MouseButton1Click:Connect(function()
        if isPopping then return end
        isPopping = true

        Camlock.Enabled = not Camlock.Enabled
        lockedTarget = Camlock.Enabled and getClosestPlayer() or nil
        elysianButton.Image = Camlock.Enabled and lockedIcon or unlockedIcon

        local buttonStart = elysianButton.Size

        local tweenUp = TweenService:Create(pbassButton, TweenInfo.new(0.1), {
            Size = buttonStart + UDim2.new(0, 6, 0, 6)
        })
        local tweenDown = TweenService:Create(pbassButton, TweenInfo.new(0.1), {
            Size = buttonStart
        })

        tweenUp:Play()
        tweenUp.Completed:Connect(function()
            tweenDown:Play()
        end)
        tweenDown.Completed:Connect(function()
            isPopping = false
        end)
    end)
end)

Groupboxes.CamlockBox:AddDropdown('CamlockAimPart', {
    Values = { 'Head', 'UpperTorso', 'LowerTorso', 'HumanoidRootPart' },
    Default = Camlock.AimPart,
    Text = 'Aim Part',
    Callback = function(val)
        Camlock.AimPart = val
    end
})

Groupboxes.CamlockBox:AddInput('CamlockHor', {
    Text = 'Horizontal Prediction X',
    Default = tostring(Camlock.HorPrediction),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Camlock.HorPrediction = tonumber(val) or 0.1
    end
})

Groupboxes.CamlockBox:AddInput('CamlockVert', {
    Text = 'Vertical Prediction Y',
    Default = tostring(Camlock.VertPrediction),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Camlock.VertPrediction = tonumber(val) or 0.1
    end
})

Groupboxes.CamlockBox:AddInput('CamlockSmooth', {
    Text = 'Smoothness',
    Default = tostring(Camlock.Smoothness),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Camlock.Smoothness = tonumber(val) or 1
    end
})

Groupboxes.CamlockBox:AddToggle('UnlockDeath', {
    Text = 'Unlock on',
    Default = Camlock.UnlockOnDeath,
    Callback = function(val)
        Camlock.UnlockOnDeath = val
    end
})

Groupboxes.TargetAimBox:AddToggle('TargetAimEnabled', {
    Text = 'Target Aim Enabled',
    Default = TargetAim.Enabled,
    Callback = function(val)
        TargetAim.Enabled = val
    end
})

Groupboxes.TargetAimBox:AddDropdown('TargetMethodDropdown', {
    Values = { 'Mouse', 'Index', 'Namecall' },
    Default = TargetAim.Method or 'Index',
    Text = 'Target Method',
    Callback = function(method)
        TargetAim.Method = method
    end
})

Groupboxes.TargetAimBox:AddInput('TargetHor', {
    Text = 'Horizontal Prediction X',
    Default = tostring(TargetAim.HorPrediction),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        TargetAim.HorPrediction = tonumber(val) or 0.1
    end
})

Groupboxes.TargetAimBox:AddInput('TargetVert', {
    Text = 'Vertical Prediction Y',
    Default = tostring(TargetAim.VertPrediction),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        TargetAim.VertPrediction = tonumber(val) or 0.1
    end
})

Groupboxes.TargetAimBox:AddDropdown('TargetAimPart', {
    Values = { 'Head', 'UpperTorso', 'LowerTorso', 'HumanoidRootPart' },
    Default = TargetAim.AimPart,
    Text = 'Aim Part',
    Callback = function(val)
        TargetAim.AimPart = val
    end
})

Groupboxes.HitSoundBox:AddToggle('ToggleHitSound', {
    Text = 'Enable Hit Sound',
    Default = HitSoundConfig.Enabled,
    Callback = function(val)
        HitSoundConfig.Enabled = val
    end
})

local hitSoundNames = {}
for name in pairs(HitSounds) do
    table.insert(hitSoundNames, name)
end

Groupboxes.HitSoundBox:AddDropdown('HitSoundDropdown', {
    Values = hitSoundNames,
    Default = HitSoundConfig.Current,
    Text = 'Hit Sound',
    Callback = function(val)
        HitSoundConfig.Current = val
        HitSound.SoundId = HitSounds[val] or ""
    end
})
Groupboxes.HitEffectB:AddToggle('ToggleHitEffect', {
    Text = 'Enable Hit Effect',
    Default = VisualToggles.HitEffect,
    Callback = function(val)
        VisualToggles.HitEffect = val
    end
})
Groupboxes.HitEffectB:AddDropdown('Hutefrectdd', {
    Values = effectmodule.geteffect(),
    Default = VisualToggles.CurrentHitEffect,
    Text = 'Effect',
    Callback = function(val)
        VisualToggles.CurrentHitEffect = val
    end
})
Groupboxes.MiscBox:AddButton('Create Auto Shoot Button', function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    if playerGui:FindFirstChild("AutoShootGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoShootGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local outerFrame = Instance.new("Frame")
    outerFrame.Size = UDim2.new(0, 240, 0, 48)
    outerFrame.Position = UDim2.new(0, 10, 0, 10)
    outerFrame.BackgroundColor3 = Color3.fromRGB(53, 50, 53)
    outerFrame.Parent = screenGui

    local uiCornerOuter = Instance.new("UICorner")
    uiCornerOuter.CornerRadius = UDim.new(0, 5)
    uiCornerOuter.Parent = outerFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 20, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 68, 71)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Code
    button.TextSize = 18
    button.Text = "Auto Shoot Off"
    button.Parent = outerFrame

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 5)
    uiCorner.Parent = button

    local autoShoot = false
    local shootingConnection = nil

    local function activateTool()
        local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end

    local function startAutoShoot()
        autoShoot = true
        button.Text = "Auto Shoot On"

        shootingConnection = RunService.Heartbeat:Connect(function()
            activateTool()
            task.wait(0.05)
        end)
    end

    local function stopAutoShoot()
        autoShoot = false
        button.Text = "Auto Shoot Off"

        if shootingConnection then
            shootingConnection:Disconnect()
            shootingConnection = nil
        end
    end

    button.MouseButton1Click:Connect(function()
        if autoShoot then
            stopAutoShoot()
        else
            startAutoShoot()
        end
    end)

    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    outerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = outerFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            TweenService:Create(outerFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = newPos
            }):Play()
        end
    end)
end)

local currentColor = Color3.fromRGB(255, 0, 0)

VisualToggles = VisualToggles or {}
VisualToggles.Highlight = VisualToggles.Highlight or false
VisualToggles.Dot = VisualToggles.Dot or false

local highlight = Instance.new("Highlight")
highlight.Name = "CamlockHighlight"
highlight.FillColor = currentColor
highlight.OutlineColor = currentColor
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0
highlight.Enabled = false
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = game:GetService("CoreGui")

local dotGui = Instance.new("ScreenGui")
dotGui.Name = "DotGui"
dotGui.ResetOnSpawn = false
dotGui.Parent = playerGui

local dot = Instance.new("Frame")
dot.Name = "CamlockDot"
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0.5, -4, 0.5, -4)
dot.BackgroundColor3 = currentColor
dot.BorderSizePixel = 0
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Visible = false
dot.Parent = dotGui

Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    local shouldShow = false
    local adornee = nil

    if Camlock.Enabled and lockedTarget and lockedTarget.Character then
        local part = lockedTarget.Character:FindFirstChild(Camlock.AimPart)
        if part then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                dot.Position = UDim2.new(0, screenPos.X - 4, 0, screenPos.Y - 4)
                shouldShow = true
                adornee = lockedTarget.Character
            end
        end
    end

    highlight.Enabled = VisualToggles.Highlight and shouldShow
    highlight.Adornee = adornee
    dot.Visible = VisualToggles.Dot and shouldShow
end)

local DotToggle = Groupboxes.VisualBox:AddToggle('DotToggle', {
    Text = 'Enable Dot',
    Default = VisualToggles.Dot,
    Callback = function(val)
        VisualToggles.Dot = val
    end
})

local HighlightToggle = Groupboxes.VisualBox:AddToggle('HighlightToggle', {
    Text = 'Enable Highlight',
    Default = VisualToggles.Highlight,
    Callback = function(val)
        VisualToggles.Highlight = val
    end
})

HighlightToggle:AddColorPicker('HighlightColor', {
    Default = currentColor,
    Title = 'Highlight/Dot Color',
    Transparency = 0,
    Callback = function(color)
        currentColor = color
        highlight.FillColor = color
        highlight.OutlineColor = color
        dot.BackgroundColor3 = color
    end
})

Groupboxes.AutoAirBox:AddToggle('AutoAirToggle', {
    Text = 'Auto Air',
    Default = AutoAir.Enabled,
    Callback = function(val)
        AutoAir.Enabled = val
    end
})

Groupboxes.AutoAirBox:AddInput('AutoAirDelay', {
    Text = 'Air Delay s',
    Default = tostring(AutoAir.Delay),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        AutoAir.Delay = tonumber(val) or 0.05
    end
})

Groupboxes.TargetBox:AddToggle('StrafeToggle', {
    Text = 'Target Strafe',
    Default = Strafe.Enabled,
    Callback = function(val)
        Strafe.Enabled = val
    end
})

Groupboxes.TargetBox:AddInput('StrafeDistance', {
    Text = 'Strafe Distance',
    Default = tostring(Strafe.Distance),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Strafe.Distance = tonumber(val) or 6
    end
})

Groupboxes.TargetBox:AddInput('StrafeHeight', {
    Text = 'Strafe Height',
    Default = tostring(Strafe.Height),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Strafe.Height = tonumber(val) or 0
    end
})

Groupboxes.TargetBox:AddInput('StrafeSpeed', {
    Text = 'Strafe Speed',
    Default = tostring(Strafe.Speed),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Strafe.Speed = tonumber(val) or 1.25
    end
})

RunService.Heartbeat:Connect(function()
    if Strafe.Enabled and lockedTarget and lockedTarget.Character and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") then
        local root = Plr.Character.HumanoidRootPart
        local targetRoot = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local t = tick() * Strafe.Speed
            local angle = t % (2 * math.pi)
            local offset = CFrame.new(math.cos(angle) * Strafe.Distance, Strafe.Height, math.sin(angle) * Strafe.Distance)
            local strafePos = targetRoot.Position + offset.Position
            root.CFrame = CFrame.new(strafePos, targetRoot.Position)
        end
    end
end)

local walkspeedToggled = false
local speedLoopConnection
local characterConnection

local function applyWalkspeed(enable)
    local char = Plr.Character or workspace:FindFirstChild(Plr.Name)
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return end

    if enable then
        if Walkspeed.Bypass then
            if speedLoopConnection then speedLoopConnection:Disconnect() end
            speedLoopConnection = RunService.Heartbeat:Connect(function()
                local dir = hum.MoveDirection
                root.Velocity = Vector3.new(dir.X * Walkspeed.Amount, root.Velocity.Y, dir.Z * Walkspeed.Amount)
            end)
        else
            hum.WalkSpeed = Walkspeed.Amount
            if speedLoopConnection then speedLoopConnection:Disconnect() end
            speedLoopConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                hum.WalkSpeed = Walkspeed.Amount
            end)
        end

        if characterConnection then characterConnection:Disconnect() end
        characterConnection = Plr.CharacterAdded:Connect(function(newChar)
            wait(1)
            Walkspeed.Enabled = false
            applyWalkspeed(false)
        end)
    else
        if hum then hum.WalkSpeed = 16 end
        if speedLoopConnection then speedLoopConnection:Disconnect() end
        if characterConnection then characterConnection:Disconnect() end
    end
end

UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Walkspeed.Key and Walkspeed.Enabled then
        walkspeedToggled = not walkspeedToggled
        applyWalkspeed(walkspeedToggled)
    end
end)

Groupboxes.WalkBox:AddToggle('WalkspeedToggle', {
    Text = 'Walkspeed Enabled',
    Default = Walkspeed.Enabled,
    Callback = function(val)
        Walkspeed.Enabled = val
        if not val then
            walkspeedToggled = false
            applyWalkspeed(false)
        end
    end
})

Groupboxes.WalkBox:AddToggle('WalkspeedBypass', {
    Text = 'Bypass Mode',
    Default = Walkspeed.Bypass,
    Callback = function(val)
        Walkspeed.Bypass = val
    end
})

Groupboxes.WalkBox:AddInput('WalkspeedAmount', {
    Text = 'Speed Amount',
    Default = tostring(Walkspeed.Amount),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        Walkspeed.Amount = tonumber(val) or 324
    end
})

Groupboxes.WalkBox:AddButton('Create Walkspeed Button', createWalkspeedButton)

local function createWalkspeedButton()
    if playerGui:FindFirstChild("WalkspeedGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WalkspeedGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local outerFrame = Instance.new("Frame")
    outerFrame.Size = UDim2.new(0, 240, 0, 48)
    outerFrame.Position = UDim2.new(0, 10, 0, 70)
    outerFrame.BackgroundColor3 = Color3.fromRGB(53, 50, 53)
    outerFrame.Parent = screenGui

    Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0, 5)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 20, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 68, 71)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Code
    button.TextSize = 18
    button.Text = "Walkspeed Off"
    button.Parent = outerFrame

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)

    local function toggleWalkspeedButton()
        walkspeedToggled = not walkspeedToggled
        applyWalkspeed(walkspeedToggled)
        button.Text = walkspeedToggled and "Walkspeed On" or "Walkspeed Off"
    end

    button.MouseButton1Click:Connect(toggleWalkspeedButton)

    -- Draggable Logic
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    outerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = outerFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            TweenService:Create(outerFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = newPos
            }):Play()
        end
    end)
end

--// DO NOT REMOVE THIS IT'S FOR THE PC KEYBIND TO LOCK ON AND LOCK OFF --//

UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Keybind.Camlock then
        Camlock.Enabled = not Camlock.Enabled
        lockedTarget = Camlock.Enabled and getClosestPlayer() or nil
    elseif input.KeyCode == Keybind.TargetAim then
        TargetAim.Enabled = not TargetAim.Enabled
    end
end)

local jumpToggled = false
local jumpConnection

local function applyJumpPower(enable)
    local char = Plr.Character or workspace:FindFirstChild(Plr.Name)
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")

    if not hum then return end

    if enable then
        hum.JumpPower = JumpPower.Amount
        jumpConnection = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
            hum.JumpPower = JumpPower.Amount
        end)
        characterConnection = Plr.CharacterAdded:Connect(function()
            wait(1)
            JumpPower.Enabled = false
            applyJumpPower(false)
        end)
    else
        hum.JumpPower = 50
        if jumpConnection then jumpConnection:Disconnect() end
        if characterConnection then characterConnection:Disconnect() end
    end
end

Groupboxes.JumpBox:AddToggle('JumpPowerToggle', {
    Text = 'Jump Power Enabled',
    Default = JumpPower.Enabled,
    Callback = function(val)
        JumpPower.Enabled = val
        if not val then
            jumpToggled = false
            applyJumpPower(false)
        end
    end
})

Groupboxes.JumpBox:AddInput('JumpPowerAmount', {
    Text = 'Jump Power',
    Default = tostring(JumpPower.Amount),
    Numeric = true,
    Finished = true,
    Callback = function(val)
        JumpPower.Amount = tonumber(val) or 100
    end
})

Groupboxes.JumpBox:AddButton('Create JumpPower Button', function()
    if playerGui:FindFirstChild("JumpPowerGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JumpPowerGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local outerFrame = Instance.new("Frame")
    outerFrame.Size = UDim2.new(0, 240, 0, 48)
    outerFrame.Position = UDim2.new(0, 10, 0, 130)
    outerFrame.BackgroundColor3 = Color3.fromRGB(53, 50, 53)
    outerFrame.Parent = screenGui

    Instance.new("UICorner", outerFrame).CornerRadius = UDim.new(0, 5)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = UDim2.new(0, 20, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 68, 71)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Code
    button.TextSize = 18
    button.Text = "Jump Power Off"
    button.Parent = outerFrame

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)

    local function toggleJumpPower()
        jumpToggled = not jumpToggled
        applyJumpPower(jumpToggled)
        button.Text = jumpToggled and "Jump Power On" or "Jump Power Off"
    end

    button.MouseButton1Click:Connect(toggleJumpPower)

    -- Draggable Logic
    local dragging = false
    local dragStart = Vector2.new()
    local startPos = UDim2.new()

    outerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = outerFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInput.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            TweenService:Create(outerFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = newPos
            }):Play()
        end
    end)
end)

-- local HitChams = Groupboxes.HitBox:AddToggle('HitChamsToggle', {
--     Text = 'Hit Chams',
--     Default = VisualToggles.HitChams,
--     Callback = function(val)
--         VisualToggles.HitChams = val
--     end
-- })

local HitSkeleton = Groupboxes.HitBox:AddToggle('HitSkeletonToggle', {
    Text = 'Hit Skeleton',
    Default = VisualToggles.HitSkeleton,
    Callback = function(val)
        VisualToggles.HitSkeleton = val
    end
})

-- HitChams:AddColorPicker('HitChamsColorPicker', {
--     Default = VisualColors.HitChams,
--     Text = 'Hit Chams Color',
--     Transparency = 0,
--     Callback = function(color)
--         VisualColors.HitChams = color
--     end
-- })

HitSkeleton:AddColorPicker('HitSkeletonColorPicker', {
    Default = VisualColors.HitSkeleton,
    Text = 'Hit Skeleton Color',
    Transparency = 0,
    Callback = function(color)
        VisualColors.HitSkeleton = color
    end
})


Groupboxes.atBox:AddToggle('LookAtToggle', {
    Text = 'Enable LookAt',
    Default = lookat.Enabled,
    Callback = function(val)
        lookat.Enabled = val
        if val and not lockedTarget then
            lockedTarget = getClosestPlayer()
        end
    end
})

function lUpdate()
    if not lookat.Enabled or not Players.LocalPlayer.Character then return end

    local root = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetPos = lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart").Position
    if not targetPos then return end

    local localPos = root.Position
    local direction = (targetPos - localPos).Unit
    direction = Vector3.new(direction.X, 0, direction.Z).Unit -- Flat Y axis

    root.CFrame = CFrame.new(localPos, localPos + direction)
end

RunService.RenderStepped:Connect(function()
    if lookat.Enabled then
        lUpdate()
    end

    if Camlock.Enabled and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild(Camlock.AimPart) then
        local hum = lockedTarget.Character:FindFirstChild("Humanoid")
        if Camlock.UnlockOnDeath and hum and hum.Health <= 0 then
            Camlock.Enabled = false
            lockedTarget = nil
            return
        end

        local aimPart = lockedTarget.Character[Camlock.AimPart]
        local hrp = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
        local velocity = hrp and hrp.Velocity or Vector3.zero

        local predicted = aimPart.Position + Vector3.new(
            velocity.X * Camlock.HorPrediction,
            velocity.Y * Camlock.VertPrediction,
            velocity.Z * Camlock.HorPrediction
        )

        local smooth = math.clamp(Camlock.Smoothness, 0, 1)
        if smooth <= 0 then return end

        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), smooth)
    end
end)

crd:AddLabel('+ soulzz: Head Manager')

chng:AddLabel('+ image button')

chng:AddLabel('+ Added EnemyStats')

chng:AddLabel('+ Added Antigroundshots')

chng:AddLabel('i hate typin')

library:Notify("Join Diddy club Rn!!!", 4)


savemanager:SetLibrary(library)
thememanager:SetLibrary(library)
thememanager:SetFolder('zn7')
savemanager:SetFolder('soulzz')
thememanager:ApplyToTab(tabs.config)
savemanager:BuildConfigSection(tabs.config)

library:Notify("Pbass loaded successfully", 5)

game.StarterGui:SetCore("SendNotification", {
    Title = "troll.cc",
    Text = "script successfully loaded",
    Duration = 3
})
