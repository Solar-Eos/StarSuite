--!nocheck


-- Services


-- Libraries
local Plugin = script.Parent.Parent
local Home = Plugin.Parent
local Shared = Home.Shared

local PluginGlobals = require(Shared.PluginGlobals)
local Config = require(Plugin.Resources.Containers.Config)
local Internal = require(Plugin.Resources.Containers.Internal)


-- Upvalues


-- Constants
local PLUGIN_MOUSE = plugin:GetMouse()
local PLUGIN_TOOLBAR = plugin:CreateToolbar(PluginGlobals.ToolbarTitle)
local PLUGIN_BUTTON = PLUGIN_TOOLBAR:CreateButton(Config.ButtonTitle, Config.ButtonDescription, Config.ButtonIcon)
local PLUGIN_WIDGET = plugin:CreateDockWidgetPluginGui(Config.WidgetTitle, DockWidgetPluginGuiInfo.new(Config.WidgetDockState, Config.WidgetInitialize, Config.WidgetOverride, Config.WidgetSizeX, Config.WidgetSizeY, Config.WidgetMinSizeX, Config.WidgetMinSizeY))


-- Variables


-- Remotes


-- Functions


-- Setup
do
	PLUGIN_BUTTON.ClickableWhenViewportHidden = Config.WidgetEnabledAllTimes
	PLUGIN_WIDGET.Name = "StarSuite_Cypher"
	
	-- FLAG
	--for _, element in Plugin.Interface.ScreenGui:GetChildren() do
	--	element:Clone().Parent = PLUGIN_WIDGET
	--end
	--Plugin.Interface.ScreenGui:Destroy()

	Internal.PluginMouse = PLUGIN_MOUSE
	Internal.PluginToolbar = PLUGIN_TOOLBAR
	Internal.PluginButton = PLUGIN_BUTTON
	Internal.PluginWidget = PLUGIN_WIDGET
end


-- Main
do
	PLUGIN_BUTTON.Click:Connect(function()
		PLUGIN_WIDGET.Enabled = not PLUGIN_WIDGET.Enabled
	end)

	PLUGIN_WIDGET:GetPropertyChangedSignal("Enabled"):Connect(function()
		PLUGIN_BUTTON:SetActive(PLUGIN_WIDGET.Enabled)
	end)
end


-- Cleanup
do
	Internal.LoaderLoaded = true
end