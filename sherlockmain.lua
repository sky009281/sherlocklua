-- ============================================================
-- Sherlock BETA
-- language: Lua (Luau) | target: Roblox client (executor / LocalScript)
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local Lighting         = game:GetService("Lighting")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FONT       = Enum.Font.Code
local FONT_TITLE = Enum.Font.SourceSansBold
local FONT_TAG   = Enum.Font.GothamBold

local SHERLOCK_USERS = {
    [11543603683] = { rank = "Owner", extra = "Sky" },
}
local SCRIPT_MARKER_NAME = "SherlockMarker"

-- ============================================================
-- THEMES
-- ============================================================
local THEMES = {
    default = { Accent=Color3.fromRGB(200,200,205), Bg=Color3.fromRGB(10,10,12), BgSide=Color3.fromRGB(6,6,8), BgContent=Color3.fromRGB(14,14,16), BgTop=Color3.fromRGB(16,16,18), BgRow=Color3.fromRGB(20,20,22), BgRowHover=Color3.fromRGB(30,30,34), BgTrack=Color3.fromRGB(40,40,44), Stroke=Color3.fromRGB(38,38,42), TextPrimary=Color3.fromRGB(235,235,240), TextNormal=Color3.fromRGB(180,180,185), TextDim=Color3.fromRGB(100,100,105) },
    glass   = { Accent=Color3.fromRGB(165,205,255), Bg=Color3.fromRGB(24,28,40), BgSide=Color3.fromRGB(16,20,30), BgContent=Color3.fromRGB(30,36,50), BgTop=Color3.fromRGB(34,40,56), BgRow=Color3.fromRGB(38,44,60), BgRowHover=Color3.fromRGB(58,68,92), BgTrack=Color3.fromRGB(60,70,92), Stroke=Color3.fromRGB(96,116,156), TextPrimary=Color3.fromRGB(245,250,255), TextNormal=Color3.fromRGB(196,214,238), TextDim=Color3.fromRGB(126,146,176) },
    neon    = { Accent=Color3.fromRGB(0,255,200), Bg=Color3.fromRGB(6,10,12), BgSide=Color3.fromRGB(4,6,8), BgContent=Color3.fromRGB(8,14,16), BgTop=Color3.fromRGB(10,18,22), BgRow=Color3.fromRGB(12,22,26), BgRowHover=Color3.fromRGB(22,44,48), BgTrack=Color3.fromRGB(32,54,58), Stroke=Color3.fromRGB(0,120,110), TextPrimary=Color3.fromRGB(180,255,240), TextNormal=Color3.fromRGB(120,220,200), TextDim=Color3.fromRGB(60,140,130) },
    midnight= { Accent=Color3.fromRGB(170,140,255), Bg=Color3.fromRGB(12,10,24), BgSide=Color3.fromRGB(8,6,18), BgContent=Color3.fromRGB(16,12,30), BgTop=Color3.fromRGB(20,16,38), BgRow=Color3.fromRGB(24,18,44), BgRowHover=Color3.fromRGB(44,34,74), BgTrack=Color3.fromRGB(54,42,84), Stroke=Color3.fromRGB(64,48,104), TextPrimary=Color3.fromRGB(235,220,255), TextNormal=Color3.fromRGB(180,165,220), TextDim=Color3.fromRGB(112,100,152) },
}
local Theme = {}
for k, v in pairs(THEMES.default) do Theme[k] = v end

-- ============================================================
-- CONFIG
-- ============================================================
local DEFAULTS = {
    Nametags = true, NametagOnlyScriptUsers = false, NametagClickTeleport = true,
    HideAds = true, Enabled = false,
    Box = false, Name = false, Distance = false, Health = false,
    Fill = false, Tracers = false, TeamCheck = false,
    MaxDistance = 1500, TracerOrigin = "Bottom", TracerThickness = 1,
    HealthBarSide = "Left", BoxStyle = "Full", DistanceUnit = "m", HeadDot = false,
    Charm = false, CharmFill = 0.7, CharmOutline = true,
    BoxColor = Color3.fromRGB(200,200,205), FillColor = Color3.fromRGB(200,200,205),
    TracerColor = Color3.fromRGB(200,200,205), HealthColor = Color3.fromRGB(0,255,120),
    NameColor = Color3.fromRGB(255,255,255), DistanceColor = Color3.fromRGB(200,205,215),
    HeadDotColor = Color3.fromRGB(255,80,80),
    CharmFillColor = Color3.fromRGB(180,180,190), CharmOutlineColor = Color3.fromRGB(220,220,225),
    RainbowMenu = false, RainbowMenuSpeed = 0.15,
    RainbowESP = false, RainbowESPSpeed = 0.25,
    RainbowCharm = false, RainbowCharmSpeed = 0.30,
    RainbowTag = false, RainbowTagSpeed = 0.20,
    AimEnabled = false, AimKey = nil, AimMode = "Camera", AimSmooth = 0.25, AimFOV = 120,
    AimVisible = true, AimPart = "Head", AimTeamCheck = true, AimShowFOV = true, AimMaxDist = 800,
    AimPrediction = 0.135, AimPredictionEnabled = true, AimResolver = false, AimHitChance = 100,
    AimFovStyle = "Circle", AimFovColor = Color3.fromRGB(255,255,255),
    AimSticky = false, AimLockVisual = true,
    SpinEnabled = false, SpinSpeed = 15, SpinAxis = "Y", SpinKey = nil,
    SpeedEnabled = false, WalkSpeed = 60, JumpPower = 120, SpeedKey = nil, SpeedRestore = true,
    FlyEnabled = false, FlySpeed = 60, FlyKey = nil, FlyVertical = true, FlyMode = "Classic",
    FlyAnimSpeed = 1, SupermanPose = false, SupermanTilt = 75,
    ThirdPerson = false, TP_Distance = 12, TP_Height = 2, TP_Shoulder = 1.5, TP_MouseControl = true,
    MenuKey = Enum.KeyCode.K, EspKey = nil,
    ThemeName = "default",
    SkyEnabled = false, SkyTop = Color3.fromRGB(40,46,66), SkyBottom = Color3.fromRGB(14,14,20),
    SkyStars = false, SkySun = false, SkyRainbow = false, SkyRainbowSpeed = 0.15,
    SkyBrightness = 2, SkyClockTime = 14,
    CrosshairEnabled = false, CrosshairSize = 22, CrosshairThickness = 2,
    CrosshairColor = Color3.fromRGB(255,80,80), CrosshairSpin = true, CrosshairSpinSpeed = 1.0,
    CrosshairRainbow = false, CrosshairRainbowSpeed = 0.35, CrosshairGlow = true,
}

local Config = {}
for k, v in pairs(DEFAULTS) do Config[k] = v end

-- ============================================================
-- HELPERS
-- ============================================================
local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function guiParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return LP:WaitForChild("PlayerGui")
end
local ROOT = guiParent()

local function getHSV(c)
    local ok, h, s, v = pcall(function()
        local hh, ss, vv = c:ToHSV()
        return hh, ss, vv
    end)
    if ok and type(h) == "number" then return h, s, v end
    return 0, 1, 1
end

local function buildLogo(parent, size, color)
    local box = new("Frame", { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, BorderSizePixel = 0 }, parent)
    local scale = size / 100
    local SEGMENTS = {
        { x = 18, y = 20, w = 14, h = 44, r = -45 },
        { x = 46, y = 10, w = 14, h = 44, r =  45 },
        { x = 42, y = 48, w = 12, h = 30, r =  45 },
        { x = 78, y = 22, w = 10, h = 18, r =   0 },
    }
    local segs = {}
    for i, s in ipairs(SEGMENTS) do
        local f = new("Frame", {
            Size = UDim2.fromOffset(s.w * scale, s.h * scale),
            Position = UDim2.fromOffset(s.x * scale, s.y * scale),
            Rotation = s.r, BackgroundColor3 = color, BorderSizePixel = 0,
        }, box)
        new("UICorner", { CornerRadius = UDim.new(0, 2) }, f)
        segs[i] = f
    end
    return box, segs
end

local function avatarThumb(userId, kind)
    return "rbxthumb://type=" .. (kind or "AvatarBust") .. "&id=" .. tostring(userId) .. "&w=420&h=420"
end

-- ============================================================
-- BASE64 + COMPACT SERIALIZATION
-- ============================================================
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64_LOOKUP = {}
for i = 1, #B64 do B64_LOOKUP[B64:sub(i, i)] = i - 1 end

local function b64encode(s)
    local out = {}
    local n = #s
    local i = 1
    while i <= n do
        local b1 = string.byte(s, i)
        local b2 = i + 1 <= n and string.byte(s, i + 1) or 0
        local b3 = i + 2 <= n and string.byte(s, i + 2) or 0
        local c1 = math.floor(b1 / 4)
        local c2 = (b1 % 4) * 16 + math.floor(b2 / 16)
        local c3 = (b2 % 16) * 4 + math.floor(b3 / 64)
        local c4 = b3 % 64
        out[#out + 1] = B64:sub(c1 + 1, c1 + 1)
        out[#out + 1] = B64:sub(c2 + 1, c2 + 1)
        out[#out + 1] = (i + 1 <= n) and B64:sub(c3 + 1, c3 + 1) or "="
        out[#out + 1] = (i + 2 <= n) and B64:sub(c4 + 1, c4 + 1) or "="
        i = i + 3
    end
    return table.concat(out)
end

local function b64decode(s)
    local out = {}
    local i = 1
    while i <= #s do
        local c1 = B64_LOOKUP[s:sub(i, i)] or 0
        local c2 = B64_LOOKUP[s:sub(i + 1, i + 1)] or 0
        local ch3 = s:sub(i + 2, i + 2)
        local ch4 = s:sub(i + 3, i + 3)
        local c3 = ch3 ~= "=" and (B64_LOOKUP[ch3] or 0) or 0
        local c4 = ch4 ~= "=" and (B64_LOOKUP[ch4] or 0) or 0
        local b1 = c1 * 4 + math.floor(c2 / 16)
        local b2 = (c2 % 16) * 16 + math.floor(c3 / 4)
        local b3 = (c3 % 4) * 64 + c4
        out[#out + 1] = string.char(b1)
        if ch3 ~= "=" and ch3 ~= "" then out[#out + 1] = string.char(b2) end
        if ch4 ~= "=" and ch4 ~= "" then out[#out + 1] = string.char(b3) end
        i = i + 4
    end
    return table.concat(out)
end

local function colorToHex(c)
    return string.format("#%02x%02x%02x",
        math.floor(c.R * 255 + 0.5),
        math.floor(c.G * 255 + 0.5),
        math.floor(c.B * 255 + 0.5))
end

local function hexToColor(h)
    return Color3.fromRGB(
        tonumber(h:sub(1, 2), 16) or 0,
        tonumber(h:sub(3, 4), 16) or 0,
        tonumber(h:sub(5, 6), 16) or 0)
end

-- compact serialize: only non-default values
local function compactSerialize()
    local parts = {}
    for k, v in pairs(Config) do
        if v ~= nil and DEFAULTS[k] ~= v then
            local tv = type(v)
            if tv == "boolean" then
                parts[#parts + 1] = k .. "=" .. (v and "1" or "0")
            elseif tv == "number" then
                parts[#parts + 1] = k .. "=" .. tostring(v)
            elseif tv == "string" then
                parts[#parts + 1] = k .. "=" .. v
            elseif typeof(v) == "Color3" then
                parts[#parts + 1] = k .. "=" .. colorToHex(v)
            elseif typeof(v) == "EnumItem" then
                parts[#parts + 1] = k .. "=" .. tostring(v.EnumType) .. ":" .. v.Name
            end
        end
    end
    return table.concat(parts, "|")
end

local function compactDeserialize(s)
    if not s or s == "" then return end
    -- reset to defaults first
    for k, v in pairs(DEFAULTS) do Config[k] = v end
    for pair in s:gmatch("[^|]+") do
        local k, v = pair:match("^([^=]+)=(.+)$")
        if k and v then
            if v:sub(1, 1) == "#" then
                Config[k] = hexToColor(v:sub(2))
            elseif v:find(":", 1, true) and (v:sub(1, 3) == "Key" or v:sub(1, 4) == "User") then
                local etype, ename = v:match("^([^:]+):(.+)$")
                local ok, item = pcall(function() return Enum[etype][ename] end)
                if ok then Config[k] = item end
            elseif v == "1" then Config[k] = true
            elseif v == "0" then Config[k] = false
            elseif tonumber(v) then Config[k] = tonumber(v)
            else Config[k] = v end
        end
    end
end

-- ============================================================
-- AD HIDE
-- ============================================================
task.spawn(function()
    local KILL_WORDS = { "donate", "game pass", "free panel", "chat tag", "support the game", "donat", "buy the gamepass" }
    local function killAdsIn(root)
        if not root then return end
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("ScreenGui") then
                for _, c in ipairs(d:GetDescendants()) do
                    if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                        local txt = string.lower(c.Text or "")
                        for _, kw in ipairs(KILL_WORDS) do
                            if txt:find(kw, 1, true) then
                                pcall(function() d.Enabled = false end)
                                pcall(function() c.Text = "" end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    local function hook(root)
        pcall(function()
            root.DescendantAdded:Connect(function(d)
                if not Config.HideAds then return end
                task.wait(0.05)
                if d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("ScreenGui") then killAdsIn(root) end
            end)
        end)
    end
    hook(workspace)
    hook(game:GetService("CoreGui"))
    pcall(function() hook(LP.PlayerGui) end)
    while true do
        if Config.HideAds then
            pcall(function() killAdsIn(workspace) end)
            pcall(function() killAdsIn(game:GetService("CoreGui")) end)
        end
        task.wait(0.5)
    end
end)

local bootGui  = new("ScreenGui", { Name = "Sherlock_Boot",  ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 50, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local espGui   = new("ScreenGui", { Name = "Sherlock_ESP",   ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 1,  ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local skyGui   = new("ScreenGui", { Name = "Sherlock_Sky",   ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 0,  ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local hudGui   = new("ScreenGui", { Name = "Sherlock_HUD",   ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 5,  ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local tagGui   = new("ScreenGui", { Name = "Sherlock_Tags",  ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 6,  ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local menuGui  = new("ScreenGui", { Name = "Sherlock_Menu",  ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)

local espCache = {}

-- ============================================================
-- BOOT v4 — starfield zoom + portal + welcome back
-- ============================================================
do
    local backdrop = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1,
    }, bootGui)

    local vignette = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(8, 8, 12),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
    }, backdrop)
    new("UIGradient", { Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(56, 56, 68)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(4, 4, 8)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(56, 56, 68)),
    }) }, vignette)

    -- starfield zoom
    local starLayer = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 3,
    }, backdrop)
    local stars = {}
    local CX, CY = 0.5, 0.5
    for i = 1, 90 do
        local s = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(1.5, 1.5),
            Position = UDim2.new(CX, 0, CY, 0), BackgroundColor3 = Color3.fromRGB(200, 220, 255),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
        }, starLayer)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, s)
        stars[i] = {
            obj = s, ang = math.random() * math.pi * 2,
            radius = math.random() * 0.05 + 0.01,
            speed = 0.35 + math.random() * 0.85,
            a = 0.3 + math.random() * 0.6,
        }
    end

    -- scanlines
    local scanHolder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3 }, backdrop)
    local scanlines = {}
    for i = 0, 42 do
        scanlines[i] = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0, i * 22),
            BackgroundColor3 = Color3.fromRGB(140, 145, 165),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
        }, scanHolder)
    end

    -- perspective grid floor
    local gridHolder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3 }, backdrop)
    local hLines, vLines = {}, {}
    for i = 0, 18 do
        local t = i / 18
        hLines[i] = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.58 + t * t * 0.45, 0),
            BackgroundColor3 = Color3.fromRGB(120, 130, 160),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
        }, gridHolder)
    end
    for i = -10, 10 do
        local t = i / 10
        vLines[i] = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 1, 0.45, 0),
            Position = UDim2.new(0.5 + t * 0.85, 0, 0.58, 0), Rotation = t * 22,
            BackgroundColor3 = Color3.fromRGB(120, 130, 160),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3,
        }, gridHolder)
    end

    -- glyph rain
    local GLYPHS = { "0","1","S","H","E","R","L","O","C","K","λ","Δ","Ω","7","3","9","#","*" }
    local rainHolder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4 }, backdrop)
    local rainCols = {}
    for c = 1, 26 do
        local col = new("Frame", {
            Size = UDim2.new(0, 14, 1, 0), Position = UDim2.new((c - 1) / 26 + 0.008, 0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4,
        }, rainHolder)
        local chars = {}
        for r = 1, 22 do
            chars[r] = new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, (r - 1) / 22, 0),
                BackgroundTransparency = 1, Text = GLYPHS[math.random(1, #GLYPHS)],
                TextColor3 = Color3.fromRGB(140, 220, 170),
                Font = FONT, TextSize = 11, TextTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
            }, col)
        end
        rainCols[c] = { obj = col, chars = chars, y = -1 - math.random() * 2, sp = 0.35 + math.random() * 0.55, tick = 0 }
    end

    local coreGlow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(420, 420),
        Position = UDim2.new(CX, 0, CY, 0), BackgroundColor3 = Color3.fromRGB(160, 200, 255),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, backdrop)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, coreGlow)

    local coreInner = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(120, 120),
        Position = UDim2.new(CX, 0, CY, 0), BackgroundColor3 = Color3.fromRGB(230, 240, 255),
        BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6,
    }, backdrop)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, coreInner)

    local function mkRing(size, thickness, color, zidx, trans, dashes)
        local r = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size),
            Position = UDim2.new(CX, 0, CY, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = zidx,
        }, backdrop)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, r)
        local st = new("UIStroke", { Color = color, Thickness = thickness, Transparency = trans }, r)
        local dashTable = {}
        if dashes then
            for i = 1, dashes do
                local d = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.fromOffset(thickness + 1.5, thickness + 1.5),
                    BackgroundColor3 = color, BorderSizePixel = 0,
                    BackgroundTransparency = trans, ZIndex = zidx + 1,
                }, backdrop)
                new("UICorner", { CornerRadius = UDim.new(1, 0) }, d)
                dashTable[i] = { obj = d, ang = (i - 1) / dashes * math.pi * 2, r = size / 2 }
            end
        end
        return r, st, dashTable
    end

    local ringOuter, ringOuterStroke, ringOuterDashes = mkRing(360, 1.2, Color3.fromRGB(200, 200, 210), 6, 1, 24)
    local ringMid,   ringMidStroke,   ringMidDashes   = mkRing(280, 1.8, Color3.fromRGB(210, 210, 220), 6, 1, 16)
    local ringInner, ringInnerStroke, ringInnerDashes = mkRing(200, 2.4, Color3.fromRGB(220, 220, 230), 6, 1, 8)
    local ringCore,  ringCoreStroke                   = mkRing(140, 1.6, Color3.fromRGB(230, 235, 250), 6, 1)

    -- shockwave rings
    local shockwaves = {}
    for i = 1, 3 do
        local sw = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(50, 50),
            Position = UDim2.new(CX, 0, CY, 0), BackgroundTransparency = 1,
            BorderSizePixel = 0, Visible = false, ZIndex = 5,
        }, backdrop)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, sw)
        local st = new("UIStroke", { Color = Color3.fromRGB(200, 220, 255), Thickness = 2, Transparency = 0.4 }, sw)
        shockwaves[i] = { obj = sw, stroke = st, active = false }
    end

    -- WELCOME BACK
    local welcome = new("TextLabel", {
        Size = UDim2.new(0, 640, 0, 24),
        Position = UDim2.new(CX, -320, CY, -180),
        BackgroundTransparency = 1, Text = "WELCOME BACK",
        TextColor3 = Color3.fromRGB(200, 225, 255),
        Font = FONT_TITLE, TextSize = 22, TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 8,
    }, backdrop)

    local welcomeSub = new("TextLabel", {
        Size = UDim2.new(0, 640, 0, 14),
        Position = UDim2.new(CX, -320, CY, -150),
        BackgroundTransparency = 1, Text = (LP.DisplayName or LP.Name),
        TextColor3 = Color3.fromRGB(140, 170, 220),
        Font = FONT, TextSize = 11, TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 8,
    }, backdrop)

    local logoHolder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(140, 140),
        Position = UDim2.new(CX, 0, CY, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7,
    }, backdrop)
    local _, logoSegments = buildLogo(logoHolder, 140, Color3.fromRGB(255, 255, 255))
    for _, s in ipairs(logoSegments) do s.BackgroundTransparency = 1 end

    local wordHolder = new("Frame", {
        Size = UDim2.new(0, 520, 0, 36), Position = UDim2.new(CX, -260, CY, 96),
        BackgroundTransparency = 1, ZIndex = 7,
    }, backdrop)
    local letters = {}
    local text = "SHERLOCK"
    local totalW = #text * 32
    for i = 1, #text do
        letters[i] = new("TextLabel", {
            Size = UDim2.new(0, 32, 1, 0),
            Position = UDim2.new(0, (i - 1) * 32 + (520 - totalW) / 2, 0, 0),
            BackgroundTransparency = 1, Text = text:sub(i, i),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = FONT_TITLE, TextSize = 34, TextTransparency = 1, ZIndex = 7,
        }, wordHolder)
    end

    local accentLine = new("Frame", {
        Size = UDim2.new(0, 0, 0, 1), Position = UDim2.new(CX, 0, CY, 140),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 7,
    }, backdrop)

    local tagline = new("TextLabel", {
        Size = UDim2.new(0, 520, 0, 14), Position = UDim2.new(CX, -260, CY, 150),
        BackgroundTransparency = 1, Text = "initializing portal",
        TextColor3 = Theme.TextDim, Font = FONT, TextSize = 11,
        TextTransparency = 1, ZIndex = 7,
    }, backdrop)

    local barBg = new("Frame", {
        Size = UDim2.new(0, 340, 0, 4), Position = UDim2.new(CX, -170, CY, 182),
        BackgroundColor3 = Color3.fromRGB(24, 24, 28),
        BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 7,
    }, backdrop)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barBg)
    local barFill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 8,
    }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barFill)
    local barGlow = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, BackgroundTransparency = 1, ZIndex = 8,
    }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barGlow)

    local pctLabel = new("TextLabel", {
        Size = UDim2.new(0, 340, 0, 12), Position = UDim2.new(CX, -170, CY, 196),
        BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextDim,
        Font = FONT, TextSize = 10, TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 7,
    }, backdrop)

    local statusLabel = new("TextLabel", {
        Size = UDim2.new(0, 520, 0, 12), Position = UDim2.new(CX, -260, CY, 214),
        BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(140, 200, 170),
        Font = FONT, TextSize = 9, TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 7,
    }, backdrop)

    -- loops
    local ringT = 0
    task.spawn(function()
        while backdrop.Parent do
            ringT = ringT + 0.016
            ringOuter.Rotation = (ringT * 14) % 360
            ringMid.Rotation   = (-ringT * 24) % 360
            ringInner.Rotation = (ringT * 42) % 360
            ringCore.Rotation  = (-ringT * 68) % 360
            for _, d in ipairs(ringOuterDashes) do
                local a = d.ang + ringT * 0.35
                d.obj.Position = UDim2.new(CX + math.cos(a) * (d.r / 1000), 0, CY + math.sin(a) * (d.r / 1000), 0)
            end
            for _, d in ipairs(ringMidDashes) do
                local a = d.ang - ringT * 0.55
                d.obj.Position = UDim2.new(CX + math.cos(a) * (d.r / 1000), 0, CY + math.sin(a) * (d.r / 1000), 0)
            end
            for _, d in ipairs(ringInnerDashes) do
                local a = d.ang + ringT * 0.9
                d.obj.Position = UDim2.new(CX + math.cos(a) * (d.r / 1000), 0, CY + math.sin(a) * (d.r / 1000), 0)
            end
            task.wait(0.016)
        end
    end)

    task.spawn(function()
        while backdrop.Parent do
            for _, s in ipairs(stars) do
                s.radius = s.radius + s.speed * 0.005
                if s.radius > 1.1 then
                    s.radius = 0.005
                    s.ang = math.random() * math.pi * 2
                    s.speed = 0.35 + math.random() * 0.85
                end
                s.obj.Position = UDim2.new(CX + math.cos(s.ang) * s.radius, 0, CY + math.sin(s.ang) * s.radius, 0)
                local fade = math.clamp(1 - s.radius, 0, 1)
                local alpha = s.a * fade
                s.obj.BackgroundTransparency = 1 - alpha
                s.obj.Size = UDim2.fromOffset(1 + s.radius * 4, 1 + s.radius * 4)
            end
            task.wait(0.016)
        end
    end)

    task.spawn(function()
        while backdrop.Parent do
            for _, col in ipairs(rainCols) do
                col.y = col.y + col.sp * 0.02
                if col.y > 1.4 then col.y = -1.4 col.sp = 0.35 + math.random() * 0.55 col.tick = 0 end
                col.tick = col.tick + 1
                if col.tick % 5 == 0 then
                    for _, ch in ipairs(col.chars) do
                        if math.random() < 0.35 then ch.Text = GLYPHS[math.random(1, #GLYPHS)] end
                    end
                end
                for r, ch in ipairs(col.chars) do
                    local rel = (r - 1) / 22
                    local yPos = rel + col.y
                    if yPos < -0.05 or yPos > 1.05 then
                        ch.TextTransparency = 1
                    else
                        ch.Position = UDim2.new(0, 0, yPos, 0)
                        local fade = math.min(yPos * 3, (1 - yPos) * 3, 1)
                        local head = math.clamp(1 - math.abs(rel - 0.9) * 6, 0, 1)
                        local baseT = 0.75 - head * 0.55
                        ch.TextTransparency = math.clamp(baseT + (1 - fade) * 0.4, 0, 1)
                    end
                end
            end
            task.wait(0.03)
        end
    end)

    task.spawn(function()
        while backdrop.Parent do
            TweenService:Create(coreGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.72 }):Play()
            TweenService:Create(coreInner, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.55 }):Play()
            task.wait(1.2)
            TweenService:Create(coreGlow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.88 }):Play()
            TweenService:Create(coreInner, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.8 }):Play()
            task.wait(1.2)
        end
    end)

    task.spawn(function()
        while backdrop.Parent do
            for _, sw in ipairs(shockwaves) do
                if not sw.active then
                    sw.active = true
                    sw.obj.Visible = true
                    sw.obj.Size = UDim2.fromOffset(30, 30)
                    sw.stroke.Transparency = 0.2
                    TweenService:Create(sw.obj, TweenInfo.new(1.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(700, 700) }):Play()
                    TweenService:Create(sw.stroke, TweenInfo.new(1.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 1, Thickness = 0.5 }):Play()
                    task.delay(1.6, function()
                        sw.active = false
                        sw.obj.Visible = false
                    end)
                    task.wait(0.55)
                end
            end
            task.wait(0.05)
        end
    end)

    -- choreography
    task.spawn(function()
        pcall(function()
            task.wait(0.05)
            TweenService:Create(backdrop, TweenInfo.new(0.45), { BackgroundTransparency = 0 }):Play()
            TweenService:Create(vignette, TweenInfo.new(0.7), { BackgroundTransparency = 0 }):Play()
            task.wait(0.15)
            for _, line in pairs(scanlines) do
                TweenService:Create(line, TweenInfo.new(0.55, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.93 }):Play()
            end
            for _, l in pairs(hLines) do
                TweenService:Create(l, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.88 }):Play()
            end
            for _, l in pairs(vLines) do
                TweenService:Create(l, TweenInfo.new(0.7, Enum.EasingStyle.Quint), { BackgroundTransparency = 0.88 }):Play()
            end

            task.wait(0.3)
            welcome.Position = UDim2.new(CX, -320, CY, -200)
            TweenService:Create(welcome, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { TextTransparency = 0, Position = UDim2.new(CX, -320, CY, -180) }):Play()
            task.wait(0.15)
            welcomeSub.Position = UDim2.new(CX, -320, CY, -170)
            TweenService:Create(welcomeSub, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { TextTransparency = 0.15, Position = UDim2.new(CX, -320, CY, -150) }):Play()

            task.wait(0.3)
            coreGlow.BackgroundTransparency = 0.55
            coreInner.BackgroundTransparency = 0.4
            TweenService:Create(coreGlow, TweenInfo.new(0.6), { BackgroundTransparency = 0.9 }):Play()
            TweenService:Create(coreInner, TweenInfo.new(0.6), { BackgroundTransparency = 0.75 }):Play()
            TweenService:Create(ringOuterStroke, TweenInfo.new(0.7), { Transparency = 0.55 }):Play()
            TweenService:Create(ringMidStroke,   TweenInfo.new(0.6), { Transparency = 0.4 }):Play()
            TweenService:Create(ringInnerStroke, TweenInfo.new(0.5), { Transparency = 0.28 }):Play()
            TweenService:Create(ringCoreStroke,  TweenInfo.new(0.4), { Transparency = 0.2 }):Play()

            task.wait(0.35)
            logoHolder.Size = UDim2.fromOffset(20, 20)
            logoHolder.Rotation = -200
            TweenService:Create(logoHolder, TweenInfo.new(1.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(140, 140), Rotation = 0 }):Play()
            for i, seg in ipairs(logoSegments) do
                task.delay((i - 1) * 0.07, function()
                    TweenService:Create(seg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), { BackgroundTransparency = 0 }):Play()
                end)
            end
            task.wait(0.7)
            for i, lbl in ipairs(letters) do
                task.delay((i - 1) * 0.055, function()
                    lbl.Position = UDim2.new(0, lbl.Position.X.Offset, 0, 22)
                    TweenService:Create(lbl, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextTransparency = 0, Position = UDim2.new(0, lbl.Position.X.Offset, 0, 0) }):Play()
                end)
            end
            task.wait(0.6)
            TweenService:Create(accentLine, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 260, 0, 1), BackgroundTransparency = 0.25 }):Play()
            task.wait(0.15)
            tagline.Position = UDim2.new(CX, -260, CY, 164)
            TweenService:Create(tagline, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextTransparency = 0, Position = UDim2.new(CX, -260, CY, 150) }):Play()
            task.wait(0.2)
            TweenService:Create(barBg, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
            TweenService:Create(pctLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
            TweenService:Create(statusLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
            task.wait(0.1)
            TweenService:Create(barFill, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 }):Play()
            TweenService:Create(barGlow, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.35 }):Play()
            local stages = { "linking kernel", "loading symbols", "decrypting signatures", "mapping modules", "attaching observers", "warming shaders", "synthesizing glyphs", "calibrating portal", "ready" }
            for i = 0, 100, 1 do
                pctLabel.Text = tostring(i) .. "%"
                local stageIdx = math.floor(i / 100 * #stages) + 1
                if stageIdx > #stages then stageIdx = #stages end
                statusLabel.Text = string.upper(stages[stageIdx])
                if i % 8 == 0 then
                    for c = 1, 4 do
                        local col = rainCols[math.random(1, #rainCols)]
                        for _, ch in ipairs(col.chars) do
                            if math.random() < 0.3 then ch.Text = GLYPHS[math.random(1, #GLYPHS)] end
                        end
                    end
                end
                task.wait(0.016)
            end
            pctLabel.Text = "100%"
            statusLabel.Text = "READY"
            task.wait(0.55)
            TweenService:Create(welcome, TweenInfo.new(0.5), { TextTransparency = 1, Position = UDim2.new(CX, -320, CY, -200) }):Play()
            TweenService:Create(welcomeSub, TweenInfo.new(0.5), { TextTransparency = 1, Position = UDim2.new(CX, -320, CY, -170) }):Play()
            TweenService:Create(logoHolder, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.fromOffset(0, 0), Rotation = 220 }):Play()
            for _, seg in ipairs(logoSegments) do
                TweenService:Create(seg, TweenInfo.new(0.55), { BackgroundTransparency = 1 }):Play()
            end
            TweenService:Create(coreGlow, TweenInfo.new(0.55), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(coreInner, TweenInfo.new(0.55), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(ringOuterStroke, TweenInfo.new(0.55), { Transparency = 1, Thickness = 6 }):Play()
            TweenService:Create(ringMidStroke,   TweenInfo.new(0.55), { Transparency = 1, Thickness = 8 }):Play()
            TweenService:Create(ringInnerStroke, TweenInfo.new(0.55), { Transparency = 1, Thickness = 10 }):Play()
            TweenService:Create(ringCoreStroke,  TweenInfo.new(0.55), { Transparency = 1, Thickness = 12 }):Play()
            for _, d in ipairs(ringOuterDashes) do TweenService:Create(d.obj, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play() end
            for _, d in ipairs(ringMidDashes)   do TweenService:Create(d.obj, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play() end
            for _, d in ipairs(ringInnerDashes) do TweenService:Create(d.obj, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play() end
            for _, lbl in ipairs(letters) do
                TweenService:Create(lbl, TweenInfo.new(0.5), { TextTransparency = 1, Position = UDim2.new(0, lbl.Position.X.Offset, 0, 24) }):Play()
            end
            TweenService:Create(accentLine, TweenInfo.new(0.5), { Size = UDim2.new(0, 0, 0, 1), BackgroundTransparency = 1 }):Play()
            TweenService:Create(tagline, TweenInfo.new(0.5), { TextTransparency = 1, Position = UDim2.new(CX, -260, CY, 164) }):Play()
            TweenService:Create(barBg, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(barFill, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(barGlow, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(pctLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
            TweenService:Create(statusLabel, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
            for _, line in pairs(scanlines) do TweenService:Create(line, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play() end
            for _, l in pairs(hLines) do TweenService:Create(l, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play() end
            for _, l in pairs(vLines) do TweenService:Create(l, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play() end
            for _, s in ipairs(stars) do
                TweenService:Create(s.obj, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            end
            for _, col in ipairs(rainCols) do
                for _, ch in ipairs(col.chars) do
                    TweenService:Create(ch, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
                end
            end
            TweenService:Create(vignette, TweenInfo.new(0.65), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(backdrop, TweenInfo.new(0.65), { BackgroundTransparency = 1 }):Play()
            task.wait(0.7)
        end)
        pcall(function() bootGui:Destroy() end)
    end)
end

-- ============================================================
-- NAMETAGS
-- ============================================================
local Nametags = {}
do
    local tagCache = {}

    local function particle(parent, color, size, z)
        local p = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = z or 1,
        }, parent)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, p)
        return p
    end

    local function clipHolder(card, name)
        local h = new("Frame", { Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 1 }, card)
        new("UICorner", { CornerRadius = UDim.new(0, 6) }, h)
        return h
    end

    local function goldDust(card, count)
        local h = clipHolder(card, "GoldDust")
        local list = {}
        for i = 1, count do
            local p = particle(h, Color3.fromRGB(255, 220, 100), 2, 1)
            list[i] = { obj = p, x = math.random(), y = -0.2 - math.random(), vy = 0.020 + math.random() * 0.030, sway = math.random() * math.pi * 2, ss = 0.040 + math.random() * 0.050, a = 0.35 + math.random() * 0.55 }
            p.BackgroundTransparency = 1 - list[i].a
        end
        task.spawn(function()
            while h.Parent do
                for _, d in ipairs(list) do
                    d.y = d.y + d.vy
                    d.sway = d.sway + d.ss
                    if d.y > 1.15 then d.y = -0.2 d.x = math.random() end
                    d.obj.Position = UDim2.new(d.x + math.sin(d.sway) * 0.07, 0, d.y, 0)
                    local edge = math.min(d.y * 4, (1 - d.y) * 4, 1)
                    d.obj.BackgroundTransparency = 1 - d.a * math.clamp(edge, 0, 1)
                end
                task.wait(0.035)
            end
        end)
    end

    local function auroraSweep(card)
        local s = new("Frame", { Name = "Aurora", Size = UDim2.new(2.4, 0, 1, 0), Position = UDim2.new(-1.7, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 210, 80), BackgroundTransparency = 0.72, BorderSizePixel = 0, ZIndex = 0 }, card)
        new("UICorner", { CornerRadius = UDim.new(0, 6) }, s)
        new("UIGradient", { Rotation = 0, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0.0, 1), NumberSequenceKeypoint.new(0.5, 0.15), NumberSequenceKeypoint.new(1.0, 1) }) }, s)
        task.spawn(function()
            while s.Parent do
                s.Position = UDim2.new(-1.7, 0, 0, 0)
                TweenService:Create(s, TweenInfo.new(2.6, Enum.EasingStyle.Linear), { Position = UDim2.new(1.4, 0, 0, 0) }):Play()
                task.wait(2.8)
            end
        end)
    end

    local function blueSnow(card, count)
        local h = clipHolder(card, "BlueSnow")
        local list = {}
        for i = 1, count do
            local p = particle(h, Color3.fromRGB(190, 235, 255), 2, 1)
            list[i] = { obj = p, x = math.random(), y = -0.2 - math.random(), vy = 0.014 + math.random() * 0.018, sway = math.random() * math.pi * 2, ss = 0.050 + math.random() * 0.050, a = 0.60 + math.random() * 0.35 }
            p.BackgroundTransparency = 1 - list[i].a
        end
        task.spawn(function()
            while h.Parent do
                for _, d in ipairs(list) do
                    d.y = d.y + d.vy
                    d.sway = d.sway + d.ss
                    if d.y > 1.15 then d.y = -0.2 d.x = math.random() end
                    d.obj.Position = UDim2.new(d.x + math.sin(d.sway) * 0.05, 0, d.y, 0)
                end
                task.wait(0.03)
            end
        end)
    end

    local function bottomWave(card)
        local h = clipHolder(card, "Wave")
        local w = new("Frame", { Size = UDim2.new(2.2, 0, 0, 7), Position = UDim2.new(-0.6, 0, 1, -3.5), BackgroundColor3 = Color3.fromRGB(100, 150, 220), BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 1 }, h)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, w)
        new("UIGradient", { Rotation = 0, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0.0, 1), NumberSequenceKeypoint.new(0.5, 0.10), NumberSequenceKeypoint.new(1.0, 1) }) }, w)
        task.spawn(function()
            while h.Parent do
                local t = tick()
                w.Position = UDim2.new(-0.6 + math.sin(t * 0.7) * 0.20, 0, 1, -3.5 + math.sin(t * 1.3) * 1.6)
                task.wait(0.05)
            end
        end)
    end

    local function scriptRing(parent, color)
        local holder = new("Frame", { Name = "ScriptRing", Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, ZIndex = 4 }, parent)
        local dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 4 }, holder)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, dot)
        task.spawn(function()
            while holder.Parent do
                local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(5, 5), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, ZIndex = 3 }, holder)
                new("UICorner", { CornerRadius = UDim.new(1, 0) }, r)
                local st = new("UIStroke", { Color = color, Thickness = 1.5, Transparency = 0.1 }, r)
                TweenService:Create(r, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(16, 16) }):Play()
                TweenService:Create(st, TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
                task.delay(1.3, function() pcall(function() r:Destroy() end) end)
                task.wait(0.55)
            end
        end)
        return holder, dot
    end

    local function entrance(card, baseSize)
        card.Size = UDim2.new(0, 0, 0, 0)
        card.Position = UDim2.new(0.5, 0, 0.5, 0)
        card.Rotation = -18
        TweenService:Create(card, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = baseSize,
            Position = UDim2.new(0.5, -baseSize.X.Offset / 2, 0, 0),
            Rotation = 0,
        }):Play()
    end

    local function getDisplayInfo(plr)
        local entry = SHERLOCK_USERS[plr.UserId]
        if entry then return entry.rank, entry.extra end
        local char = plr.Character
        if char and char:FindFirstChild(SCRIPT_MARKER_NAME) then return "Guest", nil end
        return "Player", nil
    end

    local function isScriptUser(plr)
        if SHERLOCK_USERS[plr.UserId] then return true end
        local char = plr.Character
        if char and char:FindFirstChild(SCRIPT_MARKER_NAME) then return true end
        return false
    end

    local function teleportTo(plr)
        if plr == LP or not Config.NametagClickTeleport then return end
        local char = plr.Character
        if not char then return end
        local targetRoot = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        local myChar = LP.Character
        if not myChar or not targetRoot then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local tPos = targetRoot.Position
        local tLook = targetRoot.CFrame.LookVector
        local newPos = tPos + tLook * 4
        local newCF = CFrame.new(newPos, Vector3.new(tPos.X, newPos.Y, tPos.Z))
        pcall(function() myRoot.AssemblyLinearVelocity = Vector3.zero end)
        local ok = pcall(function() myChar:PivotTo(newCF) end)
        if not ok then myRoot.CFrame = newCF end
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then cam.CFrame = CFrame.new(newPos + Vector3.new(0, 2, 0), tPos) end
        end)
    end

    local function buildTag(plr, char)
        local head = char:FindFirstChild("Head")
        if not head then return nil end
        local old = head:FindFirstChild("Sherlock_Tag")
        if old then old:Destroy() end

        local rank, extra = getDisplayInfo(plr)
        local isOwner  = (rank == "Owner")
        local isGuest  = (rank == "Guest")
        local isSelf   = (plr == LP)

        local CARD_W, CARD_H
        if isOwner then CARD_W, CARD_H = 156, 48
        elseif isGuest then CARD_W, CARD_H = 142, 42
        else CARD_W, CARD_H = 124, 36 end
        if extra then CARD_H = CARD_H + 12 end

        local bgColor, strokeColor, titleColor, glowColor, barColor, nameColor
        if isOwner then
            bgColor = Color3.fromRGB(28, 20, 6); strokeColor = Color3.fromRGB(255, 215, 90)
            titleColor = Color3.fromRGB(255, 225, 120); glowColor = Color3.fromRGB(255, 210, 80)
            barColor = Color3.fromRGB(255, 220, 100); nameColor = Color3.fromRGB(255, 250, 235)
        elseif isGuest then
            bgColor = Color3.fromRGB(6, 16, 28); strokeColor = Color3.fromRGB(90, 190, 255)
            titleColor = Color3.fromRGB(120, 210, 255); glowColor = Color3.fromRGB(80, 180, 255)
            barColor = Color3.fromRGB(80, 180, 255); nameColor = Color3.fromRGB(220, 240, 255)
        else
            bgColor = Color3.fromRGB(12, 14, 20); strokeColor = Color3.fromRGB(70, 100, 160)
            titleColor = Color3.fromRGB(150, 180, 220); glowColor = Color3.fromRGB(60, 90, 150)
            barColor = Color3.fromRGB(80, 110, 170); nameColor = Color3.fromRGB(220, 225, 235)
        end

        local billboard = new("BillboardGui", {
            Name = "Sherlock_Tag",
            Size = UDim2.fromOffset(CARD_W + 12, CARD_H + 12),
            StudsOffset = Vector3.new(0, isOwner and 3.2 or 2.9, 0),
            AlwaysOnTop = true, ResetOnSpawn = false, MaxDistance = 600, Active = true,
        }, head)

        local root = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 }, billboard)

        local glowBehind = new("Frame", {
            Size = UDim2.new(0, CARD_W + 8, 0, CARD_H + 8),
            Position = UDim2.new(0.5, -(CARD_W + 8) / 2, 0, 0),
            BackgroundColor3 = glowColor, BackgroundTransparency = 0.9, BorderSizePixel = 0, ZIndex = 0,
        }, root)
        new("UICorner", { CornerRadius = UDim.new(0, 7) }, glowBehind)

        local cardBg = new("Frame", {
            Size = UDim2.new(0, CARD_W, 0, CARD_H),
            Position = UDim2.new(0.5, -CARD_W / 2, 0, 0),
            BackgroundColor3 = bgColor, BackgroundTransparency = 1,
            BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2,
        }, root)
        new("UICorner", { CornerRadius = UDim.new(0, 6) }, cardBg)
        local cardStroke = new("UIStroke", { Color = strokeColor, Thickness = isOwner and 1.4 or 1, Transparency = 0.15 }, cardBg)

        if isOwner then auroraSweep(cardBg) goldDust(cardBg, 7)
        elseif isGuest then blueSnow(cardBg, 6)
        else bottomWave(cardBg) end

        local accentBar = new("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, 3, 0, 4), BackgroundColor3 = barColor, BorderSizePixel = 0, ZIndex = 3 }, cardBg)
        new("UICorner", { CornerRadius = UDim.new(1, 0) }, accentBar)

        local title = new("TextLabel", {
            Size = UDim2.new(1, -34, 0, 16), Position = UDim2.new(0, 12, 0, 3),
            BackgroundTransparency = 1, Text = string.upper(rank),
            TextColor3 = titleColor, Font = FONT_TAG, TextSize = isOwner and 13 or 12,
            TextStrokeTransparency = 0.55, TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
        }, cardBg)

        local userLabel = new("TextLabel", {
            Size = UDim2.new(1, -34, 0, 12), Position = UDim2.new(0, 12, 0, 17),
            BackgroundTransparency = 1, Text = plr.Name, TextColor3 = nameColor,
            Font = Enum.Font.GothamSemibold, TextSize = isOwner and 11 or 10,
            TextStrokeTransparency = 0.5, TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
        }, cardBg)

        local extraLabel = nil
        if extra then
            extraLabel = new("TextLabel", {
                Size = UDim2.new(1, -34, 0, 12), Position = UDim2.new(0, 12, 0, 29),
                BackgroundTransparency = 1, Text = extra, TextColor3 = Color3.fromRGB(255, 240, 180),
                Font = FONT_TAG, TextSize = 10, TextStrokeTransparency = 0.5,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
            }, cardBg)
        end

        if isOwner or isGuest then
            local ringHolder = new("Frame", { Size = UDim2.fromOffset(12, 12), Position = UDim2.new(1, -18, 0, 5), BackgroundTransparency = 1, ZIndex = 4 }, cardBg)
            local ringColor = isOwner and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(80, 230, 130)
            scriptRing(ringHolder, ringColor)
            local badgeTxt = isOwner and "AUTHOR" or "SCRIPT"
            local badgeColor = isOwner and Color3.fromRGB(255, 240, 160) or Color3.fromRGB(120, 240, 160)
            new("TextLabel", {
                Size = UDim2.new(0, 60, 0, 10), Position = UDim2.new(1, -76, 0, 5),
                BackgroundTransparency = 1, Text = badgeTxt, TextColor3 = badgeColor,
                Font = FONT_TAG, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Right,
                TextStrokeTransparency = 0.6, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), ZIndex = 4,
            }, cardBg)
        end

        local hint = new("TextLabel", {
            Size = UDim2.new(1, -22, 0, 10), Position = UDim2.new(0, 12, 1, -12),
            BackgroundTransparency = 1,
            Text = (Config.NametagClickTeleport and not isSelf) and "click to teleport" or "",
            TextColor3 = Color3.fromRGB(160, 170, 190), Font = Enum.Font.Gotham, TextSize = 8,
            TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 4,
        }, cardBg)

        entrance(cardBg, UDim2.new(0, CARD_W, 0, CARD_H))
        TweenService:Create(cardBg, TweenInfo.new(0.55), { BackgroundTransparency = 0.04 }):Play()
        glowBehind.Size = UDim2.new(0, 0, 0, 0)
        glowBehind.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(glowBehind, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, CARD_W + 8, 0, CARD_H + 8),
            Position = UDim2.new(0.5, -(CARD_W + 8) / 2, 0, 0),
        }):Play()

        task.spawn(function()
            local pulseTitle = isOwner and Color3.fromRGB(255, 250, 210)
                or isGuest and Color3.fromRGB(180, 230, 255) or Color3.fromRGB(200, 215, 235)
            local glowBase = isOwner and 0.82 or isGuest and 0.88 or 0.92
            local speed = isOwner and 0.9 or isGuest and 1.1 or 1.4
            while billboard.Parent do
                TweenService:Create(title, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = pulseTitle }):Play()
                TweenService:Create(cardStroke, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.5 }):Play()
                TweenService:Create(glowBehind, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = glowBase - 0.06 }):Play()
                task.wait(speed)
                TweenService:Create(title, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = titleColor }):Play()
                TweenService:Create(cardStroke, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.15 }):Play()
                TweenService:Create(glowBehind, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = glowBase }):Play()
                task.wait(speed)
            end
        end)

        local baseSize = UDim2.new(0, CARD_W, 0, CARD_H)
        cardBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(cardBg, TweenInfo.new(0.15), {
                    Size = UDim2.new(0, CARD_W + 5, 0, CARD_H + 3),
                    Position = UDim2.new(0.5, -(CARD_W + 5) / 2, 0, -1.5), BackgroundTransparency = 0,
                }):Play()
                TweenService:Create(cardStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(255, 255, 255), Transparency = 0 }):Play()
                if hint.Text ~= "" then TweenService:Create(hint, TweenInfo.new(0.15), { TextTransparency = 0 }):Play() end
            end
        end)
        cardBg.MouseLeave:Connect(function()
            TweenService:Create(cardBg, TweenInfo.new(0.15), { Size = baseSize, Position = UDim2.new(0.5, -CARD_W / 2, 0, 0), BackgroundTransparency = 0.04 }):Play()
            TweenService:Create(cardStroke, TweenInfo.new(0.15), { Color = strokeColor, Transparency = 0.15 }):Play()
            TweenService:Create(hint, TweenInfo.new(0.15), { TextTransparency = 1 }):Play()
        end)
        cardBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not isSelf and Config.NametagClickTeleport then teleportTo(plr) end
            end
        end)

        return { billboard = billboard, cardBg = cardBg, cardStroke = cardStroke, title = title, userLabel = userLabel, extraLabel = extraLabel, hint = hint, glowBehind = glowBehind }
    end

    local function removeTag(plr)
        local data = tagCache[plr]
        if data and data.billboard then pcall(function() data.billboard:Destroy() end) end
        tagCache[plr] = nil
    end

    local function shouldTag(plr)
        if Config.NametagOnlyScriptUsers then
            if plr == LP then return true end
            return isScriptUser(plr)
        end
        return true
    end

    local function refreshAll()
        for plr in pairs(tagCache) do
            if not plr.Parent or not plr.Character or not shouldTag(plr) then removeTag(plr) end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if shouldTag(plr) then
                local char = plr.Character
                local head = char and char:FindFirstChild("Head")
                if head and not head:FindFirstChild("Sherlock_Tag") then
                    local data = buildTag(plr, char)
                    if data then tagCache[plr] = data end
                end
            end
        end
    end

    local function hookPlayer(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            local head = char:WaitForChild("Head", 6)
            if head and Config.Nametags and shouldTag(plr) then
                local data = buildTag(plr, char)
                if data then tagCache[plr] = data end
            end
        end)
        plr.CharacterRemoving:Connect(function() removeTag(plr) end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
    Players.PlayerAdded:Connect(hookPlayer)
    Players.PlayerRemoving:Connect(function(plr) removeTag(plr) end)

    task.spawn(function()
        while tagGui.Parent do
            task.wait(1.2)
            if Config.Nametags then refreshAll()
            else for plr in pairs(tagCache) do removeTag(plr) end end
        end
    end)

    Nametags.refresh      = refreshAll
    Nametags.removeAll    = function() for plr in pairs(tagCache) do removeTag(plr) end end
    Nametags.isScriptUser = isScriptUser

    local function markSelf()
        local char = LP.Character
        if not char then return end
        if not char:FindFirstChild(SCRIPT_MARKER_NAME) then
            local marker = Instance.new("BoolValue")
            marker.Name = SCRIPT_MARKER_NAME
            pcall(function() marker.Parent = char end)
        end
    end
    LP.CharacterAdded:Connect(function() task.wait(0.4) markSelf() end)
    task.spawn(function()
        while tagGui.Parent do markSelf() task.wait(2.5) end
    end)

    task.spawn(function()
        while tagGui.Parent do
            if LP.Character and LP.Character:FindFirstChild("Head")
               and not LP.Character.Head:FindFirstChild("Sherlock_Tag") and Config.Nametags then
                local data = buildTag(LP, LP.Character)
                if data then tagCache[LP] = data end
            end
            task.wait(1.0)
        end
    end)
end

-- ============================================================
-- SKY CHANGER
-- ============================================================
do
    local overlay = new("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Config.SkyTop,
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
    }, skyGui)
    local skyGrad = new("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(0.6, 0.85),
            NumberSequenceKeypoint.new(1, 0.95),
        }),
    }, overlay)

    local starHolder = new("Frame", { Size = UDim2.new(1, 0, 0.7, 0), BackgroundTransparency = 1, Visible = false }, overlay)
    local stars = {}
    for i = 1, 80 do
        stars[i] = new("Frame", {
            Size = UDim2.fromOffset(1 + math.random() * 1, 1 + math.random() * 1),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.2 + math.random() * 0.5,
            BorderSizePixel = 0,
        }, starHolder)
    end

    local sun = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(70, 70),
        Position = UDim2.new(0.78, 0, 0.2, 0), BackgroundColor3 = Color3.fromRGB(255, 230, 150),
        BackgroundTransparency = 0.35, BorderSizePixel = 0, Visible = false,
    }, overlay)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, sun)
    local sunGlow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(170, 170),
        Position = UDim2.fromScale(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 220, 120),
        BackgroundTransparency = 0.85, BorderSizePixel = 0,
    }, sun)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, sunGlow)

    local orig = {
        Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
        FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    }
    local applied = false
    local t = 0

    RunService.RenderStepped:Connect(function(dt)
        t = t + dt
        overlay.Visible = Config.SkyEnabled
        starHolder.Visible = Config.SkyEnabled and Config.SkyStars
        sun.Visible = Config.SkyEnabled and Config.SkySun

        if not Config.SkyEnabled then
            if applied then
                pcall(function()
                    Lighting.Ambient = orig.Ambient
                    Lighting.OutdoorAmbient = orig.OutdoorAmbient
                    Lighting.FogColor = orig.FogColor
                    Lighting.FogEnd = orig.FogEnd
                    Lighting.FogStart = orig.FogStart
                    Lighting.Brightness = orig.Brightness
                    Lighting.ClockTime = orig.ClockTime
                end)
                applied = false
            end
            return
        end

        local top, bottom = Config.SkyTop, Config.SkyBottom
        if Config.SkyRainbow then
            local h1 = (t * Config.SkyRainbowSpeed) % 1
            local h2 = (h1 + 0.15) % 1
            top = Color3.fromHSV(h1, 0.7, 0.9)
            bottom = Color3.fromHSV(h2, 0.8, 0.35)
        end

        overlay.BackgroundColor3 = top
        skyGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, top),
            ColorSequenceKeypoint.new(1, bottom),
        })

        pcall(function()
            Lighting.Ambient = bottom:Lerp(Color3.fromRGB(80, 80, 80), 0.3)
            Lighting.OutdoorAmbient = top:Lerp(Color3.fromRGB(120, 120, 120), 0.35)
            Lighting.FogColor = bottom
            Lighting.FogEnd = 400
            Lighting.FogStart = 100
            Lighting.Brightness = Config.SkyBrightness
            Lighting.ClockTime = Config.SkyClockTime
        end)
        applied = true

        if Config.SkyStars then
            local phase = math.floor(t * 6) % 8
            for i = 2, 80, 8 do
                if (i + phase) % 8 == 0 then
                    local s = stars[i]
                    if s then s.BackgroundTransparency = 0.2 + math.sin(t * 3 + i) * 0.3 end
                end
            end
        end
    end)
end

-- ============================================================
-- CROSSHAIR
-- ============================================================
local Crosshair = {}
do
    local holder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(140, 140),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1, Visible = false, ZIndex = 4,
    }, hudGui)
    local star = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
    }, holder)

    local lines = {}
    local function clearLines()
        for _, l in ipairs(lines) do pcall(function() l:Destroy() end) end
        lines = {}
    end

    local function drawLine(x1, y1, x2, y2, thickness, color, glow)
        local dx, dy = x2 - x1, y2 - y1
        local length = math.sqrt(dx * dx + dy * dy)
        local mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        local line = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(length, thickness),
            Position = UDim2.fromOffset(mx + 70, my + 70),
            Rotation = math.deg(math.atan2(dy, dx)),
            BackgroundColor3 = color, BorderSizePixel = 0,
        }, star)
        if glow then
            new("UIStroke", { Color = color, Thickness = 2, Transparency = 0.72 }, line)
        end
        return line
    end

    function Crosshair.rebuild()
        clearLines()
        local S = Config.CrosshairSize
        local T = Config.CrosshairThickness
        local c = Config.CrosshairColor
        local g = Config.CrosshairGlow
        local ax, ay = 0, -S
        local bx, by = S * 0.866, S * 0.5
        local cx, cy = -S * 0.866, S * 0.5
        local dx_, dy_ = 0, S
        local ex, ey = S * 0.866, -S * 0.5
        local fx, fy = -S * 0.866, -S * 0.5
        lines[1] = drawLine(ax, ay, bx, by, T, c, g)
        lines[2] = drawLine(bx, by, cx, cy, T, c, g)
        lines[3] = drawLine(cx, cy, ax, ay, T, c, g)
        lines[4] = drawLine(dx_, dy_, ex, ey, T, c, g)
        lines[5] = drawLine(ex, ey, fx, fy, T, c, g)
        lines[6] = drawLine(fx, fy, dx_, dy_, T, c, g)
    end
    Crosshair.rebuild()

    local spinT, hueT = 0, 0
    RunService.RenderStepped:Connect(function(dt)
        holder.Visible = Config.CrosshairEnabled
        if not Config.CrosshairEnabled then return end
        if Config.CrosshairSpin then
            spinT = (spinT + dt * Config.CrosshairSpinSpeed * 60) % 360
            star.Rotation = spinT
        end
        local c = Config.CrosshairColor
        if Config.CrosshairRainbow then
            hueT = (hueT + dt * Config.CrosshairRainbowSpeed) % 1
            c = Color3.fromHSV(hueT, 0.9, 1)
        end
        for _, l in ipairs(lines) do
            l.BackgroundColor3 = c
            local st = l:FindFirstChildOfClass("UIStroke")
            if st then st.Color = c end
        end
    end)
end

-- ============================================================
-- HUD (fov + lock)
-- ============================================================
local fovFrame = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(Config.AimFOV * 2, Config.AimFOV * 2), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 3 }, hudGui)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, fovFrame)
local fovStroke = new("UIStroke", { Color = Config.AimFovColor, Thickness = 1.2, Transparency = 0.3 }, fovFrame)
local lockHighlight = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(64, 64), BackgroundTransparency = 1, Visible = false, ZIndex = 6 }, hudGui)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, lockHighlight)
new("UIStroke", { Color = Color3.fromRGB(255, 80, 80), Thickness = 2 }, lockHighlight)

local function refreshFov()
    fovFrame.Visible = Config.AimShowFOV and Config.AimEnabled
    fovFrame.Size = UDim2.fromOffset(Config.AimFOV * 2, Config.AimFOV * 2)
    fovStroke.Color = Config.AimFovColor
    local c = fovFrame:FindFirstChildOfClass("UICorner")
    if c then c.CornerRadius = Config.AimFovStyle == "Circle" and UDim.new(1, 0) or UDim.new(0, 0) end
end

-- ============================================================
-- MENU BUILD
-- ============================================================
local W, H = 660, 460
local BASE_POS = UDim2.new(0.5, -W / 2, 0.5, -H / 2)

local main = new("Frame", { Name = "Sherlock", Size = UDim2.fromOffset(W, H), Position = BASE_POS, BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false }, menuGui)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
local mainStroke = new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, main)
local scale = new("UIScale", { Scale = 1 }, main)

local menuOverlay = new("Frame", {
    Name = "MenuOverlay", Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, Visible = false, ZIndex = 0,
}, menuGui)

local TOP_H = 26
local topBar = new("Frame", { Size = UDim2.new(1, 0, 0, TOP_H), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0 }, main)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, topBar)
new("Frame", { Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0 }, topBar)

new("TextLabel", { Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1, Text = "sherlock  [beta]  |  developed by sky", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, topBar)
local topDate = new("TextLabel", { Size = UDim2.new(0, 180, 1, 0), Position = UDim2.new(1, -190, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextDim, Font = FONT, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right }, topBar)
task.spawn(function()
    while topDate.Parent do
        pcall(function() topDate.Text = os.date("%A, %d %B %Y") end)
        task.wait(60)
    end
end)

local SIDE_W = 132
local side = new("Frame", { Size = UDim2.new(0, SIDE_W, 1, -(TOP_H + 16)), Position = UDim2.new(0, 8, 0, TOP_H + 8), BackgroundColor3 = Theme.BgSide, BorderSizePixel = 0 }, main)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, side)

local CONTENT_X = SIDE_W + 16
local content = new("Frame", { Size = UDim2.new(1, -(CONTENT_X + 8), 1, -(TOP_H + 16)), Position = UDim2.new(0, CONTENT_X, 0, TOP_H + 8), BackgroundColor3 = Theme.BgContent, BorderSizePixel = 0 }, main)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, content)

do
    local logoBox = new("Frame", { Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0, 10, 1, -82), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0 }, side)
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, logoBox)
    new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, logoBox)
    buildLogo(logoBox, 56, Theme.Accent)
    new("TextLabel", { Size = UDim2.new(1, -18, 0, 18), Position = UDim2.new(0, 10, 1, -22), BackgroundTransparency = 1, Text = "sherlock", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }, side)
end

local SIDE_TABS = { "aimbot", "visuals", "misc", "config", "settings" }
local sideBtns = {}
local contentPages = {}
for i = 1, #SIDE_TABS do
    contentPages[i] = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }, content)
end

local function selectSideTab(i)
    for k, b in ipairs(sideBtns) do
        local on = (k == i)
        TweenService:Create(b.bg, TweenInfo.new(0.15), { BackgroundColor3 = on and Theme.BgRow or Theme.BgSide }):Play()
        b.lbl.TextColor3 = on and Theme.Accent or Theme.TextNormal
        b.bar.Visible = on
    end
    for k, p in ipairs(contentPages) do p.Visible = (k == i) end
end

for i, name in ipairs(SIDE_TABS) do
    local bg = new("TextButton", { Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 10 + (i - 1) * 32), BackgroundColor3 = Theme.BgSide, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, side)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, bg)
    local bar = new("Frame", { Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false }, bg)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
    local lbl = new("TextLabel", { Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, bg)
    bg.MouseButton1Click:Connect(function() selectSideTab(i) end)
    sideBtns[i] = { bg = bg, lbl = lbl, bar = bar }
end

local function makeSubTab(pageIdx, subs, onSelect)
    local page = contentPages[pageIdx]
    local SUB_H = 22
    local strip = new("Frame", { Size = UDim2.new(1, -16, 0, SUB_H), Position = UDim2.new(0, 8, 0, 8), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0 }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, strip)
    local holder = new("Frame", { Size = UDim2.new(1, -16, 1, -(SUB_H + 16)), Position = UDim2.new(0, 8, 0, SUB_H + 14), BackgroundTransparency = 1 }, page)

    local subPages = {}
    for i = 1, #subs do
        subPages[i] = new("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.TextDim,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
        }, holder)
    end
    local subBtns = {}
    local function selectSub(i)
        for k, b in ipairs(subBtns) do
            local on = (k == i)
            TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = on and Theme.Accent or Theme.BgTop }):Play()
            b.TextColor3 = on and Theme.Bg or Theme.TextNormal
        end
        for k, p in ipairs(subPages) do p.Visible = (k == i) end
        if onSelect then pcall(onSelect, i) end
    end
    for i, name in ipairs(subs) do
        local b = new("TextButton", {
            Size = UDim2.new(1 / #subs, -(#subs - 1) * 2 / #subs, 1, -4),
            Position = UDim2.new((i - 1) / #subs, 2, 0, 2),
            BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0, Text = name,
            TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 11, AutoButtonColor = false,
        }, strip)
        new("UICorner", { CornerRadius = UDim.new(0, 4) }, b)
        b.MouseButton1Click:Connect(function() selectSub(i) end)
        subBtns[i] = b
    end
    selectSub(1)
    return subPages
end

local ROW_H, ROW_GAP, PAD = 26, 5, 10
local SECTION_H, SLIDER_H = 22, 40

local function styleRow(row)
    row.MouseEnter:Connect(function()
        if row:GetAttribute("noHover") then return end
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Theme.BgRowHover }):Play()
    end)
    row.MouseLeave:Connect(function()
        if row:GetAttribute("noHover") then return end
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Theme.BgRow }):Play()
    end)
end

local toggleRefs = {}

local function makeSection(parent, title, y)
    local row = new("Frame", { Size = UDim2.new(1, -PAD * 2, 0, SECTION_H), Position = UDim2.new(0, PAD, 0, y), BackgroundTransparency = 1 }, parent)
    new("TextLabel", { Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1, Text = string.upper(title), TextColor3 = Theme.TextDim, Font = FONT, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, row)
    new("Frame", { Size = UDim2.new(1, -132, 0, 1), Position = UDim2.new(0, 128, 0.5, 0), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.4, BorderSizePixel = 0 }, row)
    return SECTION_H
end

local function makeToggle(parent, label, key, y)
    local row = new("TextButton", { Size = UDim2.new(1, -PAD * 2, 0, ROW_H), Position = UDim2.new(0, PAD, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
    local box = new("Frame", { Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 10, 0.5, -6), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0 }, row)
    new("UICorner", { CornerRadius = UDim.new(0, 2) }, box)
    local boxStroke = new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, box)
    local check = new("Frame", { Size = UDim2.fromOffset(6, 6), Position = UDim2.new(0.5, -3, 0.5, -3), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Visible = false }, box)
    new("UICorner", { CornerRadius = UDim.new(0, 1) }, check)
    new("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, row)

    local function refresh()
        local on = Config[key]
        boxStroke.Color = on and Theme.Accent or Theme.Stroke
        check.BackgroundColor3 = Theme.Accent
        check.Visible = on
    end
    row.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        refresh()
        if key == "Nametags" then
            if Config.Nametags then Nametags.refresh() else Nametags.removeAll() end
        elseif key == "NametagClickTeleport" or key == "NametagOnlyScriptUsers" then
            Nametags.removeAll()
            task.wait(0.1)
            Nametags.refresh()
        end
    end)
    styleRow(row) refresh()
    toggleRefs[key] = refresh
    return ROW_H + ROW_GAP
end

local function makeSlider(parent, label, key, min, max, step, fmt, y, onChange)
    local row = new("Frame", { Size = UDim2.new(1, -PAD * 2, 0, SLIDER_H), Position = UDim2.new(0, PAD, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
    new("TextLabel", { Size = UDim2.new(1, -80, 0, 14), Position = UDim2.new(0, 10, 0, 3), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local valBox = new("Frame", { Size = UDim2.fromOffset(56, 14), Position = UDim2.new(1, -66, 0, 3), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0 }, row)
    new("UICorner", { CornerRadius = UDim.new(0, 3) }, valBox)
    local valLbl = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 11 }, valBox)

    local track = new("Frame", { Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 0, 26), BackgroundColor3 = Theme.BgTrack, BorderSizePixel = 0 }, row)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 }, track)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
    local thumb = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.TextPrimary, BorderSizePixel = 0 }, track)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, thumb)

    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * rel
        local v = math.floor(raw / step + 0.5) * step
        v = math.clamp(v, min, max)
        Config[key] = v
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = fmt(v)
        if onChange then onChange(v) end
    end
    do
        local rel = (Config[key] - min) / (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, 0, 0.5, 0)
        valLbl.Text = fmt(Config[key])
    end
    local dragging = false
    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true setFromX(input.Position.X)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then setFromX(input.Position.X) end
    end)
    return SLIDER_H + ROW_GAP
end

local function makeCycle(parent, label, key, values, fmt, y, onChange)
    local row = new("TextButton", { Size = UDim2.new(1, -PAD * 2, 0, ROW_H), Position = UDim2.new(0, PAD, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
    new("TextLabel", { Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local valBox = new("Frame", { Size = UDim2.fromOffset(100, 16), Position = UDim2.new(1, -108, 0.5, -8), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0 }, row)
    new("UICorner", { CornerRadius = UDim.new(0, 3) }, valBox)
    local value = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 11 }, valBox)

    local idx = 1
    for i, v in ipairs(values) do if v == Config[key] then idx = i break end end
    local function refresh() value.Text = fmt(values[idx]) Config[key] = values[idx] if onChange then onChange(values[idx]) end end
    row.MouseButton1Click:Connect(function() idx = idx % #values + 1 refresh() end)
    styleRow(row) refresh()
    return ROW_H + ROW_GAP
end

local rebindCallbacks = {}
local function makeRebind(parent, label, key, y)
    local row = new("TextButton", { Size = UDim2.new(1, -PAD * 2, 0, ROW_H), Position = UDim2.new(0, PAD, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
    new("TextLabel", { Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, row)
    local valBox = new("Frame", { Size = UDim2.fromOffset(100, 16), Position = UDim2.new(1, -108, 0.5, -8), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0 }, row)
    new("UICorner", { CornerRadius = UDim.new(0, 3) }, valBox)
    local keyLbl = new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Text = (Config[key] and Config[key].Name) or "—",
        TextColor3 = (Config[key] and Theme.TextPrimary) or Theme.TextDim,
        Font = FONT, TextSize = 11,
    }, valBox)

    local listening = false
    row.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        keyLbl.TextColor3 = Color3.fromRGB(255, 180, 60)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Config[key] = input.KeyCode
                keyLbl.Text = input.KeyCode.Name
                keyLbl.TextColor3 = Theme.TextPrimary
                listening = false
                conn:Disconnect()
            end
        end)
    end)
    styleRow(row)
    rebindCallbacks[key] = function()
        if Config[key] then
            keyLbl.Text = Config[key].Name
            keyLbl.TextColor3 = Theme.TextPrimary
        else
            keyLbl.Text = "—"
            keyLbl.TextColor3 = Theme.TextDim
        end
    end
    return ROW_H + ROW_GAP
end

-- ============================================================
-- COLOR PICKER
-- ============================================================
local function makeColorWheel(parent, label, key, y, onChange)
    local ROW_H_PICKER = 128
    local row = new("Frame", { Size = UDim2.new(1, -PAD * 2, 0, ROW_H_PICKER), Position = UDim2.new(0, PAD, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
    new("TextLabel", { Size = UDim2.new(1, -100, 0, 16), Position = UDim2.new(0, 10, 0, 6), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, row)

    local swatchRow = new("Frame", { Size = UDim2.fromOffset(64, 16), Position = UDim2.new(1, -74, 0, 6), BackgroundTransparency = 1 }, row)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, swatchRow)

    local function applyColor(c)
        Config[key] = c
        if onChange then onChange(c) end
    end

    for _, col in ipairs({ Color3.fromRGB(255,255,255), Color3.fromRGB(150,150,150), Color3.fromRGB(0,0,0) }) do
        local s = new("TextButton", { Size = UDim2.fromOffset(18, 16), BackgroundColor3 = col, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, swatchRow)
        new("UICorner", { CornerRadius = UDim.new(0, 3) }, s)
        new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, s)
        s.MouseButton1Click:Connect(function() applyColor(col) end)
    end

    local barBg = new("Frame", { Size = UDim2.fromOffset(22, 84), Position = UDim2.new(0, 14, 0, 32), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true }, row)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, barBg)
    new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, barBg)

    local bwFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, barBg)
    new("UIGradient", { Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
    }) }, bwFill)

    local hueOverlay = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Config[key], BackgroundTransparency = 0.25, BorderSizePixel = 0 }, barBg)

    local handle = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 8, 0, 3), Position = UDim2.new(0.5, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, ZIndex = 5 }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, handle)
    new("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1 }, handle)

    local DISC = 84
    local R = DISC / 2
    local wheel = new("Frame", { Size = UDim2.fromOffset(DISC, DISC), Position = UDim2.new(1, -DISC - 14, 0, 32), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true }, row)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, wheel)
    new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, wheel)

    local N = 72
    for i = 0, N - 1 do
        local hue = i / N
        local angleDeg = i * (360 / N)
        local angleRad = math.rad(angleDeg)
        local midX = R + math.cos(angleRad) * (R * 0.5)
        local midY = R + math.sin(angleRad) * (R * 0.5)
        local slice = Instance.new("Frame")
        slice.AnchorPoint = Vector2.new(0.5, 0.5)
        slice.Position = UDim2.fromOffset(midX, midY)
        slice.Size = UDim2.fromOffset(R + 4, 7)
        slice.BackgroundColor3 = Color3.new(1, 1, 1)
        slice.BorderSizePixel = 0
        slice.ZIndex = 1
        slice.Rotation = angleDeg
        slice.Parent = wheel
        local grad = Instance.new("UIGradient")
        grad.Rotation = 0
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
        })
        grad.Parent = slice
    end

    local marker = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Config[key], BorderSizePixel = 0, ZIndex = 6 }, wheel)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, marker)
    new("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5 }, marker)

    local function updateAll()
        local h, s, v = getHSV(Config[key])
        local ang = h * math.pi * 2
        local rr = s * R * 0.88
        marker.Position = UDim2.fromOffset(R + math.cos(ang) * rr, R + math.sin(ang) * rr)
        marker.BackgroundColor3 = Config[key]
        handle.Position = UDim2.new(0.5, 0, 1 - v, 0)
        hueOverlay.BackgroundColor3 = Color3.fromHSV(h, s, math.max(v, 0.35))
    end
    updateAll()

    local function setWheelFromScreen(mx, my)
        local ccx = wheel.AbsolutePosition.X + R
        local ccy = wheel.AbsolutePosition.Y + R
        local dx = mx - ccx
        local dy = my - ccy
        local dist = math.sqrt(dx * dx + dy * dy)
        local clampedDist = math.min(dist, R * 0.98)
        local hue = ((math.atan2(dy, dx) / (math.pi * 2)) + 1) % 1
        local sat = math.clamp(clampedDist / R, 0, 1)
        local _, _, v = getHSV(Config[key])
        local c = Color3.fromHSV(hue, sat, math.max(v, 0.5))
        Config[key] = c
        updateAll()
        if onChange then onChange(c) end
    end

    local wheelActive = false
    wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            wheelActive = true
            setWheelFromScreen(input.Position.X, input.Position.Y)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then wheelActive = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not wheelActive then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            setWheelFromScreen(input.Position.X, input.Position.Y)
        end
    end)

    local function setBarFromScreen(my)
        local rel = math.clamp((my - barBg.AbsolutePosition.Y) / barBg.AbsoluteSize.Y, 0, 1)
        local v = math.max(1 - rel, 0.02)
        local h, s, _ = getHSV(Config[key])
        Config[key] = Color3.fromHSV(h, s, v)
        updateAll()
        if onChange then onChange(Config[key]) end
    end

    local barActive = false
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            barActive = true
            setBarFromScreen(input.Position.Y)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then barActive = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not barActive then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            setBarFromScreen(input.Position.Y)
        end
    end)

    return ROW_H_PICKER + ROW_GAP
end

-- ============================================================
-- CONFIG SAVE / LOAD + SHARE
-- ============================================================
local CONFIG_DIR = "Sherlock_Configs"

local function ensureFs()
    if not writefile or not isfolder or not makefolder then return false end
    pcall(function() if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end end)
    return true
end

local function sanitizeName(n)
    n = tostring(n or ""):gsub("[^%w_%-%. ]", ""):gsub("%s+", "_")
    if n == "" then n = "unnamed" end
    return n
end

local function randomChunk(len)
    local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    local out = {}
    for i = 1, len do
        local idx = math.random(1, #chars)
        out[i] = chars:sub(idx, idx)
    end
    return table.concat(out)
end

local function generateShareId()
    return "Sherlock-" .. randomChunk(6) .. "-" .. randomChunk(6)
end

local function filePath(name) return CONFIG_DIR .. "/" .. sanitizeName(name) .. ".json" end

local function saveNamedConfig(name)
    if not ensureFs() then return false end
    name = sanitizeName(name)
    local payload = compactSerialize()
    local ok = pcall(function() writefile(filePath(name), payload) end)
    return ok, name
end

local function loadNamedConfig(name)
    if not ensureFs() then return false end
    local path = filePath(name)
    if not isfile or not isfile(path) then return false end
    local raw
    local ok = pcall(function() raw = readfile(path) end)
    if not ok or not raw then return false end
    compactDeserialize(raw)
    for _, r in pairs(toggleRefs) do pcall(r) end
    for _, cb in pairs(rebindCallbacks) do pcall(cb) end
    return true
end

local function listNamedConfigs()
    if not ensureFs() or not listfiles then return {} end
    local out = {}
    pcall(function()
        for _, f in ipairs(listfiles(CONFIG_DIR)) do
            local name = f:match("([^/\\]+)%.json$")
            if name then table.insert(out, name) end
        end
    end)
    return out
end

local function deleteNamedConfig(name)
    if not ensureFs() or not delfile then return false end
    return pcall(function() delfile(filePath(name)) end)
end

-- share string: Sherlock-xxx-yyy:<base64 of "name|payload">
local function makeShareString(name)
    name = sanitizeName(name)
    local payload
    local path = filePath(name)
    if isfile and isfile(path) then
        pcall(function() payload = readfile(path) end)
    end
    if not payload then payload = compactSerialize() end
    local combined = name .. "|" .. payload
    return generateShareId() .. ":" .. b64encode(combined)
end

-- returns ok, name on success
local function importShareString(s)
    if type(s) ~= "string" then return false end
    s = s:gsub("%s+", "")
    local id, b64 = s:match("^(Sherlock%-[%w]+%-[%w]+):(.+)$")
    if not id or not b64 then return false end
    local decoded
    local ok = pcall(function() decoded = b64decode(b64) end)
    if not ok or not decoded then return false end
    local name, payload = decoded:match("^([^|]+)|(.+)$")
    if not name or not payload then return false end
    name = sanitizeName(name)
    if ensureFs() then
        pcall(function() writefile(filePath(name), payload) end)
    end
    compactDeserialize(payload)
    for _, r in pairs(toggleRefs) do pcall(r) end
    for _, cb in pairs(rebindCallbacks) do pcall(cb) end
    return true, name
end

local function setClipboardSafe(s)
    if setclipboard then
        pcall(function() setclipboard(s) end)
        return true
    end
    return false
end

-- ============================================================
-- PREVIEW
-- ============================================================
local function buildPreview(parentFrame)
    local box = new("Frame", {
        Name = "Preview", Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 14),
        BorderSizePixel = 0, ZIndex = 100, ClipsDescendants = true,
    }, parentFrame)
    new("UICorner", { CornerRadius = UDim.new(0, 8) }, box)
    new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, box)

    local header = new("Frame", { Size = UDim2.new(1, -16, 0, 18), Position = UDim2.new(0, 8, 0, 6), BackgroundTransparency = 1, ZIndex = 102 }, box)
    local liveDot = new("Frame", { Size = UDim2.fromOffset(6, 6), Position = UDim2.new(0, 2, 0.5, -3), BackgroundColor3 = Color3.fromRGB(255, 60, 60), BorderSizePixel = 0, ZIndex = 103 }, header)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, liveDot)
    new("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 14, 0, 0), BackgroundTransparency = 1, Text = "PREVIEW  ·  LIVE", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103 }, header)
    task.spawn(function()
        while box.Parent do
            TweenService:Create(liveDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.75 }):Play()
            task.wait(0.6)
            TweenService:Create(liveDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play()
            task.wait(0.6)
        end
    end)

    local nameLbl = new("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 0, 26),
        BackgroundTransparency = 1, Text = (LP.DisplayName or LP.Name) .. "  ·  @" .. LP.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 10,
        TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 103,
    }, box)

    local chipsRow = new("Frame", { Size = UDim2.new(1, -16, 0, 14), Position = UDim2.new(0, 10, 0, 42), BackgroundTransparency = 1, ZIndex = 103 }, box)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, chipsRow)
    local function chip(color)
        local c = new("Frame", { Size = UDim2.fromOffset(52, 14), BackgroundColor3 = color, BackgroundTransparency = 0.85, BorderSizePixel = 0 }, chipsRow)
        new("UICorner", { CornerRadius = UDim.new(0, 3) }, c)
        new("UIStroke", { Color = color, Thickness = 1, Transparency = 0.5 }, c)
        return new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", TextColor3 = color, Font = FONT, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center }, c)
    end
    local chipHP  = chip(Color3.fromRGB(80, 220, 140))
    local chipWS  = chip(Color3.fromRGB(120, 180, 255))
    local chipFPS = chip(Color3.fromRGB(255, 190, 100))

    local sceneFrame = new("Frame", {
        Size = UDim2.new(1, -16, 0, 262), Position = UDim2.new(0, 8, 0, 62),
        BackgroundColor3 = Color3.fromRGB(14, 14, 20),
        BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 101,
    }, box)
    new("UICorner", { CornerRadius = UDim.new(0, 6) }, sceneFrame)
    new("UIStroke", { Color = Theme.Stroke, Thickness = 1, Transparency = 0.5 }, sceneFrame)

    local sky = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Config.SkyTop, BorderSizePixel = 0, ZIndex = 1 }, sceneFrame)
    local skyGrad = new("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Config.SkyTop),
            ColorSequenceKeypoint.new(1, Config.SkyBottom),
        }),
    }, sky)

    local starLayer = new("Frame", { Size = UDim2.new(1, 0, 0.6, 0), BackgroundTransparency = 1, Visible = false, ZIndex = 2 }, sceneFrame)
    for i = 1, 24 do
        new("Frame", {
            Size = UDim2.fromOffset(1, 1),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.3 + math.random() * 0.5,
            BorderSizePixel = 0, ZIndex = 2,
        }, starLayer)
    end

    local previewSun = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(0.82, 0, 0.18, 0), BackgroundColor3 = Color3.fromRGB(255, 230, 150),
        BackgroundTransparency = 0.25, BorderSizePixel = 0, Visible = false, ZIndex = 2,
    }, sceneFrame)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, previewSun)

    new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.72, 0), BackgroundColor3 = Color3.fromRGB(120, 140, 190), BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 3 }, sceneFrame)

    local floorHolder = new("Frame", { Size = UDim2.new(1, 0, 0.28, 0), Position = UDim2.new(0, 0, 0.72, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3 }, sceneFrame)
    for i = 0, 10 do
        local t = i / 10
        new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, t * t, 0), BackgroundColor3 = Color3.fromRGB(90, 110, 160), BackgroundTransparency = 0.72 - t * 0.3, BorderSizePixel = 0, ZIndex = 3 }, floorHolder)
    end
    for i = -7, 7 do
        local t = i / 7
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5 + t * 0.9, 0, 0, 0), Rotation = -t * 26, BackgroundColor3 = Color3.fromRGB(90, 110, 160), BackgroundTransparency = 0.75, BorderSizePixel = 0, ZIndex = 3 }, floorHolder)
    end

    for _, x in ipairs({ -0.12, 0.3, 0.7, 1.08 }) do
        new("Frame", { Size = UDim2.new(0, 5, 0, 44), Position = UDim2.new(x, 0, 0.72, -44), BackgroundColor3 = Color3.fromRGB(60, 70, 100), BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 3 }, sceneFrame)
    end

    local charmHalo = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(120, 120),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Config.CharmFillColor, BackgroundTransparency = 0.85,
        BorderSizePixel = 0, Visible = false, ZIndex = 4,
    }, sceneFrame)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, charmHalo)

    local avatarBox = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(120, 150),
        Position = UDim2.new(0.5, 0, 0.72, 6),
        BackgroundTransparency = 1, ZIndex = 5,
    }, sceneFrame)

    new("ImageLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Image = avatarThumb(LP.UserId, "AvatarBust"),
        ScaleType = Enum.ScaleType.Fit,
        ImageTransparency = 0, ZIndex = 5,
    }, avatarBox)

    local shadow = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(80, 8),
        Position = UDim2.new(0.5, 0, 0.72, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.55,
        BorderSizePixel = 0, ZIndex = 4,
    }, sceneFrame)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, shadow)

    local rigTag = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(108, 24),
        Position = UDim2.new(0.5, 0, 0.72, -150),
        BackgroundColor3 = Color3.fromRGB(14, 16, 22),
        BackgroundTransparency = 0.08, BorderSizePixel = 0, ZIndex = 9,
    }, sceneFrame)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, rigTag)
    new("UIStroke", { Color = Color3.fromRGB(70, 100, 160), Thickness = 1, Transparency = 0.15 }, rigTag)
    new("TextLabel", { Size = UDim2.new(1, -8, 0, 11), Position = UDim2.new(0, 6, 0, 2), BackgroundTransparency = 1, Text = "PLAYER", TextColor3 = Color3.fromRGB(150, 180, 220), Font = FONT_TAG, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10 }, rigTag)
    new("TextLabel", { Size = UDim2.new(1, -8, 0, 10), Position = UDim2.new(0, 6, 0, 13), BackgroundTransparency = 1, Text = LP.Name, TextColor3 = Color3.fromRGB(220, 225, 235), Font = Enum.Font.GothamSemibold, TextSize = 8, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10 }, rigTag)

    local brackets = {}
    local function mkBracket(x, y, hx, vy)
        local h = new("Frame", { Size = UDim2.fromOffset(16, 2), Position = UDim2.new(0.5, x, 0.5, y), AnchorPoint = Vector2.new(hx > 0 and 0 or 1, 0.5), BackgroundColor3 = Config.BoxColor, BorderSizePixel = 0, Visible = false, ZIndex = 11 }, sceneFrame)
        local v = new("Frame", { Size = UDim2.fromOffset(2, 16), Position = UDim2.new(0.5, x, 0.5, y), AnchorPoint = Vector2.new(0.5, vy > 0 and 0 or 1), BackgroundColor3 = Config.BoxColor, BorderSizePixel = 0, Visible = false, ZIndex = 11 }, sceneFrame)
        return { h = h, v = v }
    end
    brackets[1] = mkBracket(-56, -78, -1, -1)
    brackets[2] = mkBracket( 56, -78,  1, -1)
    brackets[3] = mkBracket(-56,  78, -1,  1)
    brackets[4] = mkBracket( 56,  78,  1,  1)

    local hpBar = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(4, 156), Position = UDim2.new(0.5, -70, 0.5, 78), BackgroundColor3 = Color3.fromRGB(30, 30, 34), BackgroundTransparency = 0.3, BorderSizePixel = 0, Visible = false, ZIndex = 11 }, sceneFrame)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, hpBar)
    local hpFill = new("Frame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Config.HealthColor, BorderSizePixel = 0, ZIndex = 12 }, hpBar)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, hpFill)

    local headDot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), Position = UDim2.new(0.5, 0, 0.5, -78), BackgroundColor3 = Config.HeadDotColor, BorderSizePixel = 0, Visible = false, ZIndex = 12 }, sceneFrame)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, headDot)

    local tracer = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 1, 0, 78), Position = UDim2.new(0.5, 0, 0.5, 78), BackgroundColor3 = Config.TracerColor, BackgroundTransparency = 0.4, BorderSizePixel = 0, Visible = false, ZIndex = 11 }, sceneFrame)

    local sceneStatus = new("TextLabel", {
        Size = UDim2.new(1, -16, 0, 12), Position = UDim2.new(0, 8, 1, -16),
        BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(180, 200, 230),
        Font = FONT, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12,
    }, sceneFrame)

    local crossHolder = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(60, 60),
        Position = UDim2.new(0.5, 0, 0.5, 78), BackgroundTransparency = 1, Visible = false, ZIndex = 12,
    }, sceneFrame)
    local crossStar = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1 }, crossHolder)
    local crossLines = {}
    local function drawCross()
        for _, l in ipairs(crossLines) do pcall(function() l:Destroy() end) end
        crossLines = {}
        local S, T = 18, 1.5
        local c = Config.CrosshairColor
        local pts = {
            { 0, -S, S * 0.866, S * 0.5 }, { S * 0.866, S * 0.5, -S * 0.866, S * 0.5 }, { -S * 0.866, S * 0.5, 0, -S },
            { 0, S, S * 0.866, -S * 0.5 }, { S * 0.866, -S * 0.5, -S * 0.866, -S * 0.5 }, { -S * 0.866, -S * 0.5, 0, S },
        }
        for _, p in ipairs(pts) do
            local x1, y1, x2, y2 = p[1], p[2], p[3], p[4]
            local dx, dy = x2 - x1, y2 - y1
            local length = math.sqrt(dx * dx + dy * dy)
            local mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            local line = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(length, T),
                Position = UDim2.fromOffset(mx + 30, my + 30),
                Rotation = math.deg(math.atan2(dy, dx)),
                BackgroundColor3 = c, BorderSizePixel = 0,
            }, crossStar)
            table.insert(crossLines, line)
        end
    end
    drawCross()

    local bobPhase, breathePhase = 0, 0
    local crossSpin, crossHue = 0, 0

    task.spawn(function()
        while box.Parent do
            bobPhase = bobPhase + 0.06
            breathePhase = breathePhase + 0.09
            local bob = math.sin(bobPhase) * 2

            local top, bottom = Config.SkyTop, Config.SkyBottom
            if Config.SkyRainbow then
                local h1 = (tick() * Config.SkyRainbowSpeed) % 1
                local h2 = (h1 + 0.15) % 1
                top = Color3.fromHSV(h1, 0.7, 0.9)
                bottom = Color3.fromHSV(h2, 0.8, 0.35)
            end
            sky.BackgroundColor3 = top
            skyGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, top),
                ColorSequenceKeypoint.new(1, bottom),
            })
            starLayer.Visible = Config.SkyStars
            previewSun.Visible = Config.SkySun

            avatarBox.Position = UDim2.new(0.5, 0, 0.72, 6 + bob)
            avatarBox.Rotation = math.sin(breathePhase * 0.5) * 1.5
            shadow.Size = UDim2.fromOffset(80 - math.abs(bob) * 2, 8)
            rigTag.Position = UDim2.new(0.5, 0, 0.72, -150 + bob)

            for _, br in ipairs(brackets) do
                br.h.BackgroundColor3 = Config.BoxColor
                br.v.BackgroundColor3 = Config.BoxColor
                br.h.Visible = Config.Box
                br.v.Visible = Config.Box
            end
            hpBar.Visible = Config.Health
            hpBar.Position = UDim2.new(0.5, -70, 0.5, 78 + bob)
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            local hp = 100
            if hum and hum.MaxHealth > 0 then hp = math.floor(hum.Health / hum.MaxHealth * 100) end
            hpFill.Size = UDim2.new(1, 0, hp / 100, 0)
            hpFill.BackgroundColor3 = Config.HealthColor:Lerp(Color3.fromRGB(255, 60, 60), 1 - hp / 100)

            headDot.Visible = Config.HeadDot
            headDot.Position = UDim2.new(0.5, 0, 0.5, -78 + bob)
            headDot.BackgroundColor3 = Config.HeadDotColor

            tracer.Visible = Config.Tracers
            tracer.BackgroundColor3 = Config.TracerColor
            tracer.Position = UDim2.new(0.5, 0, 0.5, 78 + bob)
            tracer.Size = UDim2.new(0, Config.TracerThickness, 0, 78)

            charmHalo.Visible = Config.Charm
            charmHalo.BackgroundColor3 = Config.CharmFillColor
            charmHalo.BackgroundTransparency = 1 - Config.CharmFill * 0.6
            charmHalo.Size = UDim2.fromOffset(120 + bob, 120 + bob)
            charmHalo.Position = UDim2.new(0.5, 0, 0.5, bob)

            crossHolder.Visible = Config.CrosshairEnabled
            if Config.CrosshairEnabled then
                crossHolder.Position = UDim2.new(0.5, 0, 0.5, 78 + bob)
                if Config.CrosshairSpin then
                    crossSpin = (crossSpin + 0.016 * Config.CrosshairSpinSpeed * 60) % 360
                    crossStar.Rotation = crossSpin
                end
                local c = Config.CrosshairColor
                if Config.CrosshairRainbow then
                    crossHue = (crossHue + 0.016 * Config.CrosshairRainbowSpeed) % 1
                    c = Color3.fromHSV(crossHue, 0.9, 1)
                end
                for _, l in ipairs(crossLines) do l.BackgroundColor3 = c end
            end

            local ws = hum and math.floor(hum.WalkSpeed) or 16
            chipHP.Text = "hp " .. hp
            chipWS.Text = "ws " .. ws
            chipFPS.Text = "fps " .. math.floor(60 + math.sin(bobPhase * 0.3) * 4)

            local parts = {}
            if Config.Box then table.insert(parts, "box") end
            if Config.Name then table.insert(parts, "name") end
            if Config.Health then table.insert(parts, "hp") end
            if Config.Tracers then table.insert(parts, "tracers") end
            if Config.Charm then table.insert(parts, "charm") end
            if Config.AimEnabled then table.insert(parts, "aim") end
            if Config.SkyEnabled then table.insert(parts, "sky") end
            if Config.CrosshairEnabled then table.insert(parts, "crosshair") end
            if #parts == 0 then
                sceneStatus.Text = "— idle —"
                sceneStatus.TextColor3 = Color3.fromRGB(120, 130, 150)
            else
                sceneStatus.Text = table.concat(parts, " · ")
                sceneStatus.TextColor3 = Color3.fromRGB(140, 220, 180)
            end

            task.wait(0.05)
        end
    end)

    return box
end

-- ============================================================
-- PAGES
-- ============================================================
-- AIMBOT with LegitBot header
pcall(function()
    local subs = makeSubTab(1, { "LegitBot", "RageBot", "Spin" })
    local y = 4
    y = y + makeSection(subs[1], "aimbot", y)
    y = y + makeToggle(subs[1], "enabled",           "AimEnabled", y)
    y = y + makeToggle(subs[1], "show fov",          "AimShowFOV", y)
    y = y + makeToggle(subs[1], "visible only",      "AimVisible", y)
    y = y + makeToggle(subs[1], "team check",        "AimTeamCheck", y)
    y = y + makeToggle(subs[1], "sticky target",     "AimSticky", y)
    y = y + makeToggle(subs[1], "lock highlight",    "AimLockVisual", y)
    y = y + makeCycle (subs[1], "mode", "AimMode", { "Camera", "Silent", "Both" }, tostring, y)
    y = y + makeCycle (subs[1], "target part", "AimPart", { "Head", "HumanoidRootPart", "Nearest", "Random" }, tostring, y)
    y = y + makeCycle (subs[1], "fov style", "AimFovStyle", { "Circle", "Square" }, tostring, y, refreshFov)
    y = y + makeRebind(subs[1], "aim key", "AimKey", y)

    local y2 = 4
    y2 = y2 + makeSection(subs[2], "accuracy", y2)
    y2 = y2 + makeSlider(subs[2], "field of view", "AimFOV", 30, 400, 5, function(v) return tostring(v) end, y2, refreshFov)
    y2 = y2 + makeSlider(subs[2], "smooth", "AimSmooth", 0.02, 1.0, 0.02, function(v) return string.format("%.2f", v) end, y2)
    y2 = y2 + makeSlider(subs[2], "max range", "AimMaxDist", 100, 2000, 50, function(v) return tostring(v) end, y2)
    y2 = y2 + makeSlider(subs[2], "hitchance", "AimHitChance", 0, 100, 5, function(v) return v .. "%" end, y2)
    y2 = y2 + makeToggle(subs[2], "prediction", "AimPredictionEnabled", y2)
    y2 = y2 + makeSlider(subs[2], "prediction amount", "AimPrediction", 0.0, 0.5, 0.005, function(v) return string.format("%.3f", v) end, y2)
    y2 = y2 + makeToggle(subs[2], "resolver", "AimResolver", y2)

    local y3 = 4
    y3 = y3 + makeSection(subs[3], "spinbot", y3)
    y3 = y3 + makeToggle(subs[3], "enabled",   "SpinEnabled", y3)
    y3 = y3 + makeCycle (subs[3], "axis", "SpinAxis", { "Y", "XYZ", "Random" }, tostring, y3)
    y3 = y3 + makeSlider(subs[3], "speed", "SpinSpeed", 1, 60, 1, function(v) return v .. "/s" end, y3)
    y3 = y3 + makeRebind(subs[3], "toggle key", "SpinKey", y3)
end)

-- VISUALS
pcall(function()
    local previewLayer
    local subs = makeSubTab(2, { "main", "esp", "colors" }, function(i)
        if previewLayer then previewLayer.Visible = (i == 1) end
    end)
    for _, sub in ipairs(subs) do
        sub.Size = UDim2.new(1, -240, 1, 0)
    end

    previewLayer = new("Frame", {
        Name = "PreviewLayer", Size = UDim2.new(0, 226, 1, 0),
        Position = UDim2.new(1, -236, 0, 0), BackgroundTransparency = 1, ZIndex = 99, Visible = true,
    }, contentPages[2])
    buildPreview(previewLayer)

    local y = 4
    y = y + makeSection(subs[1], "esp toggles", y)
    y = y + makeToggle(subs[1], "esp master",    "Enabled", y)
    y = y + makeToggle(subs[1], "box esp",       "Box", y)
    y = y + makeToggle(subs[1], "name",          "Name", y)
    y = y + makeToggle(subs[1], "distance",      "Distance", y)
    y = y + makeToggle(subs[1], "health bar",    "Health", y)
    y = y + makeToggle(subs[1], "box fill",      "Fill", y)
    y = y + makeToggle(subs[1], "tracker lines", "Tracers", y)
    y = y + makeToggle(subs[1], "team check",    "TeamCheck", y)
    y = y + makeToggle(subs[1], "head dot",      "HeadDot", y)
    y = y + makeToggle(subs[1], "charm",         "Charm", y)
    y = y + 8
    y = y + makeSection(subs[1], "nametags", y)
    y = y + makeToggle(subs[1], "nametags enabled",  "Nametags", y)
    y = y + makeToggle(subs[1], "click teleport",    "NametagClickTeleport", y)
    y = y + makeToggle(subs[1], "only script users", "NametagOnlyScriptUsers", y)
    y = y + 8
    y = y + makeSection(subs[1], "misc", y)
    y = y + makeToggle(subs[1], "hide ads", "HideAds", y)

    local y2 = 4
    y2 = y2 + makeSection(subs[2], "options", y2)
    y2 = y2 + makeCycle (subs[2], "tracer origin", "TracerOrigin", { "Bottom", "Center", "Mouse" }, tostring, y2)
    y2 = y2 + makeCycle (subs[2], "health side", "HealthBarSide", { "Left", "Right" }, tostring, y2)
    y2 = y2 + makeCycle (subs[2], "distance unit", "DistanceUnit", { "m", "studs", "none" }, tostring, y2)
    y2 = y2 + makeCycle (subs[2], "max distance", "MaxDistance", { 250, 500, 1000, 1500, 2500, 5000 }, function(v) return v >= 1000 and string.format("%dk", v / 1000) or tostring(v) end, y2)
    y2 = y2 + makeSlider(subs[2], "tracer thickness", "TracerThickness", 1, 5, 0.5, function(v) return string.format("%.1f", v) end, y2)
    y2 = y2 + makeSlider(subs[2], "charm fill", "CharmFill", 0, 1, 0.05, function(v) return string.format("%.2f", v) end, y2)
    y2 = y2 + makeToggle(subs[2], "charm outline", "CharmOutline", y2)

    local y3 = 4
    y3 = y3 + makeSection(subs[3], "rainbow", y3)
    y3 = y3 + makeToggle(subs[3], "menu rainbow",  "RainbowMenu", y3)
    y3 = y3 + makeSlider(subs[3], "menu speed",    "RainbowMenuSpeed",  0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y3)
    y3 = y3 + makeToggle(subs[3], "esp rainbow",   "RainbowESP", y3)
    y3 = y3 + makeSlider(subs[3], "esp speed",     "RainbowESPSpeed",   0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y3)
    y3 = y3 + makeToggle(subs[3], "charm rainbow", "RainbowCharm", y3)
    y3 = y3 + makeSlider(subs[3], "charm speed",   "RainbowCharmSpeed", 0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y3)
    y3 = y3 + makeToggle(subs[3], "tag rainbow",   "RainbowTag", y3)
    y3 = y3 + makeSlider(subs[3], "tag speed",     "RainbowTagSpeed",   0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y3)

    y3 = y3 + 8
    y3 = y3 + makeSection(subs[3], "esp colors", y3)
    y3 = y3 + makeColorWheel(subs[3], "box color",    "BoxColor", y3, function(c)
        for _, d in pairs(espCache) do d.stroke.Color = c end
    end)
    y3 = y3 + makeColorWheel(subs[3], "tracer color", "TracerColor", y3, function(c)
        for _, d in pairs(espCache) do d.tracer.BackgroundColor3 = c end
    end)
    y3 = y3 + makeColorWheel(subs[3], "name color",   "NameColor", y3, function(c)
        for _, d in pairs(espCache) do d.name.TextColor3 = c end
    end)
    y3 = y3 + makeColorWheel(subs[3], "health color", "HealthColor", y3, function(c)
        for _, d in pairs(espCache) do d.hpFill.BackgroundColor3 = c end
    end)
    y3 = y3 + makeColorWheel(subs[3], "charm fill",   "CharmFillColor", y3)
    y3 = y3 + makeColorWheel(subs[3], "charm outline","CharmOutlineColor", y3)
end)

-- MISC
pcall(function()
    local subs = makeSubTab(3, { "speed", "fly", "camera", "sky", "crosshair" })

    local y = 4
    y = y + makeSection(subs[1], "speed", y)
    y = y + makeToggle(subs[1], "speed enabled",  "SpeedEnabled", y)
    y = y + makeToggle(subs[1], "restore on off", "SpeedRestore", y)
    y = y + makeSlider(subs[1], "walk speed", "WalkSpeed", 16, 500, 1, function(v) return tostring(v) end, y)
    y = y + makeSlider(subs[1], "jump power", "JumpPower", 50, 500, 5, function(v) return tostring(v) end, y)
    y = y + makeRebind(subs[1], "speed key", "SpeedKey", y)

    local yb = 4
    yb = yb + makeSection(subs[2], "fly", yb)
    yb = yb + makeToggle(subs[2], "fly enabled", "FlyEnabled", yb)
    yb = yb + makeToggle(subs[2], "vertical fly", "FlyVertical", yb)
    yb = yb + makeToggle(subs[2], "superman pose", "SupermanPose", yb)
    yb = yb + makeCycle (subs[2], "fly animation", "FlyMode", { "Classic", "Boost", "Hover" }, tostring, yb)
    yb = yb + makeSlider(subs[2], "fly speed", "FlySpeed", 10, 300, 5, function(v) return tostring(v) end, yb)
    yb = yb + makeSlider(subs[2], "anim intensity", "FlyAnimSpeed", 0.2, 3, 0.1, function(v) return string.format("%.1f", v) end, yb)
    yb = yb + makeSlider(subs[2], "superman tilt", "SupermanTilt", 30, 90, 5, function(v) return v .. "°" end, yb)
    yb = yb + makeRebind(subs[2], "fly key", "FlyKey", yb)

    local yc = 4
    yc = yc + makeSection(subs[3], "third person", yc)
    yc = yc + makeToggle(subs[3], "enabled",         "ThirdPerson", yc)
    yc = yc + makeToggle(subs[3], "mouse control",   "TP_MouseControl", yc)
    yc = yc + makeSlider(subs[3], "distance", "TP_Distance", 3, 30, 1, function(v) return tostring(v) end, yc)
    yc = yc + makeSlider(subs[3], "height",   "TP_Height", -5, 10, 0.5, function(v) return string.format("%.1f", v) end, yc)
    yc = yc + makeSlider(subs[3], "shoulder", "TP_Shoulder", -5, 5, 0.5, function(v) return string.format("%.1f", v) end, yc)

    local ys = 4
    ys = ys + makeSection(subs[4], "sky changer", ys)
    ys = ys + makeToggle(subs[4], "sky enabled",   "SkyEnabled", ys)
    ys = ys + makeToggle(subs[4], "stars",         "SkyStars", ys)
    ys = ys + makeToggle(subs[4], "sun",           "SkySun", ys)
    ys = ys + makeToggle(subs[4], "rainbow sky",   "SkyRainbow", ys)
    ys = ys + makeSlider(subs[4], "rainbow speed", "SkyRainbowSpeed", 0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, ys)
    ys = ys + makeSlider(subs[4], "brightness",    "SkyBrightness", 0, 5, 0.1, function(v) return string.format("%.1f", v) end, ys)
    ys = ys + makeSlider(subs[4], "clock time",    "SkyClockTime", 0, 24, 0.5, function(v) return string.format("%.1f", v) end, ys)
    ys = ys + makeColorWheel(subs[4], "sky top",    "SkyTop", ys)
    ys = ys + makeColorWheel(subs[4], "sky bottom", "SkyBottom", ys)

    local yx = 4
    yx = yx + makeSection(subs[5], "crosshair", yx)
    yx = yx + makeToggle(subs[5], "enabled",        "CrosshairEnabled", yx)
    yx = yx + makeToggle(subs[5], "spin",           "CrosshairSpin", yx)
    yx = yx + makeToggle(subs[5], "rainbow",        "CrosshairRainbow", yx)
    yx = yx + makeToggle(subs[5], "glow",           "CrosshairGlow", yx)
    yx = yx + makeSlider(subs[5], "size", "CrosshairSize", 8, 48, 1, function(v) return tostring(v) end, yx, Crosshair.rebuild)
    yx = yx + makeSlider(subs[5], "thickness", "CrosshairThickness", 1, 6, 0.5, function(v) return string.format("%.1f", v) end, yx, Crosshair.rebuild)
    yx = yx + makeSlider(subs[5], "spin speed", "CrosshairSpinSpeed", 0.1, 4, 0.1, function(v) return string.format("%.1f", v) end, yx)
    yx = yx + makeSlider(subs[5], "rainbow speed", "CrosshairRainbowSpeed", 0.05, 1.5, 0.05, function(v) return string.format("%.2f", v) end, yx)
    yx = yx + makeColorWheel(subs[5], "crosshair color", "CrosshairColor", yx)
end)

-- CONFIG
local rebuildCfgList
pcall(function()
    local page = contentPages[4]
    local y = 8

    new("TextLabel", { Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "save config", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 20

    local nameBox = new("Frame", { Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, nameBox)
    local nameInput = new("TextBox", {
        Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = "default",
        PlaceholderText = "config name",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, nameBox)
    local saveBtn = new("TextButton", { Size = UDim2.fromOffset(72, 22), Position = UDim2.new(1, -78, 0.5, -11), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Text = "save", TextColor3 = Theme.Bg, Font = FONT, TextSize = 12, AutoButtonColor = false }, nameBox)
    new("UICorner", { CornerRadius = UDim.new(0, 3) }, saveBtn)
    y = y + 34

    local statusLbl = new("TextLabel", { Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "", TextColor3 = Theme.TextDim, Font = FONT, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 22

    new("TextLabel", { Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "import / paste share", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 20

    local shareBox = new("Frame", { Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, shareBox)
    local shareInput = new("TextBox", {
        Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Sherlock-xxx-yyy:...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
    }, shareBox)
    local importBtn = new("TextButton", { Size = UDim2.fromOffset(72, 22), Position = UDim2.new(1, -78, 0.5, -11), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Text = "import", TextColor3 = Theme.Bg, Font = FONT, TextSize = 12, AutoButtonColor = false }, shareBox)
    new("UICorner", { CornerRadius = UDim.new(0, 3) }, importBtn)
    y = y + 36

    new("TextLabel", { Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "your configs", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 20

    local cfgListStart = y

    rebuildCfgList = function()
        for _, c in ipairs(page:GetChildren()) do
            if c:GetAttribute("cfgRow") then c:Destroy() end
        end
        local configs = listNamedConfigs()
        if #configs == 0 then
            local empty = new("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, cfgListStart),
                BackgroundTransparency = 1, Text = "no configs saved yet",
                TextColor3 = Theme.TextDim, Font = FONT, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, page)
            empty:SetAttribute("cfgRow", true)
            return
        end
        for i, name in ipairs(configs) do
            local row = new("Frame", { Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, cfgListStart + (i - 1) * 30), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, page)
            row:SetAttribute("cfgRow", true)
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
            new("TextLabel", { Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, row)
            local loadB = new("TextButton", { Size = UDim2.fromOffset(46, 18), Position = UDim2.new(1, -152, 0.5, -9), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0, Text = "load", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 10, AutoButtonColor = false }, row)
            new("UICorner", { CornerRadius = UDim.new(0, 3) }, loadB)
            local shareB = new("TextButton", { Size = UDim2.fromOffset(46, 18), Position = UDim2.new(1, -102, 0.5, -9), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0, Text = "share", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 10, AutoButtonColor = false }, row)
            new("UICorner", { CornerRadius = UDim.new(0, 3) }, shareB)
            local delB = new("TextButton", { Size = UDim2.fromOffset(38, 18), Position = UDim2.new(1, -52, 0.5, -9), BackgroundColor3 = Color3.fromRGB(60, 25, 30), BorderSizePixel = 0, Text = "del", TextColor3 = Color3.fromRGB(255, 130, 130), Font = FONT, TextSize = 10, AutoButtonColor = false }, row)
            new("UICorner", { CornerRadius = UDim.new(0, 3) }, delB)

            loadB.MouseButton1Click:Connect(function()
                if loadNamedConfig(name) then
                    statusLbl.Text = "loaded: " .. name
                    statusLbl.TextColor3 = Color3.fromRGB(140, 220, 180)
                else
                    statusLbl.Text = "load failed"
                    statusLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
                end
            end)
            shareB.MouseButton1Click:Connect(function()
                local s = makeShareString(name)
                if setClipboardSafe(s) then
                    statusLbl.Text = "share id copied: " .. s:match("^(Sherlock%-[%w]+%-[%w]+)") 
                    statusLbl.TextColor3 = Color3.fromRGB(140, 220, 180)
                else
                    shareInput.Text = s
                    statusLbl.Text = "share id in box above — copy it"
                    statusLbl.TextColor3 = Color3.fromRGB(255, 200, 120)
                end
            end)
            delB.MouseButton1Click:Connect(function()
                deleteNamedConfig(name)
                rebuildCfgList()
            end)
        end
    end

    saveBtn.MouseButton1Click:Connect(function()
        local ok, nm = saveNamedConfig(nameInput.Text)
        if ok then
            statusLbl.Text = "saved: " .. nm
            statusLbl.TextColor3 = Color3.fromRGB(140, 220, 180)
            rebuildCfgList()
        else
            statusLbl.Text = "save failed"
            statusLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
    end)

    importBtn.MouseButton1Click:Connect(function()
        local s = shareInput.Text or ""
        if s == "" then
            statusLbl.Text = "paste a share string first"
            statusLbl.TextColor3 = Color3.fromRGB(255, 200, 120)
            return
        end
        local ok, nm = importShareString(s)
        if ok then
            statusLbl.Text = "imported: " .. tostring(nm)
            statusLbl.TextColor3 = Color3.fromRGB(140, 220, 180)
            rebuildCfgList()
        else
            statusLbl.Text = "invalid share string"
            statusLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
    end)

    rebuildCfgList()
end)

-- SETTINGS
pcall(function()
    local page = contentPages[5]
    local y = 8
    new("TextLabel", { Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "themes", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 22

    local themeNames = { "default", "glass", "neon", "midnight" }
    local themeButtons = {}
    local function applyThemeByName(name)
        local newT = THEMES[name]
        if not newT then return end
        local old = {}
        for k, v in pairs(Theme) do old[k] = v end
        for k, v in pairs(newT) do Theme[k] = v end
        Config.ThemeName = name

        local function remap(o)
            if o:IsA("GuiObject") then
                local bg = o.BackgroundColor3
                for k, v in pairs(old) do
                    if typeof(v) == "Color3" and v == bg and newT[k] then
                        pcall(function() o.BackgroundColor3 = newT[k] end)
                        break
                    end
                end
            end
            if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
                local tc = o.TextColor3
                for k, v in pairs(old) do
                    if typeof(v) == "Color3" and v == tc and newT[k] then
                        pcall(function() o.TextColor3 = newT[k] end)
                        break
                    end
                end
            end
            if o:IsA("UIStroke") then
                local sc = o.Color
                for k, v in pairs(old) do
                    if typeof(v) == "Color3" and v == sc and newT[k] then
                        pcall(function() o.Color = newT[k] end)
                        break
                    end
                end
            end
        end

        remap(main)
        for _, d in ipairs(main:GetDescendants()) do remap(d) end
        main.BackgroundColor3 = Theme.Bg
        mainStroke.Color = Theme.Stroke

        for name2, btn in pairs(themeButtons) do
            local on = (name2 == name)
            btn.bg.BackgroundColor3 = on and Theme.Accent or Theme.BgRow
            btn.lbl.TextColor3 = on and Theme.Bg or Theme.TextNormal
            btn.stroke.Color = on and Theme.Accent or Theme.Stroke
        end
    end

    local PER_ROW = 2
    for i, name in ipairs(themeNames) do
        local col = (i - 1) % PER_ROW
        local row = math.floor((i - 1) / PER_ROW)
        local btn = new("TextButton", {
            Size = UDim2.new(1 / PER_ROW, -14 / PER_ROW, 0, 34),
            Position = UDim2.new(col / PER_ROW, 6, 0, y + row * 40),
            BackgroundColor3 = (name == Config.ThemeName) and Theme.Accent or Theme.BgRow,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        }, page)
        new("UICorner", { CornerRadius = UDim.new(0, 5) }, btn)
        local st = new("UIStroke", { Color = (name == Config.ThemeName) and Theme.Accent or Theme.Stroke, Thickness = 1 }, btn)
        local lbl = new("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Text = string.upper(name), TextColor3 = (name == Config.ThemeName) and Theme.Bg or Theme.TextNormal,
            Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Center,
        }, btn)
        btn.MouseButton1Click:Connect(function() applyThemeByName(name) end)
        themeButtons[name] = { bg = btn, lbl = lbl, stroke = st }
    end
    y = y + math.ceil(#themeNames / PER_ROW) * 40 + 8

    new("TextLabel", { Size = UDim2.new(1, -20, 0, 14), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "menu keybind", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 20

    local menuKeyRow = new("TextButton", { Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, menuKeyRow)
    new("TextLabel", { Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "menu toggle", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, menuKeyRow)
    local mkBox = new("Frame", { Size = UDim2.fromOffset(100, 16), Position = UDim2.new(1, -108, 0.5, -8), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0 }, menuKeyRow)
    new("UICorner", { CornerRadius = UDim.new(0, 3) }, mkBox)
    local mkLbl = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = (Config.MenuKey and Config.MenuKey.Name) or "—", TextColor3 = (Config.MenuKey and Theme.TextPrimary) or Theme.TextDim, Font = FONT, TextSize = 11 }, mkBox)
    local mkListening = false
    menuKeyRow.MouseButton1Click:Connect(function()
        if mkListening then return end
        mkListening = true
        mkLbl.Text = "..."
        mkLbl.TextColor3 = Color3.fromRGB(255, 180, 60)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Config.MenuKey = input.KeyCode
                mkLbl.Text = input.KeyCode.Name
                mkLbl.TextColor3 = Theme.TextPrimary
                mkListening = false
                conn:Disconnect()
            end
        end)
    end)
    styleRow(menuKeyRow)
    y = y + 34

    local clearAllBtn = new("TextButton", { Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, y), BackgroundColor3 = Color3.fromRGB(60, 25, 30), BorderSizePixel = 0, Text = "clear all feature keybinds", TextColor3 = Color3.fromRGB(255, 130, 130), Font = FONT, TextSize = 11, AutoButtonColor = false }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, clearAllBtn)
    clearAllBtn.MouseButton1Click:Connect(function()
        Config.AimKey = nil
        Config.SpinKey = nil
        Config.SpeedKey = nil
        Config.FlyKey = nil
        Config.EspKey = nil
        for _, cb in pairs(rebindCallbacks) do pcall(cb) end
    end)
end)

-- ============================================================
-- OPEN / CLOSE
-- ============================================================
local menuOpen = false
local fadeList = {}
do
    local function snap(o)
        if o:GetAttribute("noFade") then return end
        local e = { o = o }
        if o:IsA("GuiObject") then e.bg = o.BackgroundTransparency end
        if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then e.txt = o.TextTransparency e.stk = o.TextStrokeTransparency end
        if o:IsA("ImageLabel") or o:IsA("ImageButton") then e.img = o.ImageTransparency end
        if o:IsA("UIStroke") then e.str = o.Transparency end
        fadeList[#fadeList + 1] = e
    end
    snap(main)
    for _, d in ipairs(main:GetDescendants()) do snap(d) end
end

local menuAlpha = 1
local function applyFade(a)
    for _, e in ipairs(fadeList) do
        local o = e.o
        if e.bg  then o.BackgroundTransparency = e.bg  + (1 - e.bg)  * a end
        if e.txt then o.TextTransparency       = e.txt + (1 - e.txt) * a end
        if e.stk then o.TextStrokeTransparency = e.stk + (1 - e.stk) * a end
        if e.img then o.ImageTransparency      = e.img + (1 - e.img) * a end
        if e.str then o.Transparency           = e.str + (1 - e.str) * a end
    end
end

local fadeToken = 0
local function tweenAlpha(goal, dur, easeFn)
    fadeToken += 1
    local my = fadeToken
    local start = menuAlpha
    local t0 = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if my ~= fadeToken then conn:Disconnect() return end
        local a = math.clamp((os.clock() - t0) / dur, 0, 1)
        local e = easeFn and easeFn(a) or (1 - (1 - a) ^ 3)
        menuAlpha = start + (goal - start) * e
        applyFade(menuAlpha)
        if a >= 1 then conn:Disconnect() end
    end)
end

function openMenu()
    if menuOpen then return end
    menuOpen = true
    menuOverlay.Visible = true
    menuOverlay.BackgroundTransparency = 1
    TweenService:Create(menuOverlay, TweenInfo.new(0.4), { BackgroundTransparency = 0.55 }):Play()
    main.Visible = true
    menuAlpha = 1
    applyFade(1)
    scale.Scale = 0.5
    main.Rotation = -8
    main.Position = UDim2.new(BASE_POS.X.Scale, BASE_POS.X.Offset, BASE_POS.Y.Scale, BASE_POS.Y.Offset + 80)
    main.Size = UDim2.fromOffset(W, 40)
    TweenService:Create(main, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(W, H), Position = BASE_POS, Rotation = 0,
    }):Play()
    TweenService:Create(scale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    tweenAlpha(0, 0.55, function(a) return 1 - (1 - a) ^ 4 end)
end

function closeMenu()
    if not menuOpen then return end
    menuOpen = false
    TweenService:Create(menuOverlay, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
    task.delay(0.4, function() if not menuOpen then menuOverlay.Visible = false end end)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(W, 40),
        Position = UDim2.new(BASE_POS.X.Scale, BASE_POS.X.Offset, BASE_POS.Y.Scale, BASE_POS.Y.Offset + 60),
        Rotation = 6,
    }):Play()
    TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Scale = 0.6 }):Play()
    tweenAlpha(1, 0.3, function(a) return a * a end)
    task.delay(0.4, function()
        if not menuOpen then
            main.Visible = false
            main.Size = UDim2.fromOffset(W, H)
            main.Rotation = 0
            scale.Scale = 1
        end
    end)
end

do
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

selectSideTab(1)

local aimHeld = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local menuKey = Config.MenuKey or Enum.KeyCode.K
    if input.KeyCode == menuKey then
        if menuOpen then closeMenu() else openMenu() end
    elseif Config.EspKey and input.KeyCode == Config.EspKey then
        Config.Enabled = not Config.Enabled
        if toggleRefs.Enabled then toggleRefs.Enabled() end
    elseif Config.AimKey and input.KeyCode == Config.AimKey then
        aimHeld = true
    elseif Config.FlyKey and input.KeyCode == Config.FlyKey then
        Config.FlyEnabled = not Config.FlyEnabled
        if toggleRefs.FlyEnabled then toggleRefs.FlyEnabled() end
    elseif Config.SpinKey and input.KeyCode == Config.SpinKey then
        Config.SpinEnabled = not Config.SpinEnabled
        if toggleRefs.SpinEnabled then toggleRefs.SpinEnabled() end
    elseif Config.SpeedKey and input.KeyCode == Config.SpeedKey then
        Config.SpeedEnabled = not Config.SpeedEnabled
        if toggleRefs.SpeedEnabled then toggleRefs.SpeedEnabled() end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if Config.AimKey and input.KeyCode == Config.AimKey then aimHeld = false end
end)

task.spawn(function()
    while menuGui.Parent do
        task.wait(0.3)
        for _, cb in pairs(rebindCallbacks) do pcall(cb) end
    end
end)

local function rainbowColor(speed)
    return Color3.fromHSV((tick() * speed) % 1, 0.8, 1)
end
RunService.RenderStepped:Connect(function()
    if Config.RainbowMenu then
        local c = rainbowColor(Config.RainbowMenuSpeed)
        Theme.Accent = c
        for k, b in ipairs(sideBtns) do
            b.bar.BackgroundColor3 = c
            if b.bar.Visible then b.lbl.TextColor3 = c end
        end
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local function createHolder(player)
    local holder = new("Frame", { Name = player.Name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 2 }, espGui)
    local box = new("Frame", { Size = UDim2.new(), Position = UDim2.new(), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3 }, holder)
    local boxStroke = new("UIStroke", { Color = Config.BoxColor, Thickness = 1.4, Transparency = 0 }, box)
    local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Config.FillColor, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, box)
    local hpBg = new("Frame", { Size = UDim2.new(), Position = UDim2.new(), BackgroundColor3 = Color3.fromRGB(15, 15, 18), BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 3 }, holder)
    local hpFill = new("Frame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.fromScale(0, 1), AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Config.HealthColor, BorderSizePixel = 0, ZIndex = 4 }, hpBg)
    local nameLbl = new("TextLabel", { Size = UDim2.new(0, 200, 0, 14), AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Text = player.Name, TextColor3 = Config.NameColor, Font = Enum.Font.GothamSemibold, TextSize = 13, TextStrokeTransparency = 0.35, ZIndex = 5 }, holder)
    local distLbl = new("TextLabel", { Size = UDim2.new(0, 200, 0, 12), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Config.DistanceColor, Font = Enum.Font.Gotham, TextSize = 11, TextStrokeTransparency = 0.4, ZIndex = 5 }, holder)
    local headDot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Config.HeadDotColor, BorderSizePixel = 0, Visible = false, ZIndex = 6 }, holder)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, headDot)
    local tracer = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(), BackgroundColor3 = Config.TracerColor, BorderSizePixel = 0, ZIndex = 1 }, holder)
    new("UIGradient", { Rotation = 0, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.75), NumberSequenceKeypoint.new(1, 0.05) }) }, tracer)
    return { holder = holder, box = box, stroke = boxStroke, fill = fill, hpBg = hpBg, hpFill = hpFill, name = nameLbl, dist = distLbl, tracer = tracer, headDot = headDot }
end

local function screenBounds(char)
    local ok, cf, size = pcall(function() return char:GetBoundingBox() end)
    if not ok or not cf then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local half = size * 0.5
    for _, sx in ipairs({ -1, 1 }) do
        for _, sy in ipairs({ -1, 1 }) do
            for _, sz in ipairs({ -1, 1 }) do
                local world = cf * Vector3.new(half.X * sx, half.Y * sy, half.Z * sz)
                local sp = Camera:WorldToViewportPoint(world)
                if sp.Z <= 0 then return nil end
                minX = math.min(minX, sp.X); maxX = math.max(maxX, sp.X)
                minY = math.min(minY, sp.Y); maxY = math.max(maxY, sp.Y)
            end
        end
    end
    return minX, minY, maxX, maxY
end

local function drawTracer(frame, p1, p2, thickness)
    local dx, dy = p2.X - p1.X, p2.Y - p1.Y
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 1 then frame.Visible = false return end
    frame.Visible = true
    frame.Size = UDim2.new(0, length, 0, thickness)
    frame.Position = UDim2.new(0, (p1.X + p2.X) * 0.5, 0, (p1.Y + p2.Y) * 0.5)
    frame.Rotation = math.deg(math.atan2(dy, dx))
end

local function espQualifies(plr)
    if plr == LP then return false end
    if Config.TeamCheck and LP.Team and plr.Team == LP.Team then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function formatDistance(dist)
    if Config.DistanceUnit == "none" then return "" end
    if Config.DistanceUnit == "studs" then return string.format("%d studs", math.floor(dist + 0.5)) end
    return string.format("%d m", math.floor(dist + 0.5))
end

local function updateCharm(char)
    if not char then return end
    local hl = char:FindFirstChild("Sherlock_Highlight")
    if Config.Charm and not hl then
        hl = Instance.new("Highlight")
        hl.Name = "Sherlock_Highlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = char
        hl.Parent = char
    elseif not Config.Charm and hl then
        hl:Destroy()
        return
    end
    if hl then
        local useRainbow = Config.RainbowCharm or Config.RainbowESP
        local speed = Config.RainbowCharm and Config.RainbowCharmSpeed or Config.RainbowESPSpeed
        local fillC = useRainbow and rainbowColor(speed) or Config.CharmFillColor
        local outlC = useRainbow and rainbowColor(speed) or Config.CharmOutlineColor
        hl.FillColor = fillC
        hl.OutlineColor = outlC
        hl.FillTransparency = 1 - Config.CharmFill
        hl.OutlineTransparency = Config.CharmOutline and 0.15 or 1
    end
end

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end
    local vp = Camera.ViewportSize

    for plr, data in pairs(espCache) do
        if not plr.Parent then data.holder:Destroy() espCache[plr] = nil
        else data.holder.Visible = false end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then updateCharm(plr.Character) end
    end

    if not Config.Enabled then return end

    local espBox    = Config.RainbowESP and rainbowColor(Config.RainbowESPSpeed) or Config.BoxColor
    local espTracer = Config.RainbowESP and rainbowColor(Config.RainbowESPSpeed) or Config.TracerColor
    local espName   = Config.RainbowESP and rainbowColor(Config.RainbowESPSpeed) or Config.NameColor

    for _, plr in ipairs(Players:GetPlayers()) do
        if espQualifies(plr) then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            local dist = root and (root.Position - Camera.CFrame.Position).Magnitude or 0
            if dist <= Config.MaxDistance then
                local data = espCache[plr]
                if not data then data = createHolder(plr) espCache[plr] = data end
                local minX, minY, maxX, maxY = screenBounds(char)
                if minX then
                    local w, h = maxX - minX, maxY - minY
                    local cx = (minX + maxX) * 0.5
                    data.holder.Visible = true
                    data.box.Size = UDim2.fromOffset(w, h)
                    data.box.Position = UDim2.fromOffset(minX, minY)
                    data.stroke.Transparency = Config.Box and 0 or 1
                    data.stroke.Color = espBox
                    data.fill.BackgroundTransparency = Config.Fill and 0.82 or 1
                    data.fill.BackgroundColor3 = espBox
                    local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    data.hpBg.Visible = Config.Health
                    if Config.Health then
                        local hx = (Config.HealthBarSide == "Left") and (minX - 7) or (maxX + 4)
                        data.hpBg.Size = UDim2.fromOffset(3, h)
                        data.hpBg.Position = UDim2.fromOffset(hx, minY)
                        data.hpFill.Size = UDim2.new(1, 0, ratio, 0)
                        data.hpFill.BackgroundColor3 = Config.HealthColor:Lerp(Color3.fromRGB(255, 60, 60), 1 - ratio)
                    end
                    data.name.Visible = Config.Name
                    if Config.Name then
                        data.name.Text = plr.Name
                        data.name.TextColor3 = espName
                        data.name.Position = UDim2.fromOffset(cx, minY - 3)
                    end
                    data.dist.Visible = Config.Distance and Config.DistanceUnit ~= "none"
                    if data.dist.Visible then
                        data.dist.Text = formatDistance(dist)
                        data.dist.TextColor3 = Config.DistanceColor
                        data.dist.Position = UDim2.fromOffset(cx, maxY + 4)
                    end
                    data.headDot.Visible = Config.HeadDot
                    if Config.HeadDot then
                        local head = char:FindFirstChild("Head")
                        if head then
                            local hs = Camera:WorldToViewportPoint(head.Position)
                            if hs.Z > 0 then
                                data.headDot.Position = UDim2.fromOffset(hs.X, hs.Y)
                                data.headDot.BackgroundColor3 = Config.HeadDotColor
                            else data.headDot.Visible = false end
                        end
                    end
                    if Config.Tracers then
                        local origin
                        if Config.TracerOrigin == "Bottom" then origin = Vector2.new(vp.X * 0.5, vp.Y)
                        elseif Config.TracerOrigin == "Center" then origin = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
                        else origin = UserInputService:GetMouseLocation() end
                        data.tracer.BackgroundColor3 = espTracer
                        drawTracer(data.tracer, origin, Vector2.new(cx, maxY), Config.TracerThickness)
                    else
                        data.tracer.Visible = false
                    end
                else
                    data.holder.Visible = false
                end
            end
        end
    end
end)

-- ============================================================
-- AIMBOT
-- ============================================================
local aimParams = RaycastParams.new()
aimParams.FilterType = Enum.RaycastFilterType.Exclude
local stickyTarget = nil

local function refreshAimParams()
    local f = { LP.Character }
    if LP.Character then
        for _, d in ipairs(LP.Character:GetDescendants()) do table.insert(f, d) end
    end
    aimParams.FilterDescendantsInstances = f
end
local function predictPosition(part)
    if not Config.AimPredictionEnabled then return part.Position end
    return part.Position + (part.Velocity * Config.AimPrediction)
end
local function resolveVelocity(part)
    if not Config.AimResolver then return part.Velocity end
    local v = part.Velocity
    return Vector3.new(v.X, math.clamp(v.Y, -30, 30), v.Z)
end
local function getAimPart(char)
    if Config.AimPart == "Nearest" then
        local best, bestD = nil, math.huge
        local myPos = Camera.CFrame.Position
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local d = (part.Position - myPos).Magnitude
                if d < bestD then bestD = d best = part end
            end
        end
        return best
    elseif Config.AimPart == "Random" then
        local parts = {}
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then table.insert(parts, part) end
        end
        if #parts == 0 then return nil end
        return parts[math.random(1, #parts)]
    else
        return char:FindFirstChild(Config.AimPart)
    end
end
local function aimCandidate()
    if Config.AimSticky and stickyTarget then
        local char = stickyTarget.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = getAimPart(char)
                if part then
                    local sp = Camera:WorldToViewportPoint(part.Position)
                    if sp.Z > 0 then
                        local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
                        local sd = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if sd <= Config.AimFOV * 1.5 then return part, stickyTarget end
                    end
                end
            end
        end
        stickyTarget = nil
    end
    if math.random(1, 100) > Config.AimHitChance then return nil end
    local best, bestPlayer, bestScore = nil, nil, math.huge
    local myPos = Camera.CFrame.Position
    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    refreshAimParams()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local include = true
            if Config.AimTeamCheck and LP.Team and plr.Team == LP.Team then include = false end
            if include then
                local char = plr.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local targetPart = getAimPart(char)
                        if targetPart then
                            local predPos = predictPosition(targetPart)
                            local dist3 = (predPos - myPos).Magnitude
                            if dist3 <= Config.AimMaxDist then
                                local sp = Camera:WorldToViewportPoint(predPos)
                                if sp.Z > 0 then
                                    local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                    if screenDist <= Config.AimFOV then
                                        local visible = true
                                        if Config.AimVisible then
                                            local rp = workspace:Raycast(myPos, targetPart.Position - myPos, aimParams)
                                            if rp and not rp.Instance:IsDescendantOf(char) then visible = false end
                                        end
                                        if visible and screenDist < bestScore then
                                            bestScore = screenDist
                                            best = targetPart
                                            bestPlayer = plr
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if bestPlayer and Config.AimSticky then stickyTarget = bestPlayer end
    return best, bestPlayer
end

RunService.RenderStepped:Connect(function(dt)
    refreshFov()
    if not (Config.AimEnabled and aimHeld) then lockHighlight.Visible = false return end
    local part = aimCandidate()
    if not part then lockHighlight.Visible = false return end
    local vel = resolveVelocity(part)
    local basePos = part.Position + (vel * (Config.AimPredictionEnabled and Config.AimPrediction or 0))
    if Config.AimMode == "Camera" or Config.AimMode == "Both" then
        local alpha = 1 - math.pow(Config.AimSmooth, dt * 60)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, basePos), alpha)
    end
    if Config.AimLockVisual then
        local sp = Camera:WorldToViewportPoint(basePos)
        if sp.Z > 0 then
            lockHighlight.Visible = true
            lockHighlight.Position = UDim2.fromOffset(sp.X, sp.Y)
        else lockHighlight.Visible = false end
    else lockHighlight.Visible = false end
end)

-- ============================================================
-- SPINBOT
-- ============================================================
do
    local spinAngle = 0
    local attach, align
    local function cleanupSpin()
        if attach then attach:Destroy() attach = nil end
        if align then align:Destroy() align = nil end
        spinAngle = 0
    end
    local function attachSpin()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        cleanupSpin()
        attach = Instance.new("Attachment")
        attach.Name = "Sherlock_SpinAttach"
        attach.Parent = hrp
        align = Instance.new("AlignOrientation")
        align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        align.Attachment0 = attach
        align.MaxTorque = 1e6
        align.Responsiveness = 200
        align.PrimaryAxisOnly = false
        align.Parent = hrp
    end
    LP.CharacterAdded:Connect(function() cleanupSpin() end)
    RunService.RenderStepped:Connect(function(dt)
        if not Config.SpinEnabled then
            if attach or align then cleanupSpin() end
            return
        end
        spinAngle = spinAngle + dt * Config.SpinSpeed * math.pi * 2
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not align or not align.Parent then attachSpin() end
        if align and align.Parent and attach then
            attach.WorldPosition = hrp.Position
            local rot
            if Config.SpinAxis == "Y" then rot = CFrame.Angles(0, spinAngle, 0)
            elseif Config.SpinAxis == "XYZ" then rot = CFrame.Angles(spinAngle * 0.3, spinAngle, spinAngle * 0.15)
            else
                local rx, ry, rz = math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1
                local axis = Vector3.new(rx, ry, rz)
                if axis.Magnitude < 0.001 then axis = Vector3.yAxis end
                rot = CFrame.fromAxisAngle(axis.Unit, spinAngle)
            end
            align.CFrame = rot
        end
    end)
end

-- ============================================================
-- SPEED
-- ============================================================
do
    local originalWalk, originalJump = 16, 50
    local captured = false
    local function captureOriginals()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and not captured then
            originalWalk = hum.WalkSpeed
            originalJump = hum.JumpPower
            captured = true
        end
    end
    local function applySpeed()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        captureOriginals()
        if Config.SpeedEnabled then
            pcall(function() hum.WalkSpeed = Config.WalkSpeed end)
            pcall(function() hum.JumpPower = Config.JumpPower end)
            pcall(function() hum.UseJumpPower = true end)
        elseif Config.SpeedRestore and captured then
            pcall(function() hum.WalkSpeed = originalWalk end)
            pcall(function() hum.JumpPower = originalJump end)
        end
    end
    RunService.Heartbeat:Connect(function()
        if Config.SpeedEnabled then applySpeed() end
    end)
    LP.CharacterAdded:Connect(function()
        captured = false
        task.wait(0.5)
        captureOriginals()
        if Config.SpeedEnabled then applySpeed() end
    end)
end

-- ============================================================
-- THIRD PERSON
-- ============================================================
do
    local originalOffset, tpActive
    local function cleanupTP()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum and originalOffset then hum.CameraOffset = originalOffset end
        originalOffset = nil
        tpActive = false
    end
    LP.CharacterAdded:Connect(function() cleanupTP() end)
    RunService.RenderStepped:Connect(function()
        if not Config.ThirdPerson then
            if tpActive then cleanupTP() end
            return
        end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if not tpActive then originalOffset = hum.CameraOffset tpActive = true end
        hum.CameraOffset = Vector3.new(Config.TP_Shoulder, Config.TP_Height, Config.TP_Distance)
    end)
end

-- ============================================================
-- FLY
-- ============================================================
do
    local flyBV, flyBG
    local baseFov = 70
    local fovTarget = baseFov
    local modeTimer = 0
    local jointCache, rigType = nil, "R6"
    local poseAlpha = 0

    local R6_JOINTS = { "Right Shoulder", "Left Shoulder", "RightHip", "LeftHip" }
    local R15_JOINTS = { "RightUpperArm", "LeftUpperArm", "RightLowerArm", "LeftLowerArm", "RightHand", "LeftHand", "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg", "RightFoot", "LeftFoot", "Waist" }

    local function detectRig(char) return char:FindFirstChild("UpperTorso") and "R15" or "R6" end
    local function cacheJoints(char)
        if jointCache then return end
        rigType = detectRig(char)
        jointCache = {}
        local list = rigType == "R15" and R15_JOINTS or R6_JOINTS
        local searchRoots = {}
        for _, name in ipairs({ "Torso", "UpperTorso", "LowerTorso", "RightUpperArm", "LeftUpperArm", "RightUpperLeg", "LeftUpperLeg" }) do
            local part = char:FindFirstChild(name)
            if part then table.insert(searchRoots, part) end
        end
        for _, root in ipairs(searchRoots) do
            for _, name in ipairs(list) do
                local j = root:FindFirstChild(name)
                if j and j:IsA("Motor6D") and not jointCache[name] then
                    jointCache[name] = { joint = j, C0 = j.C0, C1 = j.C1 }
                end
            end
        end
    end
    local function restoreJoints()
        if not jointCache then return end
        for _, d in pairs(jointCache) do
            if d.joint and d.joint.Parent then d.joint.C0 = d.C0 d.joint.C1 = d.C1 end
        end
    end
    local function clearJoints() restoreJoints() jointCache = nil poseAlpha = 0 end
    local function getTargetCF(name, baseC0)
        if rigType == "R15" then
            if name == "RightUpperArm" then return baseC0 * CFrame.Angles(math.rad(-90), 0, math.rad(-10)) end
            if name == "LeftUpperArm" then return baseC0 * CFrame.Angles(math.rad(-90), 0, math.rad(10)) end
            if name == "RightUpperLeg" or name == "LeftUpperLeg" then return baseC0 * CFrame.Angles(math.rad(5), 0, 0) end
            if name == "Waist" then return baseC0 * CFrame.Angles(math.rad(-10), 0, 0) end
        else
            if name == "Right Shoulder" then return baseC0 * CFrame.Angles(math.rad(-95), 0, 0) * CFrame.Angles(0, 0, math.rad(-15)) end
            if name == "Left Shoulder" then return baseC0 * CFrame.Angles(math.rad(-95), 0, 0) * CFrame.Angles(0, 0, math.rad(15)) end
            if name == "RightHip" then return CFrame.new(0.4, -1, 0) end
            if name == "LeftHip" then return CFrame.new(-0.4, -1, 0) end
        end
        return baseC0
    end
    local function applySuperman(alpha)
        if not jointCache then return end
        for name, d in pairs(jointCache) do
            local j = d.joint
            if j and j.Parent then
                local target = getTargetCF(name, d.C0)
                if target then j.C0 = d.C0:Lerp(target, alpha) end
            end
        end
    end
    local function cleanup()
        clearJoints()
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = baseFov end
    end
    local function attach()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        cleanup()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBG.P = 1500 flyBG.D = 50
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
        cacheJoints(char)
    end
    local lastState = false
    RunService.Heartbeat:Connect(function(dt)
        if Config.FlyEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            if not flyBV or not flyBV.Parent then attach() end
            if not jointCache then cacheJoints(LP.Character) end
            local hrp = LP.Character.HumanoidRootPart
            local cam = workspace.CurrentCamera
            if not cam then return end
            if not lastState then baseFov = cam.FieldOfView end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if Config.FlyVertical then
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end
            end
            local intensity = Config.FlyAnimSpeed
            local speed = Config.FlySpeed
            modeTimer = modeTimer + dt
            local isMoving = move.Magnitude > 0.1
            local wantSuperman = Config.SupermanPose and not isMoving
            local targetAlpha = wantSuperman and 1 or 0
            poseAlpha = poseAlpha + (targetAlpha - poseAlpha) * math.clamp(dt * 6 * intensity, 0, 1)
            if jointCache then
                if Config.SupermanPose then applySuperman(poseAlpha) else restoreJoints() end
            end
            if Config.FlyMode == "Classic" then
                fovTarget = baseFov
                if move.Magnitude > 0 then move = move.Unit end
                flyBV.Velocity = move * speed
            elseif Config.FlyMode == "Boost" then
                local boosting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
                if boosting then speed = speed * 2 * intensity end
                fovTarget = baseFov + (move.Magnitude > 0.1 and (boosting and 14 or 6) * intensity or 0)
                if move.Magnitude > 0 then move = move.Unit end
                flyBV.Velocity = move * speed
            elseif Config.FlyMode == "Hover" then
                speed = speed * 0.6
                if move.Magnitude > 0 then move = move.Unit end
                local bob = math.sin(modeTimer * 2 * intensity) * 0.35 * intensity
                flyBV.Velocity = move * speed + Vector3.new(0, bob, 0)
                fovTarget = baseFov + 3 * intensity
            end
            local lookTarget = hrp.Position + cam.CFrame.LookVector
            local baseCF = CFrame.new(hrp.Position, lookTarget)
            if Config.SupermanPose and poseAlpha > 0.02 then
                baseCF = baseCF * CFrame.Angles(math.rad(-Config.SupermanTilt * poseAlpha), 0, 0)
            end
            if Config.FlyMode == "Hover" and not wantSuperman then
                baseCF = baseCF * CFrame.Angles(0, 0, math.sin(modeTimer * 1.5 * intensity) * math.rad(3 * intensity))
            end
            flyBG.CFrame = baseCF
            cam.FieldOfView = cam.FieldOfView + (fovTarget - cam.FieldOfView) * math.clamp(dt * 8, 0, 1)
            lastState = true
        elseif lastState then
            cleanup()
            lastState = false
        end
    end)
    LP.CharacterAdded:Connect(function() cleanup() end)
end

-- ============================================================
-- BOOT
-- ============================================================
task.wait(0.05)
Nametags.refresh()
pcall(openMenu)
print("[Sherlock] loaded — press K to toggle menu")
