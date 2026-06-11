local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SERVER_URL = "http://localhost:5000/solve"

repeat task.wait() until game:IsLoaded()

local LP = Players.LocalPlayer
while not LP do task.wait(); LP = Players.LocalPlayer end

local playerGui = LP:FindFirstChild("PlayerGui")
while not playerGui do task.wait(); playerGui = LP:FindFirstChild("PlayerGui") end

local captchaGui = playerGui:FindFirstChild("CardCaptchaGame")
while not captchaGui do task.wait(); captchaGui = playerGui:FindFirstChild("CardCaptchaGame") end

local function solve()
    local captcha = captchaGui:FindFirstChild("CaptchaGame")
    if not captcha then return end
    
    local topCard = captcha:FindFirstChild("Top") and captcha.Top:FindFirstChild("Card")
    if not topCard then return end
    
    local url = topCard.Image
    local assetId = string.match(url, "id=(%d+)")
    if not assetId then
        warn("No asset ID found")
        return
    end
    
    print("Solving captcha for ID:", assetId)
    
    local success, response = pcall(function()
        return game:HttpGet(SERVER_URL .. "?id=" .. assetId, 5)
    end)
    
    if not success then
        warn("HTTP request failed:", response)
        return
    end
    
    local data = HttpService:JSONDecode(response)
    if data and data.success and data.index then
        print("Match found! Firing button", data.index)
        
        local remote = ReplicatedStorage:FindFirstChild("CaptchaRemote")
        if remote then
            local setup = remote:FindFirstChild("CaptchaAttempt")
            if setup then
                setup:FireServer(data.index)
            else
                warn("CaptchaAttempt not found")
            end
        else
            warn("CaptchaRemote not found")
        end
    else
        warn("Server error:", data and data.error or "Unknown")
    end
end

captchaGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if captchaGui.Enabled then
        task.wait(math.random(5, 15))
        pcall(solve)
    end
end)

if captchaGui.Enabled then
    task.spawn(function()
        task.wait(math.random(5, 15))
        pcall(solve)
    end)
end
