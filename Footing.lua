local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()

local FootUpdateDebounce = tick()
local FootPlacementSettings = {
	RightOffset = Vector3.new(.5, 0, 0),
	LeftOffset = Vector3.new(-.5, 0, 0)
}




return function (VirtualRig, VirtualBody, MoveRightLeg, MoveLeftLeg, RayIgnore)
	local function FloorRay(Part, Distance)
		local Position = Part.CFrame.p
		local Target = Position - Vector3.new(0, Distance, 0)
		local Line = Ray.new(Position, (Target - Position).Unit * Distance)
		local FloorPart, FloorPosition, FloorNormal =
			workspace:FindPartOnRayWithIgnoreList(Line, RayIgnore)
		if FloorPart then
			return FloorPart, FloorPosition, FloorNormal, (FloorPosition - Position).Magnitude
		else
			return nil, Target, Vector3.new(), Distance
		end
	end

	local function Flatten(CF)
		local X, Y, Z = CF.X, CF.Y, CF.Z
		local LX, LZ = CF.lookVector.X, CF.lookVector.Z
		return CFrame.new(X, Y, Z) * CFrame.Angles(0, math.atan2(LX, LZ), 0)
	end

	local function FootReady(Foot, Target)
		local MaxDist
		if Character.Humanoid.MoveDirection.Magnitude > 0 then
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

	local function FootYield()
		local RightFooting = VirtualRig.RightFoot.BodyPosition
		local LeftFooting = VirtualRig.LeftFoot.BodyPosition
		local LowerTorso = VirtualRig.LowerTorso
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

	local function UpdateFooting()
		if not VirtualRig:FindFirstChild("LowerTorso") then
			RunService.RenderStepped:Wait()
			return
		end
		--local MoveDirection = AngledVector(LeftThumbstick)
		local Floor, FloorPosition, FloorNormal, Dist = FloorRay(VirtualRig.LowerTorso, 3)
		Dist = math.clamp(Dist, 0, 5)
		local FootTarget =
			VirtualRig.LowerTorso.CFrame * CFrame.new(FootPlacementSettings.RightOffset) - Vector3.new(0, Dist, 0) +
			VirtualBody.Humanoid.MoveDirection * (VirtualBody.Humanoid.WalkSpeed / 8) * 2
		if FootReady(VirtualRig.RightFoot, FootTarget) then
			VirtualRig.RightFoot.BodyPosition.Position = FootTarget.p
			VirtualRig.RightFoot.BodyGyro.CFrame = Flatten(VirtualRig.LowerTorso.CFrame)
		end
		FootYield()
		local FootTarget =
			VirtualRig.LowerTorso.CFrame * CFrame.new(FootPlacementSettings.LeftOffset) - Vector3.new(0, Dist, 0) +
			VirtualBody.Humanoid.MoveDirection * (VirtualBody.Humanoid.WalkSpeed / 8) * 2
		if FootReady(VirtualRig.LeftFoot, FootTarget) then
			VirtualRig.LeftFoot.BodyPosition.Position = FootTarget.p
			VirtualRig.LeftFoot.BodyGyro.CFrame = Flatten(VirtualRig.LowerTorso.CFrame)
		end
	end

	local function UpdateLegPosition()
		do
			local Positioning =
				VirtualRig.RightLowerLeg.CFrame:Lerp(VirtualRig.RightFoot.CFrame, 0.5) *
				CFrame.Angles(0, math.rad(180), 0) +
				Vector3.new(0, 0.5, 0)
			MoveRightLeg.WorldCFrame = (Positioning)
		end
		do
			local Positioning =
				VirtualRig.LeftLowerLeg.CFrame:Lerp(VirtualRig.LeftFoot.CFrame, 0.5) *
				CFrame.Angles(0, math.rad(180), 0) +
				Vector3.new(0, 0.5, 0)
			MoveLeftLeg.WorldCFrame = (Positioning)
		end
	end



	return FloorRay, Flatten, FootReady, FootYield, UpdateFooting, UpdateLegPosition
end