--!nocheck


-- Services


-- Libraries


-- Variables


-- Main
local sanitizer = {}


--[[ sanitizer.SanitizeByColorRGB(text)
PARAMETERS: 
- <string> text: The text to sanitize.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for color in RGB, allowing only numbers and commas to be keyed in. ]] 
function sanitizer.SanitizeByColorRGB(text: string)
	local sanitizedString
	
	sanitizedString = string.gsub(text, '[^0-9, ]', '')
	sanitizedString = string.sub(sanitizedString, 1, 1)
	
	return sanitizedString
end


--[[ sanitizer.SanitizeByColorHEX(text)
PARAMETERS: 
- <string> text: The text to sanitize.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for color in HEX, allowing only numbers, letters A-F (non-case-sensitive), and hashtags to be keyed in. ]] 
function sanitizer.SanitizeByColorHEX(text: string)
	local sanitizedString

	sanitizedString = string.gsub(text, '[^#0-9a-fA-F]', '')
	sanitizedString = string.sub(sanitizedString, 1, 7)

	return sanitizedString
end


--[[ sanitizer.SanitizeByColorBoth(text)
PARAMETERS: 
- <string> text: The text to sanitize.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for color in either RGB and HEX, allowing only numbers, commas, letters A-F (non-case-sensitive), and hashtags to be keyed in. ]] 
function sanitizer.SanitizeByColorBoth(text: string)
	local sanitizedString
	
	if string.sub(text, 1, 1) == '#' then
		sanitizedString = string.gsub(text, '[^#0-9a-fA-F]', '')
		sanitizedString = string.sub(sanitizedString, 1, 7)
	else
		sanitizedString = string.gsub(text, '[^0-9, ]', '')
		sanitizedString = string.sub(sanitizedString, 1, 13)
	end

	return sanitizedString
end


--[[ sanitizer.SanitizeByAlphanumeric(text, limit)
PARAMETERS: 
- <string> text: The text to sanitize.
- <number?> limit: The maximum amount of characters allowed. Defaults to -1, in which case no limit is imposed.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for alphabets and numbers, allowing only numbers and letters (non-case-sensitive) to be keyed in. ]] 
function sanitizer.SanitizeByAlphanumeric(text: string, limit: number?)
	return string.sub(string.gsub(text, '%W', ''), 1, limit)
end


--[[ sanitizer.SanitizeByAlphabet(text, limit)
PARAMETERS: 
- <string> text: The text to sanitize.
- <number?> limit: The maximum amount of characters allowed. Defaults to -1, in which case no limit is imposed.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for alphabets, allowing only letters (non-case-sensitive) to be keyed in. ]] 
function sanitizer.SanitizeByAlphabet(text: string, limit: number?)
	return string.sub(string.gsub(text, '%A', ''), 1, limit)
end


--[[ sanitizer.SanitizeByInteger(text, limit)
PARAMETERS: 
- <string> text: The text to sanitize.
- <number?> limit: The maximum amount of characters allowed. Defaults to -1, in which case no limit is imposed.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for whole numbers, allowing only numbers to be keyed in. ]] 
function sanitizer.SanitizeByInteger(text: string, limit: number?)
	return string.sub(string.gsub(text, '%D', ''), 1, limit)
end


--[[ sanitizer.SanitizeByFloat(text, limit)
PARAMETERS: 
- <string> text: The text to sanitize.
- <number?> limit: The maximum amount of characters allowed. Defaults to -1, in which case no limit is imposed.

RETURNS:
- <string> sanitizedText: The sanitized text.

Sanitizes a text for decimal numbers, allowing only numbers and decimal points (fullstop) to be keyed in. ]] 
function sanitizer.SanitizeByFloat(text: string, limit: number?)
	return string.sub(string.gsub(text, '[^0-9.]', ''), 1, limit)
end


--[[ sanitizer.CleanseByColorRGB(text, default)
PARAMETERS: 
- <string> text: The text to cleanse and format.
- <number?> default: The default color number to use when no such input exists for either spectrum. Defaults to 255.

RETURNS:
- <table> color: The resulting color.

Cleanses a text for proper RGB color input, displaying it in proper color format. Returns the components of the inputted color. ]] 
function sanitizer.CleanseByColorRGB(text: string, default: number?)
	local newDefault = math.clamp(default or 255, 0, 255)
	local nums = {}

	for _, color in string.split(text, ',') do
		local x = string.gsub(color, '%s+', '')
		if x == ' ' or x == '' or x == nil then continue end

		table.insert(nums, math.clamp(x, 0, 255))
	end

	return {nums[1] or newDefault or 255, nums[2] or newDefault or 255, nums[3] or newDefault or 255} 
end


--[[ sanitizer.CleanseByColorHEX(text, default)
PARAMETERS: 
- <string> text: The text to cleanse and format.
- <number?> default: The default color number to use when no such input exists for either spectrum. Defaults to 255.

RETURNS:
- <string> hex: The resulting HEX color based on input.

Cleanses a text for proper HEX color input, displaying it in proper color format. Returns the component of the inputted HEX color. ]] 
function sanitizer.CleanseByColorHEX(text: string, default: number?)
	local newDefault = string.format("%X", math.clamp(default or 255, 0, 255))
	local oldColor = string.gsub(text, '#', '')
	
	for i = #oldColor, 6, 1 do
		oldColor ..= newDefault
	end
	oldColor = '#' .. string.sub(oldColor, 1, 6)
	text = oldColor
	
	return oldColor
end


return sanitizer