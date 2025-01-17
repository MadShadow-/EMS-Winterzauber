--[[
		Sync Version 3.0
		
		-- Sync.CallNoSync("Message","Hello")
		-- Sync.Call("Logic.CreateEntity", Entities.PU_Hero3, 15000,15000,0,1)
		-- MPMenu.Screen_ToT1()
]]
Sync = {
	PrepareChar = string.char(2),
	AcknowledgeChar = string.char(3),
	NoSyncChar = string.char(4)
}

function Sync.Init()
	-- allow use of tributes
	GameCallback_FulfillTribute = function() return 1 end
	
	Sync.UseWhitelist = false
	Sync.Whitelist = {
	};
	
	if not CNetwork then
		-- numOfTributes determines actions at the same time
		local numberOfTributes = 150;
		Sync.Tributes = {}
		for playerId = 1,8 do
			for i = 1, numberOfTributes do
				Sync.CreateNewTribut(playerId)
			end
		end
	end
	
	-- this overwrite should be the last one, to overwrite this method
	-- so no one can accidentely filter out sync messages
	if CNetwork then
		Sync.ApplicationCallback_ReceivedChatMessageRaw = ApplicationCallback_ReceivedChatMessageRaw
		ApplicationCallback_ReceivedChatMessageRaw = function(_name, _msg, _color, _allied, _sender)
			if string.find(_msg, Sync.PrepareChar) == 1 then
				Sync.OnPrepareMessageArrived(string.sub(_msg, 2))
				return true;
			elseif string.find(_msg, Sync.AcknowledgeChar) == 1 then
				Sync.OnAcknowledgeMessageArrived(string.sub(_msg, 2), _senderID)
				return true;
			elseif string.find(_msg, Sync.NoSyncChar) == 1 then
				Sync.ExecuteFunctionByString(string.sub(_msg,2))
				return true;
			end
			return Sync.ApplicationCallback_ReceivedChatMessageRaw(_name, _msg, _color, _allied, _sender)
		end
	else
		Sync.MPGame_ApplicationCallback_ReceivedChatMessage = MPGame_ApplicationCallback_ReceivedChatMessage;
		MPGame_ApplicationCallback_ReceivedChatMessage = function( _msg, _alliedOnly, _senderID )
			if string.find(_msg, Sync.PrepareChar) == 1 then
				Sync.OnPrepareMessageArrived(string.sub(_msg, 2))
				return
			elseif string.find(_msg, Sync.AcknowledgeChar) == 1 then
				Sync.OnAcknowledgeMessageArrived(string.sub(_msg, 2), _senderID)
				return
			elseif string.find(_msg, Sync.NoSyncChar) == 1 then
				Sync.ExecuteFunctionByString(string.sub(_msg,2))
				return
			end
			Sync.MPGame_ApplicationCallback_ReceivedChatMessage(_msg, _alliedOnly, _senderID);
		end
	end
	
	if not CNetwork then
		Sync.Call = function(_func, ...)
			local player = GUI.GetPlayerID()
			local id = Sync.GetFreeTributeId(player)
			if not id then
				Message("Sync Failed: No Tribute Id's left")
				return
			end
			Sync.Tributes[id].Used = true
			Sync.Tributes[id].AckData = {}
			for i = 1, 8 do
				Sync.Tributes[id].AckData[i] = ((XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) ~= 1) or GUI.GetPlayerID() == i or (XNetwork.GameInformation_IsHumanPlayerThatLeftAttachedToPlayerID(i) == 1))
			end
			local fs = Sync.CreateFunctionString( _func, unpack(arg))
			Sync.OverwriteTributeCallback(id, fs)
			Sync.Send(Sync.PrepareChar..id..fs);
		end
	end
	Sync.CallNoSync = function(_func, ...)
		Sync.Send(Sync.NoSyncChar .. Sync.CreateFunctionString(_func, unpack(arg)))
	end
end
function Sync.Call(_func, ...)
	local player = GUI.GetPlayerID()
	local id = Sync.GetFreeTributeId(player)
	if not id then
		Message("Sync Failed: No Tribute Id's left")
		return
	end
	Sync.Tributes[id].Used = true
	Sync.Tributes[id].AckData = {}
	for i = 1, 8 do
		Sync.Tributes[id].AckData[i] = ((XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i) ~= 1) or GUI.GetPlayerID() == i or (XNetwork.GameInformation_IsHumanPlayerThatLeftAttachedToPlayerID(i) == 1))
	end
	local fs = Sync.CreateFunctionString( _func, unpack(arg))
	Sync.OverwriteTributeCallback(id, fs)
	Sync.Send(Sync.PrepareChar..id..fs);
end
function Sync.CallNoSync(_func, ...)
	Sync.Send(Sync.NoSyncChar .. Sync.CreateFunctionString(_func, unpack(arg)))
end
function Sync.AddCall(_f)
	Sync.Whitelist[_f] = true;
end
function Sync.OverwriteTributeCallback(_id, _fs)
	Sync.Tributes[_id].Callback = function()
		Sync.ExecuteFunctionByString(_fs)
		Sync.CreateNewTribut(Sync.Tributes[_id].Player)
		Sync.Tributes[_id] = nil
	end
end
function Sync.OnPrepareMessageArrived(_msg)
	local start, finish = string.find( _msg, "%d+")
	local tributeId = tonumber(string.sub(_msg, start, finish))
	local fs = string.sub( _msg, finish+1)
	Sync.OverwriteTributeCallback(tributeId, fs)
	Sync.Send(Sync.AcknowledgeChar..tributeId)
end
function Sync.OnAcknowledgeMessageArrived(_msg, _pId)
	local tributeId = tonumber(_msg)
	-- Is tributeId for this player?
	if GUI.GetPlayerID() ~= Sync.Tributes[tributeId].Player then
		return
	end
	Sync.Tributes[tributeId].AckData[_pId] = true;
	for i = 1, 8 do
		if not Sync.Tributes[tributeId].AckData[i] then
			return
		end
	end
	GUI.PayTribute(8, tributeId)
end

function Sync.Send(_str)
	if MCS.T.IsMultiplayer() then
		XNetwork.Chat_SendMessageToAll(_str)
	else
		MPGame_ApplicationCallback_ReceivedChatMessage(_str, 0, GUI.GetPlayerID())
	end
end

function Sync.CreateNewTribut(_playerId)
	local tributeData = {
		text = "",
		cost = {},
		pId = 8,
		Callback = function()	--TO BE OVERRIDEN ONCE FUNCTION IS READY TO CALL
		end				
	}
	local tributeId = AddTribute(tributeData)
	Sync.Tributes[tributeId] = tributeData
	Sync.Tributes[tributeId].Player = _playerId
	Sync.Tributes[tributeId].Used = false
end

function Sync.GetFreeTributeId(_pId)
	for k,v in pairs(Sync.Tributes) do
		if (not v.Used) and (v.Player == _pId) then
			return k
		end
	end
end

-- type mapping: 1=string, 2=number, 3=table, 4=boolean, 5=true, 6=false
-- structure: key, valuetype, value

function Sync.CreateFunctionString(_func, ...)
	return _func .. string.char(4) .. Sync.TableToString(arg)
end

function Sync.ExecuteFunctionByString(_s)
	local start = string.find(_s, string.char(4))
	local fString = string.sub(_s, 1, start-1)
	if Sync.UseWhitelist and not Sync.Whitelist[fString] then
		return;
	end
	local arguments = Sync.StringToTable(string.sub(_s, start+1))
	local ref = _G;
	local sep = string.find(fString, ".", 1, true)
	while(sep) do
		ref = ref[string.sub(fString, 1, sep-1)]
		fString = string.sub(fString, sep+1)
		sep = string.find(fString, ".", 1, true)
	end
	ref[fString](unpack(arguments))
end

function Sync.TableToString(_table)
	local s = ""
	-- X as seperator
	local X = string.char(4)
	for key, value in pairs(_table) do
		s = s .. key .. X
		if type(value) == "string" then
			s = s .. "1" .. value .. X
		elseif type(value) == "number" then
			s = s .. "2" .. value .. X
		elseif type(value) == "boolean" then
			local bool = "6"
			if value then
				bool = "5"
			end
			s = s .. "4" .. bool .. X
		elseif type(value) == "table" then
			s = s .. "3" .. Sync.TableToString(value) .. X
		else
			s = s .. "1" .. tostring(value) .. X
		end
	end
	return s .. string.char(3)
end

function Sync.StringToTable(_string)
	local t = {}
	local getKeyAndVType = function()
		local next = string.find(_string, string.char(4))
		local key, vtype = string.sub(_string, 1, next-1), string.sub(_string, next+1, next+1)
		_string = string.sub(_string, next+2)
		return (tonumber(key) or key), vtype
	end
	local getValue = function()
		local next = string.find(_string, string.char(4))
		local value = string.sub(_string, 1, next-1)
		_string = string.sub(_string, next+1)
		return value
	end
	local isEnd = function()
		if string.find(_string, string.char(3)) == 1 then
			return true
		end
	end
	local key, vtype, v
	repeat
		if isEnd() then
			return t, string.sub(_string, 3)
		end
		key, vtype = getKeyAndVType()
		if vtype == "3" then
			v, _string = Sync.StringToTable(_string)
		elseif vtype == "2" then
			v = tonumber(getValue())
		elseif vtype == "4" then
			v = (getValue()=="5")
		else
			v = getValue()
		end
		t[key] = v
	until(false)
end
-- X=Sync.StringToTable(Sync.TableToString({1,2}))
