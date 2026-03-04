-- [[ Khayal V26 - AGGRESSIVE FOLLOW & AUTO CLIMB ]] --
local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local EHackActive, AutoSlap, AutoFloor, Following = false, false, false, false
local SpeedMode, TargetSpeed = 1, 29
local FloorPart, TargetPlayer = nil, nil
local lastJumpTick = 0

-- [ 1. المحرك الفيزيائي ] --
local Attachment = Instance.new("Attachment")
local LV = Instance.new("LinearVelocity")
LV.MaxForce = 999999
LV.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
LV.PrimaryTangentAxis = Vector3.new(1, 0, 0)
LV.SecondaryTangentAxis = Vector3.new(0, 0, 1)
LV.RelativeTo = Enum.ActuatorRelativeTo.World

-- [ 2. الواجهة الرسومية ] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 300)
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
Title.Text = "المصمم خياال - V26"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17 
Title.BackgroundTransparency = 1

local function CreateBtn(pos_y, text)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 42)
    b.Position = UDim2.new(0.05, 0, 0, pos_y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.TextColor3 = Color3.fromRGB(200, 0, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14 
    Instance.new("UICorner", b)
    return b
end

local BtnR = CreateBtn(60, "E-HACK: OFF (R)")
local BtnT = CreateBtn(105, "Speed: 29 (T)")
local BtnC = CreateBtn(150, "Follow: OFF (C)")
local BtnE = CreateBtn(195, "Floor: OFF (E)")
local BtnK = CreateBtn(240, "Slap: OFF (K)")

-- [ 3. الوظائف والتحكم ] --
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

local function UpdateUI()
    BtnR.Text = EHackActive and "E-HACK: ON ✅ (R)" or "E-HACK: OFF (R)"
    BtnT.Text = "Speed: " .. TargetSpeed .. " (T)"
    BtnC.Text = Following and "Follow: ON 🏃 (C)" or "Follow: OFF (C)"
    BtnE.Text = AutoFloor and "Floor: ON ✅ (E)" or "Floor: OFF (E)"
    BtnK.Text = AutoSlap and "Slap: ON 🔥 (K)" or "Slap: OFF (K)"
end

local function ToggleFloor(state)
    AutoFloor = state
    if state then
        if not FloorPart then
            FloorPart = Instance.new("Part", workspace)
            FloorPart.Size, FloorPart.Anchored, FloorPart.CanTouch = Vector3.new(15, 1, 15), true, false
            FloorPart.Transparency, FloorPart.Material = 0.5, Enum.Material.ForceField
        end
    else
        if FloorPart then FloorPart:Destroy() FloorPart = nil end
    end
    UpdateUI()
end

local function Toggle(k)
    if k == "R" then EHackActive = not EHackActive
    elseif k == "T" then 
        if SpeedMode == 1 then SpeedMode = 2 TargetSpeed = 54 else SpeedMode = 1 TargetSpeed = 29 end
    elseif k == "C" then 
        Following = not Following
        TargetPlayer = Following and GetClosest() or nil
        if Following then TargetSpeed = 54 end -- سرعة قصوى عند اللحاق
    elseif k == "E" then ToggleFloor(not AutoFloor)
    elseif k == "K" then AutoSlap = not AutoSlap
    end
    UpdateUI()
end

BtnR.Activated:Connect(function() Toggle("R") end)
BtnT.Activated:Connect(function() Toggle("T") end)
BtnC.Activated:Connect(function() Toggle("C") end)
BtnE.Activated:Connect(function() Toggle("E") end)
BtnK.Activated:Connect(function() Toggle("K") end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe then Toggle(input.KeyCode.Name) end
end)

-- [ 4. المحرك الأساسي ] --
RS.Heartbeat:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if root and hum then
        Attachment.Parent = root
        LV.Parent = root
        LV.Attachment0 = Attachment
        
        local moveVec = hum.MoveDirection
        
        -- منطق الـ Follow الهجومي
        if Following and TargetPlayer and TargetPlayer.Character then
            local tRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                -- دفع فيزيائي باتجاه الخصم
                local dir = (tRoot.Position - root.Position).Unit
                moveVec = Vector3.new(dir.X, 0, dir.Z)
                
                -- نظام الصعود التلقائي (Auto Climb)
                if tRoot.Position.Y > root.Position.Y + 4 then
                    if not AutoFloor then ToggleFloor(true) end
                    if tick() - lastJumpTick > 0.6 then hum.Jump = true lastJumpTick = tick() end
                elseif tRoot.Position.Y < root.Position.Y - 2 then
                    if AutoFloor then ToggleFloor(false) end
                end
            end
        end

        -- تطبيق السرعة
        if moveVec.Magnitude > 0 or Following then
            LV.PlaneVelocity = Vector2.new(moveVec.X * TargetSpeed, moveVec.Z * TargetSpeed)
        else
            LV.PlaneVelocity = Vector2.new(0, 0)
        end

        -- تحريك الأرضية
        if AutoFloor and FloorPart then
            FloorPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.9, root.Position.Z)
            if root.Velocity.Y < 0 then root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z) end
        end
    end
end)

task.spawn(function()
    while task.wait(0.29) do
        if AutoSlap and LP.Character then
            local target = GetClosest()
            if target and target.Character and (target.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude < 10 then
                local tool = LP.Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
        if EHackActive then
            for _, v in pairs(workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end end
        end
    end
end)
