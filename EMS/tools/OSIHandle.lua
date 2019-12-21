--[[
	OnScreenInformation Handle
	Author: MadShadow

	Ermöglicht die gleichzeitige Verwendung mehrerer OnScreenInformation.
	Benötigt den S5Hook.
	
	Beispiel:
	function MyOSI(eID, active, x, y)
		if active then
			S5Hook.OSIDrawImage(myImg, x-myImgW/2, y-myImgH/2 - 40, myImgW, myImgH)
		else
			S5Hook.OSIDrawText("eID: " .. eID, 3, x+25, y, 255, 255, 128, 255)
		end
	end
	myOSIId = OSI.Register(MyOSI);
	...
	OSI.RemoveOSI(myOSIId);
]]

OSI = {Active=false,Callbacks={}};

function OSI.RegisterOSI(_function)
	assert(S5Hook, "S5Hook not found!");
	local id = 0;
	while(OSI.Callbacks[id]~=nil) do
		id = id + 1;
	end
	OSI.Callbacks[id] = _function;
	if not OSI.Active then
		S5Hook.OSISetDrawTrigger(OSI.CharCallbacks);
		OSI.Active = true;
	end
	return id;
end

function OSI.RemoveOSI(_id)
	OSI.Callbacks[_id] = nil;
	for k,v in pairs(OSI.Callbacks) do
		return;
	end
	S5Hook.OSISetDrawTrigger()
	OSI.Active = false;
end

function OSI.CharCallbacks(eID, active, x, y)
	for k, f in pairs(OSI.Callbacks) do
		f(eID, active, x, y);
	end
end