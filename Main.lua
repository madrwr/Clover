local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local Camera = workspace.Camera




function GetModule(module)
	return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/madrwr/Clover/main/" .. module .. ".lua"))()
	--return require(script.Parent:WaitForChild(module))
end

local CharacterModule = GetModule("Character")
local Footing = GetModule("Footing")


-- Settings
local AutoRun = false
local ViewportEnabled = false
local BodyVelocity = {-17.5, 0, -17.5}
local HatVelocity = {-17.5, 0, -17.5}


--




function Start()
	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local PlayerModule = Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")
	local ControlModule = require(PlayerModule:WaitForChild("ControlModule"))
	Character:WaitForChild("HumanoidRootPart")
	Character:WaitForChild("Humanoid")
	
	local Reanimation = CharacterModule.CreateReanimation()
	local VirtualRig, VirtualBody, Anchor = CharacterModule.GetBodies()
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
			MoveRightArm.WorldCFrame = (Positioning)
			
			VirtualRig.RightHand.CFrame = Positioning
			VirtualRig.RightUpperArm.Aim.MaxTorque = Vector3.new(0, 0, 0)
		elseif UserCFrame == Enum.UserCFrame.LeftHand then
			Positioning = Positioning * CFrame.new(0, 0, 1) * CFrame.Angles(math.rad(90), 0, 0)
			MoveLeftArm.WorldCFrame = (Positioning)
			
			VirtualRig.LeftHand.CFrame = Positioning
			VirtualRig.LeftUpperArm.Aim.MaxTorque = Vector3.new(0, 0, 0)
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
		Camera.CFrame = (RootPosition * CFrame.new(0, UserCFrame.Y, 0) * Turn * GetHeadlockedCFrame())
		
		
		
		if ControlModule.activeController and ControlModule.activeController.enabled then
			ControlModule:Disable()
			ContextActionService:BindActivate(Enum.UserInputType.Gamepad1,Enum.KeyCode.ButtonR2)
		end
		
		VirtualBody.Humanoid:Move(AngledVector(LeftThumbstick), true)


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
	end, false, Enum.KeyCode.ButtonA)
	
	
	
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
	
	
	--
	Players.LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
	Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
	Players.LocalPlayer.CameraMaxZoomDistance = 15
	Players.LocalPlayer.CameraMinZoomDistance = 10
	StarterGui:SetCore("VRLaserPointerMode", 3)
	VRService:RecenterUserHeadCFrame()
	
	settings().Physics.AllowSleep = false 
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	
	
	--
	
	wait(2)
	if Reanimation then
		CharacterModule.CreateSockets(Reanimation)
	end
end


Start()
wait(9e16)
return true