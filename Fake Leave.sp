#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <autoexecconfig>

#define CS_TEAM_NONE        0  // Dont have Team | Sem equipa
#define CS_TEAM_SPECTATOR   1  // Spectator | Espectador
#define CS_TEAM_T       2      // Terrorist | Terrorista
#define CS_TEAM_CT      3      // Counter-Terrorists | Contra-Terrorista

#pragma newdecls required

ConVar gConVar_Staff_Join;
ConVar gConVar_Staff_Leave;
ConVar gConVar_Join_StaffMode;
ConVar gConVar_Leave_StaffMode;

//======================================================================================
// This plugin requires 2 dependencies:
// Admin WallHack for Spectators - https://forums.alliedmods.net/showthread.php?t=312982
// Admin STEALTH - https://forums.alliedmods.net/showthread.php?t=195733
//======================================================================================

//======================================================================================
// Este plugin requer 2 dependências:
// Admin WallHack for Spectators - https://forums.alliedmods.net/showthread.php?t=312982
// Admin STEALTH - https://forums.alliedmods.net/showthread.php?t=195733
//======================================================================================

public Plugin myinfo = 
{
	name = "Fake Leave", 
	author = "LanteJoula", 
	description = "Fake Leave Server for Staff with chat message and autojoin with message", 
	version = "1.2", 
	url = "https://steamcommunity.com/id/lantejoula/"
};

public void OnPluginStart()
{
	LoadTranslations("fakeleave.phrases");
	RegAdminCmd("sm_fake", CommandFake, ADMFLAG_GENERIC, "Switch to stealth mode and send fake leave chat msg");
	RegAdminCmd("sm_t", JoinTeamT, ADMFLAG_GENERIC, "go to T team");
	RegAdminCmd("sm_ct", JoinTeamCT, ADMFLAG_GENERIC, "go to CT team");
	
	
	AutoExecConfig_SetFile("plugin.fakeleave");
	
	gConVar_Staff_Join = AutoExecConfig_CreateConVar("sm_joinstaff_message", "1", "Enable/Disable the Fake Join Staff Message (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	gConVar_Staff_Leave = AutoExecConfig_CreateConVar("sm_leavestaff_message", "1", "Enable/Disable the Fake Leave Staff Message (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	gConVar_Join_StaffMode = AutoExecConfig_CreateConVar("sm_join_staffmode_message", "1", "Enable/Disable the Join Staff Mode (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	gConVar_Leave_StaffMode = AutoExecConfig_CreateConVar("sm_leave_staffmode_message", "1", "Enable/Disable the Leave Staff Mode (1 - Enable | 0 - Disable)", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public Action CommandFake(int client, int args)
{
	if (GetUserFlagBits(client))
	{
		FakeClientCommand(client, "sm_stealth");
		char name[128];
		GetClientName(client, name, sizeof(name));
		if (gConVar_Staff_Leave.BoolValue)
			CPrintToChatAll("%t", "Staff Leave", name);
		if (gConVar_Join_StaffMode.BoolValue)
			CPrintToChat(client, "%t %t", "Prefix", "Join Staff Mode");
	}
	else
	{
		CPrintToChat(client, "%t %t", "Prefix", "You dont have access");
	}
}

public Action JoinTeamT(int client, int args)
{
	if (GetUserFlagBits(client))
	{
		char name[128];
		GetClientName(client, name, sizeof(name));
		ChangeClientTeam(client, CS_TEAM_T);
		GetClientName(client, name, sizeof(name));
		if (gConVar_Staff_Join.BoolValue)
			CPrintToChatAll("%t", "Staff Join", name);
		if (gConVar_Leave_StaffMode.BoolValue)
			CPrintToChat(client, "%t %t", "Prefix", "Leave Staff Mode");
	}
	else
	{
		CPrintToChat(client, "%t %t", "Prefix", "You dont have access");
	}
	return Plugin_Handled;
}

public Action JoinTeamCT(int client, int args)
{
	if (GetUserFlagBits(client))
	{
		char name[128];
		GetClientName(client, name, sizeof(name));
		ChangeClientTeam(client, CS_TEAM_CT);
		if (gConVar_Staff_Join.BoolValue)
			CPrintToChatAll("%t", "Staff Join", name);
		if (gConVar_Leave_StaffMode.BoolValue)
			CPrintToChat(client, "%t %t", "Prefix", "Leave Staff Mode");
	}
	else
	{
		CPrintToChat(client, "%t %t", "Prefix", "You dont have access");
	}
	return Plugin_Handled;
}

stock bool IsValidClient(int client)
{
	return (1 <= client <= MaxClients && IsClientInGame(client) && !IsClientSourceTV(client));
}
