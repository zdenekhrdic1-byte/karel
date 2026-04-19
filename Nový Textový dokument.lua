-- Binh Hub FPS Booster V1

game.StarterGui:SetCore("SendNotification", {
    Title = "Binh Hub FPS Booster V1",
    Text = "FPS Booster načten!",
    Icon = "http://www.roblox.com/asset/?id=13450463175",
    Duration = 5,
})

-- Unlock FPS
local function unlockFPS()
    local success, err = pcall(function()
        local runService = game:GetService("RunService")
        -- Metoda 1: přes syn (executor funkce)
        if syn and syn.set_fps_cap then
            syn.set_fps_cap(0)
        end
        -- Metoda 2: přes setfpscap (podporují někteří executory)
        if setfpscap then
            setfpscap(0)
        end
    end)
end
unlockFPS()

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSBoosterGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0.5, -110, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Titulek
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "FPS Booster V1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

-- FPS Counter
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 24)
fpsLabel.Position = UDim2.new(0, 0, 0, 28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.Parent = frame

-- Toggle tlačítko
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
toggleBtn.Text = "✘ Vypnuto"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 122)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● Boost neaktivní"
statusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- FPS Counter logika
local fps = 0
local lastTime = tick()
local frameCount = 0

game:GetService("RunService").RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        fps = math.round(frameCount / (now - lastTime))
        frameCount = 0
        lastTime = now
        fpsLabel.Text = "FPS: " .. fps
        -- Barva podle výkonu
        if fps >= 100 then
            fpsLabel.TextColor3 = Color3.fromRGB(0, 220, 80)
        elseif fps >= 60 then
            fpsLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        else
            fpsLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        end
    end
end)

-- Uložení původních hodnot
local lighting = game.Lighting
local terrain = game.Workspace.Terrain

local origValues = {
    GlobalShadows    = lighting.GlobalShadows,
    FogEnd           = lighting.FogEnd,
    FogStart         = lighting.FogStart,
    FogColor         = lighting.FogColor,
    Brightness       = lighting.Brightness,
    WaterWaveSize    = terrain.WaterWaveSize,
    WaterWaveSpeed   = terrain.WaterWaveSpeed,
    WaterReflectance = terrain.WaterReflectance,
    WaterTransparency= terrain.WaterTransparency,
}

local savedObjects = {} -- { obj, prop, origValue }
local enabled = false

local function applyBoost()
    -- Lighting
    lighting.GlobalShadows = false
    lighting.FogEnd = 9e9      -- prakticky nekonečno = žádná mlha
    lighting.FogStart = 9e9
    lighting.Brightness = 0

    -- Terrain voda
    terrain.WaterWaveSize    = 0
    terrain.WaterWaveSpeed   = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency= 0

    -- Kvalita renderování
    settings().Rendering.QualityLevel = "Level01"

    -- Procházení descendantů
    savedObjects = {}
    for _, v in ipairs(game:GetDescendants()) do
        local ok, _ = pcall(function()
            if v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
                table.insert(savedObjects, {v, "Material", v.Material})
                table.insert(savedObjects, {v, "Reflectance", v.Reflectance})
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                table.insert(savedObjects, {v, "Transparency", v.Transparency})
                v.Transparency = 1
            elseif v:IsA("Trail") then
                table.insert(savedObjects, {v, "Lifetime", v.Lifetime})
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("ParticleEmitter") then
                table.insert(savedObjects, {v, "Enabled", v.Enabled})
                v.Enabled = false
            elseif v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                table.insert(savedObjects, {v, "Enabled", v.Enabled})
                v.Enabled = false
            elseif v:IsA("SpecialMesh") then
                -- nechaj, ale zniž detail
            elseif v:IsA("PostEffect") then
                table.insert(savedObjects, {v, "Enabled", v.Enabled})
                v.Enabled = false
            end
        end)
    end
end

local function removeBoost()
    -- Obnov Lighting
    lighting.GlobalShadows = origValues.GlobalShadows
    lighting.FogEnd         = origValues.FogEnd
    lighting.FogStart       = origValues.FogStart
    lighting.FogColor       = origValues.FogColor
    lighting.Brightness     = origValues.Brightness

    -- Obnov terén
    terrain.WaterWaveSize    = origValues.WaterWaveSize
    terrain.WaterWaveSpeed   = origValues.WaterWaveSpeed
    terrain.WaterReflectance = origValues.WaterReflectance
    terrain.WaterTransparency= origValues.WaterTransparency

    -- Obnov kvalitu
    settings().Rendering.QualityLevel = "Automatic"

    -- Obnov objekty
    for _, data in ipairs(savedObjects) do
        local ok, _ = pcall(function()
            data[1][data[2]] = data[3]
        end)
    end
    savedObjects = {}
end

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        applyBoost()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        toggleBtn.Text = "✔ Zapnuto"
        statusLabel.Text = "● Boost aktivní"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 80)
    else
        removeBoost()
        toggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        toggleBtn.Text = "✘ Vypnuto"
        statusLabel.Text = "● Boost neaktivní"
        statusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Draggable
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)