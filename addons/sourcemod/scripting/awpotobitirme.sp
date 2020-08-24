#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <multicolors>

#define DEBUG

#pragma semicolon 1
#pragma newdecls required

ConVar turbitis_delay;
ConVar eklenti_tag_cvar;

Handle g_SlayTimer = INVALID_HANDLE;

char timer_gosterici[64];
char eklenti_tagi[64];

public Plugin myinfo = 
{
	name = "Awp - Aim 1v1 Oto tur bitirme",
	author = "ByDexter",
	description = "Awp - Aim haritalarda 1v1 kalındığında X saniye sonra oyuncular öldürülür",
	version = "1.0",
	url = "https://steamcommunity.com/id/ByDexterTR/"
};

public void OnPluginStart()
{
	turbitis_delay = CreateConVar("sm_roundend_delay", "20", "Kaç saniye sonra oyuncular öldürülsün", FCVAR_NOTIFY, true, 0.0, true, 60.0);
	eklenti_tag_cvar = CreateConVar("prefix", "ByDexter", "Eklentinin chat kısmından geçeceği reklam tagı", FCVAR_NOTIFY);
	HookEvent("player_death", Control_Auto, EventHookMode_PostNoCopy);
	AutoExecConfig(true, "1v1otobitirme", "sourcemod");
}

public Action Control_Auto(Handle event, const char[] name, bool dontBroadcast)
{
	GetConVarString(eklenti_tag_cvar, eklenti_tagi, sizeof(eklenti_tagi));
	GetConVarString(turbitis_delay, timer_gosterici, sizeof(timer_gosterici));
	int T_Sayisi = 0;
	int CT_Sayisi = 0;	
	for (int i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i) && IsPlayerAlive(i))
	{
		if(GetClientTeam(i) == CS_TEAM_T)
		{
			T_Sayisi++;
		}
		if(GetClientTeam(i) == CS_TEAM_CT)
		{
			CT_Sayisi++;		
		}	
	}
	if(T_Sayisi == 1 && CT_Sayisi == 1)
	{
		CPrintToChatAll("{darkred}[%s] {darkblue}1v1 Kaldınız! {green}%s saniye {default}sonra iki takım oyuncusuda öldürülecektir",  eklenti_tagi, timer_gosterici);
		g_SlayTimer = CreateTimer(turbitis_delay.FloatValue, Slay_Roundend);
	}
	else
	{
		if(g_SlayTimer != INVALID_HANDLE)
		{
			KillTimer(g_SlayTimer);
			g_SlayTimer = INVALID_HANDLE;
		}
	}
}

public Action Slay_Roundend(Handle Timer)
{
	for (int i = 1; i <= MaxClients; i++) 
	if(IsPlayerAlive(i))
	{
		ForcePlayerSuicide(i);
	}
}

public void OnAutoConfigsBuffered()
{
    CreateTimer(3.0, awpaimcontrol);
}

public Action awpaimcontrol(Handle timer)
{
    char filename[512];
    GetPluginFilename(INVALID_HANDLE, filename, sizeof(filename));
    char mapname[PLATFORM_MAX_PATH];
    GetCurrentMap(mapname, sizeof(mapname));
    if (StrContains(mapname, "awp_", false) == -1)
    {
        ServerCommand("sm plugins unload %s", filename);
    }
    else
    if (StrContains(mapname, "aim", false) == -1)
    {
        ServerCommand("sm plugins unload %s", filename);
    }
    else 
    if (StrContains(mapname, "awp_", false) == 0)
    {
        ServerCommand("sm plugins load %s", filename);
    }
    else
    if (StrContains(mapname, "aim_", false) == 0)
    {
        ServerCommand("sm plugins load %s", filename);
    }
    return Plugin_Stop;
}