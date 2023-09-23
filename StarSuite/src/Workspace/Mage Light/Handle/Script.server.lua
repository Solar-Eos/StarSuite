function Break(hit) 
hit:BreakJoints() 
end 

script.Parent.Touched:connect(Break)

