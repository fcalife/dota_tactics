(function () {
	StartTrackingMouse()

	CustomNetTables.SubscribeNetTableListener("turn_manager", UpdateTurnInfo);
})();

var CONSUME_EVENT = true;
var CONTINUE_PROCESSING_EVENT = false;

function StartTrackingMouse() {

	// Track player mouse movement and clicking
	MousePositionThink();
	GameUI.SetMouseCallback(MouseClickFilter);

	$.Msg("initialized mouse tracking");
}

function UpdateTurnInfo(keys) {
	var time = CustomNetTables.GetTableValue("turn_manager", "turn_time").time;
	var radiant_ap = CustomNetTables.GetTableValue("turn_manager", "action_points").radiant;
	var dire_ap = CustomNetTables.GetTableValue("turn_manager", "action_points").dire;
	var radiant_mana = CustomNetTables.GetTableValue("turn_manager", "mana").radiant;
	var dire_mana = CustomNetTables.GetTableValue("turn_manager", "mana").dire;

	$('#timer').text = time;
	$('#radiant_ap').text = radiant_ap;
	$('#dire_ap').text = dire_ap;
	$('#radiant_mana').text = radiant_mana;
	$('#dire_mana').text = dire_mana;
}

function RequestEndTurn() {
	GameEvents.SendCustomGameEventToServer("end_turn", {player_id: Game.GetLocalPlayerID()});
}

function MousePositionThink() {
	is_looping = true
	var mouse_position = GameUI.GetCursorPosition();
	var world_coords = Game.ScreenXYToWorld(mouse_position[0], mouse_position[1]);
	var player_id = Game.GetLocalPlayerID()
	var selected_entities = Players.GetSelectedEntities(player_id)

	// Prune excess selected entities if necessary
	if (selected_entities.length > 1) {
		GameUI.SelectUnit(selected_entities[0], false)
		selected_entities = Players.GetSelectedEntities(player_id)
	}

	// Update mouse position and unit selection
	GameEvents.SendCustomGameEventToServer("mouse_position_think", {x: world_coords[0], y: world_coords[1], player_id: player_id, selected_entity: selected_entities[0], active_ability: Abilities.GetLocalPlayerActiveAbility()});

	$.Schedule(0.03, MousePositionThink);
}

// 0 = left-click, 1 = right-click, 2 = mouse wheel click
function MouseClickFilter(event, button) {
	if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
		return CONTINUE_PROCESSING_EVENT;
	}

	if (event == "pressed") {
		var player_id = Game.GetLocalPlayerID()
		if (button == 0) {
			GameEvents.SendCustomGameEventToServer("left_mouse_pressed", {player_id: player_id});
		}
		if (button == 1) {
			GameEvents.SendCustomGameEventToServer("right_mouse_pressed", {player_id: player_id});
		}
	}
	return CONTINUE_PROCESSING_EVENT;
}

// Utility functions
function FindDotaHudElement (id) {
	return GetDotaHud().FindChildTraverse(id);
}

function GetDotaHud () {
	var p = $.GetContextPanel();
	while (p !== null && p.id !== 'Hud') {
		p = p.GetParent();
	}
	if (p === null) {
		throw new HudNotFoundException('Could not find Hud root as parent of panel with id: ' + $.GetContextPanel().id);
	} else {
		return p;
	}
}

// Checks if the local player has local privileges
function CheckForHostPrivileges() {
	var player_info = Game.GetLocalPlayerInfo();
	if ( !player_info ) {
		return undefined;
	} else {
		return player_info.player_has_host_privileges;
	}
}