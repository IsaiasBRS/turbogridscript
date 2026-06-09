local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Aguarda o RemoteEvent existir ou criar caso não exista
local event
while true do
    event = ReplicatedStorage:FindFirstChild("AdminMoneyEvent")
    if event then
        break
    end
    task.wait()
end

-- Pega o UserId do jogador atual (injeção)
local localPlayer = Players.LocalPlayer

-- Função para puxar dinheiro
local function pullMoney(amount)
    if not amount or amount <= 0 then
        return
    end

    -- Envia o evento para o servidor
    event:FireServer(amount)
end

-- Criar interface simples (Mod Menu)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModMenu"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 180, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.PlaceholderText = "Valor para adicionar"
textBox.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 30)
button.Position = UDim2.new(0, 10, 0, 50)
button.BackgroundColor3 = Color3.new(0, 0.5, 0)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "PEGAR DINHEIRO"
button.Parent = frame

-- Função do botão
button.MouseButton1Click:Connect(
    function()
        local amount = tonumber(textBox.Text)
        if amount then
            pullMoney(amount)
        end
    end
)

-- Fechar menu com 'F5' (opcional)
UserInputService.InputBegan:Connect(
    function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.F5 and not gameProcessed then
            screenGui.Enabled = not screenGui.Enabled
        end
    end
)
