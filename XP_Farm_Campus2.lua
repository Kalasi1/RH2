repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
if #Players:GetPlayers() > 1 then game:Shutdown() end
Players.PlayerAdded:Connect(function() game:Shutdown() end)

game:GetService("RunService"):Set3dRenderingEnabled(false)

local LP = Players.LocalPlayer
for _,v in next, getconnections(LP.Idled) do v:Disable() end
local _ = LP.Character or LP.CharacterAdded:Wait()

coroutine.resume(coroutine.create(loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixterity/RH/main/CatpchaSolver.lua"))))

local scripts = {
    ["735030788"] = game:HttpGet("https://raw.githubusercontent.com/Lixterity/RH/main/BeachHouseTP.lua"),
    ["4728136927"] = game:HttpGet("https://raw.githubusercontent.com/Lixterity/RH/main/BeachHouse.lua"),
    ["1765700510"] = game:HttpGet("https://raw.githubusercontent.com/Lixterity/RH/main/School.lua")
}; coroutine.resume(coroutine.create(loadstring(scripts[tostring(game.PlaceId)])))
