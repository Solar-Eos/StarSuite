times=7

if script.Parent.className=="Part" then
for i=1, times do
script.Parent.Mesh.Scale=Vector3.new(i*.2,1,i*.2)+Vector3.new(1,0,1)
wait()
end
script.Parent.particle.Enabled = false
script.Parent.particle2.Enabled = false
script.Parent.particle3.Enabled = false
wait(1)
script.Parent:remove()
end
