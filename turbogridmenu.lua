-- ========== TURBO GRID SOLARA BLASTER v2.1 ==========
-- Ativa modo "Dirty Hack" - força bruta na física do chassi
-- Funciona por: bypass de anti-cheat + injeção de força inferior
-- Exige: Solara Executor (bypass Byfron/Hyperion ativado)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
if not Player then
    return
end

-- ========== Variáveis de controle ==========
local TargetSpeedKmH = 300
local Enabled = false
local ForceObject = nil
local MainChassis = nil
local Seat = nil

-- ========== UI: MODAL MINIMA correspondente ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SolarBlast_v2.1"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 180)
Frame.Position = UDim2.new(0.5, -140, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "SOLARA BLASTER v2.1"
Title.TextColor3 = Color3.new(1, 0.6, 0)
Title.BackgroundColor3 = Color3.fromRGB(100, 30, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -30, 0, 0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.GothamBold
Close.Parent = Title
Close.MouseButton1Click:Connect(
    function()
        ScreenGui:Destroy()
    end
)

local Input = Instance.new("TextBox")
Input.Size = UDim2.new(1, -20, 0, 40)
Input.Position = UDim2.new(0, 10, 0, 40)
Input.Text = "300"
Input.PlaceholderText = "VELOCIDADE (km/h)"
Input.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Input.TextColor3 = Color3.new(0, 255, 120)
Input.Font = Enum.Font.GothamBold
Input.TextSize = 24
Input.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 90)
ToggleBtn.Text = "ATIVAR FORÇA"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 16
ToggleBtn.Parent = Frame

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, 0, 0, 20)
StatusLbl.Position = UDim2.new(0, 0, 1, -20)
StatusLbl.Text = "Carregado. Entre no carro."
StatusLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 12
StatusLbl.Parent = Frame

-- ========== DETECÇÃO + HACK NO CHASSI ==========
local function ApplyMassiveForce()
    Seat =
        Player.Character and Player.Character:FindFirstChild("DriveSeat") or
        Player.Character:FindFirstChildWhichIsA("VehicleSeat")
    if not Seat then
        StatusLbl.Text = "Error: DriveSeat não detectado."
        StatusLbl.TextColor3 = Color3.fromRGB(255, 0, 0)
        return false
    end

    -- Pega chassi principal (o que realmente se move)
    MainChassis =
        Seat.RootPart or Seat.Parent:FindFirstChildWhichIsA("BasePart") or Seat.Parent:FindFirstChild("Body") or
        Seat.Parent:FindFirstChild("Chassis")
    if not MainChassis then
        StatusLbl.Text = "Error: Part principal não achada."
        warn("MainChassis não detectado para DriveSeat.")
        return false
    end

    -- ========== FORÇA RAIVOSA: VIA BODYVELOCITY + DIREÇÃO ==========
    ForceObject = Instance.new("BodyVelocity")
    ForceObject.Name = "SolarBlastForce"
    ForceObject.Parent = MainChassis

    -- Atualiza a cada frame, não dependendo do game engine
    local maxForce = Vector3.new(math.huge, 0, math.huge)
    local speedStudsPerSecond = (TargetSpeedKmH * 0.55) * 2 -- Fator agressivo, duplica a força

    -- Loop próprio, sem depender do Roblox update
    local conn
    conn =
        RunService.Heartbeat:Connect(
        function()
            if not Enabled or not MainChassis or not MainChassis:IsDescendantOf(workspace) then
                ForceObject:Destroy()
                if conn then
                    conn:Disconnect()
                end
                return
            end

            local lookVec = MainChassis.CFrame.LookVector
            local velocity = lookVec * speedStudsPerSecond * 1.5 -- Overdrive

            ForceObject.Velocity = velocity
            ForceObject.MaxForce = maxForce

            -- Empurra a velocidade para frente, ignorando torque e resistência
            MainChassis.AssemblyLinearVelocity = velocity
            MainChassis.AssemblyAngularVelocity = Vector3.new(0, 0, 0) -- Trava rotação
        end
    )

    return true
end

-- ========== AÇÃO DO BOTÃO ==========
ToggleBtn.MouseButton1Click:Connect(
    function()
        if not Seat or Seat.Occupant ~= Player then
            StatusLb.Text = "Entre no carro primeiro!"
            return
        end

        Enabled = not Enabled
        TargetSpeedKmH = tonumber(Input.Text) or 300

        if Enabled then
            if ApplyMassiveForce() then
                ToggleBtn.Text = "DESATIVAR"
                ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                StatusLbl.Text = "BLASTER ATIVADO: " .. TargetSpeedKmH .. " km/h"
                StatusLbl.TextColor3 = Color3.new(0, 255, 0)
            else
                StatusLbl.Text = "Falha na modulação. Tente reiniciar."
            end
        else
            ToggleBtn.Text = "ATIVAR FORÇA"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            if ForceObject then
                ForceObject:Destroy()
            end
            if conn and conn.Connected then
                conn:Disconnect()
            end
            StatusLbl.Text = "Força removida."
            StatusLbl.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end
)

-- Cleanup seguro
ScreenGui.AncestryChanged:Connect(
    function(obj, newParent)
        if newParent == nil then
            if ForceObject and ForceObject.Parent then
                ForceObject:Destroy()
            end
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
    end
)

print(">>> Solara Blaster v2.1 carregado. Entre no carro e ative.")
