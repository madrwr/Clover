local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Camera = workspace.CurrentCamera

local ChatModule = {}


local ChatFrameOBJV = Instance.new("ObjectValue", script)



function GetModule(Path)
	local MainPath = "https://raw.githubusercontent.com/madrwr/Clover"
	local Module =  loadstring(game:HttpGetAsync(MainPath.. Path.. ".lua"))()
	return Module
end



function ChatModule.New(self)
	local Chat = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ChatScript"):WaitForChild("ChatMain"))
	local Keyboard = GetModule(nil)
	
	
	function self:NewGui()
		local Tbl = {}

		local SurfaceGui = Instance.new("SurfaceGui")
		SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
		SurfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		SurfaceGui.ResetOnSpawn = false
		SurfaceGui.Active = false
		SurfaceGui.AlwaysOnTop = true
		SurfaceGui.Name = game:GetService("HttpService"):GenerateGUID(false)

		SurfaceGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		SurfaceGui.Face = "Back"


		Tbl.SurfaceGui = SurfaceGui
		Tbl.CanvasSize = Vector2.new(1000,1000)
		Tbl.FieldOfView = math.rad(50)

		return Tbl
	end
	
	function self:MoveChat(Parent)
		local ChatFrame:Frame
		
		if self.ChatFrameOBJV and self.ChatFrameOBJV.Value then
			ChatFrame = self.ChatFrameOBJV.Value
		else
			local ChatWindow = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Chat")
			while #ChatWindow:GetChildren() == 0 do wait() end
			ChatFrame = ChatWindow:FindFirstChildOfClass("Frame")
		end
		
		
		self.PreviousChatSize = ChatFrame.Size
		ChatFrame.Size = UDim2.new(1,0,1,0)
		ChatFrame.Parent = Parent
		ChatFrame.Active = false
		
		for Index, Thing in pairs(ChatFrame:GetDescendants()) do
			pcall(function()
				Thing.Active = false
			end)
		end
		
		ChatFrameOBJV.Value = ChatFrame
	end
	
	function self:NewChatParent(Adornee)
		coroutine.wrap(function()
			local NewGui = self:NewGui()
			self.ChatParent = NewGui.SurfaceGui
			self.ChatFrameOBJV = ChatFrameOBJV
			
			if not Adornee then
				Adornee = Instance.new("Part")
				Adornee.Anchored = true
				Adornee.CanCollide = false
				Adornee.Transparency = 1
				
				Adornee.Parent = Camera
			end
			
			
			NewGui.SurfaceGui.Adornee = Adornee
			NewGui.CanvasSize = Vector2.new(750,750)
			
			self:MoveChat(self.ChatParent)
			
			
			
			self.ShowChatUI = true			
			ContextActionService:BindAction("VRChatInput", function(Name, State, Input)
				if State == Enum.UserInputState.Begin then
					local Character = self:GetCharacter()
					
					if Character and Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
						if Input.KeyCode == Enum.KeyCode.ButtonY then
							self.ShowChatUI = not self.ShowChatUI
						end

						if (Input.KeyCode == Enum.KeyCode.ButtonB or Input.KeyCode == Enum.KeyCode.Slash) and self:GetCharacter() then
							RunService.Stepped:Wait()
							Chat:FocusChatBar()
						end
					end
				end
			end, false, Enum.KeyCode.ButtonY, Enum.KeyCode.ButtonB, Enum.KeyCode.Slash)
			

			self:UpdateSize(NewGui)
		end)()
	end
	
	
	function self:UpdateSize(Tbl)
		Tbl = Tbl or {}

		if Tbl.SurfaceGui then
			local Gui = Tbl.SurfaceGui
			local CanvasSize = Tbl.CanvasSize or Vector2.new(1000,1000)
			local FieldOfView = Tbl.FieldOfView or math.rad(50)
			local Depth = 5



			local Width = 2 * math.tan(FieldOfView/2) * Depth
			if CanvasSize.Y <= CanvasSize.X then
				Gui.Adornee.Size = Vector3.new(Width,Width * (CanvasSize.Y/CanvasSize.X),0)
			else
				Gui.Adornee.Size = Vector3.new(Width * (CanvasSize.X/CanvasSize.Y),Width,0)
			end
			Gui.CanvasSize = CanvasSize
		end
	end
	
	function self:ForceExitChat()
		Keyboard.ForceExit:Fire()
	end

	function self:UpdateChat(Delta)
		if self.ChatParent and self.ChatParent.Adornee then
			local CameraCFrame = Camera:GetRenderCFrame()
			local NewRotation = self.ChatParent.Adornee.CFrame:Lerp(CameraCFrame, 0.2 * Delta * 60)
			NewRotation = NewRotation - NewRotation.Position

			self.ChatParent.Adornee.CFrame = CFrame.new(CameraCFrame.Position) * NewRotation * CFrame.new(0, 0, -5)
			Chat:SetVisible(not Chat:IsFocused() and self.ShowChatUI)
		end
	end
end


return ChatModule.New