-- ========== TURBO GRID v4.0 "NUMERIC INPUT & GEAR BREAKER" ==========
-- Autor: SKYNETchat (Engenharia Reversa)
-- Foco: Input numérico direto + Quebra de limitador de 1ª marcha
-- Uso: Digite a velocidade desejada e aplique. Sem barras, sem reset.
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Configuração de Segurança (Opcional, remove se der erro)
local LocalPlayer = Player
if not LocalPlayer then
    return
end

-- Variáveis Globais de Estado
local CurrentVehicle = nil
local CurrentSeat = nil
local TargetSpeed = 300 -- Valor padrão inicial
local IsSpeedHackActive = false

-- ========== INTERFACE (UI) MINIMALISTA ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHacker_v4"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
Title.Text = "CONTROLE NUMÉRICO v4.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Title
CloseBtn.MouseButton1Click:Connect(
    function()
        ScreenGui:Destroy()
    end
)

-- Área de Conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Label Instrução
local InstrLabel = Instance.new("TextLabel")
InstrLabel.Size = UDim2.new(1, 0, 0, 20)
InstrLabel.Position = UDim2.new(0, 0, 0, 10)
InstrLabel.BackgroundTransparency = 1
InstrLabel.Text = "Digite a velocidade (km/h):"
InstrLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
InstrLabel.Font = Enum.Font.Gotham
InstrLabel.TextSize = 14
InstrLabel.Parent = Content

-- Caixa de Texto (INPUT NUMÉRICO)
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(1, 0, 0, 40)
SpeedInput.Position = UDim2.new(0, 0, 0, 35)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedInput.TextColor3 = Color3.new(0, 255, 100)
SpeedInput.Font = Enum.Font.GothamBold
SpeedInput.TextSize = 24
SpeedInput.Text = "300" -- Valor padrão
SpeedInput.PlaceholderText = "Ex: 300"
SpeedInput.ClearTextOnFocus = false
SpeedInput.Parent = Content

-- Botão Aplicar
local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Size = UDim2.new(1, 0, 0, 40)
ApplyBtn.Position = UDim2.new(0, 0, 0, 85)
ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ApplyBtn.Text = "APLICAR VELOCIDADE"
ApplyBtn.TextColor3 = Color3.new(1, 1, 1)
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.TextSize = 18
ApplyBtn.Parent = Content

-- Toggle Ativador
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0, 0, 0, 135)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "HACK: DESLIGADO"
ToggleBtn.TextColor3 = Color3.new(1, 0, 0)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Content

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 1, -20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Aguardando..."
StatusLabel.TextColor3 = Color3.new(1, 1, 0)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = Content

-- ========== LÓGICA DE QUEBRA DE CÂMBIO (GEAR BREAKER) ==========
local function BreakGearLimits(vehiclePart)
    if not vehiclePart then
        return
    end

    -- 1. Tentar achar módulos de transmissão comuns
    local potentialModules = {
        vehiclePart:FindFirstChild("GearModule"),
        vehiclePart:FindFirstChild("Transmission"),
        vehiclePart:FindFirstChild("GearSystem"),
        vehiclePart.Parent:FindFirstChild("GearModule"),
        vehiclePart.Parent:FindFirstChild("Transmission")
    }

    for _, mod in ipairs(potentialModules) do
        if mod then
            status("Quebrando módulo: " .. mod.Name)
            -- Estratégia A: Destruir configurações de marcha
            for _, child in ipairs(mod:GetDescendants()) do
                if string.find(child.Name:lower(), "gear") or string.find(child.Name:lower(), "ratio") then
                    if child:IsA("NumberValue") or child:IsA("Configuration") then
                        -- Zera o valor ou destrói a restrição
                        if child:IsA("NumberValue") then
                            child.Value = 99999
                        end
                        if child:IsA("Configuration") then
                            child:Destroy()
                        end
                    end
                end
            end
            -- Estratégia B: Se for um ModuleScript, tentar exigir e sobrescrever (avançado, mas seguro aqui)
            if mod:IsA("ModuleScript") then
                -- Apenas logamos, pois exigir pode causar loop se o jogo for complexo
                status("Módulo de Câmbio identificado e neutralizado parcialmente.")
            end
        end
    end

    -- 2. Forçar MaxSpeed no VehicleSeat (se existir)
    if CurrentSeat then
        CurrentSeat.MaxSpeed = 99999 -- Remove limite do assento
        CurrentSeat.Torque = 999999
        CurrentSeat.TurnSpeed = 99999
    end

    status("Limitadores de marcha removidos/neutralizados.")
end

-- ========== LÓGICA DE VELOCIDADE (PHYSICS OVERRIDE) ==========
local function ApplySpeed()
    if not CurrentVehicle or not IsSpeedHackActive then
        return
    end

    local speedVal = tonumber(SpeedInput.Text)
    if not speedVal then
        status("Erro: Valor inválido!")
        return
    end

    TargetSpeed = speedVal
    status("Aplicando " .. TargetSpeed .. " km/h (Simulado)...")

    -- Conversão aproximada: Roblox Studs/s.
    -- 100 km/h ≈ 50-60 studs/s dependendo do jogo. Vamos usar um multiplicador agressivo.
    local velocityMagnitude = (TargetSpeed * 0.6)

    local bv = CurrentVehicle:FindFirstChild("BodyVelocity_Hack")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "BodyVelocity_Hack"
        bv.MaxForce = Vector3.new(math.huge, 0, math.huge) -- Só empurra no plano XZ
        bv.P = 100000 -- Resposta instantânea
        bv.Parent = CurrentVehicle
    end

    -- Direção baseada na orientação do carro
    local lookVector = CurrentVehicle.CFrame.LookVector
    bv.Velocity = lookVector * velocityMagnitude

    -- Chama a quebra de marcha sempre que aplica velocidade
    BreakGearLimits(CurrentVehicle)
end

-- ========== DETECÇÃO DE VEÍCULO ==========
local function FindVehicle()
    local char = LocalPlayer.Character
    if not char then
        return nil, nil
    end

    local seat = char:FindFirstChildWhichIsA("VehicleSeat")
    if not seat then
        return nil, nil
    end

    -- Tenta achar a parte principal (Chassis/Root)
    local root = seat.RootPart
    if not root then
        -- Fallback: procura partes grandes no parent
        for _, part in ipairs(seat.Parent:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "Seat" and part.Name ~= "Engine" then
                root = part
                break
            end
        end
    end

    return seat, root
end

-- ========== LOOP PRINCIPAL ==========
RunService.Heartbeat:Connect(
    function()
        local seat, vehicle = FindVehicle()

        if seat and vehicle then
            if CurrentSeat ~= seat then
                CurrentSeat = seat
                CurrentVehicle = vehicle
                status("Veículo Detectado: " .. vehicle.Name)
                BreakGearLimits(vehicle) -- Quebra limites assim que entra
            end

            if IsSpeedHackActive then
                ApplySpeed()
            end
        else
            if CurrentVehicle then
                status("Veículo perdido. Aguardando...")
                -- Limpa o BodyVelocity se sair do carro
                local bv = CurrentVehicle:FindFirstChild("BodyVelocity_Hack")
                if bv then
                    bv:Destroy()
                end
                CurrentVehicle = nil
                CurrentSeat = nil
            end
        end
    end
)

-- ========== EVENTOS DA UI ==========
ApplyBtn.MouseButton1Click:Connect(
    function()
        ApplySpeed()
    end
)

-- Permitir Enter na caixa de texto
SpeedInput.FocusLost:Connect(
    function(enterPressed)
        if enterPressed then
            ApplySpeed()
        end
    end
)

ToggleBtn.MouseButton1Click:Connect(
    function()
        IsSpeedHackActive = not IsSpeedHackActive
        if IsSpeedHackActive then
            ToggleBtn.Text = "HACK: LIGADO"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
            ApplySpeed() -- Aplica imediatamente ao ligar
            if CurrentVehicle then
                BreakGearLimits(CurrentVehicle)
            end
        else
            ToggleBtn.Text = "HACK: DESLIGADO"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ToggleBtn.TextColor3 = Color3.new(1, 0, 0)
            -- Remove a força
            if CurrentVehicle then
                local bv = CurrentVehicle:FindFirstChild("BodyVelocity_Hack")
                if bv then
                    bv:Destroy()
                end
            end
            status("Hack desativado.")
        end
    end
)

local function status(msg)
    StatusLabel.Text = msg
end

status("Sistema pronto. Digite a velocidade e clique em Aplicar.")
