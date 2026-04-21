-- my booster niiger

game.StarterGui:SetCore("SendNotification", {
    Title = "Low Budget PC Roblox Graphic Saver",
    Text = "Graphic Saver načten!",
    Icon = "rbxassetid://10152375596",
    Duration = 5,
})

-- Unlock FPS
pcall(function()
    if syn and syn.set_fps_cap then syn.set_fps_cap(0) end
    if setfpscap then setfpscap(0) end
end)

local lighting = game.Lighting
local terrain = game.Workspace.Terrain
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local origValues = {
    GlobalShadows     = lighting.GlobalShadows,
    FogEnd            = lighting.FogEnd,
    FogStart          = lighting.FogStart,
    FogColor          = lighting.FogColor,
    Brightness        = lighting.Brightness,
    WaterWaveSize     = terrain.WaterWaveSize,
    WaterWaveSpeed    = terrain.WaterWaveSpeed,
    WaterReflectance  = terrain.WaterReflectance,
    WaterTransparency = terrain.WaterTransparency,
}

local DISABLE_CLASSES = {
    ParticleEmitter       = true,
    Trail                 = true,
    Smoke                 = true,
    Fire                  = true,
    Sparkles              = true,
    Beam                  = true,
    PostEffect            = true,
    Decal                 = true,
    Texture               = true,
    SelectionBox          = true,
    SelectionSphere       = true,
    BillboardGui          = true,
    SurfaceGui            = true,
    PointLight            = true,
    SpotLight             = true,
    SurfaceLight          = true,
    ColorCorrectionEffect = true,
    BloomEffect           = true,
    BlurEffect            = true,
    SunRaysEffect         = true,
    DepthOfFieldEffect    = true,
}

local savedObjects = {}
local savedSkyParent = nil
local enabled = false

local function applyBoost()
    savedObjects = {}

    -- Lighting
    lighting.GlobalShadows = false
    lighting.FogEnd        = 9e9
    lighting.FogStart      = 9e9
    lighting.Brightness    = 0

    -- Voda
    terrain.WaterWaveSize     = 0
    terrain.WaterWaveSpeed    = 0
    terrain.WaterReflectance  = 0
    terrain.WaterTransparency = 0

    -- Kvalita
    settings().Rendering.QualityLevel = "Level01"

    -- Atmosphere (hlavní příčina mlhy)
    local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        table.insert(savedObjects, {atmosphere, "Density", atmosphere.Density})
        table.insert(savedObjects, {atmosphere, "Offset",  atmosphere.Offset})
        table.insert(savedObjects, {atmosphere, "Haze",    atmosphere.Haze})
        atmosphere.Density = 0
        atmosphere.Offset  = 0
        atmosphere.Haze    = 0
    end

    -- Sky
    local sky = lighting:FindFirstChildOfClass("Sky")
    if sky then
        savedSkyParent = sky.Parent
        sky.Parent = nil
    end

    -- Všechny descendanty
    for _, v in ipairs(game:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then
                table.insert(savedObjects, {v, "Material",    v.Material})
                table.insert(savedObjects, {v, "Reflectance", v.Reflectance})
                table.insert(savedObjects, {v, "CastShadow",  v.CastShadow})
                v.Material    = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow  = false
            elseif DISABLE_CLASSES[v.ClassName] then
                table.insert(savedObjects, {v, "Enabled", v.Enabled})
                v.Enabled = false
            elseif v:IsA("SpecialMesh") then
                table.insert(savedObjects, {v, "LODFactor", v.LODFactor})
                v.LODFactor = 0
            end
        end)
    end
end

local function removeBoost()
    lighting.GlobalShadows    = origValues.GlobalShadows
    lighting.FogEnd           = origValues.FogEnd
    lighting.FogStart         = origValues.FogStart
    lighting.FogColor         = origValues.FogColor
    lighting.Brightness       = origValues.Brightness
    terrain.WaterWaveSize     = origValues.WaterWaveSize
    terrain.WaterWaveSpeed    = origValues.WaterWaveSpeed
    terrain.WaterReflectance  = origValues.WaterReflectance
    terrain.WaterTransparency = origValues.WaterTransparency
    settings().Rendering.QualityLevel = "Automatic"

    -- Obnov Sky
    if savedSkyParent then
        local sky = lighting:FindFirstChildOfClass("Sky")
        if not sky then
            -- sky byl uložen, vrátíme ho
        end
        savedSkyParent = nil
    end

    for _, data in ipairs(savedObjects) do
        pcall(function() data[1][data[2]] = data[3] end)
    end
    savedObjects = {}
end

-- ===== GUI =====
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

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "FPS Booster V1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 24)
fpsLabel.Position = UDim2.new(0, 0, 0, 28)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 13
fpsLabel.Parent = frame

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

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 122)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● Boost neaktivní"
statusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = frame

-- FPS Counter
local frameCount, lastTime = 0, tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local fps = math.round(frameCount / (now - lastTime))
        frameCount, lastTime = 0, now
        fpsLabel.Text = "FPS: " .. fps
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
        dragging, dragStart, startPos = true, input.Position, frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
