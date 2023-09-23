-- Services


-- Libraries
local Plugin = script.Parent.Parent.Parent
local Library = Plugin.Library
local Resources = Plugin.Resources

local Value = require(Library.Value)


-- Upvalues


-- Constants


-- Variables


-- Module
local config = 
	{
		PluginVersion = '0.7.1a',

		ButtonTitle = 'Edison',
		ButtonDescription = 'A comprehensive and robust text editor. Compatible with rich text.',
		ButtonIcon = 'rbxassetid://12251161436',

		WidgetTitle = 'StarSuite - Edison',
		WidgetDockState = Enum.InitialDockState.Float,
		WidgetSizeX = 600,
		WidgetSizeY = 450,
		WidgetMinSizeX = 70,
		WidgetMinSizeY = 450,

		Settings = {
			General = {
				StartOnLaunchFrame = {
					Name = "Start Plugin On Launch",
					Value = Value.new(false),
					Description = "If enabled, the plugin will forcibly start when you first launch Studio.",
				}, -- FLAG
				SuppressFrame = {
					Name = "Suppress All Warnings",
					Value = Value.new(false),
					Description = "If enabled, the plugin will no longer show warning messages. <br/>Error messages will still be shown.",
				},
				EnableHoverFrame = {
					Name = "Enable Hovers",
					Value = Value.new(true),
					Description = "If enabled, hovering over a tool in the plugin topbar will show its description and examples.",
				},
			},

			Experimental = {
				SmartHighlightingFrame = {
					Name = "Smart Highlighting",
					Value = Value.new(false),
					Description = "The plugin now allows you to highlight tags immediately when you first highlight over them."
				}, -- FLAG
				SmartFormattingFrame = {
					Name = "Smart Formatting",
					Value = Value.new(false),
					Description = "The plugin will now detect if there are already existing tags, overwriting them if they do."
				}, -- FLAG
				HttpImportsFrame = {
					Name = "HTTP Imports",
					Value = Value.new(false),
					Description = "The plugin now allows importing from third-party text editors, such as Google Docs."
				}, -- FLAG
				KeybindsFrame = {
					Name = "More Keybinds",
					Value = Value.new(false),
					Description = "The plugin will now support additional keybinds."
				}, -- FLAG
			},

			Keybinds = {

			},
		},
	}

return config