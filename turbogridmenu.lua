-- ========== TURBO GRID MOD MENU v3.0 (VEHICLE SPEED HACK) ==========
-- Desenvolvido para: catuabinha_hb
-- Funciona em: Personagem AND Veículos (Carros, Motos, etc)
-- ============================================================

local Version = "3.0-VehicleFix"
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Verificação de Segurança
if Player.Name ~= "catuabinha_hb" then
warn("❌ ERRO: Script bloqueado. Usuário incorreto: ".. Player.Name)
return
end

-- ========== VARIAVEIS DE ESTADO ==========
local Stats = {
SpeedHack = false,
GodMode = false,
VehicleSpeed = false, -- Novo: Hack de veículo
WalkSpeed = 200,
VehicleForce = 50000, -- Força base do carro
TargetVehicleSpeed = 100 -- Multiplicador de velocidade do carro
}

local OriginalStats = {
WalkSpeed = 16,
MaxHealth = 100
}

-- Armazena a força original do veículo para restaurar depois
local OriginalVehicleVelocity = nil
local CurrentVehiclePart = nil
local VehicleConnection = nil

-- ========== UI LIB SIMPLIFICADA (EMBURIDA) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TurboGridMenu_Catuabinha_v3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 300) -- Aumentado para caber mais opções
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.Text = "Turbo Grid v3 | Veículos"
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
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 6
Content.CanvasSize = UDim2.new(0, 0, 0, 500)
Content.Parent = MainFrame

-- Funções de Criação de UI (Mesmas da v2.0)
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
Button.MouseButton1Click:Connect(function()
active = not active
Button.Text = active and "ON" or "OFF"
Button.TextColor3 = active and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
callback(active)
end)
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
Label.Text = name.. ": ".. default
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
SliderBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
SliderBtn.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
local pos = UDim2.new(0, math.clamp(input.Position.X - SliderBtn.AbsolutePosition.X, 0, SliderBtn.AbsoluteSize.X), 0, 0)
Indicator.Size = pos
local val = math.floor(min + (max - min) * pos.X.Scale)
Label.Text = name.. ": ".. val
callback(val)
end
end)
Indicator.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
end

-- ========== OPÇÕES DO MENU ==========
local yOffset = 10

-- 1. Speed Hack Personagem
createToggle("Speed Hack (Personagem)", yOffset, function(state)
Stats.SpeedHack = state
local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
if Humanoid then
Humanoid.WalkSpeed = state and Stats.WalkSpeed or OriginalStats.WalkSpeed
end
end)
yOffset = yOffset + 50

createSlider("Velocidade Personagem", yOffset, 10, 500, Stats.WalkSpeed, function(val)
Stats.WalkSpeed = val
if Stats.SpeedHack then
local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
if Humanoid then Humanoid.WalkSpeed = val end
end
end)
yOffset = yOffset + 60

-- 2. Speed Hack VEÍCULO (NOVO)
createToggle("Turbo Veículo (Carro)", yOffset, function(state)
Stats.VehicleSpeed = state
if not state and CurrentVehiclePart then
-- Restaurar velocidade normal ao desligar
if CurrentVehiclePart:FindFirstChild("BodyVelocity") then
Local bv = CurrentVehiclePart:FindFirstChild("BodyVelocity")
if bv then bv.MaxForce = Vector3.new(0,0,0) end
end
end
print("[catuabinha_hb] Turbo Veículo:", state and "ATIVADO" or "DESATIVADO")
end)
yOffset = yOffset + 50

createSlider("Força do Carro", yOffset, 1000, 500000, Stats.VehicleForce, function(val)
Stats.VehicleForce = val
-- Aplica imediatamente se já estiver num carro
if Stats.VehicleSpeed and CurrentVehiclePart then
ApplyVehicleSpeed(CurrentVehiclePart)
end
end)
yOffset = yOffset + 60

createSlider("Multiplicador Velocidade", yOffset, 1, 50, 10, function(val)
Stats.TargetVehicleSpeed = val
if Stats.VehicleSpeed and CurrentVehiclePart then
ApplyVehicleSpeed(CurrentVehiclePart)
end
end)
yOffset = yOffset + 60

-- 3. God Mode
createToggle("God Mode", yOffset, function(state)
Stats.GodMode = state
local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
if Humanoid then
if state then
Humanoid.MaxHealth = math.huge
Humanoid.Health = math.huge
else
Humanoid.MaxHealth = OriginalStats.MaxHealth
Humanoid.Health = OriginalStats.MaxHealth
end
end
end)
yOffset = yOffset + 50

-- Reset
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.9, 0, 0, 40)
ResetBtn.Position = UDim2.new(0.05, 0, 0, yOffset)
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ResetBtn.Text = "RESETAR TUDO"
ResetBtn.TextColor3 = Color3.new(1, 1, 1)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.Parent = Content
ResetBtn.MouseButton1Click:Connect(function()
Stats.SpeedHack = false
Stats.VehicleSpeed = false
Stats.GodMode = false
local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
if Humanoid then
Humanoid.WalkSpeed = OriginalStats.WalkSpeed
Humanoid.MaxHealth = OriginalStats.MaxHealth
Humanoid.Health = OriginalStats.MaxHealth
end
if CurrentVehiclePart then
local bv = CurrentVehiclePart:FindFirstChild("BodyVelocity")
if bv then bv:Destroy() end
end
ScreenGui:Destroy()
wait(0.5)
loadstring(game:HttpGet("https://raw.githubusercontent.com/IsaiasBRS/turbogridscript/refs/heads/main/turbogridmenu.lua"))()
end)

Content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 60)

-- ========== LÓGICA DE VEÍCULO (O SEGREDO) ==========
function ApplyVehicleSpeed(vehiclePart)
if not Stats.VehicleSpeed then return end

-- Tenta encontrar ou criar o BodyVelocity
local bv = vehiclePart:FindFirstChild("BodyVelocity")
if not bv then
bv = Instance.new("BodyVelocity")
bv.Name = "BodyVelocity"
bv.MaxForce = Vector3.new(400000, 400000, 400000) -- Força máxima em todos os eixos
bv.P = 10000 -- Proporcionalidade (quanto maior, mais "duro" o carro responde)
bv.Parent = vehiclePart
end

-- A mágica: Definimos uma velocidade baseada no slider
-- O jogo geralmente calcula a velocidade do carro baseado na força aplicada nas rodas.
-- Aqui forçamos o chassi a se mover na direção que ele já está indo, mas muito mais rápido.

-- Nota: Em muitos jogos de carro do Roblox, o "BodyVelocity" é usado pelo próprio jogo para controlar o carro.
-- Nós vamos sobrescrever o MaxForce ou a Velocity dependendo de como o jogo funciona.

-- Estratégia Compatível: Aumentar drasticamente o MaxForce para permitir aceleração infinita
bv.MaxForce = Vector3.new(Stats.VehicleForce, Stats.VehicleForce, Stats.VehicleForce)

-- Se o jogo usa Velocidade direta no BodyVelocity (comum em jogos antigos):
-- bv.Velocity = vehiclePart.CFrame.LookVector * (Stats.TargetVehicleSpeed * 10)

print(" Aplicando força ".. Stats.VehicleForce.. " ao veículo.")
end

-- Detectar entrada/saída do veículo
Player.CharacterAdded:Connect(function(char)
wait(1) -- Pequeno delay para o carro carregar se estiver dentro
CheckVehicle()
end)

function CheckVehicle()
local char = Player.Character
if not char then return end

-- Procura por um "VehicleSeat" que o jogador está usando
local seat = char:FindFirstChildWhichIsA("VehicleSeat")
if not seat then
-- Tenta achar no modelo do carro se o script rodou enquanto já estava dentro
for _, obj in ipairs(char:GetDescendants()) do
if obj:IsA("VehicleSeat") and obj.Occupant == Player then
seat = obj
break
end
end
end

if seat and seat.Parent then
-- O jogador está num carro!
local vehicleModel = seat.Parent
-- Achar a parte principal do carro (geralmente a que tem o BodyVelocity ou chassi)
local mainPart = vehicleModel:FindFirstChildWhichIsA("BasePart")

-- Às vezes a parte principal não é a primeira. Tenta achar uma chamada "Chassis", "Body", "Car", etc.
if not mainPart then mainPart = vehicleModel:FindFirstChild("Chassis") end
if not mainPart then mainPart = vehicleModel:FindFirstChild("Body") end
if not mainPart then mainPart = seat.RootPart -- Fallback

if mainPart and mainPart ~= CurrentVehiclePart then
CurrentVehiclePart = mainPart
print(" Jogador entrou no veículo: ".. (vehicleModel.Name or "Unknown"))
ApplyVehicleSpeed(mainPart)
end
else
-- Jogador saiu do carro
if CurrentVehiclePart then
local bv = CurrentVehiclePart:FindFirstChild("BodyVelocity")
if bv then
-- Reseta para força normal ou remove (depende do jogo, melhor reduzir força)
bv.MaxForce = Vector3.new(10000, 10000, 10000)
end
CurrentVehiclePart = nil
print(" Jogador saiu do veículo.")
end
end
end

-- Loop de verificação constante (para pegar carros que mudam de nome ou estrutura)
RunService.Heartbeat:Connect(function()
if Stats.VehicleSpeed then
CheckVehicle()
if CurrentVehiclePart then
ApplyVehicleSpeed(CurrentVehiclePart)
end
end

-- God Mode Loop
if Stats.GodMode then
local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
if Humanoid then Humanoid.Health = Humanoid.MaxHealth end
end

-- Speed Hack Personagem Loop
if Stats.SpeedHack then
local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
if Humanoid then Humanoid.WalkSpeed = Stats.WalkSpeed end
end
end)

print("✅ Turbo Grid v3.0 Iniciado. Hack de Veículo Pronto.")
