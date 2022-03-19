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
		local Enabled = true
		
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
				self.VirtualBody.HumanoidRootPart.CFrame = CFrame.new(self.VirtualBody.HumanoidRootPart.Position + MoveVector * Scale) * Rotation


				local BaseHeight = (Character.Torso.Size.Y+Character.Head.Size.Y)/2
				local Height = HeadCFrame.Y*Scale
				local HeightPosition = (self.VirtualBody.HumanoidRootPart.CFrame * CFrame.new(0,BaseHeight + math.clamp(Height, -2, 0.25),0)).p

				Camera.CFrame = CFrame.new(HeightPosition) * self.Turn * self:GetHeadlockedCFrame()
				self.VirtualBody.Humanoid:Move(self:VectorToCameraYSpace(self.MoveVector))
				
				
				

				-- // Hands
				local RightHandOffset = self:ScaleCFrame(RightCFrame, Scale) * self.HandRotation * CFrame.new(0, 2/3, 0)
				local LeftHandOffset = self:ScaleCFrame(LeftCFrame, Scale) * self.HandRotation * CFrame.new(0, 2/3, 0)
				
				local RightHandCFame = Camera.CFrame * RightHandOffset
				local LeftHandCFrame = Camera.CFrame * LeftHandOffset
				
				self.MoveRightArm(RightHandCFame)
				self.MoveLeftArm(LeftHandCFrame)
				
				self.VirtualRig.RightHand.CFrame = RightHandCFame
				self.VirtualRig.LeftHand.CFrame = LeftHandCFrame
				self.VirtualRig.RightHand.Anchored = true
				self.VirtualRig.LeftHand.Anchored = true
				
				-- // Torso
				Character.HumanoidRootPart.CFrame = self.VirtualRig.UpperTorso.CFrame
				self.Anchor.Velocity = self.VirtualBody.HumanoidRootPart.Velocity
				
				local RootPosition = self.VirtualRig.UpperTorso.CFrame
				self.MoveTorso(RootPosition * CFrame.new(0, -0.25, 0))
				self.MoveRoot(RootPosition * CFrame.new(0, -0.25, 0))
				
				
				-- // Legs
				do -- // Right leg
					local Positioning =
						self.VirtualRig.RightLowerLeg.CFrame:Lerp(self.VirtualRig.RightFoot.CFrame, 0.5) *
						CFrame.Angles(0, math.rad(180), 0) +
						Vector3.new(0, 0.5, 0)
					self.MoveRightLeg(Positioning)
				end
				do -- // Left leg
					local Positioning =
						self.VirtualRig.LeftLowerLeg.CFrame:Lerp(self.VirtualRig.LeftFoot.CFrame, 0.5) *
						CFrame.Angles(0, math.rad(180), 0) +
						Vector3.new(0, 0.5, 0)
					self.MoveLeftLeg(Positioning)
				end
				
				
				-- // Head
				self.MoveHead(self:ScaleCFrame(HeadCFrame, Scale))
				
				
				
				
				
				
				-- // Set things up for next update
				self.LastUserCFrame = HeadCFrame
				self:HideHats()

				--self:UpdateChat(Delta)
			else
				self:EndUpdating()
				Enabled = false
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
		
		
		coroutine.wrap(function()
			while Enabled do
				self:FootYield()
				self:UpdateFooting()
				RunService.RenderStepped:Wait()
			end
		end)()
	end
	
	function self:EndUpdating()
		self:Disconnect(RunString, "RunBind")
		self:EndInputs()
		self.Stepped = self:Disconnect(self.Stepped)
	end
end


return RunModule.New