-- ========== TURBO GRID MOD MENU v1.3 (catuabinha_hb) ==========
-- Desenvolvido para: Turbo Grid (ID 119941573290845)
-- Interface: ArrayField (Loadstring)
-- Usuário: catuabinha_hb
-- ============================================================

local Version = "1.3-catuabinha"
local ArrayField =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/UI-Interface/ArrayField/main/Source.lua"))()
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

if Player.Name ~= "catuabinha_hb" then
    warn("❌ Você não está jogando com o personagem 'catuabinha_hb'!")
    warn("❌ Mod Menu só deve ser usado com este nome de usuário!")
end

local Humanoid = Character:WaitForChild("Humanoid", 5)
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
local RunService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- ========== VARIAVEIS DE ESTADO ==========
local speedHackEnabled = false
local coinFarmEnabled = false
local godModeEnabled = false
local originalWalkSpeed = Humanoid.WalkSpeed
local originalHealth = Humanoid.Health
local originalMaxHealth = Humanoid.MaxHealth

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

    Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(
        function()
            if speedHackEnabled and Humanoid.WalkSpeed < 200 then
                Humanoid.WalkSpeed = 200
            end
        end
    )

    if godModeEnabled then
        Humanoid.Health = math.huge
        Humanoid.MaxHealth = math.huge
    else
        Humanoid.Health = originalHealth
        Humanoid.MaxHealth = originalMaxHealth
    end
end

-- ========== FARM AUTOMATICO DE DINHEIRO ==========
local function findRemoteEvent(keyword)
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(keyword:lower()) then
            return obj
        end
    end
    return nil
end

local function hookMoneySystem()
    local coinRemote = findRemoteEvent("coin")
    if not coinRemote then
        warn(" RemoteEvent 'coin' não encontrado. Tentando 'money'...")
        coinRemote = findRemoteEvent("money")
    end

    if coinRemote then
        local oldFireServer = coinRemote.FireServer
        coinRemote.FireServer = function(self, ...)
            local args = {...}
            print(" [catuabinha_hb] Coin Event triggered with args:", unpack(args))
            return oldFireServer(self, table.unpack(args))
        end
    else
        warn(" Não foi possível encontrar RemoteEvent para farm de dinheiro.")
    end
end

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

-- ========== MOD MENU INTERFACE (catuabinha_hb) ==========
local Window =
    ArrayField:CreateWindow(
    {
        Name = "Mod Menu (catuabinha_hb) | v" .. Version,
        LoadingTitle = "Carregando menu...",
        LoadingSubtitle = "Hacks para catuabinha_hb",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "TurboGridHacks_catuabinha_hb",
            FileName = "ModMenuSettings_catuabinha"
        }
    }
)

local Tab1 = Window:CreateTab("Speed", 4483347587)
local ToggleSpeed =
    Tab1:CreateToggle(
    {
        Name = "Speed Hack",
        CurrentValue = false,
        Flag = "SpeedHack",
        Callback = function(Value)
            speedHackEnabled = Value
            applySpeed(Value and 200 or originalWalkSpeed)
            print(" [catuabinha_hb] Speed Status:", Value and "ON (200m/s)" or "OFF (" .. originalWalkSpeed .. "m/s)")
        end
    }
)

local SliderSpeed =
    Tab1:CreateSlider(
    {
        Name = "Velocidade Personalizada",
        Range = {10, 500},
        Increment = 10,
        CurrentValue = 200,
        Flag = "SpeedValue",
        Callback = function(Value)
            if speedHackEnabled then
                applySpeed(Value)
            end
        end
    }
)

local Tab2 = Window:CreateTab("Gameplay", 4483347587)
local ToggleGod =
    Tab2:CreateToggle(
    {
        Name = "God Mode",
        CurrentValue = false,
        Flag = "GodMode",
        Callback = function(Value)
            godModeEnabled = Value
            hookHumanoid()
            print(" [catuabinha_hb] God Mode Status:", Value and "ATIVADO" or "DESATIVADO")
        end
    }
)

local ToggleFarm =
    Tab2:CreateToggle(
    {
        Name = "Infinite Coin Farm",
        CurrentValue = false,
        Flag = "CoinFarm",
        Callback = function(Value)
            coinFarmEnabled = Value
            if Value then
                startAutoFarm()
                hookMoneySystem()
            end
            print(" [catuabinha_hb] Coin Farm Status:", Value and "ATIVADO" or "DESATIVADO")
        end
    }
)

local SliderHealth =
    Tab2:CreateSlider(
    {
        Name = "Health (God Mode)",
        Range = {0, 1000},
        Increment = 10,
        CurrentValue = 1000,
        Flag = "HealthValue",
        Callback = function(Value)
            if godModeEnabled then
                Humanoid.Health = Value
            end
        end
    }
)

local Tab3 = Window:CreateTab("Misc", 4483347587)
local LabelInfo = Tab3:CreateLabel("⚠ ATENÇÃO catuabinha_hb\nUse apenas em ambiente local")
local ButtonReset =
    Tab3:CreateButton(
    {
        Name = "Resetar Hacks",
        Interact = "Click",
        Callback = function()
            speedHackEnabled = false
            coinFarmEnabled = false
            godModeEnabled = false
            applySpeed(originalWalkSpeed)
            hookHumanoid()
            print(" [catuabinha_hb] Todos os hacks resetados!")
        end
    }
)

-- ========== INICIALIZACAO ==========
local function init()
    if not Humanoid then
        warn(" [catuabinha_hb] Humanoid não encontrado. Aguardando personagem...")
        Player.CharacterAdded:Wait()
        Character = Player.Character
        Humanoid = Character:WaitForChild("Humanoid", 5)
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)
    end

    originalWalkSpeed = Humanoid.WalkSpeed
    originalHealth = Humanoid.Health
    originalMaxHealth = Humanoid.MaxHealth

    hookHumanoid()
    print("[catuabinha_hb] Turbo Grid Mod Menu v" .. Version .. " INICIALIZADO")
    print(" ↳ Jogador: " .. Player.Name)
    print(" ↳ Objetivo: 201m < 4s (Speed Hack + Farm)")
end

-- ========== LOOP PRINCIPAL ==========
RunService.Heartbeat:Connect(
    function()
        if speedHackEnabled and Humanoid then
            Humanoid.WalkSpeed = SliderSpeed.CurrentValue
        end

        if godModeEnabled then
            Humanoid.Health = math.huge
        end

        if coinFarmEnabled and HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end
)

-- ========== EVENTOS ==========
Player.CharacterAdded:Connect(
    function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid", 5)
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
        init()
    end
)

if Character and Humanoid then
    init()
end
