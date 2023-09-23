ting=0
Tool=script.Parent

if Tool:FindFirstChild("Splash") == nil then
SplashSound = Instance.new("Sound")
SplashSound.Name = "Splash"
SplashSound.SoundId = "http://www.roblox.com/asset/?id=10548108"
SplashSound.Parent = Tool
SplashSound.Volume = 0
SplashSound.Pitch = 2
else
SplashSound=Tool:FindFirstChild("Splash")
end


function onTouched(hit)
if ting==0 then
ting=1
--player=game.Players:GetPlayerFromCharacter(hit.Parent)

--if player ~= nil then

SplashSound:play()

new=Instance.new("Part")
new.Name="Wave"
new.formFactor=2
new.Size=Vector3.new(1,.4,1)
new.Anchored=true
new.CanCollide=false
new.Transparency=1

--hitPos=hit.Parent.Head.Position*Vector3.new(1,0,1)
hitPos=hit.Position*Vector3.new(1,0,1)
hight=(script.Parent.Position*Vector3.new(0,1,0))+script.Parent.Size*Vector3.new(0,.5,0)

new.Position=hitPos+hight

local d=script.particle:Clone()
d.Parent = new
d.Enabled = true
local d2=script.particle2:Clone()
d2.Parent = new
d2.Enabled = true
local d3=script.particle3:Clone()
d3.Parent = new
d3.Enabled = true


m=script.Mesh:clone()
m.Parent=new

s=script.GrowScript:clone()
s.Parent=new

new.Parent=game.Workspace

wait(.2)
--end
ting=0
end
end

script.Parent.Touched:connect(onTouched)
