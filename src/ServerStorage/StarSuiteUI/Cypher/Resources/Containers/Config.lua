-- Services


-- Libraries


-- Upvalues


-- Constants


-- Variables


-- Module
local config = 
	{
		PluginVersion = '0.5a',

		ButtonTitle = 'Cypher',
		ButtonDescription = 'A visual scripting platform for UI.',
		ButtonIcon = 'rbxassetid://12251161436',

		WidgetTitle = 'StarSuite - Cypher',
		WidgetEnabledAllTimes = true,
		WidgetDockState = Enum.InitialDockState.Float,
		WidgetInitialize = false,
		WidgetOverride = false,
		WidgetSizeX = 800,
		WidgetSizeY = 450,
		WidgetMinSizeX = 800,
		WidgetMinSizeY = 450,

		Settings = {
			General = {
			},

			Appearance = {
				DarkMode = true, -- FLAG
			},

			Experimental = {
				EnableBetaFeatures = false, -- FLAG
			},

			Keybinds = {
			},
		},
	}

return config