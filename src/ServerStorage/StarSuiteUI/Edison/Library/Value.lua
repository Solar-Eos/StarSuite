--!nocheck


-- Services


-- Libraries


-- Types
export type Value = {
	_ChangedEvent: BindableEvent,
	_DestroyingEvent: BindableEvent,

	Value: any,

	Changed: RBXScriptSignal,
	Destroying: RBXScriptSignal,
}


-- Variables


-- Main
local ValueClass = {}
ValueClass.__index = ValueClass


function ValueClass.new(value: any): Value
	local changedEvent = Instance.new("BindableEvent")
	local destroyingEvent = Instance.new("BindableEvent")
	
	return setmetatable({
		_ChangedEvent = changedEvent,
		_DestroyingEvent = destroyingEvent,
		
		Value = value,
		
		Changed = changedEvent.Event,
		Destroying = destroyingEvent.Event
		
	}, ValueClass)
	
end


function ValueClass:Clone()
	local function DeepCopy(original)
		local copy = {}
		
		for k, v in original do
			if typeof(v) == "table" then
				v = DeepCopy(v)
			end
			
			copy[k] = v
		end
		
		return setmetatable(copy, ValueClass)
	end
	
	return DeepCopy(self)
end


function ValueClass:Destroy()
	self._DestroyingEvent:Fire()
	
	self._ChangedEvent:Destroy()
	self._DestroyingEvent:Destroy()
	
	setmetatable(self, nil)
	table.clear(self)
end


function ValueClass:Change(new: any)
	local old = self.Value
	
	self.Value = new
	self._ChangedEvent:Fire(old)
end


return ValueClass