local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


local Footing = {}
local FootPlacementSettings = {
	RightOffset = Vector3.new(.5, 0, 0),
	LeftOffset = Vector3.new(-.5, 0, 0)
}



function Footing.New(self)
	local FootUpdateDebounce = tick()
	
	function self:FloorRay(Part, Distance)
		local Position = Part.CFrame.p
		local Target = Position - Vector3.new(0, Distance, 0)
		local Line = Ray.new(Position, (Target - Position).Unit * Distance)
		local FloorPart, FloorPosition, FloorNormal =
			workspace:FindPartOnRayWithIgnoreList(Line, self.RayIgnore)
		if FloorPart then
			return FloorPart, FloorPosition, FloorNormal, (FloorPosition - Position).Magnitude
		else
			return nil, Target, Vector3.new(), Distance
		end
	end
	
	function self:Flatten(CF)
		local X, Y, Z = CF.X, CF.Y, CF.Z
		local LX, LZ = CF.lookVector.X, CF.lookVector.Z
		return CFrame.new(X, Y, Z) * CFrame.Angles(0, math.atan2(LX, LZ), 0)
	end
	
	function self:FootReady(Foot, Target)
		local MaxDist
		if Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
			MaxDist = .5
		else
			MaxDist = 1
		end
		local PastThreshold = (Foot.Position - Target.Position).Magnitude > MaxDist
		local PastTick = tick() - FootUpdateDebounce >= 2
		if PastThreshold or PastTick then
			FootUpdateDebounce = tick()
		end
		return PastThreshold or PastTick
	end
	
	function self:FootYield()
		local RightFooting = self.VirtualRig.RightFoot.BodyPosition
		local LeftFooting = self.VirtualRig.LeftFoot.BodyPosition
		local LowerTorso = self.VirtualRig.LowerTorso
		local Yield = tick()
		repeat
			RunService.RenderStepped:Wait()
			if
				(LowerTorso.Position - RightFooting.Position).Y > 4 or
				(LowerTorso.Position - LeftFooting.Position).Y > 4 or
				((LowerTorso.Position - RightFooting.Position) * Vector3.new(1, 0, 1)).Magnitude > 4 or
				((LowerTorso.Position - LeftFooting.Position) * Vector3.new(1, 0, 1)).Magnitude > 4
			then
				break
			end
		until tick() - Yield >= .17
	end
	
	function self:UpdateFooting()
		if not self.VirtualRig:FindFirstChild("LowerTorso") then
			RunService.RenderStepped:Wait()
			return
		end
		--local MoveDirection = AngledVector(LeftThumbstick)
		local Floor, FloorPosition, FloorNormal, Dist = self:FloorRay(self.VirtualRig.LowerTorso, 3)
		Dist = math.clamp(Dist, 0, 5)
		local FootTarget =
			self.VirtualRig.LowerTorso.CFrame * CFrame.new(FootPlacementSettings.RightOffset) - Vector3.new(0, Dist, 0) +
			self.VirtualBody.Humanoid.MoveDirection * (self.VirtualBody.Humanoid.WalkSpeed / 8) * 2
		if self:FootReady(self.VirtualRig.RightFoot, FootTarget) then
			self.VirtualRig.RightFoot.BodyPosition.Position = FootTarget.p
			self.VirtualRig.RightFoot.BodyGyro.CFrame = self:Flatten(self.VirtualRig.LowerTorso.CFrame)
		end
		self:FootYield()
		local FootTarget =
			self.VirtualRig.LowerTorso.CFrame * CFrame.new(FootPlacementSettings.LeftOffset) - Vector3.new(0, Dist, 0) +
			self.VirtualBody.Humanoid.MoveDirection * (self.VirtualBody.Humanoid.WalkSpeed / 8) * 2
		if self:FootReady(self.VirtualRig.LeftFoot, FootTarget) then
			self.VirtualRig.LeftFoot.BodyPosition.Position = FootTarget.p
			self.VirtualRig.LeftFoot.BodyGyro.CFrame = self:Flatten(self.VirtualRig.LowerTorso.CFrame)
		end
	end
end


return Footing.New