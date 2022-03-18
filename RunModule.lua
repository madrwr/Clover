local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local Camera = workspace.CurrentCamera
local Flat = Vector3.new(1, 0, 1)

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local RunModule = {}
local RunString = "VRStep_RunModule"



function RunModule.New(self)
	function self:StartUpdating()
		RunService:BindToRenderStep(RunString, Enum.RenderPriority.Camera.Value - 1, function(Delta)
			local Character = self:GetCharacter()

			if Character then
				local HeadCFrame, RightCFrame, LeftCFrame = self:GetUserCFrames()
				local Scale = Camera.HeadScale

				Camera.CameraType = Enum.CameraType.Scriptable


				-- // Movevector
				local MoveVector = self.Turn * CFrame.new(HeadCFrame.Position - self.LastUserCFrame.p).Position * Flat	

				-- // Root And Camera
				Camera.CFrame = self.Turn * self:GetHeadlockedCFrame()

				local CameraAngle = self:GetLookAngle(Camera:GetRenderCFrame())
				local RootAngle = self:GetLookAngle(Character.HumanoidRootPart.CFrame)
				local Rotation = CFrame.fromEulerAnglesXYZ(0, CameraAngle, 0)
				Character.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position + MoveVector * Scale) * Rotation


				local BaseHeight = (Character.Torso.Size.Y+Character.Head.Size.Y)/2
				local Height = HeadCFrame.Y*Scale
				local HeightPosition = (Character.HumanoidRootPart.CFrame * CFrame.new(0,BaseHeight + math.clamp(Height, -2, 0.25),0)).p

				Camera.CFrame = CFrame.new(HeightPosition) * self.Turn * self:GetHeadlockedCFrame()
				Players.LocalPlayer:Move(self:VectorToCameraYSpace(self.MoveVector))






				-- // Torso


				-- // Hands and neck
				local RightHandOffset = self:ScaleCFrame(RightCFrame, Scale) * self.HandRotation * CFrame.new(0, 2/3, 0)
				local LeftHandOffset = self:ScaleCFrame(LeftCFrame, Scale) * self.HandRotation * CFrame.new(0, 2/3, 0)
				
				
				-- // Set things up for next update
				self.LastUserCFrame = HeadCFrame
				self:HideHats()

				self:UpdateChat(Delta)
			else
				self:EndUpdating()
			end
		end)

		self.Stepped = RunService.Stepped:Connect(function()
			local Character = self:GetCharacter()

			if Character then
				local IsClimbing = Character.Humanoid:GetState() == Enum.HumanoidStateType.Climbing

				Character.Torso.CanCollide = false
				Character.Head.CanCollide = not IsClimbing

				Character.HumanoidRootPart.CanCollide = true
			end
		end)
	end
	
	function self:EndUpdating()
		self:Disconnect(RunString, "RunBind")
		self:EndInputs()
		self.Stepped = self:Disconnect(self.Stepped)

		if self.CurrentSolver then
			self.CurrentSolver:Terminate()
			self.CurrentSolver = nil
		end
	end
end


return RunModule.New