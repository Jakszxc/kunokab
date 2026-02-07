-- [[ KAITUN TRUE SCRIPT - STATIC BRING MOB EDITION ]]
repeat task.wait() until game:IsLoaded()

local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [ 1. BYPASS & AUTO TEAM ]
Player.ReplicationFocus = workspace
local function ForceTeam()
    task.spawn(function()
        while not Player.Team do
            pcall(function() CommF:InvokeServer("SetTeam", "Pirates") end)
            task.wait(1)
        end
    end)
end
ForceTeam()

-- [ 2. SMART TWEEN ENGINE ]
local function SmartTween(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local dist = (targetCFrame.p - root.Position).Magnitude
    if dist < 10 then root.CFrame = targetCFrame return end

    local tween = TS:Create(root, TweenInfo.new(dist/_G.Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    local arrived = false
    local connection = tween.Completed:Connect(function() arrived = true end)
    repeat task.wait() until arrived or not _G.Config.AutoFarm
    connection:Disconnect()
end

-- [[ 3. HÀM BRING MOB TẠI ĐIỂM CỐ ĐỊNH ]]
local function BringMobToStaticPoint(targetPoint, mName)
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == mName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            -- Kéo tất cả quái về điểm cố định (Tâm bãi quái)
            if (v.HumanoidRootPart.Position - targetPoint.p).Magnitude < 350 then
                v.HumanoidRootPart.CFrame = targetPoint
                v.HumanoidRootPart.CanCollide = false
                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
                v.Humanoid:ChangeState(11)
            end
        end
    end
end

-- [ 4. DATA QUEST 1-210 ]
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
    else return "PrisonerQuest", 1, "Prisoner", CFrame.new(5311, 0, 475), CFrame.new(5090, 0, 424) end
end

-- [[ 5. MAIN FARM LOOP ]]
task.spawn(function()
    while task.wait() do
        if _G.Config.AutoFarm and Player.Team ~= nil and not _G.IsBuying then
            pcall(function()
                local qName, qID, mName, npcPos, mobArea = GetQuestData()
                
                if not Player.PlayerGui.Main.Quest.Visible then
                    SmartTween(npcPos)
                    if (Player.Character.HumanoidRootPart.Position - npcPos.p).Magnitude < 15 then
                        task.wait(0.5)
                        CommF:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    -- 1. Kiểm tra nếu có quái trong bãi
                    local hasMob = false
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v.Humanoid.Health > 0 then hasMob = true; break end
                    end

                    if hasMob then
                        -- 2. Đứng cố định tại tâm bãi quái (Distance: 13)
                        Player.Character.HumanoidRootPart.CFrame = mobArea * CFrame.new(0, _G.Config.FarmHeight, 0)
                        
                        -- 3. Liên tục kéo quái về tâm
                        BringMobToStaticPoint(mobArea, mName)

                        -- 4. Tấn công
                        local tool = Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat") or Player.Character:FindFirstChildOfClass("Tool")
                        if tool then Player.Character.Humanoid:EquipTool(tool) end
                        
                        RS.Modules.Net["RE/RegisterAttack"]:FireServer()
                        -- Hit tất cả quái tại tâm
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == mName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - mobArea.p).Magnitude < 20 then
                                RS.Modules.Net["RE/RegisterHit"]:FireServer(v.HumanoidRootPart)
                            end
                        end
                        task.wait(_G.Config.AttackSpeed)
                    else
                        -- 5. Nếu không thấy quái, Tween đi tuần tra các điểm spawn để kích hoạt Streaming load quái
                        SmartTween(mobArea)
                        task.wait(0.2)
                    end
                end
            end)
        end
    end
end)

-- [ CÁC LOGIC MISC GIỮ NGUYÊN ]
task.spawn(function()
    while task.wait(3) do
        if _G.Config.AutoStat then
            local p = Player.Data.StatsPoints.Value
            if p > 0 then CommF:InvokeServer("AddPoint", _G.Config.StatTarget, p) end
        end
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    if _G.Config.AutoFarm and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

print("STATIC BRING MOB LOADED!")
