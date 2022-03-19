local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


-- // Disable kicking
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
	local args = {...} 
	if getnamecallmethod() == 'Kick' then 
		return false
	end
	return OldNamecall(Self, unpack(args))
end)








function GetModule(module)
	return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/madrwr/Clover/main/" .. module .. ".lua"))()
end

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

local function GetMotorForLimb(Limb)
	for _, Motor in next, Character:GetDescendants() do
		if Motor:IsA("Motor6D") and Motor.Part1 == Limb then
			return Motor
		end
	end
end



local Client = {}
Client.__index = Client


function Client.Permakill()
	local RealCharacter = Players.LocalPlayer.Character
	local StaleCharacter = CreateStale()
	Players.LocalPlayer.Character = StaleCharacter
	wait(game.Players.RespawnTime/2)
	warn("50%")
	Players.LocalPlayer.Character = RealCharacter
	wait(game.Players.RespawnTime/2 + 0.5)
	warn("100%")
end

function Client.Respawn()
	local RealCharacter = Players.LocalPlayer.Character
	local StaleCharacter = CreateStale()
	Players.LocalPlayer.Character = StaleCharacter
	wait(game.Players.RespawnTime)
	Players.LocalPlayer.Character = RealCharacter
end

function Client.PhysicsBypass() -- // Questionable
	pcall(function()
		settings().Physics.AllowSleep = false 
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	end)
end

function Client.CreateLegSockets(Model)
	local LeftAttachment = Instance.new("Attachment", Model["Left Leg"])
	LeftAttachment.Position = Vector3.new(0, 1, 0)
	
	local LeftHipAttachment = Instance.new("Attachment", Model["Torso"])
	LeftHipAttachment.Position = Vector3.new(-0.5, -1, 0)
	
	local LeftHipSocket = Instance.new("BallSocketConstraint", Model["Left Leg"])
	LeftHipSocket.Attachment0 = LeftAttachment
	LeftHipSocket.Attachment1 = LeftHipAttachment
	
	
	local RightAttachment = Instance.new("Attachment", Model["Right Leg"])
	RightAttachment.Position = Vector3.new(0, 1, 0)
	
	local RightHipAttachment = Instance.new("Attachment", Model["Torso"])
	RightHipAttachment.Position = Vector3.new(0.5, -1, 0)
	
	local RightHipSocket = Instance.new("BallSocketConstraint", Model["Right Leg"])
	RightHipSocket.Attachment0 = RightAttachment
	RightHipSocket.Attachment1 = RightHipAttachment
	
	
	local NeckAttachment = Instance.new("Attachment", Model["Head"])
	NeckAttachment.Position = Vector3.new(0, -0.5, 0)
	
	local TorsoToNeckAttachment = Instance.new("Attachment", Model["Torso"])
	TorsoToNeckAttachment.Position = Vector3.new(0, 1, 0)
	
	local NeckSocket = Instance.new("BallSocketConstraint", Model["Head"])
	NeckSocket.Attachment0 = NeckAttachment
	NeckSocket.Attachment1 = TorsoToNeckAttachment
end

function Client.ClovrContainedReanimation(Character)
	local function CreateAttachment(parent, position, orientation, axis, secondaryAxis, name)
		local newAttchment = Instance.new("Attachment", parent)
		newAttchment.Position = position
		newAttchment.Orientation = orientation
		newAttchment.Axis = axis
		newAttchment.SecondaryAxis = secondaryAxis
		newAttchment.Name = name
	end
	
	local ReanimationFolder = Instance.new("Folder", Character)
	ReanimationFolder.Name = "FakeCharacter"

	local Reanimation = Instance.new("Model", ReanimationFolder)
	Reanimation.Name = "Reanimation"
	
	
	do
		local Head = Instance.new("Part", Reanimation)
		Head.Size = Vector3.new(2, 1, 1)
		Head.Name = "Head"

		--Torso
		local Torso = Instance.new("Part", Reanimation)
		Torso.Size = Vector3.new(2, 2, 1)
		Torso.Name = "Torso"

		--Left Arm
		local LeftArm = Instance.new("Part", Reanimation)
		LeftArm.Size = Vector3.new(1, 2, 1)
		LeftArm.Name = "Left Arm"

		--Right Arm
		local RightArm = Instance.new("Part", Reanimation)
		RightArm.Size = Vector3.new(1, 2, 1)
		RightArm.Name = "Right Arm"

		--Left Leg
		local LeftLeg = Instance.new("Part", Reanimation)
		LeftLeg.Size = Vector3.new(1, 2, 1)
		LeftLeg.Name = "Left Leg"

		--Right Leg
		local RightLeg = Instance.new("Part", Reanimation)
		RightLeg.Size = Vector3.new(1, 2, 1)
		RightLeg.Name = "Right Leg"

		--HumanoidRootPart
		local HumanoidRootPart = Instance.new("Part", Reanimation)
		HumanoidRootPart.Size = Vector3.new(2, 2, 1)
		HumanoidRootPart.Name = "HumanoidRootPart"
		HumanoidRootPart.Transparency = 1
		HumanoidRootPart.CanCollide = false

		--Transparency
		for i,v in pairs(Reanimation:GetChildren()) do
			if v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
				v.Transparency = 1--0.5
			end
		end

		--Joints--
		--Right Shoulder
		local rShoulder = Instance.new("Motor6D", Torso)
		rShoulder.Part0 = Torso
		rShoulder.Part1 = RightArm
		rShoulder.Name = "Right Shoulder"
		rShoulder.C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
		rShoulder.C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)

		--Left Shoulder
		local lShoulder = Instance.new("Motor6D", Torso)
		lShoulder.Part0 = Torso
		lShoulder.Part1 = LeftArm
		lShoulder.Name = "Left Shoulder"
		lShoulder.C0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		lShoulder.C1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

		--Right Hip
		local rHip = Instance.new("Motor6D", Torso)
		rHip.Part0 = Torso
		rHip.Part1 = RightLeg
		rHip.Name = "Right Hip"
		rHip.C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
		rHip.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)

		--Left Hip
		local lHip = Instance.new("Motor6D", Torso)
		lHip.Part0 = Torso
		lHip.Part1 = LeftLeg
		lHip.Name = "Left Hip"
		lHip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		lHip.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

		--Neck
		local neck = Instance.new("Motor6D", Torso)
		neck.Part0 = Torso
		neck.Part1 = Head
		neck.Name = "Neck"
		neck.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		neck.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)

		--RootJoint
		local rootJoint = Instance.new("Motor6D", HumanoidRootPart)
		rootJoint.Part0 = HumanoidRootPart
		rootJoint.Part1 = Torso
		rootJoint.Name = "RootJoint"
		rootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		rootJoint.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)

		--Humanoid--
		local Humanoid = Instance.new("Humanoid", Reanimation)
		Humanoid.DisplayDistanceType = "None"

		--Head Mesh--
		local Mesh = Instance.new("SpecialMesh", Head)
		Mesh.Scale = Vector3.new(1.25, 1.25, 1.25)


		CreateAttachment(Head, Vector3.new(0,0.60000002384186,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "HairAttachment")
		CreateAttachment(Head, Vector3.new(0,0.60000002384186,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "HatAttachment")
		CreateAttachment(Head, Vector3.new(0,0,-0.60000002384186), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "FaceFrontAttachment")
		CreateAttachment(Head, Vector3.new(0,0,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "FaceCenterAttachment")
		CreateAttachment(Torso, Vector3.new(0,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "NeckAttachment")
		CreateAttachment(Torso, Vector3.new(0,0,-0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "BodyFrontAttachment")
		CreateAttachment(Torso, Vector3.new(0,0,0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "BodyBackAttachment")
		CreateAttachment(Torso, Vector3.new(-1,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftCollarAttachment")
		CreateAttachment(Torso, Vector3.new(1,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightCollarAttachment")
		CreateAttachment(Torso, Vector3.new(0,-1,-0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "WaistFrontAttachment")
		CreateAttachment(Torso, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "WaistCenterAttachment")
		CreateAttachment(Torso, Vector3.new(0,-1,0.5), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "WaistBackAttachment")
		CreateAttachment(LeftArm, Vector3.new(0,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftShoulderAttachment")
		CreateAttachment(LeftArm, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftGripAttachment")
		CreateAttachment(RightArm, Vector3.new(0,1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightShoulderAttachment")
		CreateAttachment(RightArm, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightGripAttachment")
		CreateAttachment(LeftLeg, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "LeftFootAttachment")
		CreateAttachment(RightLeg, Vector3.new(0,-1,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RightFootAttachment")
		CreateAttachment(HumanoidRootPart, Vector3.new(0,0,0), Vector3.new(-0,0,0), Vector3.new(1,0,0), Vector3.new(0,1,0), "RootAttachment")


		--Creating Attachments

		--Cloning Hats (For Netless)
		for Index, _Instance in pairs(Character:GetChildren()) do
			if _Instance:IsA("Accessory") then
				local Clone = _Instance:Clone()
				local Weld = _Instance.Handle:FindFirstChildWhichIsA("Weld")
				local WeldPart1 = Weld.Part1
				local NewWeld = Instance.new("Weld", Clone.Handle)
				local CFrame0 = _Instance.Handle.AccessoryWeld.C0
				local CFrame1 = _Instance.Handle.AccessoryWeld.C1

				Clone.Handle:FindFirstChild("AccessoryWeld"):Destroy()
				Clone.Parent = Reanimation
				NewWeld.Name = "AccessoryWeld"
				NewWeld.C0 = CFrame0
				NewWeld.C1 = CFrame1
				NewWeld.Part0 = Clone.Handle
				NewWeld.Part1 = Character:FindFirstChild(WeldPart1.Name)
				Clone.Handle.Transparency = 1
			end
		end

		HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
	end
	
	return Reanimation
end

function Client.CreatAlignment(Limb, Anchor)
	local Reanimation = Limb.Parent
	
	local Attachment0 = Instance.new("Attachment", Anchor)
	local Attachment1 = Instance.new("Attachment", Limb)
	local Orientation = Instance.new("AlignOrientation")
	local Position = Instance.new("AlignPosition")
	Orientation.Attachment0 = Attachment1
	Orientation.Attachment1 = Attachment0
	Orientation.RigidityEnabled = false
	Orientation.MaxTorque = 2000
	Orientation.Responsiveness = 200
	Orientation.Parent = Reanimation["HumanoidRootPart"]

	Orientation.Name = Limb.Name.."'s AlignRot"
	Orientation.MaxAngularVelocity = 10000

	Position.Attachment0 = Attachment1
	Position.Attachment1 = Attachment0
	Position.RigidityEnabled = false
	Position.MaxForce = 4000
	Position.Responsiveness = 200
	Position.Parent = Reanimation["HumanoidRootPart"]

	Position.Name = Limb.Name.."'s AlignPos"
	Position.MaxVelocity = 10000

	Limb.Massless = false
	local Motor = GetMotorForLimb(Limb)
	if Motor then
		Motor:Destroy()
	end
	return function(CF, Local)
		Attachment0.WorldCFrame = CF
	end
end



-- // Where the real stuff happens
function Client.New()
	local self = setmetatable({}, Client)

	-- // Create a couple self variables
	self.TurnDeg = 30
	self.LastTurn = CFrame.fromEulerAnglesXYZ(0, 0, 0)
	self.Turn = CFrame.fromEulerAnglesXYZ(0, 0, 0)
	self.IsTurning = false

	self.LastUserCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	self.HandRotation = CFrame.fromEulerAnglesXYZ(math.rad(90), 0, 0)
	self.MoveVector = Vector3.new()


	-- // Call necessary FFlags and Requires
	self:Require("Functions")
	self:Require("RunModule")
	self:Require("Input")
	self:Require("ChatModules/ChatMain")
	self:Require("Footing")

	-- // Character
	local Character = LocalPlayer.Character
	Character:WaitForChild("HumanoidRootPart")
	Character:WaitForChild("Humanoid")

	if Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		self.Reanimation = Client.ClovrContainedReanimation(Character)
		self.VirtualRig = game:GetObjects("rbxassetid://4468539481")[1]
		self.VirtualBody = game:GetObjects("rbxassetid://4464983829")[1]
		self.Anchor = Instance.new("Part")
		self.Anchor.Anchored = true
		self.Anchor.Transparency = 1
		self.Anchor.CanCollide = false
		self.Anchor.Parent = workspace
		
		
		Client.Permakill()
		self.MoveHead = Client.CreatAlignment(self.Reanimation["Head"], self.Anchor)
		self.MoveRightArm = Client.CreatAlignment(self.Reanimation["Right Arm"], self.Anchor)
		self.MoveLeftArm = Client.CreatAlignment(self.Reanimation["Left Arm"], self.Anchor)
		self.MoveRightLeg = Client.CreatAlignment(self.Reanimation["Right Leg"], self.Anchor)
		self.MoveLeftLeg = Client.CreatAlignment(self.Reanimation["Left Leg"], self.Anchor)
		self.MoveTorso = Client.CreatAlignment(self.Reanimation["Torso"], self.Anchor)
		self.MoveRoot = Client.CreatAlignment(self.Reanimation["HumanoidRootPart"], self.Anchor)
		
		for _, _Instance in pairs(self.Reanimation:GetChildren()) do
			if _Instance:IsA("Accessory") and _Instance:FindFirstChild("Handle") then
				local Attachment1 = _Instance.Handle:FindFirstChildWhichIsA("Attachment")
				local Attachment0 = self.Reanimation:FindFirstChild(tostring(Attachment1), true)
				local Orientation = Instance.new("AlignOrientation")
				local Position = Instance.new("AlignPosition")
				--print(Attachment1, Attachment0, Accessory)

				Orientation.Attachment0 = Attachment1
				Orientation.Attachment1 = Attachment0
				Orientation.RigidityEnabled = false
				Orientation.ReactionTorqueEnabled = true
				Orientation.MaxTorque = 2000
				Orientation.Responsiveness = 200
				Orientation.Parent = self.Reanimation["Head"]

				Position.Attachment0 = Attachment1
				Position.Attachment1 = Attachment0
				Position.RigidityEnabled = false
				Position.ReactionForceEnabled = true
				Position.MaxForce = 4000
				Position.Responsiveness = 200
				Position.Parent = self.Reanimation["Head"]
			end
		end
		
		do  -- // Set up virtual bodies
			self.VirtualRig.Name = "VirtualRig"
			self.VirtualRig.RightFoot.BodyPosition.Position = Character.HumanoidRootPart.CFrame.p
			self.VirtualRig.LeftFoot.BodyPosition.Position = Character.HumanoidRootPart.CFrame.p
			self.VirtualRig.Parent = workspace
			self.VirtualRig:SetPrimaryPartCFrame(Character.HumanoidRootPart.CFrame)
			self.VirtualRig.Humanoid.Health = 0
			self.VirtualRig:BreakJoints()
			for _, Part in pairs(self.VirtualRig:GetChildren()) do
				if Part:IsA("BasePart") then
					Part.CFrame = Character.HumanoidRootPart.CFrame
				end
			end
			--
			self.VirtualBody.Parent = workspace
			self.VirtualBody.Name = "VirtualBody"
			self.VirtualBody.Humanoid.WalkSpeed = 8
			self.VirtualBody:SetPrimaryPartCFrame(Character.HumanoidRootPart.CFrame)
			--
			Character.Humanoid.WalkSpeed = 0
			Character.Humanoid.JumpPower = 1
			for _, Part in pairs(self.VirtualBody:GetChildren()) do
				if Part:IsA("BasePart") then
					Part.Transparency = 1
				end
			end
			for _, Part in pairs(self.VirtualRig:GetChildren()) do
				if Part:IsA("BasePart") then
					Part.Transparency = 1
				end
			end
			
			
			for _, Part in pairs(Character:GetDescendants()) do
				if Part:IsA("BasePart") and Part.Name == "Handle" and Part.Parent:IsA("Accessory") then
					Part.LocalTransparencyModifier = 1
				elseif Part:IsA("BasePart") and Part.Transparency < 0.5 and Part.Name ~= "Head" then
					Part.LocalTransparencyModifier = 0.6
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
		end
		
		
		
		self.RayIgnore = {self.VirtualRig, self.VirtualBody, Character, Camera, self.Anchor}
		
		
		
		
		Client.CreateLegSockets(Character)
		Client.PhysicsBypass()
		
		self:NewChatParent()
		self:StartUpdating()
		self:StartInputs()
	end
	
	

	-- // Hide the main pointer
	pcall(function()
		VRService:RecenterUserHeadCFrame()
		game.StarterGui:SetCore("VRLaserPointerMode", "Hidden")
		game.StarterGui:SetCore("VREnableControllerModels", true)
	end)
end

function Client:GetCharacter()
	local Character = LocalPlayer.Character
	return (Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart")) and Character or nil
end

function Client:Require(Name)
	GetModule(Name)(self)
end





-- // nothing to return, just run
Client.New()