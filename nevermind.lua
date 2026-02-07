-- [[ PANDA DEVELOPMENT - CORE LOGIC ]]
-- [[ COMPATIBLE WITH EXTERNAL CONFIG ]]

local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = RS.Modules.Net

-- [[ 0. CONFIG CHECKER ]]
-- Nếu người dùng không để Config ở ngoài, script sẽ tự lấy bộ này
_G.Config = _G.Config or {
    Team = "Pirates",
    AutoFarm = true,
    TeleportFarm = false,
    FarmHeight = 20,
    TweenSpeed = 300,
    StatTarget = "Melee",
    AutoCode = true,
    AutoGacha = true,
    AutoBuyHaki = true,
    AutoBuyBlackLeg = true,
    AutoBuso = true
}

-- [[ 1. AUTO TEAM JOINER ]]
task.spawn(function()
    if not Player.Team or Player.Team.Name == "" then
        local targetTeam = (_G.Config.Team == "Marines") and "Marines" or "Pirates"
        repeat task.wait()
            CommF:InvokeServer("SetTeam", targetTeam)
        until Player.Team ~= nil
    end
end)

-- [[ 2. SMART MOVEMENT ENGINE ]]
local function SmartMove(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local distance = (targetCFrame.p - root.Position).Magnitude
    
    if distance < 10 then 
        root.CFrame = targetCFrame
        return 
    end

    if _G.Config.TeleportFarm then
        root.CFrame = targetCFrame
    else
        local tSpeed = _G.Config.TweenSpeed or 300
        local tween = TS:Create(root, TweenInfo.new(distance / tSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- [[ 3. AUTO CODE REDEEMER ]]
if _G.Config.AutoCode then
    task.spawn(function()
        local codeList = {"LIGHTNINGABUSE", "fudd10", "fudd10_V2", "Chandler", "BIGNEWS", "KITT_RESET", "Sub2UncleKizaru", "SUB2GAMERROBOT_RESET1", "Sub2Fer999", "Enyu_is_Pro", "JCWK", "StarcodeHEO", "MagicBUS", "KittGaming", "Sub2CaptainMaui", "Sub2OfficialNoobie", "TheGreatAce", "Sub2NoobMaster123", "Sub2Daigrock", "Axiore", "StrawHatMaine", "TantaiGaming", "Bluxxy", "SUB2GAMERROBOT_EXP1"}
        for _, code in pairs(codeList) do
            RS.Remotes.Redeem:InvokeServer(code)
            task.wait(0.1)
        end
    end)
end

-- [[ 4. QUEST DATA ]]
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
    elseif lv < 190 then return "SkyQuest", 2, "Dark Bird", CFrame.new(-4840, 717, -2619), CFrame.new(-5244, 390, -2155)
    elseif lv < 210 then return "PrisonerQuest", 1, "Prisoner", CFrame.new(5311, 0, 475), CFrame.new(5090, 0, 424)
    else return "PrisonerQuest", 2, "Dangerous Prisoner", CFrame.new(5311, 0, 475), CFrame.new(5485, 0, 468) end
end

-- [[ 5. MAIN FARM LOOP ]]
task.spawn(function()
    while task.wait() do
        if not _G.Config.AutoFarm or _G.IsBuying then continue end
        pcall(function()
            local qName, qID, mName, npcPos, mobArea = GetQuestData()
            local height = _G.Config.FarmHeight or 20
            
            if not Player.PlayerGui.Main.Quest.Visible then
                SmartMove(npcPos)
                if (Player.Character.HumanoidRootPart.Position - npcPos.p).Magnitude < 15 then
                    CommF:InvokeServer("StartQuest", qName, qID)
                end
            else
                if not string.find(Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, mName) then
                    CommF:InvokeServer("AbandonQuest") return
                end
                
                local targetMob = nil
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v.Name == mName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        targetMob = v; break
                    end
                end

                if targetMob then
                    local farmPos = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, height, 0)
                    if (Player.Character.HumanoidRootPart.Position - farmPos.p).Magnitude > 5 then
                        SmartMove(farmPos)
                    end
                    
                    local tool = Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat")
                    if tool then Player.Character.Humanoid:EquipTool(tool) end
                    Net["RE/RegisterAttack"]:FireServer()
                    Net["RE/RegisterHit"]:FireServer(targetMob.HumanoidRootPart)
                else
                    SmartMove(mobArea * CFrame.new(0, height, 0))
                end
            end
        end)
    end
end)

-- [[ 6. UTILITIES ]]
task.spawn(function()
    local lastGacha = 0
    while task.wait(5) do
        pcall(function()
            local beli = Player.Data.Beli.Value
            
            if _G.Config.AutoBuso and Player.Character and not Player.Character:FindFirstChild("HasBuso") then
                CommF:InvokeServer("Buso")
            end
            
            if beli >= 25000 and _G.Config.AutoBuyHaki then
                if not Player.Character:FindFirstChild("Geppo") then
                    _G.IsBuying = true
                    SmartMove(CFrame.new(-1033, 15, 6724))
                    CommF:InvokeServer("BuyHaki", "Buso")
                    CommF:InvokeServer("BuyHaki", "Geppo")
                    _G.IsBuying = false
                end
            end
            
            if beli >= 150000 and _G.Config.AutoBuyBlackLeg then
                if not (Player.Backpack:FindFirstChild("Black Leg") or Player.Character:FindFirstChild("Black Leg")) then
                    _G.IsBuying = true
                    SmartMove(CFrame.new(-1106.5, 4.7, 3882.1))
                    CommF:InvokeServer("BuyBlackLeg")
                    _G.IsBuying = false
                end
            end
            
            if _G.Config.AutoGacha and (tick() - lastGacha >= 1800) then
                if CommF:InvokeServer("Cousin", "CheckCanBuyType", "DLCBoxData") then
                    RS.Modules.Net["RF/GachaUtilRF"]:InvokeServer({Context = "getGachaFromBoxName", BoxName = "SummerWeek5Gacha"})
                    lastGacha = tick()
                end
            end
            
            if _G.Config.AutoStat then
                CommF:InvokeServer("AddPoint", _G.Config.StatTarget or "Melee", 3)
            end
        end)
    end
end)

-- [[ 7. PHYSICS ]]
game:GetService("RunService").Stepped:Connect(function()
    if Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root and not root:FindFirstChild("VelocityControl") then
            local bv = Instance.new("BodyVelocity", root)
            bv.Name = "VelocityControl"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Success Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Panda Kaitun",
    Text = "Logic Loaded Successfully!",
    Duration = 5
})
