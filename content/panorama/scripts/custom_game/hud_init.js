(function () {
	InitializeUI()
})();

function InitializeUI() {

	// Eliminating unnecessary vanilla HUD elements
	FindDotaHudElement("inventory_tpscroll_container").style.visibility = 'collapse';
	FindDotaHudElement("left_flare").style.visibility = 'collapse';
	FindDotaHudElement("xp").style.visibility = 'collapse';
	FindDotaHudElement("stats_container").style.visibility = 'collapse';
	FindDotaHudElement("unitbadge").style.visibility = 'collapse';
	//FindDotaHudElement("abilities").style.visibility = 'collapse';

	// Unit portrait adjustments
	FindDotaHudElement("PortraitBacker")["style"]["margin-left"] = '10px';
	FindDotaHudElement("PortraitBackerColor")["style"]["margin-left"] = '10px';
	FindDotaHudElement("PortraitContainer")["style"]["margin-left"] = '10px';
	FindDotaHudElement("InspectButton")["style"]["margin-left"] = '22px';
	FindDotaHudElement("HeroViewButton")["style"]["margin-left"] = '10px';
	FindDotaHudElement("PortraitContainer")["style"]["margin-top"] = '20px';
	FindDotaHudElement("PortraitBacker")["style"]["margin-top"] = '20px';
	FindDotaHudElement("PortraitBackerColor")["style"]["margin-top"] = '20px';
	FindDotaHudElement("unitname")["style"]["margin-left"] = '10px';
	FindDotaHudElement("PortraitBacker")["style"]["vertical-align"] = 'top';
	FindDotaHudElement("PortraitBackerColor")["style"]["vertical-align"] = 'top';
	FindDotaHudElement("PortraitContainer")["style"]["vertical-align"] = 'top';
	FindDotaHudElement("unitname")["style"]["vertical-align"] = 'top';
	FindDotaHudElement("UnitNameLabel")["style"]["padding-left"] = '0px';
	FindDotaHudElement("center_with_stats")["style"]["horizontal-align"] = 'left';

	// Events
	//CustomNetTables.SubscribeNetTableListener("drop_positions", UpdateDropPosition)
	//GameEvents.Subscribe("drop_map_choice_finished", MapDropChoiceFinished);

	GameUI.SetCameraPitchMin(10)
	if ( Players.GetTeam(Game.GetLocalPlayerID()) == DOTATeam_t.DOTA_TEAM_BADGUYS) {
		GameUI.SetCameraYaw(180)
	}
	$.Msg("initialized game UI")
}

//GameEvents.SendCustomGameEventToServer('debug_start_level', {level: level});

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