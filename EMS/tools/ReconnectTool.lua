ReconnectTool = {
	StartedReconnect = false,
	LastActionTimestamp = 0,
	DelayNextAction = 0,
	CurrentActionIndex = 0,
	Text = " Verbindung verloren ",
	Started = false,
	GameNotOpenAnymore = false,
	Actions =
	{
		[1] = function()
			CUtil.SetGameTimeFactor(1);
			XNetworkUbiCom.Manager_Destroy();
			XNetworkUbiCom.Manager_Create();
			ReconnectTool.Started = true;
			ReconnectTool.Text = " Verbinden ";
			XGUIEng.ShowWidget("ReconnectToolState",1);
			return 1;
		end,
		
		[2] = XNetworkUbiCom.Manager_LogIn_Connect,
		[3] = XNetworkUbiCom.Manager_LogIn_Start,
		
		[4] = function()
			return XNetworkUbiCom.Lobby_Group_Enter(NETWORK_GAME_LOBBY);
		end,
		
		[5] = function()
			XNetworkUbiCom.Lobby_Group_Enter(NETWORK_GAME_LOBBY);
			if XNetworkUbiCom.Lobby_Group_GetIndexOfCurrent() == -1 then
				ReconnectTool.GameNotOpenAnymore = true;
				return 1;
			end
			XNetwork.Chat_SendMessageToAll(".join"); return 1;
		end,
		
		[6] = function()
			CNetwork.set_ready();
			return 1;
		end,
		
		[7] = function()
			CNetwork.send_need_ticks(Network_GetLastTickReceived() + 2000);
			-- reset params
			ReconnectTool.Started = false;
			ReconnectTool.CurrentActionIndex = 0;
			-- update GUI
			ReconnectTool.Text = " @color:0,255,0 Verbunden! ";
			local count = 3;
			ReconnectTool_Hide = function()
				if count > 0 then count = count - 1; return; end
				XGUIEng.ShowWidget("ReconnectToolState",0);
				return true;
			end
			StartSimpleJob("ReconnectTool_Hide");
			XGUIEng.SetText( "ReconnectToolState", ReconnectTool.Text);
			XNetwork.Manager_Create();
			return 1;
		end,
	},
};

function ReconnectTool.UpdateEveryFrame()
	if not CNetwork then
		return;
	end
	if not ReconnectTool.Started then
		if table.getn(GetIngamePlayers()) > 0 then
			return;
		end
		if table.getn(GetSpectators()) > 0 then
			return;
		end
	end
	if ReconnectTool.GameNotOpenAnymore then
		XGUIEng.SetText( "ReconnectToolState", " @color:255,0,0 Spiel nicht mehr offen! Kann nicht verbinden! ");
		return;
	end
	-- disconnected => reconnect
	local currentTimestamp = math.floor(XGUIEng.GetSystemTime());
	local delay = currentTimestamp - ReconnectTool.LastActionTimestamp;
	XGUIEng.SetText( "ReconnectToolState", "("..ReconnectTool.CurrentActionIndex.."/7) "..ReconnectTool.Text.." in "..(ReconnectTool.DelayNextAction-delay));
	if delay > ReconnectTool.DelayNextAction then
		-- update timestamp
		ReconnectTool.LastActionTimestamp = currentTimestamp;
		-- next action
		ReconnectTool.CurrentActionIndex = ReconnectTool.CurrentActionIndex + 1;
		-- execute
		local res = ReconnectTool.Actions[ReconnectTool.CurrentActionIndex]();
		if res ~= 1 then
			-- action failed
			ReconnectTool.CurrentActionIndex = 0;
			ReconnectTool.DelayNextAction = 5;
			ReconnectTool.Text = " @color:255,0,0 Fehlgeschlagen! ";
			return;
		end
		ReconnectTool.DelayNextAction = 2;
	end
end
