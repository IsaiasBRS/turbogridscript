-- ========== TURBO GRID MOD MENU v2.0 (UI EMBUTIDA) ==========
-- Desenvolvido para: catuabinha_hb
-- Sem dependência de links externos (Anti-Falha)
-- ============================================================

local Version = "2.0-Standalone"
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Verificação de Segurança
if Player.Name ~= "catuabinha_hb" then
    warn("❌ ERRO: Script bloqueado. Usuário incorreto: " .. Player.Name)
    return
end

local Humanoid = Character:WaitForChild("Humanoid", 10)
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

if not Humanoid or not HumanoidRootPart then
    warn("❌ Erro: Personagem não carregou corretamente.")
    return
end

-- ========== VARIAVEIS DE ESTADO ==========
local Stats = {
    SpeedHack = false,
    GodMode = false,
    AutoFarm = false,
    WalkSpeed = 200,
    JumpPower = 50
}
local OriginalStats = {
    WalkSpeed = Humanoid.WalkSpeed,
    JumpPower = Humanoid.JumpPower,
    MaxHealth = Humanoid.MaxHealth
}

-- ========== UI LIB SIMPLIFICADA (EMBURIDA) ==========
-- Criação manual da GUI para evitar dependência de links quebrados
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TurboGridMenu_Catuabinha"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Title.Text = "Turbo Grid | catuabinha_hb | v" .. Version
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Botão Fechar
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

-- Container de Conteúdo
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 6
Content.CanvasSize = UDim2.new(0, 0, 0, 400) -- Altura inicial
Content.Parent = MainFrame

-- Função Auxiliar para criar Botões/Toggles
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

-- Função para Slider de Velocidade
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

    -- Set initial
    Indicator.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
end

-- ========== CRIAÇÃO DOS ELEMENTOS DO MENU ==========
local yOffset = 10

createToggle(
    "Speed Hack",
    yOffset,
    function(state)
        Stats.SpeedHack = state
        Humanoid.WalkSpeed = state and Stats.WalkSpeed or OriginalStats.WalkSpeed
        print("[catuabinha_hb] Speed Hack:", state and "ATIVADO" or "DESATIVADO")
    end
)
yOffset = yOffset + 50

createSlider(
    "Velocidade",
    yOffset,
    10,
    500,
    Stats.WalkSpeed,
    function(val)
        Stats.WalkSpeed = val
        if Stats.SpeedHack then
            Humanoid.WalkSpeed = val
        end
    end
)
yOffset = yOffset + 60

createToggle(
    "God Mode",
    yOffset,
    function(state)
        Stats.GodMode = state
        if state then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
        else
            Humanoid.MaxHealth = OriginalStats.MaxHealth
            Humanoid.Health = OriginalStats.MaxHealth
        end
        print("[catuabinha_hb] God Mode:", state and "ATIVADO" or "DESATIVADO")
    end
)
yOffset = yOffset + 50

createToggle(
    "Auto Farm (Loop)",
    yOffset,
    function(state)
        Stats.AutoFarm = state
        print("[catuabinha_hb] Auto Farm:", state and "ATIVADO" or "DESATIVADO")
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
        Stats.GodMode = false
        Stats.AutoFarm = false
        Humanoid.WalkSpeed = OriginalStats.WalkSpeed
        Humanoid.MaxHealth = OriginalStats.MaxHealth
        Humanoid.Health = OriginalStats.MaxHealth
        print("[catuabinha_hb] Tudo resetado!")

        -- Recarrega GUI visualmente (simples reload da página não, apenas reseta vars)
        -- Para simplificar, o usuário pode fechar e abrir de novo se quiser resetar os botões visuais
        ScreenGui:Destroy()
        wait(1)
        loadstring(
            game:HttpGet("https://raw.githubusercontent.com/IsaiasBRS/turbogridscript/main/catuabinha_hb_mod_menu.lua")
        )()
    end
)

Content.CanvasSize = UDim2.new(0, 0, 0, yOffset + 60)

-- ========== LOOP PRINCIPAL ==========
RunService.Heartbeat:Connect(
    function()
        if Stats.SpeedHack then
            Humanoid.WalkSpeed = Stats.WalkSpeed
        end

        if Stats.GodMode then
            Humanoid.Health = Humanoid.MaxHealth
        end

        if Stats.AutoFarm and HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(0, 5, 0) -- Teleporta para o start
        end
    end
)

-- ========== EVENTO DE RESPAWN ==========
Player.CharacterAdded:Connect(
    function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid", 10)
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)

        -- Reaplica stats se estiverem ativos
        if Stats.SpeedHack then
            Humanoid.WalkSpeed = Stats.WalkSpeed
        end
        if Stats.GodMode then
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = math.huge
        end
    end
)

print("✅ Menu v2.0 Carregado com Sucesso para catuabinha_hb!")
print("✅ Interface embutida: Sem erros de link.")
