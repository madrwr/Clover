local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")

local Camera = workspace.CurrentCamera


local Functions = {}



function Functions.New(self)
	function self:ScaleCFrame(CF, Scale)
		return CFrame.new(CF.Position * Scale) * CFrame.fromEulerAnglesXYZ(CF:ToEulerAnglesXYZ())
	end

	function self:GetUserCFrames()
		local HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		local RightCFrame = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
		local LeftCFrame = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)	

		return HeadCFrame, RightCFrame, LeftCFrame
	end

	function self:GetRotation(CF)
		return CFrame.fromEulerAnglesXYZ(CF:ToEulerAnglesXYZ())
	end

	function self:GetHeadlockedCFrame()
		local UserCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
		UserCFrame = self:ScaleCFrame(UserCFrame, Camera.HeadScale)

		return CFrame.fromEulerAnglesXYZ(UserCFrame:ToEulerAnglesXYZ()) * UserCFrame:Inverse()
	end

	function self:GetLookAngle(CF)
		local LookVector = CF.LookVector
		local LookVector2 = Vector3.new(LookVector.X, 0, LookVector.Z).Unit
		local Atan2 = math.atan2(-LookVector2.Z, LookVector2.X) - math.pi/2

		return Atan2
	end

	function self:HideHats()
		local Character = self:GetCharacter()
		
		for Index, Inst in pairs(Character:GetChildren()) do
			if Inst:IsA("Accessory") then
				local Handle = Inst:FindFirstChildOfClass("Part")
				Handle.LocalTransparencyModifier = 1
			end
		end
	end
	
	function self:Lerp(A, B, C)
		return A + (B - A) * C
	end
	
	function self:VectorToCameraYSpace(Vector)
		local CameraLook = Camera:GetRenderCFrame().LookVector
		local AtanAngle = math.atan2(-CameraLook.X, -CameraLook.Z)
		local Angle = CFrame.fromEulerAnglesXYZ(0, AtanAngle, 0)
						
		return (Angle*CFrame.new(Vector)).Position
	end
	
	function self:Disconnect(NameOrEvent, Type)
		if typeof(NameOrEvent) == "RBXScriptConnection" then
			NameOrEvent:Disconnect()
			return nil
		else
			if Type == "RunBind" then
				local RunService = game:GetService("RunService")

				pcall(function()
					RunService:UnbindFromRenderStep(NameOrEvent)
				end)
			elseif Type == "Input" then
				local ContextActionService = game:GetService("ContextActionService")

				pcall(function()
					ContextActionService:UnbindAction(NameOrEvent)
				end)
			else
				warn(Type, "is not a valid Disconnect type : EventConnection, RunBind, Input")
			end
		end
	end
end


return Functions.New
