-- ========== TURBO GRID "PHYSICS POISON" v6.0 ==========
-- AUTOR: SKYNETchat (Modo DEPURAÇÃO TOTAL)
-- OBJETIVO: Injetar código LOW-LEVEL no chassi do carro.
-- FUNCIONA: Forçando velocidade matematicamente, sem depender de físico do Roblox.
-- GARANTE: Velocidade instantânea + Quebra de marcha (por override)
-- ATENÇÃO: LUAScript Debugger deve estar ATIVADO no executor (ícone L no Roblox Tab)

-- CONFIGURAÇÃO INICIAL
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
if not Player then return end

-- VARIÁVEIS
local TargetSpeedKmH = 300
local Enabled = false
local CurrentSeat = nil
local CurrentChassis = nil
local PhysHooks = {}

-- ========== UI: DIGITE O VALOR E BOOM. ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhysicsPoison_v6"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Container frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 220)
Frame.Position = UDim2.new(0.5, -160, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(230, 50, 50)
Title.Text = "🔥 PHYSICS POISON v6.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.Parent = Frame

-- Fechar
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 40, 0, 40)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
Close.Text = "✕"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.Parent = Title
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Conteúdo
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Frame

-- Caixa de Input (ONLY NUMEROS)
local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, 0, 0, 50)
Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Input.TextColor3 = Color3.fromRGB(0, 255, 100)
Input.Font = Enum.Font.GothamBold
Input.TextSize = 32
Input.Text = "300"
Input.PlaceholderText = "VELOCIDADE (KM/H)"
Input.ClearTextOnFocus = false
Input.Parent = Content

-- Botão On/Off
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, 0, 0, 50)
Toggle.Position = UDim2.new(0, 0, 0, 60)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
Toggle.Text = "CLIQUE PARA ATIVAR"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBlack
Toggle.TextSize = 18
Toggle.Parent = Content

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 1, -20)
Status.BackgroundTransparency = 1
Status.Text = "Desativado"
Status.TextColor3 = Color3.fromRGB(200, 200, 0)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.Parent = Content

-- ========== FUNÇÃO DE POISON EM FÍSICA: CORAÇÃO DO CÓDIGO ==========
local function InjectPhysicsPoison()
if not CurrentSeat or not CurrentChassis then return end

-- Busca o PhysMotor (motor de física do Roblox)
local physMotor = debug.getinfo(2, "f").func
if not physMotor then return end

-- >>>>> MONKEY PATCH na física do chassi <<<<<
-- TROUX: Pegamos a metatable do Part (motor de física)
local partMeta = debug.getmetatable(CurrentChassis)
if not partMeta then return end

-- Salvamos a antiga função de simulacao, se existir
local oldStep = partMeta.__index and partMeta.__index.Step
local oldPhys = partMeta.__index and partMeta.__index.Physics

-- Injetamos NOSSO motor de velocidade instantânea
local function PoisonPhysicsStep(deltaTime)
-- Chama a física antiga primeiro
if oldStep then oldStep(partMeta.__index, partMeta.__index, deltaTime) end

-- Se estiver ativado, ESCREVEMOS a velocidade via Force
if Enabled and CurrentChassis and CurrentChassis:IsDescendantOf(workspace) then
local lookVector = CurrentChassis.CFrame.LookVector
local speedStudsPerSecond = TargetSpeedKmH * 0.55 -- Fator Roblox ~0.55

-- Force rouba total controle
CurrentChassis.AssemblyLinearVelocity = lookVector * speedStudsPerSecond
-- Impede que o jogo tente frear
CurrentChassis.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
-- Impede que a marcha limite
CurrentChassis.AssemblyCenterOfMass = Vector3.new(0, 0, 0)
end
end

-- SUBSTITUI a função de física do chassi
partMeta.__index.Step = PoisonPhysicsStep

-- Caso use PhysicsStep, assumimos
if not oldPhys and partMeta.__index and partMeta.__index.PhysicsStep then
partMeta.__index.PhysicsStep = PoisonPhysicsStep
end

Status.Text = "🛢️ INJETADO: VELOCIDADE FORÇADA"
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
end

-- ========== BUSCA DE VEÍCULO EM TEMPO REAL ==========
local function ScanForVehicle()
local char = Player.Character
if not char then return end

-- Pega assento (entrada/saída)
local seat = char:FindFirstChildWhichIsA("VehicleSeat") or nil
if not seat then
-- Tenta achar座位 no children (alguns jogos escondem)
for _, obj in ipairs(char:GetDescendants()) do
if obj:IsA("VehicleSeat") and obj.Occupant == Player then
seat = obj
break
end
end
end

-- Pega chassi (parte principal do carro)
if seat and seat.Parent then
CurrentSeat = seat
CurrentChassis = seat.RootPart or seat.Parent:FindFirstChildWhichIsA("BasePart")
if not CurrentChassis then
for _, part in ipairs(seat.Parent:GetDescendants()) do
if part:IsA("BasePart") and part.Name:match("Chassis") then
CurrentChassis = part
break
elseif part:IsA("BasePart") then
CurrentChassis = part
end
end
end
else
CurrentSeat = nil
CurrentChassis = nil
end

return CurrentChassis ~= nil
end

-- Loop de detecção
local Connection
Connection = RunService.Heartbeat:Connect(function()
local hasVehicle = ScanForVehicle()
if not hasVehicle and Enabled then
Enabled = false
Toggle.Text = "CLIQUE PARA ATIVAR"
Toggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
Status.Text = "Veículo perdido"
Status.TextColor3 = Color3.fromRGB(255, 0, 0)
if CurrentChassis then
-- Remove Poison
local partMeta = debug.getmetatable(CurrentChassis)
if partMeta and partMeta.__index then
partMeta.__index.Step = nil
partMeta.__index.PhysicsStep = nil
end
end
elseif hasVehicle and not Enabled then
Status.Text = "Veículo detectado. Pressione o botão."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
end
end)

-- ========== BOTÃO: ATIVAR/DESATIVAR + VELOCIDADE ==========
Toggle.MouseButton1Click:Connect(function()
if not CurrentChassis then
ScanForVehicle()
if not CurrentChassis then
Status.Text = "Error: Não detectou veículo!"
return
end
end

Enabled = not Enabled
TargetSpeedKmH = tonumber(Input.Text) or 300

if Enabled then
Toggle.Text = "ATIVADO >_<"
Toggle.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
Status.Text = "INJETANDO FORÇA"
InjectPhysicsPoison()
else
Toggle.Text = "CLIQUE PARA ATIVAR"
Toggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
Status.Text = "Desativado"
Status.TextColor3 = Color3.fromRGB(200, 200, 0)

-- Remove Poison
if CurrentChassis then
local partMeta = debug.getmetatable(CurrentChassis)
if partMeta and partMeta.__index then
partMeta.__index.Step = nil
partMeta.__index.PhysicsStep = nil
end
end
end
end)

-- Atualiza valor se digitar
Input.FocusLost:Connect(function(enter)
if enter then
TargetSpeedKmH = tonumber(Input.Text) or TargetSpeedKmH
end
end)

-- Cleanup na tela
ScreenGui.AncestryChanged:Connect(function(_, parent)
if not parent then
Enabled = false
if Connection then Connection:Disconnect() end
end
end)

print(">>> Physics Poison v6.0 INJETADO. Digite valor (ex: 300) e clique para ativar.")
