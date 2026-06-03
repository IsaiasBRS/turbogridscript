-- ========== TURBO GRID MOD MENU v3.1 (ADVANCED VEHICLE OVERRIDE) ==========
-- Foco: Carros com física complexa (RPM/Marchas)
-- Detecta e anula limitadores de velocidade nativos
-- ============================================================

local Version = "3.1-AdvancedOverride"
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if Player.Name ~= "catuabinha_hb" then
    return
end

-- ========== CONFIGURAÇÕES ==========
local Stats = {
    SpeedHack = false,
    GodMode = false,
    VehicleSpeed = false,
    WalkSpeed = 200,
    VehicleForce = 100000, -- Aumentado padrão
    VehicleMaxSpeed = 500 -- Nova variável de alvo
}

local OriginalStats = {WalkSpeed = 16, MaxHealth = 100}
local CurrentVehiclePart = nil
local CurrentVehicleSeat = nil
local OriginalMaxSpeed = nil
local OriginalPlatformStand = nil

-- ========== UI (Mesma estrutura, atualizada para v3.1) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TurboGrid_v3.1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 320)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.Text = "Turbo Grid v3.1 | Override Física"
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
Content.CanvasSize = UDim2.new(0, 0, 0, 550)
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

local yOffset = 10

createToggle(
    "Speed Hack (Personagem)",
    yOffset,
    function(state)
        Stats.SpeedHack = state
        local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
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
            local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = val
            end
        end
    end
)
yOffset = yOffset + 60

createToggle(
    "Turbo Veículo (Override)",
    yOffset,
    function(state)
        Stats.VehicleSpeed = state
        if not state then
            ResetVehicle()
        end
    end
)
yOffset = yOffset + 50

createSlider(
    "Força do Motor",
    yOffset,
    10000,
    1000000,
    Stats.VehicleForce,
    function(val)
        Stats.VehicleForce = val
        if Stats.VehicleSpeed and CurrentVehiclePart then
            ApplyVehicleForce()
        end
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
        if Stats.VehicleSpeed and CurrentVehicleSeat then
            ApplySpeedLimitOverride()
        end
    end
)
yOffset = yOffset + 60

createToggle(
    "God Mode",
    yOffset,
    function(state)
        Stats.GodMode = state
        local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
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
        ResetVehicle()
        local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = OriginalStats.WalkSpeed
            Humanoid.MaxHealth = OriginalStats.MaxHealth
            Humanoid.Health = OriginalStats.MaxHealth
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

-- ========== LÓGICA AVANÇADA DE VEÍCULO ==========

function ResetVehicle()
    if CurrentVehiclePart then
        local bv = CurrentVehiclePart:FindFirstChild("BodyVelocity")
        if bv then
            bv:Destroy()
        end
    end
    if CurrentVehicleSeat and OriginalMaxSpeed then
        CurrentVehicleSeat.MaxSpeed = OriginalMaxSpeed
    end
    if CurrentVehicleSeat and OriginalPlatformStand then
        CurrentVehicleSeat.PlatformStand = OriginalPlatformStand
    end
    CurrentVehiclePart = nil
    CurrentVehicleSeat = nil
end

function ApplySpeedLimitOverride()
    if not CurrentVehicleSeat then
        return
    end
    -- Tenta remover o limitador de velocidade do assento
    -- Muitos jogos usam MaxSpeed no VehicleSeat para limitar
    if OriginalMaxSpeed == nil then
        OriginalMaxSpeed = CurrentVehicleSeat.MaxSpeed
    end

    -- Definir MaxSpeed para um valor absurdo (o Roblox limita internamente, mas ajuda)
    CurrentVehicleSeat.MaxSpeed = Stats.VehicleMaxSpeed * 2

    -- Alguns jogos usam PlatformStand para travar física,ensure false
    CurrentVehicleSeat.PlatformStand = false
end

function ApplyVehicleForce()
    if not CurrentVehiclePart then
        return
    end

    local bv = CurrentVehiclePart:FindFirstChild("BodyVelocity")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "BodyVelocity"
        bv.P = 10000
        bv.Parent = CurrentVehiclePart
    end

    bv.MaxForce = Vector3.new(Stats.VehicleForce, Stats.VehicleForce, Stats.VehicleForce)

    -- NOTA: Não definimos bv.Velocity diretamente aqui para não travar o carro no lugar.
    -- Deixamos o jogo controlar a direção, mas damos força infinita para acelerar.
end

function CheckVehicle()
    local char = Player.Character
    if not char then
        return
    end

    local seat = char:FindFirstChildWhichIsA("VehicleSeat")
    if not seat then
        -- Fallback: procurar em descendentes
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("VehicleSeat") and obj.Occupant == Player then
                seat = obj
                break
            end
        end
    end

    if seat and seat.Parent then
        if seat ~= CurrentVehicleSeat then
            -- Entrou em um NOVO carro
            ResetVehicle() -- Limpa anterior
            CurrentVehicleSeat = seat
            CurrentVehiclePart = seat.RootPart -- Pega a parte física principal

            -- Tenta achar o chassi real se o RootPart for apenas o assento
            local model = seat.Parent
            if model:IsA("Model") then
                local chassis =
                    model:FindFirstChild("Chassis") or model:FindFirstChild("Body") or model:FindFirstChild("Engine")
                if chassis and chassis:IsA("BasePart") then
                    CurrentVehiclePart = chassis
                end
            end

            print("[v3.1] Veículo Detectado: " .. model.Name .. " | Chassi: " .. (CurrentVehiclePart.Name or "N/A"))
            OriginalMaxSpeed = seat.MaxSpeed

            if Stats.VehicleSpeed then
                ApplyVehicleForce()
                ApplySpeedLimitOverride()
            end
        else
            -- Já está no carro, apenas reaplica se estiver ativo
            if Stats.VehicleSpeed then
                ApplyVehicleForce()
                ApplySpeedLimitOverride()
            end
        end
    else
        -- Saiu do carro
        if CurrentVehicleSeat then
            ResetVehicle()
        end
    end
end

-- Loop Principal
RunService.Heartbeat:Connect(
    function()
        if Stats.VehicleSpeed then
            CheckVehicle()
        end

        if Stats.GodMode then
            local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end

        if Stats.SpeedHack then
            local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = Stats.WalkSpeed
            end
        end
    end
)

Player.CharacterAdded:Connect(
    function()
        wait(1)
        CheckVehicle()
    end
)

print("✅ Turbo Grid v3.1 Iniciado. Sistema de Override de Veículo Ativo.")
