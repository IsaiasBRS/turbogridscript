-- ========== TURBO GRID MOD MENU v4.0 (ALPHA - CARRO INDOMÁVEL) ==========
-- Funciona em: Carros com câmbio limitado (Remove 1ª marcha <300km/h)
-- Soluciona: Seletor que zera para 50
-- ============================================================

local Version = "4.0-Alpha"
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if Player.Name ~= "catuabinha_hb" then
    warn("❌ ERRO: USER BLOQUEADO: " .. Player.Name)
    return
end

local Stats = {
    SpeedHack = false,
    GodMode = false,
    VehicleSpeed = false,
    WalkSpeed = 200,
    VehicleMaxSpeed = 300,
    VehicleForce = 500000
}

local OriginalStats = {WalkSpeed = 16, MaxHealth = 100}
local CurrentVehicleSeat = nil
local OriginalMaxSpeed = nil
local TurboTorque = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TurboGrid_v4_0"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 330)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.Text = "Turbo Grid v4.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(
    function()
        ScreenGui:Destroy()
    end
)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 6
Content.CanvasSize = UDim2.new(0, 0, 0, 600)
Content.Parent = MainFrame

local function createToggle(name, startPos, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.Position = UDim2.new(0, 5, 0, startPos)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.Parent = Content
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 60, 0, 30)
    Button.Position = UDim2.new(1, -65, 0.5, -15)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.new(1, 0, 0)
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Frame
    local active = false
    Button.MouseButton1Click:Connect(
        function()
            active = not active
            Button.Text = active and "ON" or "OFF"
            Button.TextColor3 = active and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            callback(active)
        end
    )
    return Frame
end

local function createSlider(name, startPos, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.Position = UDim2.new(0, 5, 0, startPos)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.Parent = Content
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 5, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size = UDim2.new(0.8, 0, 0, 20)
    SliderBtn.Position = UDim2.new(0.1, 0, 1, -25)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    SliderBtn.Text = ""
    SliderBtn.Parent = Frame
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 0, 1, 0)
    Indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    Indicator.Parent = SliderBtn
    local dragging = false
    SliderBtn.InputBegan:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end
    )
    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end
    )
    SliderBtn.InputChanged:Connect(
        function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos =
                    UDim2.new(
                    0,
                    math.clamp(input.Position.X - SliderBtn.AbsolutePosition.X, 0, SliderBtn.AbsoluteSize.X),
                    0,
                    0
                )
                Indicator.Size = pos
                local val = math.floor(min + (max - min) * pos.X.Scale)
                Label.Text = name .. ": " .. val
                callback(val)
            end
        end
    )
    Indicator.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
end

-- Sliders e Toggles
local yOffset = 10

createToggle(
    "Speed Hack Personagem",
    yOffset,
    function(state)
        Stats.SpeedHack = state
        local Humanoid = Player.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = state and Stats.WalkSpeed or OriginalStats.WalkSpeed
        end
    end
)
yOffset = yOffset + 50

createSlider(
    "Velocidade Personagem",
    yOffset,
    10,
    500,
    Stats.WalkSpeed,
    function(val)
        Stats.WalkSpeed = val
        if Stats.SpeedHack then
            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = val
            end
        end
    end
)
yOffset = yOffset + 60

createToggle(
    "Turbo Veículo (Overdrive)",
    yOffset,
    function(state)
        Stats.VehicleSpeed = state
        if not state and TurboTorque then
            TurboTorque:Destroy()
        end
    end
)
yOffset = yOffset + 50

createSlider(
    "Força do Carro",
    yOffset,
    10000,
    1000000,
    Stats.VehicleForce,
    function(val)
        Stats.VehicleForce = val
    end
)
yOffset = yOffset + 60

createSlider(
    "Velocidade Máxima (km/h)",
    yOffset,
    50,
    1000,
    Stats.VehicleMaxSpeed,
    function(val)
        Stats.VehicleMaxSpeed = val
    end
)
yOffset = yOffset + 60

createToggle(
    "God Mode",
    yOffset,
    function(state)
        Stats.GodMode = state
        local Humanoid = Player.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.MaxHealth = state and math.huge or OriginalStats.MaxHealth
            Humanoid.Health = Humanoid.MaxHealth
        end
    end
)
yOffset = yOffset + 50

local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.9, 0, 0, 40)
ResetBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ResetBtn.Text = "RESETAR TUDO"
ResetBtn.TextColor3 = Color3.new(1, 1, 1)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = Content
ResetBtn.MouseButton1Click:Connect(
    function()
        Stats.SpeedHack = false
        Stats.VehicleSpeed = false
        Stats.GodMode = false
        if TurboTorque then
            TurboTorque:Destroy()
        end
        local Humanoid = Player.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = OriginalStats.WalkSpeed
            Humanoid.MaxHealth = OriginalStats.MaxHealth
            Humanoid.Health = OriginalStats.MaxHealth
        end
        if CurrentVehicleSeat then
            CurrentVehicleSeat.MaxSpeed = OriginalMaxSpeed or 100
        end
        ScreenGui:Destroy()
        wait(0.5)
        loadstring(
            game:HttpGet(
                "https://raw.githubusercontent.com/IsaiasBRS/turbogridscript/refs/heads/main/turbogridmenu.lua"
            )
        )()
    end
)

Content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 60)

-- FUNÇÕES DE VEÍCULO
function ForceVehicleOverdrive()
    if not CurrentVehicleSeat then
        return
    end
    local chassi = CurrentVehicleSeat.RootPart
    if not chassi then
        return
    end

    -- Destrói BodyVelocity velho se existir
    local oldBv = chassi:FindFirstChild("BodyVelocity")
    if oldBv then
        oldBv:Destroy()
    end

    -- Adiciona nova força absoluta
    local bv = Instance.new("BodyVelocity")
    bv.Name = "TurboGrid_TurboForce"
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.P = 1e9
    bv.Velocity = chassi.CFrame.LookVector * (Stats.VehicleMaxSpeed * 0.53) -- magic number km/h -> m/s multiplicador
    bv.Parent = chassi

    -- Torque extra para quebra de marchas
    TurboTorque = Instance.new("BodyAngularVelocity")
    TurboTorque.Name = "TurboGrid_Torque"
    TurboTorque.MaxTorque = Vector3.new(1e12, 1e12, 1e12)
    TurboTorque.AngularVelocity = Vector3.new(0, 50000, 0)
    TurboTorque.Parent = chassi

    -- Remove limite de marchas
    if OriginalMaxSpeed == nil then
        OriginalMaxSpeed = CurrentVehicleSeat.MaxSpeed
    end
    CurrentVehicleSeat.MaxSpeed = 1000
    print(" Câmbio forçado: primeira marcha > 300km/h")
end

function CheckVehicle()
    local char = Player.Character
    if not char then
        return
    end

    local seat = char:FindFirstChildWhichIsA("VehicleSeat")
    if not seat then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("VehicleSeat") and obj.Occupant == Player then
                seat = obj
                break
            end
        end
    end

    if seat and seat.Parent then
        if seat ~= CurrentVehicleSeat then
            CurrentVehicleSeat = seat
            print("[v4.0] Veículo Detectado:", seat.Parent.Name)
        end
    else
        if CurrentVehicleSeat then
            if OriginalMaxSpeed then
                CurrentVehicleSeat.MaxSpeed = OriginalMaxSpeed
            end
            CurrentVehicleSeat = nil
        end
    end
end

-- LOOP PRINCIPAL ESTÁVEL
RunService.Heartbeat:Connect(
    function()
        if Stats.VehicleSpeed then
            CheckVehicle()
            if CurrentVehicleSeat then
                ForceVehicleOverdrive()
            end
        end

        -- Personagem e GodMode
        if Stats.SpeedHack then
            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = Stats.WalkSpeed
            end
        end

        if Stats.GodMode then
            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end
    end
)

Player.CharacterAdded:Connect(
    function()
        wait(1)
        CurrentVehicleSeat = nil
        TurboTorque = nil
    end
)

print("✅ Turbo Grid v4.0 Iniciado. Carro Indomável ligado.")
