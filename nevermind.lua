-- [[ KAITUN FULL LOGIC 1-210 - BRING MOB EDITION ]]
repeat task.wait() until game:IsLoaded()

-- [ 1. BYPASS STREAMING DATA ]
if game:GetService("Workspace"):FindFirstChild("StreamingEnabled") then
    game:GetService("Players").LocalPlayer.ReplicationFocus = workspace
end

-- [ 2. FORCE AUTO TEAM ]
local function ForceTeam()
    local joinRem = game:GetService("ReplicatedStorage").Remotes.CommF_
    task.spawn(function()
        while true do
            if game:GetService("Players").LocalPlayer.Team == nil then
                joinRem:InvokeServer("SetTeam", "Pirates")
            else
                break
            end
            task.wait(0.5)
        end
    end)
end
ForceTeam()

-- [ CÁC BIẾN HỆ THỐNG ]
local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")

_G.Config = _G.Config or {AutoFarm = true, FarmHeight = 25, TweenSpeed = 300}

-- [ HÀM SMART MOVE ]
local function SmartMove(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local dist = (targetCFrame.p - root.Position).Magnitude
    if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
    if dist < 15 then root.CFrame = targetCFrame return end
    TS:Create(root, TweenInfo.new(dist/_G.Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame}):Play()
end

-- [[ 3. HÀM BRING MOB (GOM QUÁI) ]]
local function BringMob(targetMob, mName)
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == mName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
            -- Chỉ gom những con quái ở gần con quái mục tiêu (tránh kéo quái cả map bị kick)
            if (v.HumanoidRootPart.Position - targetMob.HumanoidRootPart.Position).Magnitude < 300 then
                v.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame
                v.HumanoidRootPart.CanCollide = false
                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end -- Chặn quái đánh trả
                v.Humanoid:ChangeState(11) -- Đứng yên
            end
        end
    end
end

-- [ DATA QUEST LEVEL 1-210 ]
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

-- [ MAIN FARM LOOP ]
task.spawn(function()
    while task.wait() do
        if _G.Config.AutoFarm and Player.Team ~= nil and not _G.IsBuying then
            pcall(function()
                local qName, qID, mName, npcPos, mobArea = GetQuestData()
                
                if not Player.PlayerGui.Main.Quest.Visible then
                    SmartMove(npcPos)
                    if (Player.Character.HumanoidRootPart.Position - npcPos.p).Magnitude < 15 then
                        CommF:InvokeServer("StartQuest", qName, qID)
                    end
                else
                    if not string.find(Player.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, mName) then
                        CommF:InvokeServer("AbandonQuest")
                    end
                    
                    local targetMob = nil
                    for _, v in pairs(workspace.Enemies:GetChildren()) do
                        if v.Name == mName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetMob = v; break
                        end
                    end
                    
                    if targetMob then
                        -- GỌI HÀM GOM QUÁI
                        BringMob(targetMob, mName)
                        
                        -- Farm ngay trên đầu quái
                        Player.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, _G.Config.FarmHeight, 0)
                        
                        local tool = Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat") or Player.Character:FindFirstChildOfClass("Tool")
                        if tool then Player.Character.Humanoid:EquipTool(tool) end
                        
                        -- Attack
                        RS.Modules.Net["RE/RegisterAttack"]:FireServer()
                        RS.Modules.Net["RE/RegisterHit"]:FireServer(targetMob.HumanoidRootPart)
                    else
                        SmartMove(mobArea)
                    end
                end
            end)
        end
    end
end)

-- [ AUTO MISC ]
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            if _G.Config.AutoStat then
                local p = Player.Data.StatsPoints.Value
                if p > 0 then CommF:InvokeServer("AddPoint", _G.Config.StatTarget or "Melee", p) end
            end
            if _G.Config.AutoBuso and not Player.Character:FindFirstChild("HasBuso") then CommF:InvokeServer("Buso") end
        end)
    end
end)

-- [ PHYSICS ]
game:GetService("RunService").Stepped:Connect(function()
    if _G.Config.AutoFarm and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

if _G.Config.WhiteScreen then game:GetService("RunService"):Set3dRenderingEnabled(false) end
print("KAITUN BRING MOB LOADED!")
