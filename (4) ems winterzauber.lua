-- ************************************************************************************************
-- *                                                                                              *
-- *                                                                                              *
-- *                                              EMS                                             *
-- *                                         CONFIGURATION                                        *
-- *                                                                                              *
-- *                                                                                              *
-- ************************************************************************************************

EMS_CustomMapConfig =
{
	-- ********************************************************************************************
	-- * Configuration File Version
	-- * A version check will make sure every player has the same version of the configuration file
	-- ********************************************************************************************
	Version = 1.2,
 
	-- ********************************************************************************************
	-- * Callback_OnMapStart
	-- * Called directly after the loading screen vanishes and works as your entry point.
	-- * Similar use to FirstMapAction/GameCallback_OnGameSart
	-- ********************************************************************************************
 
	Callback_OnMapStart = function()
		Logic.AddWeatherElement(1, 1, 1, 4, 5, 10);
		WT.SetupWeather();
		LocalMusic.UseSet = MEDITERANEANMUSIC;
		WT.Setup();
		
		local t = {
			Entities.XD_StonePit1,
			Entities.XD_IronPit1,
			Entities.XD_ClayPit1,
			Entities.XD_SulfurPit1
		}
		local amount = {
			[Entities.XD_StonePit1] = 100000,
			[Entities.XD_IronPit1] = 30000,
			[Entities.XD_ClayPit1] = 100000,
			[Entities.XD_SulfurPit1] = 50000
		}
		for eId in S5Hook.EntityIterator(Predicate.OfAnyType(t[1],t[2],t[3],t[4])) do
			local entityType = Logic.GetEntityType(eId)
			Logic.SetResourceDoodadGoodAmount( eId, amount[entityType])
		end
		
		for eId in S5Hook.EntityIterator(Predicate.OfType(Entities.XD_Clay1)) do
			Logic.SetResourceDoodadGoodAmount( eId, 3000);
		end
		
		for i = 1,12 do
			CreateWoodPile( "woodpile"..i, 100000);
		end
		
		for i = 1,2 do
			local mercTent = GetEntityId( "merc"..i );
			Logic.AddMercenaryOffer( mercTent, Entities.PU_LeaderHeavyCavalry2, 3, ResourceType.Gold, 1500, ResourceType.Wood, 1000 );
			Logic.AddMercenaryOffer( mercTent, Entities.PU_Scout, 2, ResourceType.Wood, 100 );
			Logic.AddMercenaryOffer( mercTent, Entities.PU_LeaderBow3, 3, ResourceType.Wood, 300 );
			Logic.AddMercenaryOffer( mercTent, Entities.PU_LeaderSword2, 5, ResourceType.Wood, 300 );
		end
		for i = 1,4 do
			Logic.HurtEntity(GetEntityId("r"..i), 400);
		end
		
		local ViewCenter;
		for i = 1,4 do
			ViewCenter = Logic.CreateEntity(Entities.XD_ScriptEntity,  6860, 38380+i, 0, i)
			Logic.SetEntityExplorationRange(ViewCenter, 7)
			ViewCenter = Logic.CreateEntity(Entities.XD_ScriptEntity, 70099, 38489+i, 0, i)
			Logic.SetEntityExplorationRange(ViewCenter, 7)
		end
		
		Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_CREATED, "", "WT_MineFiller", 1);
	end,
 
 
	-- ********************************************************************************************
	-- * Callback_OnGameStart
	-- * Called at the end of the 10 seconds delay, after the host chose the rules and started
	-- ********************************************************************************************
	Callback_OnGameStart = function()
		WT.StartWeather();
		WT.SetupDiplomacy();
		Logic.PlayerSetIsHumanFlag( 5, 1);
		Logic.PlayerSetIsHumanFlag( 6, 1);
		WT.SuddenDeathTimeCounter = 60*60;
		StartSimpleJob("WT_SuddenDeathTimer");
		StartSimpleJob("WT_MercernaryRefiller");
		
		-- attraction place provided by steam machine
		S5Hook.GetRawMem(9002416)[0][16][Entities.CB_SteamMashine*8+2][44]:SetInt(25);
	end,
 
	-- ********************************************************************************************
	-- * Callback_OnPeacetimeEnded
	-- * Called when the peacetime counter reaches zero
	-- ********************************************************************************************
	Callback_OnPeacetimeEnded = function()
		
	end,
 
 
	-- ********************************************************************************************
	-- * Peacetime
	-- * Number of minutes the players will be unable to attack each other
	-- ********************************************************************************************
	Peacetime = 0,
 
	-- ********************************************************************************************
	-- * GameMode
	-- * GameMode is a concept of a switchable option, that the scripter can freely use
	-- *
	-- * GameModes is a table that contains the available options for the players, for example:
	-- * GameModes = {"3vs3", "2vs2", "1vs1"},
	-- *
	-- * GameMode contains the index of selected mode by default - ranging from 1 to X
	-- *
	-- * Callback_GameModeSelected
	-- * Lets the scripter make changes, according to the selected game mode.
	-- * You could give different resources or change the map environment accordingly
	-- * _gamemode contains the index of the selected option according to the GameModes table
	-- ********************************************************************************************
	GameMode = 1,
	GameModes = {"Standard"},
	Callback_GameModeSelected = function(_gamemode)
	end,
	
	-- ********************************************************************************************
	-- * Resource Level
	-- * Determines how much ressources the players start with
	-- * 1 = Normal
	-- * 2 = FastGame
	-- * 3 = SpeedGame
	-- * See the ressources table below for configuration
	-- ********************************************************************************************
	ResourceLevel = 1,
 
	-- ********************************************************************************************
	-- * Resources
	-- * Order:
	-- * Gold, Clay, Wood, Stone, Iron, Sulfur
	-- * Rules:
	-- * 1. If no player is defined, default values are used
	-- * 2. If player 1 is defined, these ressources will be used for all other players too
	-- * 3. Use the players index to give ressources explicitly
	-- ********************************************************************************************
	Ressources =
	{
		Normal = {
			[1] = {
				1500,
				2750,
				2400,
				900,
				50,
				50,
			},
		},
	},
 
	-- ********************************************************************************************
	-- * Callback_OnFastGame
	-- * Called together with Callback_OnGameStart if the player selected ResourceLevel 2 or 3
	-- * (FastGame or SpeedGame)
	-- ********************************************************************************************
	Callback_OnFastGame = function()
	end,
	
	AIPlayers = {5,6,7,8},
	
	NumberOfHeroesForAll = 2,
	Drake = 0,
	Erec = 0,
	
	HeavyCavalry = 0,
	LightCavalry = 0,
	Cannon4 = 0,
	Cannon3 = 0,
	Markets = -1,
	TowerLevel = 1,
	WeatherChangeLockTimer = 1,
	Thief = 0,
};

function WT_MineFiller()
	local eId = Event.GetEntityID();
	local eType = Logic.GetEntityType(eId);
	if eType == Entities.XD_IronPit1 
	or eType == Entities.XD_SulfurPit1 then
		Logic.SetResourceDoodadGoodAmount( eId, 25000);
	end
end
-- todo: refill merchenaries
-- disable thiefs?
-- bessere ai kontrolle;
-- nerf camps
-- cannons better, not moving past

-- everything left:
-- create the spawn and the forward motion of the army
-- enable spawn points
-- conditions on the techs
-- buttons highlighted when resarched
-- create the defending armies
-- create the army buffs
-- create an "spawn army" button
-- create the counter that shows when the next army spawns
-- create spawn camps on the map
-- sudden death dz
-- fill merchenaries

-- todo:
-- sudden death dz
-- fill merchenaries
-- todo:
-- söldnerlager respawn
-- kirchen bringen was
-- anzeige das hq ausgebaut werden muss bevor upgrade
-- eisenminen + schwefel + lehmhaufen
-- suddendeath - towers runterticken
-- deactivate
-- armee mit attack move und wegpunkten
-- 

WT = {};
WT.TroopTypes =
{
	Sword = 1,
	Bow = 2,
	PoleArm = 3,
	Cavalry = 4,
	Cannon = 5,
}

WT.TroopTypeMapping =
{
	"PU_LeaderSword",
	"PU_LeaderBow",
	"PU_LeaderPoleArm",
	"PU_LeaderHeavyCavalry",
	"PV_Cannon",
}


WT.TroopBaseCosts = {
	{ResourceType.Gold, 500},
	{ResourceType.Wood, 200},
	{ResourceType.Wood, 200},
	{ResourceType.Iron, 1000},
	{ResourceType.Sulfur, 1200},
}

WT.TroopPriceIncreasePerUpgrade = {
	300,
	300,
	200,
	1000,
	1000,
};

WT.AI1 = 5;
WT.AI2 = 6;
WT.EnemyAI = 7;

WT.RespawnTimerDecrease = 30;

function WT.Setup()


	WT.SetupColorMapping();

	-- attack line p1/2 to p3/4
	local newX = 38400;
	local distanceY = 3900;
	local n = 76800/distanceY;
	
	local attackLine = {};
	for i = 1,n+1 do
		attackLine[i] = {newX, 1000 + distanceY * (i-1)}
		--Logic.CreateEntity(Entities.PU_Hero3, attackLine[i].X, attackLine[i].Y, 0,1);
	end
	
	-- Ally computer
	local respawnMinutes = 5;
	local availableSlots = 2;
	WT.AI = {};
	
	WT.AI[WT.AI1] = {};
	WT.AI[WT.AI2] = {};
	
	WT.AI[WT.AI1].AttackLine = attackLine;
	WT.AI[WT.AI2].AttackLine = {};
	-- reverse attack line order
	for i = table.getn(attackLine), 1, -1 do
		table.insert(WT.AI[WT.AI2].AttackLine, attackLine[i]);
	end
	
	for i = WT.AI1, WT.AI2 do
		WT.AI[i].RespawnTimeMax = respawnMinutes*60;
		WT.AI[i].RespawnTime = 0;
		WT.AI[i].SlotsAvailable = availableSlots;
		WT.AI[i].BonusSlotsAvailable = 0;
		WT.AI[i].RespawnTroops = {}; -- troops that will be spawned every resoawn
		WT.AI[i].UpgradeLevel = 1; -- levels 1-4 of troops
		WT.AI[i].SpawnIndex = 0;
		WT.AI[i].SpawnPosition = WT.GetSpawnPosition(i);
		WT.AI[i].Armies = {};
		WT.AI[i].RecruitingActive = false;
	end
	
	WT.SetupWin();
	WT.CreateEnemyAI();
	WT.CreateAllyAI();
	WT.SetupControllableTowers();
	WT.SetupSpawnSystem();
	WT.SetupChests();
	
	-- hide other slots
	for i = availableSlots+1, 10 do
		XGUIEng.ShowWidget("EMSMAWS"..i, 0);
	end
	
	-- disable horses before lvl 3;
	XGUIEng.DisableButton("EMSMAWT4", 1);
	
	WT.TroopPricePerCount = 200;
	
	WT.ResourceNames = {
		[ResourceType.Gold] = WT.TextTable.Gold,
		[ResourceType.Clay] = WT.TextTable.Clay,
		[ResourceType.Wood] = WT.TextTable.Wood,
		[ResourceType.Stone] = WT.TextTable.Stone,
		[ResourceType.Iron] = WT.TextTable.Iron,
		[ResourceType.Sulfur] = WT.TextTable.Sulfur,
	};
	StartSimpleHiResJob("WT_HideSecondTooltip");
	
	WT.PlayerHQLevels = {1,1,1,1};
	WT.GameCallback_OnBuildingUpgradeComplete = GameCallback_OnBuildingUpgradeComplete;
	GameCallback_OnBuildingUpgradeComplete = function(_oId, _nId)
		if Logic.GetEntityType(_nId) == Entities.PB_Headquarters2 then
			WT.PlayerHQLevels[GetPlayer(_nId)] = 2;
		elseif Logic.GetEntityType(_nId) == Entities.PB_Headquarters3 then
			WT.PlayerHQLevels[GetPlayer(_nId)] = 3;
		end
		WT.GameCallback_OnBuildingUpgradeComplete(_oId, _nId);
	end
	
	if CNetwork then
		CNetwork.SetNetworkHandler("WT.AddRespawnTroop", function(name, _troopType, _playerId)
			if CNetwork.isAllowedToManipulatePlayer(name, _playerId) then
				WT.AddRespawnTroop(_troopType, _playerId);
			end
		end)

		CNetwork.SetNetworkHandler("WT.SlotButton_Synced", function(name, _index, _playerId)
			if CNetwork.isAllowedToManipulatePlayer(name, _playerId) then
				WT.SlotButton_Synced(_index, _playerId);
			end
		end)

		CNetwork.SetNetworkHandler("WT.OptionButton_Synced", function(name, _index, _playerId)
			if CNetwork.isAllowedToManipulatePlayer(name, _playerId) then
				WT.OptionButton_Synced(_index, _playerId);
			end
		end)
	end
end

-- Logic.CreateEntity_O = Logic.CreateEntity; Logic.CreateEntity=function(_e,_x,_y,_r,_p) LuaDebugger.Log(_e) return Logic.CreateEntity_O(_e,_x,_y,_r,_p) end
WT.PlayersAI = {
	[1] = WT.AI1,
	[2] = WT.AI1,
	[3] = WT.AI2,
	[4] = WT.AI2,
};

function WT.GetPlayersAI(_playerId)
	return WT.PlayersAI[_playerId];
end

-- ********************************************************************************************
-- ********************************************************************************************
-- AI Army

WT.AllyArmyRodeLength = 1000;
WT.AllyArmyRodeLengthAdjusted = WT.AllyArmyRodeLength+500;
WT.AllyArmyRodeLengthSquared = WT.AllyArmyRodeLengthAdjusted*WT.AllyArmyRodeLengthAdjusted;
WT.NextAttackPosDistance = 1500^2;

function WT.CreateAllyAI()
	local x = 1000000;
	--Tools.GiveResouces(WT.AI1, x, x, x, x, x, x);
	--Tools.GiveResouces(WT.AI2, x, x, x, x, x, x);
	local desc = {serfLimit = 0}
	--SetupPlayerAi(WT.AI1, desc);
	--SetupPlayerAi(WT.AI2, desc);
	
	WT.MaxOffset = 6000;
	WT.WorldMidOffsetMinDist = Logic.WorldGetSize()/2 - WT.MaxOffset;
	WT.WorldMidOffsetMaxDist = Logic.WorldGetSize()/2 + WT.MaxOffset;
	
	StartSimpleJob("WT_AllyArmyController");
	WT_AllyArmySpawnControlJob = StartSimpleJob("WT_AllyArmySpawnControl");
end

function WT.GetSpawnPosition(_ai)
	-- every odd entry of the attack line can be a spawn position
	local index = WT.AI[_ai].SpawnIndex * 2 + 1;
	return WT.AI[_ai].AttackLine[index];
end

function WT.GetAttackLineIndexBySpawnIndex(_spawnIndex)
	-- every odd entry of the attack line can be a spawn position
	return _spawnIndex * 2 + 1;
end

function WT.SpawnAttackArmy(_ai)
	local troopDescription = {
		maxNumberOfSoldiers = 4,
		minNumberOfSoldiers = 0,
		experiencePoints = VERYLOW_EXPERIENCE,
		leaderType = Entities.PU_Hero3
	};
	local armyId = -1;
	for i = 1, 8 do
		if WT.IsArmyDead(WT.AI[_ai].Armies[i] or {}) then
			armyId = i;
			break;
		end
	end
	if armyId == -1 then
		return;
	end
	local army = {}
	local pos = WT.GetCurrentSpawnPosition(_ai);
	army.player = _ai
	army.id = armyId
	--army.strength = 9
	--army.position = {X=pos[1],Y=pos[2]}
	--army.rodeLength = WT.AllyArmyRodeLength;
	army.attackLineIndex = WT.GetAttackLineIndexByCurrentSpawn(_ai, pos)-1;
	army.nextAttackPosition = WT.GetNextAttackLinePosition(army);
	army.leaders = {};
	--SetupArmy(army)
	
	local leaderType;
	local troopType;
	for i = 1, table.getn(WT.AI[_ai].RespawnTroops) do
		troopType = WT.AI[_ai].RespawnTroops[i];
		if troopType == WT.TroopTypes.Cavalry then
			leaderType = Entities[WT.TroopTypeMapping[troopType]..(WT.AI[_ai].UpgradeLevel-2)];
		else
			leaderType = Entities[WT.TroopTypeMapping[troopType]..WT.AI[_ai].UpgradeLevel];
		end
		table.insert(army.leaders,
			AI.Entity_CreateFormation(
				_ai,
				leaderType,
				4,
				4,
				pos[1], pos[2],
				0,0,
				0,
				0
			)
		);
	end
	WT.AI[_ai].Armies[armyId] = army;
end

function WT.IsArmyDead(_army)
	for i = 1, table.getn(_army.leaders or {}) do
		if IsAlive(_army.leaders[i]) then
			return false;
		end
	end
	return true;
end

-- wo laufen sie denn hin?
function WT.GetAttackLineIndexByCurrentSpawn(_ai, pos)
	local y = pos[2];
	if _ai == WT.AI1 then
		for i = 1, table.getn(WT.AI[_ai].AttackLine) do
			if y < WT.AI[_ai].AttackLine[i][2] then
				return i;
			end
		end
	else
		for i = 1, table.getn(WT.AI[_ai].AttackLine) do
			if y > WT.AI[_ai].AttackLine[i][2] then
				return i;
			end
		end
	end
end

function WT_AllyArmyController()
	for ai = WT.AI1, WT.AI2 do
		for armyId, army in pairs(WT.AI[ai].Armies) do
			WT.AllyArmyUpdate(ai, army, armyId);
		end
	end
end

WT.MovingLeaders = {};

function WT.AllyArmyUpdate(_ai, _army, _armyId)
	if WT.IsArmyDead(_army) then
		WT.AI[_ai].Armies[_armyId] = nil;
		return;
	end
	
	local leader, x, y;
	if not WT.IsArmyClose(_army) then
		for i = 1, table.getn(_army.leaders) do
			leader = _army.leaders[i];
			if IsAlive(leader) then
				if not WT.IsLeaderFighting(leader) then
					-- if idle, move to attack position
					if WT.IsLeaderIdle(leader) then
						if not WT.IsLeaderClose(leader, _army.nextAttackPosition) then
						--LuaDebugger.Log(leader..": idle -> attack move to pos");
							x,y = WT.RandomizePos(_army.nextAttackPosition);
							Logic.GroupAttackMove(leader, x, y, -1);
						end
					end
				end
				
				-- if chasing to far, move back closer to attack position
				local pos = GetPosition(leader);
				if pos.X < WT.WorldMidOffsetMinDist or pos.X > WT.WorldMidOffsetMaxDist then
					--LuaDebugger.Log(leader..": moved away to far, return back to path "..pos.X .. " < "..WT.WorldMidOffsetMinDist.." or > "..WT.WorldMidOffsetMaxDist );
					if not WT.MovingLeaders[leader] then
						Logic.MoveSettler(leader, _army.nextAttackPosition.X, _army.nextAttackPosition.Y);
						WT.MovingLeaders[leader] = true;
					end
				elseif WT.MovingLeaders[leader] then
					-- give back control to army controller -> set idle
					--LuaDebugger.Log(leader..": set idle" );
					WT.MovingLeaders[leader] = false;
					Logic.MoveSettler(leader, pos.X, pos.Y);
				end
			end
		end
		return;
	end

	-- army reached next point
	-- -> advance
	_army.attackLineIndex = _army.attackLineIndex + 1;
	if _army.attackLineIndex > table.getn(WT.AI[_ai].AttackLine) then
		_army.attackLineIndex = table.getn(WT.AI[_ai].AttackLine);
		return;
	end
	_army.nextAttackPosition = WT.GetNextAttackLinePosition(_army);
	WT.ArmyAttackPosition(_army, _army.nextAttackPosition);
end

function WT.IsArmyClose(_army)
	local pos;
	for i = 1, table.getn(_army.leaders) do
		if IsAlive(_army.leaders[i]) then
			pos = GetPosition(_army.leaders[i]);
			if ((pos.X-_army.nextAttackPosition.X)^2 + (pos.Y-_army.nextAttackPosition.Y)^2) > WT.NextAttackPosDistance then
				return false;
			end
		end
	end
	return true;
end

function WT.IsLeaderClose(_leader, _pos)
	local pos = GetPosition(_leader);
	return ((pos.X-_pos.X)^2 + (pos.Y-_pos.Y)^2) < WT.NextAttackPosDistance;
end

function WT.ArmyAttackPosition(_army, _position)
	local x,y;
	for i = 1, table.getn(_army.leaders) do
		if IsAlive(_army.leaders[i]) then
			x,y = WT.RandomizePos(_position);
			Logic.GroupAttackMove(_army.leaders[i], x, y, -1);
		end
	end
end

function WT.RandomizePos(pos)
	return pos.X+(math.random(-30,30)*10), pos.Y+(math.random(-30,30)*10);
end

function WT.GetNextAttackLinePosition(_army)
	local index = _army.attackLineIndex + 1;
	local ai = _army.player;
	
	-- not more then max index
	if index > table.getn(WT.AI[ai].AttackLine) then
		index = table.getn(WT.AI[ai].AttackLine);
	end
	-- get next anchor
	local pos = WT.AI[ai].AttackLine[index];
	return {X = pos[1], Y = pos[2]};
end

WT.BattleTaskLists = {
	["TL_BATTLE"] = true,
	["TL_BATTLE_BOW"] = true,
	["TL_BATTLE_MACE"] = true,
	["TL_BATTLE_SPECIAL"] = true,
	["TL_BATTLE_VEHICLE"] = true,
	["TL_BATTLE_CROSSBOW"] = true,
	["TL_START_BATTLE"] = true,
};

function WT.IsLeaderIdle(_leader)
	local tl = Logic.GetCurrentTaskList(_leader);
	return tl == "TL_MILITARY_IDLE" or tl == "TL_VEHICLE_IDLE";
end

function WT.IsLeaderFighting(_leader)
	return WT.BattleTaskLists[Logic.GetCurrentTaskList(_leader)];
end

function WT.IsFighting(_army)
	local leaders = _army.leaders
	if not leaders then
		return false;
	end
	for i = 1, table.getn(leaders) do
		if WT.BattleTaskLists[Logic.GetCurrentTaskList(leaders[i])] then
			return true;
		end
	end
	return false;
end

function WT.ArmyIsNearNext(_army)
	local next = _army.nextAttackPosition;
	local leaders = _army.leaders;
	for i = 1, table.getn(leaders) do
		if IsAlive(leaders[i]) then
			local pos = GetPosition(leaders[i]);
			if (pos.X-next.X)^2+(pos.Y-next.Y)^2 > WT.AllyArmyRodeLengthSquared then
				return false;
			end
		end
	end
	return true;
end

function WT_AllyArmySpawnControl()
	for ai = WT.AI1, WT.AI2 do
		if WT.AI[ai].RecruitingActive then
			if WT.AI[ai].RespawnTime > 0 then
				WT.AI[ai].RespawnTime = WT.AI[ai].RespawnTime - 1;
			else
				WT.SpawnAttackArmy(ai);
				WT.AI[ai].RespawnTime = WT.AI[ai].RespawnTimeMax;
				if WT.GetPlayersAI(GUI.GetPlayerID()) == ai then
					if WT.RespawnCountdown then
						MCS.T.StopCountdown(WT.RespawnCountdown);
					end
					WT.RespawnCountdown = MCS.T.StartCountdown(WT.AI[ai].RespawnTime, nil, true);
				end
			end
		end
	end
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Troop Buttons

function WT.TroopButton(_troopType)
	if MCS.GV.GameStarted then
		WT.Sync("WT.AddRespawnTroop", _troopType, GUI.GetPlayerID())
	end
end

function WT.UpdateTroopTooltip(_troopType)
	local costs = WT.GetTroopCosts(_troopType, WT.GetPlayersAI(GUI.GetPlayerID()));
	XGUIEng.SetText("EMSMAWTooltip", WT.GetCostString(costs, GUI.GetPlayerID()));
end

function WT.AddRespawnTroop(_troopType, _playerId)
	local ai = WT.GetPlayersAI(_playerId);
	if WT.CheckAddTroopConditions(_troopType, _playerId, ai) then
		WT.PayTroop(_playerId, _troopType);
		table.insert(WT.AI[ai].RespawnTroops, _troopType);
		WT.UpdateRespawnTroops(ai);
	end
end

WT.SourceButtons = {
	"MultiSelectionSource_Sword",
	"MultiSelectionSource_Bow",
	"MultiSelectionSource_Spear",
	"MultiSelectionSource_HeavyCav",
	"MultiSelectionSource_Cannon",
};

function WT.UpdateRespawnTroops(_ai)
	local myAI = WT.GetPlayersAI(GUI.GetPlayerID());
	if _ai ~= myAI then
		return;
	end
	local sourceButton;
	local widgetId;
	local numTroops = table.getn(WT.AI[_ai].RespawnTroops);
	for i = 1, numTroops do
		widgetId = XGUIEng.GetWidgetID("EMSMAWS"..i);
		sourceButton = WT.SourceButtons[WT.AI[_ai].RespawnTroops[i]];
		XGUIEng.TransferMaterials(sourceButton, widgetId);
	end
	for i = numTroops + 1, 10 do
		widgetId = XGUIEng.GetWidgetID("EMSMAWS"..i);
		XGUIEng.TransferMaterials("EMSMAWSTemplate", widgetId);
	end
end

function WT.CheckAddTroopConditions(_troopType, _playerId, _ai)
	-- enough resources
	local costs = WT.GetTroopCosts(_troopType, _ai);
	if WT.GetPlayersTotalResources(_playerId, costs[1][1]) < costs[1][2] then
		if GUI.GetPlayerID() == _playerId then
			Message(WT.TextTable.NotEnoughResources);
		end
		return false;
	end
	if _troopType == WT.TroopTypes.Cavalry and WT.AI[_ai].UpgradeLevel < 3 then
		return false;
	end
	if table.getn(WT.AI[_ai].RespawnTroops) >= (WT.AI[_ai].SlotsAvailable+WT.AI[_ai].BonusSlotsAvailable) then
		if GUI.GetPlayerID() == _playerId then
			Message(WT.TextTable.ArmyLimitReached);
		end
		return false;
	end
	return true;
end

function WT.GetTroopCosts(_troopType, _ai)
	local count = 0;
	for i = 1, table.getn(WT.AI[_ai].RespawnTroops) do
		if WT.AI[_ai].RespawnTroops[i] == _troopType then
			count = count + 1;
		end
	end
	local price = WT.TroopBaseCosts[_troopType][2];
	-- increase price for each troop and each upgrade level
	price = price + (count*WT.TroopPricePerCount + (WT.AI[_ai].UpgradeLevel-1)*WT.TroopPriceIncreasePerUpgrade[_troopType])
	return {{WT.TroopBaseCosts[_troopType][1], price}};
end

function WT.PayTroop(_playerId, _troopType)
	local ai = WT.GetPlayersAI(_playerId);
	local costs = WT.GetTroopCosts(_troopType, ai);
	WT.Pay(_playerId, costs);
end

function WT.GetCostString(_costs, _playerId)
	local str = WT.TextTable.Costs..": @cr ";
	local color = "";
	local playerRes;
	if table.getn(_costs) == 0 then
		return "";
	end
	for i = 1, table.getn(_costs) do
		playerRes = WT.GetPlayersTotalResources(_playerId, _costs[i][1]);
		if playerRes < _costs[i][2] then
			color = "@color:255,0,0";
		else
			color = "@color:255,255,255";
		end
		str = str .. WT.ResourceNames[_costs[i][1]] .. " : ".. color .. " " .. _costs[i][2] .. " @cr @color:255,255,255 ";
	end
	return str;
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Slot Buttons

function WT.SlotButton(_index)
	if MCS.GV.GameStarted then
		WT.Sync("WT.SlotButton_Synced", _index, GUI.GetPlayerID())
	end
end

function WT.SlotButton_Synced(_index, _playerId)
	local ai = WT.GetPlayersAI(_playerId);
	if _index > table.getn(WT.AI[ai].RespawnTroops) then
		return;
	end
	table.remove(WT.AI[ai].RespawnTroops, _index);
	WT.UpdateRespawnTroops(ai);
end

function WT.UpdateSlotTooltip(_index)
	XGUIEng.SetText("EMSMAWTooltip", WT.TextTable.Remove);
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Option Buttons

function WT.OptionButton(_index)
	local pId = GUI.GetPlayerID();
	local costs = WT.GetOptionCosts(_index, pId);
	if WT.HasEnoughResources(pId, costs) and WT.OptionConditionFullfilled(_index, pId) then
		if MCS.GV.GameStarted then
			WT.Sync("WT.OptionButton_Synced", _index, pId);
		end
	end
end

function WT.OptionButton_Synced(_index, _playerId)
	local costs = WT.GetOptionCosts(_index, _playerId)
	if WT.HasEnoughResources(_playerId, costs) and WT.OptionConditionFullfilled(_index, _playerId) then
		WT.OptionButtonCallbacks[_index](_playerId);
		WT.Pay(_playerId, costs);
	end
end

function WT.UpdateOptionTooltip(_index)
	XGUIEng.ShowWidget("EMSMAWTooltip", 1);
	WT.SecondTooltipVisible = true;
	XGUIEng.SetText("EMSMAWTooltip", WT.GetCostString(WT.GetOptionCosts(_index, GUI.GetPlayerID()), GUI.GetPlayerID()));
	if _index == 6 then
		local pId = GUI.GetPlayerID();
		local ai = WT.GetPlayersAI(pId);
		if WT.AI[ai].UpgradeLevel == 2 then
			if WT.PlayerHQLevels[pId] == 1 then
				XGUIEng.SetText("EMSMAWTooltip2", WT.TextTable.NeedsHQ2);
				return;
			end
		elseif WT.AI[ai].UpgradeLevel == 3 then
			if WT.PlayerHQLevels[pId] == 2 then
				XGUIEng.SetText("EMSMAWTooltip2", WT.TextTable.NeedsHQ3);
				return;
			end
		end
	end
	XGUIEng.SetText("EMSMAWTooltip2", WT.TextTable.OT[_index]);
end

function WT_HideSecondTooltip()
	if WT.SecondTooltipVisible then
		if XGUIEng.IsWidgetShown("EMSMAWTooltip2") == 0 then
			XGUIEng.ShowWidget("EMSMAWTooltip", 0);
			WT.SecondTooltipVisible = false;
		end
	end
end

function WT.UpgradeMaxed(_index, _ai)
	if _ai == WT.GetPlayersAI(GUI.GetPlayerID()) then
		XGUIEng.HighLightButton("EMSMAWO".._index, 1);
	end
end

WT.OptionButtonCallbacks = {
	-- New Spawnpoint
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		WT.PushSpawn(ai);
	end,
	
	-- New Slot
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		WT.AI[ai].SlotsAvailable = WT.AI[ai].SlotsAvailable + 1;
		WT.UpdateSlots(ai);
		if WT.AI[ai].SlotsAvailable == 8 then
			WT.UpgradeMaxed(2, ai);
		end
	end,
	
	-- better armor
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		Logic.SetTechnologyState(ai, Technologies.T_LeatherMailArmor, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_ChainMailArmor, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_PlateMailArmor, 3);
		Logic.SetTechnologyState(ai, Technologies.T_SoftArcherArmor, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_PaddedArcherArmor, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_LeatherArcherArmor, 3);
		WT.AI[ai].ArmorResearched = true;
		WT.UpgradeMaxed(3, ai);
	end,
	
	-- better weapons
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		Logic.SetTechnologyState(ai, Technologies.T_MasterOfSmithery, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_IronCasting, 3);
		Logic.SetTechnologyState(ai, Technologies.T_Fletching, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_BodkinArrow, 3);
		Logic.SetTechnologyState(ai, Technologies.T_WoodAging, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_Turnery, 3);
		Logic.SetTechnologyState(ai, Technologies.T_EnhancedGunPowder, 3);
		--Logic.SetTechnologyState(ai, Technologies.T_BlisteringCannonballs, 3);
		WT.AI[ai].WeaponsResearched = true;
		WT.UpgradeMaxed(4, ai);
	end,
	
	-- less recruiting time
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		if WT.AI[ai].RespawnTime > WT.RespawnTimerDecrease then
			WT.AI[ai].RespawnTime = WT.AI[ai].RespawnTime - WT.RespawnTimerDecrease;
		else
			WT.AI[ai].RespawnTime = 0;
		end
		WT.AI[ai].RespawnTimeMax = WT.AI[ai].RespawnTimeMax - WT.RespawnTimerDecrease;
		
		-- adjust visible counter
		if WT.GetPlayersAI(GUI.GetPlayerID()) == ai then
			if GUIQuestTools.UltimatumTime then
				GUIQuestTools.UltimatumTime = GUIQuestTools.UltimatumTime - WT.RespawnTimerDecrease;
			end
		end

		WT.AI[ai].UpgradeCount_RespawnTime = (WT.AI[ai].UpgradeCount_RespawnTime or 0) + 1;
		if WT.AI[ai].UpgradeCount_RespawnTime >= 2 then
			WT.UpgradeMaxed(5, ai);
		end
	end,
	
	-- level upgrade
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		WT.AI[ai].UpgradeLevel = WT.AI[ai].UpgradeLevel + 1;
		if WT.AI[ai].UpgradeLevel == 3 then
			if WT.GetPlayersAI(GUI.GetPlayerID()) == ai then
				XGUIEng.DisableButton("EMSMAWT4", 0);
			end
		end
		if WT.AI[ai].UpgradeLevel == 4 then
			WT.UpgradeMaxed(6, ai);
		end
	end,
	
	-- start recruiting
	function(_playerId)
		local ai = WT.GetPlayersAI(_playerId);
		WT.AI[ai].RecruitingActive = true;
		if ai == WT.GetPlayersAI(GUI.GetPlayerID()) then
			XGUIEng.ShowWidget("EMSMAWO7", 0);
		end
	end,
}

function WT.UpdateSlots(_ai)
	local aiSlots = WT.AI[_ai].SlotsAvailable + WT.AI[_ai].BonusSlotsAvailable;
	if WT.GetPlayersAI(GUI.GetPlayerID()) == _ai then
		for i = 1, aiSlots do
			XGUIEng.ShowWidget("EMSMAWS"..i, 1);
		end
		for i = aiSlots+1, 10 do
			XGUIEng.ShowWidget("EMSMAWS"..i, 0);
			widgetId = XGUIEng.GetWidgetID("EMSMAWS"..i);
			XGUIEng.TransferMaterials("EMSMAWSTemplate", widgetId);
		end
	end
	if table.getn(WT.AI[_ai].RespawnTroops) > aiSlots then
		for i = 1, table.getn(WT.AI[_ai].RespawnTroops)-aiSlots do
			table.remove(WT.AI[_ai].RespawnTroops, table.getn(WT.AI[_ai].RespawnTroops));
		end
	end
end

WT.OptionBaseCosts = {
	{ResourceType.Wood, 500},
	{ResourceType.Gold, 1000},
	{ResourceType.Iron, 1000},
	{ResourceType.Iron, 1000},
	{ResourceType.Gold, 2000},
}

function WT.GetOptionCosts(_index, _playerId)
	if _index == 6 then
		return WT.GetAIUpgradeCosts(_playerId)
	else
		return {WT.OptionBaseCosts[_index]};
	end
end

function WT.OptionConditionFullfilled(_index, _playerId)
	local ai = WT.GetPlayersAI(_playerId);
	
	if _index == 6 then
		-- upgrade level
		if WT.AI[ai].UpgradeLevel == 2 then
			if WT.PlayerHQLevels[_playerId] == 1 then
				return false;
			end
		elseif WT.AI[ai].UpgradeLevel == 3 then
			if WT.PlayerHQLevels[_playerId] == 2 then
				return false;
			end
		elseif WT.AI[ai].UpgradeLevel == 4 then
			return false;
		end
	elseif _index == 5 then
		if WT.AI[ai].UpgradeCount_RespawnTime then
			if WT.AI[ai].UpgradeCount_RespawnTime >= 2 then
				return false;
			end
		end
	elseif _index == 4 then
		if WT.AI[ai].WeaponsResearched then
			return false;
		end
	elseif _index == 3 then
		if WT.AI[ai].ArmorResearched then
			return false;
		end
	elseif _index == 2 then
		if WT.AI[ai].SlotsAvailable >= 8 then
			return false;
		end
	elseif _index == 1 then
		if WT.AI[ai].SpawnConstruction.Active then
			return false;
		end
	end
	return true;
end

function WT.GetAIUpgradeCosts(_playerId)
	local ai = WT.GetPlayersAI(_playerId);
	local costs = {};
	local troopType, baseCosts, resType;
	-- repay for all currently bought troops
	for i = 1, table.getn(WT.AI[ai].RespawnTroops) do
		troopType = WT.AI[ai].RespawnTroops[i];
		baseCosts = WT.TroopBaseCosts[troopType];
		resType = baseCosts[1];
		if costs[resType] == nil then
			costs[resType] = {resType, WT.TroopPriceIncreasePerUpgrade[troopType]}
		else
			costs[resType][2] = costs[resType][2] + WT.TroopPriceIncreasePerUpgrade[troopType];
		end
	end
	local costs2 = {{ResourceType.Gold, 2000*WT.AI[ai].UpgradeLevel}};
	if costs[ResourceType.Gold] then
		costs2[1][2] = costs2[1][2] + costs[ResourceType.Gold][2];
	end
	for i = 1,20 do
		if costs[i] ~= nil and i ~= ResourceType.Gold then
			table.insert(costs2, costs[i]);
		end
	end
	return costs2;
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Spawning
function WT.SetupSpawnSystem()
	local spawns = {
		{38400, 12100},
		{38400, 24000},
		{38400, 34000},
		{38400, 42800},
		{38400, 52800},
		{38400, 64700},
	};
	
	WT.Spawns = spawns;
	WT.SpawnPlaces = {};
	for i = 1, table.getn(spawns) do
		WT.SpawnPlaces[i] = Logic.CreateEntity(Entities.XD_RuinSmallTower4, spawns[i][1], spawns[i][2], math.random(0,369), 0);
	end
	
	WT.AI[WT.AI1].SpawnConstruction = {Active=false, Building=-1, Index=-1};
	WT.AI[WT.AI2].SpawnConstruction = {Active=false, Building=-1, Index=-1};
	StartSimpleJob("WT_ConstructionControl");
	StartSimpleHiResJob("WT_DeadTowerCollection");
end

function WT.PushSpawn(_ai)
	if WT.AI[_ai].SpawnConstruction.Active then
		return;
	end
	--if WT.AI[_ai].SpawnIndex == table.getn(WT.Spawns) then
	--	return;
	--end
	if not WT.SetNextSpawnPlace(_ai) then
		return;
	end
	
	WT.AI[_ai].SpawnConstruction.Serfs = {}
	local pos = WT.GetCurrentSpawnPosition(_ai);
	for i = 1, 4 do
		WT.AI[_ai].SpawnConstruction.Serfs[i] = AI.Entity_CreateFormation(
			_ai,
			Entities.PU_Serf,
			0,
			0,
			pos[1], pos[2],
			0,0,
			0,
			0
		);
		if not WT.ReattachSerfsJob then
			WT.ReattachSerfsJob = StartSimpleJob("WT_ReattachSerfs");
		end
		--WT.ConstructBuilding(WT.AI[_ai].SpawnConstruction.Serfs[i], WT.AI[_ai].SpawnConstruction.Building);
	end
end

function WT_ReattachSerfs()
	-- # weird bug: direct call from debug console doesnt need this
	for ai = WT.AI1, WT.AI2 do
		if WT.AI[ai].SpawnConstruction.Active then
			for i = 1, 4 do
				WT.ConstructBuilding(WT.AI[ai].SpawnConstruction.Serfs[i], WT.AI[ai].SpawnConstruction.Building)
			end
		end
	end
	WT.ReattachSerfsJob = nil;
	return true;
end

function WT.ConstructBuilding(_serfId, _buildingId)
	if SendEvent then
		if SendEvent.SerfConstructBuilding then
			SendEvent.SerfConstructBuilding(_serfId, _buildingId);
		else
			Message("Error:send but not send event");
		end
	else
		PostEvent.SerfConstructBuilding(_serfId, _buildingId)
	end
end

function WT.GetCurrentSpawnPosition(_ai)
	local spawnIndex = WT.AI[_ai].SpawnIndex;
	local index;
	-- base spawn
	local pos = WT.AI[_ai].AttackLine[1];
	
	-- follow spawn line until spawn line breaks
	-- in terms of a turret missing
	if _ai == WT.AI1 then
		
		-- normal order
		for i = 1, table.getn(WT.SpawnPlaces) do
			if not IsAlive(WT.SpawnPlaces[i]) then
				break;
			end
			if Logic.IsConstructionComplete(WT.SpawnPlaces[i]) == 0 then
				break;
			end
			if Logic.EntityGetPlayer(WT.SpawnPlaces[i]) ~= _ai then
				break;
			end
			pos = WT.Spawns[i];
		end
		
	else
	
		-- reverse order
		for i = table.getn(WT.SpawnPlaces), 1, -1 do
			if not IsAlive(WT.SpawnPlaces[i]) then
				break;
			end
			if Logic.IsConstructionComplete(WT.SpawnPlaces[i]) == 0 then
				break;
			end
			if Logic.EntityGetPlayer(WT.SpawnPlaces[i]) ~= _ai then
				break;
			end
			pos = WT.Spawns[i];
		end
		
	end
	return pos;
end

function WT_DeadTowerCollection()
	for i = 1, table.getn(WT.SpawnPlaces) do
		if IsDead(WT.SpawnPlaces[i]) then
			local pos = WT.Spawns[i];
			WT.SpawnPlaces[i] = Logic.CreateEntity(Entities.XD_RuinSmallTower4, pos[1], pos[2], math.random(1,360), 0);
		end
	end
end

function WT_ConstructionControl()
	local failed;
	for ai = WT.AI1, WT.AI2 do
		if WT.AI[ai].SpawnConstruction.Active then
			failed = true;
			-- check serfs alive
			for i = 1,4 do
				if IsAlive(WT.AI[ai].SpawnConstruction.Serfs[i]) then
					failed = false;
				end
			end
			-- check building alive
			if not IsAlive(WT.AI[ai].SpawnConstruction.Building) then
				failed = true;
			end
			
			if failed then
				WT.ResetSpawnPlace(ai);
			end
			
			if Logic.IsConstructionComplete(WT.AI[ai].SpawnConstruction.Building) == 1 then
				WT.RemoveSerfs(ai);
				WT.AI[ai].SpawnConstruction.Active = false;
				WT.AI[ai].SpawnConstruction.Building = -1;
				WT.AI[ai].SpawnIndex = math.min(WT.AI[ai].SpawnIndex + 1, 6);
			end
		end
	end
end

function WT.RemoveSerfs(_ai)
	-- kill serfs
	for i = 1,4 do
		if IsAlive(WT.AI[_ai].SpawnConstruction.Serfs[i]) then
			Logic.HurtEntity(WT.AI[_ai].SpawnConstruction.Serfs[i], 1000);
		end
	end
end

function WT.ResetSpawnPlace(_ai)
	-- kill building
	if IsAlive(WT.AI[_ai].SpawnConstruction.Building) then
		DestroyEntity(WT.AI[_ai].SpawnConstruction.Building);
	end
	-- kill serfs
	WT.RemoveSerfs(_ai);
	-- recreate ruin
	--local index = WT.AI[_ai].SpawnConstruction.Index;
	--local pos = WT.Spawns[index];
	--WT.SpawnPlaces[index] = Logic.CreateEntity(Entities.XD_RuinSmallTower4, pos[1], pos[2], math.random(1,360), 0);
	WT.AI[_ai].SpawnConstruction.Active = false;
end

function WT.SetNextSpawnPlace(_ai)
	local spawnIndex = WT.AI[_ai].SpawnIndex + 1;
	local index;
	if _ai == WT.AI1 then
		index = spawnIndex;
		-- validate if row is complete
		for i = 1, index do
			if not (Logic.EntityGetPlayer(WT.SpawnPlaces[i]) == _ai) then
				index = i;
				break;
			end
		end
	else
		-- max+1-1 = first element
		index = table.getn(WT.SpawnPlaces)+1 - spawnIndex;
		-- validate if row is complete
		for i = table.getn(WT.SpawnPlaces), index, -1 do
			if not (Logic.EntityGetPlayer(WT.SpawnPlaces[i]) == _ai) then
				index = i;
				break;
			end
		end
	end
	
	local entities;
	local range = 300;
	if IsAlive(WT.SpawnPlaces[index]) then
		if Logic.GetEntityType(WT.SpawnPlaces[index]) == Entities.XD_RuinSmallTower4 then
			DestroyEntity(WT.SpawnPlaces[index])
			Logic.CreateConstructionSite(WT.Spawns[index][1], WT.Spawns[index][2], 0, Entities.PB_Tower1, _ai);
			
			entities = {Logic.GetPlayerEntitiesInArea(_ai, Entities.PB_Tower1, WT.Spawns[index][1], WT.Spawns[index][2], range, 3)}
			if entities[1] == 1 then
				WT.SpawnPlaces[index] = entities[2];
				WT.AI[_ai].SpawnConstruction.Building = entities[2];
				WT.AI[_ai].SpawnConstruction.Index = index;
				WT.AI[_ai].SpawnConstruction.Active = true;
				return true;
			else
				Message("error: created construction site tower "..entities[1])
				return false;
			end
		else
			-- probably occupied by other player already
			if WT.GetPlayersAI(GUI.GetPlayerID()) == _ai then
				Message("@color:255,150,0 " .. WT.TextTable.OtherTeamOwnsSpawn);
			end
			return false;
		end
	end
end

-- ********************************************************************************************
-- ********************************************************************************************
-- TextTable
WT.Language = string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName())
if WT.Language == "de" then
	WT.TextTable = {
		Costs = "Kosten",
		Gold = "Taler",
		Clay = "Lehm",
		Wood = "Holz",
		Stone = "Stein",
		Iron = "Eisen",
		Sulfur = "Schwefel",
		
		OT = {
			"Sendet Leibeigene aus um eure Front nach vorne zu verlagern!",
			"Kauft einen zusätzlichen Truppenslot!",
			"Verbessert die Rüstung aller Truppen (Rüstung +2)!",
			"Verbessert die Angriffskraft aller Truppen (Angriffschaden +2)!",
			"Reduziert die Zeit für die Rekrutierung um "..WT.RespawnTimerDecrease.." Sekunden!",
			"Verbessert die Einheiten auf die nächste Stufe!",
			"Hebt die Armee eures Verbündeten aus (einmalig)",
		},
		
		Remove = "Entfernt diese Einheit von der Rekrutierung!",
		NotEnoughResources = "Nicht genügend Rohstoffe vorhanden!",
		ArmyLimitReached = "Maximale Armeegröße erreicht!",
		
		OtherTeamOwnsSpawn = "Das andere Team hat diesen Punkt bereits besetzt!",
		Win1 = "Der Weihnachtsbaum ist gefallen! ",
		Win2 = " und ",
		Win3 = " haben diese Runde für sich entschieden! Herzlichen Glückwunsch an die beiden!",
		
		WinHead1 = "Hurra!",
		WinHead2 = "Oh Nein!",
		
		Team1 = " und ",
		Team2 = " haben einen Leuchtturm erobert!",
		
		Chest1 = " hat die Schatztruhe von ",
		Chest2 = " geöffnet!",
		
		NeedsHQ2 = "Benötigt Festung!",
		NeedsHQ3 = "Benötigt Zitadelle!",
	}
else
	WT.TextTable = {
		Costs = "Costs",
		Gold = "Gold",
		Clay = "Clay",
		Wood = "Wood",
		Stone = "Stone",
		Iron = "Iron",
		Sulfur = "Sulfur",
		
		OT = {
			"Send serfs to advance your front!",
			"Buy an additional army troop slot!",
			"Improves armor (Armor +2)!",
			"Improves attack damage(damage +2)!",
			"Reduces recruiting time by "..WT.RespawnTimerDecrease.." seconds!",
			"Upgrade unit level!",
			"Hebt die Armee eures Verbündeten aus (einmalig)",
		},
		
		Remove = "Removes this unit from beeing recruited!",
		NotEnoughResources = "Not enough resources!",
		ArmyLimitReached = "Maximum army size reached!",
		
		OtherTeamOwnsSpawn = "The other Team has already blocked the next placement!",
		Win1 = "The Christmas tree has fallen! ",
		Win2 = " and ",
		Win3 = " have won this game! Congratulations!",
		
		WinHead1 = "Hurra!",
		WinHead2 = "Oh No!",
		
		Team1 = " and ",
		Team2 = " have conquered a tower!",
		
		Chest1 = " opened ",
		Chest2 = " chest!",
		
		NeedsHQ2 = "Needs Headquarters Level 2!",
		NeedsHQ3 = "Needs Headquarters Level 3!",
	}
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Controllable Towers

function WT.SetupControllableTowers()
	WT.TowerSpawns = {{7000, 38500},{70100, 38500}}
	WT.TowerState = {
		Neutral = 1,
		Attackable = 2
	}
	WT.TowerStates = {WT.TowerState.Attackable, WT.TowerState.Attackable}
	WT.Towers = {
		Logic.CreateEntity(Entities.CB_Lighthouse, WT.TowerSpawns[1][1], WT.TowerSpawns[1][2], 0, 7),
		Logic.CreateEntity(Entities.CB_Lighthouse, WT.TowerSpawns[2][1], WT.TowerSpawns[2][2], 0, 7)
	};
	
	WT.VillageCenterProviders = {};
	for i = 1,4 do
		WT.VillageCenterProviders[i] = {0,0};
	end
	
	StartSimpleJob("WT_TowerController");
end

function WT_TowerController()
	local range = 3000;
	for i = 1,2 do
		if IsAlive(WT.Towers[i]) then
			if WT.TowerStates[i] == WT.TowerState.Attackable then
				-- if tower falls below 150 hp, set neutral and activate conquer mode
				if Logic.GetEntityHealth(WT.Towers[i]) <= 150 then
					WT.SpawnTower(i, 8, WT.TowerState.Neutral, Entities.CB_Lighthouse);
				end
			else
				-- conquer mode: if one team is solo in the area of range around the tower, the tower will fall into their hands
				local entities, isTeam1, isTeam2, isTeam3 = 0, false, false, false;
				for playerId = 1, 2 do
					entities = {Logic.GetPlayerEntitiesInArea(playerId, 0, WT.TowerSpawns[i][1], WT.TowerSpawns[i][2], range, 5)}
					for i = 1, entities[1] do
						if IsAlive(entities[i+1]) then
							isTeam1 = true;
							break;
						end
					end
				end
				for playerId = 3, 4 do
					entities = {Logic.GetPlayerEntitiesInArea(playerId, 0, WT.TowerSpawns[i][1], WT.TowerSpawns[i][2], range, 5)}
					for i = 1, entities[1] do
						if IsAlive(entities[i+1]) then
							isTeam2 = true;
							break;
						end
					end
				end
				
				-- enemy AI
				entities = {Logic.GetPlayerEntitiesInArea(7, 0, WT.TowerSpawns[i][1], WT.TowerSpawns[i][2], range, 1)}
				if entities[1] > 0 then
					isTeam3 = true;
				end
				
				if isTeam1 and not isTeam2 and not isTeam3 then
					Message("@color:255,125,0 " .. UserTool_GetPlayerName(1) .. WT.TextTable.Team1 .. UserTool_GetPlayerName(2) ..  WT.TextTable.Team2);
					WT.SpawnTower(i, 1, WT.TowerState.Attackable, Entities.CB_LighthouseActivated);
				elseif not isTeam1 and isTeam2 and not isTeam3 then
					Message("@color:255,125,0 " .. UserTool_GetPlayerName(3) .. WT.TextTable.Team1 .. UserTool_GetPlayerName(4) ..  WT.TextTable.Team2);
					WT.SpawnTower(i, 3, WT.TowerState.Attackable, Entities.CB_LighthouseActivated);
				end
			end
		else
			WT.SpawnTower(i, 8, WT.TowerState.Neutral, Entities.CB_Lighthouse);
		end
	end
end

function WT.SpawnTower(_towerId, _playerId, _towerState, _entity)
	if IsAlive(WT.Towers[_towerId]) then
		DestroyEntity(WT.Towers[_towerId]);
	end
	WT.Towers[_towerId] = Logic.CreateEntity(_entity, WT.TowerSpawns[_towerId][1], WT.TowerSpawns[_towerId][2], 0, _playerId)
	Logic.HurtEntity(WT.Towers[_towerId], 400);
	WT.TowerStates[_towerId] = _towerState;
	
	local towersTeam1 = 0;
	local towersTeam2 = 0;
	local player;
	for i = 1,2 do
		player = Logic.EntityGetPlayer(WT.Towers[i]);
		if player == 1 then
			towersTeam1 = towersTeam1 + 1;
		else
			towersTeam2 = towersTeam2 + 1;
		end
	end
	WT.SetControlledTowersLevel(5, towersTeam1);
	WT.SetControlledTowersLevel(6, towersTeam2);
end

function WT.SetControlledTowersLevel(_ai, _level)
	local armor, damage, movementspeed;
	
	WT.UpdateVillagePlacesProvided(_ai, _level);
	
	if _level == 1 then
		-- armor yes, damage no
		armor = 3;
		damage = 2;
		movementspeed = 3;
		WT.AI[_ai].BonusSlotsAvailable = 1;
	elseif _level == 2 then
		-- armor yes, damage yes
		armor = 3;
		damage = 3;
		movementspeed = 3;
		WT.AI[_ai].BonusSlotsAvailable = 2;
	else
		-- armor no, damage no
		armor = 2;
		damage = 2;
		movementspeed = 2;
		WT.AI[_ai].BonusSlotsAvailable = 0;
	end
	-- unit armor change by 4
	Logic.SetTechnologyState(_ai, Technologies.T_ChainMailArmor, armor);
	Logic.SetTechnologyState(_ai, Technologies.T_PlateMailArmor, armor);
	Logic.SetTechnologyState(_ai, Technologies.T_PaddedArcherArmor, armor);
	Logic.SetTechnologyState(_ai, Technologies.T_LeatherArcherArmor, armor);
	
	-- change unit damage
	Logic.SetTechnologyState(_ai, Technologies.T_IronCasting, damage);
	Logic.SetTechnologyState(_ai, Technologies.T_BodkinArrow, damage);
	Logic.SetTechnologyState(_ai, Technologies.T_Turnery, damage);
	Logic.SetTechnologyState(_ai, Technologies.T_BlisteringCannonballs, damage);
	
	-- unit movementspeed
	Logic.SetTechnologyState(_ai, T_BetterTrainingBarracks, movementspeed);
	Logic.SetTechnologyState(_ai, T_BetterTrainingArchery, movementspeed);
	Logic.SetTechnologyState(_ai, T_Shoeing, movementspeed);
	Logic.SetTechnologyState(_ai, T_BetterChassis, movementspeed);
	WT.UpdateSlots(_ai);
end

function WT.UpdateVillagePlacesProvided(_ai, _level)
	local p1,p2;
	if _ai == WT.AI1 then
		p1 = 1;
		p2 = 2;
	else
		p1 = 3;
		p2 = 4;
	end
	if _level == 1 then
		for i = p1,p2 do
			-- create first
			if not IsAlive(WT.VillageCenterProviders[i][1]) then
				WT.VillageCenterProviders[i][1] = Logic.CreateEntity(Entities.CB_SteamMashine, 500, 500, 0, i);
				Logic.SetModelAndAnimSet( WT.VillageCenterProviders[i][1], Models.XD_Rock3);
			end
			-- destroy second
			if IsAlive(WT.VillageCenterProviders[i][2]) then
				DestroyEntity(WT.VillageCenterProviders[i][2]);
				WT.VillageCenterProviders[i][2] = 0;
			end
		end
	elseif _level == 2 then
		for i = p1,p2 do
			-- create first
			if not IsAlive(WT.VillageCenterProviders[p1][1]) then
				WT.VillageCenterProviders[i][1] = Logic.CreateEntity(Entities.CB_SteamMashine, 500, 500, 0, i);
				Logic.SetModelAndAnimSet( WT.VillageCenterProviders[i][1], Models.XD_Rock3);
			end
			-- create second
			if not IsAlive(WT.VillageCenterProviders[p1][2]) then
				WT.VillageCenterProviders[i][2] = Logic.CreateEntity(Entities.CB_SteamMashine, 500, 500, 0, i);
				Logic.SetModelAndAnimSet( WT.VillageCenterProviders[i][2], Models.XD_Rock3);
			end
		end
	else
		for i = p1,p2 do
			-- destroy first
			if IsAlive(WT.VillageCenterProviders[i][1]) then
				DestroyEntity(WT.VillageCenterProviders[i][1]);
				WT.VillageCenterProviders[i][1] = 0;
			end
			-- destroy second
			if IsAlive(WT.VillageCenterProviders[i][2]) then
				DestroyEntity(WT.VillageCenterProviders[i][2]);
				WT.VillageCenterProviders[i][2] = 0;
			end
		end
	end
end

function WT.Sync(...)
	if CNetwork then
		CNetwork.send_command(unpack(arg));
	else
		Sync.Call(unpack(arg));
	end
end

function WT.GetPlayersTotalResources(_playerId, _resourceType)
	return Logic.GetPlayersGlobalResource( _playerId, _resourceType ) + Logic.GetPlayersGlobalResource( _playerId, _resourceType+1);
end

function WT.Pay(_playerId, _costs)
	for i = 1, table.getn(_costs) do
		Logic.SubFromPlayersGlobalResource(_playerId , _costs[i][1], _costs[i][2]);
	end
end

function WT.HasEnoughResources(_playerId, _costs)
	for i = 1, table.getn(_costs) do
		if WT.GetPlayersTotalResources(_playerId, _costs[i][1]) < _costs[i][2] then
			return false;
		end
	end
	return true;
end

function WT.ToogleWindowButton()
	local widget = "EMSMAWinter";
	if XGUIEng.IsWidgetShown(widget) == 0 then
		XGUIEng.ShowWidget(widget, 1);
	else
		XGUIEng.ShowWidget(widget, 0);
	end
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Win Condition

function WT.SetupWin()
	local spawns = {
		[WT.AI1] = {38400, 7300, 290},
		[WT.AI2] = {38300, 69500, 110}
	};
	WT.DefendingTowers = {};
	for ai = WT.AI1, WT.AI2 do
		WT.AI[ai].TreePos = spawns[ai];
		WT.AI[ai].Basement, WT.AI[ai].Tree = WT.CreateBasement(spawns[ai][3], ai, spawns[ai]);
		for eId, alive in pairs(WT.AI[ai].Basement) do
			Logic.SetEntityInvulnerabilityFlag(eId, 1);
		end
	end
	StartSimpleJob("WT_WinControl");
	Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "WT_WinEntityHurt", 1);
end

function WT_WinEntityHurt()
	local attackerID = Event.GetEntityID1();
	local attackerPlayer = GetPlayer(attackerID);
	local tarID = Event.GetEntityID2();
	local targetPlayer = GetPlayer(tarID);
	if attackerPlayer ~= WT.AI1 and attackerPlayer ~= WT.AI2 then
		return;
	end
	if targetPlayer ~= WT.AI1 and targetPlayer ~= WT.AI2 then
		return;
	end
	for ai = WT.AI1, WT.AI2 do
		if WT.AI[ai].Basement[tarID] then
			local dmg = 25;
			local hp = Logic.GetEntityHealth(tarID);
			if hp > dmg then
				MakeVulnerable(tarID);
				Logic.HurtEntity(tarID,dmg);
				MakeInvulnerable(tarID);
			else
				MakeVulnerable(tarID);
				SetHealth(tarID,0);
				WT.AI[ai].Basement[tarID] = false;
			end
		end
	end
end

function WT_WinControl()
	for ai = WT.AI1, WT.AI2 do
		local basementAlive = false;
		for eId, alive in pairs(WT.AI[ai].Basement) do
			if IsAlive(eId) then
				basementAlive = true;
				break;
			end
		end
		if not basementAlive then
			if not WT.AI[ai].TreeFreed then
				WT.SetTreeFree(ai);
				WT.AI[ai].TreeFreed = true;
			end
		end
		-- wait for tree to be chopped
		if IsDead(WT.AI[ai].Tree) then
			if WT.AI[ai].ResourceTree == nil then
				local entities = {Logic.GetEntitiesInArea(Entities.XD_ResourceTree, WT.AI[ai].TreePos[1], WT.AI[ai].TreePos[2], 300, 1)}
				if entities[1] > 0 then
					WT.AI[ai].ResourceTree = entities[2];
				end
			else
				if Logic.GetResourceDoodadGoodAmount(WT.AI[ai].ResourceTree) < 50 then
					if ai == WT.AI1 then
						WT.Win(WT.AI2, ai);
					else
						WT.Win(WT.AI1, ai);
					end
					return true;
				end
			end
		end
	end
end

function WT.SetTreeFree(_ai)
	if not WT.ChopTreeCheckJob then
		WT.ChopTreeCheckJob = StartSimpleJob("WT_ChopTreeCheck");
	end
	local pos = GetPosition(WT.AI[_ai].Tree);
	DestroyEntity(WT.AI[_ai].Tree);
	local realTree = Logic.CreateEntity(Entities.XD_Fir1, pos.X, pos.Y, 0, 0);
	S5Hook.GetEntityMem(realTree)[25]:SetFloat(1.5);
	WT.AI[_ai].Tree = realTree;
end

function WT.CreateBasement(_rotation, _playerId, _pos)
	local n = 6;
	local step = math.floor(270/n);
	local radius = 1000;
	local rotation = _rotation;
	local rotOffsetChapell = 20;
	local radiusOffsetChapell = 100;
	local basement = {};
	local id;
	id = Logic.CreateEntity(Entities.CB_Abbey01, _pos[1] + math.cos(math.rad(rotation-rotOffsetChapell))*(radius+radiusOffsetChapell), _pos[2] + math.sin(math.rad(rotation-rotOffsetChapell))*(radius+radiusOffsetChapell), rotation-rotOffsetChapell, _playerId); 
	basement[id] = true;
	for i = 45+rotation, 270+rotation, step do
		id = Logic.CreateEntity(Entities.CB_Abbey04, _pos[1] + math.cos(math.rad(i))*radius, _pos[2] + math.sin(math.rad(i))*radius, i, _playerId); 
		basement[id] = true;
	end
	
	n = 6;
	radius = 1500;
	step = math.floor(260/n);
	for i = 50+rotation, 270+rotation, step do
		id = Logic.CreateEntity(Entities.PB_Tower2, _pos[1] + math.cos(math.rad(i))*radius, _pos[2] + math.sin(math.rad(i))*radius, 0, _playerId); 
		basement[id] = true;
		table.insert(WT.DefendingTowers, id);
	end
	
	Logic.CreateEntity(Entities.XD_Sparkles, _pos[1], _pos[2], 0, 0);
	local tree = Logic.CreateEntity(Entities.XD_Rock3, _pos[1], _pos[2], 0, 0);
	Logic.SetModelAndAnimSet( tree, Models.XD_Fir1);
	S5Hook.GetEntityMem(tree)[25]:SetFloat(1.5);
	return basement, tree;
end

function WT.Win(_winnerAI, _loserAI)
	
	if WT.GetPlayersAI(1) == _winnerAI then
		WT.Winner1ID = 1;
		WT.Winner2ID = 2;
		WT.Winner1 = UserTool_GetPlayerName(1);
		WT.Winner2 = UserTool_GetPlayerName(2);
	else
		WT.Winner1ID = 3;
		WT.Winner2ID = 4;
		WT.Winner1 = UserTool_GetPlayerName(3);
		WT.Winner2 = UserTool_GetPlayerName(4);
	end
		

	XGUIEng.ShowWidget("EMSMAWinter", 0);
	XGUIEng.ShowWidget("EMSMenu", 0);
	XGUIEng.ShowWidget("EMSMAWShowWindow", 0);
	local pos = WT.AI[_loserAI].TreePos;
	Camera.ScrollSetLookAt(pos[1]-200,pos[2]-200);
	WT.EndCutsceneTimer = 20;
	
	XGUIEng.SetText("Cinematic_Headline","");
	XGUIEng.SetText("Cinematic_Text","");
	-- camera flight
	gvCamera.DefaultFlag = 0;
	Interface_SetCinematicMode(1);
	XGUIEng.ShowWidget("Cinematic_Text",1);
	XGUIEng.ShowWidget("Cinematic_Headline",1)
	Camera.ZoomSetDistanceFlight(10000, 1);
	Camera.RotFlight(360, WT.EndCutsceneTimer);
	StartSimpleJob("WT_EndCutsceneController");
	
	-- weltfrieden
	for i = 1,8 do
		for j = 1,8 do
			SetFriendly(i,j);
		end
	end
	
	-- disable army respawn
	EndJob(WT_AllyArmySpawnControlJob);
	for ai = WT.AI1, WT.AI2 do
		WT.AI[ai].RecruitingActive = false;
	end
end

function WT_EndCutsceneController()
	
	if WT.EndCutsceneTimer > 0 then
		WT.EndCutsceneTimer = WT.EndCutsceneTimer - 1;
		if WT.EndCutsceneTimer == 15 then
			XGUIEng.SetText("Cinematic_Text", WT.TextTable.Win1 .. tostring(WT.Winner1) .. WT.TextTable.Win2 .. tostring(WT.Winner2) .. WT.TextTable.Win3 );
			
			if GUI.GetPlayerID() == WT.Winner1ID or GUI.GetPlayerID() == WT.Winner2ID then
				XGUIEng.SetText("Cinematic_Headline", WT.TextTable.WinHead1);
				Sound.PlayGUISound(Sounds.VoicesMentor_COMMENT_GoodPlay_rnd_01,125);
			else
				XGUIEng.SetText("Cinematic_Headline", WT.TextTable.WinHead2);
				Sound.PlayGUISound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_01,125);
			end
		end
	else
		gvCamera.DefaultFlag = 1;
		Interface_SetCinematicMode(0);
		return true;
	end
end

function WT.SetupColorMapping()
	local ai1Color = XNetwork.GameInformation_GetLogicPlayerColor(WT.AI1);
	local ai2Color = XNetwork.GameInformation_GetLogicPlayerColor(WT.AI2);
	if ai1Color == 0 then
		ai1Color = 9;
	end
	if ai2Color == 0 then
		ai2Color = 13;
	end
	
	local colors = {}
	for i = 1,4 do
		colors[XNetwork.GameInformation_GetLogicPlayerColor(i)] = true;
	end
	
	-- enemy ai color not used
	colors[14] = true;
	colors[7] = true;

	-- if default colors green and white are not used by players-> use them
	if not colors[9] then
		ai1Color = 9;
		colors[9] = true;
	elseif colors[ai1Color] then
		-- set aiColor also used by player
		for i = 1, 16 do
			if not colors[i] then
				ai1Color = i;
				colors[i] = true;
				break;
			end
		end
	end
	if not colors[13] then
		ai2Color = 13;
	elseif colors[ai2Color] then
		-- set aiColor also used by player
		for i = 1, 16 do
			if not colors[i] then
				ai2Color = i;
			end
		end
	end

	-- set ingame colors
	Display.SetPlayerColorMapping(WT.AI1, ai1Color);
	Display.SetPlayerColorMapping(WT.AI2, ai2Color);
	
	-- stati colors
	local r,g,b = GUI.GetPlayerColor(WT.AI1);
	Logic.PlayerSetPlayerColor(WT.AI1, r, g, b);
	r,g,b = GUI.GetPlayerColor(WT.AI2);
	Logic.PlayerSetPlayerColor(WT.AI2, r, g, b);
	
	Display.SetPlayerColorMapping(7, 14);
	Display.SetPlayerColorMapping(8, 7);
	
	MCS.T.SetShareExploration(1, 5, 1);
	MCS.T.SetShareExploration(2, 5, 1);
	MCS.T.SetShareExploration(3, 6, 1);
	MCS.T.SetShareExploration(4, 6, 1);
	
	SetPlayerName(5, "Dorf Folklung")
	SetPlayerName(6, "Dorf Norfolk")
	-- stati
	SetPlayerName(7, "Barbaren");
	SetPlayerName(8, "Söldnerlager");
end

function WT.SetupDiplomacy()
	SetFriendly(1,2);
	SetFriendly(1,5);
	SetHostile(1,3);
	SetHostile(1,4);
	SetHostile(1,6);
	SetHostile(1,7);
	
	SetFriendly(2,5);
	SetHostile(2,3);
	SetHostile(2,4);
	SetHostile(2,6);
	SetHostile(2,7);
	
	SetFriendly(3,4);
	SetFriendly(3,6);
	SetHostile(3,5);
	SetHostile(3,7);
	
	SetFriendly(4,6);
	SetHostile(4,5);
	SetHostile(4,7);
	
	SetHostile(5,6);
	SetHostile(5,7);
	
	SetHostile(6,7);
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Armies and enemy AI

function WT.CreateEnemyAI()
	for i = 1,4 do
		SetHostile(i, WT.EnemyAI);
	end
	WT.ArmyPositions = {
		-- big spawn{X,Y}, smallspawn{X,Y}
		-- for p1
		{ {15196, 31323}, {6569,33929} },
		-- for p2
		{{61931,31487},{70373,33801}},
		-- for p3
		{{15564,45455},{6550,43123}},
		-- for p4
		{{62185,45530},{70682,43061}}
	};
	
	local x = 1000000;
	--Tools.GiveResouces(7, x, x, x, x, x, x);
	local desc = {serfLimit = 4}
	SetupPlayerAi(WT.EnemyAI,desc);
	
	-- overwrite enlarge army
	EnlargeArmy = function(_army,_troop)
		local troop = CreateTroop(_army,_troop)
		AI.Entity_ConnectLeader(troop,_army.id)
		return troop;
	end
	
	WT.Armies = {}
	local army;
	local count = 1;
	
	local troopDescription_CU_Barbarian_LeaderClub2 = {
		maxNumberOfSoldiers = 4,
		minNumberOfSoldiers = 0,
		experiencePoints = VERYLOW_EXPERIENCE,
		leaderType = Entities.CU_Barbarian_LeaderClub2
	};
	
	local troopDescription_PU_LeaderBow2 = {
		maxNumberOfSoldiers = 4,
		minNumberOfSoldiers = 0,
		experiencePoints = VERYLOW_EXPERIENCE,
		leaderType = Entities.PU_LeaderBow2
	};
	
	local rodelength = {3000, 4000}
	for i = 1,4 do
		WT.Armies[i] = {};
		for j = 1,2 do
			army = {}
			army.player = WT.EnemyAI
			army.id = count
			army.strength = 7
			army.position = {X=WT.ArmyPositions[i][j][1],Y=WT.ArmyPositions[i][j][2]}
			army.rodeLength = rodelength[j]
			SetupArmy(army)
			
			if j == 1 then
				EnlargeArmy(army, troopDescription_CU_Barbarian_LeaderClub2);
				EnlargeArmy(army, troopDescription_CU_Barbarian_LeaderClub2);
				EnlargeArmy(army, troopDescription_CU_Barbarian_LeaderClub2);
				EnlargeArmy(army, troopDescription_CU_Barbarian_LeaderClub2);
				
				EnlargeArmy(army, troopDescription_PU_LeaderBow2);
				EnlargeArmy(army, troopDescription_PU_LeaderBow2);
				EnlargeArmy(army, troopDescription_PU_LeaderBow2);
			else
				EnlargeArmy(army, troopDescription_CU_Barbarian_LeaderClub2);
				EnlargeArmy(army, troopDescription_PU_LeaderBow2);
				EnlargeArmy(army, troopDescription_PU_LeaderBow2);
			end
			FrontalAttack(army)
			WT.Armies[i][j] = army;
			count = count + 1;
		end
	end
	StartSimpleJob("WT_ArmyControl");
	WT.CreateChurchRuinSquad();
end

function WT.CreateChurchRuinSquad()
	WT.ChurchPositions = {
		{{ 3771, 24270}, { 5714, 24020}}, -- p1
		{{71261, 23915}, {73095, 24621}}, -- p2
		{{ 3803, 52314}, { 5322, 53104}}, -- p3
		{{73074, 52512}, {71158, 52889}}, -- p4
	}
	WT.ChurchTroops = {};
	for i = 1,4 do
		WT.ChurchTroops[i] = {};
		for j = 1,2 do
			local troop = AI.Entity_CreateFormation(
				WT.EnemyAI,
				Entities.PU_LeaderBow3,
				8,
				8,
				WT.ChurchPositions[i][1][1], WT.ChurchPositions[i][1][2],
				0,0,
				0,
				0
			);
			table.insert(WT.ChurchTroops[i], troop);
			Logic.GroupPatrol(troop, WT.ChurchPositions[i][2][1], WT.ChurchPositions[i][2][2]);
		end
		for j = 1,1 do
			local troop = AI.Entity_CreateFormation(
				WT.EnemyAI,
				Entities.PU_LeaderSword3,
				8,
				8,
				WT.ChurchPositions[i][1][1], WT.ChurchPositions[i][1][2],
				0,0,
				0,
				0
			);
			table.insert(WT.ChurchTroops[i], troop);
			Logic.GroupPatrol(troop, WT.ChurchPositions[i][2][1], WT.ChurchPositions[i][2][2]);
		end
	end
	WT.ChurchCounter = 0;
	StartSimpleJob("WT_ChurchTroopControl");
end

function WT_ChurchTroopControl()
	WT.ChurchCounter = WT.ChurchCounter + 1;
	if WT.ChurchCounter == 25 then
		-- respawner
		for i = 1,4 do
			if IsAlive("r"..i) then
				for j = 1, table.getn(WT.ChurchTroops[i]) do
					if not IsAlive(WT.ChurchTroops[i][j]) then
						local troop = AI.Entity_CreateFormation(
							WT.EnemyAI,
							Entities.PU_LeaderSword3,
							8,
							8,
							WT.ChurchPositions[i][1][1], WT.ChurchPositions[i][1][2],
							0,0,
							0,
							0
						);
						table.remove(WT.ChurchTroops[i], j);
						table.insert(WT.ChurchTroops[i], troop);
						Logic.GroupPatrol(troop, WT.ChurchPositions[i][2][1], WT.ChurchPositions[i][2][2]);
					end
				end
			end
		end
		WT.ChurchCounter = 0;
	end
	
	if WT.ChurchCounter == 5 then
		for i = 1,4 do
			for j = 1, table.getn(WT.ChurchTroops[i]) do
				if IsAlive(WT.ChurchTroops[i][j]) then
					if Logic.GetCurrentTaskList(WT.ChurchTroops[i][j]) == "TL_MILITARY_IDLE" then
						Logic.GroupPatrol(WT.ChurchTroops[i][j], WT.ChurchPositions[i][2][1], WT.ChurchPositions[i][2][2]);
					end
				end
			end
		end
	end
end

function WT.GetRandomTroopDesc()
	local troopDescription = {
		maxNumberOfSoldiers = 8,
		minNumberOfSoldiers = 0,
		experiencePoints = VERYLOW_EXPERIENCE,
	};
	if math.random(4) == 1 then
		-- ~20% chance for sword
		troopDescription.leaderType = Entities.CU_Barbarian_LeaderClub2;
	else
		-- ~80% chance for bow
		troopDescription.leaderType = Entities.PU_LeaderBow2;
	end
	return troopDescription;
end

function WT_ArmyControl()
	local allArmySpawnsDead = true;
	local armyType, army;
	for armyPosIndex = 1, 4 do
		for armyTypeIndex = 1,2 do
			army = WT.Armies[armyPosIndex][armyTypeIndex];
			if armyTypeIndex == 1 then
				if IsAlive("t1_"..armyPosIndex) or IsAlive("t2_"..armyPosIndex) then
					allArmySpawnsDead = false;
					if AI.Army_GetNumberOfTroops(army.player, army.id) < 2 then
						EnlargeArmy(army, WT.GetRandomTroopDesc());
					end
				end
			else
				if IsAlive("tent_"..armyPosIndex) then
					allArmySpawnsDead = false;
					if AI.Army_GetNumberOfTroops(army.player, army.id) < 1 then
						EnlargeArmy(army, WT.GetRandomTroopDesc());
					end
				end
			end
		end
	end
	
	if allArmySpawnsDead then
		return true;
	end
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Sudden death

function WT_SuddenDeathTimer()
	WT.SuddenDeathTimeCounter = WT.SuddenDeathTimeCounter - 1;
	if WT.SuddenDeathTimeCounter <= 0 then
		Message("@color:255,0,0 Sudden death started! Towers burn!");
		WT.StartSuddenDeath();
		return true;
	end
end

function WT.StartSuddenDeath()
	WT.TowerHurtCounter = 0;
	DestroyEntity("ruinX");
	Logic.CreateEntity(Entities.XD_VillageCenter, Logic.WorldGetSize()/2, Logic.WorldGetSize()/2, 0, 0);
	StartSimpleJob("WT_HurtTowers");
end

function WT_HurtTowers()
	-- 1200hp turrets 
	WT.TowerHurtCounter = WT.TowerHurtCounter + 1;
	if math.mod(WT.TowerHurtCounter, 10) == 0 then
		local allDead = true;
		for i = 1, table.getn(WT.DefendingTowers) do
			if IsAlive(WT.DefendingTowers[i]) then
				allDead = false;
				Logic.SetEntityInvulnerabilityFlag(WT.DefendingTowers[i], 0);
				Logic.HurtEntity(WT.DefendingTowers[i], 10);
				if Logic.GetEntityHealth(WT.DefendingTowers[i]) <= 0 then
					Logic.SetEntityInvulnerabilityFlag(WT.DefendingTowers[i], 1);
				end
			end
		end
		if allDead then
			return true;
		end
	end
end

-- ********************************************************************************************
-- ********************************************************************************************
-- Weather

function WT.SetupWeather()
	-- summer
	--Display.GfxSetSetLightParams(4,  0.0, 1.0,  40, -15, -75,  80, 100, 130, 200,200,200)
	--Display.GfxSetSetLightParams(4,  0.0, 1.0,  40, -15, -75,  100, 100, 100, 200,200,200)
	--Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 152,172,182, 9000,25000)
	
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 152,172,182, 9000,28000)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)
	
	-- summer special
	Display.GfxSetSetSnowEffectStatus(1, 0, 6.0, 1);
	Display.GfxSetSetSnowStatus(1, 0, 0.8, 0);
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 152,172,182, 9000,28000)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)
	
	-- rain
	Display.GfxSetSetSnowEffectStatus(2, 0, 1.0, 1);
	Display.GfxSetSetSnowStatus(2, 0.0, 1.0, 0);
	Display.GfxSetSetRainEffectStatus(2, 0, 0.8, 1);
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 102,132,142, 6000,28000)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)

	-- winter
	Display.GfxSetSetSnowStatus(3, 0, 0.8, 1);
	Display.GfxSetSetSnowEffectStatus(3, 0, 1.0, 1);
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 152,172,182, 6000,23000)
	Display.GfxSetSetLightParams(3,  0.0, 1.0,  40, -15, -75,  116,144,164, 255,234,202)

	-- winter special (no snow)
	Display.GfxSetSetLightParams(5,  0.0, 1.0,  40, -15, -75,  110, 140, 150, 200,200,230)
	Display.GfxSetSetSnowEffectStatus(5, 0, 1.0, 0);
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 1);
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 152,172,182, 5000,23000)
	Display.GfxSetSetLightParams(5,  0.0, 1.0,  40, -15, -75,  116,144,164, 255,234,202)
end

function WT.StartWeather()
--[[
	Param1: Weather State of period, 1 = normal, 2 = rain, 3 = snow
	Param2: Duration of period in seconds
	Param3: Is periodic, 1 for (normal)periodic weather element else 0 for weather machine effects
	Param4: Gfx Set of this weather element
	Param5: Gfx Set forerun (gfx transition start some time before logic state change), time in seconds
	Param6: duration of Gfx Set transition
]]
	local summer = function(_time) Logic.AddWeatherElement(1, _time*60, 0, 4, 5, 10); end
	local rain = function(_time) Logic.AddWeatherElement(2, _time*60, 1, 2, 5, 10); end
	local winter = function(_time) Logic.AddWeatherElement(3, _time*60, 1, 3, 5, 10); end
	local summer_special = function(_time) Logic.AddWeatherElement(2, _time*60, 1, 1, 5, 10); end
	local winter_special = function(_time) Logic.AddWeatherElement(3, _time*60, 1, 5, 5, 10); end
	summer(5)
	summer_special(8)
	winter(5)
	winter_special(2)
	rain(2)
	winter(5)
	rain(1)
	summer_special(5)
	winter(7)
	rain(1)
	winter_special(7)
	winter(4)
	summer_special(5)
	winter(15)
end

function CreateWoodPile( _posEntity, _resources )
    assert( type( _posEntity ) == "string" );
    assert( type( _resources ) == "number" );
    gvWoodPiles = gvWoodPiles or {
        JobID = StartSimpleJob("ControlWoodPiles"),
    };
    local pos = GetPosition( _posEntity );
    local pile_id = Logic.CreateEntity( Entities.XD_Rock3, pos.X, pos.Y, 0, 0 );
	
    SetEntityName( pile_id, _posEntity.."_WoodPile" );
	
    local newE = ReplaceEntity( _posEntity, Entities.XD_ResourceTree );
	Logic.SetModelAndAnimSet(newE, Models.XD_SignalFire1);
    Logic.SetResourceDoodadGoodAmount( GetEntityId( _posEntity ), _resources*10 );
	Logic.SetModelAndAnimSet(pile_id, Models.Effects_XF_ChopTree);
    table.insert( gvWoodPiles, { ResourceEntity = _posEntity, PileEntity = _posEntity.."_WoodPile", ResourceLimit = _resources*9 } );
end

function ControlWoodPiles()
    for i = table.getn( gvWoodPiles ),1,-1 do
        if Logic.GetResourceDoodadGoodAmount( GetEntityId( gvWoodPiles[i].ResourceEntity ) ) <= gvWoodPiles[i].ResourceLimit then
            DestroyWoodPile( gvWoodPiles[i], i );
        end
    end
end
 
function DestroyWoodPile( _piletable, _index )
    local pos = GetPosition( _piletable.ResourceEntity );
    DestroyEntity( _piletable.ResourceEntity );
    DestroyEntity( _piletable.PileEntity );
    Logic.CreateEffect( GGL_Effects.FXCrushBuilding, pos.X, pos.Y, 0 );
    table.remove( gvWoodPiles, _index )
end

function WT.SetupChests()
	WT.ChestsActive = {
		false,
		false,
		false,
		false
	};
	WT.ChestsDestroyed = {
		false,
		false,
		false,
		false
	};
	StartSimpleJob("WT_ChestControl");
end

function WT_ChestControl()
	for i = 1,4 do
		if Logic.IsEntityDestroyed(GetEntityId("st"..i)) then
			WT.ChestsActive[i] = true;
		end
	end
	local entities, pos;
	for i = 1,4 do
		if WT.ChestsActive[i] and not WT.ChestsDestroyed[i] then
			pos = GetPosition("ch"..i);
			for j = 1, 4 do
				entities = {Logic.GetPlayerEntitiesInArea(j, 0, pos.X, pos.Y, 1000, 1)};
				if entities[1] > 0 then
					Message("@color:0,255,255 " .. UserTool_GetPlayerName(j) .. WT.TextTable.Chest1 .. UserTool_GetPlayerName(i) .. WT.TextTable.Chest2);
					AddGold(j, 1000);
					WT.ChestsDestroyed[i] = true;
					ReplaceEntity("ch"..i, Entities.XD_ChestOpen);
					local allDestroyed = true;
					for x = 1,4 do
						if not WT.ChestsDestroyed[x] then
							allDestroyed = false;
						end
					end
					if allDestroyed then
						return true;
					end
				end
			end
		end
	end
end

function GetMercenaryOfferLeft(id, slot)
    assert(IsValid(id), "invalid")
    local sv = S5Hook.GetEntityMem(id)
    local vtable = tonumber("7782C0", 16)
    local number = (sv[32]:GetInt() - sv[31]:GetInt()) / 4
    for i=0,number-1 do
        if sv[31][i]:GetInt()>0 and sv[31][i][0]:GetInt()==vtable then
            local sv2 = sv[31][i]
            local number2 = (sv2[8]:GetInt() - sv2[7]:GetInt()) / 4
            assert(number2 >= slot, "slot invalid")
            return sv2[7][slot][19]:GetInt()
        end
    end
    assert(false, "behavior not found")
end

function SetMercenaryOfferLeft(id, slot, left)
    assert(IsValid(id), "invalid")
    local sv = S5Hook.GetEntityMem(id)
    local vtable = tonumber("7782C0", 16)
    local number = (sv[32]:GetInt() - sv[31]:GetInt()) / 4
    for i=0,number-1 do
        if sv[31][i]:GetInt()>0 and sv[31][i][0]:GetInt()==vtable then
            local sv2 = sv[31][i]
            local number2 = (sv2[8]:GetInt() - sv2[7]:GetInt()) / 4
            assert(number2 >= slot, "slot invalid")
            sv2[7][slot][19]:SetInt(left)
            return
        end
    end
    assert(false, "behavior not found")
end

WT.MercernaryCounters = {
	10*60,
	10*60,
}

WT.Mercenaries = {
	GetEntityId("merc1"),
	GetEntityId("merc2")
}

function WT_MercernaryRefiller()
	for i = 1,2 do
		if GetMercenaryOfferLeft(WT.Mercenaries[i], 0) < 3 then
			WT.MercernaryCounters[i] = WT.MercernaryCounters[i] - 1;
			if WT.MercernaryCounters[i] <= 0 then
				WT.MercernaryCounters[i] = 10*60;
				SetMercenaryOfferLeft(WT.Mercenaries[i], 0, 3);
			end
		end
	end
end
























