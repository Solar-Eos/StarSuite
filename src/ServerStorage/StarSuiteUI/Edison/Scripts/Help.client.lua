--!nocheck


-- Services
local _PLAYERS = game:GetService("Players")
local _SELECTION = game:GetService("Selection")
local _STUDIOSERVICE = game:GetService("StudioService")


-- Libraries
local Plugin = script.Parent.Parent
local Templates = Plugin.Resources.UI

local Value = require(Plugin.Library.Value)

local Internal = require(Plugin.Resources.Containers.Internal)


-- Upvalues


-- Yield
repeat task.wait() until Internal.LoaderLoaded == true


-- Constants


-- Variables
local TransitionFrame = Internal.PluginWidget.TransitionFrame
local GuideFrame = Internal.PluginWidget.GuideFrame
local OverviewFrame = Internal.PluginWidget.OverviewFrame
local TOSFrame = Internal.PluginWidget.TOSFrame

local PagesFrame = GuideFrame.PagesFrame

local currentPage = Value.new(1)
local guidePages = { GuideFrame.FirstFrame, GuideFrame.SecondFrame, GuideFrame.ThirdFrame }
local radioButtons = { PagesFrame.OneButton, PagesFrame.TwoButton, PagesFrame.ThreeButton }


-- Remotes

 
-- Functions


-- Setup
do
	OverviewFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
		OverviewFrame.Visible = false
	end)
	
	OverviewFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		TransitionFrame.Visible = OverviewFrame.Visible
	end)
	
	TOSFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
		TOSFrame.Visible = false
	end)

	TOSFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		TransitionFrame.Visible = TOSFrame.Visible
	end)
	
	GuideFrame.NameText.CancelButton.MouseButton1Click:Connect(function()
		GuideFrame.Visible = false
		plugin:SetSetting("EDISON_FIRSTTIME", true)
	end)

	GuideFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		TransitionFrame.Visible = GuideFrame.Visible
		currentPage:Change(1)
	end)

	GuideFrame.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end

		local result = math.clamp(currentPage.Value - input.Position.Z, 1, #guidePages)
		currentPage:Change(result)
	end)
	
	for i, button in radioButtons do
		button.MouseButton1Click:Connect(function()
			currentPage:Change(i)
		end)
	end
end


-- Main
do
	currentPage.Changed:Connect(function(old)
		for i = 1, #guidePages do
			if i == currentPage.Value then
				guidePages[i].Visible = true
				radioButtons[i].BackgroundColor3 = Color3.fromRGB(160, 160, 160)
				continue
			end

			guidePages[i].Visible = false
			radioButtons[i].BackgroundColor3 = Color3.fromRGB(75, 75, 75)
		end
	end)
end


-- Cleanup
do
	
end