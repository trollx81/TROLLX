
if game.PlaceId == 9825515356 then

local a = game:GetService("ReplicatedStorage"):WaitForChild("MainEvent")
local b = {"IS_MOBILE"}
local c
if a and a:IsA("RemoteEvent") then
    c = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" and self == a and table.find(b, args[1]) then
            return
        end
        return c(self, ...)
    end)
end
end

for Key, Object in pairs(getgc(true)) do
            if type(Object) == "table" then
                setreadonly(Object, false)
                local indexInstance = rawget(Object, "indexInstance")
                if type(indexInstance) == "table" and indexInstance[1] == "kick" then
                    setreadonly(indexInstance, false)
                    rawset(Object, "Table", {"kick", function() coroutine.yield() end})
                break
           end
      end
end

local bullet_trailin = false;

local Players           = game:GetService("Players");
local RunService        = game:GetService("RunService");
local UserInputService  = game:GetService("UserInputService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Workspace         = game:GetService("Workspace");
local TweenService      = game:GetService("TweenService");
local Configurations    = getgenv().Configurations -- you can just do Configurations but i defined it since i dont want that yellow indicator on my roblox lsp
local Debris            = game:GetService('Debris');
local Lighting       = game:GetService("Lighting");
local utility = {};

local LocalPlayer       = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local crosshair_position = "Middle";
local clone_chams_tick = tick();
local connections = {}
if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_JIT_ULTRA = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(f) return function(...) return f(...) end end
    LPH_ENCSTR = function(...) return ... end
    LPH_STRENC = function(...) return ... end
    LPH_HOOK_FIX = function(...) return ... end
    LPH_CRASH = function() return print(debug.traceback()) end
end

local wrap = LPH_NO_VIRTUALIZE(function(f)
    coroutine.resume(coroutine.create(f))
end)

local function GetBullet()
    if workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Siren") and workspace.Ignored.Siren:FindFirstChild("Radius") then
        return {
            BulletPath = workspace.Ignored.Siren.Radius,
            BulletName = "BULLET_RAYS",
            BulletBeamName = "GunBeam"
        }
    elseif workspace:FindFirstChild("Ignored") then
        return {
            BulletPath = workspace.Ignored,
            BulletName = "BULLET_RAYS",
            BulletBeamName = "GunBeam"
        }
    elseif workspace then
        return {
            BulletPath = workspace,
            BulletName = "Part",
            BulletBeamName = "gb"
        }
    end
    return nil
end

local support = GetBullet()
local bullet_beam_name = support.BulletBeamName
local bullet_name = support.BulletName
local bullet_path = support.BulletPath

local Library = loadstring(game:HttpGet("https://gist.githubusercontent.com/public-account-7/4098a248a7fcd0ad67e45c75671b409e/raw/50e0d671122a0541276a92f4bf31221dff2f11f9/gistfile1.txt",true))()

local MainColor = Library.Accent

Configurations = {
    Visuals = {
        Bullet_Trails = {
            Enabled = false,
            Width = 1.7,
            Duration = 5,
            Fade = false,
            FadeDuration = 5,
            Color = MainColor,
            Texture = "Normal" -- 12781803086
        }
    }
}


local utility = {}; do
    utility.world_to_screen = LPH_NO_VIRTUALIZE(function(position)
        local screen_position, on_screen = Camera:WorldToViewportPoint(position)
        return {position = Vector2.new(screen_position.X, screen_position.Y), on_screen = on_screen}
    end)
utility.instance_new = function(type, properties)
        local instance = Instance.new(type);

        for property, value in properties do
            instance[property] = value;
        end;

        return instance;
    end;

    utility.has_character = LPH_NO_VIRTUALIZE(function(player)
        return (player and player.Character and player.Character:FindFirstChild("Humanoid")) and true or false
    end)

    utility.new_connection = function(type, callback) --// by all means do NOT virtualize this
        local connection = type:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    utility.create_beam = LPH_NO_VIRTUALIZE(function(from, to, color_1, color_2, duration, fade_enabled, fade_duration)
        local tween
        local total_time = 0

        local main_part = utility.instance_new("Part", {
            Parent = workspace,
            Size = Vector3.new(0, 0, 0),
            Massless = true,
            Transparency = 1,
            CanCollide = false,
            Position = from,
            Anchored = true
        })

        local part0 = utility.instance_new("Part", {
            Parent = main_part,
            Size = Vector3.new(0, 0, 0),
            Massless = true,
            Transparency = 1,
            CanCollide = false,
            Position = from,
            Anchored = true
        })

        local part1 = utility.instance_new("Part", {
            Parent = main_part,
            Size = Vector3.new(0, 0, 0),
            Massless = true,
            Transparency = 1,
            CanCollide = false,
            Position = to,
            Anchored = true
        })

        local attachment0 = utility.instance_new("Attachment", {Parent = part0})
        local attachment1 = utility.instance_new("Attachment", {Parent = part1})

        local beam = utility.instance_new("Beam", {
            Texture = "rbxassetid://446111271",
            TextureMode = Enum.TextureMode.Wrap,
            TextureLength = 10,
            LightEmission = 1,
            LightInfluence = 1,
            FaceCamera = true,
            ZOffset = -1,
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            }),
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color_1),
                ColorSequenceKeypoint.new(1, color_2),
            }),
            Attachment0 = attachment0,
            Attachment1 = attachment1,
            Enabled = true,
            Parent = main_part
        })

        if fade_enabled then
            tween = utility.new_connection(RunService.Heartbeat, function(delta_time) --// credits to Xander
                total_time += delta_time
                beam.Transparency = NumberSequence.new(
                    TweenService:GetValue((total_time / fade_duration), Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                )
            end)
        end

        task.delay(duration, function()
            main_part:Destroy()
            if tween then
                tween:Disconnect()
            end
        end)
    end)
end

local Notifications = {}
local Utility = {}
local Desync = {}

local function SirenAdded(Obj)
        local Character = LocalPlayer.Character
        local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")

        local function VerifyBullet(obj)
            return (obj.Name == bullet_name or obj:FindFirstChild("Attachment") or obj:FindFirstChild(bullet_beam_name)) and obj
        end

        local PlayerChecks = {PlayerGun = false}
        local BulletRay = VerifyBullet(Obj)
    
        if BulletRay and RootPart then
            local Mag = (RootPart.Position - BulletRay.Position).Magnitude
            if Mag <= 13 then PlayerChecks.PlayerGun = true end

            if PlayerChecks.PlayerGun then
                local GunBeam = BulletRay:WaitForChild(bullet_beam_name)
                
                local Attachment0 = GunBeam.Attachment0 -- closest to player
                local Attachment1 = GunBeam.Attachment1 -- mouse position


            if Configurations.Visuals.Bullet_Trails.Enabled then
                GunBeam:Destroy()
                utility.create_beam(
                    BulletRay.Position,
                    Attachment1.WorldCFrame.Position,
                    Configurations.Visuals.Bullet_Trails.Color,
                    Configurations.Visuals.Bullet_Trails.Color,
                    Configurations.Visuals.Bullet_Trails.Duration,
                    Configurations.Visuals.Bullet_Trails.Fade,
                    Configurations.Visuals.Bullet_Trails.FadeDuration
                )
            end
        end
    end
end

if bullet_path then
    bullet_path.ChildAdded:Connect(SirenAdded)
end



if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_JIT_ULTRA = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(f) return function(...) return f(...) end end
    LPH_ENCSTR = function(...) return ... end
    LPH_STRENC = function(...) return ... end
    LPH_HOOK_FIX = function(...) return ... end
    LPH_CRASH = function() return print(debug.traceback()) end
end

local Script = {
        Functions = {},
        Folders = {},
        Parts = {},
        Locals = {
            Target = nil,
            Targeting = false,
            Resolver = {
                OldTick = tick(),
                OldPos = Vector3.new(0, 0, 0),
                ResolvedVelocity = Vector3.new(0, 0, 0)
            },
            AutoSelectTick = tick(),
            AntiAimViewer = {
                MouseRemoteFound = false,
                MouseRemote = nil,
                MouseRemoteArgs = nil,
                MouseRemotePositionIndex = nil
            },
           GunTP = { 
                Enabled = false,
                Anchor = false,
                Offset = {0,-1,0},
           },
           Aura = { 
                Enabled = true,
                Color = Color3.fromRGB(0,0,67),
           },
           RocketTP = {
                Enabled = false,
           },
           GrenadeTP = {
                Enabled = false,
           },
           KnifeAbilityTest = {
               TargetPart = "HumanoidRootPart",
               Radius = 90,
               Visible = false
            },
            HitEffect = {
                ["Nova Impact"] = nil,
                ["Crescent Slash"] = nil,
                ["Crescent Slash"] = nil,
                ["Coom"] = nil,
                ["Cosmic Explosion"] = nil,
                ["Slash"] = nil,
                ["Atomic Slash"] = nil,
            },
            Gun = {
                PreviousGun = nil,
                PreviousAmmo = 999,
                Shotguns = {"[Double-Barrel SG]", "[TacticalShotgun]", "[Shotgun]"}
            },
            PlayerHealth = {},
            JumpOffset = 0,
            BulletPath = {
                [4312377180] = Workspace:FindFirstChild("MAP") and Workspace.MAP:FindFirstChild("Ignored") or nil,
                [1008451066] = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Siren") and Workspace.Ignored.Siren:FindFirstChild("Radius") or nil,
                [3985694250] = Workspace and Workspace:FindFirstChild("Ignored") or nil,
                [5106782457] = Workspace and Workspace:FindFirstChild("Ignored") or nil,
                [4937639028] = Workspace and Workspace:FindFirstChild("Ignored") or nil,
                [1958807588] = Workspace and Workspace:FindFirstChild("Ignored") or nil
            },
            SavedCFrame = nil,
            NetworkPreviousTick = tick(),
            NetworkShouldSleep = false,
            FFlags = {
      }
            ,OriginalVelocity = {},
            RotationAngle = 0
        },
        Utility = {
            Drawings = {},
            EspCache = {}
        },
        Connections = {
            GunConnections = {}
        },
        AuraIgnoreFolder = Instance.new("Folder", game:GetService("Workspace"))
    }

    local Settings = {
        Combat = {
            Enabled = false,
            Skibidi = true,
            Spectate = true,
            AimPart = "HumanoidRootPart",
            ESP = true,
            Silent = false,
            BetaAirshot = false,
            TriggerBot = {
                Enabled = false,
                Delay = 0,
                TargeyOnly = false,
                FOV = {
                    Show = true,
                    Size = 80
                }
            },
            TargetInfo = false,
            Camera = false,
            EasingStyle = "Sine",
            EasingDirection = "Out",
            Alerts = true,
            LookAt = false,
            Spectate = false,
            PingBased = false,
            UseIndex = false,
            AntiAimViewer = false,
            AutoSelect = {
                Enabled = false,
                Cooldown = {
                    Enabled = false,
                    Amount = 0.5
                }
            },
            Checks = {
                Enabled = false,
                Knocked = false,
                Crew = false,
                Wall = false,
                Grabbed = false,
                Vehicle = false
            },
            Smoothing = {
                Horizontal = 1,
                Vertical = 1
            },
            Prediction = {
                Horizontal = 0.134,
                Vertical = 0.134
            },
            Resolver = {
                Enabled = false,
                RefreshRate = 190
            },
            Fov = {
                Visualize = {
                    Enabled = false,
                    Color = Color3.new(1, 1, 1)
                },
                Radius = 80
            },
            Visuals = {
                Enabled = true,
                Tracer = {
                    Enabled = false,
                    Color = Color3.new(1, 1, 1),
                    Thickness = 2
                },
                Dot = {
                    Enabled = false,
                    Color = Color3.new(1, 1, 1),
                    Filled = true,
                    Size = 6
                },
                Chams = {
                    Enabled = false,
                    Fill = {
                        Color = Color3.fromRGB(255,209,220),
                        Transparency = 0.5
                    },
                    Outline = {
                        Color = Color3.new(255,255,255),
                        Transparency = 0
                    }
                }
            },
            Air = {
                Enabled = true,
                AirAimPart = {
                    Enabled = false,
                    HitPart = "LowerTorso"
                },
                JumpOffset = {
                    Enabled = false,
                    Offset = 0
                }
            }
        },
        Visuals = {
            Backtrack = {
                Enabled = true,
                Color = Color3.fromRGB(255,255,255),
                Method = "Folllow",
                Transparency = 0.5,
                Material = "Plastic",
            },
            BulletTracers = {
                Enabled = false,
                Color = {
                    Gradient1 = Color3.new(1, 1, 1),
                    Gradient2 = Color3.new(0, 0, 0)
                },
                Duration = 1,
                Fade = {
                    Enabled = false,
                    Duration = 0.5
                }
            },
            BulletImpacts = {
                Enabled = false,
                Color = Color3.new(1, 1, 1),
                Duration = 1,
                Size = 1,
                Material = "SmoothPlastic",
                Fade = {
                    Enabled = false,
                    Duration = 0.5
                }
            },
            OnHit = {
                Enabled = false,
                Effect = {
                    Enabled = false,
                    Color = Color3.new(1, 1, 1)
                },
                Sound = {
                    Enabled = false,
                    Volume = 5,
                    Value = "hentai4.wav"
                },
                Chams = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,209,220),
                    Material = "ForceField",
                    Duration = 1
                }
            },
            World = {
                Enabled = false,
                Fog = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,209,220),
                    End = 1000,
                    Start = 10000
                },
                Ambient = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,209,220)
                },
                Brightness = {
                    Enabled = false,
                    Value = 0
                },
                ClockTime = {
                    Enabled = false,
                    Value = 24
                },
                WorldExposure = {
                    Enabled = false,
                    Value = -0.1
                }
            },
            Crosshair = {
                Enabled = false,
                StickToTarget = false,
                Color = Color3.new(1, 1, 1),
                Size = 10,
                Gap = 2,
                Rotation = {
                    Enabled = false,
                    Speed = 1
                }
            }
        },
        AntiAim = {
            DaCoolBoyDesync = false,
            DaCoolBoyDesync2 = false,
            DaCoolBoyDesync3 = false,
            VelocitySpoofer = {
                Enabled = false,
                Visualize = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,209,220),
                    Prediction = 0.134
                },
                Type = "Underground",
                Roll = 0,
                Pitch = 0,
                Yaw = 0
            },
            CSync = {
                Enabled = false,
                Spoof = false,
                Type = "Target Strafe",
                Visualize = {
                    Enabled = false,
                    Color = Color3.fromRGB(255,209,220)
                },
                RandomDistance = 10,
                Custom = {
                    X = 0,
                    Y = 0,
                    Z = 0
                },
                TargetStrafe = {
                    Speed = 1,
                    Distance = 1,
                    Height = 1
                }
            },
            Network = {
                Enabled = false,
                WalkingCheck = false,
                Amount = 0.05
            },
            VelocityDesync = {
                Enabled = false,
                Range = 1
            },
            FFlagDesync = {
                Enabled = false,
                SetNew = false,
                FFlags = {"S2PhysicsSenderRate"}, 
                SetNewAmount = 1,
                Amount = 1
            },
        },
        Misc = {
            Movement = {
                Macro = {
                    Enabled = false,
                    Speed = 0.1,
                },
                Speed = {
                    Enabled = false,
                    Amount = 1
                },
            },
            Exploits = {
                Enabled = false,
                NoRecoil = false,
                NoJumpCooldown = false,
                NoSlowDown = false
            }
        }
    }



getgenv().Sentinel = {
    Enabled = true,
    HorizontalPrediction = 0.1,
    VerticalPrediction = 0.1,
    jumpoffset2 = -1,
    jumpoffset = 0,
    ResolverEnabled = false,
    SelectedPart = "HumanoidRootPart",
    CamPredHori = 0.1,
    CamPredVert = 0.4,
    AutoPrediction = true,
    Sway = false,
    AutoPredMode = "PingBased", 
    ShootDelay = 0.22,
    NoGroundShot = true,
    AutoAir = true,
    ForceFieldCheck = true,
    LookAt = true,
    smoothness = 0.3,
    TracerEnabled = true,
    NearestPart = false,
    speedvalue = 1,
    MacroSpeed = 0.1,
    Camera = false,
    easingStyle = "Sine",
    easingDirection = "Out",
    JumpBreak = false,
    network = false
}




local GrenadeTP = false
local RocketTP = false
getgenv().Desync = false
getgenv().AntiLockType = "Behind"
getgenv().Direction = Vector3.new(0, 0, -1)

    local Debris = game:GetService('Debris')
    local EtherealParts = Instance.new('Folder', workspace)
    EtherealParts.Name  = 'EtherealParts'
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")


Script.Functions.VisualizeMovement = function()
                if Settings.Combat.Skibidi then
                  local Character = game.Players.LocalPlayer and (game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait())
                  local RootPart = Character and Character.HumanoidRootPart
                  local Ball = Instance.new('Part') do
                      Ball.Anchored = true
                      Ball.Size = Vector3.new(0.5, 0.5, 0.5)
                      Ball.Transparency = -0.5
                      Ball.Shape = Enum.PartType.Ball
                      Ball.Color = Color3.fromRGB(255,209,220)
                      Ball.Material = Enum.Material.ForceField
                      Ball.Parent = Workspace
                      Ball.CFrame = RootPart.CFrame
                      Ball.CanCollide = false
                      local highlight = Instance.new("Highlight")
                      highlight.Adornee = Ball
                      highlight.FillColor = Color3.fromRGB(255,209,220)
                      highlight.OutlineColor = Color3.fromRGB(255,255,255)
                      highlight.Parent = Ball
                  end;
                  Debris:AddItem(Ball, 2)
                end
            end

Script.Functions.VisualizeMovement()






    print("OpenAc Flagged & Bypassed!, Loading Script!")
       


local Psalms = {
    Tech = {
        speedvalue = 1
    }
}







 


        
    



--[[ http://www.roblox.com/asset/?id=17677463033
Ak47 : rbxassetid://88836741434398

REV : rbxassetid://106397886212631

SG : 118698023926650

Snipah : 104037274406938

138737595020251

113531571097970

]]


local hitsounds = {
    ["RIFK7"] = "rbxassetid://9102080552",
    ["Bubble"] = "rbxassetid://9102092728",
    ["Minecraft"] = "rbxassetid://5869422451",
    ["Cod"] = "rbxassetid://160432334",
    ["Bameware"] = "rbxassetid://6565367558",
    ["Neverlose"] = "rbxassetid://6565370984",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Rust"] = "rbxassetid://6565371338",
    ["BlackPencil"] = "https://github.com/Shatapmatehabibi/Hitsounds/raw/main/bananapencil.mp3.mp3",
    ["Fein"] = "https://github.com/CongoOhioDog/SoundS/blob/main/psalms%20highly%20defined%20fein.mp3?raw=true",
    ["Unicorn"] = "https://github.com/CongoOhioDog/SoundS/blob/main/shiny%20unicorn%20for%20dh%20_%20psalms.mp3?raw=true",
    ["Kitty"] = "https://github.com/CongoOhioDog/SoundS/blob/main/Kitty.mp3?raw=true",
    ["Bird"] = "https://github.com/CongoOhioDog/SoundS/blob/main/bird%20chirping%20for%20DH%20_%20psalms%20audio.mp3?raw=true",
    ["BirthdayCake"] = "https://github.com/CongoOhioDog/SoundS/blob/main/Birthday%20cake%20for%20dh%20_%20psalms.mp3?raw=true", 
    ["KenCarson"] =  "https://github.com/CongoOhioDog/SoundS/blob/main/ken_carson_-_jennifer_s_body_offici(2).mp3?raw=true"
}



local TargetAimbot = {
    Enabled = true, 
    Keybind = Enum.KeyCode.Q,
    Autoselect = false,
    Prediction = 0.145, 
    RealPrediction = 0.145, 
    Resolver = false, 
    ResolverType = "Recalculate", 
    JumpOffset = 0.06, 
    RealJumpOffset = 0.09, 
    HitParts = {"HumanoidRootPart"}, 
    RealHitPart = "HumanoidRootPart", 
    KoCheck = false, 
    LookAt = false, --
    CSync = {
        Enabled = false,
        Type = "Orbit",
        Distance = 10,
        Height = 2,
        Speed = 10,
        Circle = true,
        VisualizeMovement = false,
        RandomAmount = 10,
        Color = Color3.fromRGB(255, 255, 255),
        Spectate = false,
    },
    ViewAt = false,
    Tracer = true,
    Highlight = true,
    HighlightColor1 =Color3.fromRGB(255, 255, 255),
    HighlightColor2 =Color3.fromRGB(255, 255, 255),
    Stats = false, 
    UseFov = false,
    HitEffect = true,
    HitEffectType = "Coom", -- Nova, Crescent Slash, Coom, Cosmic Explosion, Slash, Atomic Slash
    HitEffectColor = Color3.fromRGB(255, 255, 255),
    HitSounds = true,
    HitSound = "Bameware",
    HitChams = true,
    HitSkele = true,
    SkeleColor = Library.Accent,
    HitChamsMaterial = Enum.Material.Neon,
    HitChamsDuration = 1,
    HitChamsColor = Color3.fromRGB(173, 216, 230)
}

local  Highlight = false

local ESP = {
    Enabled = false,
    TeamCheck = true,
    MaxDistance = 200,
    FontSize = 11,
    TargetOnly = false,
    FadeOut = {
        OnDistance = true,
        OnDeath = false,
        OnLeave = false,
    },
    Options = { 
        Teamcheck = false, TeamcheckRGB = Color3.fromRGB(0, 255, 0),
        Friendcheck = true, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
        Highlight = false, HighlightRGB = Color3.fromRGB(255, 0, 0),
    },
    Drawing = {
        Chams = {
            Enabled  = true,
            Thermal = true,
            FillRGB = Color3.fromRGB(173, 216, 230),
            Fill_Transparency = 100,
            OutlineRGB = Color3.fromRGB(173, 216, 230),
            Outline_Transparency = 100,
            VisibleCheck = true,
        },
        Names = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Flags = {
            Enabled = true,
        },
        Distances = {
            Enabled = true, 
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Weapons = {
            Enabled = true, WeaponTextRGB = Color3.fromRGB(119, 120, 255),
            Outlined = false,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(255, 255, 255), GradientRGB2 = Color3.fromRGB(119, 120, 255),
        },
        Healthbar = {
            Enabled = true,  
            HealthText = true, Lerp = false, HealthTextRGB = Color3.fromRGB(119, 120, 255),
            Width = 2.5,
            Gradient = true, GradientRGB1 = Color3.fromRGB(p, 0, 0), GradientRGB2 = Color3.fromRGB(60, 60, 125), GradientRGB3 = Color3.fromRGB(173, 216, 230), 
        },
        Boxes = {
            Animate = true,
            RotationSpeed = 300,
            Gradient = false, GradientRGB1 = Color3.fromRGB(173, 216, 230), GradientRGB2 = Color3.fromRGB(0, 0, 0), 
            GradientFill = true, GradientFillRGB1 = Color3.fromRGB(119, 120, 255), GradientFillRGB2 = Color3.fromRGB(0, 0, 0), 
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        };
    };
    Connections = {
        RunService = RunService;
    };
    Fonts = {};
}




local player = game:GetService("Players").LocalPlayer
local display = player.DisplayName
local Window = Library:Window({Name = "Patz.lol | đŸ„ Da Hood | " .. display})

--
local plyaha = game.Players.LocalPlayer.Name
local dick2 = string.sub(tostring(math.random()), 3, 8) 
local what = {"Santa", "The Grinch", "Ozzy"}
local christmasCharacter = what[math.random(#what)]
--
local Watermark = Library:Watermark({Name = string.format("$$ osamason $$ | %s | %s | %s | Christmas Cheer | Jingle Bells | Snowflakes | Holiday Vibes | gyatt", plyaha, dick2, christmasCharacter)})
--
local Indicator = Library:Indicator({Name = "Target Indicator"})
local TextIndicator = Indicator:NewValue({Name = "Target:", Value = "No Target"})
local BarIndicator = Indicator:NewBar({Name = "Health", Value = 0, Min = 0, Max = 100})
--


local Page = Window:Page({Name = "Main", Weapons = true})
local Visuals = Window:Page({Name = "Visuals", Weapons = true})
local Sat = Window:Page({Name = "Rage", Weapons = true})
local playahlis = Window:Page({Name = "Playerlist", Weapons = true})
local Settings = Window:Page({Name = "Settings"})
--
local SubPage1 = Page:Weapon({Icon = "rbxassetid://78117064682304"})
local SubPage2 = Page:Weapon({Icon = "rbxassetid://120304994615919"})

local SubPage3 = Page:Weapon({Icon = "rbxassetid://77469221937135"})
local SubPage4 = Page:Weapon({Icon = "rbxassetid://128385756502234"})

local SubPage5 = playahlis:Weapon({Icon = "rbxassetid://114736089502081"})

local SubPage6 = Sat:Weapon({Icon = "rbxassetid://8547258459"})

local SubPage7 = Visuals:Weapon({})
local SubPage8 = Visuals:Weapon({Icon = "rbxassetid://16997762295"})

-- // TargetPlayers:PlayerList({})

SubPage5:PlayerList({Flag = "CurrentPlayer"})
local PlayerlistONE = SubPage5:Section({Name = ">_<", Zindex = 2, Side = "Right"})
PlayerlistONE:Button({Name = "Goto", Callback = function()
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Library.Flags.CurrentPlayer.Character.HumanoidRootPart.CFrame 
end})

local VisSectiom = 
SubPage8:Section({Name = "Hit Detection"})

local Others = SubPage8:Section({Name = "Others"})

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local gradient = Instance.new("UIGradient")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local sama_sama_sama = true
local whattheskibidi = 0.6
local mode = "Center"
local coluhhh = Color3.fromRGB(255, 255, 255)
local coluhhh2 = Color3.fromRGB(0,54,0)
local HuhDrawing = 200

Frame.Parent = ScreenGui
Frame.Visible = sama_sama_sama
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BackgroundTransparency = whattheskibidi
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Frame

UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Parent = Frame

gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, coluhhh),
    ColorSequenceKeypoint.new(1, coluhhh2)
}
gradient.Parent = Frame

local function ChangeFOVFrickinSizees(HuhDrawing)
    Frame.Size = UDim2.new(0, HuhDrawing, 0, HuhDrawing)
    Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset / 2, 0.5, -Frame.Size.Y.Offset / 2)
end

ChangeFOVFrickinSizees(200)

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

local stick_to_target = false


mouse.Move:Connect(function()
    if mouse and mode == "Mouse" then
        Frame.Position = UDim2.new(0, mouse.X - Frame.Size.X.Offset / 2, 0, mouse.Y - Frame.Size.Y.Offset / 2)
    elseif stick_to_target == false then
            Frame.Position = UDim2.new(0.5, -Frame.Size.X.Offset / 2, 0.5, -Frame.Size.Y.Offset / 2)
        end
end)

local RotateThisDick = 3

spawn(function()
    while true do
        gradient.Rotation = gradient.Rotation + RotateThisDick
        wait(0.01)
    end
end)

Others:Toggle({Name = "Gradient FOV", Default = sama_sama_sama, Callback = function(a) Frame.Visible = a end})

local bullet_tracers = SubPage8:Section({Name = "Bullet Tracers", Side = "Right"}) do 
    bullet_tracers:Toggle({Name = "Enabled", Flag = "Bullet Tracers", Callback = function(a) Configurations.Visuals.Bullet_Trails.Enabled = a end}):Colorpicker({Default = Library.Accent, Flag = "Bullet Tracers Color", Callback = function(a) Configurations.Visuals.Bullet_Trails.Color = a end})
    bullet_tracers:List({Name = "Type", Flag = "Bullet Tracers Type", Options = {"Drawing", "Beam"}, Default = "Beam"})
    bullet_tracers:Slider({Name = "Thickness", Flag = 'Bullet Tracers Thickness', Min = 0, Max = 5, Default = 2, Decimals = 0.1, Callback = function(a) Configurations.Visuals.Bullet_Trails.Width = a end})
    bullet_tracers:Slider({Name = "Duration", Flag = 'Tracers Life Time', Min = 0, Max = 10, Default = 2, Decimals = 0.1, Callback = function(a) Configurations.Visuals.Bullet_Trails.Duration = a end})
    bullet_tracers:Toggle({Name = "Fade", Flag = "Bullet Fade", Callback = function(a) Configurations.Visuals.Bullet_Trails.Fade = a end})
    bullet_tracers:Slider({Name = "Fade Duration", Flag = 'Tracers Fade Life Time', Min = 0, Max = 10, Default = 2, Decimals = 0.1, Callback = function(a) Configurations.Visuals.Bullet_Trails.FadeDuration = a end})
end

local world_visuals = Visuals:Section({Name = "World", Side = "Right"}) do
        world_visuals:Toggle({Name = "Fog", Flag = "visuals_world_fog"}):Colorpicker({Name = "Color", Flag = "visuals_world_fog_color", Default = Library.Accent})
        world_visuals:Slider({Name = "Start", Flag = "visuals_world_fog_start", Default = 50, Minimum = 1, Maximum = 1000, Decimals = 1, Ending = "%"})
        world_visuals:Slider({Name = "End", Flag = "visuals_world_fog_end", Default = 50, Minimum = 1, Maximum = 1000, Decimals = 1, Ending = "%"})
        
        world_visuals:Toggle({Name = "Ambient", Flag = "visuals_world_ambient"}):Colorpicker({Name = "Color", Flag = "visuals_world_ambient_color", Default = Library.Accent})
        
        world_visuals:Toggle({Name = "Clock Time", Flag = "visuals_world_clock_time"})
        world_visuals:Slider({Name = "Time", Flag = "visuals_world_clock_time_time", Default = 14, Minimum = 0, Maximum = 24, Decimals = 1})
        
        
        world_visuals:Toggle({Name = "Color Shift Top", Flag = "visuals_world_color_shift_top"}):Colorpicker({Name = "Color", Flag = "visuals_world_color_shift_top_color", Default = Library.Accent})
        world_visuals:Toggle({Name = "Color Shift Bottom", Flag = "visuals_world_color_shift_bottom"}):Colorpicker({Name = "Color", Flag = "visuals_world_color_shift_bottom_color", Default = Library.Accent})
    end
local HitEffectModule = {
    Locals = {
        Type = {
            ["Nova"] = nil,
            ["Crescent Slash"] = nil,
            ["Coom"] = nil,
            ["Cosmic Explosion"] = nil,
            ["Slash"] = nil,
            ["Atomic Slash"] = nil,
        },
    },
    Functions = {},
    Settings = {HitEffect = {Color = TargetAimbot.HitEffectColor}}
}


VisSectiom:Toggle({
    Name = "Enabled",
    Callback = function(a)
  TargetAimbot.HitEffect = a
    end
})

VisSectiom:Toggle({
    Name = "Hit Skeleton",
    Callback = function(a)
  TargetAimbot.HitSkele = a
    end
})

VisSectiom:Toggle({
    Name = "Hit Chams",
    Callback = function(a)
     TargetAimbot.HitChams = a
    end
})



local HitEffectXD = {"Nova", "Crescent Slash", "Coom", "Cosmic Explosion", "Slash", "Atomic Slash"}

VisSectiom:List({
    Name = "Effect Type",
    Options = HitEffectXD,
    Default = TargetAimbot.HitEffectType,
    Callback = function(a)
        TargetAimbot.HitEffectType = a
    end
})

VisSectiom:Toggle({
    Name = "Hit Sounds",
    Callback = function(a)
   TargetAimbot.HitSounds = a
    end
})


local hitdoundz = {
    "RIFK7",
    "Bubble",
    "Minecraft",
    "Cod",
    "Bameware",
    "Neverlose",
    "Gamesense",
    "Rust",
    "BlackPencil",
    "Fein",
    "Unicorn",
    "Bird",
    "KenCarson"
}

VisSectiom:List({
    Name = "Sound Type",
    Options = hitdoundz,
    Default = TargetAimbot.HitSound,
    Callback = function(a)
        TargetAimbot.HitSound = a
    end
})

local TargetAimSection = SubPage1:Section({Name = "Silent/Target", Side = "Left"})

local CamlockSection = SubPage2:Section({Name = "Aim Assist", Side = "Left"})

local RoboticShit = SubPage2:Section({Name = "Robotic Movement", Side = "Right"})

local CamHitPart = SubPage2:Section({Name = "Hit Part", Side = "Left"})


CamlockSection:Toggle({
    Name = "Enabled",
    Default = getgenv().Sentinel.Camera,
    Callback = function(a)
  getgenv().Sentinel.Camera = a
    end
})
CamlockSection:Toggle({
   Name = "Sway -- Left Or Right",
   Callback = function(a)
     Sentinel.Sway = a
   end
})

CamlockSection:Textbox({
   Name = "Prediction",
   Default = "0.134",
   Callback = function(a)
     Sentinel.CamPredHori = a
   end
})


CamlockSection:Textbox({
   Name = "Vertical Prediction",
   Default = "0.134",
   Callback = function(a)
     Sentinel.CamPredVert = a
   end
})


CamHitPart:List({
   Name = "Part",
   Options = {
        "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", 
        "LeftUpperArm", "LeftLowerArm", "LeftHand", 
        "RightUpperArm", "RightLowerArm", "RightHand", 
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", 
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
   },
   Default = "Head"
})

RoboticShit:Toggle({
    Name = "Enabled",
    Default = getgenv().Sentinel.Camera
})
RoboticShit:Textbox({
    Name = "Amount",
    Default = "1",
    Callback = function(a)
      Sentinel.smoothness = a
   end
})

RoboticShit:List({
   Name = "Easing Style",
   Options = 
   {"Linear",
  "Sine","Cubical"},
   Default = "Linear",
   Callback = function(a)
      easingstyle = a 
   end
})

RoboticShit:List({
   Name = "Easing Direction",
   Options = {"InOut","In","Out"},
   Default = "InOut",
   Callback = function(a)
      easingDirection = a
   end
})


     

TargetAimSection:Toggle({
    Name = "Enabled",
    Callback = function(a)
  getgenv().Sentinel.Enabled = a
    end
})

TargetAimSection:Toggle({
    Name = "Auto Air",
    Callback = function(a)
  getgenv().Sentinel.AutoAir = a
    end
})

TargetAimSection:Toggle({
    Name = "Look At",
    Callback = function(a)
  getgenv().Sentinel.LookAt = a
    end
})



TargetAimSection:Toggle({
    Name = "Spectate",
    Callback = function(a)
  TargetAimbot.CSync.Spectate = a
    end
})

TargetAimSection:Toggle({
    Name = "Highlight",
    Callback = function(a)
  Highlight = a
    end
})

local TapY = SubPage1:Section({Name = "Bullet Tp ", Side = "Left"})
TapY:Toggle({
    Name = "Enable",
    Callback = function(a)
  Script.Locals.GunTP.Enabled = a
    end
})

TapY:Toggle({
    Name = "Anchor",
    Callback = function(a)
  Script.Locals.GunTP.Anchor = a
    end
})

TapY:Toggle({
    Name = "Rocket TP",
    Callback = function(a)
  Script.Locals.RocketTP.Enabled = a
    end
})

TapY:Toggle({
    Name = "Grenade TP",
    Callback = function(a)
  Script.Locals.GrenadeTP.Enabled = a
    end
})

TapY:List({
   Name = "Method",
   Options = {"GP","Shh"},
   Default = "GP",
   Callback = function(a)
 
   end
})

local clucluxclan = SubPage1:Section({Name = "Toggle", Side = "Left"})

clucluxclan:Toggle({
   Name = "Hold Mode -- PC",
   Callback = function()
   end
})

clucluxclan:List({
   Name = "Target Mode",
   Options = {"Button", "Key"}, 
   Default = "Button",
   Callback = function()
   end
})

local nnigga = SubPage1:Section({Name = "HitPart", Side = "Left"})

nnigga:Toggle({
    Name = "Randomized",
    Callback = function(a)
        getgenv().Sentinel.NearestPart = a
    end
})

nnigga:List({
    Name = "BodyPart",
    Options = {
        "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", 
        "LeftUpperArm", "LeftLowerArm", "LeftHand", 
        "RightUpperArm", "RightLowerArm", "RightHand", 
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", 
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
    },
    Default = "HumanoidRootPart",
    Callback = function(a)
        getgenv().Sentinel.SelectedPart = a
    end
})

local idkquit = SubPage1:Section({Name = "Calculation", Side = "Right"})
idkquit:Divider({Name = "Prediction"})
idkquit:Toggle({
    Name = "Auto Prediction",
    Callback = function(a)
  getgenv().Sentinel.AutoPrediction = a
    end
})

idkquit:List({
    Name = "Lock Type",
    Options = {
        "Namecall", "Index"
    },
    Default = "Namecall",
    Callback = function(a)
        getgenv().Sentinel.LockType = a
    end
})

idkquit:Textbox({
    Name = "Horizontal Prediction",
    Default = "0.164",
    Callback = function(a)
        getgenv().Sentinel.HorizontalPrediction = a
    end
})

idkquit:Divider({Name = "Resolver"})

idkquit:Toggle({
    Name = "Enable Resolver",
    Default = getgenv().Sentinel,
    Callback = function(a)
 getgenv().Sentinel.ResolverEnabled = a
    end
})

idkquit:List({
    Name = "Mode",
    Options = {"LookVector", "Diddy", "MoveDirection"},
    Callback = function(a)
    getgenv().Sentinel.RESOLVER = a
    end
})
    

local nomorees = SubPage1:Section({Name = "Checks", Side = "Right"})

nomorees:Toggle({
    Name = "WallCheck",
    Callback = function(a)
  
    end
})

nomorees:Toggle({
    Name = "ForceField Check",
    Callback = function(a)
  Sentinel.ForceFieldCheck = a
    end
})

nomorees:Toggle({
    Name = "Knocked",
    Callback = function(a)
  
    end
})

nomorees:Toggle({
    Name = "Crew Check",
    Callback = function(a)
  
    end
})

nomorees:Toggle({
    Name = "Anti Curve",
    Callback = function(a)
  
    end
})

nomorees:Toggle({
    Name = "Anti Ground Shots",
    Default = Sentinel.NoGroundShots,
    Callback = function(a)
      Sentinel.NoGroundShots = a
    end
})

local buyarmorandfooddelay = 0.5
local foodbuy
local bro
local map = workspace:FindFirstChild("MAP")

if map then
    local shops = map:FindFirstChild("Shops")
    local pads = map:FindFirstChild("Pads")

    if shops and shops:FindFirstChild("[Medium Armor]") then
        bro = shops["[Medium Armor]"]
        foodbuy = shops["[Taco]"]
    elseif pads and pads:FindFirstChild("[Medium Armor]") then
        bro = pads["[Medium Armor]"]
        foodbuy = pads["[Pizza]"]
    else
        bro = nil
        foodbuy = nil
    end
else
    bro = nil
    foodbuy = nil
end

    local VoidFall = SubPage6:Section({Name = "AutoBuy -- Voidfall Games", Side = "Right", Zindex = 2})

    VoidFall:Button({
        Name = "Buy",
        Callback = function()
            if bro:FindFirstChild("ClickDetector") then
                fireclickdetector(bro.ClickDetector)
fireclickdetector(foodbuy.ClickDetector)
            end
        end
    })

    VoidFall:Toggle({
        Name = "AutoBuy",
        Callback = function(a)
   AutoArmor = a
            while AutoArmor do
                if bro:FindFirstChild("ClickDetector") then
                    fireclickdetector(bro.ClickDetector)
fireclickdetector(foodbuy.ClickDetector)
                else
                    break
                end
                wait(buyarmorandfooddelay)
            end
        end
    })

VoidFall:Slider({
    Name = "Delay",
    Min = 0,
    Max = 10,
    Default = buyarmorandfooddelay,
    Suffix = "",
    Decimals = 0.001,
    Callback = function(a)
        buyarmorandfooddelay = a
    end
})

local flySpeed = 50
local flying = false
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local function toggleFlying(character, state)
    flying = state
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if flying and humanoid and humanoidRootPart then
        humanoid.PlatformStand = false
        local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
        local bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
        bodyGyro.P = 9e4
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        local connection
        connection = runService.RenderStepped:Connect(function()
            if flying then
                bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                local moveDirection = workspace.CurrentCamera.CFrame.LookVector
                local verticalVelocity = userInputService:IsKeyDown(Enum.KeyCode.Space) and flySpeed or userInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -flySpeed or 0
                
                bodyVelocity.Velocity = moveDirection * flySpeed + Vector3.new(0, verticalVelocity, 0)
                humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                connection:Disconnect()
            end
        end)
    elseif humanoid and humanoidRootPart then
        for _, v in pairs(humanoidRootPart:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end
    end
end

local function onCharacterAdded(character)
    toggleFlying(character, false)
end

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    onCharacterAdded(character)
end)

local KillBotSection = SubPage6:Section({Name = "KillBot -- Uses Silent/Target", Side = "Right", Zindex = 2})

local CFrameShit = SubPage6:Section({Name = "CFrame Speed", Side = "Left", Zindex = 2})

local VelFly = SubPage6:Section({Name = "Velocity Fly", Side = "Left", Zindex = 2})


local AutoBuyingShit = SubPage6:Section({Name = "Auto Buy/Armor", Side = "Left", Zindex = 2})

local atlas = {
   Misc = {
    AutoBuy = {
        Enabled = false,
        ReturnBackDelay = 0.023,
        Gun = "LMG",
        Foods = "Chicken",
        Misc = "Surgeon Mask",
        Armor = "Medium Armor",
        AmmoAmount = 3,
        AutoArmor = {
            Enabled = false,
            BuyOn = 80
        },
        AutoEat = {
            Enabled = false,
            BuyOn = 80
         }
     }
  }
}

local Client = Players.LocalPlayer

function TeleportBuy(Target)
    if not Target or Target == "" then
        return
    end

    local targetItem = workspace.Ignored.Shop:FindFirstChild(Target)
    if not targetItem then
        return
    end

    local playerCharacter = Client and Client.Character
    if not playerCharacter or not playerCharacter:FindFirstChild("HumanoidRootPart") then
        return
    end

    local oldCFrame = playerCharacter.HumanoidRootPart.CFrame
    local returnDelay = atlas.Misc.AutoBuy.ReturnBackDelay

    playerCharacter.HumanoidRootPart.CFrame = targetItem.Head.CFrame * CFrame.new(0, 1, 0)
    wait(0.2)

    local clickDetector = targetItem:FindFirstChild("ClickDetector")
    if not clickDetector then
        return
    end

    if atlas.Misc.AutoBuy.Enabled then
        for i = 1, 3 do
            fireclickdetector(clickDetector)
            wait(0.05)
        end
    end

    wait(returnDelay)
    playerCharacter.HumanoidRootPart.CFrame = oldCFrame
end

function ToolName(Name)
    for _, item in ipairs(workspace.Ignored.Shop:GetChildren()) do
        if item.Name:match("%[" .. Name .. "%] %- %$%d+") then
            return item.Name
        end
    end
end

function ToolAmmo(Name)
    for _, item in ipairs(workspace.Ignored.Shop:GetChildren()) do
        if item.Name:match("%d+ %[" .. Name .. " Ammo%] %- %$%d+") then
            return item.Name
        end
    end
end

 AutoBuyingShit:Toggle({
        Name = 'Enable',
        Default = atlas.Misc.AutoBuy.Enabled, 
        Callback = function(bool)
    atlas.Misc.AutoBuy.Enabled = bool
end
})

AutoBuyingShit:List({
        Options = {"Glock","SMG","Silencer","TacticalShotgun","P90","AUG","Shotgun","RPG","AR","Double-Barrel SG","Flamethrower","Revolver","LMG","AK47","DrumGun","Silencer","GrenadeLauncher","Taser","SilencerAR","Grenade"}, 
        Default = atlas.Misc.AutoBuy.Gun,
        Callback = function(bool)
            atlas.Misc.AutoBuy.Gun = bool
        end
})

AutoBuyingShit:Button({Name = "Purchase Gun", Callback = function() 
        TeleportBuy(ToolName(atlas.Misc.AutoBuy.Gun))
    end})



AutoBuyingShit:List({
        Options = {"Cranberry","Donut","Pizza","Chicken","Popcorn","Hamburger","Taco","Starblox Latte","Lettuce","Lemonade"}, 
        Default = atlas.Misc.AutoBuy.Foods,
        Callback = function(bool)
            atlas.Misc.AutoBuy.Foods = bool
        end
    })

AutoBuyingShit:Button({Name = "Purchase Foods", Callback = function() 
        TeleportBuy(ToolName(atlas.Misc.AutoBuy.Foods))
    end})


AutoBuyingShit:List({
        Options = {"Surgeon Mask","Knife"}, 
        Default = atlas.Misc.AutoBuy.Misc,
        Callback = function(bool)
            atlas.Misc.AutoBuy.Misc = bool
        end
    })


--// Ratz

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


local AutoArmor = true
local BuyOn = 75
local AutoBuyShit = true

local selectedArmor = "[High-Medium Armor] - $2440" 
    
    local function AutoBuyArmor()
        task.spawn(function()
            while RunService.RenderStepped:Wait() do
                if AutoArmor and AutoBuyShit then
                    local Character = Client.Character
                    if Character and Character:FindFirstChild("BodyEffects") and Character.BodyEffects:FindFirstChild("Armor") then
                        if Character.BodyEffects.Armor.Value < BuyOn then
                            local OldPosition = Character.HumanoidRootPart.CFrame

                            local armorItem = workspace.Ignored.Shop:FindFirstChild(selectedArmor)
                            if armorItem and armorItem:FindFirstChild("Head") and armorItem:FindFirstChild("ClickDetector") then
                         
