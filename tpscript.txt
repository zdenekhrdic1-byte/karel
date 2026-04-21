-- ╔══════════════════════════════════════════╗
-- ║         ADMIN GUI  –  by Claude          ║
-- ║  Green/Black • Draggable • Resizable     ║
-- ║  Draggable icon • Shrink-to-icon anim    ║
-- ╚══════════════════════════════════════════╝

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UIS               = game:GetService("UserInputService")

local LocalPlayer       = Players.LocalPlayer
local PlayerGui         = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════
local MIN_W, MIN_H   = 420, 340
local MAX_W, MAX_H   = 860, 700
local DEF_W, DEF_H   = 560, 420
local ICON_SIZE      = 50
local savedPosition  = nil

-- ══════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "AdminGUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = PlayerGui

-- ══════════════════════════════════════════
--  OPEN ICON  (draggable)
-- ══════════════════════════════════════════
local IconBtn = Instance.new("ImageButton")
IconBtn.Name             = "IconBtn"
IconBtn.Size             = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
IconBtn.Position         = UDim2.new(0, 14, 1, -64)
IconBtn.BackgroundColor3 = Color3.fromRGB(10, 28, 10)
IconBtn.BorderSizePixel  = 0
IconBtn.Image            = "rbxassetid://7733960981"
IconBtn.ImageColor3      = Color3.fromRGB(0, 235, 90)
IconBtn.ZIndex           = 20
IconBtn.Visible          = false          -- hidden while window is open
IconBtn.Parent           = ScreenGui

Instance.new("UICorner", IconBtn).CornerRadius = UDim.new(0, 10)
local iconStroke = Instance.new("UIStroke", IconBtn)
iconStroke.Color     = Color3.fromRGB(0, 200, 70)
iconStroke.Thickness = 2

-- Icon hover glow
IconBtn.MouseEnter:Connect(function()
    TweenService:Create(IconBtn, TweenInfo.new(.15), {
        BackgroundColor3 = Color3.fromRGB(0, 55, 20),
        Size             = UDim2.new(0, ICON_SIZE+6, 0, ICON_SIZE+6)
    }):Play()
end)
IconBtn.MouseLeave:Connect(function()
    TweenService:Create(IconBtn, TweenInfo.new(.15), {
        BackgroundColor3 = Color3.fromRGB(10, 28, 10),
        Size             = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
    }):Play()
end)

-- Icon drag logic
do
    local dragging, dragStart, iconStart = false, nil, nil
    local moved = false

    IconBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            moved      = false
            dragStart  = inp.Position
            iconStart  = IconBtn.Position
        end
    end)

    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStart
            if d.Magnitude > 5 then moved = true end
            IconBtn.Position = UDim2.new(
                iconStart.X.Scale, iconStart.X.Offset + d.X,
                iconStart.Y.Scale, iconStart.Y.Offset + d.Y)
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Only open if it was a click, not a drag
    IconBtn.MouseButton1Click:Connect(function()
        if not moved then openGUI() end
    end)
end

-- ══════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, DEF_W, 0, DEF_H)
MainFrame.Position         = UDim2.new(0.5, -DEF_W/2, 0.5, -DEF_H/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(7, 15, 7)
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex           = 10
MainFrame.Parent           = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 170, 60)
do
    local s = MainFrame:FindFirstChildOfClass("UIStroke"); s.Thickness = 1.5
    local g = Instance.new("UIGradient", MainFrame)
    g.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(11,24,11)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(5,11,5))})
    g.Rotation = 135
end

-- ── TITLE BAR ───────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 38, 14)
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 11
TitleBar.Parent           = MainFrame

do
    local g = Instance.new("UIGradient", TitleBar)
    g.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,58,20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,28,10))})
    g.Rotation = 90
end

local TitleIcon = Instance.new("ImageLabel", TitleBar)
TitleIcon.Size              = UDim2.new(0,22,0,22)
TitleIcon.Position          = UDim2.new(0,10,0.5,-11)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image             = "rbxassetid://7733960981"
TitleIcon.ImageColor3       = Color3.fromRGB(0,255,100)
TitleIcon.ZIndex            = 12

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size               = UDim2.new(1,-120,1,0)
TitleLbl.Position           = UDim2.new(0,38,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "ADMIN PANEL"
TitleLbl.TextColor3         = Color3.fromRGB(0,255,100)
TitleLbl.TextSize           = 15
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left
TitleLbl.ZIndex             = 12

-- Minimize button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size               = UDim2.new(0,30,0,30)
MinBtn.Position           = UDim2.new(1,-74,0.5,-15)
MinBtn.BackgroundColor3   = Color3.fromRGB(160,120,0)
MinBtn.BorderSizePixel    = 0
MinBtn.Text               = "—"
MinBtn.TextColor3         = Color3.fromRGB(255,255,255)
MinBtn.TextSize           = 14
MinBtn.Font               = Enum.Font.GothamBold
MinBtn.ZIndex             = 13
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)

-- Close button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size               = UDim2.new(0,30,0,30)
CloseBtn.Position           = UDim2.new(1,-38,0.5,-15)
CloseBtn.BackgroundColor3   = Color3.fromRGB(180,30,30)
CloseBtn.BorderSizePixel    = 0
CloseBtn.Text               = "✕"
CloseBtn.TextColor3         = Color3.fromRGB(255,255,255)
CloseBtn.TextSize           = 14
CloseBtn.Font               = Enum.Font.GothamBold
CloseBtn.ZIndex             = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Button hover
for _, b in ipairs({MinBtn, CloseBtn}) do
    local orig = b.BackgroundColor3
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(.1),{
            BackgroundColor3=Color3.new(math.min(orig.R+.15,1),math.min(orig.G+.15,1),math.min(orig.B+.15,1))
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(.1),{BackgroundColor3=orig}):Play()
    end)
end

-- ── RESIZE HANDLE ───────────────────────────
local ResizeHandle = Instance.new("Frame", MainFrame)
ResizeHandle.Name             = "ResizeHandle"
ResizeHandle.Size             = UDim2.new(0,20,0,20)
ResizeHandle.Position         = UDim2.new(1,-20,1,-20)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(0,130,48)
ResizeHandle.BorderSizePixel  = 0
ResizeHandle.ZIndex           = 15
Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0,4)

-- grip dots
for row = 0,2 do
    for col = 0,2 do
        if row+col >= 2 then
            local dot = Instance.new("Frame", ResizeHandle)
            dot.Size              = UDim2.new(0,3,0,3)
            dot.Position          = UDim2.new(0, 3+col*5, 0, 3+row*5)
            dot.BackgroundColor3  = Color3.fromRGB(0,255,100)
            dot.BorderSizePixel   = 0
            dot.ZIndex            = 16
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
        end
    end
end

-- invisible click layer on handle
local ResizeBtn = Instance.new("TextButton", ResizeHandle)
ResizeBtn.Size               = UDim2.new(1,0,1,0)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text               = ""
ResizeBtn.ZIndex             = 17

-- ── CONTENT FRAME ───────────────────────────
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Name             = "Content"
ContentFrame.Size             = UDim2.new(1,-16,1,-52)
ContentFrame.Position         = UDim2.new(0,8,0,44)
ContentFrame.BackgroundTransparency = 1

-- ══════════════════════════════════════════
--  LEFT PANEL
-- ══════════════════════════════════════════
local LeftPanel = Instance.new("Frame", ContentFrame)
LeftPanel.Size                = UDim2.new(0.55,-6,1,0)
LeftPanel.BackgroundTransparency = 1

do
    local ul=Instance.new("UIListLayout",LeftPanel)
    ul.SortOrder=Enum.SortOrder.LayoutOrder
    ul.Padding=UDim.new(0,7)
end

-- helpers ──────────────────────────────────
local function mkLabel(parent, txt, order)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,0,0,15); l.BackgroundTransparency=1
    l.Text=txt; l.TextColor3=Color3.fromRGB(0,210,85)
    l.TextSize=11; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.LayoutOrder=order or 0
    return l
end

local function mkBox(parent, ph, order)
    local b=Instance.new("TextBox",parent)
    b.Size=UDim2.new(1,0,0,34); b.BackgroundColor3=Color3.fromRGB(11,26,11)
    b.BorderSizePixel=0; b.PlaceholderText=ph
    b.PlaceholderColor3=Color3.fromRGB(0,110,45); b.Text=""
    b.TextColor3=Color3.fromRGB(180,255,180); b.TextSize=13
    b.Font=Enum.Font.Gotham; b.ClearTextOnFocus=false
    b.LayoutOrder=order or 0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(0,120,48); s.Thickness=1
    local p=Instance.new("UIPadding",b); p.PaddingLeft=UDim.new(0,8)
    b.Focused:Connect(function() TweenService:Create(s,TweenInfo.new(.15),{Color=Color3.fromRGB(0,255,100)}):Play() end)
    b.FocusLost:Connect(function() TweenService:Create(s,TweenInfo.new(.15),{Color=Color3.fromRGB(0,120,48)}):Play() end)
    return b
end

local function mkBtn(parent, txt, col, order)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,34); b.BackgroundColor3=col
    b.BorderSizePixel=0; b.Text=txt
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=12
    b.Font=Enum.Font.GothamBold; b.LayoutOrder=order or 0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local origCol=col
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(.1),{BackgroundColor3=Color3.new(
            math.min(origCol.R+.12,1),math.min(origCol.G+.12,1),math.min(origCol.B+.12,1))}):Play()
    end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.1),{BackgroundColor3=origCol}):Play() end)
    b.MouseButton1Down:Connect(function() TweenService:Create(b,TweenInfo.new(.07),{Size=UDim2.new(.97,0,0,31)}):Play() end)
    b.MouseButton1Up:Connect(function() TweenService:Create(b,TweenInfo.new(.07),{Size=UDim2.new(1,0,0,34)}):Play() end)
    return b
end

local function mkDivider(parent, order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,1); f.BackgroundColor3=Color3.fromRGB(0,70,25)
    f.BorderSizePixel=0; f.LayoutOrder=order
    return f
end

-- ── Player name ─────────────────────────────
mkLabel(LeftPanel, "  👤  PLAYER NAME", 1)
local PlayerNameBox = mkBox(LeftPanel, "Enter player name...", 2)
local TpPlayerBtn   = mkBtn(LeftPanel, "⚡  TELEPORT TO PLAYER", Color3.fromRGB(0,128,48), 3)
mkDivider(LeftPanel, 4)

-- ── Coordinates ─────────────────────────────
mkLabel(LeftPanel, "  📍  COORDINATES  ( X  Y  Z )", 5)
local CoordsBox = mkBox(LeftPanel, "e.g.  1001.10  100.10  11.10", 6)

local hintLbl=Instance.new("TextLabel",LeftPanel)
hintLbl.Size=UDim2.new(1,0,0,12); hintLbl.BackgroundTransparency=1
hintLbl.Text="  Format:  X Y Z  separated by spaces"
hintLbl.TextColor3=Color3.fromRGB(0,110,45); hintLbl.TextSize=10
hintLbl.Font=Enum.Font.Gotham; hintLbl.TextXAlignment=Enum.TextXAlignment.Left
hintLbl.LayoutOrder=7

local SavePosBtn  = mkBtn(LeftPanel, "💾  SAVE CURRENT POSITION", Color3.fromRGB(0,95,155), 8)
local TpCoordsBtn = mkBtn(LeftPanel, "🎯  TELEPORT TO COORDS",    Color3.fromRGB(0,128,48), 9)

local savedLbl=Instance.new("TextLabel",LeftPanel)
savedLbl.Size=UDim2.new(1,0,0,13); savedLbl.BackgroundTransparency=1
savedLbl.Text="  Saved position:  —"
savedLbl.TextColor3=Color3.fromRGB(0,170,75); savedLbl.TextSize=10
savedLbl.Font=Enum.Font.Gotham; savedLbl.TextXAlignment=Enum.TextXAlignment.Left
savedLbl.LayoutOrder=10

-- ══════════════════════════════════════════
--  VERTICAL DIVIDER
-- ══════════════════════════════════════════
local VDiv=Instance.new("Frame",ContentFrame)
VDiv.Size=UDim2.new(0,1,1,0); VDiv.Position=UDim2.new(0.55,2,0,0)
VDiv.BackgroundColor3=Color3.fromRGB(0,75,28); VDiv.BorderSizePixel=0

-- ══════════════════════════════════════════
--  RIGHT PANEL  –  scrollable player list
-- ══════════════════════════════════════════
local RightPanel=Instance.new("Frame",ContentFrame)
RightPanel.Size=UDim2.new(0.45,-10,1,0)
RightPanel.Position=UDim2.new(0.55,8,0,0)
RightPanel.BackgroundTransparency=1

local onlineHdr=Instance.new("TextLabel",RightPanel)
onlineHdr.Size=UDim2.new(1,0,0,20); onlineHdr.BackgroundTransparency=1
onlineHdr.Text="🟢  PLAYERS ONLINE"
onlineHdr.TextColor3=Color3.fromRGB(0,220,90); onlineHdr.TextSize=12
onlineHdr.Font=Enum.Font.GothamBold; onlineHdr.TextXAlignment=Enum.TextXAlignment.Left

local ScrollFrame=Instance.new("ScrollingFrame",RightPanel)
ScrollFrame.Size=UDim2.new(1,0,1,-24); ScrollFrame.Position=UDim2.new(0,0,0,24)
ScrollFrame.BackgroundColor3=Color3.fromRGB(6,13,6); ScrollFrame.BorderSizePixel=0
ScrollFrame.ScrollBarThickness=4; ScrollFrame.ScrollBarImageColor3=Color3.fromRGB(0,180,60)
ScrollFrame.CanvasSize=UDim2.new(0,0,0,0); ScrollFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y
Instance.new("UICorner",ScrollFrame).CornerRadius=UDim.new(0,7)
Instance.new("UIStroke",ScrollFrame).Color=Color3.fromRGB(0,90,35)
do
    local ul=Instance.new("UIListLayout",ScrollFrame)
    ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,4)
    local p=Instance.new("UIPadding",ScrollFrame)
    p.PaddingTop=UDim.new(0,4); p.PaddingLeft=UDim.new(0,4); p.PaddingRight=UDim.new(0,4)
end

local function createCard(plr)
    local card=Instance.new("Frame",ScrollFrame)
    card.Name=plr.Name; card.Size=UDim2.new(1,0,0,62)
    card.BackgroundColor3=Color3.fromRGB(11,24,11); card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,7)
    local cs=Instance.new("UIStroke",card); cs.Color=Color3.fromRGB(0,75,28); cs.Thickness=1

    -- Avatar
    local av=Instance.new("ImageLabel",card)
    av.Size=UDim2.new(0,42,0,42); av.Position=UDim2.new(0,6,0.5,-21)
    av.BackgroundColor3=Color3.fromRGB(0,38,14); av.BorderSizePixel=0
    Instance.new("UICorner",av).CornerRadius=UDim.new(0,6)
    local ok,img=pcall(function()
        return Players:GetUserThumbnailAsync(plr.UserId,
            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    end)
    av.Image = ok and img or "rbxassetid://7733960981"
    if not ok then av.ImageColor3=Color3.fromRGB(0,200,80) end

    -- Display name
    local dn=Instance.new("TextLabel",card)
    dn.Size=UDim2.new(1,-56,0,20); dn.Position=UDim2.new(0,54,0,8)
    dn.BackgroundTransparency=1; dn.Text=plr.DisplayName
    dn.TextColor3=Color3.fromRGB(215,255,215); dn.TextSize=12
    dn.Font=Enum.Font.GothamBold; dn.TextXAlignment=Enum.TextXAlignment.Left
    dn.TextTruncate=Enum.TextTruncate.AtEnd

    -- @username
    local un=Instance.new("TextLabel",card)
    un.Size=UDim2.new(1,-56,0,14); un.Position=UDim2.new(0,54,0,28)
    un.BackgroundTransparency=1; un.Text="@"..plr.Name
    un.TextColor3=Color3.fromRGB(0,155,65); un.TextSize=10
    un.Font=Enum.Font.Gotham; un.TextXAlignment=Enum.TextXAlignment.Left
    un.TextTruncate=Enum.TextTruncate.AtEnd

    -- Click to fill name box
    local cb=Instance.new("TextButton",card)
    cb.Size=UDim2.new(1,0,1,0); cb.BackgroundTransparency=1; cb.Text=""; cb.ZIndex=5
    cb.MouseEnter:Connect(function()
        TweenService:Create(card,TweenInfo.new(.1),{BackgroundColor3=Color3.fromRGB(0,36,16)}):Play()
        TweenService:Create(cs,TweenInfo.new(.1),{Color=Color3.fromRGB(0,170,65)}):Play()
    end)
    cb.MouseLeave:Connect(function()
        TweenService:Create(card,TweenInfo.new(.1),{BackgroundColor3=Color3.fromRGB(11,24,11)}):Play()
        TweenService:Create(cs,TweenInfo.new(.1),{Color=Color3.fromRGB(0,75,28)}):Play()
    end)
    cb.MouseButton1Click:Connect(function() PlayerNameBox.Text=plr.Name end)
    return card
end

local function refreshList()
    for _,c in ipairs(ScrollFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _,p in ipairs(Players:GetPlayers()) do createCard(p) end
end

refreshList()
Players.PlayerAdded:Connect(function(p) task.wait(1); createCard(p) end)
Players.PlayerRemoving:Connect(function(p)
    local c=ScrollFrame:FindFirstChild(p.Name); if c then c:Destroy() end
end)

-- ══════════════════════════════════════════
--  OPEN / CLOSE  –  shrink / expand to icon
-- ══════════════════════════════════════════
local function getIconAbsCenter()
    -- Compute absolute pixel center of the icon
    local vp = workspace.CurrentCamera.ViewportSize
    local ox  = IconBtn.Position.X.Offset + (IconBtn.Position.X.Scale * vp.X)
    local oy  = IconBtn.Position.Y.Offset + (IconBtn.Position.Y.Scale * vp.Y)
    return Vector2.new(ox + ICON_SIZE/2, oy + ICON_SIZE/2)
end

-- Forward declare so closeGUI can reference openGUI reference
function openGUI()
    local ic  = getIconAbsCenter()
    local vp  = workspace.CurrentCamera.ViewportSize
    local tw, th = DEF_W, DEF_H

    -- Restore size if user had resized last session
    if MainFrame.Size.X.Offset > 0 then
        tw = MainFrame.Size.X.Offset
        th = MainFrame.Size.Y.Offset
    end

    -- Start from icon center at size 0
    MainFrame.Size     = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0, ic.X, 0, ic.Y)
    MainFrame.Visible  = true
    IconBtn.Visible    = false

    local tx = math.clamp(ic.X - tw/2, 4, vp.X - tw - 4)
    local ty = math.clamp(ic.Y - th/2, 4, vp.Y - th - 4)

    TweenService:Create(MainFrame,
        TweenInfo.new(.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size     = UDim2.new(0, tw, 0, th),
        Position = UDim2.new(0, tx, 0, ty)
    }):Play()
end

local function closeGUI()
    local ic = getIconAbsCenter()
    local tw = TweenService:Create(MainFrame,
        TweenInfo.new(.28, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, ic.X, 0, ic.Y)
    })
    tw:Play()
    tw.Completed:Connect(function()
        MainFrame.Visible = false
        IconBtn.Visible   = true
    end)
end

CloseBtn.MouseButton1Click:Connect(closeGUI)
MinBtn.MouseButton1Click:Connect(closeGUI)

-- ══════════════════════════════════════════
--  WINDOW DRAG  (title bar)
-- ══════════════════════════════════════════
do
    local dragging, dragStart, winStart = false, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            winStart  = MainFrame.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStart
            MainFrame.Position = UDim2.new(
                winStart.X.Scale, winStart.X.Offset + d.X,
                winStart.Y.Scale, winStart.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ══════════════════════════════════════════
--  RESIZE  (bottom-right corner handle)
-- ══════════════════════════════════════════
do
    local resizing, resStart, sizeStart = false, nil, nil
    ResizeBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            resizing  = true
            resStart  = inp.Position
            sizeStart = Vector2.new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not resizing then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d  = inp.Position - resStart
            local nw = math.clamp(sizeStart.X + d.X, MIN_W, MAX_W)
            local nh = math.clamp(sizeStart.Y + d.Y, MIN_H, MAX_H)
            MainFrame.Size = UDim2.new(0, nw, 0, nh)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
end

-- ══════════════════════════════════════════
--  TELEPORT LOGIC
-- ══════════════════════════════════════════
local function parseCoords(txt)
    local parts={}
    for v in txt:gmatch("[%-]?%d+%.?%d*") do parts[#parts+1]=tonumber(v) end
    if #parts>=3 then return Vector3.new(parts[1],parts[2],parts[3]) end
    return nil
end

local function flashBtn(btn, ok_txt, fail_txt, success, orig)
    btn.Text = success and ok_txt or fail_txt
    task.delay(1.5, function() btn.Text = orig end)
end

TpCoordsBtn.MouseButton1Click:Connect(function()
    local orig = "🎯  TELEPORT TO COORDS"
    local pos  = parseCoords(CoordsBox.Text)
    if pos then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame=CFrame.new(pos); flashBtn(TpCoordsBtn,"✅  TELEPORTED!","",true,orig)
        else flashBtn(TpCoordsBtn,"","❌  NO CHARACTER",false,orig) end
    else flashBtn(TpCoordsBtn,"","❌  BAD FORMAT — use X Y Z",false,orig) end
end)

SavePosBtn.MouseButton1Click:Connect(function()
    local orig = "💾  SAVE CURRENT POSITION"
    local hrp  = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedPosition = hrp.Position
        local x,y,z = math.floor(savedPosition.X*100)/100,
                      math.floor(savedPosition.Y*100)/100,
                      math.floor(savedPosition.Z*100)/100
        savedLbl.Text  = string.format("  💾 Saved: %.2f  %.2f  %.2f",x,y,z)
        CoordsBox.Text = string.format("%.2f %.2f %.2f",x,y,z)
        flashBtn(SavePosBtn,"✅  SAVED!","",true,orig)
    end
end)

TpPlayerBtn.MouseButton1Click:Connect(function()
    local orig = "⚡  TELEPORT TO PLAYER"
    local name = PlayerNameBox.Text
    if name=="" then flashBtn(TpPlayerBtn,"","❌  ENTER A NAME",false,orig); return end
    local target
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower()==name:lower() or p.DisplayName:lower()==name:lower()
        or p.Name:lower():find(name:lower(),1,true) then target=p; break end
    end
    if target and target.Character then
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local mHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tHRP and mHRP then
            mHRP.CFrame = tHRP.CFrame + Vector3.new(3,0,0)
            flashBtn(TpPlayerBtn,"✅  TELEPORTED!","",true,orig)
        else flashBtn(TpPlayerBtn,"","❌  NO CHARACTER",false,orig) end
    else flashBtn(TpPlayerBtn,"","❌  PLAYER NOT FOUND",false,orig) end
end)

-- ══════════════════════════════════════════
--  STARTUP
-- ══════════════════════════════════════════
MainFrame.Visible = true
IconBtn.Visible   = false

print("[AdminGUI] ✅ Loaded!")
