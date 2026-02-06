-- [[ PANDA DEVELOPMENT - INTEGRATED CORE ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 1. SETUP CONFIG (Kết nối UI và Logic)
_G.Config = {
    AutoFarm = false,
    FarmHeight = 25,
    TweenSpeed = 300,
    Team = "Pirates",
    StatTarget = "Melee",
    AutoCode = true,
    AutoGacha = false
}

-- 2. SETUP UI (Fluent)
local Window = Fluent:CreateWindow({
    Title = "Panda Hub | Kaitun Edition",
    SubTitle = "Sea 1 - Fast & Smooth",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main Farm", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "component" })
}

-- Add Controls vào UI
Tabs.Main:AddToggle("FarmToggle", {Title = "Auto Farm Level", Default = false}):OnChanged(function(Value) _G.Config.AutoFarm = Value end)
Tabs.Main:AddSlider("Height", {Title = "Farm Height", Default = 25, Min = 10, Max = 50, Rounding = 1, Callback = function(V) _G.Config.FarmHeight = V end})
Tabs.Main:AddSlider("Speed", {Title = "Tween Speed", Default = 300, Min = 100, Max = 500, Rounding = 1, Callback = function(V) _G.Config.TweenSpeed = V end})

-- 3. CORE LOGIC (Giữ nguyên tinh hoa của bạn nhưng tối ưu RAM)
local Player = game:GetService("Players").LocalPlayer
local CommF = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")

-- Smart Movement Engine
local function SmartMove(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local distance = (targetCFrame.p - root.Position).Magnitude
    if distance < 15 then root.CFrame = targetCFrame return end
    
    local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(distance / _G.Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    -- Ngắt tween nếu tắt AutoFarm để tránh bị bay lơ lửng
    if not _G.Config.AutoFarm then tween:Cancel() end
end

-- Farm Loop (Chạy ngầm)
task.spawn(function()
    while task.wait() do
        if _G.Config.AutoFarm then
            pcall(function()
                -- [ Logic GetQuestData và Farm của bạn đặt ở đây ]
                -- Nhớ dùng _G.Config.FarmHeight từ UI để người dùng tự chỉnh độ cao
                
                -- Ví dụ Attack nhanh:
                local tool = Player.Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat")
                if tool and not Player.Character:FindFirstChild(tool.Name) then
                    Player.Character.Humanoid:EquipTool(tool)
                end
                
                -- Click chuột trái giả lập
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
            end)
        end
    end
end)

-- Anti-Collide & Velocity Control (Phần này quan trọng để không bị kẹt địa hình)
game:GetService("RunService").Stepped:Connect(function()
    if _G.Config.AutoFarm and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

Fluent:Notify({Title = "Panda Hub", Content = "Script Ready!", Duration = 3})
