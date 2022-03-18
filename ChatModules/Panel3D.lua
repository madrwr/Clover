local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Parent = Player:WaitForChild("PlayerGui")

local Utility = require(script.Parent:WaitForChild("Utility"))

--Panel3D State variables
local DefaultPixelsPerStud = 128
local ZeroVector = Vector3.new(0, 0, 0)
local ZeroVector2 = Vector2.new(0, 0)
local PartThickness = 0.2

--The default origin CFrame for all Standard type Panels
local Normal = Vector3.new(0, -0.5, -5.5)
local StandardOriginCF = CFrame.new(Normal)

--Compensates for the thickness of the Panel part and rotates it so that
--the front face is pointing back at the camera
local PanelAdjustCF = CFrame.new(0, 0, -0.5 * PartThickness) * CFrame.Angles(0, math.pi, 0) 

local CursorHidden = true

local CurrentModal = nil
local LastModal = nil
local CurrentMaxDist = math.huge
local CurrentClosest = nil
local CurrentCursorParent = nil
local CurrentCursorPos = ZeroVector2
local LastClosest = nil
local CurrentHeadScale = 1
local Panels = {}
local Cursor = Instance.new("ImageLabel")
Cursor.Image = "rbxasset://textures/Cursors/Gamepad/Pointer.png"
Cursor.Size = UDim2.new(0, 8, 0, 8)
Cursor.BackgroundTransparency = 1
Cursor.ZIndex = 1e9


local PartFolder = Instance.new("Folder",workspace.CurrentCamera)
PartFolder.Name = "BootlegVRCoreStuff"


--Panel3D Declaration and enumerations
local Panel3D = {}
Panel3D.Type = {
	None = 0,
	Standard = 1,
	Fixed = 2,
	HorizontalFollow = 3,
	FixedToHead = 4
}

Panel3D.OnPanelClosed = Instance.new("BindableEvent")

function MultiplyCFrame(CF, x)
	local Rotation = CF - CF.Position
	local NewPosition = CF.Position * x
	
	return CFrame.new(NewPosition) * Rotation
end

function Panel3D.GetHeadLookXZ(withTranslation)
	local userHeadCF = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local headLook = userHeadCF.lookVector
	local headYaw = math.atan2(-headLook.Z, headLook.X) - math.rad(90)
	local CF = CFrame.Angles(0, headYaw, 0)

	if withTranslation then
		CF = CF + userHeadCF.p
	end
	return CF
end

function Panel3D.FindContainerOf(element)
	for _, Panel in pairs(Panels) do
		if Panel.Gui and Panel.Gui:IsAncestorOf(element) then
			return Panel
		end
		for _, SubPanel in pairs(Panel.SubPanels) do
			if SubPanel.gui and SubPanel.gui:IsAncestorOf(element) then
				return Panel
			end
		end
	end
	return nil
end

function Panel3D.SetModalPanel(Panel)
	if CurrentModal == Panel then
		return
	end
	if CurrentModal then
		CurrentModal:OnModalChanged(false)
	end
	if Panel then
		Panel:OnModalChanged(true)
	end
	lastModal = CurrentModal
	CurrentModal = Panel
end

function Panel3D.ChangeOffset(Scale)
	StandardOriginCF = CFrame.new(Normal * Scale)
end

function RayPlaneIntersection(RayCast, PlaneNormal, PointOnPlane)
	PlaneNormal = PlaneNormal.Unit
	RayCast = RayCast.Unit

	local PlaneDot = PlaneNormal:Dot(RayCast.Direction)
	if PlaneDot == 0 then
		return nil
	end

	local OriginDot = PlaneNormal:Dot(PointOnPlane - RayCast.Origin)
	local Dot = OriginDot / PlaneDot
	if Dot < 0 then
		return nil
	end

	return RayCast.Origin + RayCast.Direction * Dot
end

function Panel3D.RaycastOntoPanel(Part, ParentGui, Gui, RayCast)
	local InstanceSize = Part.Size
	local InstanceThickness = InstanceSize.Z
	local InstanceWidth = InstanceSize.X
	local InstanceHeight = InstanceSize.Y

	local PlanceCFrame = Part:GetRenderCFrame()
	local PlaneNormal = PlanceCFrame.lookVector
	local PointOnPlane = PlanceCFrame.p + (PlaneNormal * InstanceThickness * 0.5)



	local WorldIntersectPoint = RayPlaneIntersection(RayCast, PlaneNormal, PointOnPlane)
	if WorldIntersectPoint then
		local ParentWidth, parentGuiHeight = ParentGui.AbsoluteSize.X, ParentGui.AbsoluteSize.Y
		local LocalIntersectPoint = PlanceCFrame:pointToObjectSpace(WorldIntersectPoint) * Vector3.new(-1, 1, 1) + Vector3.new(InstanceWidth / 2, -InstanceHeight / 2, 0)
		local PixelLook = Vector2.new((LocalIntersectPoint.X / InstanceWidth) * ParentWidth, (LocalIntersectPoint.Y / InstanceHeight) * -parentGuiHeight)


		return WorldIntersectPoint, LocalIntersectPoint, PixelLook, true
	else
		return nil, nil, nil, false
	end
end

function GetDebrisFolder()
	local Lighting = game:GetService("Lighting")
	local Folder = Lighting:FindFirstChild("PanelDebris")
	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = "PanelDebris"
		Folder.Parent = Lighting
	end
	
	return Folder
end

--End of Panel3D Declaration and enumerations

--Panel class implementation
local Panel = {}
Panel.__index = Panel
function Panel.new(Name)
	local self = {}
	self.Name = Name

	self.Part = false
	self.Gui = false

	self.width = 1
	self.height = 1

	self.IsVisible = false
	self.IsEnabled = false
	self.PanelType = Panel3D.Type.Standard
	self.PixelScale = 1
	
	
	self.SubPanels = {}

	self.Transparency = 1
	self.IsLookedAt = false
	self.IsOffscreen = true
	self.LookAtPixel = Vector2.new(-1, -1)
	self.CursorPos = Vector2.new(-1, -1)
	self.LookAtDistance = math.huge
	self.LookAtGuiElement = false
	self.IsClosest = true
	
	self.DrawCursor = true

	self.LocalCF = CFrame.new()
	self.AngleFromHorizon = CFrame.Angles(0, 0, 0)
	self.AngleFromForward = CFrame.Angles(0, 0, 0)
	self.Distance = 5

	if Panels[Name] then
		error("A Panel by the name of " .. Name .. " already exists.")
	end
	Panels[Name] = self

	return setmetatable(self, Panel)
end

--Panel accessor methods
function Panel:GetPart()
	if not self.Part then
		self.Part = Instance.new("Part")
		self.Part.Name = self.Name
		self.Part.Parent = PartFolder

		self.Part.Transparency = 1

		self.Part.CanCollide = false
		self.Part.Anchored = true

		self.Part.Size = Vector3.new(1, 1, PartThickness)
	end
	return self.Part
end

function Panel:GetGui()
	if not self.Gui then
		local Part = self:GetPart()
		self.Gui = Instance.new("SurfaceGui", Parent)
		self.Gui.Name = self.Name
		self.Gui.Archivable = false
		self.Gui.Adornee = Part
		self.Gui.ToolPunchThroughDistance = 1000
		self.Gui.CanvasSize = self.CanvasSize or Vector2.new(0, 0)
		self.Gui.Enabled = self.IsEnabled
		self.Gui.AlwaysOnTop = true
		self.Gui.ResetOnSpawn = false
		
	end
	return self.Gui
end

function Panel:FindHoveredGuiElement(elements)
	local x, y = self.lookAtPixel.X, self.lookAtPixel.Y
	for i, v in pairs(elements) do
		local minPt = v.AbsolutePosition
		local maxPt = v.AbsolutePosition + v.AbsoluteSize
		if minPt.X <= x and maxPt.X >= x and
			minPt.Y <= y and maxPt.Y >= y then
			return v, i
		end
	end
end
--End of Panel accessor methods


--Panel update methods
function Panel:SetPartCFrame(CFrame)
	self:GetPart().CFrame = CFrame * PanelAdjustCF
end

function Panel:SetEnabled(Enabled)
	self.IsEnabled = Enabled
	self:GetPart().Parent = Enabled and PartFolder or GetDebrisFolder()
	self:GetGui().Enabled = Enabled
end

function Panel:EvaluatePositioning(cameraCF, cameraRenderCF, userHeadCF)
	if self.PanelType == Panel3D.Type.Fixed then
		local cf = self.LocalCF - self.LocalCF.p
		cf = cf + (self.LocalCF.p * CurrentHeadScale)
		self:SetPartCFrame(cameraCF * cf)
	elseif self.PanelType == Panel3D.Type.HorizontalFollow then
		userHeadCF = MultiplyCFrame(userHeadCF, workspace.CurrentCamera.HeadScale)
		local headLook = userHeadCF.lookVector
		local headForwardCF = CFrame.new(userHeadCF.p, userHeadCF.p + (headLook * Vector3.new(1, 0, 1)))
		local LocalCF = (headForwardCF * self.AngleFromForward) *
			self.AngleFromHorizon * --Rotate about X (up-down)
			CFrame.new(0, 0, CurrentHeadScale * -self.Distance)
		self:SetPartCFrame(cameraCF * LocalCF)
	elseif self.PanelType == Panel3D.Type.FixedToHead then
		local cf = self.LocalCF - self.LocalCF.p
		cf = cf + (self.LocalCF.p * CurrentHeadScale)
		self:SetPartCFrame(cameraRenderCF * cf)
	elseif self.PanelType == Panel3D.Type.Standard then
		self:SetPartCFrame(cameraCF * self.originCF * self.LocalCF)
	end
end

function Panel:SetLookedAt(lookedAt)
	if not self.IsLookedAt and lookedAt then
		self.IsLookedAt = true
	elseif self.IsLookedAt and not lookedAt then
		self.IsLookedAt = false
	end
end

function Panel:EvaluateGaze(cameraCF, cameraRenderCF, userHeadCF, lookRay, pointerRay)
	--reset Distance data
	self.IsClosest = false
	self.LookAtPixel = ZeroVector2
	self.LookAtDistance = math.huge



	local Gui = self:GetGui()
	local WorldIntersectPoint, localIntersectPoint, GuiPixelHit, isOnGui = Panel3D.RaycastOntoPanel(self:GetPart(), Gui, Gui, pointerRay)
	if WorldIntersectPoint then
		self.IsOffscreen = false


		self.lookAtPixel = GuiPixelHit
		self.CursorPos = GuiPixelHit
		
		currentCursorParent = self.Gui
		currentCursorPos = self.CursorPos
		
		self.LookAtDistance = (WorldIntersectPoint - cameraRenderCF.p).magnitude
		CurrentMaxDist = self.LookAtDistance
		CurrentClosest = self
	else
		self.IsOffscreen = true
		self.IsLookedAt = false
	end
end

function Panel:EvaluateTransparency()
	self.Transparency = 0
end

function Panel:Update(cameraCF, cameraRenderCF, userHeadCF, lookRay, pointerRay)
	if self.IsVisible then
		self:EvaluatePositioning(cameraCF, cameraRenderCF, userHeadCF)
		for i, v in pairs(self.SubPanels) do
			v:Update()
		end
		
		self:EvaluateGaze(cameraCF, cameraRenderCF, userHeadCF, lookRay, pointerRay)

		self:EvaluateTransparency(cameraCF, cameraRenderCF)
	end
end



--Panel configuration methods
function Panel:ResizeStuds(width, height, pixelsPerStud)
	pixelsPerStud = pixelsPerStud or DefaultPixelsPerStud

	self.width = width
	self.height = height

	self.PixelScale = pixelsPerStud / DefaultPixelsPerStud

	local Part = self:GetPart()
	Part.Size = Vector3.new(self.width * CurrentHeadScale, self.height * CurrentHeadScale, PartThickness)
	local Gui = self:GetGui()
	Gui.CanvasSize = Vector2.new(pixelsPerStud * self.width, pixelsPerStud * self.height)

	for i, v in pairs(self.SubPanels) do
		if v.Part then
			v.Part.Size = Part.Size
		end
		if v.Gui then
			v.Gui.CanvasSize = Gui.CanvasSize
		end
	end
end

function Panel:ResizePixels(width, height, pixelsPerStud)
	pixelsPerStud = pixelsPerStud or DefaultPixelsPerStud

	local widthInStuds = width / pixelsPerStud
	local heightInStuds = height / pixelsPerStud
	self:ResizeStuds(widthInStuds, heightInStuds, pixelsPerStud)
end

function Panel:OnHeadScaleChanged(newHeadScale)
	local pixelsPerStud = self.PixelScale * DefaultPixelsPerStud
	self:ResizeStuds(self.width, self.height, pixelsPerStud)
end

function Panel:SetType(PanelType, config)
	self.PanelType = PanelType
	--clear out old type-specific members

	self.LocalCF = CFrame.new()

	self.AngleFromHorizon = false
	self.AngleFromForward = false
	self.Distance = false

	if not config then
		config = {}
	end

	if PanelType == Panel3D.Type.None then
		--nothing to do
		return
	elseif PanelType == Panel3D.Type.Standard then
		self.LocalCF = config.CFrame or CFrame.new()
	elseif PanelType == Panel3D.Type.Fixed then
		self.LocalCF = config.CFrame or CFrame.new()
	elseif PanelType == Panel3D.Type.HorizontalFollow then
		self.AngleFromHorizon = CFrame.Angles(config.AngleFromHorizon or 0, 0, 0)
		self.AngleFromForward = CFrame.Angles(0, config.AngleFromForward or 0, 0)
		self.Distance = config.Distance or 5
	elseif PanelType == Panel3D.Type.FixedToHead then
		self.LocalCF = config.CFrame or CFrame.new()
	else
		error("Invalid Panel type")
	end
end

function Panel:SetVisible(visible, modal)
	if visible ~= self.IsVisible then
		if not visible then
			Panel3D.OnPanelClosed:Fire(self.Name)
		else
			local headLookXZ = Panel3D.GetHeadLookXZ(true)
			self.originCF = headLookXZ * StandardOriginCF
		end
	end
	
	if visible then
		CursorHidden = self.DrawCursor
	end
	
	self.IsVisible = visible
	self:SetEnabled(visible)
	if visible and modal then
		Panel3D.SetModalPanel(self)
	end
	if not visible and CurrentModal == self then
		if modal then
			--restore last modal Panel
			Panel3D.SetModalPanel(lastModal)
		else
			Panel3D.SetModalPanel(nil)

			--if the coder explicitly wanted to hide this modal Panel,
			--it follows that they don't want it to be restored when the next
			--modal Panel is hidden.
			if lastModal == self then
				lastModal = nil
			end
		end
	end

	if not visible and self.forceShowUntilLookedAt then
		self.forceShowUntilLookedAt = false
	end
end

function Panel:IsVisible()
	return self.IsVisible
end

function Panel:GetGuiPositionInPanelSpace(GuiPosition)
	local PartSize = Vector2.new(self.Part.Size.X, self.Part.Size.Y)
	local GuiSize = self.Gui.AbsoluteSize
	local GuiCenter = GuiSize / 2

	local GuiPositionFraction = (GuiPosition - GuiCenter) / GuiSize
	local PositionInPartFace = GuiPositionFraction * PartSize

	return Vector3.new(PositionInPartFace.X, PositionInPartFace.Y, PartThickness * 0.5)
end

function Panel:GetCFrameInCameraSpace()
	if self.PanelType == Panel3D.Type.Standard then
		return self.originCF * self.LocalCF
	else
		return self.LocalCF or CFrame.new()
	end
end

--Child class, SubPanel
local SubPanel = {}
SubPanel.__index = SubPanel
function SubPanel.new(parentPanel, GuiElement)
	local self = {}
	self.parentPanel = parentPanel
	self.GuiElement = GuiElement
	self.lastParent = GuiElement.Parent
	self.ancestryConn = nil
	self.changedConn = nil

	self.lookAtPixel = Vector2.new(-1, -1)
	self.CursorPos = Vector2.new(-1, -1)
	self.lookedAt = false

	self.IsEnabled = true

	self.Part = nil
	self.Gui = nil
	self.GuiSurrogate = nil

	self.DepthOffset = 0
	self.DefaultDensity = 128

	setmetatable(self, SubPanel)


	self:GetGui()
	self:UpdateSurrogate()
	self:WatchParent(self.lastParent)

	GuiElement.Parent = self.GuiSurrogate

	local function ancestryCallback(parent, child)
		self:GetGui().Enabled = self.parentPanel:GetGui():IsAncestorOf(self.lastParent)
		if not self:GetGui().Enabled then
			self:GetPart().Parent = nil
		else
			self:GetPart().Parent = workspace.CurrentCamera
		end
		if child == GuiElement then
			--disconnect the event because we're going to move this element
			self.ancestryConn:disconnect()

			self.lastParent = GuiElement.Parent
			GuiElement.Parent = self.GuiSurrogate
			self:WatchParent(self.lastParent)

			--reconnect it
			self.ancestryConn = GuiElement.AncestryChanged:connect(ancestryCallback)
		end
	end
	self.ancestryConn = GuiElement.AncestryChanged:connect(ancestryCallback)

	return self
end

function SubPanel:Cleanup()
	self.GuiElement.Parent = self.lastParent
	if self.Part then
		self.Part:Destroy()
		self.Part = nil
	end
	spawn(function()
		wait() --wait so anything that's in the Gui that doesn't want to be has time to get out (Panel Cursor for example)
		if self.Gui then
			self.Gui:Destroy()
			self.Gui = nil
		end
	end)
	if self.ancestryConn then
		self.ancestryConn:disconnect()
		self.ancestryConn = nil
	end
	if self.changedConn then
		self.changedConn:disconnect()
		self.changedConn = nil
	end
	self.lastParent = nil
	self.parentPanel = nil
	self.GuiElement = nil
	self.GuiSurrogate = nil
end

function SubPanel:SetLookedAt(lookedAt)
	self.lookedAt = lookedAt
end

function SubPanel:WatchParent(parent)
	if self.changedConn then
		self.changedConn:disconnect()
	end
	self.changedConn = parent.Changed:connect(function(prop)
		if prop == "AbsolutePosition" or prop == "AbsoluteSize" or prop == "Parent" then
			self:UpdateSurrogate()
		end
	end)
end

function SubPanel:UpdateSurrogate()
	local lastParent = self.lastParent
	self.GuiSurrogate.Position = UDim2.new(0, lastParent.AbsolutePosition.X, 0, lastParent.AbsolutePosition.Y)
	self.GuiSurrogate.Size = UDim2.new(0, lastParent.AbsoluteSize.X, 0, lastParent.AbsoluteSize.Y)
end

function SubPanel:GetPart()
	if self.Part then
		return self.Part
	end

	self.Part = self.parentPanel:GetPart():Clone()
	self.Part.Parent = PartFolder
	return self.Part
end

function SubPanel:GetGui()
	if self.Gui then
		return self.Gui
	end

	self.Gui = Instance.new("SurfaceGui")
	self.Gui.Parent = Parent
	self.Gui.Adornee = self:GetPart()
	self.Gui.ToolPunchThroughDistance = 1000
	self.Gui.CanvasSize = self.parentPanel:GetGui().CanvasSize
	self.Gui.Enabled = self.parentPanel.IsEnabled
	self.Gui.AlwaysOnTop = true
	self.GuiSurrogate = Instance.new("Frame")
	self.GuiSurrogate.Parent = self.Gui

	self.GuiSurrogate.Active = false

	self.GuiSurrogate.Position = UDim2.new(0, 0, 0, 0)
	self.GuiSurrogate.Size = UDim2.new(1, 0, 1, 0)

	self.GuiSurrogate.BackgroundTransparency = 1
	return self.Gui
end

function SubPanel:SetDepthOffset(offset)
	self.DepthOffset = offset
end

function SubPanel:Update()
	local Part = self:GetPart()
	local parentPart = self.parentPanel:GetPart()

	if Part and parentPart then
		Part.CFrame = parentPart.CFrame * CFrame.new(0, 0, -self.DepthOffset*workspace.CurrentCamera.HeadScale)
	end
end

function Panel:OnModalChanged(isModal)
end

function SubPanel:SetEnabled(Enabled)
	self.IsEnabled = Enabled
	self:GetPart().Parent = Enabled and PartFolder or nil
	self:GetGui().Enabled = Enabled
end

function SubPanel:GetEnabled()
	return self.IsEnabled
end

function SubPanel:GetPixelScale()
	return self.parentPanel:GetPixelScale()
end

function Panel:GetPixelScale()
	return self.PixelScale
end

function Panel:AddSubPanel(GuiElement)
	local SubPanel = SubPanel.new(self, GuiElement)
	self.SubPanels[GuiElement] = SubPanel
	return SubPanel
end

function Panel:RemoveSubPanel(GuiElement)
	local SubPanel = self.SubPanels[GuiElement]
	if SubPanel then
		SubPanel:Cleanup()
	end
	self.SubPanels[GuiElement] = nil
end

function Panel:SetSubPanelDepth(GuiElement, depth)
	local SubPanel = self.SubPanels[GuiElement]

	if depth == 0 then
		if SubPanel then
			self:RemoveSubPanel(GuiElement)
		end
		return nil
	end

	if not SubPanel then
		SubPanel = self:AddSubPanel(GuiElement)
	end
	SubPanel:SetDepthOffset(depth)

	return SubPanel
end

--End of Panel configuration methods
--End of Panel class implementation


--Panel3D API
function Panel3D.Get(Name)
	if not Panels[Name] then
		Panels[Name] = Panel.new(Name)
	end
	return Panels[Name]
end
--End of Panel3D API


--Panel3D Setup
function Panel3D.onRenderStep()
	CurrentClosest = nil
	CurrentMaxDist = math.huge

	--figure out some useful stuff
	local camera = workspace.CurrentCamera
	CurrentHeadScale = camera.HeadScale
	
	
	local cameraCF = camera.CFrame
	local cameraRenderCF = camera:GetRenderCFrame()
	local userHeadCF = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local lookRay = Ray.new(cameraRenderCF.p, cameraRenderCF.lookVector)

	local inputUserCFrame = VRService.GuiInputUserCFrame
	local inputCF = cameraCF * MultiplyCFrame(VRService:GetUserCFrame(inputUserCFrame), CurrentHeadScale)
	local pointerRay = Ray.new(inputCF.p, inputCF.lookVector)

	
	for i, v in pairs(Panels) do
		v:Update(cameraCF, cameraRenderCF, userHeadCF, lookRay, pointerRay)
	end


	for i, v in pairs(Panels) do
		if v.Part and v.Gui then
			v:SetEnabled(v.IsVisible)
			
			if v.IsVisible then
				v:ResizeStuds(v.width, v.height, v.DefaultDensity)
			end
		end
	end
	
	if CurrentClosest and CursorHidden then
		Cursor.Parent = currentCursorParent

		local x, y = currentCursorPos.X, currentCursorPos.Y
		local PixelScale = CurrentClosest:GetPixelScale()
		Cursor.Size = UDim2.new(0, (16 * PixelScale), 0, (16 * PixelScale))
		Cursor.Position = UDim2.new(0, x - Cursor.AbsoluteSize.x * 0.5, 0, y - Cursor.AbsoluteSize.y * 0.5)
	else
		Cursor.Parent = nil
	end
	LastClosest = CurrentClosest
end

do
	RunService.RenderStepped:Connect(Panel3D.onRenderStep)
end

return Panel3D