local services = setmetatable({},{__index = function(_,serv) return game:GetService(serv) end})
local classRemotes = services.ReplicatedStorage.Classes
local prevConnections = {}

local localPlayer = services.Players.LocalPlayer

-- ============================================
-- NEW: Human reaction time helper (was instant before)
-- Old: No delays, instant responses
-- New: 0.3-0.8 second natural reaction time
-- ============================================
local function humanWait(minSec, maxSec)
    local baseWait = minSec or 0.3
    local maxWait = maxSec or (minSec or 0.3) + 0.5
    local variance = math.random() * 0.3
    task.wait(baseWait + variance + math.random(0, (maxWait - baseWait) * 10) / 10)
end

-- ============================================
-- NEW: Random delay between actions (was none before)
-- ============================================
local function actionDelay()
    task.wait(math.random(0.8, 2.5) + (math.random() * 0.5))
end

-- ============================================
-- NEW: Random locker code generator (was hardcoded "0000" before)
-- ============================================
local function generateLockerCode()
    local code = ""
    for i = 1, 4 do
        code = code .. math.random(0, 9)
    end
    if code == "0000" or code == "1234" or code == "1111" then
        return generateLockerCode()
    end
    return code
end

-- ============================================
-- CHANGED: Added human delays between remote fires
-- Old: Instant firing, no delays
-- New: 0.5-1.5 second delay between each fire
-- ============================================
function fireBack(remote, times, ...)
    local args = {...}
    return remote.OnClientEvent:Connect(function()
        for i = 0, times do
            humanWait(0.5, 1.5)
            remote:FireServer(unpack(args))
        end
    end)
end

local classFuncs = {
    -- ============================================
    -- SWIMMING CLASS - COMPLETELY REWRITTEN
    -- OLD: hrp.CFrame + Vector3.new(0,10,0) + Anchored = true
    -- OLD: Perfect stillness for 55 seconds (detectable)
    -- NEW: Jump simulation with 85-95% success rate
    -- NEW: Random obstacle timing (1.5-4 seconds)
    -- NEW: Occasional failures with recovery time
    -- ============================================
    swimming = function()
        return {
            classRemotes.Timer.OnClientEvent:Connect(function()
                local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
                if not humanoid then return end
                
                local startTime = tick()
                local duration = 55
                local consecutiveFails = 0
                
                while tick() - startTime < duration do
                    local timeToObstacle = math.random(15, 40) / 10
                    task.wait(timeToObstacle)
                    
                    local successRate = math.random(85, 95)
                    local success = math.random(1, 100) <= successRate
                    
                    if success then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.15)
                        consecutiveFails = 0
                    else
                        consecutiveFails = consecutiveFails + 1
                        task.wait(math.random(2, 4))
                        
                        if consecutiveFails >= 2 then
                            task.wait(timeToObstacle)
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            consecutiveFails = 0
                        end
                    end
                end
            end)
        }
    end,
    
    -- ============================================
    -- ART CLASS - ADDED HUMAN DELAYS
    -- OLD: No delays, instant painting
    -- NEW: 1-3 second study time, 0.2-0.6 sec between colors
    -- ============================================
    art = function() 
        local function getCanvasData()
            local canvas = {}
            for _,part in next, workspace.ArtClassReal.MainEasel.CanvasToCopy:GetChildren() do
                canvas[part.Name] = part.BrickColor.Number
            end
            return canvas
        end
        
        local function fillCanvas()
            humanWait(1, 3)
            for name,num in next, getCanvasData() do
                humanWait(0.2, 0.6)
                services.ReplicatedStorage.Tools.Paint.SetColor:FireServer(workspace.ArtClassReal.Easel.Canvas:FindFirstChild(name), BrickColor.new(num))
            end
        end
        
        return {
            classRemotes.BookCheck.OnClientEvent:Connect(function()
                humanWait(0.8, 2)
                fillCanvas()
            end)
        }
    end,
    
    computer = function()
        return {fireBack(classRemotes.Computer, 1, 1)}
    end,

    chemistry = function()
        return {fireBack(classRemotes.Chemistry, 1, "SequenceDone")}
    end,

    -- ============================================
    -- PE CLASS - ADDED REALISTIC TIMING
    -- OLD: Instant teleport, completed in 1 second
    -- NEW: 50-60 second delay before teleport (looks human)
    -- NOTE: Still uses teleport but hides it with wait
    -- ============================================
    pe = function()
        return {
            classRemotes.Timer.OnClientEvent:Connect(function()
                humanWait(0.5, 1.5)
                
                if not workspace:FindFirstChild("PE Class") then return end
                
                local bell = workspace["PE Class"].Bell
                
                local realisticCourseTime = math.random(50, 60)
                
                task.wait(realisticCourseTime)
                
                local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(-1604, 20, 9)
                end
                
                humanWait(0.2, 0.5)
                fireclickdetector(bell.ClickDetector, 4)
            end)   
        }
    end,
    
    -- ============================================
    -- ENGLISH CLASS - ADDED READING TIME
    -- OLD: 0.1 second response (inhuman)
    -- NEW: 1.5-4 second reading time + 0.3-0.8 sec hesitation
    -- ============================================
    english = function()
        local correctWords = {"Argument", "Enough", "Until", "Amateur", "Library", "Embarrassing", "Tongue", "Dessert", "February", "Accommodate", "a lot", "Beautiful"}

        local frame = localPlayer.PlayerGui.EnglishClass.Frame
        return {
            frame.question:GetPropertyChangedSignal("Text"):Connect(function()
                if frame.question.Text == "Please wait..." then return end
                humanWait(1.5, 4)
                for _, name in {"A", "B", "C", "D"} do
                    local answer = frame[name].Answer.Value
                    if table.find(correctWords, answer) then
                        humanWait(0.3, 0.8)
                        classRemotes.English:FireServer(answer)
                        break
                    end
                end
            end)
        }
    end,

    -- ============================================
    -- BAKING CLASS - ADDED HUMAN DELAYS
    -- OLD: Instant actions, no delays
    -- NEW: 0.8-1.5 sec between selections, random action delays
    -- ============================================
    baking = function()
        local flavorFrame = localPlayer.PlayerGui.Baking.FlavorSelect
        local linerFrame = localPlayer.PlayerGui.Baking.LinerSelect
        local icingFrame = localPlayer.PlayerGui.Baking.IcingSelect
        local addedIndex = 0

        fireBackData = {
            {services.ReplicatedStorage.Cooking.Butter, 1},
            {services.ReplicatedStorage.Cooking.Sugar, 15},
            {services.ReplicatedStorage.Cooking.Mixer, 1, 300},
            {services.ReplicatedStorage.Cooking.Flour, 15},
            {services.ReplicatedStorage.Cooking.Milk, 1}
        }

        function getFireBackConns()
            local connections = {}
            for _,data in next, fireBackData do
                table.insert(connections, fireBack(data[1], data[2], data[3]))
            end
            return connections
        end

        function getFrameConns()
            local connections = {}
            for i,frame in next, {flavorFrame, linerFrame, icingFrame} do
                table.insert(connections, frame:GetPropertyChangedSignal("Visible"):Connect(function()
                    if frame.Visible then
                        humanWait(0.8, 1.5)
                        getconnections(frame:FindFirstChildOfClass("TextButton").MouseButton1Click)[1]:Fire()
                        actionDelay()

                        if i == 3 then
                            humanWait(1, 2)
                            services.ReplicatedStorage.Cooking.Toppings:FireServer("Done", "")
                            humanWait(0.5, 1)
                            localPlayer.PlayerGui.Baking.Enabled = false
                        end
                    end
                end))
            end
            return connections
        end

        function getAllConns()
            local t1 = getFireBackConns()
            local t2 = getFrameConns()
            for _,connection in next, t2 do
                table.insert(t1, connection)
            end
            return t1
        end

        return {
            classRemotes.BookCheck.OnClientEvent:Connect(function()
                humanWait(0.5, 1.5)
                fireclickdetector(workspace.BakingCounters.CounterStuff.ClaimButton.ClickDetector, 5)
            end),

            services.ReplicatedStorage.Cooking.Egg.OnClientEvent:Connect(function(p1)
                if not p1 then return end
                humanWait(0.5, 1)
                fireclickdetector(workspace.BakingCounters.CounterStuff.BakingCupcakesIngredients.egg.ClickDetector, 3)
                task.wait(math.random(3, 4.5))
                fireclickdetector(workspace.BakingCounters.CounterStuff.BakingCupcakesIngredients.egg.ClickDetector, 3)
            end),

            localPlayer.Character.ChildAdded:Connect(function(child)
                if child.Name == "Cupcake Pan" then
                    actionDelay()
                    if addedIndex == 0 then
                        localPlayer.Character.Humanoid:MoveTo(workspace.BakingCounters.CounterStuff.Oven.Door.Position)
                    else
                        localPlayer.Character.Humanoid:MoveTo(workspace.BakingCounters.CounterStuff.Place.Position)
                    end
                    addedIndex += 1
                end
            end),

            unpack(getAllConns())
        }
    end
}

-- ============================================
-- CHANGED: Added human reaction before class starts
-- OLD: Instant response to class starting
-- NEW: 0.3-0.8 second delay
-- ============================================
classRemotes.Starting.OnClientEvent:Connect(function(class)
    humanWait(0.3, 0.8)
    local class = string.lower(string.gsub(class, " class", ""))
    if not classFuncs[class] then return end
    game:GetService("ReplicatedStorage").Classes.Starting:FireServer()

    local newConnections = classFuncs[class]() or {}

    for _,connection in next, prevConnections do
        connection:Disconnect()
    end; prevConnections = {}

    for _,connection in next, newConnections do
        table.insert(prevConnections, connection)
    end
end)

-- ============================================
-- HOMEWORK - ADDED HUMAN PACING
-- OLD: 0.5 seconds between homework completions
-- NEW: 4-8 seconds per assignment (normal human speed)
-- ============================================
localPlayer.ChildAdded:Connect(function(child)
    if child.Name == "Homework" then
        humanWait(1, 3)
        repeat task.wait() until child:FindFirstChildOfClass("BoolValue")
        for i,homework in next, child:GetChildren() do
            humanWait(4, 8)
            homework.Complete:FireServer()
            humanWait(0.8, 1.5)
            fireclickdetector(workspace:WaitForChild("Homeworkbox_" .. homework.Name, 10).Click.ClickDetector, 3)
            if i == 3 then
                humanWait(5, 8)
                local placeId = game.PlaceId
                repeat
                    humanWait(1, 2)
                    services.ReplicatedStorage.SceptorTeleport:FireServer("BeachHouse")
                    task.wait(math.random(4, 7))
                until game.PlaceId ~= placeId
            end
        end
    end
end)

-- ============================================
-- TIME-BASED TELEPORT - ADDED RANDOM DELAYS
-- OLD: Perfect 5-second intervals
-- NEW: Random delays (4-8 seconds), random retry counts (3-5)
-- ============================================
local time = localPlayer.PlayerGui.SchoolHUD.MainFrame.Time.Time
time:GetPropertyChangedSignal("Value"):Connect(function()
    if time.Value >= 15 and time.Value <= 23 then
        humanWait(2, 5)
        local placeId = game.PlaceId
        for i = 1, math.random(3, 5) do
            if game.PlaceId == placeId then
                humanWait(1, 3)
                services.ReplicatedStorage.SceptorTeleport:FireServer("BeachHouse")
                task.wait(math.random(4, 8))
            end
        end
    end
end)

local function getLocker()
    local closestMag = math.huge; local closetLocker;
    for _,door in next, workspace:GetDescendants() do
        if door:IsA("MeshPart") and door.Name == "LockerDoor" then
            local mag = (door.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            if mag < closestMag then closestMag = mag; closetLocker = door end
        end
    end
    return closetLocker
end

-- ============================================
-- LOCKER - ADDED RANDOM CODE + HUMAN DELAYS
-- OLD: Hardcoded "0000" code, no delays
-- NEW: Random 4-digit code, human delays between actions
-- ============================================
local function getBooks()
    humanWait(2, 5)
    repeat task.wait() until #localPlayer.Locker:GetChildren() == 5
    humanWait(3, 6)
    
    local locker = getLocker()
    humanWait(0.5, 1.5)
    fireclickdetector(locker.ClickDetector)
    humanWait(0.5, 1)
    
    local lockerCode = generateLockerCode()
    services.ReplicatedStorage.Lockers.Code:FireServer(locker, lockerCode, "Create")
    
    humanWait(1, 2)

    for _,book in next, localPlayer.Locker:GetChildren() do
        humanWait(0.8, 1.5)
        services.ReplicatedStorage.Lockers.Contents:InvokeServer("Take", book)
    end

    humanWait(1, 2)
    localPlayer.PlayerGui.Locker.Enabled = false
end

getBooks()
