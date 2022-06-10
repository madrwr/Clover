local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local Camera = workspace.Camera




-- Settings
local HighLevelAccess = true

local AutoRun = false
local ViewportEnabled = false
local BodyVelocity = {-17.5, 0, -17.5}
local HatVelocity = {-17.5, 0, -17.5}












-- Module prepare
function GetModule(module)
	if HighLevelAccess then
		local Success, Returned = pcall(function()
			return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/madrwr/Clover/main/" .. module .. ".lua"))()
		end)
		
		return Success and Returned or nil
	else
		return require(script.Parent:WaitForChild(module))
	end
end

local CharacterModule = GetModule("Character")
local Footing = GetModule("Footing")


if not CharacterModule or not Footing then
	warn("Something has gone wrong")
	return function()end
end



--




local CameraAngle = CFrame.new()
local WasdMove = Vector3.new()


if not VRService.VREnabled then
	local WasdTable = {
		[Enum.KeyCode.W.Name] = 0,
		[Enum.KeyCode.A.Name] = 0,
		[Enum.KeyCode.S.Name] = 0,
		[Enum.KeyCode.D.Name] = 0
	}


	local W = 0
	local A = 0
	local S = 0
	local D = 0

	local TargetAngleX = 0
	local TargetAngleY = 0

	ContextActionService:BindAction("GameMouseMovement", function(Name, State, Input)
		if (State == Enum.UserInputState.Change or State == Enum.UserInputState.Begin) then
			local Delta = Vector2.new(Input.Delta.X / 4, Input.Delta.Y / 4)
			TargetAngleX = math.clamp(TargetAngleX - Delta.Y , -80, 80)
			TargetAngleY = (TargetAngleY - Delta.X) % 360

			CameraAngle = CFrame.Angles(0,math.rad(TargetAngleY),0) * CFrame.Angles(math.rad(TargetAngleX),0,0)
		end

		game:GetService("UserInputService").MouseIconEnabled = false
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
	end, false, Enum.UserInputType.MouseMovement)

	ContextActionService:BindAction("Wasd_ClovrVR", function(Name, State, Input)
		WasdTable[Input.KeyCode.Name] = (State == Enum.UserInputState.Begin) and 1 or 0
		WasdMove = Vector3.new(WasdTable[Enum.KeyCode.D.Name] - WasdTable[Enum.KeyCode.A.Name], 0, WasdTable[Enum.KeyCode.S.Name] - WasdTable[Enum.KeyCode.W.Name])
	end, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D)
end




function Start()
	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local PlayerModule = Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")
	local ControlModule = require(PlayerModule:WaitForChild("ControlModule"))
	Character:WaitForChild("HumanoidRootPart")
	Character:WaitForChild("Humanoid")

	local Reanimation = CharacterModule.CreateReanimation()
	local VirtualRig, VirtualBody, Anchor = CharacterModule.GetBodies(not HighLevelAccess)
	local Ignore = {VirtualRig, VirtualBody, Character, Camera, Anchor}
	local CharacterCFrame = Character.HumanoidRootPart.CFrame

	local MoveHead, MoveRightArm,
	MoveLeftArm, MoveRightLeg,
	MoveLeftLeg, MoveTorso,
	MoveRoot = CharacterModule.CreateCharacterAlignment(Anchor)

	CharacterModule.SetUpBodies(VirtualRig, VirtualBody, CharacterCFrame)
	CharacterModule.SetUpCharacter()


	local FloorRay, Flatten, FootReady, FootYield, UpdateFooting, UpdateLegPosition = Footing(VirtualRig, VirtualBody, MoveRightLeg, MoveLeftLeg, Ignore)


	local function UpdateTorsoPosition()
		local Positioning = VirtualRig.UpperTorso.CFrame
		MoveTorso.WorldCFrame = (Positioning * CFrame.new(0, -0.25, 0))
		MoveRoot.WorldCFrame = (Positioning * CFrame.new(0, -0.25, 0))
	end

	local function OnUserCFrameChanged(UserCFrame, Positioning)
		local Positioning = Camera.CFrame * Positioning

		if UserCFrame == Enum.UserCFrame.Head then
			MoveHead.WorldCFrame = (Positioning)

			VirtualRig.Head.CFrame = Positioning
		elseif UserCFrame == Enum.UserCFrame.RightHand then
			Positioning = Positioning * CFrame.new(0, 0, 1) * CFrame.Angles(math.rad(90), 0, 0)

			VirtualRig.RightHand.CFrame = Positioning
			VirtualRig.RightUpperArm.Aim.MaxTorque = Vector3.new(0, 0, 0)


			if not VRService.VREnabled then
				Positioning = VirtualRig.RightUpperArm.CFrame:Lerp(VirtualRig.RightLowerArm.CFrame, 0.5)
			end

			MoveRightArm.WorldCFrame = (Positioning)
		elseif UserCFrame == Enum.UserCFrame.LeftHand then
			Positioning = Positioning * CFrame.new(0, 0, 1) * CFrame.Angles(math.rad(90), 0, 0)

			VirtualRig.LeftHand.CFrame = Positioning
			VirtualRig.LeftUpperArm.Aim.MaxTorque = Vector3.new(0, 0, 0)


			if not VRService.VREnabled then
				Positioning = VirtualRig.LeftUpperArm.CFrame:Lerp(VirtualRig.LeftLowerArm.CFrame, 0.5)
			end

			MoveLeftArm.WorldCFrame = (Positioning)
		end

		VirtualRig.RightHand.Anchored = true
		VirtualRig.LeftHand.Anchored = true
	end

	local function GetHeadlockedCFrame()
		local Camera = workspace.CurrentCamera
		local UserCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)

		return CFrame.fromEulerAnglesXYZ(UserCFrame:ToEulerAnglesXYZ()) * UserCFrame:Inverse()
	end	

	local function AngledVector(Vector)
		local CameraCFrame = Camera:GetRenderCFrame()
		local LookDirection = CameraCFrame.LookVector
		local LookAngle = math.atan2(LookDirection.Z, LookDirection.X)

		return (CFrame.new(Vector) * CFrame.fromEulerAnglesXYZ(0, LookAngle, 0)).Position
	end

	local function DestroyModel(Model)
		if Model then
			Model:Destroy()
		end
	end


	--
	local LastUserPosition = VRService:GetUserCFrame(Enum.UserCFrame.Head).Position
	local LeftThumbstick = Vector3.new()
	local Turn = CFrame.fromEulerAnglesXYZ(0,0,0)
	local IsTurning = false


	--	
	local OnStepped
	OnStepped = RunService.Stepped:Connect(function()
		for _, Part in pairs(VirtualRig:GetChildren()) do
			if Part:IsA("BasePart") then
				Part.CanCollide = false
			end
		end

		for _, Part in pairs(Character:GetChildren()) do
			if Part:IsA("BasePart") then
				Part.CanCollide = false
			end
		end

		for _, Part in pairs(Reanimation:GetChildren()) do
			if Part:IsA("BasePart") then
				Part.CanCollide = false
			end
		end
	end)


	local OnRenderStepped
	OnRenderStepped = RunService.RenderStepped:Connect(function(Delta)
		if not (Character and Character:FindFirstChild("HumanoidRootPart")) then warn("No Character or HumanoidRootPart") return end
		local UserCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		local MoveDistance = Turn * CFrame.new(UserCFrame.Position - LastUserPosition).Position * Vector3.new(1, 0, 1)

		local LookDirection = Camera:GetRenderCFrame().LookVector
		local LookAngle = math.atan2(-LookDirection.X, -LookDirection.Z)
		local RawPosition = VirtualBody.HumanoidRootPart.Position + MoveDistance
		VirtualBody.HumanoidRootPart.CFrame = CFrame.lookAt(RawPosition, RawPosition + CFrame.fromEulerAnglesXYZ(0, LookAngle, 0).LookVector)
		local RootPosition = CFrame.new(VirtualBody.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0))


		Camera.CameraSubject = nil
		Camera.CameraType = Enum.CameraType.Scriptable



		if ControlModule.activeController and ControlModule.activeController.enabled then
			ControlModule:Disable()
			ContextActionService:BindActivate(Enum.UserInputType.Gamepad1,Enum.KeyCode.ButtonR2)
		end


		if VRService.VREnabled then
			Camera.CFrame = (RootPosition * CFrame.new(0, UserCFrame.Y, 0) * Turn * GetHeadlockedCFrame())
			VirtualBody.Humanoid:Move(AngledVector(LeftThumbstick), true)
		else
			Camera.CFrame = RootPosition * CameraAngle
			VirtualBody.Humanoid:Move(AngledVector(WasdMove), true)

			VirtualRig.RightUpperArm.ShoulderConstraint.RigidityEnabled = true
			VirtualRig.LeftUpperArm.ShoulderConstraint.RigidityEnabled = true
		end


		LastUserPosition = UserCFrame.Position
		Character.HumanoidRootPart.CFrame = VirtualRig.UpperTorso.CFrame
		Anchor.Velocity = VirtualBody.HumanoidRootPart.Velocity
		OnUserCFrameChanged(Enum.UserCFrame.Head, VRService:GetUserCFrame(Enum.UserCFrame.Head))
		OnUserCFrameChanged(Enum.UserCFrame.RightHand, VRService:GetUserCFrame(Enum.UserCFrame.RightHand))
		OnUserCFrameChanged(Enum.UserCFrame.LeftHand, VRService:GetUserCFrame(Enum.UserCFrame.LeftHand))

		UpdateTorsoPosition()
		UpdateLegPosition()


		for _, Part in pairs(Character:GetChildren()) do
			if Part:IsA("BasePart") then
				Part.Velocity = Vector3.new(BodyVelocity[1], BodyVelocity[2], BodyVelocity[3])
				Part.CFrame = Reanimation:FindFirstChild(Part.Name).CFrame
			end

			if Part:IsA("Accessory") then
				if Part:FindFirstChild("Handle") and Reanimation:FindFirstChild(Part.Name):FindFirstChild("Handle") then
					Part.Handle.Velocity = Vector3.new(HatVelocity[1], HatVelocity[2], HatVelocity[3])
					Part.Handle.CFrame = Reanimation:FindFirstChild(Part.Name).Handle.CFrame
				end
			end
		end
	end)

	spawn(function()
		while Character and Character.Parent do
			FootYield()
			UpdateFooting()
		end
	end)


	--
	ControlModule:Disable()

	ContextActionService:BindAction("ThumbStick2", function(Name, State, Input)
		if not IsTurning and math.abs(Input.Position.X) > 0.7 then
			IsTurning = true

			local TurnDirection = 30 * -math.sign(Input.Position.X)				
			Turn = Turn * CFrame.fromEulerAnglesXYZ(0, math.rad(TurnDirection), 0)
		elseif IsTurning and math.abs(Input.Position.X) < 0.7 then
			IsTurning = false
		end
	end, false, Enum.KeyCode.Thumbstick2)

	ContextActionService:BindAction("Movement", function(Name, State, Input)
		if Input.Position.Magnitude > 0.15 then
			LeftThumbstick = Vector3.new(Input.Position.X, 0, -Input.Position.Y)
		else
			LeftThumbstick = Vector3.new()
		end
	end, false, Enum.KeyCode.Thumbstick1)

	ContextActionService:BindAction("Jump", function(Name, State, Input)
		if State == Enum.UserInputState.Begin then
			VirtualBody.Humanoid.Jump = true
		end
	end, false, Enum.KeyCode.ButtonA, Enum.KeyCode.Space)

	ContextActionService:BindAction("Run", function(Name, State, Input)
		if State == Enum.UserInputState.Begin then
			VirtualBody.Humanoid.WalkSpeed = 16
		elseif State == Enum.UserInputState.End then
			VirtualBody.Humanoid.WalkSpeed = 10
		end
	end, false, Enum.KeyCode.ButtonR2, Enum.KeyCode.LeftShift)



	--
	local CharacterAdded
	CharacterAdded = Players.LocalPlayer.CharacterAdded:Connect(function()
		CharacterAdded:Disconnect()
		OnRenderStepped:Disconnect()
		OnStepped:Disconnect()

		DestroyModel(Reanimation)
		DestroyModel(VirtualRig)
		DestroyModel(VirtualBody)
		DestroyModel(Anchor)

		ContextActionService:UnbindAction("Thumbstick2")
		ContextActionService:UnbindAction("Movement")
		ContextActionService:UnbindAction("Jump")

		if AutoRun then
			wait(2)
			Start()
		end
	end)
	
	
	if HighLevelAccess then
		settings().Physics.AllowSleep = false 
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
		Players.LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
	end

	--

	wait(2)
	if Reanimation then
		CharacterModule.CreateSockets(Reanimation)
	end
end


return function(Data)
	if Data.HighLevelAccess then
		HighLevelAccess = Data.HighLevelAccess
	end
	
	if Data.AutoRun then
		AutoRun = Data.AutoRun
	end
	
	if Data.ViewportEnabled then
		ViewportEnabled = Data.ViewportEnabled
	end
	
	if Data.BodyVelocity then
		BodyVelocity = Data.BodyVelocity
	end
	
	if Data.HatVelocity then
		HatVelocity = Data.HatVelocity
	end
	
	Start()
end