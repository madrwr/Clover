local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")


local Input = {}



function Input.New(self)
	function self:StartInputs()
		ContextActionService:BindAction("ThumbStick2", function(Name, State, Input)
			if not self.IsTurning and math.abs(Input.Position.X) > 0.7 then
				self.IsTurning = true

				local TurnDirection = self.TurnDeg * -math.sign(Input.Position.X)				
				self.Turn = self.Turn * CFrame.fromEulerAnglesXYZ(0, math.rad(TurnDirection), 0)
			elseif self.IsTurning and math.abs(Input.Position.X) < 0.7 then
				self.IsTurning = false
			end
		end, false, Enum.KeyCode.Thumbstick2)
		
		
		ContextActionService:BindAction("Movement", function(Name, State, Input)
			if State == Enum.UserInputState.Begin or State == Enum.UserInputState.Change then
				if Input.Position.Magnitude > 0.15 then
					self.MoveVector = Vector3.new(Input.Position.X, 0, -Input.Position.Y)
				else
					self.MoveVector = Vector3.new()
				end
			else
				self.MoveVector = Vector3.new()
			end
		end, false, Enum.KeyCode.Thumbstick1)
		
		ContextActionService:BindAction("Jump", function(Name, State, Input)
			if State == Enum.UserInputState.Begin then
				self.VirtualBody.Humanoid.Jump = true
			end
		end, false, Enum.KeyCode.ButtonA)
	end
	
	function self:EndInputs()
		self:Disconnect("ThumbStick2", "Input")
		self:Disconnect("Movement", "Input")
		self:Disconnect("Jump", "Input")
	end
end


return Input.New
