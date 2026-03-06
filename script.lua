-- قائمة الحسابات المسموح لها (ضع الأسماء هنا)
local AllowedUsers = {"", "", "ahmoooood209"} 

local Player = game:GetService("Players").LocalPlayer
local isAllowed = false

-- التحقق من اسم اللاعب
for _, Name in pairs(AllowedUsers) do
    if Player.Name == Name then
        isAllowed = true
        break
    end
end

-- إذا لم يكن اللاعب مسموحاً له
if not isAllowed then
    -- إنشاء واجهة رسالة التحذير (خط كبير)
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local TextLabel = Instance.new("TextLabel", ScreenGui)
    
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundColor3 = Color3.new(0, 0, 0) -- خلفية سوداء
    TextLabel.TextColor3 = Color3.new(1, 0, 0) -- خط أحمر
    TextLabel.TextScaled = true -- الخط يكون كبير جداً
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "عذراً، ليس لديك صلاحية!\nلو تبي الصلاحية كلم 5edf في الديسكورد"
    
    task.wait(5) -- تظهر الرسالة 5 ثواني ثم يطرد اللاعب
    Player:Kick("Contact 5edf on Discord for access.")
    return
end

-- كودك الأصلي يبدأ من هنا (ضعه تحت هذا السطر)
print("تم تفعيل السكربت بنجاح، أهلاً بك يا " .. Player.Name)

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local EHackActive, AutoSlap, AutoFloor, Following, IsRunningPath = false, false, false, false, false
local SpeedMode, TargetSpeed = 1, 28
local FloorPart, TargetPlayer = nil, nil
local lastJumpTick = 0

-- [ 1. إحداثيات المسارات Q ] --
local Path1 = {
    {pos = Vector3.new(-474.2, -7.0, 26.3), speed = 54},
    {pos = Vector3.new(-487.4, -4.5, 25.2), speed = 54, holdE = true},
    {pos = Vector3.new(-473.5, -7.0, 25.4), speed = 28},
    {pos = Vector3.new(-473.8, -7.0, 52.1), speed = 28}
}
local Path2 = {
    {pos = Vector3.new(-474.1, -7.0, 93.6), speed = 54},
    {pos = Vector3.new(-488.0, -4.5, 95.5), speed = 54, holdE = true},
    {pos = Vector3.new(-476.0, -6.7, 95.3), speed = 28},
    {pos = Vector3.new(-476.4, -7.0, 72.3), speed = 28}
}

-- [ 2. المحرك الفيزيائي للسرعة ] --
local Attachment = Instance.new("Attachment")
local LV = Instance.new("LinearVelocity")
LV.MaxForce = 999999
LV.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
LV.PrimaryTangentAxis = Vector3.new(1, 0, 0)
LV.SecondaryTangentAxis = Vector3.new(0, 0, 1)
LV.RelativeTo = Enum.ActuatorRelativeTo.World

-- [ 3. الواجهة الرسومية ] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 350)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main)

local function ApplyRGB(obj)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(170, 0, 255) 
end
ApplyRGB(Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "المصمم خياال - V30"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17 
Title.BackgroundTransparency = 1

local function CreateBtn(pos_y, text)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = UDim2.new(0.05, 0, 0, pos_y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.fromRGB(200, 0, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13 
    Instance.new("UICorner", b)
    return b
end

local BtnR = CreateBtn(55, "INSTANT STEAL: OFF (R)") 
local BtnT = CreateBtn(100, "Speed: 28 (T)")
local BtnC = CreateBtn(145, "Follow: OFF (C)")
local BtnE = CreateBtn(190, "Floor: OFF (E)")
local BtnQ = CreateBtn(235, "Auto Path: OFF (Q)")
local BtnK = CreateBtn(280, "Slap: OFF (K)")

function UpdateUI()
    BtnR.Text = EHackActive and "STEAL: ON ✅ (R)" or "STEAL: OFF (R)"
    BtnT.Text = "Speed: " .. TargetSpeed .. " (T)"
    BtnC.Text = Following and "Follow: ON 🏃 (C)" or "Follow: OFF (C)"
    BtnE.Text = AutoFloor and "Floor: ON ✅ (E)" or "Floor: OFF (E)"
    BtnQ.Text = IsRunningPath and "Path: ON ⚙️ (Q)" or "Path: OFF (Q)"
    BtnK.Text = AutoSlap and "Slap: ON 🔥 (K)" or "Slap: OFF (K)"
end

local function Toggle(k)
    if k == "R" then EHackActive = not EHackActive
    elseif k == "T" then if SpeedMode == 1 then SpeedMode = 2 TargetSpeed = 54 else SpeedMode = 1 TargetSpeed = 28 end
    elseif k == "C" then Following = not Following TargetPlayer = Following and (function()
        local d, p = math.huge, nil
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist < d then d = dist p = v end
            end
        end
        return p
    end)() or nil
    elseif k == "E" then 
        AutoFloor = not AutoFloor
        if AutoFloor then
            if not FloorPart then
                FloorPart = Instance.new("Part", workspace)
                FloorPart.Size, FloorPart.Anchored, FloorPart.CanTouch = Vector3.new(15, 1, 15), true, false
                FloorPart.Transparency, FloorPart.Material = 0.5, Enum.Material.ForceField
            end
        else if FloorPart then FloorPart:Destroy() FloorPart = nil end end
    elseif k == "Q" then if IsRunningPath then IsRunningPath = false else task.spawn(function()
            IsRunningPath = true
            UpdateUI()
            local root = LP.Character.HumanoidRootPart
            local selectedPath = (root.Position - Path1[1].pos).Magnitude < (root.Position - Path2[1].pos).Magnitude and Path1 or Path2
            for i, step in ipairs(selectedPath) do
                if not IsRunningPath then break end
                while (root.Position - step.pos).Magnitude > 2 and IsRunningPath do
                    local dir = (step.pos - root.Position).Unit
                    LV.PlaneVelocity = Vector2.new(dir.X * step.speed, dir.Z * step.speed)
                    task.wait()
                end
                
                -- التعديل: يوقف يسرق ثلث ثانية ثم يكمل الباقي
                if step.holdE and IsRunningPath then
                    LV.PlaneVelocity = Vector2.new(0, 0)
                    root.Velocity = Vector3.new(0, 0, 0)
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.33) -- ثلث ثانية
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                end
            end
            IsRunningPath = false
            UpdateUI()
        end) end
    elseif k == "K" then AutoSlap = not AutoSlap
    end
    UpdateUI()
end

BtnR.Activated:Connect(function() Toggle("R") end)
BtnT.Activated:Connect(function() Toggle("T") end)
BtnC.Activated:Connect(function() Toggle("C") end)
BtnE.Activated:Connect(function() Toggle("E") end)
BtnQ.Activated:Connect(function() Toggle("Q") end)
BtnK.Activated:Connect(function() Toggle("K") end)
UIS.InputBegan:Connect(function(input, gpe) if not gpe then Toggle(input.KeyCode.Name) end end)

RS.Heartbeat:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum then
        Attachment.Parent = root
        LV.Parent = root
        LV.Attachment0 = Attachment
        if not IsRunningPath then
            local moveVec = hum.MoveDirection
            if Following and TargetPlayer and TargetPlayer.Character then
                local tRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    hum:MoveTo(tRoot.Position)
                    local dir = (tRoot.Position - root.Position).Unit
                    moveVec = Vector3.new(dir.X, 0, dir.Z)
                    if tRoot.Position.Y > root.Position.Y + 4 then hum.Jump = true end
                end
            end
            LV.PlaneVelocity = Vector2.new(moveVec.X * TargetSpeed, moveVec.Z * TargetSpeed)
        end
        if AutoFloor and FloorPart then
            FloorPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.9, root.Position.Z)
            if root.Velocity.Y < 0 then root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.28) do
        if EHackActive then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
            end
        end
        if AutoSlap and LP.Character then
            local tool = LP.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)
