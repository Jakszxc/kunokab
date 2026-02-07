-- [[ KAITUN FULL LOGIC 1-210 ]]
local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = RS.Modules.Net

-- Check Config (Phòng trường hợp người dùng xóa config)
_G.Config = _G.Config or {AutoFarm = true, FarmHeight = 25, TweenSpeed = 300}

-- [ HÀM SMART MOVE ]
local function SmartMove(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = Player.Character.HumanoidRootPart
    local dist = (targetCFrame.p - root.Position).Magnitude
    if dist < 15 then root.CFrame = targetCFrame return end
    
    local tween = TS:Create(root, TweenInfo.new(dist/_G.Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
end

-- [ DATA QUEST LEVEL 1-210 ]
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

-- [ VÒNG LẶP MISC - CHẠY RIÊNG CHO MƯỢT ]
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local beli = Player.Data.Beli.Value
            
            -- Auto Stats
            if _G.Config.AutoStat then
                local p = Player.Data.StatsPoints.Value
                if p > 0 then CommF:InvokeServer("AddPoint", _G.Config.StatTarget or "Melee", p) end
            end

            -- Auto Buy Haki
            if _G.Config.AutoBuyHaki and beli >= 25000 and not Player.Character:FindFirstChild("Geppo") then
                _G.IsBuying = true
                SmartMove(CFrame.new(-1033, 15, 6724))
                CommF:InvokeServer("BuyHaki", "Geppo")
                CommF:InvokeServer("BuyHaki", "Buso")
                _G.IsBuying = false
            end

            -- Auto Buy Black Leg
            if _G.Config.AutoBuyBlackLeg and beli >= 150000 then
                if not (Player.Backpack:FindFirstChild("Black Leg") or Player.Character:FindFirstChild("Black Leg")) then
                    _G.IsBuying = true
                    SmartMove(CFrame.new(-1106, 5, 3882))
                    CommF:InvokeServer("BuyBlackLeg")
                    _G.IsBuying = false
                end
            end

            -- Auto Gacha & Store
            if _G.Config.AutoGacha then
                CommF:InvokeServer("Cousin", "Buy")
                for _, v in pairs(Player.Backpack:GetChildren()) do
                    if v:IsA("Tool") and (v:FindFirstChild("Fruit") or v.Name:find("Fruit")) then
                        CommF:InvokeServer("StoreFruit", v:GetAttribute("FruitName") or v.Name, v)
                    end
                end
            end

            -- Auto Code
            if _G.Config.AutoCode then
                local codes = {"LIGHTNINGABUSE", "fudd10", "fudd10_V2", "BIGNEWS", "SUB2GAMERROBOT_EXP1"}
                for _, c in pairs(codes) do RS.Remotes.Redeem:InvokeServer(c) end
                _G.Config.AutoCode = false
            end

            -- Auto Buso
            if _G.Config.AutoBuso and not Player.Character:FindFirstChild("HasBuso") then
                CommF:InvokeServer("Buso")
            end
        end)
    end
end)

-- [ MAIN FARM LOOP ]
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
                        Player.Character.HumanoidRootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, _G.Config.FarmHeight, 0)
                        local tool = Player.Backpack:FindFirstChild("Black Leg") or Player.Backpack:FindFirstChild("Combat") or Player.Character:FindFirstChildOfClass("Tool")
                        if tool then Player.Character.Humanoid:EquipTool(tool) end
                        
                        -- Fast Attack
                        game:GetService("VirtualUser"):CaptureController()
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
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

-- [ ANTI-COLLIDE & PHYSICS ]
game:GetService("RunService").Stepped:Connect(function()
    if _G.Config.AutoFarm and Player.Character then
        for _, v in pairs(Player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

if _G.Config.WhiteScreen then game:GetService("RunService"):Set3dRenderingEnabled(false) end
print("KAITUN FULL 1-210 LOADED!")
