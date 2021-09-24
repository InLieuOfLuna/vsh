#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <clientprefs>

#include <morecolors>
#include <vsh2>


public Plugin myinfo = {
	name        = "VSH2 dmg tracker",
	author      = "Nergal, all props to Aurora",
	description = "",
	version     = "1.1",
	url         = "https://github.com/VSH2-Devs/VSH2-Addons"
};


enum {
	RED, GREEN, BLUE, ALPHA,
	MaxColors
}

enum struct DmgTrackerData {
	int RGBA[MaxColors];
	int DmgSetting;
}

DmgTrackerData g_dmg[MAXPLAYERS+1];
Handle         g_hDamageHUD;
Cookie         g_haledmg_cookie;


public void OnLibraryAdded(const char[] name) {
	if( StrEqual(name, "VSH2") ) {
		g_haledmg_cookie = new Cookie("vsh2_haledmg", "cookie to track boss damage settings", CookieAccess_Public);
		RegConsoleCmd("haledmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
		RegConsoleCmd("vsh2dmg", Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
		RegConsoleCmd("ff2dmg",  Command_damagetracker, "haledmg - Enable/disable the damage tracker.");
		CreateTimer(180.0, Timer_Advertise);
		g_hDamageHUD = CreateHudSynchronizer();
	}
}

public void OnMapStart() {
	CreateTimer(0.1, Timer_Millisecond, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Advertise(Handle timer) {
	CreateTimer(180.0, Timer_Advertise);
	CPrintToChatAll("{olive}[VSH 2]{default} Type \"!haledmg on\" to display the top 3 players! Type \"!haledmg off\" to turn it off again.");
	return Plugin_Handled;
}

public Action Command_damagetracker(int client, int args) {
	if( client==0) {
		PrintToServer("[VSH 2] The damage tracker cannot be enabled by Console.");
		return Plugin_Handled;
	} else if( args==0 ) {
		char playersetting[3];
		if( g_dmg[client].DmgSetting == 0 ) {
			playersetting = "Off";
		}
		if( g_dmg[client].DmgSetting > 0 ) {
			playersetting = "On";
		}
		CPrintToChat(client, "{olive}[VSH 2]{default} The damage tracker is {olive}%s{default}.\n{olive}[VSH 2]{default} Change it by saying \"!haledmg on [R] [G] [B] [A]\" or \"!haledmg off\"!", playersetting);
		return Plugin_Handled;
	}
	char arg1[64];
	int newval = 3;
	GetCmdArg(1, arg1, sizeof(arg1));
	if( StrEqual(arg1, "off", false) ) {
		g_dmg[client].DmgSetting = 0;
	}
	if( StrEqual(arg1, "on", false) ) {
		g_dmg[client].DmgSetting = 3;
	}
	if( StrEqual(arg1, "0", false) ) {
		g_dmg[client].DmgSetting = 0;
	}
	if( StrEqual(arg1, "of", false) ) {
		g_dmg[client].DmgSetting = 0;
	}
	
	if( !StrEqual(arg1, "off", false) && !StrEqual(arg1, "on", false) && !StrEqual(arg1, "0", false) && !StrEqual(arg1, "of", false) ) {
		newval = StringToInt(arg1);
		char newsetting[3];
		if( newval > 8 ) {
			newval = 8;
		}
		if( newval != 0 ) {
			g_dmg[client].DmgSetting = newval;
		}
		if( newval != 0 && g_dmg[client].DmgSetting == 0 ) {
			newsetting = "off";
		}
		if( newval != 0 && g_dmg[client].DmgSetting > 0 ) {
			newsetting = "on";
		}
		
		CPrintToChat(client, "{olive}[VSH 2]{default} The damage tracker is now {lightgreen}%s{default}!", newsetting);
		if( AreClientCookiesCached(client) ) {
			char strval[6]; IntToString(g_dmg[client].DmgSetting, strval, sizeof(strval));
			g_haledmg_cookie.Set(client, strval);
		}
	}
	
	char r[4], g[4], b[4], a[4];
	if(args >= 2) {
		GetCmdArg(2, r, sizeof(r));
		if(!StrEqual(r, "_"))
			g_dmg[client].RGBA[RED] = StringToInt(r);
	}
	
	if(args >= 3) {
		GetCmdArg(3, g, sizeof(g));
		if(!StrEqual(g, "_"))
			g_dmg[client].RGBA[GREEN] = StringToInt(g);
	}
	if(args >= 4) {
		GetCmdArg(4, b, sizeof(b));
		if(!StrEqual(b, "_"))
			g_dmg[client].RGBA[BLUE] = StringToInt(b);
	}
	if(args >= 5) {
		GetCmdArg(5, a, sizeof(a));
		if(!StrEqual(a, "_"))
			g_dmg[client].RGBA[ALPHA] = StringToInt(a);
	}
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	g_dmg[client].DmgSetting = 0;
	g_dmg[client].RGBA[RED] = 255;
	g_dmg[client].RGBA[GREEN] = 90;
	g_dmg[client].RGBA[BLUE] = 30;
	g_dmg[client].RGBA[ALPHA] = 255;
	
	if( AreClientCookiesCached(client) ) {
		char setting[2]; g_haledmg_cookie.Get(client, setting, sizeof(setting));
		g_dmg[client].DmgSetting = StringToInt(setting);
	}
}

public Action Timer_Millisecond(Handle timer)
{
	if( VSH2GameMode.GetPropInt("iRoundState") != StateRunning )
		return Plugin_Continue;
	
	VSH2Player top_players[3];
	VSH2Player(0).SetPropInt("iDamage", 0);
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) || GetClientTeam(i) < VSH2Team_Red ) {
			continue;
		}
		
		VSH2Player player = VSH2Player(i);
		if( player.GetPropInt("bIsBoss") || player.GetPropInt("iDamage")==0 ) {
			continue;
		} else if( player.GetPropInt("iDamage") >= top_players[0].GetPropInt("iDamage") ) {
			top_players[2] = top_players[1];
			top_players[1] = top_players[0];
			top_players[0] = player;
		} else if( player.GetPropInt("iDamage") >= top_players[1].GetPropInt("iDamage") ) {
			top_players[2] = top_players[1];
			top_players[1] = player;
		} else if( player.GetPropInt("iDamage") >= top_players[2].GetPropInt("iDamage") ) {
			top_players[2] = player;
		}
	}
	
	char names[3][64];
	int damages[3];
	for( int i; i<3; i++ ) {
		int dmg = top_players[i].GetPropInt("iDamage");
		if( top_players[i].index && dmg > 0 ) {
			GetClientName(top_players[i].index, names[i], sizeof(names[]));
			damages[i] = dmg;
		} else {
			names[i] = "nil";
		}
	}
	
	char damage_list[512];
	Format(damage_list, sizeof(damage_list), "Most damage dealt by:\n1)%i - %s\n2)%i - %s\n3)%i - %s", damages[0], names[0], damages[1], names[1], damages[2], names[2]);
	
	for( int i=MaxClients; i; --i ) {
		if( !IsValidClient(i) ) {
			continue;
		}
		VSH2Player player = VSH2Player(i);
		if( g_dmg[i].DmgSetting > 0 ) {
			if( !player.GetPropInt("bIsBoss") && !(GetClientButtons(i) & IN_SCORE) ) {
				SetHudTextParams(0.0, 0.0, 0.2, g_dmg[i].RGBA[RED], g_dmg[i].RGBA[GREEN], g_dmg[i].RGBA[BLUE], g_dmg[i].RGBA[ALPHA]);
				ShowSyncHudText(i, g_hDamageHUD, "%s", damage_list);
			}
		}
	}
	return Plugin_Continue;
}

stock bool IsValidClient(const int client, bool nobots=false)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
		return false; 
	return IsClientInGame(client); 
}