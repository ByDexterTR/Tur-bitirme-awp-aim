#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

ConVar turbitis_delay = null;
Handle g_SlayTimer = null;

public Plugin myinfo = 
{
	name = "Awp - Aim 1v1 Oto tur bitirme", 
	author = "ByDexter", 
	description = "Awp - Aim haritalarda 1v1 kalındığında X saniye sonra oyuncular öldürülür", 
	version = "1.1 - Optimization", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#5494"
};

public void OnPluginStart()
{
	turbitis_delay = CreateConVar("sm_bitirme_delay", "20", "Kaç saniye sonra oyuncular öldürülsün", FCVAR_NOTIFY, true, 0.0, true, 120.0);
	HookEvent("round_start", Control_Auto, EventHookMode_PostNoCopy);
	HookEvent("round_end", Control_End, EventHookMode_PostNoCopy);
	HookEvent("player_death", Control_Auto, EventHookMode_PostNoCopy);
	AutoExecConfig(true, "Otomatik-Turbitirme", "ByDexter");
}

public void OnMapStart()
{
	char mapname[PLATFORM_MAX_PATH];
	GetCurrentMap(mapname, sizeof(mapname));
	if (strcmp(mapname, "awp_") != 0)
	{
		SetFailState("[Otomatik-Tur-Bitirme] Awp Haritalarinda calismaktadir!");
	}
}

public Action Control_Auto(Event event, const char[] name, bool dontBroadcast)
{
	int T_Sayisi = 0;
	int CT_Sayisi = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				T_Sayisi++;
			}
			if (GetClientTeam(i) == CS_TEAM_CT)
			{
				CT_Sayisi++;
			}
		}
	}
	if (T_Sayisi == 1 && CT_Sayisi == 1)
	{
		PrintToChatAll("[SM] \x041v1 Kaldınız! \x10%d saniye \x01sonra iki takım oyuncusuda öldürülecektir!", turbitis_delay.IntValue);
		if (g_SlayTimer != null)
			delete g_SlayTimer;
		g_SlayTimer = CreateTimer(turbitis_delay.FloatValue, Slay_Roundend, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Control_End(Event event, const char[] name, bool dontBroadcast)
{
	if (g_SlayTimer != null)
	{
		delete g_SlayTimer;
		g_SlayTimer = null;
	}
}

public Action Slay_Roundend(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			ForcePlayerSuicide(i);
		}
	}
	g_SlayTimer = null;
	return Plugin_Stop;
} 