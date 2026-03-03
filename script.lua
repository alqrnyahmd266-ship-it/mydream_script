-- [[ Dark Edition: V14 ULTIMATE - SMART CHASE & AUTO FLOOR - BY KHAYAL ]] --
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local EHackActive, RockMode, JumpActive, AutoSlap, AutoFloor = false, false, true, false, false
local Following, IsMinimized = false, false
local SpeedValue = 29
local TargetPlayer = nil
local lastJumpTick = 0 

-- [ 1. الواجهة الرسومية ] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Khayal_V14_SmartChase"

local EStatus = Instance.new("Frame", ScreenGui)
EStatus.Size = UDim2.new(0, 160, 0, 40)
EStatus.Position = UDim2.new(0.5, -80, 0.02, 0)
EStatus.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
EStatus.BorderSizePixel = 2
EStatus.BorderColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", EStatus)

local ELabel = Instance.new("TextLabel", EStatus)
ELabel.Size = UDim2.new(1, 0, 1, 0)
ELabel.Text = " خيال (R)"
ELabel.TextColor3 = Color3.fromRGB(255, 0, 0)
ELabel.Font = Enum.Font.GothamBold
ELabel.TextSize = 15 
ELabel.BackgroundTransparency = 1

local BarContainer = Instance.new("Frame", EStatus)
BarContainer.Size = UDim2.new(1, 0, 0, 5)
BarContainer.Position = UDim2.new(0, 0, 1, 5)
BarContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
BarContainer.Visible = false
Instance.new("UICorner", BarContainer)

local ProgressLine = Instance.new("Frame", BarContainer)
ProgressLine.Size = UDim2.new(0, 0, 1, 0)
ProgressLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
Instance.new("UICorner", ProgressLine)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 430)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.new(0,0,0)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "المصمم خياال"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 19 
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 7)
MinBtn.Text = "-"
MinBtn.TextSize = 22
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinBtn)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 7)
CloseBtn.Text = "X"
CloseBtn.TextSize = 18
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseBtn)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, 0, 1, -55)
Container.Position = UDim2.new(0, 0, 0, 55)
Container.BackgroundTransparency = 1

local function CreateBtn(pos, text)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(0.9, 0, 0, 42)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 15 
    Instance.new("UICorner", b)
    return b
end

local BtnR = CreateBtn(UDim2.new(0.05, 0, 0.02, 0), "E-HACK: OFF (R)")
local BtnT = CreateBtn(UDim2.new(0.05, 0, 0.15, 0), "Speed: 27.5 (T)")
local BtnC = CreateBtn(UDim2.new(0.05, 0, 0.28, 0), "Follow: OFF (C)")
local BtnE = CreateBtn(UDim2.new(0.05, 0, 0.41, 0), "Floor: OFF (E)")
local BtnK = CreateBtn(UDim2.new(0.05, 0, 0.54, 0), "Auto Slap: OFF (K)")
local BtnF = CreateBtn(UDim2.new(0.05, 0, 0.67, 0), "Rock: OFF (F)")
local BtnJ = CreateBtn(UDim2.new(0.05, 0, 0.80, 0), "Jump: ON 🚀 (J)")

-- [ 2. منطق العمل ] --
local function UpdateUI()
    if EHackActive then
        EStatus.BorderColor3 = Color3.fromRGB(0, 255, 0)
        ELabel.Text = " خيال ACTIVE ✅"
        ELabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        BarContainer.Visible = true
    else
        EStatus.BorderColor3 = Color3.fromRGB(255, 0, 0)
        ELabel.Text = " خيال (R)"
        ELabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        BarContainer.Visible = false
    end
    BtnR.Text = EHackActive and "E-HACK: ON ✅" or "E-HACK: OFF (R)"
    BtnT.Text = "Speed: " .. SpeedValue .. " (T)"
    BtnC.Text = Following and "Follow: ON 🏃" or "Follow: OFF (C)"
    BtnE.Text = AutoFloor and "Floor: ON 🏗️" or "Floor: OFF (E)"
    BtnK.Text = AutoSlap and "Slap: ON 🔥" or "Auto Slap: OFF (K)"
    BtnF.Text = RockMode and "Rock: ON ✅" or "Rock: OFF (F)"
    BtnJ.Text = JumpActive and "Jump: ON 🚀" or "Jump: OFF (J)"
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
    elseif k == "T" then SpeedValue = (SpeedValue == 29 and 55 or 29)
    elseif k == "E" then AutoFloor = not AutoFloor
    elseif k == "K" then AutoSlap = not AutoSlap
    elseif k == "F" then RockMode = not RockMode
    elseif k == "J" then JumpActive = not JumpActive
    elseif k == "C" then 
        Following = not Following
        if Following then 
            TargetPlayer = GetClosest()
            SpeedValue = 55
        else 
            TargetPlayer = nil 
            SpeedValue = 29
            AutoFloor = false
        end
    end
    UpdateUI()
end

-- ربط الأحداث
BtnR.Activated:Connect(function() Toggle("R") end)
BtnT.Activated:Connect(function() Toggle("T") end)
BtnC.Activated:Connect(function() Toggle("C") end)
BtnE.Activated:Connect(function() Toggle("E") end)
BtnK.Activated:Connect(function() Toggle("K") end)
BtnF.Activated:Connect(function() Toggle("F") end)
BtnJ.Activated:Connect(function() Toggle("J") end)

MinBtn.MouseButton1Click:Connect(function() 
    IsMinimized = not IsMinimized 
    Container.Visible = not IsMinimized 
    Main:TweenSize(IsMinimized and UDim2.new(0, 250, 0, 50) or UDim2.new(0, 250, 0, 430), "Out", "Quad", 0.2, true) 
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- نظام النط اللانهائي (J)
UIS.JumpRequest:Connect(function()
    if JumpActive and (tick() - lastJumpTick) > 0.45 then
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            lastJumpTick = tick()
        end
    end
end)

UIS.InputBegan:Connect(function(i, g)
    if not g then Toggle(i.KeyCode.Name) end
end)

-- [ 3. الحلقات الأساسية ] --
task.spawn(function()
    while true do
        if EHackActive then
            ProgressLine.Size = UDim2.new(0, 0, 1, 0)
            ProgressLine:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0.31)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.KeyboardKeyCode == Enum.KeyCode.E then
                    local txt = (v.ActionText .. v.ObjectText):lower()
                    if not txt:find("sell") and not txt:find("بيع") then v.HoldDuration = 0 end
                end
            end
        end
        task.wait(0.31)
    end
end)

RS.Heartbeat:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChild("Humanoid")
        
        -- [ منطق المطاردة الذكي الأصلي ] --
        if Following and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local tPart = TargetPlayer.Character.HumanoidRootPart
            
            -- إذا صعد الخصم للأعلى
            if tPart.Position.Y > root.Position.Y + 4 then
                AutoFloor = true -- وضع أرضية
                if JumpActive and (tick() - lastJumpTick) > 0.45 then
                    root.Velocity = Vector3.new(root.Velocity.X, 52, root.Velocity.Z) -- نط تلقائي
                    lastJumpTick = tick()
                end
            -- إذا نزل الخصم للأسفل
            elseif tPart.Position.Y < root.Position.Y - 1.5 then
                AutoFloor = false -- إلغاء الأرضية فوراً
                local old = workspace:FindFirstChild("S_Floor_"..LP.Name)
                if old then old:Destroy() end -- حذف القطعة الموجودة حالياً لضمان السقوط
            end
            
            local moveDir = (tPart.Position - root.Position).Unit
            root.Velocity = Vector3.new(moveDir.X * SpeedValue, root.Velocity.Y, moveDir.Z * SpeedValue)
        elseif hum and hum.MoveDirection.Magnitude > 0 then
            root.Velocity = Vector3.new(hum.MoveDirection.X * SpeedValue, root.Velocity.Y, hum.MoveDirection.Z * SpeedValue)
        end

        -- صانع الأرضية
        if AutoFloor then
            local fName = "S_Floor_" .. LP.Name
            if not workspace:FindFirstChild(fName) then
                local p = Instance.new("Part", workspace)
                p.Name = fName; p.Size = Vector3.new(15, 1, 15); p.Anchored = true; p.Transparency = 0.6; p.Position = root.Position - Vector3.new(0, 3.5, 0)
                task.delay(0.1, function() if p then p:Destroy() end end)
            end
        end
        
        -- الضرب التلقائي
        if AutoSlap then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        if (v.Character.HumanoidRootPart.Position - root.Position).Magnitude < 16 then tool:Activate() end
                    end
                end
            end
        end
    end
end)

UpdateUI()
