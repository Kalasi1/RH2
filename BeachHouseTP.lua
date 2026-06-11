local placeId = game.PlaceId
repeat
    game:GetService("ReplicatedStorage").SceptorTeleport:FireServer("BeachHouse")
    task.wait(5)
until game.PlaceId ~= placeId
