if game.PlaceId ~= 4924922222 then
    print("LOL")
    return
end

local UI = loadstring(game:HttpGet("https://pastefy.app/CuzJa3ui/raw"))()

local Window = UI.MakeWindow(UI, {
    Title = "REDz HUB [ Troll ] : " .. UI.info.PlaceName,
    SubTitle = "by : redz9999",
    LoadText = "redz Hub Troll Version",
    Flags = "redz Hub.lua",
})

UI.SetTransparency(UI, 0)

Window:AddMinimizeButton({
    Button = { Image = "rbxassetid://15298567397" },
    UICorner = { CornerRadius = UDim.new(0.5, 0), true },
    UIStroke = { false },
})

local WorkspaceCom      = workspace:WaitForChild("WorkspaceCom")
local Vehicles          = workspace:WaitForChild("Vehicles")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local GiveToolsFolder   = WorkspaceCom:WaitForChild("001_GiveTools")
local RE                = ReplicatedStorage:WaitForChild("RE")

local function FireRemote(name, ...)
    local remote = RE:FindFirstChild(name)
    if not remote then return end
    if remote:IsA("RemoteEvent") then
        remote:FireServer(...)
    elseif remote:IsA("RemoteFunction") then
        remote:InvokeServer(...)
    end
end

local function GetOtherPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function GetNearestPlayer()
    local nearestDist = math.huge
    local nearestPlayer = nil
    local localRoot = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local root = player.Character and player.Character.PrimaryPart
            if root and localRoot then
                local dist = (root.Position - localRoot.Position).Magnitude
                if dist <= nearestDist then
                    nearestDist = dist
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

local function ParseNumberList(str)
    local cleaned = tostring(str):gsub(" ", "")
    local result = {}
    for _, v in ipairs(cleaned:split(",")) do
        table.insert(result, tonumber(v))
    end
    return result
end

local function GetAccessoryIds(playerName)
    local player = Players:FindFirstChild(playerName)
    if not player or not player.Character then return {} end
    local desc = player.Character.Humanoid.HumanoidDescription
    local ids = {}
    local fields = {
        "FaceAccessory", "BackAccessory", "FrontAccessory", "HairAccessory",
        "HatAccessory", "NeckAccessory", "ShouldersAccessory", "WaistAccessory",
    }
    for _, field in ipairs(fields) do
        for _, id in ipairs(ParseNumberList(desc[field])) do
            table.insert(ids, id)
        end
    end
    return ids
end

local isCopyingAvatar = false

local function CopyAvatar(targetName)
    if not targetName then return end
    if isCopyingAvatar then
        UI:MakeNotify({ "Wait", "Anti kick < Wait >" })
        return
    end
    isCopyingAvatar = true

    local target = Players:FindFirstChild(targetName)
    local targetChar = target and target.Character
    if not targetChar then
        isCopyingAvatar = false
        return
    end

    local targetDesc = targetChar.Humanoid.HumanoidDescription
    local myChar = LocalPlayer.Character
    local myDesc = myChar.Humanoid.HumanoidDescription

    for _, id in ipairs(GetAccessoryIds(LocalPlayer.Name)) do
        task.wait(0.3)
        FireRemote("1Updat1eAvata1r", "wear", id)
    end

    task.wait(0.5)

    for _, id in ipairs(GetAccessoryIds(targetName)) do
        task.wait(0.3)
        FireRemote("1Updat1eAvata1r", "wear", id)
    end

    if tonumber(myDesc.Face) ~= tonumber(targetDesc.Face) then
        FireRemote("1Updat1eAvata1r", "wear", tonumber(targetDesc.Face))
        task.wait(0.3)
    end

    FireRemote("1Clothe1s", "outfit", tonumber(targetDesc.Shirt), tonumber(targetDesc.Pants))
    task.wait(0.3)

    FireRemote("1Avata1rOrigina1l", "CharacterChange", {
        tonumber(targetDesc.Torso), tonumber(targetDesc.RightArm), tonumber(targetDesc.LeftArm),
        tonumber(targetDesc.RightLeg), tonumber(targetDesc.LeftLeg), tonumber(targetDesc.Head),
    }, "by : redz9999")
    task.wait(0.3)

    local attempts = 0
    while myChar.Head.NameGUI.TextBox.Text ~= targetChar.Head.NameGUI.TextBox.Text and attempts < 5 do
        FireRemote("1RPNam1eTex1t", "RolePlayName", targetChar.Head.NameGUI.TextBox.Text)
        task.wait(0.3)
        attempts += 1
    end

    attempts = 0
    while myChar.Head.NameGUI.TextBoxBio.Text ~= targetChar.Head.NameGUI.TextBoxBio.Text and attempts < 5 do
        FireRemote("1RPNam1eTex1t", "RolePlayName", targetChar.Head.NameGUI.TextBoxBio.Text)
        task.wait(0.3)
        attempts += 1
    end

    while myChar.Head.NameGUI.TextBox.TextColor3 ~= targetChar.Head.NameGUI.TextBox.TextColor3 do
        FireRemote("1RPNam1eColo1r", "PickingRPNameColor", targetChar.Head.NameGUI.TextBox.TextColor3)
        task.wait(0.3)
    end

    while myChar.Head.NameGUI.TextBoxBio.TextColor3 ~= targetChar.Head.NameGUI.TextBoxBio.TextColor3 do
        FireRemote("1RPNam1eColo1r", "PickingRPNameColor", targetChar.Head.NameGUI.TextBoxBio.TextColor3)
        task.wait(0.3)
    end

    local bodyColors = targetChar:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        FireRemote("1Updat1eAvata1r", "skintone", tostring(bodyColors.HeadColor))
        task.wait(0.3)
    end

    local anims = {
        targetDesc.WalkAnimation, targetDesc.RunAnimation, targetDesc.ClimbAnimation,
        targetDesc.FallAnimation, targetDesc.IdleAnimation, targetDesc.SwimAnimation,
        targetDesc.JumpAnimation,
    }
    for _, animId in ipairs(anims) do
        FireRemote("1Updat1eAvata1r", "wearWalkStyle", tonumber(animId))
        task.wait(0.3)
    end

    UI:MakeNotify({ "Notification", "Avatar Successfully Copied" })
    isCopyingAvatar = false
end

local function EquipToolsGrid(toolName, count, startPos, offset)
    local x, y, z = startPos[1], startPos[2], startPos[3]

    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            tool.Parent = LocalPlayer.Character
            tool.GripPos = Vector3.new(x, y, z)
            x = x + offset[1]
            y = y + offset[2]
            z = z + offset[3]
            count -= 1
            if count <= 0 then break end
        end
    end

    task.wait(0.1)
end

local function UnequipAllTools()
    for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = LocalPlayer.Backpack
        end
    end
end

local function CountTool(toolName)
    local count = 0
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == toolName then
            count += 1
        end
    end
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                count += 1
            end
        end
    end
    return count
end

local function DupeBasketball(toolName, amount)
    local char = LocalPlayer.Character
    local root = char and char.PrimaryPart
    if not root then return end

    local target = amount or getgenv().DupeAmount
    local savedCFrame = root.CFrame

    char.Humanoid.WalkSpeed = 0
    char.Humanoid.JumpPower = 0

    if toolName == "BasketBall" then
        local ball = GiveToolsFolder:WaitForChild("Basketball")
        root.CFrame = ball.CFrame

        while target > CountTool("Basketball") do
            task.wait()
            if (root.Position - ball.Position).Magnitude >= 10 then
                root.CFrame = ball.CFrame
            else
                fireclickdetector(ball.ClickDetector)
            end
        end
    end

    task.wait(1)

    char.Humanoid.WalkSpeed = 16
    char.Humanoid.JumpPower = 50
    root.CFrame = savedCFrame
end

local function ViewPlayerLoop()
    while getgenv().ViewPlayer do
        task.wait()
        local target = getgenv().SelectTrollPlayer
        target = target and Players:FindFirstChild(target)
        local hum = target and target.Character and target.Character:FindFirstChild("Humanoid")
        if hum and workspace.CurrentCamera.CameraSubject ~= hum then
            workspace.CurrentCamera.CameraSubject = hum
        end
    end

    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
end

local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "ESP < redz Hub >"

local existing = CoreGui:FindFirstChild(ESPFolder.Name)
if existing and existing ~= ESPFolder then
    existing:Destroy()
end

local function HasESP(playerName)
    for _, item in ipairs(ESPFolder:GetChildren()) do
        if item:IsA("BillboardGui") and item:GetAttribute("ESPName") == playerName then
            return true
        end
    end
    return false
end

local function RemoveESP(playerName)
    for _, item in ipairs(ESPFolder:GetChildren()) do
        if item:IsA("BillboardGui") and item:GetAttribute("ESPName") == playerName then
            item:Destroy()
        end
    end
end

local function CreateESP(target, color)
    if HasESP(target.Name) then return end

    local adornee = (target and target:IsA("Model")) and (target.PrimaryPart or target) or target

    local billboard = Instance.new("BillboardGui", ESPFolder)
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 100, 0, 150)
    billboard.StudsOffset = Vector3.new(0, 1, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, -50)
    label.Size = UDim2.new(0, 100, 0, 100)
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextSize = 10
    label.TextStrokeTransparency = 0
    label.TextYAlignment = Enum.TextYAlignment.Bottom
    label.ZIndex = 15
    label.Text = target.Name .. " < nil >"

    billboard:SetAttribute("ESPName", target.Name)
    billboard:SetAttribute("Distance", 0)

    task.spawn(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not (ESPFolder and billboard) then
                if conn then conn:Disconnect() end
                return
            end
            local myRoot = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
            if adornee and myRoot then
                local dist = math.floor((myRoot.Position - adornee.Position).Magnitude)
                billboard:SetAttribute("Distance", dist)
                label.Text = target.Name .. " < " .. tostring(dist) .. " >"
            end
        end)
    end)
end

local function PlayerESPLoop()
    while getgenv().PlayerESP do
        task.wait()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                CreateESP(player.Character, Color3.fromRGB(255, 255, 0))
            end
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESP(player.Name)
    end
end

local function VehicleESPLoop()
    while getgenv().VehicleESP do
        task.wait()
        for _, vehicle in ipairs(Vehicles:GetChildren()) do
            if vehicle.Name ~= LocalPlayer.Name .. "Car" then
                CreateESP(vehicle, Color3.fromRGB(0, 255, 0))
            end
        end
    end
    for _, vehicle in ipairs(Vehicles:GetChildren()) do
        RemoveESP(vehicle.Name)
    end
end

local function FlingPlayerLoop()
    local connection = Vehicles.ChildAdded:Connect(function(vehicle)
        if vehicle.Name == LocalPlayer.Name .. "Car" then
            task.wait(0.5)
            for _, part in ipairs(vehicle:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    local angularVelocity
    local pickCarDelay

    while getgenv().FlingPlayer do
        RunService.Heartbeat:Wait()

        local myCar = Vehicles:FindFirstChild(LocalPlayer.Name .. "Car")

        if myCar then
            local vehicleSeat = myCar:FindFirstChild("Body") and myCar.Body:FindFirstChild("VehicleSeat")
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart

            if root and not root:FindFirstChildOfClass("BodyAngularVelocity") then
                angularVelocity = Instance.new("BodyAngularVelocity", root)
                angularVelocity.P = math.huge
                angularVelocity.MaxTorque = Vector3.new(math.huge, 0, 0)
                angularVelocity.AngularVelocity = Vector3.new(50, 0, 0)
            elseif vehicleSeat and hum then
                if hum.SeatPart and hum.SeatPart ~= vehicleSeat then
                    hum.Sit = false
                else
                    local target = getgenv().SelectTrollPlayer
                    target = target and Players:FindFirstChild(target)
                    target = target and target.Character
                    target = target and target.PrimaryPart

                    if target and target.Position.Y > -150 then
                        if myCar.PrimaryPart then
                            myCar:SetPrimaryPartCFrame(target.CFrame * CFrame.new(0, math.random(-3, 3), -8))
                        end
                    elseif myCar.PrimaryPart then
                        myCar:SetPrimaryPartCFrame(CFrame.new(1133, 76, -1143))
                    end
                end
            elseif root then
                root.CFrame = vehicleSeat.CFrame
            end
        else
            local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
            if root then
                if (root.Position - Vector3.new(1133, 76, -1143)).Magnitude >= 10 then
                    root.CFrame = CFrame.new(1133, 76, -1143)
                else
                    task.wait(0.5)
                    if not pickCarDelay or tick() - pickCarDelay >= 8 then
                        FireRemote("1Ca1r", "PickingCar", "TowTruck")
                        pickCarDelay = tick()
                        task.wait(1)
                    end
                end
            end
        end
    end

    if connection then connection:Disconnect() end
    if angularVelocity then angularVelocity:Destroy() end
end

local function BringPlayer()
    local char = LocalPlayer.Character
    local root = char and char.PrimaryPart
    local hum = char and char:FindFirstChild("Humanoid")

    local target = getgenv().SelectTrollPlayer
    target = target and Players:FindFirstChild(target)

    local savedPos = root.Position

    if Vehicles:FindFirstChild(LocalPlayer.Name .. "Car") then
        FireRemote("1Ca1r", "DeleteAllVehicles")
        task.wait(0.3)
    end

    if hum and hum.Sit then
        hum.Sit = false
        task.wait(0.3)
    end

    if root then
        repeat
            task.wait()
            root.CFrame = CFrame.new(1133, 76, -1143)
        until (root.Position - Vector3.new(1133, 76, -1143)).Magnitude < 5
        task.wait(0.7)
        FireRemote("1Ca1r", "PickingCar", "SchoolBus")
    end

    local myCar = Vehicles:WaitForChild(LocalPlayer.Name .. "Car")
    local vehicleSeat = myCar and myCar:WaitForChild("Body"):WaitForChild("VehicleSeat")
    local seated = false

    while not seated and myCar and vehicleSeat do
        task.wait()
        root.CFrame = vehicleSeat.CFrame
        if hum.SeatPart == vehicleSeat then
            seated = true
        end
    end

    local targetChar = target and target.Character
    local targetRoot = targetChar and targetChar.PrimaryPart
    local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

    repeat
        RunService.Heartbeat:Wait()
        local offset = CFrame.new(math.random(-4, 4), -0.5, math.random(-4, 4) - targetRoot.Velocity.Magnitude)
        myCar:SetPrimaryPartCFrame(targetRoot.CFrame * offset)
    until not (targetHum and targetRoot) or targetHum.Sit or not myCar.PrimaryPart

    repeat
        task.wait()
        myCar:SetPrimaryPartCFrame(CFrame.new(savedPos))
    until (myCar.PrimaryPart.Position - savedPos).Magnitude < 5

    task.wait(1)
    FireRemote("1Ca1r", "DeleteAllVehicles")
end

local function KillPlayer()
    local char = LocalPlayer.Character
    local root = char and char.PrimaryPart
    local hum = char and char:FindFirstChild("Humanoid")

    local target = getgenv().SelectTrollPlayer
    target = target and Players:FindFirstChild(target)

    local savedPos = root.Position

    if Vehicles:FindFirstChild(LocalPlayer.Name .. "Car") then
        FireRemote("1Ca1r", "DeleteAllVehicles")
        task.wait(0.3)
    end

    if hum and hum.Sit then
        hum.Sit = false
        task.wait(0.3)
    end

    if root then
        repeat
            task.wait()
            root.CFrame = CFrame.new(1133, 76, -1143)
        until (root.Position - Vector3.new(1133, 76, -1143)).Magnitude < 5
        task.wait(0.7)
        FireRemote("1Ca1r", "PickingCar", "SchoolBus")
    end

    local myCar = Vehicles:WaitForChild(LocalPlayer.Name .. "Car")
    local vehicleSeat = myCar and myCar:WaitForChild("Body"):WaitForChild("VehicleSeat")
    local seated = false

    while not seated and myCar and vehicleSeat do
        task.wait()
        root.CFrame = vehicleSeat.CFrame
        if hum.SeatPart == vehicleSeat then
            seated = true
        end
    end

    local targetChar = target and target.Character
    local targetRoot = targetChar and targetChar.PrimaryPart
    local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

    repeat
        RunService.Heartbeat:Wait()
        local offset = CFrame.new(math.random(-4, 4), -0.5, math.random(-4, 4) - targetRoot.Velocity.Magnitude)
        myCar:SetPrimaryPartCFrame(targetRoot.CFrame * offset)
    until not (targetHum and targetRoot) or targetHum.Sit or not myCar.PrimaryPart

    repeat
        task.wait()
        myCar:SetPrimaryPartCFrame(CFrame.new(0, -450, 0))
    until targetRoot.Position.Y < -300

    hum.Sit = false

    repeat
        task.wait()
        root.CFrame = CFrame.new(savedPos)
    until (root.Position - savedPos).Magnitude < 5
end

local Tabs = {
    Discord = Window:MakeTab({ "Discord", "Info" }),
    Main    = Window:MakeTab({ "Main", "Home" }),
    Player  = Window:MakeTab({ "Player", "User" }),
    Tool    = Window:MakeTab({ "Tools", "Backpack" }),
    Misc    = Window:MakeTab({ "Misc", "Settings" }),
}

Tabs.Discord:AddLabel({ "Text", "This is a new version of redz hub [ beta ]" })
Tabs.Discord:AddLabel({ "Text", "This version is only available to some people" })
Tabs.Discord:AddDiscordInvite({
    "https://discord.gg/7aR7kNVt4g",
    "rbxassetid://15298567397",
    "REDz Hub | Community",
})

Tabs.Main:AddSection({ "Kill/Bring" })

local trollDropdown = Tabs.Main:AddDropdown({
    Name = "Select Player",
    Options = GetOtherPlayerNames(),
    Callback = function(value)
        getgenv().SelectTrollPlayer = value
    end,
})

Tabs.Main:AddButton({ "Kill Player", KillPlayer })
Tabs.Main:AddButton({ "Bring Player", BringPlayer })

Tabs.Main:AddToggle({
    "Fling Player",
    false,
    function(state)
        getgenv().FlingPlayer = state
        FlingPlayerLoop()
    end,
})

Tabs.Main:AddToggle({
    "View Player",
    false,
    function(state)
        getgenv().ViewPlayer = state
        ViewPlayerLoop()
    end,
})

Tabs.Main:AddSection({ "Avatar" })

local avatarDropdown = Tabs.Main:AddDropdown({
    Name = "Select Player",
    Options = GetOtherPlayerNames(),
    Callback = function(value)
        getgenv().SelectAvatarCopy = value
    end,
})

Tabs.Main:AddButton({
    "Copy Avatar < Selected Player >",
    function()
        CopyAvatar(getgenv().SelectAvatarCopy)
    end,
})

Tabs.Main:AddButton({
    "Copy Avatar < Nearest Player >",
    function()
        local nearest = GetNearestPlayer()
        if nearest then CopyAvatar(nearest.Name) end
    end,
})

Tabs.Main:AddSection({ "Spin" })

local spinSpeed = 10

Tabs.Main:AddSlider({
    Name = "Spin Speed",
    MinValue = 1,
    MaxValue = 100,
    Default = 10,
    Increase = 0.5,
    Flag = "SpinSpeed",
    Callback = function(value)
        spinSpeed = value
    end,
})

Tabs.Main:AddToggle({
    "Spin Player",
    false,
    function(state)
        getgenv().PlayerSpin = state
        task.spawn(function()
            repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character.PrimaryPart

            local spin = Instance.new("BodyAngularVelocity", LocalPlayer.Character.PrimaryPart)
            spin.P = math.huge
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.AngularVelocity = Vector3.new(0, tonumber(spinSpeed) or 10, 0)

            while getgenv().PlayerSpin do
                task.wait()
                if not spin then break end
                spin.AngularVelocity = Vector3.new(0, tonumber(spinSpeed) or 10, 0)
            end

            if spin then spin:Destroy() end
        end)
    end,
})

Tabs.Tool:AddTextBox({
    Name = "Dupe Amount",
    Default = "100",
    Callback = function(value)
        if tonumber(value) then
            getgenv().DupeAmount = tonumber(value)
        end
    end,
})

Tabs.Tool:AddSection({ "Basketball" })

Tabs.Tool:AddButton({
    "Dupe Basketball",
    function()
        DupeBasketball("BasketBall")
    end,
})

Tabs.Tool:AddButton({
    "Basketball Wall",
    function()
        DupeBasketball("BasketBall", 110)
        UnequipAllTools()
        task.wait(0.5)
        local columns = { 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5 }
        for _, x in ipairs(columns) do
            EquipToolsGrid("Basketball", 10, { x, 0, 0 }, { 0, -1, 1 })
        end
    end,
})

Tabs.Tool:AddButton({
    "Basketball Super Wall",
    function()
        DupeBasketball("BasketBall", 300)
        UnequipAllTools()
        task.wait(0.5)
        local columns = { 7, 6, 5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5, -6, -7 }
        for _, x in ipairs(columns) do
            EquipToolsGrid("Basketball", 20, { x, 0, 0 }, { 0, -1, 1 })
        end
    end,
})

Tabs.Tool:AddButton({
    "Basketball Line",
    function()
        DupeBasketball("BasketBall", 120)
        UnequipAllTools()
        task.wait(0.5)
        EquipToolsGrid("Basketball", 120, { 60, 0, 0 }, { -1, 0, 0 })
    end,
})

Tabs.Tool:AddToggle({
    "Loop Throw basketball",
    false,
    function(state)
        getgenv().LoopThrowBasketball = state
        task.spawn(function()
            while getgenv().LoopThrowBasketball do
                task.wait()
                if LocalPlayer.Character then
                    for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == "Basketball" then
                            local hit = LocalPlayer:GetMouse().Hit
                            local pos = Vector3.new(hit.X, hit.Y, hit.Z)
                            if tool:FindFirstChild("ClickEvent") then
                                tool.ClickEvent:FireServer(pos)
                            end
                        end
                    end
                end
            end
        end)
    end,
})

Tabs.Misc:AddSection({ "Scripts" })

Tabs.Misc:AddButton({
    "Fly <For Mobile>",
    function()
        loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))()
    end,
})

Tabs.Misc:AddButton({
    "Vehicle Fly",
    function()
        loadstring(game:HttpGet("https://pastebin.com/raw/MHE1cbWF"))()
    end,
})

Tabs.Misc:AddButton({
    "Chat Spy",
    function()
        loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Chat-Spy-Script-2104"))()
    end,
})

Tabs.Misc:AddButton({
    "infinite yield",
    function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
})

Tabs.Misc:AddSection({ "FPS Boost" })

Tabs.Misc:AddToggle({
    Flag = "Remove Balls",
    "Remove Balls",
    false,
    function(state)
        getgenv().RemoveBalls = state
        task.spawn(function()
            while getgenv().RemoveBalls do
                task.wait()
                for _, obj in ipairs(workspace.WorkspaceCom:GetChildren()) do
                    if obj and obj:IsA("BasePart") and obj.Name == "Handle" then
                        obj:Destroy()
                    end
                end
            end
        end)
    end,
})

Tabs.Player:AddSection({ "Avatar Size" })

Tabs.Player:AddButton({
    "Super Small Avatar",
    function()
        FireRemote("1Clothe1s", "CharacterSizeUp", math.random(2, 10))
        task.wait(0.5)
        LocalPlayer.Character.PrimaryPart.Size = Vector3.new(2.5, 2.5, 2.5)
    end,
})

Tabs.Player:AddButton({
    "Normal size",
    function()
        FireRemote("1Clothe1s", "CharacterSizeUp", 1)
    end,
})

Tabs.Player:AddSection({ "ESP" })

Tabs.Player:AddToggle({
    "ESP Players",
    false,
    function(state)
        getgenv().PlayerESP = state
        PlayerESPLoop()
    end,
})

Tabs.Player:AddToggle({
    "ESP Vehicles",
    false,
    function(state)
        getgenv().VehicleESP = state
        VehicleESPLoop()
    end,
})

local function RefreshDropdowns()
    local names = GetOtherPlayerNames()
    avatarDropdown:Set(names, true)
    trollDropdown:Set(names, true)
end

Players.PlayerAdded:Connect(RefreshDropdowns)
Players.PlayerRemoving:Connect(RefreshDropdowns)
