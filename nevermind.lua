local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ 1. CONFIG HỆ THỐNG ]]
_G.Config = {
    AutoFarm = false,
    FarmHeight = 25,
    TweenSpeed = 300,
    -- Stats
    AutoStat = false,
    StatTarget = "Melee",
    -- Misc
    AutoCode = false,
    AutoBuso = true,
    AutoBuyHaki = false,
    AutoBuyBlackLeg = false,
    AutoGacha = false,
    WhiteScreen = false,
    AutoStore = true
}

-- [[ 2. GIAO DIỆN UI ]]
local Window = Fluent:CreateWindow({
    Title = "KAITUN HUB | SEA 1",
    SubTitle = "By User",
    TabWidth = 160, Size = UDim2.fromOffset(580, 460), Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Auto Farm", Icon = "home" }),
    Misc = Window:AddTab({ Title = "Misc & Shop", Icon = "shopping-cart" })
}

-- TAB MAIN
Tabs.Main:AddToggle("FarmLvl", {Title = "Auto Farm Level", Default = false}):OnChanged(function(V) _G.Config.AutoFarm = V end)
Tabs.Main:AddSlider("Height", {Title = "Farm Height", Default = 25, Min = 10, Max = 50, Callback = function(V) _G.Config.FarmHeight = V end})
Tabs.Main:AddToggle("StatTog", {Title = "Auto Upgrade Stats", Default = false}):OnChanged(function(V) _G.Config.AutoStat = V end)
Tabs.Main:AddDropdown("StatSelect", {
    Title = "Stat Target",
    Values = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Current = "Melee",
    Callback = function(V) _G.Config.StatTarget = V end
})

-- TAB MISC
Tabs.Misc:AddToggle("CodeTog", {Title = "Auto Redeem All Codes", Default = false}):OnChanged(function(V) _G.Config.AutoCode = V end)
Tabs.Misc:AddToggle("HakiTog", {Title = "Auto Buy Haki/Geppo", Default = false}):OnChanged(function(V) _G.Config.AutoBuyHaki = V end)
Tabs.Misc:AddToggle("BlackLegTog", {Title = "Auto Buy Black Leg", Default = false}):OnChanged(function(V) _G.Config.AutoBuyBlackLeg = V end)
Tabs.Misc:AddToggle("GachaTog", {Title = "Auto Gacha & Store", Default = false}):OnChanged(function(V) _G.Config.AutoGacha = V end)
Tabs.Misc:AddToggle("WS", {Title = "White Screen (Anti-Lag)", Default = false}):OnChanged(function(V)
    _G.Config.WhiteScreen = V
    game:GetService("RunService"):Set3dRenderingEnabled(not V)
end)

-- [[ 3. BIẾN VÀ SERVICES ]]
local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = RS.Modules.Net

-- [[ 4. HÀM SMART MOVE ]]
local function SmartMove(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local distance = (targetCFrame.p - root.Position).Magnitude
    if distance < 15 then root.CFrame = targetCFrame return end
    
    local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(distance / _G.Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    if not _G.Config.AutoFarm and not _G.IsBuying then tween:Cancel() end
end

-- [[ 5. AUTO STATS & MISC LOOP ]]
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if _G.Config.AutoStat then
                local p = Player.Data.StatsPoints.Value
                if p > 0 then CommF:InvokeServer("AddPoint", _G.Config.StatTarget, p) end
            end
            
            if _G.Config.AutoBuso and Player.Character and not Player.Character:FindFirstChild("HasBuso") then
                CommF:InvokeServer("Buso")
            end

            if _G.Config.AutoBuyHaki and Player.Data.Beli.Value >= 25000 then
                if not Player.Character:FindFirstChild("Geppo") then
                    _G.IsBuying = true
                    SmartMove(CFrame.new(-1033, 15, 6724))
                    CommF:InvokeServer("BuyHaki", "Geppo")
                    CommF:InvokeServer("BuyHaki", "Buso")
                    _G.IsBuying = false
                end
            end

            if _G.Config.AutoGacha then
                CommF:InvokeServer("Cousin", "Buy")
                if _G.Config.AutoStore then
                    for _, v in pairs(Player.Backpack:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("Fruit") or v.Name:find("Fruit") then
                            CommF:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v)
                        end
                    end
                end
            end
        end)
    end
end)

-- [[ 6. GET QUEST DATA (TỐI ƯU) ]]
local function GetQuestData()
    local lv = Player.Data.Level.Value
    if lv < 10 then return "BanditQuest1", 1, "Bandit", CFrame.new(1059, 13, 1552), CFrame.new(1145, 17, 1630)
    elseif lv < 15 then return "JungleQuest", 1, "Monkey", CFrame.new(-1598, 36, 153), CFrame.new(-1610, 21, -48)
    elseif lv < 30 then return "JungleQuest", 2, "Gorilla", CFrame.new(-1598, 36, 153), CFrame.new(-1249, 8, -456)
    elseif lv < 40 then return "BuggyQuest1", 1, "Pirate", CFrame.new(-1141, 1, 3832), CFrame.new(-1140, 6, 3902)
    elseif lv < 60 then return "BuggyQuest1", 2, "Brute", CFrame.new(-1141, 1, 3832), CFrame.new(-1145, 15, 4300)
    elseif lv < 75 then return "DesertQuest", 1, "Desert Bandit", CFrame.new(894, 6, 4392), CFrame.new(937, 8, 4429)
    elseif lv < 90 then return "DesertQuest", 2, "Desert Officer", CFrame.new(894, 6, 4392), CFrame.new(1578, 4, 4300)
    elseif lv < 100 then return "SnowQuest", 1, "Snow Bandit", CFrame.new(1387, 87, -1295), CFrame.new(1381, 89, -1465)
    elseif lv < 120 then return "SnowQuest", 2, "Snowman", CFrame.new(1387, 87, -1295), CFrame.new(1190, 107, -1627)
    elseif lv < 150 then return "MarineQuest2", 1, "Marine Chief", CFrame.new(-5040, 28, 4325), CFrame.new(-4809, 21, 4540)
    elseif lv < 175 then return "SkyQuest", 1, "Sky Bandit", CFrame.new(-4840, 717, -2619), CFrame.new(-4945, 278, -2785)
    else return "PrisonerQuest", 1, "Prisoner", CFrame.new(5311, 0, 475), CFrame.new(5090, 0, 424) end
end

-- [[ 7. MAIN FARM LOOP ]]
task.spawn(function()
    while task.wait() do
        if _G.Config.AutoFarm and not _G.IsBuying then
            pcall(function()
                local qName, qID, mName, npcPos, mobArea = GetQuestData()
                if not Player.PlayerGui.Main.Quest.Visible then
                    SmartMove(npcPos)
                    if (Player.Character.HumanoidRootPart.Position - npcPos.p).Magnitude < 15 then
                        CommF:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    local targetMob = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMob = v; break
                        end
                    end
                    if targetMob then
                        SmartMove(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, _G.Config.FarmHeight, 0))
                        local tool = Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat") or Player.Character:FindFirstChildOfClass("Tool")
                        if tool then Player.Character.Humanoid:EquipTool(tool) end
                        require(RS.Modules.Net)["RE/RegisterAttack"]:FireServer()
                        require(RS.Modules.Net)["RE/RegisterHit"]:FireServer(targetMob.HumanoidRootPart)
                    else
                        SmartMove(mobArea)
                    end
                end
            end)
        end
    end
end)

-- [[ 8. ANTI-LAG & PHYSICS ]]
game:GetService("RunService").Stepped:Connect(function()
    if _G.Config.AutoFarm and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

Fluent:Notify({Title = "KAITUN READY", Content = "Chúc sếp farm ngon!", Duration = 5})
