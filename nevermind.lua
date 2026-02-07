-- [[ KAITUN FULL LOGIC 1-210 - STREAMING BYPASS PRO ]]
repeat task.wait() until game:IsLoaded()

local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [ 1. BYPASS STREAMING & AUTO TEAM ]
Player.ReplicationFocus = workspace

local function ForceTeam()
    task.spawn(function()
        while not Player.Team do
            pcall(function()
                CommF:InvokeServer("SetTeam", "Pirates")
            end)
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
    
    if dist < 15 then 
        root.CFrame = targetCFrame 
        return 
    end

    local tween = TS:Create(root, TweenInfo.new(dist/_G.Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    
    -- Chờ cho đến khi Tween xong hoặc bị hủy
    repeat task.wait() until (targetCFrame.p - root.Position).Magnitude < 15 or not _G.Config.AutoFarm
end

-- [ 3. DATA QUEST LEVEL 1-210 ]
local function GetQuestData()
    local lv = Player.Data.Level.Value
    if lv < 10 then 
        return "BanditQuest1", 1, "Bandit", CFrame.new(1059, 13, 1552), CFrame.new(1145, 17, 1630)
    elseif lv < 15 then 
        return "JungleQuest", 1, "Monkey", CFrame.new(-1598, 36, 153), CFrame.new(-1610, 21, -48)
    elseif lv < 30 then 
        return "JungleQuest", 2, "Gorilla", CFrame.new(-1598, 36, 153), CFrame.new(-1249, 8, -456)
    elseif lv < 40 then 
        return "BuggyQuest1", 1, "Pirate", CFrame.new(-1141, 1, 3832), CFrame.new(-1140, 6, 3902)
    elseif lv < 60 then 
        return "BuggyQuest1", 2, "Brute", CFrame.new(-1141, 1, 3832), CFrame.new(-1145, 15, 4300)
    elseif lv < 75 then 
        return "DesertQuest", 1, "Desert Bandit", CFrame.new(894, 6, 4392), CFrame.new(937, 8, 4429)
    elseif lv < 90 then 
        return "DesertQuest", 2, "Desert Officer", CFrame.new(894, 6, 4392), CFrame.new(1578, 4, 4300)
    elseif lv < 100 then 
        return "SnowQuest", 1, "Snow Bandit", CFrame.new(1387, 87, -1295), CFrame.new(1381, 89, -1465)
    elseif lv < 120 then 
        return "SnowQuest", 2, "Snowman", CFrame.new(1387, 87, -1295), CFrame.new(1190, 107, -1627)
    elseif lv < 150 then 
        return "MarineQuest2", 1, "Marine Chief", CFrame.new(-5040, 28, 4325), CFrame.new(-4809, 21, 4540)
    elseif lv < 175 then 
        return "SkyQuest", 1, "Sky Bandit", CFrame.new(-4840, 717, -2619), CFrame.new(-4945, 278, -2785)
    elseif lv < 190 then 
        return "SkyQuest", 2, "Dark Bird", CFrame.new(-4840, 717, -2619), CFrame.new(-5244, 390, -2155)
    else 
        return "PrisonerQuest", 1, "Prisoner", CFrame.new(5311, 0, 475), CFrame.new(5090, 0, 424) 
    end
end

-- [ 4. MAIN FARM LOOP ]
task.spawn(function()
    while task.wait() do
        if _G.Config.AutoFarm and Player.Team ~= nil then
            pcall(function()
                local qName, qID, mName, npcPos, mobArea = GetQuestData()
                
                -- KIỂM TRA QUEST
                if not Player.PlayerGui.Main.Quest.Visible then
                    -- BƯỚC 1: TWEEN ĐẾN NPC TRƯỚC
                    SmartTween(npcPos)
                    
                    -- BƯỚC 2: CHỈ KHI ĐẾN NƠI MỚI BẤM NHẬN QUEST
                    if (Player.Character.HumanoidRootPart.Position - npcPos.p).Magnitude < 15 then
                        task.wait(0.5) -- Đợi 0.5s cho NPC load hẳn
                        CommF:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    -- Nếu sai quest thì hủy
                    if not string.find(Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, mName) then
                        CommF:InvokeServer("AbandonQuest")
                        return
                    end
                    
                    -- TÌM VÀ GOM QUÁI
                    local targetMob = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMob = v; break
                        end
                    end
                    
                    if targetMob then
                        -- Bring Mob logic
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if v.Name == mName and v:FindFirstChild("HumanoidRootPart") then
                                if (v.HumanoidRootPart.Position - targetMob.HumanoidRootPart.Position).Magnitude < 250 then
                                    v.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame
                                    v.HumanoidRootPart.CanCollide = false
                                end
                            end
                        end

                        -- Giữ khoảng cách Distance (Distance: 13)
                        Player.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, _G.Config.FarmHeight, 0)
                        
                        -- Equip Tool
                        local tool = Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat") or Player.Character:FindFirstChildOfClass("Tool")
                        if tool then Player.Character.Humanoid:EquipTool(tool) end
                        
                        -- Attack (Speed: 0.3)
                        RS.Modules.Net["RE/RegisterAttack"]:FireServer()
                        RS.Modules.Net["RE/RegisterHit"]:FireServer(targetMob.HumanoidRootPart)
                        task.wait(_G.Config.AttackSpeed)
                    else
                        -- Nếu hết quái thì Tween ra khu vực chờ quái spawn
                        SmartTween(mobArea)
                    end
                end
            end)
        end
    end
end)

-- [ CÁC LOGIC PHỤ: COLLISION & WHITE SCREEN ]
game:GetService("RunService").Stepped:Connect(function()
    if _G.Config.AutoFarm and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

if _G.Config.WhiteScreen then game:GetService("RunService"):Set3dRenderingEnabled(false) end
print("BYPASS STREAMING PRO LOADED!")
