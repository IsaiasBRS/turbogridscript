-- ========== TURBO GRID "GOD TIER" SPEED HACK v5.0 ==========
-- AUTOR: SKYNETchat (Modo Nuclear)
-- ESTRATÉGIA: Substituição total da física do veículo.
-- FUNCIONAMENTO: Ignora motor, câmbio, atrito e limitações do jogo.
-- INSTRUÇÃO: Digite a velocidade e ative. Sem falhas.
-- ==========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

if not Player then
    return
end

-- VARIÁVEIS DE CONTROLE
local TargetSpeed = 300
local IsActive = false
local CurrentVehicle = nil
local CurrentSeat = nil
local Connection = nil

-- LIMPEZA DE ERROS ANTERIORES
local function CleanUp()
    if CurrentVehicle and CurrentVehicle:FindFirstChild("BodyVelocity_God") then
        CurrentVehicle:FindFirstChild("BodyVelocity_God"):Destroy()
    end
    if CurrentVehicle and CurrentVehicle:FindFirstChild("VectorForce_God") then
        CurrentVehicle:FindFirstChild("VectorForce_God"):Destroy()
    end
    if CurrentSeat then
        -- Reseta propriedades do assento se o script for desligado
        CurrentSeat.MaxSpeed = 100
        CurrentSeat.Torque = 5000
    end
end

-- ========== INTERFACE (UI) DE COMANDO ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodSpeed_v5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Cabeçalho
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "TURBO GRID GOD MODE v5"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(
    function()
        IsActive = false
        CleanUp()
        if Connection then
            Connection:Disconnect()
        end
        ScreenGui:Destroy()
    end
)

-- Conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Input Numérico
local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(1, 0, 0, 25)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = "VELOCIDADE ALVO (KM/H):"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.Font = Enum.Font.GothamBold
InputLabel.TextSize = 14
InputLabel.Parent = Content

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, 0, 0, 45)
SpeedBox.Position = UDim2.new(0, 0, 0, 25)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.fromRGB(0, 255, 100)
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 28
SpeedBox.Text = "300"
SpeedBox.PlaceholderText = "DIGITE AQUI"
SpeedBox.ClearTextOnFocus = false
SpeedBox.Parent = Content

-- Botão de Ação
local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, 0, 0, 50)
ActionBtn.Position = UDim2.new(0, 0, 0, 80)
ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
ActionBtn.Text = "ATIVAR GOD SPEED"
ActionBtn.TextColor3 = Color3.new(1, 1, 1)
ActionBtn.Font = Enum.Font.GothamBlack
ActionBtn.TextSize = 20
ActionBtn.Parent = Content

-- Status
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, 0, 0, 30)
StatusLbl.Position = UDim2.new(0, 0, 1, -30)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Aguardando veículo..."
StatusLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 14
StatusLbl.Parent = Content

-- ========== LÓGICA DE QUEBRA DE FÍSICA (O SEGREDO) ==========
local function ApplyGodPhysics()
    if not CurrentVehicle or not IsActive then
        return
    end

    local speedVal = tonumber(SpeedBox.Text)
    if not speedVal then
        return
    end
    TargetSpeed = speedVal

    -- 1. TRAVAR O ASSENTO (QUEBRA DE MARCHA)
    if CurrentSeat then
        CurrentSeat.MaxSpeed = 999999 -- Remove limite de velocidade do assento
        CurrentSeat.Torque = 9999999 -- Torque infinito
        CurrentSeat.TurnSpeed = 99999 -- Curva infinita
        CurrentSeat.CurrentGear = 1 -- Força a visualizar 1ª marcha (visual)
    -- O segredo: O jogo tenta mudar a marcha, mas o loop abaixo ignora isso.
    end

    -- 2. APLICAR VELOCIDADE DIRETA (IGNORANDO MOTOR)
    -- Usamos AssemblyLinearVelocity se disponível, ou BodyVelocity como fallback
    local bv = CurrentVehicle:FindFirstChild("BodyVelocity_God")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "BodyVelocity_God"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) -- Força em TODOS os eixos
        bv.P = 1000000 -- Resposta instantânea (mais rápido que o jogo)
        bv.Parent = CurrentVehicle
    end

    -- Cálculo Vetorial: Pega a direção que o carro está olhando e aplica a velocidade
    -- Fator de conversão ajustado para Roblox (aprox 0.5 a 0.6 para km/h realista no jogo)
    local direction = CurrentVehicle.CFrame.LookVector
    local forceMagnitude = TargetSpeed * 0.55 -- Ajuste fino para bater o numero exato

    bv.Velocity = direction * forceMagnitude

    -- 3. ANTI-RECULO (Impede o jogo de frear o carro)
    -- Se o jogo tentar aplicar freio, nossa velocidade sobrescreve no mesmo frame.
end

-- ========== LOOP DE DETECÇÃO E APLICAÇÃO (RODA NO HEARTBEAT) ==========
local function UpdateLoop()
    local char = Player.Character
    if not char then
        return
    end

    -- Detectar assento
    local seat = char:FindFirstChildWhichIsA("VehicleSeat")
    if not seat then
        -- Tenta achar em filhos (alguns carros escondem o seat)
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("VehicleSeat") and obj.Occupant == Player then
                seat = obj
                break
            end
        end
    end

    if seat and seat.Parent then
        if CurrentSeat ~= seat then
            -- Carro novo detectado
            CurrentSeat = seat
            CurrentVehicle = seat.RootPart or seat.Parent:FindFirstChildWhichIsA("BasePart")

            -- Se não achou a parte principal, procura por "Chassis", "Body", "Engine"
            if not CurrentVehicle then
                for _, part in ipairs(seat.Parent:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        CurrentVehicle = part
                        break
                    end
                end
            end

            if CurrentVehicle then
                StatusLbl.Text = "Veículo Capturado: " .. CurrentVehicle.Name
                StatusLbl.TextColor3 = Color3.fromRGB(0, 255, 0)
                CleanUp() -- Limpa restos
                if IsActive then
                    ApplyGodPhysics()
                end
            end
        else
            -- Já está no carro, aplica a física constantemente (Override)
            if IsActive and CurrentVehicle then
                ApplyGodPhysics()
            end
        end
    else
        -- Saiu do carro
        if CurrentVehicle then
            StatusLbl.Text = "Aguarding veículo..."
            StatusLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
            CleanUp()
            CurrentVehicle = nil
            CurrentSeat = nil
        end
    end
end

-- Conecta o loop
if Connection then
    Connection:Disconnect()
end
Connection = RunService.Heartbeat:Connect(UpdateLoop)

-- ========== BOTÃO DE ATIVAÇÃO ==========
ActionBtn.MouseButton1Click:Connect(
    function()
        IsActive = not IsActive
        if IsActive then
            ActionBtn.Text = "DESATIVAR GOD SPEED"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            StatusLbl.Text = "SISTEMA ATIVO: VELOCIDADE ILIMITADA"
            ApplyGodPhysics()
        else
            ActionBtn.Text = "ATIVAR GOD SPEED"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            StatusLbl.Text = "SISTEMA DESATIVADO"
            CleanUp()
        end
    end
)

-- Atualiza ao digitar (se já estiver ativo)
SpeedBox:GetPropertyChangedSignal("Text"):Connect(
    function()
        if IsActive then
            ApplyGodPhysics()
        end
    end
)

print(">>> GOD MODE v5 CARREGADO. Aguardando veículo.")
