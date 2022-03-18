local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera



function GetModule(module) --
	local path = "https://raw.githubusercontent.com/madrwr/Clover"
	local module =  loadstring(game:HttpGetAsync(path.. module.. ".lua"))()
	return module
end



function CreateStale()
	local Stale = Instance.new("Model", workspace)
	
	local Torso = Instance.new("Part", Stale)
	Torso.Name = "Torso"
	Torso.CanCollide = false
	Torso.Anchored = true
	
	local Head = Instance.new("Part", Torso)
	Head.Name = "Head"
	Head.Anchored = true
	Head.CanCollide = false
	
	local Humanoid = Instance.new("Humanoid", Torso)
	Humanoid.Name = "Humanoid"
	
	
	Torso.Position = Vector3.new(0, 9999, 0)
	Head.Position = Vector3.new(0, 9991, 0)
	
	
	
	return Stale
end

local Module = {}
Module.__index = Module



function Module.Permakill()
	local RealCharacter = Players.LocalPlayer.Character
	local StaleCharacter = CreateStale()
	Players.LocalPlayer.Character = StaleCharacter
	wait(game.Players.RespawnTime/2)
	warn("50%")
	Players.LocalPlayer.Character = RealCharacter
	wait(game.Players.RespawnTime/2 + 0.5)
	warn("100%")
end

function Module.Respawn()
	local RealCharacter = Players.LocalPlayer.Character
	local StaleCharacter = CreateStale()
	Players.LocalPlayer.Character = StaleCharacter
	wait(game.Players.RespawnTime)
	Players.LocalPlayer.Character = RealCharacter
end

function Module.PhysicsBypass() -- // Questionable
	settings().Physics.AllowSleep = false 
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end

function Module.CreateLegSockets(Model)
	local LeftAttachment = Instance.new("Attachment", Model["Left Leg"])
	LeftAttachment.Position = Vector3.new(0, 1, 0)
	
	local LeftHipAttachment = Instance.new("Attachment", Model["Torso"])
	LeftHipAttachment.Position = Vector3.new(-0.5, -1, 0)
	
	local LeftHipSocket = Instance.new("BallSocketConstraint", Model["Left Leg"])
	LeftHipSocket.Attachment0 = LeftAttachment
	LeftHipSocket.Attachment1 = LeftHipAttachment
	
	
	local RightAttachment = Instance.new("Attachment", Model["Right Leg"])
	RightAttachment.Position = Vector3.new(0, 1, 0)
	
	local RightHipAttachment = Instance.new("Attachment", Model["Torso"])
	RightHipAttachment.Position = Vector3.new(0.5, -1, 0)
	
	local RightHipSocket = Instance.new("BallSocketConstraint", Model["Right Leg"])
	RightHipSocket.Attachment0 = RightAttachment
	RightHipSocket.Attachment1 = RightHipAttachment
	
	
	local NeckAttachment = Instance.new("Attachment", Model["Head"])
	NeckAttachment.Position = Vector3.new(0, -0.5, 0)
	
	local TorsoToNeckAttachment = Instance.new("Attachment", Model["Torso"])
	TorsoToNeckAttachment.Position = Vector3.new(0, 1, 0)
	
	local NeckSocket = Instance.new("BallSocketConstraint", Model["Head"])
	NeckSocket.Attachment0 = NeckAttachment
	NeckSocket.Attachment1 = TorsoToNeckAttachment
end

return Module