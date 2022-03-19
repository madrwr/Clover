local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')
local HttpService = game:GetService('HttpService')
local ContextActionService = game:GetService('ContextActionService')
local PlayersService = game:GetService('Players')
local SoundService = game:GetService('SoundService')
local TextService = game:GetService('TextService')




function GetModule(module)
	return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/madrwr/Clover/main/" .. module .. ".lua"))()
end

local Panel3D = GetModule("ChatModules/Panel3D")
local Util = GetModule("ChatModules/Utility")

local BACKGROUND_OPACITY = 0.3
local NORMAL_KEY_COLOR = Color3.new(49/255,49/255,49/255)
local HOVER_KEY_COLOR = Color3.new(49/255,49/255,49/255)
local PRESSED_KEY_COLOR = Color3.new(0,162/255,1)
local SET_KEY_COLOR = Color3.new(0,162/255,1)

local KEY_TEXT_COLOR = Color3.new(1,1,1)
---------------------------------------- KEYBOARD LAYOUT --------------------------------------
local MINIMAL_KEYBOARD_LAYOUT = HttpService:JSONDecode([==[
[
  [
    {
      "a": 7,
      "w": 0.8
    },
    "*",
    "Q",
    "W",
    "E",
    "R",
    "T",
    "Y",
    "U",
    "I",
    "O",
    "P",
    {
      "w": 1.8
    },
    "Delete"
  ],
  [
    {
      "w": 1.6
    },
    "Caps",
    "A",
    "S",
    "D",
    "F",
    "G",
    "H",
    "J",
    "K",
    "L",
    "?",
    {
      "h": 2,
      "w2": 2.4,
      "h2": 1,
      "x2": -1.4,
      "y2": 1
    },
    "Enter"
  ],
  [
    {
      "w": 2.2
    },
    "Shift",
    "Z",
    "X",
    "C",
    "V",
    "B",
    "N",
    "M",
    "."
  ],
  [
    {
      "w": 2.2
    },
    "123/sym",
    {
      "w": 8
    },
    "",
    {
      "w": 2.4
    }
  ]
]
]==])

local MINIMAL_KEYBOARD_LAYOUT_SYMBOLS = HttpService:JSONDecode([==[
[
  [
    {
      "a": 7,
      "w": 0.8
    },
    "*",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    {
      "w": 1.8
    },
    "Delete"
  ],
  [
    {
      "w": 1.6
    },
    "!",
    "@",
    "#",
    "$",
    "%",
    "^",
    "&",
    "(",
    ")",
    "=",
    "?",
    {
      "h": 2,
      "w2": 2.4,
      "h2": 1,
      "x2": -1.4,
      "y2": 1
    },
    "Enter"
  ],
  [
    {
      "w": 1.2
    },
    "/",
    "-",
    "+",
    "_",
    ":",
    ";",
    "'",
    "\"",
    ",",
    "."
  ],
  [
    {
      "w": 2.2
    },
    "abc",
    {
      "w": 8
    },
    "",
    {
      "w": 2.4
    }
  ]
]
]==])


---------------------------------------- END KEYBOARD LAYOUT --------------------------------------
local function tokenizeString(str, tokenChar)
	local words = {}
	for word in string.gmatch(str, '([^' .. tokenChar .. ']+)') do
		table.insert(words, word)
	end
	return words
end

local function ConvertFontSizeEnumToInt(fontSizeEnum)
	local result = string.match(fontSizeEnum.Name, '%d+')
	return (result and tostring(result)) or 12
end

-- No rotation as of yet
local function PointInGuiObject(object, x, y)
	local minPt = object.AbsolutePosition
	local maxPt = object.AbsolutePosition + object.AbsoluteSize
	if minPt.X <= x and maxPt.X >= x and minPt.Y <= y and maxPt.Y >= y then
		return true
	end
	return false
end

function Clamp(low, high, input)
	return math.max(low, math.min(high, input))
end

local function FindAncestorOfType(object, ancestorType)
	if not object then return nil end

	local parent = object.Parent
	if parent and  parent:IsA(ancestorType) then
		return parent
	end

	return FindAncestorOfType(parent, ancestorType)
end

local function ExtendedInstance(instance)
	local this = {}
	do
		local mt =
			{
				__index = function (t, k)
				return instance[k]
			end;

				__newindex = function (t, k, v)
				instance[k] = v
			end;
			}
		setmetatable(this, mt)
	end
	return this
end

local selectionRing = Util:Create'ImageLabel'
{
	Name = 'SelectionRing';
	Size = UDim2.new(1, -6, 1, -6);
	Position = UDim2.new(0, 4, 0, 3);
	Image = 'rbxasset://textures/ui/menu/buttonHover.png';
	ScaleType = Enum.ScaleType.Slice;
	SliceCenter = Rect.new(94/2, 94/2, 94/2, 94/2);
	BackgroundTransparency = 1;
}

local KEY_ICONS =
	{
		["<Speaker>"] = {Asset = "rbxasset://textures/ui/Keyboard/mic_icon.png", AspectRatio = 0.615};
	}

local function CreateKeyboardKey(keyboard, layoutData, keyData)	
	local isSpecialShapeKey = layoutData['width2'] and layoutData['height2'] and layoutData['x2'] and layoutData['y2']
	local secondBackgroundImage = nil
	local specialSelectionObject, specialSelectionObject2, specialSelectionObject3 = nil, nil, nil

	local newKeyElement = Util:Create'ImageButton'
	{
		Name = keyData[1];
		Position = UDim2.new(layoutData['x'], 0, layoutData['y'], 0);
		Size = UDim2.new(layoutData['width'], 0, layoutData['height'], 0);
		BorderSizePixel = 0;
		Image = "";
		BackgroundTransparency = 1;
		ZIndex = 1;
	}
	local keyText = Util:Create'TextLabel'
	{
		Name = "KeyText";
		Text = keyData[#keyData];
		Position = UDim2.new(0, -10, 0, -10);
		Size = UDim2.new(1, 0, 1, 0);
		Font = Enum.Font.SourceSansBold;
		FontSize = Enum.FontSize.Size96;
		TextColor3 = KEY_TEXT_COLOR;
		BackgroundTransparency = 1;
		Selectable = true;
		ZIndex = 2;
		Parent = newKeyElement;
	}
	local backgroundImage = Util:Create'Frame'
	{
		Name = 'KeyBackground';
		Size = UDim2.new(1,-10,1,-10);
		Position = UDim2.new(0,-5,0,-5);
		BackgroundColor3 = NORMAL_KEY_COLOR;
		BackgroundTransparency = BACKGROUND_OPACITY;
		BorderSizePixel = 0;
		Parent = newKeyElement;
	}

	local selectionObject = Util:Create'ImageLabel'
	{
		Name = 'SelectionObject';
		Size = UDim2.new(1,0,1,0);
		BackgroundTransparency = 1;
		Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png";
		ImageTransparency = 0;
		ScaleType = Enum.ScaleType.Slice;
		SliceCenter = Rect.new(12,12,52,52);
		BorderSizePixel = 0;
	}

	newKeyElement.SelectionImageObject = Util:Create'ImageLabel'
	{
		Visible = false;
	}

	-- Special silly enter key nonsense
	if isSpecialShapeKey then
		secondBackgroundImage = Util:Create'ImageButton'
		{
			Name = 'KeyBackground';
			Position = UDim2.new(layoutData['x2'] / layoutData['width'], -5, layoutData['y2'] / layoutData['height'], -5);
			Size = UDim2.new(layoutData['width2'] / layoutData['width'], 0, layoutData['height2'] / layoutData['height'], -10);
			BackgroundColor3 = NORMAL_KEY_COLOR;
			BackgroundTransparency = BACKGROUND_OPACITY;
			BorderSizePixel = 0;
			AutoButtonColor = false;
			SelectionImageObject = newKeyElement.SelectionImageObject;
			Parent = newKeyElement;
		}
		if layoutData['x2'] <= 0 then
			keyText.Size = secondBackgroundImage.Size - UDim2.new(0,10,0,0)
			keyText.Position = secondBackgroundImage.Position
			secondBackgroundImage.Size = secondBackgroundImage.Size - UDim2.new(1,0,0,0)
		end

		do
			specialSelectionObject = Util:Create'Frame'
			{
				Name = 'SpecialSelectionObject';
				Size = UDim2.new(1,0,0.5,0);
				Position = UDim2.new(0,0,0.5,0);
				BackgroundTransparency = 1;
				ClipsDescendants = true;
				Util:Create'ImageLabel'
				{
					Name = 'Borders';
					Position = UDim2.new(-1,0,-1,0);
					Size = UDim2.new(2,0,2,0);
					BackgroundTransparency = 1;
					Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png";
					ImageTransparency = 0;
					ScaleType = Enum.ScaleType.Slice;
					SliceCenter = Rect.new(12,12,52,52);
				};
			}
			specialSelectionObject2 = specialSelectionObject:Clone()
			specialSelectionObject2.Size = UDim2.new(1,0,0.5,5)
			specialSelectionObject2.Position = UDim2.new(0,0,0,0)
			specialSelectionObject2.Borders.Size = UDim2.new(1,0,1,30)
			specialSelectionObject2.Borders.Position = UDim2.new(0,0,0,0)

			specialSelectionObject3 = specialSelectionObject:Clone()
			specialSelectionObject3.Size = UDim2.new(1,5,1,0)
			specialSelectionObject3.Position = UDim2.new(0,0,0,0)
			specialSelectionObject3.Borders.Size = UDim2.new(1,30,1,0)
			specialSelectionObject3.Borders.Position = UDim2.new(0,0,0,0)
		end
		-- End of nonsense
	end

	local newKey = ExtendedInstance(newKeyElement)

	local hovering = false
	local pressed = false
	local isAlpha = #keyData == 1 and type(keyData[1]) == 'string' and #keyData[1] == 1 and
		string.byte(keyData[1]) >= string.byte("A") and string.byte(keyData[1]) <= string.byte("z")

	local icon = nil
	if keyData[1] and KEY_ICONS[keyData[1]] then
		keyText.Visible = false
		icon = Util:Create'ImageLabel'
		{
			Name = 'KeyIcon';
			Size = UDim2.new(KEY_ICONS[keyData[1]].AspectRatio, -20, 1, -20);
			SizeConstraint = Enum.SizeConstraint.RelativeYY;
			BackgroundTransparency = 1;
			Image = KEY_ICONS[keyData[1]].Asset;
			Parent = backgroundImage;
		}

		local function onChanged(prop)
			if prop == 'AbsoluteSize' then
				icon.Position = UDim2.new(0.5,-icon.AbsoluteSize.X/2,0.5,-icon.AbsoluteSize.Y/2);
			end
		end
		icon.Changed:connect(onChanged)
		onChanged('AbsoluteSize')
	end

	local function onClicked()
		local keyValue = nil
		local currentKeySetting = newKey:GetCurrentKeyValue()

		if currentKeySetting == 'Shift' then
			keyboard:SetShift(not keyboard:GetShift())
		elseif currentKeySetting == 'Caps' then
			keyboard:SetCaps(not keyboard:GetCaps())
		elseif currentKeySetting == 'Enter' then
			keyboard:SubmitText(true, true)
		elseif currentKeySetting == 'Delete' then
			keyboard:BackspaceAtCursor()
		elseif currentKeySetting == "123/sym" then
			keyboard:SetCurrentKeyset(2)
		elseif currentKeySetting == "abc" then
			keyboard:SetCurrentKeyset(1)
		elseif currentKeySetting == 'Tab' then
			keyValue = '\t'
		elseif currentKeySetting == "<Speaker>" then
			return
		else
			keyValue = currentKeySetting
		end

		if keyValue ~= nil then
			keyboard:SubmitCharacter(keyValue, isAlpha)
		end
	end

	local function setKeyColor(newColor, hovering)
		backgroundImage.BackgroundColor3 = newColor
		if secondBackgroundImage then
			secondBackgroundImage.BackgroundColor3 = newColor
		end
		if isSpecialShapeKey then
			specialSelectionObject.Parent = hovering and backgroundImage or nil
			specialSelectionObject2.Parent = hovering and backgroundImage or nil
			specialSelectionObject3.Parent = hovering and secondBackgroundImage or nil
		else
			selectionObject.Parent = hovering and backgroundImage or nil
		end
	end

	local function update()
		local currentKey = newKey:GetCurrentKeyValue()

		if pressed then
			setKeyColor(PRESSED_KEY_COLOR, false)
		elseif currentKey == 'Caps' and keyboard:GetCaps() then
			setKeyColor(SET_KEY_COLOR, false)
		elseif currentKey == 'Shift' and keyboard:GetShift() then
			setKeyColor(SET_KEY_COLOR, false)
		elseif currentKey == 'abc' then
			setKeyColor(SET_KEY_COLOR, false)
		else
			setKeyColor(NORMAL_KEY_COLOR, false)
		end

		if icon then
			icon.ImageTransparency = 0.5
		end

		keyText.Text = newKey:GetCurrentKeyValue()
	end


	rawset(newKey, "SetPressed", function(self, Boolean)
		pressed = Boolean
		update()
	end)
	rawset(newKey, "OnDown", function(self)
		self:SetPressed(true)
		update()
		onClicked()
	end)
	rawset(newKey, "OnUp", function(self)
		self:SetPressed(false)
		update()
	end)
	rawset(newKey, "GetCurrentKeyValue", function(self)
		local shiftEnabled = keyboard:GetShift()
		local capsEnabled = keyboard:GetCaps()

		if isAlpha then
			if capsEnabled and shiftEnabled then
				return string.lower(keyData[#keyData])
			elseif capsEnabled or shiftEnabled then
				return keyData[1]
			else
				return string.lower(keyData[#keyData])
			end
		end

		if shiftEnabled then
			return keyData[1]
		end

		return keyData[#keyData]
	end)
	rawset(newKey, "Update", function(self)
		update()
	end)

	update()	

	local Self = {
		_Instance = newKeyElement,
		newKey = newKey,

		PressKey = function(self, X,Y)			
			if PointInGuiObject(newKeyElement, X,Y) then
				onClicked()
				return true
			end
			return false
		end,
	}

	return Self
end



local function ConstructKeyboardUI(keyboardLayoutDefinitions, event)
	local panel = Panel3D.Get("Keyboard")
	panel:SetVisible(false)
	
	panel.DefaultDensity = 320

	local buttons = {}

	local keyboardContainer = Util:Create'Frame'
	{
		Name = 'VirtualKeyboard';
		Size = UDim2.new(1, 0, 1, 0);
		Position = UDim2.new(0, 0, 0, 0);
		BackgroundTransparency = 1;
		Active = false;
		Visible = false;
		Parent = panel:GetGui()
	};

	local textEntryBackground = Util:Create'ImageLabel'
	{
		Name = 'TextEntryBackground';
		Size = UDim2.new(0.5,0,0.125,0);
		Position = UDim2.new(0.25,0,0,0);
		Image = "";
		BackgroundTransparency = 0.5;
		BackgroundColor3 = Color3.new(31/255,31/255,31/255);
		BorderSizePixel = 0;
		ClipsDescendants = true;
		Parent = keyboardContainer;
	}
	local textfieldBackground = Util:Create'Frame'
	{
		Name = 'TextfieldBackground';
		Position = UDim2.new(0,2,0,2);
		Size = UDim2.new(1, -4, 1, -4);
		BackgroundTransparency = 0;
		BackgroundColor3 = Color3.new(209/255,216/255,221/255);
		BorderSizePixel = 0;
		Visible = true;
		Parent = textEntryBackground;
	};
	local textEntryField = Util:Create'TextButton'
	{
		Name = "TextEntryField";
		Text = "";
		Position = UDim2.new(0,4,0,4);
		Size = UDim2.new(1, -8, 1, -8);
		Font = Enum.Font.SourceSans;
		FontSize = Enum.FontSize.Size60;
		TextXAlignment = Enum.TextXAlignment.Left;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Parent = textfieldBackground;
	}
	local textfieldCursor = Util:Create'Frame'
	{
		Name = 'TextfieldCursor';
		Size = UDim2.new(0, 5, 0.9, 0);
		Position = UDim2.new(0, 0, 0.05, 0);
		BackgroundTransparency = 0;
		BackgroundColor3 = SET_KEY_COLOR;
		BorderSizePixel = 0;
		Visible = true;
		ZIndex = 2;
		Parent = textEntryField;
	};

	local closeButtonElement = Util:Create'ImageButton'
	{
		Name = 'CloseButton';
		Size = UDim2.new(0.075,-10,0.198,-10);
		Position = UDim2.new(0,-5,0,-35);
		Image = "rbxasset://textures/ui/Keyboard/close_button_background.png";
		BackgroundTransparency = 1;
		AutoButtonColor = false;
		Parent = keyboardContainer;
	}
	do
		closeButtonElement.SelectionImageObject = Util:Create'ImageLabel'
		{
			Name = 'Selection';
			Size = UDim2.new(0.9,0,0.9,0);
			Position = UDim2.new(0.05,0,0.05,0);
			Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png";
			BackgroundTransparency = 1;
		}
		Util:Create'ImageLabel'
		{
			Name = 'Icon';
			Size = UDim2.new(0.5,0,0.5,0);
			Position = UDim2.new(0.25,0,0.25,0);
			Image = "rbxasset://textures/ui/Keyboard/close_button_icon.png";
			BackgroundTransparency = 1;
			Parent = closeButtonElement;
		}
	end
	
	
	
	local newKeyboard = ExtendedInstance(keyboardContainer)

	local keyboardOptions = nil
	local keysets = {}

	local capsLockEnabled = false
	local shiftEnabled = false

	local textfieldCursorPosition = 0

	local opened = false

	local function SetTextFieldCursorPosition(newPosition)
		textfieldCursorPosition = Clamp(0, #textEntryField.Text, newPosition)
		if not textEntryField.TextFits then
			textfieldCursorPosition = #textEntryField.Text
		end

		local textSize = TextService:GetTextSize(
			string.sub(textEntryField.Text, 1, textfieldCursorPosition),
			ConvertFontSizeEnumToInt(textEntryField.FontSize),
			textEntryField.Font,
			textEntryField.AbsoluteSize)
		textfieldCursor.Position = UDim2.new(0, textSize.x, textfieldCursor.Position.Y.Scale, textfieldCursor.Position.Y.Offset)
	end

	local function UpdateTextEntryFieldText(newText)
		--textEntryField:SetTextFromInput(newText)
		textEntryField.Text = newText
		SetTextFieldCursorPosition(textfieldCursorPosition)
	end

	local buffer = ""
	local function getBufferText()
		if keyboardOptions and keyboardOptions.TextBox then
			return keyboardOptions.TextBox.Text
		end
		return buffer
	end
	local function setBufferText(newBufferText)
		if keyboardOptions and keyboardOptions.TextBox then
			keyboardOptions.TextBox.Text = newBufferText
		elseif buffer ~= newBufferText then
			buffer = newBufferText
			UpdateTextEntryFieldText(buffer)
		end
	end

	local function calculateTextCursorPosition(x, y)
		x = x - textEntryField.AbsolutePosition.x
		y = y - textEntryField.AbsolutePosition.y

		for i = 1, #textEntryField.Text do
			local textSize = TextService:GetTextSize(
				string.sub(textEntryField.Text, 1, i),
				ConvertFontSizeEnumToInt(textEntryField.FontSize),
				textEntryField.Font,
				textEntryField.AbsoluteSize)
			if textSize.x > x then
				return i - 1
			end
		end

		return #textEntryField.Text
	end

	local currentKeyset = nil

	rawset(newKeyboard, "GetCurrentKeyset", function(self)
		return keysets[currentKeyset]
	end)

	rawset(newKeyboard, "SetCurrentKeyset", function(self, newKeyset)
		if newKeyset ~= currentKeyset and keysets[newKeyset] ~= nil then
			if keysets[currentKeyset] and keysets[currentKeyset].container then
				keysets[currentKeyset].container.Visible = false
			end

			currentKeyset = newKeyset

			if keysets[currentKeyset] and keysets[currentKeyset].container then
				keysets[currentKeyset].container.Visible = true
			end
		end
	end)

	rawset(newKeyboard, "GetCaps", function(self)
		return capsLockEnabled
	end)

	rawset(newKeyboard, "SetCaps", function(self, newCaps)
		capsLockEnabled = newCaps
		for _, key in pairs(self:GetCurrentKeyset().keys) do
			pcall(function()
				key.newKey:Update()
			end)
		end
	end)

	rawset(newKeyboard, "GetShift", function(self)
		return shiftEnabled
	end)

	rawset(newKeyboard, "SetShift", function(self, newShift)
		shiftEnabled = newShift
		for _, key in pairs(self:GetCurrentKeyset().keys) do
			pcall(function()
				key.newKey:Update()
			end)
		end
	end)

	local ignoreFocusedLost = false

	local textChangedConn = nil
	local textBoxFocusLostConn = nil
	local panelClosedConn = nil

	local function disconnectKeyboardEvents()
		if textChangedConn then textChangedConn:disconnect() end
		textChangedConn = nil
		if textBoxFocusLostConn then textBoxFocusLostConn:disconnect() end
		textBoxFocusLostConn = nil
		if panelClosedConn then panelClosedConn:disconnect() end
		panelClosedConn = nil
	end

	rawset(newKeyboard, "Open", function(self, options)
		if opened then return end
		opened = true
		
		local connection
		connection = event.Event:Connect(function()
			connection:Disconnect()

			self:Close(false)
		end)

		keyboardOptions = options

		self:SetCurrentKeyset(1)
		keyboardContainer.Visible = true

		panel:ResizeStuds(5.9, 2.25, 320)

		local localCF = CFrame.new()

		disconnectKeyboardEvents()
		if options.TextBox then
			textChangedConn = options.TextBox.Changed:connect(function(prop)
				if prop == 'Text' then
					UpdateTextEntryFieldText(options.TextBox.Text)
				end
			end)
			if options.TextBox:IsA("TextBox") then
				textBoxFocusLostConn = options.TextBox.FocusLost:connect(function(submitted)
					if not ignoreFocusedLost then
						self:Close(submitted)
					end
				end)
				
				if options.TextBox.ClearTextOnFocus then
					setBufferText("")
				else
					UpdateTextEntryFieldText(options.TextBox.Text)
				end
			end

			-- Find panel for 2d ui?
			local textboxPanel = Panel3D.FindContainerOf(options.TextBox)
			if textboxPanel then
				panelClosedConn = Panel3D.OnPanelClosed.Event:connect(function(closedPanelName)
					if closedPanelName == textboxPanel.name then
						self:Close(false)
					end
				end)
			end
			
			local headForwardCF = Panel3D.GetHeadLookXZ(true)
			localCF = headForwardCF * CFrame.Angles(math.rad(22.5), 0, 0) * CFrame.new(0, -1, -5)
		else
			setBufferText("")
		end


		local KeysPressed = {}
		ContextActionService:BindAction("VirtualKeyboardControllerInputNonCG",
			function(actionName, inputState, inputObject)
				if inputState == Enum.UserInputState.Begin then
					if inputObject.KeyCode == Enum.KeyCode.ButtonA then
						local LookAt = panel.CursorPos
						for Index, Self in pairs(self:GetCurrentKeyset().keys) do
							local Pressed = Self:PressKey(LookAt.X, LookAt.Y)
							if Pressed then
								if Self._Instance.Name == "CloseButton" then
									self:Close(false)
									return
								elseif Self._Instance.Name == "Enter" then
									self:Close(true, true)
									return
								end
								
								
								pcall(function()-- // run all newKey functions inside of a pcall
									KeysPressed[tostring(Self.newKey:GetCurrentKeyValue())] = Self
									Self.newKey:SetPressed(true)
								end)
							end
						end
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonL1 then
						SetTextFieldCursorPosition(textfieldCursorPosition - 1)
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonR1 then
						SetTextFieldCursorPosition(textfieldCursorPosition + 1)
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonX then
						self:BackspaceAtCursor()
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonY then
						self:SubmitCharacter(" ", false)
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonL2 then
						if currentKeyset then
							-- Go to the next keyset
							self:SetCurrentKeyset((currentKeyset % #keysets) + 1)
						end
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonL3 then
						self:SetCaps(not self:GetCaps())
					elseif inputObject.KeyCode == Enum.KeyCode.ButtonB then
						self:Close(false)
					end
				elseif inputState == Enum.UserInputState.End then
					if inputObject.KeyCode == Enum.KeyCode.ButtonA then
						for Index, Self in pairs(KeysPressed) do
							Self.newKey:SetPressed(false)
							KeysPressed[Index] = nil
						end
					end
				end
			end,
			false,
			Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL2, Enum.KeyCode.ButtonL3, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonB)


		panel:SetType(Panel3D.Type.Fixed, { CFrame = localCF })
		panel:SetVisible(true, true)

		function panel:OnUpdate()
		end
	end)

	rawset(newKeyboard, "Close", function(self, submit, send)
		submit = (submit == true)

		if not opened then return end
		opened = false

		disconnectKeyboardEvents()

		ContextActionService:UnbindAction("VirtualKeyboardControllerInputNonCG")
		-- Clean-up
		panel:SetVisible(false, true)
		keyboardContainer.Visible = false

		self:SubmitText(submit, false)
	end)

	rawset(newKeyboard, "SubmitText", function(self, submit, keepKeyboardOpen)
		local keyboardTextbox = keyboardOptions and keyboardOptions.TextBox
		if keyboardTextbox then
			if submit then
				keyboardTextbox.Text = getBufferText()
			end
			-- Only keep text boxes open for coreguis, such as chat
			local textboxPanel = Panel3D.FindContainerOf(keyboardTextbox)
			local reopenKeyboard = keepKeyboardOpen and textboxPanel and textboxPanel.linkedTo == panel

			if reopenKeyboard then
				ignoreFocusedLost = true
			end

			if keyboardTextbox:IsA("TextBox") then
				keyboardTextbox:ReleaseFocus(submit)
			end

			if reopenKeyboard then
				keyboardTextbox:CaptureFocus()
				ignoreFocusedLost = false
			end

			if submit then
				UpdateTextEntryFieldText("")
			end
		end
	end)

	rawset(newKeyboard, "GetCurrentOptions", function(self)
		return keyboardOptions
	end)

	rawset(newKeyboard, "BackspaceAtCursor", function(self)
		if textfieldCursorPosition >= 1 then
			local bufferText = getBufferText()
			local newBufferText = string.sub(bufferText, 1, textfieldCursorPosition - 1) .. string.sub(bufferText, textfieldCursorPosition + 1, #bufferText)
			local newCursorPosition = textfieldCursorPosition - 1
			setBufferText(newBufferText)
			SetTextFieldCursorPosition(newCursorPosition)
		end
	end)

	rawset(newKeyboard, "SubmitCharacter", function(self, character, isAnAlphaKey)
		local bufferText = getBufferText()
		local newBufferText = string.sub(bufferText, 1, textfieldCursorPosition) .. character .. string.sub(bufferText, textfieldCursorPosition + 1, #bufferText)
		setBufferText(newBufferText)
		SetTextFieldCursorPosition(textfieldCursorPosition + #character)

		if isAnAlphaKey and self:GetShift() then
			self:SetShift(false)
		end
	end)
	
	rawset(newKeyboard, "IsOpened", function(self)
		return opened
	end)

	do -- Parse input definition
		for _, keyboardKeyset in pairs(keyboardLayoutDefinitions) do
			local keys = {}
			local keyboardSizeConstrainer = Util:Create'Frame'
			{
				Name = 'KeyboardSizeConstrainer';
				Size = UDim2.new(1, 0, 1, -20);
				Position = UDim2.new(0, 0, 0, 20);
				BackgroundTransparency = 1;
				Parent = keyboardContainer;
			};

			local maxWidth = 0
			local maxHeight = 0
			local y = 0
			for rowNum, rowData in pairs(keyboardKeyset) do
				local x = 0
				local width = 1
				local height = 1
				local width2, height2, x2, y2;
				for columnNum, columnData in pairs(rowData) do
					if type(columnData) == 'table' then
						if columnData['w'] then width = columnData['w'] end
						if columnData['h'] then height = columnData['h'] end
						if columnData['x'] then x = x + columnData['x'] end
						if columnData['y'] then y = y + columnData['y'] end
						if columnData['x2'] then x2 = columnData['x2'] end
						if columnData['y2'] then y2 = columnData['y2'] end
						if columnData['w2'] then width2 = columnData['w2'] end
						if columnData['h2'] then height2 = columnData['h2'] end
					elseif type(columnData) == 'string' then
						if columnData == "" then
							columnData = " "
						end
						-- put key
						local key = CreateKeyboardKey(
							newKeyboard,
							{x = x, y = y, width = width, height = height, x2 = x2, y2 = y2, width2 = width2, height2 = height2},
							tokenizeString(columnData, '\n'))
						table.insert(keys, key)

						x = x + width
						maxWidth = math.max(maxWidth, x)
						maxHeight = math.max(maxHeight, y + height)
						-- reset for the next key
						width = 1
						height = 1
						width2, height2, x2, y2 = nil, nil, nil, nil
					end
				end
				y = y + 1
			end

			-- Fix the positions and sizes to fit in our KeyboardContainer
			for _, element in pairs(keys) do
				element._Instance.Position = UDim2.new(element._Instance.Position.X.Scale / maxWidth, 0, element._Instance.Position.Y.Scale / maxHeight, 0)
				element._Instance.Size = UDim2.new(element._Instance.Size.X.Scale / maxWidth, 0, element._Instance.Size.Y.Scale / maxHeight, 0)
				element._Instance.Parent = keyboardSizeConstrainer
			end

			keyboardSizeConstrainer.SizeConstraint = Enum.SizeConstraint.RelativeXX
			keyboardSizeConstrainer.Size = UDim2.new(1, 0, -maxHeight / maxWidth, 0)
			keyboardSizeConstrainer.Position = UDim2.new(0, 0, 1, 0)
			keyboardSizeConstrainer.Visible = false

			local Table = {
				keys = keys,
				container = keyboardSizeConstrainer,
			}

			local ClosedSelf = {
				_Instance = closeButtonElement,
				newKey = {},

				PressKey = function(self, X, Y)
					return PointInGuiObject(closeButtonElement, X, Y)
				end,
			}
			
			table.insert(Table.keys, ClosedSelf)
			table.insert(keysets, Table)
		end
		newKeyboard:SetCurrentKeyset(1)
	end

	return newKeyboard
end









local VirtualKeyboardClass = {}
VirtualKeyboardClass.ForceExit = Instance.new("BindableEvent", game.ReplicatedStorage)

local Keyboard = nil;
local function GetKeyboard()
	if Keyboard == nil then
		Keyboard = ConstructKeyboardUI({MINIMAL_KEYBOARD_LAYOUT, MINIMAL_KEYBOARD_LAYOUT_SYMBOLS}, VirtualKeyboardClass.ForceExit)
	end
	return Keyboard
end

function VirtualKeyboardClass:CreateVirtualKeyboardOptions(textbox)
	local keyboardOptions = {}

	keyboardOptions.TextBox = textbox

	return keyboardOptions
end

function VirtualKeyboardClass:IsOpen()
	if Keyboard then
		return Keyboard:IsOpened()
	else
		return false
	end
end

function VirtualKeyboardClass:GetBoard()
	return Keyboard
end



function VirtualKeyboardClass:ShowVirtualKeyboard(virtualKeyboardOptions)
	if UserInputService.VREnabled then
		GetKeyboard():Open(virtualKeyboardOptions)
	end
end

function VirtualKeyboardClass:CloseVirtualKeyboard()
	if UserInputService.VREnabled then
		local currentKeyboard = GetKeyboard()
		currentKeyboard:Close(false)
	end
end


if UserInputService.VREnabled then
	UserInputService.TextBoxFocused:connect(function(textbox)
		VirtualKeyboardClass:ShowVirtualKeyboard(VirtualKeyboardClass:CreateVirtualKeyboardOptions(textbox))
	end)
	
	--local Folder = script.Parent
	--Folder:WaitForChild("Activate").Event:Connect(function(textbox)
	--	VirtualKeyboardClass:ShowVirtualKeyboard(VirtualKeyboardClass:CreateVirtualKeyboardOptions(textbox))
	--end)
	-- Don't have to hook up to TextBoxFocusReleased because we are already listening to that in keyboard
end

return VirtualKeyboardClass
