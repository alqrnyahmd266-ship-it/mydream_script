-- [[ Khayal V14 - ORIGINAL SPEED - RGB BORDERS - NO F/J ]] --
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local EHackActive, RockMode, JumpActive, AutoSlap, AutoFloor = false, false, true, false, false
local Following, IsMinimized = false, false
local SpeedValue = 29 -- السرعة الأصلية
local TargetPlayer = nil
local lastJumpTick = 0 

-- [ 1. الواجهة الرسومية مع RGB ] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 310)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main)

-- وظيفة إضافة RGB نحيف جداً (Thickness = 1)
local function ApplyRGB(obj)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Thickness = 1 
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    task.spawn(function()
        while task.wait() do
            stroke.Color = Color3.fromHSV(tick() % 4 / 4, 1, 1)
        end
    end)
end
ApplyRGB(Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "المصمم خياال"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19 
Title.BackgroundTransparency = 1

local function CreateBtn(pos_y, text)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 42)
    b.Position = UDim2.new(0.05, 0, 0, pos_y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 15 
    Instance.new("UICorner", b)
    ApplyRGB(b) -- RGB حول كل خيار
    return b
end

local BtnR = CreateBtn(55, "E-HACK: OFF (R)")
local BtnT = CreateBtn(105, "Speed: 27.5 (T)")
local BtnC = CreateBtn(155, "Follow: OFF (C)")
local BtnE = CreateBtn(205, "Floor: OFF (E)")
local BtnK = CreateBtn(255, "Auto Slap: OFF (K)")

-- [ 2. منطق العمل (نفس قيم السرعة الأصلية) ] --
local function UpdateUI()
    BtnR.Text = EHackActive and "E-HACK: ON ✅" or "E-HACK: OFF (R)"
    BtnT.Text = "Speed: " .. SpeedValue .. " (T)"
    BtnC.Text = Following and "Follow: ON 🏃" or "Follow: OFF (C)"
    BtnE.Text = AutoFloor and "Floor: ON 🏗️" or "Floor: OFF (E)"
    BtnK.Text = AutoSlap and "Slap: ON 🔥" or "Auto Slap: OFF (K)"
end

local function GetClosest()
    local d, p = math.huge, nil
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if dist < d then d = dist p = v end
        end
    end
    return p
end

local function Toggle(k)
    if k == "R" then EHackActive = not EHackActive
    elseif k == "T" then SpeedValue = (SpeedValue == 29 and 55 or 29) -- رجعت 29 و 55
    elseif k == "E" then AutoFloor = not AutoFloor
    elseif k == "K" then AutoSlap = not AutoSlap
    elseif k == "C" then 
        Following = not Following
        if Following then TargetPlayer = GetClosest() SpeedValue = 55 else TargetPlayer = nil SpeedValue = 29 AutoFloor = false end
    end
    UpdateUI()
end

BtnR.Activated:Connect(function() Toggle("R") end)
BtnT.Activated:Connect(function() Toggle("T") end)
BtnC.Activated:Connect(function() Toggle("C") end)
BtnE.Activated:Connect(function() Toggle("E") end)
BtnK.Activated:Connect(function() Toggle("K") end)

UIS.InputBegan:Connect(function(i, g)
    if not g then 
        local key = i.KeyCode.Name
        if key == "R" or key == "T" or key == "C" or key == "E" or key == "K" then Toggle(key) end
    end
end)

-- [ 3. الحلقات الأساسية ] --
task.spawn(function()
    while true do
        if EHackActive then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.KeyboardKeyCode == Enum.KeyCode.E then
                    v.HoldDuration = 0
                end
            end
        end
        task.wait(0.3)
    end
end)

RS.Heartbeat:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root, hum = char.HumanoidRootPart, char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = SpeedValue end
        
        if Following and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local tPart = TargetPlayer.Character.HumanoidRootPart
            if tPart.Position.Y > root.Position.Y + 4 then
                AutoFloor = true 
                if (tick() - lastJumpTick) > 0.5 then
                    hum.Jump = true
                    lastJumpTick = tick()
                end
            end
            hum:MoveTo(tPart.Position)
        end

        if AutoFloor then
            local p = Instance.new("Part", workspace)
            p.Size, p.Position, p.Anchored, p.Transparency = Vector3.new(15, 1, 15), root.Position - Vector3.new(0, 3.5, 0), true, 0.5
            game:GetService("Debris"):AddItem(p, 0.1)
        end
    end
end)

task.spawn(function()
    while true do
        if AutoSlap then
            local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
        task.wait(0.1)
    end
end)
