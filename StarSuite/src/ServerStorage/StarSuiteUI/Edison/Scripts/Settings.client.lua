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


-- Variables
local generalSettings = Config.Settings.General
local experimentalSettings = Config.Settings.Experimental

local TransitionFrame = Internal.PluginWidget.TransitionFrame
local SettingsHoverFrame = Internal.PluginWidget.SettingsHoverFrame

local GeneralSettingsFrame = Internal.PluginWidget.GeneralSettingsFrame
local ExperimentalSettingsFrame = Internal.PluginWidget.ExperimentalSettingsFrame


-- Remotes

 
-- Functions


-- Setup
do
	
end


-- Main
do
	for _, settingFrame in { GeneralSettingsFrame, ExperimentalSettingsFrame } do
		local mainFrame = settingFrame.MainFrame.MetaFrame
		local keyName = string.gsub(settingFrame.Name, "SettingsFrame", "")

		settingFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
			settingFrame.Visible = false
			TransitionFrame.Visible = false
		end)

		for _, frame in mainFrame:GetChildren() do
			if frame:IsA("Frame") == false then continue end

			-- Init
			do
				local result = plugin:GetSetting(Internal.SettingKeys[keyName][frame.Name])
				
				Config.Settings[keyName][frame.Name].Value:Change(result)
				frame.ToggleButton.BackgroundColor3 = if result == true then Color3.fromRGB(0, 230, 0) else Color3.fromRGB(230, 0, 0)
			end

			-- Update
			do
				frame.MouseLeave:Connect(function()
					SettingsHoverFrame.Visible = false
				end)

				frame.MouseMoved:Connect(function(x, y)
					SettingsHoverFrame.Visible = true
					SettingsHoverFrame.DescriptionText.Text = Config.Settings[keyName][frame.Name].Description
					SettingsHoverFrame.Position = UDim2.fromOffset(x + 14, y + 14) 
				end)

				frame.ToggleButton.MouseButton1Click:Connect(function()
					Config.Settings[keyName][frame.Name].Value:Change(not Config.Settings[keyName][frame.Name].Value.Value)
					plugin:SetSetting(Internal.SettingKeys[keyName][frame.Name], Config.Settings[keyName][frame.Name].Value.Value)

					frame.ToggleButton.BackgroundColor3 = if Config.Settings[keyName][frame.Name].Value.Value == true then Color3.fromRGB(0, 230, 0) else Color3.fromRGB(230, 0, 0)
				end)
			end
		end
	end
end


-- Cleanup
do	
end