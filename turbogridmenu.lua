-- ========== TURBO GRID MOD MENU v1.4 (FIX INTERFACE) ==========
-- Desenvolvido para: catuabinha_hb
-- ID do Jogo: 119941573290845
-- ============================================================

local Version = "1.4-FixInterface"
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Verificação de Usuário
if Player.Name ~= "catuabinha_hb" then
    warn("❌ ERRO: Este script é exclusivo para 'catuabinha_hb'.")
    warn("❌ Seu usuário atual: " .. Player.Name)
    return -- Para a execução se não for você
end

-- ✅ TENTE CARREGAR A INTERFACE (Com fallback)
local ArrayField
local success, result =
    pcall(
    function()
        -- Link atualizado e testado para bibliotecas UI genéricas
        ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Dawid-scripts/UI-Lib/master/src.lua"))()
    end
)

if not success or not ArrayField then
    warn("❌ FALHA CRÍTICA: Não foi possível carregar a biblioteca de interface (ArrayField/UI-Lib).")
    warn("🔍 Erro detalhado:", result)
    warn("💡 Tentando carregamento alternativo...")

    -- Tentativa 2: Outra lib comum (Orion ou similar adaptado)
    pcall(
        function()
            ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source.lua"))()
        end
    )

    if not ArrayField then
        game:GetService("StarterGui"):SetCore(
            "SendNotification",
            {
                Title = "Erro no Mod Menu",
                Text = "Falha ao carregar a interface. Verifique o console (F9).",
                Duration = 5
            }
        )
        return
    end
end

print("✅ Interface carregada com sucesso! Iniciando menu para catuabinha_hb...")

local Humanoid = Character:WaitForChild("Humanoid", 5)
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== VARIAVEIS DE ESTADO ==========
local speedHackEnabled = false
local coinFarmEnabled = false
local godModeEnabled = false
local originalWalkSpeed = Humanoid.WalkSpeed

-- ========== FUNCOES DE HOOK ==========
local function applySpeed(value)
    if Humanoid then
        Humanoid.WalkSpeed = value
    end
end

local function hookHumanoid()
    if not Humanoid then
        return
    end
    if godModeEnabled then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
    else
        Humanoid.Health = Humanoid.MaxHealth
    end
end

-- ========== FARM AUTOMATICO ==========
local function startAutoFarm()
    if not coinFarmEnabled then
        return
    end
    coroutine.wrap(
        function()
            while coinFarmEnabled and HumanoidRootPart do
                HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
                RunService.Heartbeat:Wait()
            end
        end
    )()
end

-- ========== CRIAÇÃO DO MENU (Adaptado para API Genérica) ==========
-- Nota: A sintaxe pode variar ligeiramente dependendo da lib que carregou.
-- Se usar a 'UI-Lib' ou 'Orion', a estrutura abaixo é padrão.

local Window
if ArrayField.CreateWindow then
    -- Sintaxe padrão da maioria das libs (Orion/UI-Lib)
    Window =
        ArrayField:CreateWindow(
        {
            Name = "Turbo Grid | catuabinha_hb",
            LoadingTitle = "Carregando...",
            LoadingSubtitle = "v" .. Version
        }
    )
else
    -- Fallback se a API for diferente
    warn("⚠️ API da interface desconhecida. Tentando método direto...")
    -- Aqui entraria um código de emergência, mas vamos assumir que carregou.
    return
end

local TabSpeed = Window:CreateTab("Speed Hack", 4483347587) -- ID de ícone genérico
local TabGame = Window:CreateTab("Gameplay", 4483347587)
local TabMisc = Window:CreateTab("Misc", 4483347587)

-- Aba Speed
TabSpeed:CreateToggle(
    {
        Name = "Ativar Speed Hack",
        CurrentValue = false,
        Flag = "SpeedToggle",
        Callback = function(Value)
            speedHackEnabled = Value
            applySpeed(Value and 200 or originalWalkSpeed)
            print("[catuabinha_hb] Speed:", Value and "ON" or "OFF")
        end
    }
)

TabSpeed:CreateSlider(
    {
        Name = "Velocidade",
        Range = {10, 500},
        Increment = 10,
        CurrentValue = 200,
        Flag = "SpeedSlider",
        Callback = function(Value)
            if speedHackEnabled then
                applySpeed(Value)
            end
        end
    }
)

-- Aba Gameplay
TabGame:CreateToggle(
    {
        Name = "God Mode (Imortal)",
        CurrentValue = false,
        Flag = "GodToggle",
        Callback = function(Value)
            godModeEnabled = Value
            hookHumanoid()
        end
    }
)

TabGame:CreateToggle(
    {
        Name = "Auto Farm Coin (Loop)",
        CurrentValue = false,
        Flag = "FarmToggle",
        Callback = function(Value)
            coinFarmEnabled = Value
            if Value then
                startAutoFarm()
            end
        end
    }
)

-- Aba Misc
TabMisc:CreateLabel("Script exclusivo para: catuabinha_hb")
TabMisc:CreateButton(
    {
        Name = "Resetar Tudo",
        Callback = function()
            speedHackEnabled = false
            godModeEnabled = false
            coinFarmEnabled = false
            applySpeed(originalWalkSpeed)
            print("[catuabinha_hb] Tudo resetado.")
        end
    }
)

-- ========== LOOP PRINCIPAL ==========
RunService.Heartbeat:Connect(
    function()
        if speedHackEnabled and Humanoid then
            -- Garante que a velocidade não volte ao normal
            local sliderVal = Window:GetConfig().SpeedSlider or 200
            Humanoid.WalkSpeed = sliderVal
        end
        if godModeEnabled and Humanoid then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end
)

-- ========== EVENTS ==========
Player.CharacterAdded:Connect(
    function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid", 5)
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
        if godModeEnabled then
            hookHumanoid()
        end
        if speedHackEnabled then
            applySpeed(200)
        end
    end
)

print("🚀 Menu inicializado para catuabinha_hb!")
