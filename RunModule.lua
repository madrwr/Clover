local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local Camera = workspace.CurrentCamera
local Flat = Vector3.new(1, 0, 1)

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local RunModule = {}
local RunString = "VRStep_RunModule"



function RunModule.New(self)
	local function OnUserCFrameChanged(UserCFrame, Positioning, IgnoreTorso)
		local Positioning = Camera.CFrame * Positioning
		if not IgnoreTorso then
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
		end
		if UserCFrame == Enum.UserCFrame.Head then
			self.MoveHead(Positioning)
		elseif UserCFrame == Enum.UserCFrame.RightHand then
			self.MoveRightArm(Positioning)
		elseif UserCFrame == Enum.UserCFrame.LeftHand then
			self.MoveLeftArm(Positioning)
		end
		if UserCFrame == Enum.UserCFrame.Head then
			self.VirtualRig.Head.CFrame = Positioning
		elseif UserCFrame == Enum.UserCFrame.RightHand then
			self.VirtualRig.RightHand.CFrame = Positioning
		elseif UserCFrame == Enum.UserCFrame.LeftHand then
			self.VirtualRig.LeftHand.CFrame = Positioning
		end
		
		if not self.VirtualRig.LeftHand.Anchored then
			self.VirtualRig.RightHand.Anchored = true
			self.VirtualRig.LeftHand.Anchored = true
		end
	end
	
	
	function self:StartUpdating()
		local Enabled = true
		
		RunService:BindToRenderStep(RunString, Enum.RenderPriority.Camera.Value - 1, function(Delta)
			local Character = self:GetCharacter()

			if Character then
				local HeadCFrame, RightCFrame, LeftCFrame = self:GetUserCFrames()
				local Scale = Camera.HeadScale
				
				Camera.CameraSubject = nil
				Camera.CameraType = Enum.CameraType.Scriptable


				-- // Movevector
				local UserCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
				local MoveDistance = self.Turn * CFrame.new(UserCFrame.Position - self.LastUserCFrame).Position * Vector3.new(1, 0, 1)

				local LookDirection = Camera:GetRenderCFrame().LookVector
				local LookAngle = math.atan2(-LookDirection.X, -LookDirection.Z)
				local RawPosition = self.VirtualBody.HumanoidRootPart.Position + MoveDistance
				self.VirtualBody.HumanoidRootPart.CFrame = CFrame.lookAt(RawPosition, RawPosition + CFrame.fromEulerAnglesXYZ(0, LookAngle, 0).LookVector)
				local RootPosition = CFrame.new(self.VirtualBody.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0))


				Camera.CFrame = (RootPosition * CFrame.new(0, UserCFrame.Y, 0) * self.Turn * self.GetHeadlockedCFrame())
				self.VirtualBody.Humanoid:Move(self:VectorToCameraYSpace(self.MoveVector), true)
				
				
				

				-- // Hands
				local RightHandOffset = self:ScaleCFrame(RightCFrame, Scale) * self.HandRotation * CFrame.new(0, 2/3, 0)
				local LeftHandOffset = self:ScaleCFrame(LeftCFrame, Scale) * self.HandRotation * CFrame.new(0, 2/3, 0)
				
				--local RightHandCFame = Camera.CFrame * RightHandOffset
				--local LeftHandCFrame = Camera.CFrame * LeftHandOffset
				
				--self.MoveRightArm(RightHandCFame)
				--self.MoveLeftArm(LeftHandCFrame)
				
				--self.VirtualRig.RightHand.CFrame = RightHandCFame
				--self.VirtualRig.LeftHand.CFrame = LeftHandCFrame
				--self.VirtualRig.RightHand.Anchored = true
				--self.VirtualRig.LeftHand.Anchored = true
				
				-- // Torso
				Character.HumanoidRootPart.CFrame = self.VirtualRig.UpperTorso.CFrame
				self.Anchor.Velocity = self.VirtualBody.HumanoidRootPart.Velocity
				OnUserCFrameChanged(Enum.UserCFrame.Head, self:ScaleCFrame(HeadCFrame, Scale))
				OnUserCFrameChanged(Enum.UserCFrame.RightHand, RightHandOffset, true)
				OnUserCFrameChanged(Enum.UserCFrame.LeftHand, LeftHandOffset, true)
				
				--local RootPosition = self.VirtualRig.UpperTorso.CFrame
				--self.MoveTorso(RootPosition * CFrame.new(0, -0.25, 0))
				--self.MoveRoot(RootPosition * CFrame.new(0, -0.25, 0))
				
				
				---- // Legs
				--do -- // Right leg
				--	local Positioning =
				--		self.VirtualRig.RightLowerLeg.CFrame:Lerp(self.VirtualRig.RightFoot.CFrame, 0.5) *
				--		CFrame.Angles(0, math.rad(180), 0) +
				--		Vector3.new(0, 0.5, 0)
				--	self.MoveRightLeg(Positioning)
				--end
				--do -- // Left leg
				--	local Positioning =
				--		self.VirtualRig.LeftLowerLeg.CFrame:Lerp(self.VirtualRig.LeftFoot.CFrame, 0.5) *
				--		CFrame.Angles(0, math.rad(180), 0) +
				--		Vector3.new(0, 0.5, 0)
				--	self.MoveLeftLeg(Positioning)
				--end
				
				
				-- // Head
				--self.MoveHead(Camera.CFrame * self:ScaleCFrame(HeadCFrame, Scale))
				--self.VirtualRig.Head.CFrame = Camera.CFrame * self:ScaleCFrame(HeadCFrame, Scale)
				
				
				
				
				
				-- // Set things up for next update
				self.LastUserCFrame = HeadCFrame.Position
				self:HideHats()

				self:UpdateChat(Delta)
			else
				self:EndUpdating()
				Enabled = false
			end
		end)

		self.Stepped = RunService.Stepped:Connect(function()
			local Character = self:GetCharacter()

			if Character then
				for _, Part in pairs(self.VirtualRig:GetChildren()) do
					if Part:IsA("BasePart") then
						Part.CanCollide = false
					end
				end
				
				for _, Part in pairs(Character:GetChildren()) do
					if Part:IsA("BasePart") then
						Part.CanCollide = false
					end
				end
			end
		end)
		
		spawn(function()
			while Enabled do
				self:FootYield()
				self:UpdateFooting()
			end
		end)
	end
	
	function self:EndUpdating()
		self:Disconnect(RunString, "RunBind")
		self:EndInputs()
		self.Stepped = self:Disconnect(self.Stepped)
	end
end


return RunModule.New