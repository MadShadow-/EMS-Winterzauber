function AddTribute( _tribute )
	assert( type( _tribute ) == "table", "Tribut muß ein Table sein" );
	assert( type( _tribute.text ) == "string", "Tribut.text muß ein String sein" );
	assert( type( _tribute.cost ) == "table", "Tribut.cost muß ein Table sein" );
	assert( type( _tribute.pId ) == "number", "Tribut.pId muß eine Nummer sein" );
	assert( not _tribute.Tribute , "Tribut.Tribute darf nicht vorbelegt sein");

	uniqueTributeCounter = uniqueTributeCounter or 1;
	_tribute.Tribute = uniqueTributeCounter;
	uniqueTributeCounter = uniqueTributeCounter + 1;

	local tResCost = {};
	for k, v in pairs( _tribute.cost ) do
		assert( ResourceType[k] );
		assert( type( v ) == "number" );
		table.insert( tResCost, ResourceType[k] );
		table.insert( tResCost, v );
	end

	Logic.AddTribute( _tribute.pId, _tribute.Tribute, 0, 0, _tribute.text, unpack( tResCost ) );
	SetupTributePaid( _tribute );
	return _tribute.Tribute;
end

function SetShareExploration(_player, _target, _flag)
	if Comforts.ExplorationShared[_player][_target] == _flag then
		return;
	end
	Comforts.ExplorationShared[_player][_target] = _flag;
	Logic.SetShareExplorationWithPlayerFlag( _player, _target, _flag );
	-- notify callbacks that exploration has been changed
	for i = 1, table.getn(Comforts.ExplorationUpdates) do
		Comforts.ExplorationUpdates[i](_player, _target, _flag);
	end
end

function GetShareExploration(_player, _target)
	return Comforts.ExplorationShared[_player][_target];
end

function AddShareExplorationCallback(_function)
	table.insert(Comforts.ExplorationUpdates, _function);
end