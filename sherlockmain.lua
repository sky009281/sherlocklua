-- ============================================================
-- Sherlock BETA
-- language: Lua (Luau) | target: Roblox client (executor / LocalScript)
-- features: image-logo intro, sidebar menu, aimbot, esp (idf-standalone),
--           charm + charm-rainbow, superman fly pose, 3 fly modes,
--           grid HSV disc, config save/load, keybinds
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local FONT       = Enum.Font.Code
local FONT_TITLE = Enum.Font.SourceSansBold

local LOGO_ASSET_ID = "rbxassetid://0"

local Theme = {
    Accent      = Color3.fromRGB(140, 130, 255),
    Bg          = Color3.fromRGB(18, 18, 22),
    BgSide      = Color3.fromRGB(14, 14, 18),
    BgContent   = Color3.fromRGB(22, 22, 28),
    BgTop       = Color3.fromRGB(24, 24, 30),
    BgRow       = Color3.fromRGB(28, 28, 36),
    BgRowHover  = Color3.fromRGB(38, 38, 48),
    BgTrack     = Color3.fromRGB(50, 50, 62),
    Stroke      = Color3.fromRGB(45, 45, 58),
    TextPrimary = Color3.fromRGB(235, 235, 245),
    TextNormal  = Color3.fromRGB(200, 200, 215),
    TextDim     = Color3.fromRGB(120, 120, 140),
}

local Config = {
    Enabled = true,
    Box = true, Name = true, Distance = true, Health = true,
    Fill = false, Tracers = true, TeamCheck = false,
    MaxDistance = 1500, TracerOrigin = "Bottom",
    TracerThickness = 1,
    HealthBarSide = "Left", BoxStyle = "Full",
    DistanceUnit = "m", HeadDot = false,
    Charm = true, CharmFill = 0.7, CharmOutline = true,

    BoxColor      = Color3.fromRGB(140, 130, 255),
    FillColor     = Color3.fromRGB(140, 130, 255),
    TracerColor   = Color3.fromRGB(140, 130, 255),
    HealthColor   = Color3.fromRGB(0, 255, 120),
    NameColor     = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(200, 205, 215),
    HeadDotColor  = Color3.fromRGB(255, 80, 80),
    CharmFillColor    = Color3.fromRGB(150, 100, 255),
    CharmOutlineColor = Color3.fromRGB(200, 160, 255),

    RainbowMenu = false, RainbowMenuSpeed = 0.15,
    RainbowESP  = false, RainbowESPSpeed  = 0.25,
    RainbowCharm = false, RainbowCharmSpeed = 0.30,

    AimEnabled = false, AimKey = Enum.KeyCode.E,
    AimMode = "Camera", AimSmooth = 0.25, AimFOV = 120,
    AimVisible = true, AimPart = "Head",
    AimTeamCheck = true, AimShowFOV = true, AimMaxDist = 800,
    AimPrediction = 0.135, AimPredictionEnabled = true,
    AimResolver = false, AimHitChance = 100,
    AimFovStyle = "Circle", AimFovColor = Color3.fromRGB(255, 255, 255),
    AimSticky = false, AimLockVisual = true,

    FlyEnabled = false, FlySpeed = 60, FlyKey = Enum.KeyCode.F,
    FlyVertical = true, FlyMode = "Classic", FlyAnimSpeed = 1,
    SupermanPose = true, SupermanTilt = 75,

    MenuKey = Enum.KeyCode.K, EspKey = Enum.KeyCode.RightControl,
}

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

local bootGui = new("ScreenGui", { Name = "Sherlock_Boot", ResetOnSpawn = false, IgnoreGuiInset = true,  DisplayOrder = 50, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local espGui  = new("ScreenGui", { Name = "Sherlock_ESP",  ResetOnSpawn = false, IgnoreGuiInset = true,  DisplayOrder = 1,  ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local hudGui  = new("ScreenGui", { Name = "Sherlock_HUD",  ResetOnSpawn = false, IgnoreGuiInset = true,  DisplayOrder = 5,  ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)
local menuGui = new("ScreenGui", { Name = "Sherlock_Menu", ResetOnSpawn = false, IgnoreGuiInset = true,  DisplayOrder = 10, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, ROOT)

-- ============================================================
-- LOGO INTRO
-- ============================================================
do
    local backdrop = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0 }, bootGui)
    local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(180, 180), Position = UDim2.new(0.5, 0, 0.5, -30), BackgroundTransparency = 1, BorderSizePixel = 0 }, backdrop)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, ring)
    local ringStroke = new("UIStroke", { Color = Theme.Accent, Thickness = 2, Transparency = 1 }, ring)
    local glow = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(210, 210), Position = UDim2.new(0.5, 0, 0.5, -30), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0 }, backdrop)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, glow)
    local logo = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(150, 150), Position = UDim2.new(0.5, 0, 0.5, -30), BackgroundTransparency = 1, Image = LOGO_ASSET_ID, ImageTransparency = 1, ScaleType = Enum.ScaleType.Fit }, backdrop)
    local wordmark = new("TextLabel", { Size = UDim2.new(0, 300, 0, 28), Position = UDim2.new(0.5, -150, 0.5, 70), BackgroundTransparency = 1, Text = "S H E R L O C K", TextColor3 = Color3.fromRGB(255, 255, 255), Font = FONT_TITLE, TextSize = 22, TextTransparency = 1 }, backdrop)
    local tagline = new("TextLabel", { Size = UDim2.new(0, 300, 0, 14), Position = UDim2.new(0.5, -150, 0.5, 98), BackgroundTransparency = 1, Text = "beta  ·  loading", TextColor3 = Theme.TextDim, Font = FONT, TextSize = 11, TextTransparency = 1 }, backdrop)
    local barBg = new("Frame", { Size = UDim2.new(0, 220, 0, 2), Position = UDim2.new(0.5, -110, 0.5, 130), BackgroundColor3 = Theme.BgTrack, BorderSizePixel = 0, BackgroundTransparency = 1 }, backdrop)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barBg)
    local barFill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, BackgroundTransparency = 1 }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, barFill)

    task.spawn(function()
        local spinT = 0
        while ring.Parent do
            spinT = spinT + 0.02
            ring.Rotation = (spinT * 90) % 360
            task.wait(0.02)
        end
    end)

    task.spawn(function()
        pcall(function()
            task.wait(0.15)
            TweenService:Create(backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()
            TweenService:Create(glow, TweenInfo.new(0.6), { BackgroundTransparency = 0.93 }):Play()
            TweenService:Create(ringStroke, TweenInfo.new(0.5), { Transparency = 0.55 }):Play()
            logo.Size = UDim2.fromOffset(110, 110)
            TweenService:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { ImageTransparency = 0, Size = UDim2.fromOffset(150, 150) }):Play()
            task.delay(0.4, function()
                TweenService:Create(wordmark, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
                TweenService:Create(tagline, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
            end)
            task.delay(0.5, function()
                TweenService:Create(barBg, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
                TweenService:Create(barFill, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 }):Play()
            end)
            task.wait(2.3)
            TweenService:Create(logo, TweenInfo.new(0.4), { ImageTransparency = 1 }):Play()
            TweenService:Create(ringStroke, TweenInfo.new(0.4), { Transparency = 1 }):Play()
            TweenService:Create(glow, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(wordmark, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
            TweenService:Create(tagline, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
            TweenService:Create(barBg, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(barFill, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(backdrop, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
            task.wait(0.45)
        end)
        pcall(function() bootGui:Destroy() end)
    end)
end

-- ============================================================
-- HUD
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
-- MAIN MENU
-- ============================================================
local W, H = 660, 460
local BASE_POS = UDim2.new(0.5, -W / 2, 0.5, -H / 2)

local main = new("Frame", { Name = "Sherlock", Size = UDim2.fromOffset(W, H), Position = BASE_POS, BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, Visible = false }, menuGui)
new("UICorner", { CornerRadius = UDim.new(0, 8) }, main)
new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, main)
local scale = new("UIScale", { Scale = 1 }, main)

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
    local logoBox = new("Frame", { Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 12, 1, -74), BackgroundColor3 = Theme.BgContent, BorderSizePixel = 0 }, side)
    new("UICorner", { CornerRadius = UDim.new(0, 6) }, logoBox)
    new("ImageLabel", { Size = UDim2.new(1, -8, 1, -8), Position = UDim2.new(0, 4, 0, 4), BackgroundTransparency = 1, Image = LOGO_ASSET_ID, ScaleType = Enum.ScaleType.Fit }, logoBox)
    new("TextLabel", { Size = UDim2.new(1, -18, 0, 18), Position = UDim2.new(0, 10, 1, -22), BackgroundTransparency = 1, Text = "sherlock", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }, side)
end

local SIDE_TABS = { "aimbot", "visuals", "misc", "config" }
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

local function makeSubTab(pageIdx, subs)
    local page = contentPages[pageIdx]
    local SUB_H = 24
    local strip = new("Frame", { Size = UDim2.new(1, -16, 0, SUB_H), Position = UDim2.new(0, 8, 0, 8), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0 }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 5) }, strip)
    local holder = new("Frame", { Size = UDim2.new(1, -16, 1, -(SUB_H + 16)), Position = UDim2.new(0, 8, 0, SUB_H + 14), BackgroundTransparency = 1 }, page)

    local subPages = {}
    for i = 1, #subs do
        subPages[i] = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.TextDim, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false }, holder)
    end

    local subBtns = {}
    local function selectSub(i)
        for k, b in ipairs(subBtns) do
            local on = (k == i)
            TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = on and Theme.Accent or Theme.BgTop }):Play()
            b.TextColor3 = on and Theme.Bg or Theme.TextNormal
        end
        for k, p in ipairs(subPages) do p.Visible = (k == i) end
    end
    for i, name in ipairs(subs) do
        local b = new("TextButton", { Size = UDim2.new(1 / #subs, -(#subs - 1) * 2 / #subs, 1, -4), Position = UDim2.new((i - 1) / #subs, 2, 0, 2), BackgroundColor3 = Theme.BgTop, BorderSizePixel = 0, Text = name, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, AutoButtonColor = false }, strip)
        new("UICorner", { CornerRadius = UDim.new(0, 4) }, b)
        b.MouseButton1Click:Connect(function() selectSub(i) end)
        subBtns[i] = b
    end
    selectSub(1)
    return subPages
end

local hoverTargets = {}
local ROW_H, ROW_GAP, PAD = 26, 5, 10
local SLIDER_H, COLOR_H, SECTION_H = 40, 82, 22

local function styleRow(row)
    row.MouseEnter:Connect(function()
        if row:GetAttribute("noHover") then return end
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Theme.BgRowHover }):Play()
    end)
    row.MouseLeave:Connect(function()
        if row:GetAttribute("noHover") then return end
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Theme.BgRow }):Play()
    end)
    hoverTargets[#hoverTargets + 1] = row
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
        box.BackgroundColor3 = Theme.Bg
        boxStroke.Color = on and Theme.Accent or Theme.Stroke
        check.BackgroundColor3 = Theme.Accent
        check.Visible = on
    end
    row.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        refresh()
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
    local keyLbl = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = Config[key].Name, TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 11 }, valBox)

    local listening = false
    row.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLbl.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Config[key] = input.KeyCode
                keyLbl.Text = input.KeyCode.Name
                listening = false
                conn:Disconnect()
            end
        end)
    end)
    styleRow(row)
    rebindCallbacks[key] = function() keyLbl.Text = Config[key].Name end
    return ROW_H + ROW_GAP
end

local function makeColorWheel(parent, label, key, y, onChange)
    local row = new("Frame", { Size = UDim2.new(1, -PAD * 2, 0, COLOR_H + 34), Position = UDim2.new(0, PAD, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
    new("TextLabel", { Size = UDim2.new(1, -140, 0, 14), Position = UDim2.new(0, 10, 0, 4), BackgroundTransparency = 1, Text = label, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, row)

    local bwRow = new("Frame", { Size = UDim2.fromOffset(60, 16), Position = UDim2.new(1, -76, 0, 3), BackgroundTransparency = 1 }, row)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, bwRow)
    for _, col in ipairs({ Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0) }) do
        local s = new("TextButton", { Size = UDim2.fromOffset(24, 16), BackgroundColor3 = col, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, bwRow)
        new("UICorner", { CornerRadius = UDim.new(0, 3) }, s)
        new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, s)
        s.MouseButton1Click:Connect(function()
            Config[key] = col
            if onChange then onChange(col) end
        end)
    end

    local DISC = 100
    local R = DISC / 2
    local wheel = new("Frame", { Size = UDim2.fromOffset(DISC, DISC), Position = UDim2.new(1, -DISC - 12, 0, 4), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true }, row)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, wheel)
    new("UIStroke", { Color = Theme.Stroke, Thickness = 1 }, wheel)

    local N = 28
    local cell = DISC / N
    for i = 0, N - 1 do
        for j = 0, N - 1 do
            local px = (i + 0.5) * cell
            local py = (j + 0.5) * cell
            local dx, dy = px - R, py - R
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= R then
                local hue = ((math.atan2(dy, dx) / (math.pi * 2)) + 1) % 1
                local sat = math.clamp(dist / R, 0, 1)
                new("Frame", {
                    Size = UDim2.fromOffset(cell + 0.7, cell + 0.7),
                    Position = UDim2.fromOffset(i * cell, j * cell),
                    BackgroundColor3 = Color3.fromHSV(hue, sat, 1),
                    BorderSizePixel = 0,
                }, wheel)
            end
        end
    end

    local marker = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Config[key], BorderSizePixel = 0, ZIndex = 5 }, wheel)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, marker)
    new("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1.5 }, marker)

    local function updateMarker()
        local h, s = getHSV(Config[key])
        local ang = h * math.pi * 2
        local rr = s * R * 0.9
        marker.Position = UDim2.fromOffset(R + math.cos(ang) * rr, R + math.sin(ang) * rr)
        marker.BackgroundColor3 = Config[key]
    end

    wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local ccx = wheel.AbsolutePosition.X + R
            local ccy = wheel.AbsolutePosition.Y + R
            local dx, dy = input.Position.X - ccx, input.Position.Y - ccy
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= R then
                local hue = ((math.atan2(dy, dx) / (math.pi * 2)) + 1) % 1
                local sat = math.clamp(dist / R, 0, 1)
                local _, _, v = getHSV(Config[key])
                local c = Color3.fromHSV(hue, sat, math.max(v, 0.5))
                Config[key] = c
                updateMarker()
                if onChange then onChange(c) end
            end
        end
    end)

    local valTrack = new("Frame", { Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 0, COLOR_H + 6), BackgroundColor3 = Theme.BgTrack, BorderSizePixel = 0 }, row)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, valTrack)
    local valFill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0 }, valTrack)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, valFill)
    local valThumb = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Theme.TextPrimary, BorderSizePixel = 0 }, valTrack)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, valThumb)

    do
        local _, _, v = getHSV(Config[key])
        valFill.Size = UDim2.new(v, 0, 1, 0)
        valThumb.Position = UDim2.new(v, 0, 0.5, 0)
        updateMarker()
    end

    local valDrag = false
    valTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            valDrag = true
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then valDrag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not valDrag then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local rel = math.clamp((input.Position.X - valTrack.AbsolutePosition.X) / valTrack.AbsoluteSize.X, 0, 1)
            local h, s, _ = getHSV(Config[key])
            local c = Color3.fromHSV(h, s, math.max(rel, 0.02))
            Config[key] = c
            valFill.Size = UDim2.new(rel, 0, 1, 0)
            valThumb.Position = UDim2.new(rel, 0, 0.5, 0)
            updateMarker()
            if onChange then onChange(c) end
        end
    end)

    return COLOR_H + 34 + ROW_GAP
end

-- ============================================================
-- CONFIG SAVE / LOAD
-- ============================================================
local CONFIG_DIR = "Sherlock_Configs"
local function ensureFs()
    if not writefile or not isfolder or not makefolder then return false end
    pcall(function() if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end end)
    return true
end
local function serializeConfig()
    local data = {}
    for k, v in pairs(Config) do
        if typeof(v) == "EnumItem" then data[k] = { __t = "Enum", enum = tostring(v.EnumType), name = v.Name }
        elseif typeof(v) == "Color3" then data[k] = { __t = "Color3", r = v.R, g = v.G, b = v.B }
        elseif type(v) == "number" or type(v) == "string" or type(v) == "boolean" then data[k] = v end
    end
    return data
end
local function deserializeConfig(data)
    for k, v in pairs(data) do
        if type(v) == "table" and v.__t == "Enum" then
            local ok, item = pcall(function() return Enum[v.enum][v.name] end)
            if ok then Config[k] = item end
        elseif type(v) == "table" and v.__t == "Color3" then Config[k] = Color3.new(v.r, v.g, v.b)
        else Config[k] = v end
    end
end
local function saveConfig(name)
    if not ensureFs() then return false end
    return pcall(function() writefile(CONFIG_DIR .. "/" .. name .. ".json", HttpService:JSONEncode(serializeConfig())) end)
end
local function loadConfig(name)
    if not ensureFs() then return false end
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    if not isfile or not isfile(path) then return false end
    local raw
    local ok = pcall(function() raw = readfile(path) end)
    if not ok or not raw then return false end
    local data
    ok = pcall(function() data = HttpService:JSONDecode(raw) end)
    if not ok then return false end
    deserializeConfig(data)
    for _, r in pairs(toggleRefs) do pcall(r) end
    for _, cb in pairs(rebindCallbacks) do pcall(cb) end
    return true
end
local function listConfigs()
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
local function deleteConfig(name)
    if not ensureFs() or not delfile then return false end
    return pcall(function() delfile(CONFIG_DIR .. "/" .. name .. ".json") end)
end

-- ============================================================
-- PAGES
-- ============================================================
pcall(function()
    local subs = makeSubTab(1, { "main", "accuracy" })
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
end)

pcall(function()
    local subs = makeSubTab(2, { "main", "esp", "colors" })
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

pcall(function()
    local subs = makeSubTab(3, { "fly", "rainbow" })
    local y = 4
    y = y + makeSection(subs[1], "fly", y)
    y = y + makeToggle(subs[1], "fly enabled", "FlyEnabled", y)
    y = y + makeToggle(subs[1], "vertical fly", "FlyVertical", y)
    y = y + makeToggle(subs[1], "superman pose", "SupermanPose", y)
    y = y + makeCycle (subs[1], "fly animation", "FlyMode", { "Classic", "Boost", "Hover" }, tostring, y)
    y = y + makeSlider(subs[1], "fly speed", "FlySpeed", 10, 300, 5, function(v) return tostring(v) end, y)
    y = y + makeSlider(subs[1], "anim intensity", "FlyAnimSpeed", 0.2, 3, 0.1, function(v) return string.format("%.1f", v) end, y)
    y = y + makeSlider(subs[1], "superman tilt", "SupermanTilt", 30, 90, 5, function(v) return v .. "°" end, y)
    y = y + makeRebind(subs[1], "fly key", "FlyKey", y)

    local y2 = 4
    y2 = y2 + makeSection(subs[2], "rainbow", y2)
    y2 = y2 + makeToggle(subs[2], "menu rainbow", "RainbowMenu", y2)
    y2 = y2 + makeSlider(subs[2], "menu speed", "RainbowMenuSpeed", 0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y2)
    y2 = y2 + makeToggle(subs[2], "esp rainbow", "RainbowESP", y2)
    y2 = y2 + makeSlider(subs[2], "esp speed", "RainbowESPSpeed", 0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y2)
    y2 = y2 + makeToggle(subs[2], "charm rainbow", "RainbowCharm", y2)
    y2 = y2 + makeSlider(subs[2], "charm speed", "RainbowCharmSpeed", 0.02, 1, 0.02, function(v) return string.format("%.2f", v) end, y2)
    y2 = y2 + makeSection(subs[2], "bindings", y2)
    y2 = y2 + makeRebind(subs[2], "menu key", "MenuKey", y2)
    y2 = y2 + makeRebind(subs[2], "esp toggle key", "EspKey", y2)
end)

pcall(function()
    local page = contentPages[4]
    local y = 8
    new("TextLabel", { Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1, Text = "config name", TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, page)
    y = y + 22
    local nameBox = new("Frame", { Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, y), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0 }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, nameBox)
    local nameInput = new("TextBox", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 6, 0, 0), BackgroundTransparency = 1, Text = "default", TextColor3 = Theme.TextPrimary, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false }, nameBox)
    y = y + 32

    local listStart = y
    local function refreshConfigList()
        for _, c in ipairs(page:GetChildren()) do
            if c:GetAttribute("cfgRow") then c:Destroy() end
        end
        local configs = listConfigs()
        for i, name in ipairs(configs) do
            local row = new("TextButton", { Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, listStart + (i - 1) * 28), BackgroundColor3 = Theme.BgRow, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, page)
            row:SetAttribute("cfgRow", true)
            new("UICorner", { CornerRadius = UDim.new(0, 4) }, row)
            new("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Theme.TextNormal, Font = FONT, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, row)
            local delBtn = new("TextButton", { Size = UDim2.fromOffset(36, 16), Position = UDim2.new(1, -42, 0.5, -8), BackgroundColor3 = Color3.fromRGB(60, 25, 30), BorderSizePixel = 0, Text = "del", TextColor3 = Color3.fromRGB(255, 130, 130), Font = FONT, TextSize = 10, AutoButtonColor = false }, row)
            new("UICorner", { CornerRadius = UDim.new(0, 3) }, delBtn)
            delBtn.MouseButton1Click:Connect(function() deleteConfig(name) refreshConfigList() end)
            row.MouseButton1Click:Connect(function()
                nameInput.Text = name
                loadConfig(name)
            end)
        end
    end

    local saveBtn = new("TextButton", { Size = UDim2.fromOffset(80, 26), Position = UDim2.new(1, -90, 0, listStart - 32), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Text = "save", TextColor3 = Theme.Bg, Font = FONT, TextSize = 12, AutoButtonColor = false }, page)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, saveBtn)
    saveBtn.MouseButton1Click:Connect(function() saveConfig(nameInput.Text) refreshConfigList() end)

    refreshConfigList()
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
local function tweenAlpha(goal, dur)
    fadeToken += 1
    local my = fadeToken
    local start = menuAlpha
    local t0 = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if my ~= fadeToken then conn:Disconnect() return end
        local a = math.clamp((os.clock() - t0) / dur, 0, 1)
        local e = 1 - (1 - a) ^ 3
        menuAlpha = start + (goal - start) * e
        applyFade(menuAlpha)
        if a >= 1 then conn:Disconnect() end
    end)
end

function openMenu()
    if menuOpen then return end
    menuOpen = true
    main.Visible = true
    menuAlpha = 1
    applyFade(1)
    scale.Scale = 0.9
    TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    tweenAlpha(0, 0.4)
end

function closeMenu()
    if not menuOpen then return end
    menuOpen = false
    TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.9 }):Play()
    tweenAlpha(1, 0.24)
    task.delay(0.28, function() if not menuOpen then main.Visible = false end end)
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
    if input.KeyCode == Config.MenuKey then
        if menuOpen then closeMenu() else openMenu() end
    elseif input.KeyCode == Config.EspKey then
        Config.Enabled = not Config.Enabled
    elseif input.KeyCode == Config.AimKey then
        aimHeld = true
    elseif input.KeyCode == Config.FlyKey then
        Config.FlyEnabled = not Config.FlyEnabled
        if toggleRefs.FlyEnabled then toggleRefs.FlyEnabled() end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Config.AimKey then aimHeld = false end
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
local espCache = {}

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
                        if Config.TracerOrigin == "Bottom" then
                            origin = Vector2.new(vp.X * 0.5, vp.Y)
                        elseif Config.TracerOrigin == "Center" then
                            origin = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
                        else
                            origin = UserInputService:GetMouseLocation()
                        end
                        local target = Vector2.new(cx, maxY)
                        data.tracer.BackgroundColor3 = espTracer
                        drawTracer(data.tracer, origin, target, Config.TracerThickness)
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
-- FLY + SUPERMAN POSE
-- ============================================================
do
    local flyBV, flyBG
    local baseFov = 70
    local fovTarget = baseFov
    local modeTimer = 0
    local jointCache = nil
    local poseAlpha = 0

    -- joints to cache (R6 + R15 names)
    local JOINT_LIST = {
        "Right Shoulder", "Left Shoulder",
        "RightShoulder",  "LeftShoulder",
        "RightHip", "LeftHip",
        "Right Hip", "Left Hip",
        "RightUpperArm", "LeftUpperArm",
    }

    local function cacheJoints(char)
        if jointCache then return end
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not torso then return end
        jointCache = {}
        for _, name in ipairs(JOINT_LIST) do
            local j = torso:FindFirstChild(name)
            if j and j:IsA("Motor6D") then
                jointCache[name] = { joint = j, C0 = j.C0, C1 = j.C1 }
            end
        end
    end

    local function restoreJoints()
        if not jointCache then return end
        for _, d in pairs(jointCache) do
            if d.joint and d.joint.Parent then
                d.joint.C0 = d.C0
                d.joint.C1 = d.C1
            end
        end
    end

    local function clearJoints()
        restoreJoints()
        jointCache = nil
        poseAlpha = 0
    end

    -- superman pose: arms forward, legs together
    -- applied as lerp between original C0 and superman C0
    local function applySuperman(alpha)
        if not jointCache then return end
        for name, d in pairs(jointCache) do
            local j = d.joint
            if j and j.Parent then
                local target = nil
                if name == "Right Shoulder" or name == "RightShoulder" or name == "RightUpperArm" then
                    -- rotate arm forward from body
                    target = d.C0 * CFrame.Angles(math.rad(-95), 0, 0) * CFrame.Angles(0, 0, math.rad(-15))
                elseif name == "Left Shoulder" or name == "LeftShoulder" or name == "LeftUpperArm" then
                    target = d.C0 * CFrame.Angles(math.rad(-95), 0, 0) * CFrame.Angles(0, 0, math.rad(15))
                elseif name == "RightHip" or name == "Right Hip" then
                    target = CFrame.new(0.4, -1, 0)
                elseif name == "LeftHip" or name == "Left Hip" then
                    target = CFrame.new(-0.4, -1, 0)
                end
                if target then
                    j.C0 = d.C0:Lerp(target, alpha)
                end
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
            if Config.SupermanPose then applySuperman(poseAlpha) end

            -- fly mode specific velocity
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

            -- BodyGyro orientation with superman tilt
            local lookTarget = hrp.Position + cam.CFrame.LookVector
            local baseCF = CFrame.new(hrp.Position, lookTarget)
            if Config.SupermanPose and poseAlpha > 0.02 then
                local tiltRad = math.rad(-Config.SupermanTilt * poseAlpha)
                baseCF = baseCF * CFrame.Angles(tiltRad, 0, 0)
            end
            -- hover sway
            if Config.FlyMode == "Hover" and not wantSuperman then
                local sway = math.sin(modeTimer * 1.5 * intensity) * math.rad(3 * intensity)
                baseCF = baseCF * CFrame.Angles(0, 0, sway)
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
pcall(openMenu)
print("[Sherlock] loaded — press K to toggle menu")
