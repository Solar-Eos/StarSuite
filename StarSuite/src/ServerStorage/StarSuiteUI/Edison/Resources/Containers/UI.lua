-- Services


-- Libraries


-- Upvalues


-- Constants


-- Variables


-- Module
local ui = 
	{
		Fonts = {
			"AmaticSC",
			"Antique",
			"Arcade",
			"Arial",
			"Bangers",
			"Bodoni",
			"Cartoon",
			"Code",
			"Creepster",
			"DenkOne",
			"Fantasy",
			"Fondamento",
			"FredokaOne",
			"Garamond",
			"Gotham",
			"GrenzeGotisch",
			"Highway",
			"IndieFlower",
			"JosefinSans",
			"Jura",
			"Kalam",
			"Legacy",
			"LuckiestGuy",
			"Merriweather",
			"Michroma",
			"Nunito",
			"Oswald",
			"PatrickHand",
			"PermanentMarker",
			"Roboto",
			"RobotoCondensed",
			"Sarpanch",
			"SciFi",
			"SourceSans",
			"SpecialElite",
			"TitilliumWeb",
			"Ubuntu",
		},
		
		Examples = {
			BoldButton = { 
				Title = "<u><b>Bold</b></u>", 
				Description = "Weighs the selected text heavier, giving it emphasis.", 
				Example = "This text is <b>bolded</b>." 
			},
			ClearButton = { 
				Title = "<u><b>Clear Formatting</b></u>", 
				Description = "Clears the selected text of all formatting.", 
				Example = "This text is not formatted." 
			},
			ItalicButton = { 
				Title = "<u><b>Italics</b></u>", 
				Description = "Puts the selected text in cursive, giving it prominence.", 
				Example = "This text is now in <i>italics.</i>" 
			},
			LowercaseButton = { 
				Title = "<u><b>Force Lowercase</b></u>", 
				Description = "Forces the selected text to be lower-case, regardless of case. <br/><br/>Letters forced into lower-case may look different from their lower-case original.", 
				Example = "THIS TEXT IS NOW <sc>lower-case.</sc>" 
			},
			StrikeButton = { 
				Title = "<u><b>Strikethrough</b></u>", 
				Description = "Places a line between the selected text, indicating it is cancelled.", 
				Example = "This text is now <s>struck through.</s>" 
			},
			UnderlineButton = { 
				Title = "<u><b>Underline</b></u>", 
				Description = "Places a line beneath the selected text, visually highlighting it.", 
				Example = "This text is now <u>underlined.</u>" 
			},
			UppercaseButton = { 
				Title = "<u><b>Force Uppercase</b></u>", 
				Description = "Forces the selected text to be upper-case, regardless of case. <br/><br/>Letters forced into upper-case may look different from their upper-case original.", 
				Example = "This text is now <uc>upper-case.</uc>" 
			},
			FontFaceFrame = { 
				Title = "<u><b>Font Face</b></u>", 
				Description = "Changes the selected text's font.", 
				Example = "This text is now in <font face='Michroma'>Michroma.</font>" 
			}, 
			FontWeightFrame = { 
				Title = "<u><b>Font Weight</b></u>", 
				Description = "Changes the sizing and style of the selected font.", 
				Example = "This text is now <font weight='heavy'>heavy.</font>" 
			}, 
			AmpersandFrame = { 
				Title = "<u><b>Escape Ampersand (&amp;)</b></u>", 
				Description = "Escapes all ampersands in the selected text, allowing them to be displayed while ignoring rich text.", 
				Example = "This is an ampersand: &amp;" 
			}, 
			ApostropheFrame = { 
				Title = "<u><b>Escape Apostrophe (&apos;)</b></u>", 
				Description = "Escapes all apostrophes in the selected text, allowing them to be displayed while ignoring rich text.", 
				Example = "This is an apostrophe: &apos;" 
			}, 
			LeftAngularBracketFrame = { 
				Title = "<u><b>Escape Left Angular Bracket (&lt;)</b></u>", 
				Description = "Escapes all left angular brackets in the selected text, allowing them to be displayed while ignoring rich text.", 
				Example = "This is a left angular bracket: &lt;" 
			}, 
			QuoteFrame = { 
				Title = "<u><b>Escape Quotes (&quot;)</b></u>", 
				Description = "Escapes all quote marks in the selected text, allowing them to be displayed while ignoring rich text.", 
				Example = "This is a quote mark: &quot;" 
			}, 
			RightAngularBracketFrame = { 
				Title = "<u><b>Escape Right Angular Bracket (&gt;)</b></u>", 
				Description = "Escapes all right angular brackets in the selected text, allowing them to be displayed while ignoring rich text.", 
				Example = "This is a right angular bracket: &gt;" 
			}, 
			StrokeColorFrame = { 
				Title = "<u><b>Stroke Color</b></u>", 
				Description = "Changes the color of the stroke of the selected font.", 
				Example = "This text's stroke color is <stroke color='rgb(235,0,0)' joins='miter' thickness='1' transparency='0'>red</stroke>!" 
			}, 
			StrokeJoinsFrame = { 
				Title = "<u><b>Stroke Joins</b></u>", 
				Description = "Changes the joining mode of the stroke of the selected font. <br/>Available modes: miter, round, bevel", 
				Example = "This text's stroke join mode is <stroke color='rgb(255,255,255)' joins='miter' thickness='1' transparency='0'>miter</stroke>!" 
			}, 
			StrokeThicknessFrame = { 
				Title = "<u><b>Stroke Thickness</b></u>", 
				Description = "Changes the thickness of the stroke of the selected font.", 
				Example = "This text's stroke join mode is <stroke color='rgb(255,255,255)' joins='miter' thickness='3' transparency='0'>thicker</stroke>!" 
			}, 
			StrokeTransparencyFrame = { 
				Title = "<u><b>Stroke Transparency</b></u>", 
				Description = "Changes the opacity of the stroke of the selected font.", 
				Example = "This text's stroke looks <stroke color='rgb(255,255,255)' joins='miter' thickness='1' transparency='0.5'>translucent</stroke>!" 
			}, 
			TextColorFrame = { 
				Title = "<u><b>Text Color</b></u>", 
				Description = "Changes the color of the selected font.", 
				Example = "This text is in <font color='rgb(255,0,0)'>red</font>!" 
			}, 
			TextSizeFrame = { 
				Title = "<u><b>Text Size</b></u>", 
				Description = "Changes the size of the selected font.", 
				Example = "This text is <font size='16'>bigger</font>!" 
			}, 
			TextTransparencyFrame = { 
				Title = "<u><b>Text Size</b></u>", 
				Description = "Changes the opacity of the selected font.", 
				Example = "This text is <font transparency='0.5'>translucent</font>!" 
			}, 
		},
	}

function ui.SearchForFont(fontName: string)
	for _, font in ui.Fonts do
		if string.sub(string.lower(font), 1, #fontName) == string.lower(fontName) then
			return font
		end
	end
end

function ui.SearchForFontWeight(weightName: string)
	for _, weight in Enum.FontWeight:GetEnumItems() do
		if string.sub(string.lower(weight.Name), 1, #weightName) == string.lower(weightName) then
			return weight.Name
		end
	end
end

return ui