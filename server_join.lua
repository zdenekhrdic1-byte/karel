-- ============================================================
--  ServerJoiner LocalScript  v4  (all bugs fixed)
--  Place inside StarterPlayerScripts
--  Works in LIVE games only (not Studio Play)
-- ============================================================

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local LocalPlayer     = Players.LocalPlayer

-- ============================================================
-- COLOURS
-- ============================================================
local GREEN       = Color3.fromRGB(0,   220, 70)
local GREEN_DIM   = Color3.fromRGB(0,   170, 55)
local GREEN_DARK  = Color3.fromRGB(0,    70, 20)
local GREEN_HOVER = Color3.fromRGB(0,   110, 35)
local BLACK       = Color3.fromRGB(0,     0,  0)
local PANEL_BG    = Color3.fromRGB(8,    20,  8)
local TITLE_BG    = Color3.fromRGB(4,    38,  4)
local INPUT_BG    = Color3.fromRGB(4,    14,  4)
local RED         = Color3.fromRGB(220,  50, 50)
local JOIN_BG     = Color3.fromRGB(0,    45, 12)
local JOIN_HOVER  = Color3.fromRGB(0,    85, 25)

-- ============================================================
-- TWEEN HELPER
-- ============================================================
local function tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18,
            style or Enum.EasingStyle.Quad,
            dir   or Enum.EasingDirection.Out),
        props):Play()
end

-- ============================================================
-- UI HELPERS
-- ============================================================
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color     = col   or GREEN
    s.Thickness = thick or 1.5
    s.Parent    = p
    return s
end

local function makeLabel(parent, txt, x, y, w, h, size, align, color)
    local l = Instance.new("TextLabel")
    l.Size                   = UDim2.new(0, w, 0, h)
    l.Position               = UDim2.new(0, x, 0, y)
    l.BackgroundTransparency = 1
    l.Text                   = txt
    l.TextColor3             = color or GREEN_DIM
    l.TextSize               = size  or 12
    l.Font                   = Enum.Font.GothamBold
    l.TextXAlignment         = align or Enum.TextXAlignment.Left
    l.TextScaled             = false
    l.ZIndex                 = 8
    l.Parent                 = parent
    return l
end

local function makeTextBox(parent, placeholder, x, y, w, editable)
    local b = Instance.new("TextBox")
    b.Size              = UDim2.new(0, w, 0, 32)
    b.Position          = UDim2.new(0, x, 0, y)
    b.BackgroundColor3  = INPUT_BG
    b.BorderSizePixel   = 0
    b.PlaceholderText   = placeholder
    b.PlaceholderColor3 = GREEN_DARK
    b.Text              = ""
    b.TextColor3        = GREEN
    b.TextSize          = 11
    b.Font              = Enum.Font.Code
    b.ClearTextOnFocus  = false
    b.TextEditable      = (editable == nil) and true or editable
    b.TextScaled        = false
    b.TextXAlignment    = Enum.TextXAlignment.Left
    b.TextTruncate      = Enum.TextTruncate.AtEnd
    b.ZIndex            = 8
    b.Parent            = parent
    corner(b, 6)
    stroke(b, GREEN_DARK, 1)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft  = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent       = b
    return b
end

-- Button with FIXED hover (stores original position/size, no drift)
local function makeButton(parent, txt, x, y, w, bg)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, w,   0, 34)
    btn.Position         = UDim2.new(0, x,   0, y)
    btn.BackgroundColor3 = bg or GREEN_DARK
    btn.BorderSizePixel  = 0
    btn.Text             = txt
    btn.TextColor3       = GREEN
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.TextScaled       = false
    btn.AutoButtonColor  = false
    btn.ZIndex           = 8
    btn.Parent           = parent
    corner(btn, 8)
    stroke(btn, GREEN, 1.2)

    -- store originals so hover never drifts
    local origSize = btn.Size
    local origPos  = btn.Position
    local hoverSize = UDim2.new(0, w + 4, 0, 36)
    local hoverPos  = UDim2.new(0, x - 2, 0, y - 1)
    local downSize  = UDim2.new(0, w - 2, 0, 32)
    local downPos   = UDim2.new(0, x + 1, 0, y + 1)
    local normalBg  = bg or GREEN_DARK
    local hoverBg   = (bg == JOIN_BG) and JOIN_HOVER or GREEN_HOVER

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = hoverBg, Size = hoverSize, Position = hoverPos}, 0.13)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = normalBg, Size = origSize,  Position = origPos},  0.13)
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundColor3 = normalBg, Size = downSize,  Position = downPos},  0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundColor3 = hoverBg,  Size = hoverSize, Position = hoverPos}, 0.10)
    end)

    return btn
end

-- ============================================================
-- SCREEN GUI
-- ============================================================
local Gui = Instance.new("ScreenGui")
Gui.Name           = "ServerJoinerGui"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- TOGGLE BUTTON  (left edge)
-- ============================================================
local Toggle = Instance.new("TextButton")
Toggle.Name             = "Toggle"
Toggle.Size             = UDim2.new(0, 38, 0, 38)
Toggle.Position         = UDim2.new(0, 6, 0.5, -19)
Toggle.BackgroundColor3 = BLACK
Toggle.Text             = "🔗"
Toggle.TextSize         = 20
Toggle.Font             = Enum.Font.GothamBold
Toggle.TextColor3       = GREEN
Toggle.AutoButtonColor  = false
Toggle.ZIndex           = 10
Toggle.Parent           = Gui
corner(Toggle, 19)
local toggleStroke = stroke(Toggle, GREEN, 1.5)

-- Pulse glow loop
local function startPulse()
    task.spawn(function()
        while true do
            tween(toggleStroke, {Thickness = 2.8}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.9)
            tween(toggleStroke, {Thickness = 1.5}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.9)
        end
    end)
end
startPulse()

Toggle.MouseEnter:Connect(function()
    tween(Toggle, {BackgroundColor3 = GREEN_DARK, Size = UDim2.new(0, 44, 0, 44)}, 0.12)
    Toggle.Position = UDim2.new(0, 3, 0.5, -22)
end)
Toggle.MouseLeave:Connect(function()
    tween(Toggle, {BackgroundColor3 = BLACK, Size = UDim2.new(0, 38, 0, 38)}, 0.12)
    Toggle.Position = UDim2.new(0, 6, 0.5, -19)
end)

-- ============================================================
-- MAIN PANEL
-- ============================================================
local PAD     = 14
local PW      = 290
local IW      = PW - PAD * 2   -- 262
local PANEL_H = 355             -- tall enough for all content + status

local Panel = Instance.new("Frame")
Panel.Name             = "Panel"
Panel.Size             = UDim2.new(0, PW, 0, PANEL_H)
Panel.BackgroundColor3 = PANEL_BG
Panel.BorderSizePixel  = 0
Panel.Visible          = false
Panel.ZIndex           = 6
-- NO ClipsDescendants — was cutting off status label
Panel.Parent           = Gui
corner(Panel, 12)
stroke(Panel, GREEN, 1.8)

local CLOSED_POS = UDim2.new(0, -PW - 20, 0.5, -PANEL_H / 2)
local OPEN_POS   = UDim2.new(0, 52,       0.5, -PANEL_H / 2)
Panel.Position   = CLOSED_POS

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = TITLE_BG
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 7
TitleBar.Parent           = Panel
corner(TitleBar, 12)

local TitleFill = Instance.new("Frame")
TitleFill.Size             = UDim2.new(1, 0, 0, 14)
TitleFill.Position         = UDim2.new(0, 0, 1, -14)
TitleFill.BackgroundColor3 = TITLE_BG
TitleFill.BorderSizePixel  = 0
TitleFill.ZIndex           = 7
TitleFill.Parent           = TitleBar

makeLabel(TitleBar, "⚡  SERVER JOINER", 12, 0, 220, 38, 14,
    Enum.TextXAlignment.Left, GREEN)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 26, 0, 26)
CloseBtn.Position         = UDim2.new(1, -32, 0, 6)
CloseBtn.BackgroundColor3 = BLACK
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = RED
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.AutoButtonColor  = false
CloseBtn.ZIndex           = 9
CloseBtn.Parent           = TitleBar
corner(CloseBtn, 6)
CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(60,10,10)}, 0.15) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {BackgroundColor3 = BLACK}, 0.15) end)

-- ============================================================
-- CONTENT  — Y layout:
--   50  PLACE ID label
--   67  PlaceBox   (32px tall → bottom at 99)
--  107  SERVER JOB ID label
--  124  ServerBox  (32px tall → bottom at 156)
--  164  GetBtn     (34px tall → bottom at 198)
--  208  divider
--  216  JOIN label
--  233  JoinBox    (32px tall → bottom at 265)
--  273  JoinBtn    (34px tall → bottom at 307)
--  314  StatusLbl  (28px tall → bottom at 342)  ← clear of panel edge (355)
-- ============================================================

makeLabel(Panel, "PLACE ID",      PAD,  50, IW, 16, 11, Enum.TextXAlignment.Left, GREEN_DIM)
local PlaceBox  = makeTextBox(Panel, "click GET to fill...", PAD, 67, IW, false)

makeLabel(Panel, "SERVER JOB ID", PAD, 107, IW, 16, 11, Enum.TextXAlignment.Left, GREEN_DIM)
local ServerBox = makeTextBox(Panel, "click GET to fill...", PAD, 124, IW, false)

local GetBtn = makeButton(Panel, "📋   GET SERVER INFO", PAD, 164, IW, GREEN_DARK)

local Div = Instance.new("Frame")
Div.Size             = UDim2.new(0, IW, 0, 1)
Div.Position         = UDim2.new(0, PAD, 0, 208)
Div.BackgroundColor3 = GREEN_DARK
Div.BorderSizePixel  = 0
Div.ZIndex           = 7
Div.Parent           = Panel

makeLabel(Panel, "PASTE SERVER JOB ID TO JOIN", PAD, 216, IW, 16, 11, Enum.TextXAlignment.Left, GREEN_DIM)
local JoinBox = makeTextBox(Panel, "paste job id here...", PAD, 233, IW, true)

local JoinBtn = makeButton(Panel, "🚀   JOIN SERVER", PAD, 273, IW, JOIN_BG)

-- Status label — sits cleanly below JoinBtn with room to spare
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size                   = UDim2.new(0, IW, 0, 28)
StatusLbl.Position               = UDim2.new(0, PAD, 0, 314)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text                   = ""
StatusLbl.TextColor3             = GREEN
StatusLbl.TextSize               = 11
StatusLbl.Font                   = Enum.Font.Gotham
StatusLbl.TextXAlignment         = Enum.TextXAlignment.Center
StatusLbl.TextYAlignment         = Enum.TextYAlignment.Center
StatusLbl.TextScaled             = false
StatusLbl.TextWrapped            = true
StatusLbl.ZIndex                 = 8
StatusLbl.Parent                 = Panel

local function setStatus(msg, isError)
    StatusLbl.Text       = msg
    StatusLbl.TextColor3 = isError and RED or GREEN
    StatusLbl.TextTransparency = 1
    tween(StatusLbl, {TextTransparency = 0}, 0.25)
end

-- ============================================================
-- OPEN / CLOSE
-- ============================================================
local isOpen = false

local function setOpen(val)
    isOpen = val
    if val then
        Panel.Visible = true
        tween(Panel, {Position = OPEN_POS}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tween(Toggle, {TextColor3 = RED}, 0.2)
        Toggle.Text = "✕"
    else
        local t = TweenService:Create(Panel,
            TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = CLOSED_POS})
        t:Play()
        t.Completed:Connect(function()
            if not isOpen then Panel.Visible = false end
        end)
        tween(Toggle, {TextColor3 = GREEN}, 0.2)
        Toggle.Text = "🔗"
    end
end

Toggle.MouseButton1Click:Connect(function()   setOpen(not isOpen) end)
CloseBtn.MouseButton1Click:Connect(function()  setOpen(false)      end)

-- ============================================================
-- GET SERVER INFO
-- ============================================================
GetBtn.MouseButton1Click:Connect(function()
    local jobId = tostring(game.JobId)
    if jobId == "" then
        setStatus("⚠  Must be in a live server!", true)
        return
    end
    PlaceBox.Text  = ""
    ServerBox.Text = ""
    task.delay(0.05, function()
        PlaceBox.Text = tostring(game.PlaceId)
    end)
    task.delay(0.15, function()
        ServerBox.Text = jobId
        setStatus("✔  Share both IDs with your friend!", false)
        local bs = stroke(ServerBox, GREEN, 2)
        local ps = stroke(PlaceBox,  GREEN, 2)
        task.delay(0.7, function() bs:Destroy() end)
        task.delay(0.7, function() ps:Destroy() end)
    end)
end)

-- ============================================================
-- JOIN SERVER
-- ============================================================
JoinBtn.MouseButton1Click:Connect(function()
    local jobId = JoinBox.Text:match("^%s*(.-)%s*$")
    if jobId == "" or #jobId < 10 then
        setStatus("⚠  Paste a valid Server Job ID!", true)
        -- shake animation
        local origX = JoinBox.Position.X.Offset
        local origY = JoinBox.Position.Y.Offset
        task.spawn(function()
            for _, dx in ipairs({-6, 6, -4, 4, -2, 2, 0}) do
                JoinBox.Position = UDim2.new(0, origX + dx, 0, origY)
                task.wait(0.04)
            end
        end)
        return
    end
    setStatus("🔄  Teleporting...", false)
    local emojis  = {"🚀","💨","⚡","✨"}
    local idx     = 1
    local spinning = true
    task.spawn(function()
        while spinning do
            JoinBtn.Text = emojis[idx] .. "   JOINING..."
            idx = (idx % #emojis) + 1
            task.wait(0.18)
        end
    end)
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
    end)
    spinning = false
    if not ok then
        JoinBtn.Text = "🚀   JOIN SERVER"
        setStatus("✖  " .. tostring(err):sub(1, 42), true)
    end
end)
