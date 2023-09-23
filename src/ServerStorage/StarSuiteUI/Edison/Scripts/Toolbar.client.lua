--!nocheck


-- Services
local _PLAYERS = game:GetService("Players")
local _SELECTION = game:GetService("Selection")
local _STUDIOSERVICE = game:GetService("StudioService")


-- Libraries
local Plugin = script.Parent.Parent
local Templates = Plugin.Resources.UI

local Sanitizer = require(Plugin.Library.sanitizer)

local Config = require(Plugin.Resources.Containers.Config)
local Internal = require(Plugin.Resources.Containers.Internal)
local UI = require(Plugin.Resources.Containers.UI)
local FileFormats = require(Plugin.Resources.Containers.FileFormats)


-- Upvalues


-- Yield
repeat task.wait() until Internal.LoaderLoaded == true


-- Constants
local LOCALPLAYER = _STUDIOSERVICE:GetUserId()


-- Variables
local itemsToDelete = {}
local mainInputConnection = nil

local generalSettings = Config.Settings.General
local experimentalSettings = Config.Settings.Experimental

local MainFrame = Internal.PluginWidget.MainFrame
local ToolFrame = Internal.PluginWidget.ToolFrame
local TransitionFrame = Internal.PluginWidget.TransitionFrame
local ToolButtonFrame = MainFrame.TopbarFrame.ToolButtonFrame.ScrollingFrame

local GeneralSettingsFrame = Internal.PluginWidget.GeneralSettingsFrame
local ExperimentalSettingsFrame = Internal.PluginWidget.ExperimentalSettingsFrame

local MainInputBox = MainFrame.InputScroll.TextBox
local PreviewBox = MainFrame.PreviewScroll.PreviewText

local NewCanvasFrame = Templates.NewCanvasFrame
local NewCanvasButton = Templates.NewCanvasButton
local EraseCanvasFrame = Templates.EraseCanvasFrame
local CanvasPropertiesFrame = Templates.CanvasPropertiesFrame

local ToolButton = Templates.ToolButton
local DropdownFrame = Templates.DropdownFrame
local DropdownButton = Templates.DropdownButton

local TabBarFrame = MainFrame.TopbarFrame.TabBarFrame.ScrollingFrame

local TopButtonFrame = MainFrame.TopbarFrame.TopButtonFrame.ButtonFrame
local TopButtons = {
	TopButtonFrame.FileButton,
	TopButtonFrame.EditButton,
	TopButtonFrame.SettingsButton,
	TopButtonFrame.HelpButton,
}
local buttonCollections = {
	FileButton = {
		"Create New Canvas",
		"Erase All Canvas",
		"Load From File",
		"Load From HTTP",
	},
	EditButton = {
		"Canvas Properties",
	},
	SettingsButton = {
		"General",
		"Experimental",
	},
	HelpButton = {
		"Overview",
		"Guide",
		"Terms Of Use",
	},
}


-- Remotes

 
-- Functions
local function ResetToolFrame()
	for _, button in ToolFrame:GetChildren() do
		if button:IsA("GuiButton") == true then
			button:Destroy()
		end
	end
	
	ToolFrame.Position = UDim2.fromOffset(0, 24)
	ToolFrame.Visible = false
end
local function DeleteItems()
	for _, item in itemsToDelete do
		item:Destroy()
	end
end
local function BindMainInputConnection(canvasIndex: number?)
	local activeCanvasIndex = canvasIndex or 1
	
	mainInputConnection = MainInputBox:GetPropertyChangedSignal("Text"):Connect(function()
		Internal.Canvas[activeCanvasIndex].Text = MainInputBox.Text
		
		Internal.Canvas[activeCanvasIndex].Meta.CharacterLength = #MainInputBox.Text
		Internal.Canvas[activeCanvasIndex].Meta.FileSize = `{#MainInputBox.Text} bytes`
	end)
end
local function CreateTabButton(nameInput: string)
	local newButton = NewCanvasButton:Clone()
	newButton.MouseButton1Click:Connect(function()
		-- Reset tab button colors
		do
			for _, button in TabBarFrame:GetChildren() do
				if button:IsA("TextButton") == false then continue end
				button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			end
			newButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
		end

		-- Reset main inputbox connection and text and selection
		do
			mainInputConnection:Disconnect()
			MainInputBox.Text = Internal.Canvas[newButton.LayoutOrder].Text
			BindMainInputConnection(newButton.LayoutOrder)

			Internal.ActiveCanvas = newButton.LayoutOrder

			MainInputBox.SelectionStart = #MainInputBox.Text + 1
			MainInputBox.CursorPosition = #MainInputBox.Text + 1
		end

		-- Reset canvas property textboxes
		do
			ToolButtonFrame.FontFrame.FontFaceFrame.InputBox.Text = Internal.Canvas[newButton.LayoutOrder].TextFont
			ToolButtonFrame.StyleFrame.TextColorFrame.InputBox.Text = `{math.floor(Internal.Canvas[newButton.LayoutOrder].TextColor.R * 255)}, {math.floor(Internal.Canvas[newButton.LayoutOrder].TextColor.G * 255)}, {math.floor(Internal.Canvas[newButton.LayoutOrder].TextColor.B * 255)}`
			ToolButtonFrame.StyleFrame.TextSizeFrame.InputBox.Text = Internal.Canvas[newButton.LayoutOrder].TextSize
			ToolButtonFrame.StyleFrame.TextColorFrame.ActivateButton.BackgroundColor3 = Internal.Canvas[newButton.LayoutOrder].TextColor
			MainInputBox.TextColor3 = Internal.Canvas[newButton.LayoutOrder].TextColor
			MainInputBox.TextSize = Internal.Canvas[newButton.LayoutOrder].TextSize
			MainInputBox.FontFace = Font.fromEnum(Enum.Font[Internal.Canvas[newButton.LayoutOrder].TextFont])
			PreviewBox.TextColor3 = MainInputBox.TextColor3
			PreviewBox.TextSize = MainInputBox.TextSize
			PreviewBox.FontFace = MainInputBox.FontFace
		end
	end)

	newButton.Text = nameInput
	newButton.Name = `{nameInput}Button`
	newButton:SetAttribute("InWorkspace", false)
	newButton.LayoutOrder = #TabBarFrame:GetChildren() - 1
	newButton.Parent = TabBarFrame

	return newButton
end

local buttonFunctions = {
	FileButton = {
		function()
			local newCanvasFrame = NewCanvasFrame:Clone()
			local nameInputBox = newCanvasFrame.PropertiesFrame.MetaFrame.NameFrame.InputBox
			local colorInputBox = newCanvasFrame.PropertiesFrame.StyleFrame.TextColorFrame.InputBox
			local sizeInputBox = newCanvasFrame.PropertiesFrame.StyleFrame.TextSizeFrame.InputBox
			local fontFaceFrame = newCanvasFrame.PropertiesFrame.FontFrame.FontFaceFrame
			local warningText = newCanvasFrame.FooterFrame.WarningText
			local confirmButton = newCanvasFrame.FooterFrame.ConfirmButton
			local cancelButton = newCanvasFrame.NameText.CancelButton

			warningText.Text = if Internal.Canvas[nameInputBox.Text] ~= nil then "Name already exists!" else ""

			nameInputBox:GetPropertyChangedSignal("Text"):Connect(function()
				nameInputBox.Text = string.sub(nameInputBox.Text, 0, 16)
				warningText.Text = if #nameInputBox.Text <= 0 then "Name cannot be empty!" else ""
			end)

			colorInputBox:GetPropertyChangedSignal("Text"):Connect(function()
				colorInputBox.Text = Sanitizer.SanitizeByColorRGB(colorInputBox.Text)
			end)

			colorInputBox.FocusLost:Connect(function()
				local result = Sanitizer.CleanseByColorRGB(colorInputBox.Text, 255)
				colorInputBox.Text = `{result[1]}, {result[2]}, {result[3]}`
			end)

			sizeInputBox:GetPropertyChangedSignal("Text"):Connect(function()
				sizeInputBox.Text = Sanitizer.SanitizeByInteger(sizeInputBox.Text, 2)
			end)

			sizeInputBox.FocusLost:Connect(function()
				sizeInputBox.Text = tostring(math.clamp(tonumber(sizeInputBox.Text), 1, 96))
			end)

			fontFaceFrame.DropdownButton.MouseButton1Click:Connect(function()
				if newCanvasFrame:FindFirstChild("DropdownFrame") ~= nil then newCanvasFrame.DropdownFrame:Destroy() end

				local newDropdownFrame = DropdownFrame:Clone()
				newDropdownFrame.Position = UDim2.new(1, 5, 0, 14)
				newDropdownFrame.Size = UDim2.fromOffset(fontFaceFrame.InputBox.AbsoluteSize.X, DropdownButton.AbsoluteSize.Y * 4)

				for _, join in UI.Fonts do
					local button = DropdownButton:Clone()
					button.Text = join
					button.Font = Enum.Font[join]
					button.ZIndex = 36

					button.MouseButton1Click:Connect(function()
						fontFaceFrame.InputBox.Text = button.Text

						for _, child in newDropdownFrame:GetChildren() do
							if child:IsA("GuiButton") == true then
								child:Destroy()
							end
						end

						newDropdownFrame:Destroy()
					end)

					button.Parent = newDropdownFrame
				end

				newDropdownFrame.Parent = fontFaceFrame.InputBox
			end)

			fontFaceFrame.InputBox.FocusLost:Connect(function()
				fontFaceFrame.InputBox.Text = UI.SearchForFont(fontFaceFrame.InputBox.Text)
			end)

			confirmButton.MouseButton1Click:Connect(function()
				if #nameInputBox.Text <= 0 then return end

				local newButton = CreateTabButton(nameInputBox.Text)

				Internal.Canvas[newButton.LayoutOrder] = { 
					Text = "", 
					TextColor = Color3.fromRGB(string.split(colorInputBox.Text, ", ")[1], string.split(colorInputBox.Text, ", ")[2], string.split(colorInputBox.Text, ", ")[3]), 
					TextSize = tonumber(sizeInputBox.Text), 
					TextFont = fontFaceFrame.InputBox.Text,
					Meta = { 
						CanvasName = nameInputBox.Text,
						Author = LOCALPLAYER,
						CreationDate = `{os.date("%x")}, {os.date("%X")}`,
						PlaceId = game.PlaceId,
						CharacterLength = 0,
						FileSize = 0,
						InWorkspace = "FALSE",
						Inherited = "NIL",
						IsImported = "FALSE",
						ImportSource = "NIL",
						SourceExtension = "NIL",
					}
				}

				TransitionFrame.Visible = false
				newCanvasFrame:Destroy()
			end)

			cancelButton.MouseButton1Click:Connect(function()
				TransitionFrame.Visible = false
				newCanvasFrame:Destroy()
			end)

			newCanvasFrame.Parent = Internal.PluginWidget
			TransitionFrame.Visible = true
			table.insert(itemsToDelete, newCanvasFrame) 
		end,
		function()
			local eraseCanvasFrame = EraseCanvasFrame:Clone()

			eraseCanvasFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
				TransitionFrame.Visible = false
				eraseCanvasFrame:Destroy()
			end)

			eraseCanvasFrame.ConfirmButton.MouseButton1Click:Connect(function()
				TransitionFrame.Visible = false
				eraseCanvasFrame:Destroy()

				-- Clear tab buttons
				for _, tab in TabBarFrame:GetChildren() do
					if tab:IsA("TextButton") == false then continue end
					if tab.Name == "EmptyCanvasButton" then continue end

					tab:Destroy()
				end

				-- Reset external and internal states and selection
				do
					Internal.Canvas = {
						{ 
							Text = "", 
							TextColor = Color3.fromRGB(255, 255, 255), 
							TextSize = 14, 
							TextFont = "SourceSans",
							Meta = { 
								CanvasName = "Empty Canvas",
								Author = LOCALPLAYER,
								CreationDate = `{os.date("%x")}, {os.date("%X")}`,
								PlaceId = game.PlaceId,
								CharacterLength = 0,
								FileSize = 0,
								InWorkspace = "FALSE",
								Inherited = "NIL",
								IsImported = "FALSE",
								ImportSource = "NIL",
								SourceExtension = "NIL",
							}
						},
					}
					_SELECTION:Set({})
					Internal.ActiveCanvas = 1
					TabBarFrame.EmptyCanvasButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				end

				-- Reset main input boxes and connections
				do
					mainInputConnection:Disconnect()
					MainInputBox.Text = Internal.Canvas[1].Text
					BindMainInputConnection(1)

					ToolButtonFrame.FontFrame.FontFaceFrame.InputBox.Text = Internal.Canvas[1].TextFont
					ToolButtonFrame.StyleFrame.TextColorFrame.InputBox.Text = `{math.floor(Internal.Canvas[1].TextColor.R * 255)}, {math.floor(Internal.Canvas[1].TextColor.G * 255)}, {math.floor(Internal.Canvas[1].TextColor.B * 255)}`
					ToolButtonFrame.StyleFrame.TextSizeFrame.InputBox.Text = Internal.Canvas[1].TextSize
					ToolButtonFrame.StyleFrame.TextColorFrame.ActivateButton.BackgroundColor3 = Internal.Canvas[1].TextColor
					MainInputBox.TextColor3 = Internal.Canvas[1].TextColor
					MainInputBox.TextSize = Internal.Canvas[1].TextSize
					MainInputBox.FontFace = Font.fromEnum(Enum.Font[Internal.Canvas[1].TextFont])
					PreviewBox.TextColor3 = MainInputBox.TextColor3
					PreviewBox.TextSize = MainInputBox.TextSize
					PreviewBox.FontFace = MainInputBox.FontFace
				end
			end)

			eraseCanvasFrame.Parent = Internal.PluginWidget
			TransitionFrame.Visible = true
		end,
		function()
			local result = _STUDIOSERVICE:PromptImportFiles(FileFormats)
			if result == nil then 
				if generalSettings.SuppressFrame.Value.Value == false then
					warn("Edison - 1 or more of your file sizes are larger than 100MB. Import operation aborted.")
				end
				
				return
			end
			if #result <= 0 then
				if generalSettings.SuppressFrame.Value.Value == false then
					warn("Edison - No files selected. Import operation aborted.")
				end
				
				return
			end

			for _, file in result do
				local ext = string.split(file.Name, ".")
				ext = ext[#ext]

				local newButton = CreateTabButton(file.Name)

				Internal.Canvas[newButton.LayoutOrder] = { 
					Text = file:GetBinaryContents(), 
					TextColor = Color3.fromRGB(255, 255, 255), 
					TextSize = 14, 
					TextFont = "SourceSans",
					Meta = { 
						CanvasName = file.Name,
						Author = LOCALPLAYER,
						CreationDate = `{os.date("%x")}, {os.date("%X")}`,
						PlaceId = game.JobId,
						CharacterLength = file:GetBinaryContents(),
						FileSize = `{#file:GetBinaryContents()} bytes`,
						InWorkspace = "FALSE",
						Inherited = "NIL",
						IsImported = "TRUE",
						ImportSource = file.Name,
						SourceExtension = ext,
					}
				}
			end
		end,
		function()
			if experimentalSettings.EnableHTTPImports.Value == false then
				warn("Edison - Beta feature not enabled.")
			end
		end,
	},
	EditButton = {
		function()
			local canvasPropertiesFrame = CanvasPropertiesFrame:Clone()
			local metaFrame = canvasPropertiesFrame.MainFrame.MetaFrame
			
			local meta = Internal.Canvas[Internal.ActiveCanvas].Meta

			metaFrame.NameFrame.ValueText.Text = meta.CanvasName
			metaFrame.AuthorFrame.ValueText.Text = meta.Author
			metaFrame.CreationFrame.ValueText.Text = meta.CreationDate
			metaFrame.PlaceIdFrame.ValueText.Text = meta.PlaceId
			metaFrame.LengthFrame.ValueText.Text = meta.CharacterLength
			metaFrame.SizeFrame.ValueText.Text = meta.FileSize
			metaFrame.InWorkspaceFrame.ValueText.Text = meta.InWorkspace
			metaFrame.InheritedFrame.ValueText.Text = meta.Inherited
			metaFrame.ImportedFrame.ValueText.Text = meta.IsImported
			metaFrame.SourceFrame.ValueText.Text = meta.ImportSource
			metaFrame.ExtensionFrame.ValueText.Text = meta.SourceExtension

			canvasPropertiesFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
				canvasPropertiesFrame:Destroy()
				TransitionFrame.Visible = false
			end)

			canvasPropertiesFrame.Parent = Internal.PluginWidget
			TransitionFrame.Visible = true
		end,
	},
	SettingsButton = {
		function()
			GeneralSettingsFrame.Visible = true
			TransitionFrame.Visible = true
		end,
		function()
			ExperimentalSettingsFrame.Visible = true
			TransitionFrame.Visible = true
		end,
	},
	HelpButton = {
		function()
			Internal.PluginWidget.OverviewFrame.Visible = true
			TransitionFrame.Visible = true
		end,
		function()
			Internal.PluginWidget.GuideFrame.Visible = true
			TransitionFrame.Visible = true
		end,
		function()
			Internal.PluginWidget.TOSFrame.Visible = true
			TransitionFrame.Visible = true
		end,
	}
}


-- Setup
do
	MainFrame.InputBegan:Connect(function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		ResetToolFrame()
	end)
	
	_SELECTION.SelectionChanged:Connect(function()
		for _, tab in TabBarFrame:GetChildren() do
			if tab:IsA("TextButton") == false then continue end
			if tab:GetAttribute("InWorkspace") == false then continue end
			
			tab:Destroy()
		end
		
		for _, selection in _SELECTION:Get() do
			if selection:IsA("TextBox") == false and selection:IsA("TextButton") == false and selection:IsA("TextLabel") == false then continue end
			
			local newButton = NewCanvasButton:Clone()
			newButton.MouseButton1Click:Connect(function()
				-- Reset tab button colors
				do
					for _, button in TabBarFrame:GetChildren() do
						if button:IsA("TextButton") == false then continue end
						button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					end
					newButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				end

				-- Reset main inputbox connection and text and selection
				do
					Internal.ActiveCanvas = newButton.LayoutOrder
					
					mainInputConnection:Disconnect()
					MainInputBox.Text = selection.Text
					mainInputConnection = MainInputBox:GetPropertyChangedSignal("Text"):Connect(function()
						selection.Text = MainInputBox.Text
					end)

					MainInputBox.SelectionStart = #MainInputBox.Text + 1
					MainInputBox.CursorPosition = #MainInputBox.Text + 1
				end

				-- Reset canvas property textboxes
				do
					ToolButtonFrame.FontFrame.FontFaceFrame.InputBox.Text = selection.Font.Name
					ToolButtonFrame.StyleFrame.TextColorFrame.InputBox.Text = `{math.floor(selection.TextColor3.R * 255)}, {math.floor(selection.TextColor3.G * 255)}, {math.floor(selection.TextColor3.B * 255)}`
					ToolButtonFrame.StyleFrame.TextSizeFrame.InputBox.Text = selection.TextSize
					ToolButtonFrame.StyleFrame.TextColorFrame.ActivateButton.BackgroundColor3 = selection.TextColor3
					MainInputBox.TextColor3 = selection.TextColor3
					MainInputBox.TextSize = selection.TextSize
					MainInputBox.FontFace = selection.FontFace
					PreviewBox.TextColor3 = MainInputBox.TextColor3
					PreviewBox.TextSize = MainInputBox.TextSize
					PreviewBox.FontFace = MainInputBox.FontFace
				end
			end)

			newButton.Text = selection.Name
			newButton.Name = `{selection.Name}Button`
			newButton:SetAttribute("InWorkspace", true)
			newButton.LayoutOrder = #TabBarFrame:GetChildren() - 1
			newButton.Parent = TabBarFrame
		end
	end)
end


-- Main
do
	for _, button in TopButtons do
		button.MouseButton1Click:Connect(function()
			ResetToolFrame()
			
			if TransitionFrame.Visible == true then return end

			for index, option in buttonCollections[button.Name] do
				local toolButton = ToolButton:Clone()
				toolButton.Text = option

				toolButton.MouseButton1Click:Connect(function()
					buttonFunctions[button.Name][index]()

					ResetToolFrame()
				end)

				toolButton.Parent = ToolFrame
			end

			ToolFrame.Position = UDim2.fromOffset(button.AbsolutePosition.X, 24)
			ToolFrame.Visible = true
		end)
	end
	
	BindMainInputConnection(1)
	
	TabBarFrame.EmptyCanvasButton.MouseButton1Click:Connect(function()
		for _, button in TabBarFrame:GetChildren() do
			if button:IsA("TextButton") == false then continue end
			button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		end
		TabBarFrame.EmptyCanvasButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
		
		mainInputConnection:Disconnect()
		MainInputBox.Text = Internal.Canvas[1].Text
		BindMainInputConnection(1)
		
		Internal.ActiveCanvas = 1
		
		ToolButtonFrame.FontFrame.FontFaceFrame.InputBox.Text = Internal.Canvas[1].TextFont
		ToolButtonFrame.StyleFrame.TextColorFrame.InputBox.Text = `{math.floor(Internal.Canvas[1].TextColor.R * 255)}, {math.floor(Internal.Canvas[1].TextColor.G * 255)}, {math.floor(Internal.Canvas[1].TextColor.B * 255)}`
		ToolButtonFrame.StyleFrame.TextSizeFrame.InputBox.Text = Internal.Canvas[1].TextSize
		ToolButtonFrame.StyleFrame.TextColorFrame.ActivateButton.BackgroundColor3 = Internal.Canvas[1].TextColor
		MainInputBox.TextColor3 = Internal.Canvas[1].TextColor
		MainInputBox.TextSize = Internal.Canvas[1].TextSize
		MainInputBox.FontFace = Font.fromEnum(Enum.Font[Internal.Canvas[1].TextFont])
		PreviewBox.TextColor3 = MainInputBox.TextColor3
		PreviewBox.TextSize = MainInputBox.TextSize
		PreviewBox.FontFace = MainInputBox.FontFace
	end)
end


-- Cleanup
do
	Internal.Canvas[1] = {
		Text = "", 
		TextColor = Color3.fromRGB(255, 255, 255), 
		TextSize = 14, 
		TextFont = "SourceSans",
		Meta = {
			CanvasName = "Empty Canvas",
			Author = LOCALPLAYER,  
			CreationDate = `{os.date("%x")}, {os.date("%X")}`,
			PlaceId = game.PlaceId,  
			CharacterLength = 0,
			FileSize = "0 bytes",
			InWorkspace = "FALSE",
			Inherited = "NIL",
			IsImported = "FALSE",
			ImportSource = "NIL",
			SourceExtension = "NIL",
		},
	}
end