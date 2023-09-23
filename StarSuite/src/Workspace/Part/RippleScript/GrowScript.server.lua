times=30

if script.Parent.className=="Part" then
for i=1, times do
script.Parent.Mesh.Scale=Vector3.new(i*.2,1,i*.2)+Vector3.new(1,0,1)
wait()
end
script.Parent.Decal.Transparency = .1
wait()
script.Parent.Decal.Transparency = .5
wait()
script.Parent.Decal.Transparency = .75
wait()
script.Parent.Decal.Transparency = 1
wait()
script.Parent:remove()
end
