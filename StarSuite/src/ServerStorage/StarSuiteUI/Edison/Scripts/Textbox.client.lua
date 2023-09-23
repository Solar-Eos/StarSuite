--!nocheck


-- Services
local _USERINPUTSERVICE = game:GetService("UserInputService")
local _TEXTSERVICE = game:GetService("TextService")
local _STARTERGUI = game:GetService("StarterGui")


-- Libraries
local Plugin = script.Parent.Parent
local Templates = Plugin.Resources.UI

local Sanitizer = require(Plugin.Library.sanitizer)

local Internal = require(Plugin.Resources.Containers.Internal)
local UI = require(Plugin.Resources.Containers.UI)
local Config = require(Plugin.Resources.Containers.Config)


-- Upvalues


-- Yield
repeat task.wait() until Internal.LoaderLoaded == true


-- Constants


-- Variables
local selectionString = ""
local selectionStart, selectionEnd = -1, -1
local startString, endString = "", ""
local wheelHeldDown = false
local hueHeldDown = false
local hWheel, sWheel, vWheel = 0, 0, 0

local InputScroll = Internal.PluginWidget.MainFrame.InputScroll
local PreviewScroll = Internal.PluginWidget.MainFrame.PreviewScroll
local MainInputBox = InputScroll.TextBox
local PreviewText = PreviewScroll.PreviewText

local MainFrame = Internal.PluginWidget.MainFrame
local HoverFrame = Internal.PluginWidget.HoverFrame

local TopbarFrame = MainFrame.TopbarFrame
local TopbarScroll = TopbarFrame.ToolButtonFrame.ScrollingFrame
local TabBarScroll = TopbarFrame.TabBarFrame.ScrollingFrame

local DropdownFrame = Internal.PluginWidget.DropdownFrame

local DropdownButton = Templates.DropdownButton
local ColorPickerFrame = Templates.ColorFrame

local buttons = {
	TopbarScroll.FormattingFrame.MainFrame.BoldButton,
	TopbarScroll.FormattingFrame.MainFrame.ClearButton,
	TopbarScroll.FormattingFrame.MainFrame.ItalicButton,
	TopbarScroll.FormattingFrame.MainFrame.LowercaseButton,
	TopbarScroll.FormattingFrame.MainFrame.StrikeButton,
	TopbarScroll.FormattingFrame.MainFrame.UnderlineButton,
	TopbarScroll.FormattingFrame.MainFrame.UppercaseButton,
	TopbarScroll.FontFrame.FontFaceFrame.ActivateButton,
	TopbarScroll.FontFrame.FontWeightFrame.ActivateButton,
	TopbarScroll.InsertFrame.AmpersandFrame.ActivateButton,
	TopbarScroll.InsertFrame.ApostropheFrame.ActivateButton,
	TopbarScroll.InsertFrame.LeftAngularBracketFrame.ActivateButton,
	TopbarScroll.InsertFrame.QuoteFrame.ActivateButton,
	TopbarScroll.InsertFrame.RightAngularBracketFrame.ActivateButton,
	TopbarScroll.StrokeFrame.StrokeColorFrame.ActivateButton,
	TopbarScroll.StrokeFrame.StrokeJoinsFrame.ActivateButton,
	TopbarScroll.StrokeFrame.StrokeThicknessFrame.ActivateButton,
	TopbarScroll.StrokeFrame.StrokeTransparencyFrame.ActivateButton,
	TopbarScroll.StyleFrame.TextColorFrame.ActivateButton,
	TopbarScroll.StyleFrame.TextSizeFrame.ActivateButton,
	TopbarScroll.StyleFrame.TextTransparencyFrame.ActivateButton,
	--TopbarScroll.UtilityFrame.AdvancedFrame.ActivateButton,
	--TopbarScroll.UtilityFrame.ReplaceFrame.ActivateButton,
	--TopbarScroll.UtilityFrame.SearchFrame.ActivateButton,
}
local inputboxes = {
	TopbarScroll.FontFrame.FontFaceFrame.InputBox,
	TopbarScroll.FontFrame.FontWeightFrame.InputBox,
	TopbarScroll.StrokeFrame.StrokeColorFrame.InputBox,
	TopbarScroll.StrokeFrame.StrokeJoinsFrame.InputBox,
	TopbarScroll.StrokeFrame.StrokeThicknessFrame.InputBox,
	TopbarScroll.StrokeFrame.StrokeTransparencyFrame.InputBox,
	TopbarScroll.StyleFrame.TextColorFrame.InputBox,
	TopbarScroll.StyleFrame.TextSizeFrame.InputBox,
	TopbarScroll.StyleFrame.TextTransparencyFrame.InputBox,
	--TopbarScroll.UtilityFrame.AdvancedFrame.InputBox,
	--TopbarScroll.UtilityFrame.ReplaceFrame.InputBox,
	--TopbarScroll.UtilityFrame.SearchFrame.InputBox,
}
local dropdowns = {
	TopbarScroll.FontFrame.FontFaceFrame.DropdownButton,
	TopbarScroll.FontFrame.FontWeightFrame.DropdownButton,
	TopbarScroll.StrokeFrame.StrokeJoinsFrame.DropdownButton,
}
local colorpickers = {
	TopbarScroll.StrokeFrame.StrokeColorFrame.ColorPickerButton,
	TopbarScroll.StyleFrame.TextColorFrame.ColorPickerButton,
}


-- Remotes 

 
-- Functions
local function ResetSelection()
	selectionStart = -1
	selectionEnd = -1
	
	MainInputBox.SelectionStart = -1
	MainInputBox.CursorPosition = -1
end
local function ResetDropdownFrame()
	for _, child in DropdownFrame:GetChildren() do
		if child:IsA("GuiButton") == true then
			child:Destroy()
		end
	end
end
local function AdjustInputBoxSize()
	local textParams = Instance.new("GetTextBoundsParams") 
	textParams.Font = MainInputBox.FontFace
	textParams.Size = MainInputBox.TextSize
	textParams.Text = MainInputBox.Text
	textParams.Width = MainInputBox.AbsoluteSize.X - 20

	MainInputBox.Size = UDim2.new(1, 0, 0, _TEXTSERVICE:GetTextBoundsAsync(textParams).Y + 20)
	PreviewText.Size = MainInputBox.Size
end
local function AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)
	hWheel, sWheel, vWheel = color:ToHSV()
	
	previewFrame.UIStroke.Color = color
	hueFrame.UIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })
	hueFrame.SelectFrame.Position = UDim2.fromScale(0.5, 1 - vWheel)
	
	local h = hWheel * math.pi * 2
	local s = Vector2.new(-math.cos(h) / 2 * sWheel, math.sin(h) / 2 * sWheel)
	selectFrame.Position = UDim2.fromScale(0.5 + s.X, 0.5 + s.Y)
end

-- FLAG
local buttonFunctions = {
	BoldButton = function(str)
		local startTag, endTag = "<b>", "</b>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	ClearButton = function(str)
		return string.gsub(str, "%b<>", ""), nil, nil
	end,
	ItalicButton = function(str)
		local startTag, endTag = "<i>", "</i>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	LowercaseButton = function(str)
		local startTag, endTag = "<sc>", "</sc>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	StrikeButton = function(str)
		local startTag, endTag = "<s>", "</s>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	UnderlineButton = function(str)
		local startTag, endTag = "<u>", "</u>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	UppercaseButton = function(str)
		local startTag, endTag = "<uc>", "</uc>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	FontFaceFrame = function(str)
		local startTag, endTag = `<font face="{inputboxes[1].Text}">`, "</font>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	FontWeightFrame = function(str)
		local startTag, endTag = `<font weight="{inputboxes[2].Text}">`, "</font>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	AmpersandFrame = function(str)
		local result = { string.gsub(str, "&", "&amp;") }
		return result[1], #UI.AmpersandFrame
	end,
	ApostropheFrame = function(str)
		local result = { string.gsub(str, "'", "&apos;") }
		return result[1], #UI.ApostropheFrame
	end,
	LeftAngularBracketFrame = function(str)
		local result = { string.gsub(str, "<", "&lt;") }
		return result[1], #UI.LeftAngularBracketFrame
	end,
	QuoteFrame = function(str)
		local result = { string.gsub(str, `"`, "&quot;") }
		return result[1], #UI.QuoteFrame
	end,
	RightAngularBracketFrame = function(str)
		local result = { string.gsub(str, `>`, "&m;") }
		return result[1], #UI.RightAngularBracketFrame
	end,
	StrokeColorFrame = function(str)
		local startTag, endTag = `<stroke color='rgb({inputboxes[3].Text})' joins='{inputboxes[4].Text}' thickness='{inputboxes[5].Text}' transparency='{inputboxes[6].Text}'>`, "</stroke>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	StrokeJoinsFrame = function(str)
		local startTag, endTag = `<stroke color='rgb({inputboxes[3].Text})' joins='{inputboxes[4].Text}' thickness='{inputboxes[5].Text}' transparency='{inputboxes[6].Text}'>`, "</stroke>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	StrokeThicknessFrame = function(str)
		local startTag, endTag = `<stroke color='rgb({inputboxes[3].Text})' joins='{inputboxes[4].Text}' thickness='{inputboxes[5].Text}' transparency='{inputboxes[6].Text}'>`, "</stroke>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	StrokeTransparencyFrame = function(str)
		local startTag, endTag = `<stroke color='rgb({inputboxes[3].Text})' joins='{inputboxes[4].Text}' thickness='{inputboxes[5].Text}' transparency='{inputboxes[6].Text}'>`, "</stroke>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	TextColorFrame = function(str)
		local startTag, endTag = `<font color='rgb({inputboxes[7].Text})'>`, "</font>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	TextSizeFrame = function(str)
		local startTag, endTag = `<font size='{inputboxes[8].Text}'>`, "</font>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
	TextTransparencyFrame = function(str)
		local startTag, endTag = `<font transparency='{inputboxes[9].Text}'>`, "</font>"
		return `{startTag}{str}{endTag}`, #startTag, #endTag
	end,
}
local inputboxFunctions = {
	TextColorFrame = function(text)
		if string.sub(text, 1, 1) == "#" then
			return Sanitizer.CleanseByColorHEX(text, 255)
		else
			local result = Sanitizer.CleanseByColorRGB(text, 255)
			print(result)
			return `{result[1]}, {result[2]}, {result[3]}`
		end
	end,
	TextSizeFrame = function(text)
		return tostring(math.clamp(tonumber(text), 8, 96))
	end,
	TextTransparencyFrame = function(text)
		return tostring(math.clamp(tonumber(text), 0, 1))
	end,
	StrokeJoinsFrame = function(text)
		return text
	end,
	StrokeColorFrame = function(text)
		if string.sub(text, 1, 1) == "#" then
			return Sanitizer.CleanseByColorHEX(text, 255)
		else
			local result = Sanitizer.CleanseByColorRGB(text, 255)
			return `{result[1]}, {result[2]}, {result[3]}`
		end
	end,
	StrokeThicknessFrame = function(text)
		return tostring(math.clamp(tonumber(text), 8, 96))
	end,
	StrokeTransparencyFrame = function(text)
		return tostring(math.clamp(tonumber(text), 0, 1))
	end,
	FontFaceFrame = function(text)
		return UI.SearchForFont(text) or "SourceSans"
	end,
	FontWeightFrame = function(text)
		return UI.SearchForFontWeight(text) or Enum.FontWeight.Regular.Name
	end,
}
local inputboxKeyingFunctions = {
	TextColorFrame = function(text)
		return Sanitizer.SanitizeByColorBoth(text)
	end,
	TextSizeFrame = function(text)
		return Sanitizer.SanitizeByInteger(text, 2)
	end,
	TextTransparencyFrame = function(text)
		return Sanitizer.SanitizeByFloat(text, 5)
	end,
	StrokeJoinsFrame = function(text)
		return Sanitizer.SanitizeByAlphabet(text, 5)
	end,
	StrokeColorFrame = function(text)
		return Sanitizer.SanitizeByColorBoth(text)
	end,
	StrokeThicknessFrame = function(text)
		return Sanitizer.SanitizeByInteger(text, 2)
	end,
	StrokeTransparencyFrame = function(text)
		return Sanitizer.SanitizeByFloat(text, 5)
	end,
	FontFaceFrame = function(text)
		return Sanitizer.SanitizeByAlphabet(text, 15)
	end,
	FontWeightFrame = function(text)
		return Sanitizer.SanitizeByAlphabet(text, 10)
	end,
}
local inputpreviews = {
	StrokeColorFrame = function(str, button)
		if string.sub(str, 1, 1) == "#" then
			button.BackgroundColor3 = Color3.fromHex(str)
		else
			button.BackgroundColor3 = Color3.fromRGB(table.unpack(string.split(str, ", ")))
		end
	end,
	StrokeTransparencyFrame = function(str, button)
		button.BackgroundColor3 = Color3.new(1 - tonumber(str) or 0, 1 - tonumber(str) or 0, 1 - tonumber(str) or 0)
	end,
	TextColorFrame = function(str, button)
		if string.sub(str, 1, 1) == "#" then
			button.BackgroundColor3 = Color3.fromHex(str)
		else
			button.BackgroundColor3 = Color3.fromRGB(table.unpack(string.split(str, ", ")))
		end
	end,
	TextTransparencyFrame = function(str, button)
		button.BackgroundColor3 = Color3.new(1 - tonumber(str) or 0, 1 - tonumber(str) or 0, 1 - tonumber(str) or 0)
	end,
}
local dropdownFunctions = {
	FontFaceFrame = function(frame)
		DropdownFrame.Position = UDim2.fromOffset(frame.AbsolutePosition.X + frame.AbsoluteSize.X, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y + 4)
		DropdownFrame.Size = UDim2.fromOffset(frame.AbsoluteSize.X, DropdownButton.AbsoluteSize.Y * 4)

		for _, join in UI.Fonts do
			local button = DropdownButton:Clone()
			button.Text = join
			button.Font = Enum.Font[join]

			button.MouseButton1Click:Connect(function()
				frame.Text = button.Text
				UI[frame.Parent.Name] = button.Text

				for _, child in DropdownFrame:GetChildren() do
					if child:IsA("GuiButton") == true then
						child:Destroy()
					end
				end

				DropdownFrame.Position = UDim2.fromOffset(0, 0)
				DropdownFrame.Size = UDim2.fromOffset(0, 0)
			end)

			button.Parent = DropdownFrame
		end
	end,
	FontWeightFrame = function(frame)
		DropdownFrame.Position = UDim2.fromOffset(frame.AbsolutePosition.X + frame.AbsoluteSize.X, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y + 4)
		DropdownFrame.Size = UDim2.fromOffset(frame.AbsoluteSize.X, DropdownButton.AbsoluteSize.Y * 4)

		for _, join in Enum.FontWeight:GetEnumItems() do
			local button = DropdownButton:Clone()
			button.Text = join.Name

			button.MouseButton1Click:Connect(function()
				frame.Text = button.Text
				UI[frame.Parent.Name] = string.lower(button.Text)

				for _, child in DropdownFrame:GetChildren() do
					if child:IsA("GuiButton") == true then
						child:Destroy()
					end
				end

				DropdownFrame.Position = UDim2.fromOffset(0, 0)
				DropdownFrame.Size = UDim2.fromOffset(0, 0)
			end)

			button.Parent = DropdownFrame
		end
	end,
	StrokeJoinsFrame = function(frame)
		DropdownFrame.Position = UDim2.fromOffset(frame.AbsolutePosition.X + frame.AbsoluteSize.X, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y + 4)
		DropdownFrame.Size = UDim2.fromOffset(frame.AbsoluteSize.X, DropdownButton.AbsoluteSize.Y * 4)

		for _, join in Enum.LineJoinMode:GetEnumItems() do
			local button = DropdownButton:Clone()
			button.Text = join.Name

			button.MouseButton1Click:Connect(function()
				frame.Text = button.Text
				UI[frame.Parent.Name] = string.lower(button.Text)

				for _, child in DropdownFrame:GetChildren() do
					if child:IsA("GuiButton") == true then
						child:Destroy()
					end
				end

				DropdownFrame.Position = UDim2.fromOffset(0, 0)
				DropdownFrame.Size = UDim2.fromOffset(0, 0)
			end)

			button.Parent = DropdownFrame
		end
	end,
}


-- Setup
do
	-- Scaling
	do
		Internal.PluginWidget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			InputScroll.Size = UDim2.new(0.5, 0, 0, Internal.PluginWidget.AbsoluteSize.Y - TopbarFrame.AbsoluteSize.Y)
			PreviewScroll.Size = UDim2.new(0.5, 0, 0, Internal.PluginWidget.AbsoluteSize.Y - TopbarFrame.AbsoluteSize.Y)
			
			AdjustInputBoxSize()
		end)
		
		MainInputBox:GetPropertyChangedSignal("Text"):Connect(AdjustInputBoxSize)
	end
	
	-- Previewing
	do
		MainInputBox:GetPropertyChangedSignal("Text"):Connect(function()
			PreviewText.Text = MainInputBox.Text
			
			if #PreviewText.Text == 0 or PreviewText.Text == "Preview here." then
				PreviewText.Text = "Preview here."
				PreviewText.TextColor3 = Color3.fromRGB(255, 255, 255)
				PreviewText.TextTransparency = 0.5
			else
				PreviewText.TextTransparency = 0
				PreviewText.TextColor3 = MainInputBox.TextColor3
			end
		end)
	end
	
	-- Highlighting
	do
		MainInputBox:GetPropertyChangedSignal("SelectionStart"):Connect(function()
			task.wait(0.03)

			selectionStart = MainInputBox.SelectionStart
			if selectionStart > selectionEnd then
				selectionString = string.sub(MainInputBox.Text, selectionEnd + 1, selectionStart)
			else
				selectionString = string.sub(MainInputBox.Text, selectionStart, selectionEnd)
			end
		end)

		MainInputBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
			task.wait(0.03)

			selectionEnd = MainInputBox.CursorPosition - 1
			if selectionStart > selectionEnd then
				selectionString = string.sub(MainInputBox.Text, selectionEnd + 1, selectionStart)
			else
				selectionString = string.sub(MainInputBox.Text, selectionStart, selectionEnd)
			end
		end)
		
		MainFrame.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

			for _, child in DropdownFrame:GetChildren() do
				if child:IsA("GuiButton") == true then
					child:Destroy()
				end
			end

			DropdownFrame.Position = UDim2.fromOffset(0, 0)
			DropdownFrame.Size = UDim2.fromOffset(0, 0)
			
			ResetSelection()
			MainInputBox:ReleaseFocus()
		end)

		MainInputBox.FocusLost:Connect(function()
			if selectionStart > selectionEnd then
				MainInputBox.SelectionStart = selectionEnd + 1
				MainInputBox.CursorPosition = selectionStart
			else
				MainInputBox.SelectionStart = selectionStart
				MainInputBox.CursorPosition = selectionEnd + 1
			end
		end)
	end
end

 
-- Main
do
	for _, frame in buttons do
		if frame.Parent.Name == "MainFrame" then
			frame.MouseMoved:Connect(function()
				if Config.Settings.General.EnableHoverFrame.Value.Value == false then return end
				
				local result = UI.Examples[frame.Name]
				
				HoverFrame.NameText.Text = result.Title
				HoverFrame.DescriptionText.Text = result.Description
				HoverFrame.ExampleText.Text = result.Example
				
				HoverFrame.Visible = true
				HoverFrame.Position = UDim2.fromOffset(frame.AbsolutePosition.X, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y + 4)
			end)
			
			frame.MouseLeave:Connect(function()
				HoverFrame.Visible = false
				HoverFrame.Position = UDim2.fromOffset(0, 0)
			end)
		else
			frame.Parent.MouseEnter:Connect(function()
				if Config.Settings.General.EnableHoverFrame.Value.Value == false then return end
				
				local result = UI.Examples[frame.Parent.Name]

				HoverFrame.NameText.Text = result.Title
				HoverFrame.DescriptionText.Text = result.Description
				HoverFrame.ExampleText.Text = result.Example

				HoverFrame.Visible = true
				HoverFrame.Position = UDim2.fromOffset(frame.AbsolutePosition.X, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y + 4)
			end)

			frame.Parent.MouseLeave:Connect(function()
				HoverFrame.Visible = false
				HoverFrame.Position = UDim2.fromOffset(0, 0)
			end)
		end
	end
	
	for _, button in buttons do
		button.MouseButton1Click:Connect(function()
			if MainInputBox.SelectionStart == -1 or math.abs(selectionStart - selectionEnd) == 1 then return end

			startString = string.sub(MainInputBox.Text, 0, selectionStart - 1)
			endString = string.sub(MainInputBox.Text, selectionEnd + 1, -1)
			
			local replacementString, replacementArg1, replacementArg2 = nil, nil, nil
			if buttonFunctions[button.Parent.Name] ~= nil then
				replacementString, replacementArg1, replacementArg2 = buttonFunctions[button.Parent.Name](selectionString)
			elseif buttonFunctions[button.Name](selectionString) ~= nil then
				replacementString, replacementArg1, replacementArg2 = buttonFunctions[button.Name](selectionString)
			end
			
			MainInputBox.Text = `{startString}{replacementString}{endString}`
			
			selectionStart += replacementArg1 or 0
			selectionEnd = 1 + #MainInputBox.Text - #endString - (replacementArg2 or 0)
			
			MainInputBox.SelectionStart = selectionStart
			MainInputBox.CursorPosition = selectionEnd
		end)
	end
	 
	for _, inputbox in inputboxes do
		if inputbox:IsA("TextBox") == false then return end
		
		inputbox:GetPropertyChangedSignal("Text"):Connect(function()
			inputbox.Text = inputboxKeyingFunctions[inputbox.Parent.Name](inputbox.Text)
		end)
		
		inputbox.FocusLost:Connect(function()
			local frame = inputbox.Parent
			local result = inputboxFunctions[frame.Name](inputbox.Text)
			
			inputbox.Text = result
			UI[frame.Name] = inputbox.Text
			
			if inputpreviews[frame.Name] == nil then return end
			inputpreviews[frame.Name](inputbox.Text, frame.ActivateButton)
		end)
	end
	
	for _, dropdown in dropdowns do
		dropdown.MouseButton1Click:Connect(function()
			ResetDropdownFrame()
			
			dropdownFunctions[dropdown.Parent.Name](dropdown.Parent.InputBox)
		end)
	end

	for _, colorpicker in colorpickers do
		colorpicker.MouseButton1Click:Connect(function()
			local parent = colorpicker.Parent
			
			local newColorFrame = ColorPickerFrame:Clone()
			local mainFrame = newColorFrame.MainFrame
			local colorFrame = mainFrame.ColorWheelImage
			local selectFrame = colorFrame.ColorSelectFrame
			local previewFrame = colorFrame.ColorPreviewImage
			local hexFrame = mainFrame.HEXFrame
			local hsvFrame = mainFrame.HSVFrame
			local rgbFrame = mainFrame.RGBFrame
			local hueFrame = mainFrame.HueFrame

			newColorFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
				newColorFrame:Destroy()
				newColorFrame = nil
			end)

			colorFrame.MouseButton1Down:Connect(function()
				wheelHeldDown = true
			end)

			colorFrame.MouseButton1Up:Connect(function()
				wheelHeldDown = false
				hueHeldDown = false
			end)

			mainFrame.MouseButton1Up:Connect(function()
				wheelHeldDown = false
				hueHeldDown = false
			end)

			mainFrame.MouseMoved:Connect(function(x, y)
				if wheelHeldDown == true then 
					local wheelMidPosition = colorFrame.AbsolutePosition + (colorFrame.AbsoluteSize / 2)
					local currentPosition = (Vector2.new(x, y) - wheelMidPosition) / colorFrame.AbsoluteSize
					if currentPosition.Magnitude > 0.5 then
						currentPosition = (currentPosition.Unit / 2)
					end

					hWheel = currentPosition * Vector2.new(1, -1)
					hWheel = math.atan2(hWheel.Y, hWheel.X)
					hWheel = ((hWheel + math.pi) / (2 * math.pi)) * 360
					hWheel = math.clamp(hWheel / 360, 0, 1)
					sWheel = math.clamp(currentPosition.Magnitude * 2, 0, 1)
					vWheel = hueFrame.SelectFrame.Position.Y.Scale

					previewFrame.UIStroke.Color = Color3.fromHSV(hWheel, sWheel, 1 - vWheel)
					hueFrame.UIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(hWheel, sWheel, 1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })
					selectFrame.Position = UDim2.fromScale(currentPosition.X + 0.5, currentPosition.Y + 0.5)

					hexFrame.OneBox.Text = string.upper(`#{previewFrame.UIStroke.Color:ToHex()}`)
					hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = previewFrame.UIStroke.Color:ToHSV()
					rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(previewFrame.UIStroke.Color.R * 255), math.floor(previewFrame.UIStroke.Color.G * 255), math.floor(previewFrame.UIStroke.Color.B * 255)
				end

				if hueHeldDown == true then
					local hueMidPosition = hueFrame.AbsolutePosition + (hueFrame.AbsoluteSize / 2)
					local currentPosition = (Vector2.new(x, y) - hueMidPosition) / hueFrame.AbsoluteSize
					currentPosition = Vector2.new(0.5, math.clamp(currentPosition.Y + 0.5, 0, 1))

					vWheel = currentPosition.Y

					previewFrame.UIStroke.Color = Color3.fromHSV(hWheel, sWheel, 1 - vWheel)
					hueFrame.UIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(hWheel, sWheel, 1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })
					hueFrame.SelectFrame.Position = UDim2.fromScale(currentPosition.X, currentPosition.Y)

					hexFrame.OneBox.Text = string.upper(`#{previewFrame.UIStroke.Color:ToHex()}`)
					hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = previewFrame.UIStroke.Color:ToHSV()
					rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(previewFrame.UIStroke.Color.R * 255), math.floor(previewFrame.UIStroke.Color.G * 255), math.floor(previewFrame.UIStroke.Color.B * 255)
				end
			end)

			hueFrame.MouseButton1Down:Connect(function()
				hueHeldDown = true
			end)

			hueFrame.MouseButton1Up:Connect(function()
				wheelHeldDown = false
				hueHeldDown = false
			end)

			hexFrame.OneBox:GetPropertyChangedSignal("Text"):Connect(function()
				if #hexFrame.OneBox.Text == 1 then
					hexFrame.OneBox.CursorPosition = #hexFrame.OneBox.Text + 1
				end

				local result = string.sub(hexFrame.OneBox.Text, 2, -1)
				result = string.gsub(result, "[g-zG-Z%W]", "")
				result = string.sub(result, 1, 6)
				result = string.upper(result)

				hexFrame.OneBox.Text = `#{result}`
			end)

			hsvFrame.OneBox:GetPropertyChangedSignal("Text"):Connect(function()
				local dotReps = select(2, string.gsub(hsvFrame.OneBox.Text, "[&.]", ""))
				if dotReps > 1 then
					hsvFrame.OneBox.Text = `{string.gsub(hsvFrame.OneBox.Text, "[&.]", "")}.`
				end

				hsvFrame.OneBox.Text = string.gsub(hsvFrame.OneBox.Text, "[^%d.]", "")
				hsvFrame.OneBox.Text = string.sub(hsvFrame.OneBox.Text, 1, 5)
			end)

			hsvFrame.TwoBox:GetPropertyChangedSignal("Text"):Connect(function()
				local dotReps = select(2, string.gsub(hsvFrame.TwoBox.Text, "[&.]", ""))
				if dotReps > 1 then
					hsvFrame.TwoBox.Text = `{string.gsub(hsvFrame.TwoBox.Text, "[&.]", "")}.`
				end

				hsvFrame.TwoBox.Text = string.gsub(hsvFrame.TwoBox.Text, "[^%d.]", "")
				hsvFrame.TwoBox.Text = string.sub(hsvFrame.TwoBox.Text, 1, 5)
			end)

			hsvFrame.ThreeBox:GetPropertyChangedSignal("Text"):Connect(function()
				local dotReps = select(2, string.gsub(hsvFrame.ThreeBox.Text, "[&.]", ""))
				if dotReps > 1 then
					hsvFrame.ThreeBox.Text = `{string.gsub(hsvFrame.ThreeBox.Text, "[&.]", "")}.`
				end

				hsvFrame.ThreeBox.Text = string.gsub(hsvFrame.ThreeBox.Text, "[^%d.]", "")
				hsvFrame.ThreeBox.Text = string.sub(hsvFrame.ThreeBox.Text, 1, 5)
			end)

			rgbFrame.OneBox:GetPropertyChangedSignal("Text"):Connect(function()
				rgbFrame.OneBox.Text = string.gsub(rgbFrame.OneBox.Text, "%D", "")
				rgbFrame.OneBox.Text = string.sub(rgbFrame.OneBox.Text, 1, 3)
			end)

			rgbFrame.TwoBox:GetPropertyChangedSignal("Text"):Connect(function()
				rgbFrame.TwoBox.Text = string.gsub(rgbFrame.TwoBox.Text, "%D", "")
				rgbFrame.TwoBox.Text = string.sub(rgbFrame.TwoBox.Text, 1, 3)
			end)

			rgbFrame.ThreeBox:GetPropertyChangedSignal("Text"):Connect(function()
				rgbFrame.ThreeBox.Text = string.gsub(rgbFrame.ThreeBox.Text, "%D", "")
				rgbFrame.ThreeBox.Text = string.sub(rgbFrame.ThreeBox.Text, 1, 3)
			end)

			hexFrame.OneBox.FocusLost:Connect(function()
				for i = #hexFrame.OneBox.Text, 7, 1 do
					hexFrame.OneBox.Text ..= "F"
				end
				hexFrame.OneBox.Text = string.upper(hexFrame.OneBox.Text)

				local color = Color3.fromHex(hexFrame.OneBox.Text)

				previewFrame.UIStroke.Color = color
				hueFrame.UIGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })
				hueFrame.SelectFrame.Position = UDim2.fromScale(0.5, 1 - vWheel)

				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255),  math.floor(color.B * 255)
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = hWheel, sWheel, vWheel	
			end)

			hsvFrame.OneBox.FocusLost:Connect(function()
				local num = tonumber(hsvFrame.OneBox.Text) or 1
				num = math.clamp(num, 0, 1)
				hsvFrame.OneBox.Text = tostring(num)

				local color = Color3.fromHSV(tonumber(hsvFrame.OneBox.Text), tonumber(hsvFrame.TwoBox.Text), tonumber(hsvFrame.ThreeBox.Text))
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = color:ToHSV()

				AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)

				hexFrame.OneBox.Text = `#{color:ToHex()}`
				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255),  math.floor(color.B * 255)
			end)

			hsvFrame.TwoBox.FocusLost:Connect(function()
				local num = tonumber(hsvFrame.TwoBox.Text) or 1
				num = math.clamp(num, 0, 1)
				hsvFrame.TwoBox.Text = tostring(num)

				local color = Color3.fromHSV(tonumber(hsvFrame.OneBox.Text), tonumber(hsvFrame.TwoBox.Text), tonumber(hsvFrame.ThreeBox.Text))
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = color:ToHSV()

				AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)

				hexFrame.OneBox.Text = `#{color:ToHex()}`
				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255),  math.floor(color.B * 255)
			end)

			hsvFrame.ThreeBox.FocusLost:Connect(function()
				local num = tonumber(hsvFrame.ThreeBox.Text) or 1
				num = math.clamp(num, 0, 1)
				hsvFrame.ThreeBox.Text = tostring(num)

				local color = Color3.fromHSV(tonumber(hsvFrame.OneBox.Text), tonumber(hsvFrame.TwoBox.Text), tonumber(hsvFrame.ThreeBox.Text))
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = color:ToHSV()

				AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)

				hexFrame.OneBox.Text = `#{color:ToHex()}`
				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255),  math.floor(color.B * 255)
			end)

			rgbFrame.OneBox.FocusLost:Connect(function()
				local num = tonumber(rgbFrame.OneBox.Text) or 255
				num = math.clamp(num, 0, 255)
				rgbFrame.OneBox.Text = tostring(num)

				local color = Color3.fromRGB(rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text)
				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
				hWheel, sWheel, vWheel = color:ToHSV()

				AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)

				hexFrame.OneBox.Text = `#{color:ToHex()}`
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = color:ToHSV()
			end)

			rgbFrame.TwoBox.FocusLost:Connect(function()
				local num = tonumber(rgbFrame.TwoBox.Text) or 255
				num = math.clamp(num, 0, 255)
				rgbFrame.TwoBox.Text = tostring(num)

				local color = Color3.fromRGB(rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text)
				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
				hWheel, sWheel, vWheel = color:ToHSV()

				AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)

				hexFrame.OneBox.Text = `#{color:ToHex()}`
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = color:ToHSV()
			end)

			rgbFrame.ThreeBox.FocusLost:Connect(function()
				local num = tonumber(rgbFrame.ThreeBox.Text) or 255
				num = math.clamp(num, 0, 255)
				rgbFrame.ThreeBox.Text = tostring(num)

				local color = Color3.fromRGB(rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text)
				rgbFrame.OneBox.Text, rgbFrame.TwoBox.Text, rgbFrame.ThreeBox.Text = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
				hWheel, sWheel, vWheel = color:ToHSV()

				AdjustColorWheelGuis(previewFrame, hueFrame, selectFrame, color)

				hexFrame.OneBox.Text = `#{color:ToHex()}`
				hsvFrame.OneBox.Text, hsvFrame.TwoBox.Text, hsvFrame.ThreeBox.Text = color:ToHSV()
			end)

			mainFrame.ConfirmButton.MouseButton1Click:Connect(function()
				local r, g, b = math.floor(previewFrame.UIStroke.Color.R * 255), math.floor(previewFrame.UIStroke.Color.G * 255), math.floor(previewFrame.UIStroke.Color.B * 255)
				
				colorpicker.Parent.ActivateButton.BackgroundColor3 = Color3.fromRGB(r, g, b)
				colorpicker.Parent.InputBox.Text = `{r}, {g}, {b}`

				hWheel, sWheel, vWheel = 0, 0, 1

				newColorFrame:Destroy()
			end)

			newColorFrame.Parent = Internal.PluginWidget
		end)
	end
end


-- Cleanup
do
end