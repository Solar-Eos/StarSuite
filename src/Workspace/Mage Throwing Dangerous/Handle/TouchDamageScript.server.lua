function onTouched(part)
	local h = part.Parent:findFirstChild("Humanoid")
	if h~=nil then
		h.Health = h.Health -40 -- -n tells how much health to subtract. You can also add health with +n
	end
end

script.Parent.Touched:connect(onTouched)
