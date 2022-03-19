local Players = game:GetService("Players")
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

local BodyTransparency = 0.6


local CharacterModule = {}
CharacterModule.Reanimation = nil
CharacterModule.BodyTransparency = BodyTransparency


function CreateStale()
	local Stale = Instance.new("Model", workspace)

	local Torso = Instance.new("Part", Stale)
	Torso.Name = "Torso"
	Torso.CanCollide = false
	Torso.Anchored = true

	local Head = Instance.new("Part", Torso)
	Head.Name = "Head"
	Head.Anchored = true
	Head.CanCollide = false

	local Humanoid = Instance.new("Humanoid", Torso)
	Humanoid.Name = "Humanoid"


	Torso.Position = Vector3.new(0, 9999, 0)
	Head.Position = Vector3.new(0, 9991, 0)



	return Stale
end

function GetMotorForLimb(Limb)
	for _, Motor in next, Character:GetDescendants() do
		if Motor:IsA("Motor6D") and Motor.Part1 == Limb then
			return Motor
		end
	end
end

function CreateAlignment(Limb, Anchor)
	local Attachment0 = Instance.new("Attachment", Anchor)
	local Attachment1 = Instance.new("Attachment", Limb)
	local Orientation = Instance.new("AlignOrientation")
	local Position = Instance.new("AlignPosition")
	Orientation.Attachment0 = Attachment1
	Orientation.Attachment1 = Attachment0
	Orientation.RigidityEnabled = false
	Orientation.MaxTorque = 2000
	Orientation.Responsiveness = 200
	Orientation.Parent = CharacterModule.Reanimation["HumanoidRootPart"]

	Orientation.Name = Limb.Name.."'s AlignRot"
	Orientation.MaxAngularVelocity = 10000

	Position.Attachment0 = Attachment1
	Position.Attachment1 = Attachment0
	Position.RigidityEnabled = false
	Position.MaxForce = 4000
	Position.Responsiveness = 200
	Position.Parent = CharacterModule.Reanimation["HumanoidRootPart"]

	Position.Name = Limb.Name.."'s AlignPos"
	Position.MaxVelocity = 10000

	Limb.Massless = false
	local Motor = GetMotorForLimb(Limb)
	if Motor then
		Motor:Destroy()
	end
	
	return Attachment0
end

function PermaDeath()
	--local RealCharacter = Players.LocalPlayer.Character
	--local StaleCharacter = CreateStale()
	--Players.LocalPlayer.Character = StaleCharacter
	--wait(game.Players.RespawnTime/2)
	--warn("50%")
	--Players.LocalPlayer.Character = RealCharacter
	--wait(game.Players.RespawnTime/2 + 0.5)
	--warn("100%")
	
	local ch = game.Players.LocalPlayer.Character
	local prt = Instance.new("Model", workspace)
	local z1 = Instance.new("Part", prt)
	z1.Name = "Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part", prt)
	z2.Name = "Head"
	z2.Anchored = true
	z2.CanCollide = false
	local z3 = Instance.new("Humanoid", prt)
	z3.Name = "Humanoid"
	z1.Position = Vector3.new(0, 9999, 0)
	z2.Position = Vector3.new(0, 9991, 0)
	game.Players.LocalPlayer.Character = prt
	wait(game.Players.RespawnTime/2)
	warn("50%")
	game.Players.LocalPlayer.Character = ch
	wait(game.Players.RespawnTime/2 + 0.5)
	warn("100%")
end

--

function CharacterModule.CreateReanimation()
	if CharacterModule.Reanimation then
		CharacterModule.Reanimation:Destroy()
	end
	
	do
		Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		
		
		
		
		local function CreateAttachment(parent, position, orientation, axis, secondaryAxis, name)
			local newAttchment = Instance.new("Attachment", parent)
			newAttchment.Position = position
			newAttchment.Orientation = orientation
			newAttchment.Axis = axis
			newAttchment.SecondaryAxis = secondaryAxis
			newAttchment.Name = name
		end
		
		
		for i,v in pairs(Character:GetChildren()) do
			if v:IsA("LocalScript") then
				v:Destroy()
			end
		end
		
		local reanimFolder = Instance.new("Folder", Character)
		reanimFolder.Name = "FakeCharacter"

		local model = Instance.new("Model", reanimFolder)
		model.Name = "Reanimation"
		
		local cHead = Instance.new("Part", model)
		cHead.Size = Vector3.new(2, 1, 1)
		cHead.Name = "Head"

		--Torso
		local cTorso = Instance.new("Part", model)
		cTorso.Size = Vector3.new(2, 2, 1)
		cTorso.Name = "Torso"

		--Left Arm
		local cLArm = Instance.new("Part", model)
		cLArm.Size = Vector3.new(1, 2, 1)
		cLArm.Name = "Left Arm"

		--Right Arm
		local cRArm = Instance.new("Part", model)
		cRArm.Size = Vector3.new(1, 2, 1)
		cRArm.Name = "Right Arm"

		--Left Leg
		local cLLeg = Instance.new("Part", model)
		cLLeg.Size = Vector3.new(1, 2, 1)
		cLLeg.Name = "Left Leg"

		--Right Leg
		local cRLeg = Instance.new("Part", model)
		cRLeg.Size = Vector3.new(1, 2, 1)
		cRLeg.Name = "Right Leg"

		--HumanoidRootPart
		local cHRP = Instance.new("Part", model)
		cHRP.Size = Vector3.new(2, 2, 1)
		cHRP.Name = "HumanoidRootPart"
		cHRP.Transparency = 1
		cHRP.CanCollide = false

		--Transparency
		for i,v in pairs(model:GetChildren()) do
			if v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
				v.Transparency = 1--0.5
			end
		end

		--Joints--
		--Right Shoulder
		local rShoulder = Instance.new("Motor6D", cTorso)
		rShoulder.Part0 = cTorso
		rShoulder.Part1 = cRArm
		rShoulder.Name = "Right Shoulder"
		rShoulder.C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
		rShoulder.C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)

		--Left Shoulder
		local lShoulder = Instance.new("Motor6D", cTorso)
		lShoulder.Part0 = cTorso
		lShoulder.Part1 = cLArm
		lShoulder.Name = "Left Shoulder"
		lShoulder.C0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		lShoulder.C1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

		--Right Hip
		local rHip = Instance.new("Motor6D", cTorso)
		rHip.Part0 = cTorso
		rHip.Part1 = cRLeg
		rHip.Name = "Right Hip"
		rHip.C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
		rHip.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)

		--Left Hip
		local lHip = Instance.new("Motor6D", cTorso)
		lHip.Part0 = cTorso
		lHip.Part1 = cLLeg
		lHip.Name = "Left Hip"
		lHip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		lHip.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

		--Neck
		local neck = Instance.new("Motor6D", cTorso)
		neck.Part0 = cTorso
		neck.Part1 = cHead
		neck.Name = "Neck"
		neck.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		neck.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)

		--RootJoint
		local rootJoint = Instance.new("Motor6D", cHRP)
		rootJoint.Part0 = cHRP
		rootJoint.Part1 = cTorso
		rootJoint.Name = "RootJoint"
		rootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		rootJoint.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)

		--Humanoid--
		local cHumanoid = Instance.new("Humanoid", model)
		cHumanoid.DisplayDistanceType = "None"

		--Head Mesh--
		local headMesh = Instance.new("SpecialMesh", cHead)
		headMesh.Scale = Vector3.new(1.25, 1.25, 1.25)


		CreateAttachment(cHead, Vector3.new(0,0.60000002384186,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "HairAttachment")
		CreateAttachment(cHead, Vector3.new(0,0.60000002384186,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "HatAttachment")
		CreateAttachment(cHead, Vector3.new(0,0,-0.60000002384186), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "FaceFrontAttachment")
		CreateAttachment(cHead, Vector3.new(0,0,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "FaceCenterAttachment")
		CreateAttachment(cTorso, Vector3.new(0,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "NeckAttachment")
		CreateAttachment(cTorso, Vector3.new(0,0,-0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "BodyFrontAttachment")
		CreateAttachment(cTorso, Vector3.new(0,0,0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "BodyBackAttachment")
		CreateAttachment(cTorso, Vector3.new(-1,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftCollarAttachment")
		CreateAttachment(cTorso, Vector3.new(1,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightCollarAttachment")
		CreateAttachment(cTorso, Vector3.new(0,-1,-0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "WaistFrontAttachment")
		CreateAttachment(cTorso, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "WaistCenterAttachment")
		CreateAttachment(cTorso, Vector3.new(0,-1,0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "WaistBackAttachment")
		CreateAttachment(cLArm, Vector3.new(0,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftShoulderAttachment")
		CreateAttachment(cLArm, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftGripAttachment")
		CreateAttachment(cRArm, Vector3.new(0,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightShoulderAttachment")
		CreateAttachment(cRArm, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightGripAttachment")
		CreateAttachment(cLLeg, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftFootAttachment")
		CreateAttachment(cRLeg, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightFootAttachment")
		CreateAttachment(cHRP, Vector3.new(0,0,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RootAttachment")


		--Creating Attachments

		--Cloning Hats (For Netless)
		for i,v in pairs(Character:GetChildren()) do
			if v:IsA("Accessory") then
				local clone = v:Clone()
				local weld = v.Handle:FindFirstChildWhichIsA("Weld")
				local weldPart1 = weld.Part1
				local newWeld = Instance.new("Weld", clone.Handle)
				local CFrame0 = v.Handle.AccessoryWeld.C0
				local CFrame1 = v.Handle.AccessoryWeld.C1

				clone.Handle:FindFirstChild("AccessoryWeld"):Destroy()
				clone.Parent = model
				newWeld.Name = "AccessoryWeld"
				newWeld.C0 = CFrame0
				newWeld.C1 = CFrame1
				newWeld.Part0 = clone.Handle
				newWeld.Part1 = Character:FindFirstChild(weldPart1.Name)
				clone.Handle.Transparency = 1
			end
		end
		
		
		cHRP.CFrame = Character.HumanoidRootPart.CFrame
		CharacterModule.Reanimation = model
	end
	
	return CharacterModule.Reanimation
end

function CharacterModule.GetBodies()
	local VirtualRig = game.ReplicatedStorage.Dummy:Clone() --game:GetObjects("rbxassetid://4468539481")[1]
	local VirtualBody = game.ReplicatedStorage.Mover:Clone() --game:GetObjects("rbxassetid://4464983829")[1]
	local Anchor = Instance.new("Part")
	Anchor.Anchored = true
	Anchor.Transparency = 1
	Anchor.CanCollide = false
	Anchor.Position = Vector3.new()
	Anchor.Size = Vector3.new()
	Anchor.Name = "Anchor"
	Anchor.Parent = workspace
	
	return VirtualRig, VirtualBody, Anchor
end

function CharacterModule.SetUpBodies(VirtualRig, VirtualBody, CharacterCFrame)	
	VirtualRig.Name = "VirtualRig"
	VirtualRig.RightFoot.BodyPosition.Position = CharacterCFrame.p
	VirtualRig.LeftFoot.BodyPosition.Position = CharacterCFrame.p
	VirtualRig.Parent = workspace
	VirtualRig:SetPrimaryPartCFrame(CharacterCFrame)
	VirtualRig.Humanoid.Health = 0
	--VirtualRig:FindFirstChild("HumanoidRootPart").CFrame = character1.HumanoidRootPart.CFrame
	VirtualRig:BreakJoints()
	for i,v in pairs(VirtualRig:GetChildren()) do
		if v:IsA("BasePart") then
			v.CFrame = Character.HumanoidRootPart.CFrame
		end
	end
	--
	VirtualBody.Parent = workspace
	VirtualBody.Name = "VirtualBody"
	VirtualBody.Humanoid.WalkSpeed = 10
	VirtualBody:SetPrimaryPartCFrame(CharacterCFrame)
	--
	--Camera.CameraSubject = VirtualBody.Humanoid
	Character.Humanoid.WalkSpeed = 0
	Character.Humanoid.JumpPower = 1
	for _, Part in next, VirtualBody:GetChildren() do
		if Part:IsA("BasePart") then
			Part.Transparency = 1
		end
	end
	for _, Part in next, VirtualRig:GetChildren() do
		if Part:IsA("BasePart") then
			Part.Transparency = 1
		end
	end
end

function CharacterModule.CreateSockets(Reanimation) -- // Model:Reanimation
	local LeftAttachment = Instance.new("Attachment", Reanimation["Left Leg"])
	LeftAttachment.Position = Vector3.new(0, 1, 0)

	local LeftHipAttachment = Instance.new("Attachment", Reanimation["Torso"])
	LeftHipAttachment.Position = Vector3.new(-0.5, -1, 0)

	local LeftHipSocket = Instance.new("BallSocketConstraint", Reanimation["Left Leg"])
	LeftHipSocket.Attachment0 = LeftAttachment
	LeftHipSocket.Attachment1 = LeftHipAttachment


	local RightAttachment = Instance.new("Attachment", Reanimation["Right Leg"])
	RightAttachment.Position = Vector3.new(0, 1, 0)

	local RightHipAttachment = Instance.new("Attachment", Reanimation["Torso"])
	RightHipAttachment.Position = Vector3.new(0.5, -1, 0)

	local RightHipSocket = Instance.new("BallSocketConstraint", Reanimation["Right Leg"])
	RightHipSocket.Attachment0 = RightAttachment
	RightHipSocket.Attachment1 = RightHipAttachment


	local NeckAttachment = Instance.new("Attachment", Reanimation["Head"])
	NeckAttachment.Position = Vector3.new(0, -0.5, 0)

	local TorsoToNeckAttachment = Instance.new("Attachment", Reanimation["Torso"])
	TorsoToNeckAttachment.Position = Vector3.new(0, 1, 0)

	local NeckSocket = Instance.new("BallSocketConstraint", Reanimation["Head"])
	NeckSocket.Attachment0 = NeckAttachment
	NeckSocket.Attachment1 = TorsoToNeckAttachment
end

function CharacterModule.CreateCharacterAlignment(Anchor)
	PermaDeath()
	
	local MoveHead = CreateAlignment(CharacterModule.Reanimation["Head"], Anchor)
	local MoveRightArm = CreateAlignment(CharacterModule.Reanimation["Right Arm"], Anchor)
	local MoveLeftArm = CreateAlignment(CharacterModule.Reanimation["Left Arm"], Anchor)
	local MoveRightLeg = CreateAlignment(CharacterModule.Reanimation["Right Leg"], Anchor)
	local MoveLeftLeg = CreateAlignment(CharacterModule.Reanimation["Left Leg"], Anchor)
	local MoveTorso = CreateAlignment(CharacterModule.Reanimation["Torso"], Anchor)
	local MoveRoot = CreateAlignment(CharacterModule.Reanimation["HumanoidRootPart"], Anchor)

	for _, Accessory in next, CharacterModule.Reanimation:GetChildren() do
		if Accessory:IsA("Accessory") and Accessory:FindFirstChild("Handle") then
			local Attachment1 = Accessory.Handle:FindFirstChildWhichIsA("Attachment")
			local Attachment0 = CharacterModule.Reanimation:FindFirstChild(tostring(Attachment1), true)
			local Orientation = Instance.new("AlignOrientation")
			local Position = Instance.new("AlignPosition")
			--print(Attachment1, Attachment0, Accessory)

			Orientation.Attachment0 = Attachment1
			Orientation.Attachment1 = Attachment0
			Orientation.RigidityEnabled = false
			Orientation.ReactionTorqueEnabled = true
			Orientation.MaxTorque = 2000
			Orientation.Responsiveness = 200
			Orientation.Parent = CharacterModule.Reanimation["Head"]

			Position.Attachment0 = Attachment1
			Position.Attachment1 = Attachment0
			Position.RigidityEnabled = false
			Position.ReactionForceEnabled = true
			Position.MaxForce = 4000
			Position.Responsiveness = 200
			Position.Parent = CharacterModule.Reanimation["Head"]
		end
	end
	
	return MoveHead, MoveRightArm, MoveLeftArm, MoveRightLeg, MoveLeftLeg, MoveTorso, MoveRoot
end

function CharacterModule.SetUpCharacter()
	for _, Part in pairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") and Part.Name == "Handle" and Part.Parent:IsA("Accessory") then
			Part.LocalTransparencyModifier = 1
		elseif Part:IsA("BasePart") and Part.Transparency < 0.5 and Part.Name ~= "Head" then
			Part.LocalTransparencyModifier = BodyTransparency
		elseif Part:IsA("BasePart") and Part.Name == "Head" then
			Part.LocalTransparencyModifier = 1
		end
		if not Part:IsA("BasePart") and not Part:IsA("AlignPosition") and not Part:IsA("AlignOrientation") then
			pcall(
				function()
					Part.Transparency = 1
				end
			)
			pcall(
				function()
					Part.Enabled = false
				end
			)
		end
	end
	
	
	for i,v in pairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			v:Destroy()
		end
	end

	for i,v in pairs(CharacterModule.Reanimation:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end
end

return CharacterModule