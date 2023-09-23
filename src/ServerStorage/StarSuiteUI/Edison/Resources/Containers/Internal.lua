-- Services


-- Libraries
local Library = script.Parent.Parent.Parent.Library
local Value = require(Library.Value)


-- Upvalues


-- Constants


-- Variables


-- Module
local internal = 
	{
		LoaderLoaded = false,
		
		PluginMouse = "",
		PluginToolbar = "",
		PluginButton = "",
		PluginWidget = "",
		
		ActiveCanvas = 1,
		Canvas = {
			{
				Text = "", 
				TextColor = Color3.fromRGB(255, 255, 255), 
				TextSize = 14, 
				TextFont = "SourceSans",
				Meta = { 
					CanvasName = "Empty Canvas",
					Author = "",
					CreationDate = "",
					PlaceId = game.PlaceId,
					CharacterLength = 0,
					FileSize = 0,  
					InWorkspace = "NIL",
					Inherited = "NIL",
					IsImported = "NIL",
					ImportSource = "NIL",
					SourceExtension = "NIL",
				}
			},
		},
		SettingKeys = {
			General = {
				StartOnLaunchFrame = "EDISON_STARTONLAUNCH",
				SuppressFrame = "EDISON_SUPPRESSWARNINGS",
				EnableHoverFrame = "EDISON_ENABLEHOVER",
			},

			Experimental = {
				SmartHighlightingFrame = "EDISON_SMARTHIGHLIGHTING",
				SmartFormattingFrame = "EDISON_SMARTFORMATTING",
				HttpImportsFrame = "EDISON_HTTPIMPORTS",
				KeybindsFrame = "EDISON_MOREKEYBINDS",
			},

			Keybinds = {
			},
		}
	}

return internal