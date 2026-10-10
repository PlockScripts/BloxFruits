local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local TeleportQuests = require(script.TeleportQuests)
local GatewayController = require(game.StarterGui.Main.Gateway.GatewayController)
local CompassTracker = require(script.CompassTracker)
local NPCManager = require(game.ReplicatedStorage.NPCManager)
local SideCompass = require(script.SideCompass)
local GuideData = require(script.GuideData)
local GuideCallbacks = require(script.GuideCallbacks)
local Graphics = require(game.ReplicatedStorage.Util.Graphics)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local Map2 = require(game.ReplicatedStorage.Controllers.UI.Map)
local CONSTANTS = require(game.ReplicatedStorage.React.Components.Map.CONSTANTS)
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local guide = script:WaitForChild("Guide")
local _instance = SideCompass._instance
local locations = Workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations")
local children = locations:GetChildren()
local guideIcon = guide.LeftFrame.IconFrame.GuideIcon
local v = 0
local absolutePosition = guideIcon.AbsolutePosition

local function updateMenuHidden(menuHidden: number)
	local v2 = menuHidden > 0
	SideCompass.setMenuHidden(v2)
	GuideData.setMenuHidden(v2)
	CompassTracker.setMenuHidden(v2)
end

local function screenToWorldSpace(absolutePosition2: Vector2, value: number)
	local viewportSize = currentCamera.ViewportSize
	local fieldOfView = currentCamera.FieldOfView
	local v2 = value or 0.1
	local v3 = absolutePosition2 or Vector2.new()
	local Y = viewportSize.Y
	local X = viewportSize.X
	local v4 = X / Y
	local v5 = math.tan(math.rad(fieldOfView) * 0.5)
	local v6 = 2 * v2 * (v3.X / (X - 1)) - v2
	local v7 = 2 * v2 * (v3.Y / (Y - 1)) - v2
	local v8 = v4 * v5 * v6
	local v9 = -v5 * v7
	local v10 = -v2
	return currentCamera.CFrame * CFrame.new((Vector3.new(v8, v9, v10)))
end

local function getNearestLocation(vector2: Vector3)
	local v2 = nil
	local v3 = children

	if #v3 > 0 then
		for _, part in pairs(v3) do
			if part:GetAttribute("IgnoreInTracking") or not part:IsA("BasePart") or not (not v2 or (part.Position - vector2).Magnitude < (v2.Position - vector2).Magnitude) then
				continue
			end

			v2 = part
		end
	end

	return v2
end

local function setupModel(p)
	local proxy_Shirt = p.Model:FindFirstChild("Proxy_Shirt")

	if proxy_Shirt and proxy_Shirt:IsA("StringValue") and p.Model:FindFirstChildWhichIsA("Shirt") then
		local shirt = p.Model:FindFirstChildWhichIsA("Shirt")
		shirt.ShirtTemplate = Graphics.SmartScale((proxy_Shirt:GetAttribute("ShirtTemplate")))
		shirt.Color3 = proxy_Shirt:GetAttribute("Color3")
	end

	local proxy_Pants = p.Model:FindFirstChild("Proxy_Pants")

	if proxy_Pants and proxy_Pants:IsA("StringValue") and p.Model:FindFirstChildWhichIsA("Pants") then
		local pants = p.Model:FindFirstChildWhichIsA("Pants")
		pants.PantsTemplate = Graphics.SmartScale((proxy_Pants:GetAttribute("PantsTemplate")))
		pants.Color3 = proxy_Pants:GetAttribute("Color3")
	end

	local faceId = p.Model:GetAttribute("FaceId")

	if faceId and p.Model:FindFirstChild("Head") and p.Model.Head:FindFirstChild("face") then
		p.Model.Head.face.Texture = Graphics.SmartScale(faceId)
	end

	for _, child in pairs(p.Model:GetChildren()) do
		if not (child:IsA("Accessory") or child:IsA("Hat")) then
			continue
		end

		for _, descendant in pairs(child:GetDescendants()) do
			if descendant.Name ~= "Proxy_SpecialMesh" then
				continue
			end

			local specialMesh = descendant.Parent:FindFirstChildWhichIsA("SpecialMesh")

			for _, attributeName in pairs({
				"MeshId",
				"MeshType",
				"Offset",
				"Scale",
				"TextureId",
				"VertexColor"
			}) do
				local attribute = descendant:GetAttribute(attributeName)

				if attributeName == "TextureId" then
					attribute = Graphics.SmartScale(attribute)
				end

				specialMesh[attributeName] = attribute
			end
		end
	end
end

local function fn(p, p2)
	return p2 < p
end

local GuideModule = {
	UI = guide,
	SideCompass = SideCompass._instance,
	IconFrame = guide.LeftFrame.IconFrame,
	Viewport = guide.LeftFrame.IconFrame.ViewportFrame,
	AbandonButton = guide.LeftFrame.Abandon,
	TrackButton = guide.LeftFrame.Track,
	Data = {
		NPCList = {},
		Ready = false,
		Tracking = false,
		QuestData = nil,
		DisplayedNPC = nil,
		CompassLoop = nil,
		CompassTarget = nil,
		CompassTargetNpcName = nil,
		CompassTargetInitialized = false,
		LastClosestNPC = nil,
		LastMeters = 0
	},
	Properties = {
		LocationDefaults = {
			GuideColors = {
				guide.LeftFrame.IconFrame.UIStroke.UIGradient,
				"Color",
				ColorSequence.new(Color3.fromRGB(255, 197, 20))
			},
			GuideIconID = { guide.LeftFrame.IconFrame.GuideIcon, "Image", 7252565452 }
		},
		unknownLocationImage = "49009723",
		defaultCompassIcon = "8934096355"
	},
	NotifyTween = TweenService:Create(
		_instance.Frame.Alert,
		TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
		{
			ImageTransparency = 0
		}
	),
	SetDataReady = function(p, ready: boolean)
		assert(ready ~= nil)
		assert(typeof(ready) == "boolean")
		p.Data.Ready = ready
	end
}

function GuideModule.ToggleCompassShown(p, _: boolean)
	SideCompass.setButtonVisible(true)
	p.IconFrame.GuideIcon.Visible = false
	p.IconFrame.Background.Visible = false
	p.IconFrame.GuideIcon.Image = "rbxassetid://" .. GuideModule.Properties.defaultCompassIcon
end

function GuideModule.ResetCompass(p)
	p.IconFrame.GuideIcon.Rotation = 0
	p.IconFrame.GuideIcon.ImageColor3 = Color3.new(1, 1, 1)
	SideCompass.setRotation(0)
	SideCompass.setImageColor(Color3.new(1, 1, 1))
	CompassTracker.stopTracking()
end

function GuideModule.ParentUI(p, parent)
	p.UI.Parent = parent
	SideCompass._instance.Parent = parent
end

function GuideModule.AppendNPCData(p, p2, p3)
	p.Data.NPCList[p2] = p3
end

function GuideModule.GetNearestNPC(p, vector2: Vector3, p2: number)
	local frozenHeart = workspace.Map:FindFirstChild("FrozenHeart")

	if frozenHeart then
		if not frozenHeart.PrimaryPart then
			warn("the frozen heart is not streamed...")
		end

		if (vector2 - frozenHeart.PrimaryPart.Position).Magnitude < 1000 and frozenHeart:FindFirstChild(game.Players.LocalPlayer.Name) then
			if p.Data.LastClosestNPC ~= "Frozen Heart" then
				_instance.Notify.Visible = true
				Notification.new("<Color=Purple>NEW QUEST AVAILABLE!<Color=/>", 10):Display()
				Notification.new("<Color=Purple>Open your compass menu to obtain the <Leviathan Heart>.<Color=/>", 10):Display()
				p.Data.LastClosestNPC = "Frozen Heart"
			end

			if frozenHeart:FindFirstChild("Inside") and frozenHeart.Inside:GetAttribute("Harpooned") then
				if not workspace.Map.TikiOutpost:FindFirstChild("HeartDropoff") then
					warn("critical: there's no heartdropoff!")
				end

				return {
					workspace.Map.TikiOutpost.HeartDropoff.HeartDropoff.Position,
					"Frozen Heart",
					false,
					false,
					2
				}
			else
				return {
					workspace.Map.FrozenHeart.PrimaryPart.Position,
					"Frozen Heart",
					false,
					false,
					1
				}
			end
		end
	end

	for _, guideCallback in pairs(GuideCallbacks) do
		local v2 = guideCallback(vector2, p2, getNearestLocation)

		if v2 then
			return v2
		end
	end

	local lastQuestLevel = 0
	local levels = {}
	local position = nil
	local nPCName = nil
	local v3 = nil
	local v4 = nil

	for _, v5 in pairs(p.Data.NPCList) do
		for _, level in pairs(v5.Levels) do
			if lastQuestLevel < level and level <= p2 then
				lastQuestLevel = level
				levels = {}
			end

			if lastQuestLevel == level then
				table.insert(levels, level)
			end
		end
	end

	table.sort(levels, fn)
	local v5 = levels[1]

	for k, v6 in pairs(p.Data.NPCList) do
		for _, level in pairs(v6.Levels) do
			if not (level == v5 and (not position or (v6.Position - vector2).Magnitude < (position - vector2).Magnitude)) then
				continue
			end

			position = v6.Position
			nPCName = v6.NPCName
			v4 = k
		end
	end

	if position then
		v3 = getNearestLocation(position)

		if v3 and v3:FindFirstChild("Mesh").Scale.X / 2 < (v3.Position - position).Magnitude then
			v3 = nil
		end
	end

	if p.Data.LastClosestNPC == nil then
		p.Data.LastClosestNPC = nPCName
	end

	if p.Data.LastQuestLevel == nil then
		p.Data.LastQuestLevel = lastQuestLevel
	end

	if nPCName ~= p.Data.LastClosestNPC or p.Data.LastQuestLevel ~= lastQuestLevel then
		p.Data.LastClosestNPC = nPCName

		if p.Data.LastQuestLevel ~= lastQuestLevel then
			_instance.Notify.Visible = true

			if v < tick() then
				v = tick() + 5
				Notification.new("<Color=Purple>NEW QUEST AVAILABLE!<Color=/>", 10):Display()
				Notification.new("<Color=Purple>Open your compass menu to find the next island.<Color=/>", 10):Display()
			end

			p.Data.LastQuestLevel = lastQuestLevel
		end
	end

	return {
		position,
		nPCName or "Unknown NPC",
		v3,
		v4
	}
end

function GuideModule.ChangeDisplayedNPC(data, image)
	if image then
		if typeof(image) == "string" then
			if data.Data.DisplayedNPC ~= nil then
				data.Data.DisplayedNPC:Destroy()
			end

			data.IconFrame.PlayerImage.Image = image
		else
			data.IconFrame.PlayerImage.Image = ""

			if data.Data.DisplayedNPC ~= nil then
				data.Data.DisplayedNPC:Destroy()
			end

			local parent = image.Parent

			if parent ~= nil then
				if parent.PrimaryPart then
					local clone = parent:Clone()
					local Y = clone:WaitForChild("HumanoidRootPart").Orientation.Y
					local v2 = CFrame.Angles(0, Y + -math.sign(Y) * math.abs(Y), 0) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					) * (CFrame.new(0.5, -1, -0.5) * CFrame.Angles(0, -0.4363323129985824, 0))
					clone:SetPrimaryPartCFrame(CFrame.new(
						74.8819351,
						2.40001965,
						9.47781467,
						8.74227766e-8,
						0,
						-1,
						0,
						1,
						0,
						1,
						0,
						8.74227766e-8
					) * v2)
					clone.Parent = data.Viewport
					data.Data.DisplayedNPC = clone
					setupModel({
						Model = clone
					})
				else
					local Global = require(game.ReplicatedStorage.Global)
					Global.TestGameWarn("The npc model has no primarypart", parent, parent:GetFullName())
				end
			end
		end
	else
		data.IconFrame.PlayerImage.Image = ""

		if data.Data.DisplayedNPC then
			data.Data.DisplayedNPC:Destroy()
			data.Data.DisplayedNPC = nil
		end
	end
end

function GuideModule:GetDistance(vector2: Vector3?)
	if not vector2 then
		return vector2
	end

	local magnitude = (vector2 - currentCamera.CFrame.Position).Magnitude

	for _, teleportQuest in pairs(TeleportQuests) do
		local magnitude2 = (currentCamera.CFrame.Position - teleportQuest[1]).Magnitude
		local magnitude3 = (currentCamera.CFrame.Position - teleportQuest[2]).Magnitude
		local magnitude4 = (vector2 - teleportQuest[1]).Magnitude
		local magnitude5 = (vector2 - teleportQuest[2]).Magnitude

		if magnitude4 < magnitude and magnitude3 < magnitude then
			return teleportQuest[2]
		end

		if magnitude5 < magnitude and magnitude2 < magnitude then
			return teleportQuest[1]
		end
	end

	return vector2
end

function GuideModule:PointCompass(vector2: Vector3?, compassTargetNpcName: string?)
	local data = self.Data
	local distance

	if vector2 then
		distance = self:GetDistance(vector2)
	end

	local compassTarget = data.CompassTarget
	local v2

	if distance == nil then
		v2 = compassTarget ~= nil
	else
		v2 = compassTarget == nil or not distance:FuzzyEq(compassTarget)
	end

	local v3 = compassTargetNpcName ~= data.CompassTargetNpcName
	data.CompassTarget = distance
	data.CompassTargetNpcName = compassTargetNpcName

	if data.CompassTargetInitialized and not v2 and not v3 and (distance == nil or data.CompassLoop ~= nil) then
		return
	end

	if not (distance and CompassTracker.TrackedPosition and distance:FuzzyEq(CompassTracker.TrackedPosition) and compassTargetNpcName) then
		CompassTracker.stopTracking()
	end

	data.CompassTargetInitialized = true

	if v2 and data.Billboard then
		data.Billboard:Destroy()
		data.Billboard = nil
	end

	if distance then
		if data.CompassLoop then
			return
		end

		local v4 = 0
		local v5 = nil
		local v6 = nil
		local lastTime = nil
		data.CompassLoop = RunService.Heartbeat:Connect(function(dt)
			v4 += dt

			if v4 < 0.03333333333333333 then
				return
			end

			v4 %= 0.03333333333333333

			if Workspace.CurrentCamera then
				local compassTarget2 = data.CompassTarget

				if compassTarget2 == nil then
					print("no compass target")
					return
				end

				local magnitude = (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude
				local cframe = screenToWorldSpace(absolutePosition, 1) * CFrame.new(0, 0, -magnitude)
				local vectorToObjectSpace = cframe:VectorToObjectSpace((CFrame.lookAt(cframe.Position, compassTarget2).LookVector * createVector(
					1,
					0,
					1
				)).Unit)
				local rotation = math.round(math.deg((math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z))) * 100) / 100
				local v8 = math.clamp(1 - (math.abs(rotation) - 5) / 15, 0, 1)
				local lerped = Color3.new(1, 0, 0):Lerp(Color3.new(0, 1, 0), v8)

				if rotation ~= v5 then
					v5 = rotation
					guideIcon.Rotation = rotation
				end

				if lerped ~= v6 then
					v6 = lerped
					guideIcon.ImageColor3 = lerped
				end

				if not data.Tracking then
					return
				end

				if not CompassTracker.isTrackingDefault() then
					CompassTracker.trackPosition(compassTarget2)
					local compassTargetNpcName2 = data.CompassTargetNpcName

					if compassTargetNpcName2 then
						for _, v9 in NPCManager.getNPCsByName(compassTargetNpcName2) do
							local model = v9:getModel()

							if not model then
								continue
							end

							v9:setCullingState(false)
							local animator = v9:getAnimator()
							CompassTracker.setModelPreview(
								model,
								animator and animator:GetPlayingAnimationTracks() or {}
							)
						end
					end

					print("current target", compassTarget2)
					print("current data", data)
					local nearestLocation = getNearestLocation(compassTarget2)
					local imageLabel = CompassTracker.getImageLabel()
					local currentMap = Map.findCurrentMap()
					local v9

					if currentMap then
						v9 = Map.findClosestIsland(currentMap, compassTarget2)
					end

					if v9 and Map2.IsInitialized and Map2:GetNavigationTarget() == v9 then
						if lastTime == nil then
							lastTime = tick()
						end
					elseif lastTime and tick() - lastTime > CONSTANTS.COMPASS_BILLBOARD_IMAGE.HIDE_UNTIL then
						lastTime = nil
					end

					if nearestLocation and imageLabel then
						imageLabel:AddTag(CONSTANTS.COMPASS_BILLBOARD_IMAGE.TAG)
						GatewayController.setIcon(imageLabel, v9 or nearestLocation.Name, true)

						if lastTime and tick() - lastTime < CONSTANTS.COMPASS_BILLBOARD_IMAGE.HIDE_UNTIL then
							imageLabel.Visible = false
							task.wait(CONSTANTS.COMPASS_BILLBOARD_IMAGE.HIDE_UNTIL - (tick() - lastTime))
							imageLabel.Visible = true
						end
					elseif imageLabel then
						imageLabel:RemoveTag(CONSTANTS.COMPASS_BILLBOARD_IMAGE.TAG)
					end
				end
			else
				data.CompassLoop:Disconnect()
				data.CompassLoop = nil

				if data.Billboard then
					data.Billboard:Destroy()
					data.Billboard = nil
				end
			end
		end)
	else
		if data.CompassLoop then
			data.CompassLoop:Disconnect()
			data.CompassLoop = nil
		end

		if data.Billboard then
			data.Billboard:Destroy()
			data.Billboard = nil
		end

		local color = Color3.new(0, 1, 0)

		if guideIcon.Rotation ~= 0 then
			guideIcon.Rotation = 0
		end

		if guideIcon.ImageColor3 ~= color then
			guideIcon.ImageColor3 = color
		end

		SideCompass.setImageColor(color)
		SideCompass.setRotation(0)
	end
end

if not RunService:IsRunning() then
	return GuideModule
end

local Global = require(game.ReplicatedStorage.Global)

if Global.IsSandboxed ~= false then
	return GuideModule
end

guideIcon:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
	absolutePosition = guideIcon.AbsolutePosition
end)
GuideData.HandleUpdate("CanUnlockCompass", function(flag: boolean)
	if flag then
		CompassTracker.createTracker("Boaty", {
			Target = function()
				if not localPlayer.Character then
					return createVector(0, 0, 0)
				end

				local closestNPC = NPCManager.getClosestNPC(localPlayer.Character:GetPivot().Position, "Boat Dealer")

				if not closestNPC then
					return createVector(0, 0, 0)
				end

				local model = closestNPC:getModel()

				if model then
					return model:GetPivot().Position + Vector3.new(0, model:GetModelSize().Y / 1.25, 0)
				end

				return createVector(0, 0, 0)
			end,
			AlertIconSettings = {
				MaxDistance = 1000
			},
			IconSettings = {
				ShowIsland = false
			},
			ViewportSettings = {
				Model = nil,
				UseIconAsBackground = false
			},
			ShowOffScreenAlert = true
		})
	else
		CompassTracker.removeTracker("Boaty")
	end
end)
_instance.Notify:GetPropertyChangedSignal("Visible"):Connect(function()
	if _instance.Notify.Visible then
		if GuideModule.NotifyTween then
			GuideModule.NotifyTween:Play()
			_instance.Frame.Alert.Visible = true
		end
	elseif GuideModule.NotifyTween then
		GuideModule.NotifyTween:Pause()
		_instance.Frame.Alert.Visible = false
	end
end)
_instance.Frame.Alert.Visible = false
updateMenuHidden(AttributeCounter.get(localPlayer, "MenuHidden")) -- equivalent call inferred; original call site unknown
AttributeCounter.connect(localPlayer, "MenuHidden", updateMenuHidden)
locations.ChildAdded:Connect(function()
	children = locations:GetChildren()
end)
locations.ChildRemoved:Connect(function()
	children = locations:GetChildren()
end)
local CollectionService = game:GetService("CollectionService")
CollectionService:GetInstanceAddedSignal("ObjectiveReplicatorTracker"):Connect(function(instance)
	local value = instance.Value

	if not (value and value:IsA("BasePart")) then
		return
	end

	local text = instance and instance:GetAttribute("Text")
	local thread = coroutine.running()
	local clone = script.TrackerPart.BBG:Clone()
	clone.Parent = value
	instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			clone:Destroy()
			pcall(task.cancel, thread)
		end
	end)
	clone.Adornee = value
	local textLabel = clone:FindFirstChildWhichIsA("TextLabel")

	if not textLabel then
		return
	end

	while clone.Parent do
		task.wait(0.1)
		textLabel.Text = `{text or ""} ({math.floor(math.floor((currentCamera.CFrame.Position - value.Position).Magnitude) / 10)}m) `
	end
end)
task.spawn(function()
	local getBestQuestNPC = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetBestQuestNPC")

	getBestQuestNPC.OnClientInvoke = function(p: number, vector2: Vector3)
		local v2 = 0
		local levels = {}
		local position = nil
		local model = nil
		local nPCName = nil

		for _, v3 in pairs(GuideModule.Data.NPCList) do
			for _, level in pairs(v3.Levels) do
				if v2 < level and level <= p then
					v2 = level
					levels = {}
				end

				if v2 == level then
					table.insert(levels, level)
				end
			end
		end

		table.sort(levels, fn)
		local v3 = levels[1]

		for k, v4 in pairs(GuideModule.Data.NPCList) do
			for _, level in pairs(v4.Levels) do
				if not (level == v3 and (not position or (v4.Position - vector2).Magnitude < (position - vector2).Magnitude)) then
					continue
				end

				position = v4.Position
				nPCName = v4.NPCName
				model = k:FindFirstAncestorOfClass("Model")
			end
		end

		return model, nPCName
	end
end)
return GuideModule
