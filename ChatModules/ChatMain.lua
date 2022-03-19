local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Camera = workspace.CurrentCamera

local ChatModule = {}

function GetModule(module)
	return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/madrwr/Clover/main/" .. module .. ".lua"))()
end



function ChatModule.New(self)
	local Chat = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ChatScript"):WaitForChild("ChatMain"))
	local Keyboard = GetModule("ChatModules/KeyBoard")
	
	
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
		local ChatWindow = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Chat")
		while #ChatWindow:GetChildren() == 0 do wait() end
		local ChatFrame = ChatWindow:FindFirstChildOfClass("Frame")
		ChatFrame.Size = UDim2.new(1,0,1,0)
		ChatFrame.Parent = Parent
		ChatFrame.Active = false
		
		for Index, Thing in pairs(ChatFrame:GetDescendants()) do
			if Thing:IsA("Frame") or Thing:IsA("ImageButton") or Thing:IsA("TextBox") or Thing:IsA("TextButton") or Thing:IsA("TextLabel") or Thing:IsA("ImageLabel") then
				Thing.Active = false
			end
		end
	end
	
	function self:NewChatParent(Adornee)
		local NewGui = self:NewGui()
		self.ChatParent = NewGui.SurfaceGui

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
				if Input.KeyCode == Enum.KeyCode.ButtonY then
					self.ShowChatUI = not self.ShowChatUI
				end

				if (Input.KeyCode == Enum.KeyCode.ButtonB or Input.KeyCode == Enum.KeyCode.Slash) and Character then
					RunService.Stepped:Wait()
					Chat:FocusChatBar()
				end
			end
		end, false, Enum.KeyCode.ButtonY, Enum.KeyCode.ButtonB, Enum.KeyCode.Slash)


		self:UpdateSize(NewGui)
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