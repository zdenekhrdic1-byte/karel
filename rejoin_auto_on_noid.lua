-- ============================================================
--  ServerJoiner LocalScript
--  Place inside StarterPlayerScripts
-- ============================================================

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- live game only
if RunService:IsStudio() then
    warn("Only works in live games")
    return
end

-- ============================================================
-- AUTO EXECUTE AFTER TELEPORT
-- ============================================================

if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("YOUR_SCRIPT_URL"))()
    ]])
end

-- ============================================================
-- COLOURS
-- ============================================================

local GREEN       = Color3.fromRGB(0,220,70)
local GREEN_DIM   = Color3.fromRGB(0,170,55)
local GREEN_DARK  = Color3.fromRGB(0,70,20)
local GREEN_HOVER = Color3.fromRGB(0,110,35)

local BLACK       = Color3.fromRGB(0,0,0)
local PANEL_BG    = Color3.fromRGB(8,20,8)
local TITLE_BG    = Color3.fromRGB(4,38,4)

local RED         = Color3.fromRGB(220,50,50)

local JOIN_BG     = Color3.fromRGB(0,45,12)
local JOIN_HOVER  = Color3.fromRGB(0,85,25)

-- ============================================================
-- TWEEN
-- ============================================================

local function tween(obj, props, t, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(
            t or 0.18,
            style or Enum.EasingStyle.Quad,
            dir or Enum.EasingDirection.Out
        ),
        props
    ):Play()
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
    s.Color = col or GREEN
    s.Thickness = thick or 1.5
    s.Parent = p
    return s
end

local function makeLabel(parent, txt, x, y, w, h, size, align, color)

    local l = Instance.new("TextLabel")

    l.Size = UDim2.new(0,w,0,h)
    l.Position = UDim2.new(0,x,0,y)

    l.BackgroundTransparency = 1

    l.Text = txt
    l.TextColor3 = color or GREEN_DIM
    l.TextSize = size or 12

    l.Font = Enum.Font.GothamBold

    l.TextXAlignment = align or Enum.TextXAlignment.Left
    l.TextScaled = false

    l.ZIndex = 8

    l.Parent = parent

    return l
end

local function makeButton(parent, txt, x, y, w, bg)

    local btn = Instance.new("TextButton")

    btn.Size = UDim2.new(0,w,0,34)
    btn.Position = UDim2.new(0,x,0,y)

    btn.BackgroundColor3 = bg or GREEN_DARK
    btn.BorderSizePixel = 0

    btn.Text = txt
    btn.TextColor3 = GREEN
    btn.TextSize = 13

    btn.Font = Enum.Font.GothamBold

    btn.TextScaled = false
    btn.AutoButtonColor = false

    btn.ZIndex = 8
    btn.Parent = parent

    corner(btn,8)
    stroke(btn,GREEN,1.2)

    local origSize = btn.Size
    local origPos  = btn.Position

    local hoverSize = UDim2.new(0,w + 4,0,36)
    local hoverPos  = UDim2.new(0,x - 2,0,y - 1)

    local downSize  = UDim2.new(0,w - 2,0,32)
    local downPos   = UDim2.new(0,x + 1,0,y + 1)

    local normalBg = bg or GREEN_DARK
    local hoverBg  = (bg == JOIN_BG) and JOIN_HOVER or GREEN_HOVER

    btn.MouseEnter:Connect(function()
        tween(btn,{
            BackgroundColor3 = hoverBg,
            Size = hoverSize,
            Position = hoverPos
        },0.13)
    end)

    btn.MouseLeave:Connect(function()
        tween(btn,{
            BackgroundColor3 = normalBg,
            Size = origSize,
            Position = origPos
        },0.13)
    end)

    btn.MouseButton1Down:Connect(function()
        tween(btn,{
            BackgroundColor3 = normalBg,
            Size = downSize,
            Position = downPos
        },0.08)
    end)

    btn.MouseButton1Up:Connect(function()
        tween(btn,{
            BackgroundColor3 = hoverBg,
            Size = hoverSize,
            Position = hoverPos
        },0.10)
    end)

    return btn
end

-- ============================================================
-- GUI
-- ============================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "ServerJoinerGui"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- TOGGLE BUTTON
-- ============================================================

local Toggle = Instance.new("TextButton")

Toggle.Name = "Toggle"

Toggle.Size = UDim2.new(0,38,0,38)
Toggle.Position = UDim2.new(0,6,0.5,-19)

Toggle.BackgroundColor3 = BLACK

Toggle.Text = "🔗"
Toggle.TextSize = 20
Toggle.TextColor3 = GREEN

Toggle.Font = Enum.Font.GothamBold

Toggle.AutoButtonColor = false

Toggle.ZIndex = 10
Toggle.Parent = Gui

corner(Toggle,19)

local toggleStroke = stroke(Toggle,GREEN,1.5)

task.spawn(function()
    while true do

        tween(
            toggleStroke,
            {Thickness = 2.8},
            0.9,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        task.wait(0.9)

        tween(
            toggleStroke,
            {Thickness = 1.5},
            0.9,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut
        )

        task.wait(0.9)
    end
end)

Toggle.MouseEnter:Connect(function()

    tween(
        Toggle,
        {
            BackgroundColor3 = GREEN_DARK,
            Size = UDim2.new(0,44,0,44)
        },
        0.12
    )

    Toggle.Position = UDim2.new(0,3,0.5,-22)
end)

Toggle.MouseLeave:Connect(function()

    tween(
        Toggle,
        {
            BackgroundColor3 = BLACK,
            Size = UDim2.new(0,38,0,38)
        },
        0.12
    )

    Toggle.Position = UDim2.new(0,6,0.5,-19)
end)

-- ============================================================
-- PANEL
-- ============================================================

local PAD = 14
local PW = 290
local IW = PW - PAD * 2
local PANEL_H = 220

local Panel = Instance.new("Frame")

Panel.Name = "Panel"

Panel.Size = UDim2.new(0,PW,0,PANEL_H)

Panel.BackgroundColor3 = PANEL_BG
Panel.BorderSizePixel = 0

Panel.Visible = false

Panel.ZIndex = 6
Panel.Parent = Gui

corner(Panel,12)
stroke(Panel,GREEN,1.8)

local CLOSED_POS = UDim2.new(0,-PW - 20,0.5,-PANEL_H / 2)
local OPEN_POS   = UDim2.new(0,52,0.5,-PANEL_H / 2)

Panel.Position = CLOSED_POS

-- ============================================================
-- TITLE BAR
-- ============================================================

local TitleBar = Instance.new("Frame")

TitleBar.Size = UDim2.new(1,0,0,38)

TitleBar.BackgroundColor3 = TITLE_BG
TitleBar.BorderSizePixel = 0

TitleBar.ZIndex = 7
TitleBar.Parent = Panel

corner(TitleBar,12)

local TitleFill = Instance.new("Frame")

TitleFill.Size = UDim2.new(1,0,0,14)
TitleFill.Position = UDim2.new(0,0,1,-14)

TitleFill.BackgroundColor3 = TITLE_BG
TitleFill.BorderSizePixel = 0

TitleFill.ZIndex = 7
TitleFill.Parent = TitleBar

makeLabel(
    TitleBar,
    "⚡  SERVER JOINER",
    12,
    0,
    220,
    38,
    14,
    Enum.TextXAlignment.Left,
    GREEN
)

local CloseBtn = Instance.new("TextButton")

CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Position = UDim2.new(1,-32,0,6)

CloseBtn.BackgroundColor3 = BLACK

CloseBtn.Text = "✕"
CloseBtn.TextColor3 = RED
CloseBtn.TextSize = 14

CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.AutoButtonColor = false

CloseBtn.ZIndex = 9
CloseBtn.Parent = TitleBar

corner(CloseBtn,6)

-- ============================================================
-- BUTTONS
-- ============================================================

local RejoinBtn = makeButton(
    Panel,
    "🔄   REJOIN GAME",
    PAD,
    70,
    IW,
    GREEN_DARK
)

local SameServerBtn = makeButton(
    Panel,
    "🚀   REJOIN SAME SERVER",
    PAD,
    120,
    IW,
    JOIN_BG
)

-- ============================================================
-- STATUS
-- ============================================================

local StatusLbl = Instance.new("TextLabel")

StatusLbl.Size = UDim2.new(0,IW,0,28)
StatusLbl.Position = UDim2.new(0,PAD,0,175)

StatusLbl.BackgroundTransparency = 1

StatusLbl.Text = ""
StatusLbl.TextColor3 = GREEN
StatusLbl.TextSize = 11

StatusLbl.Font = Enum.Font.Gotham

StatusLbl.TextXAlignment = Enum.TextXAlignment.Center
StatusLbl.TextYAlignment = Enum.TextYAlignment.Center

StatusLbl.TextWrapped = true

StatusLbl.ZIndex = 8
StatusLbl.Parent = Panel

local function setStatus(msg,isError)

    StatusLbl.Text = msg
    StatusLbl.TextColor3 = isError and RED or GREEN

end

-- ============================================================
-- OPEN / CLOSE
-- ============================================================

local isOpen = false

local function setOpen(val)

    isOpen = val

    if val then

        Panel.Visible = true

        tween(
            Panel,
            {Position = OPEN_POS},
            0.3,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        )

        Toggle.Text = "✕"

    else

        local t = TweenService:Create(
            Panel,
            TweenInfo.new(
                0.22,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ),
            {Position = CLOSED_POS}
        )

        t:Play()

        t.Completed:Connect(function()
            if not isOpen then
                Panel.Visible = false
            end
        end)

        Toggle.Text = "🔗"
    end
end

Toggle.MouseButton1Click:Connect(function()
    setOpen(not isOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

-- ============================================================
-- REJOIN GAME
-- ============================================================

RejoinBtn.MouseButton1Click:Connect(function()

    setStatus("🔄 Rejoining game...",false)

    TeleportService:Teleport(
        game.PlaceId,
        LocalPlayer
    )
end)

-- ============================================================
-- REJOIN SAME SERVER
-- ============================================================

SameServerBtn.MouseButton1Click:Connect(function()

    setStatus("🚀 Rejoining same server...",false)

    TeleportService:TeleportToPlaceInstance(
        game.PlaceId,
        game.JobId,
        LocalPlayer
    )
end)
