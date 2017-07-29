/*  CS:GO Weapons&Knives SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <PTaH>

#pragma semicolon 1
#pragma newdecls required

#include "weapons/globals.sp"
#include "weapons/hooks.sp"
#include "weapons/helpers.sp"
#include "weapons/database.sp"
#include "weapons/config.sp"
#include "weapons/menus.sp"

public Plugin myinfo = 
{
	name = "Weapons & Knives",
	author = "kgns - wasdzone",
	description = "All in one custom weapon management",
	version = "1.0.9",
	url = "http://www.wasdzone.com"
};

public void OnPluginStart()
{
	LoadTranslations("weapons.phrases");
	
	g_Cvar_DBConnection = CreateConVar("sm_weapons_db_connection", "storage-local", "Database connection name in databases.cfg to use");
	g_Cvar_TablePrefix = CreateConVar("sm_weapons_table_prefix", "", "Prefix for database table (example: 'xyz_')");
	g_Cvar_ChatPrefix = CreateConVar("sm_weapons_chat_prefix", "[wasdzone]", "Prefix for chat messages");
	g_Cvar_KnifeStatTrakMode = CreateConVar("sm_weapons_knife_stattrak_mode", "0", "0: All knives show the same StatTrak counter (total knife kills) 1: Each type of knife shows its own separate StatTrak counter");
	g_Cvar_EnableFloat = CreateConVar("sm_weapons_enable_float", "1", "Enable/Disable weapon float options");
	g_Cvar_EnableNameTag = CreateConVar("sm_weapons_enable_nametag", "1", "Enable/Disable name tag options");
	g_Cvar_EnableStatTrak = CreateConVar("sm_weapons_enable_stattrak", "1", "Enable/Disable StatTrak options");
	g_Cvar_FloatIncrementSize = CreateConVar("sm_weapons_float_increment_size", "0.05", "Increase/Decrease by value for weapon float");
	
	AutoExecConfig(true, "weapons");
	
	RegConsoleCmd("buyammo1", CommandWeaponSkins);
	RegConsoleCmd("sm_ws", CommandWeaponSkins);
	RegConsoleCmd("buyammo2", CommandKnife);
	RegConsoleCmd("sm_knife", CommandKnife);
	RegConsoleCmd("sm_nametag", CommandNameTag);
	RegConsoleCmd("sm_wslang", CommandWSLang);
	//RegConsoleCmd("sm_reportdata", CommandReportData);
	
	PTaH(PTaH_GiveNamedItemPre, Hook, GiveNamedItemPre);
	PTaH(PTaH_GiveNamedItem, Hook, GiveNamedItem);
}

public void OnConfigsExecuted()
{
	GetConVarString(g_Cvar_DBConnection, g_DBConnection, sizeof(g_DBConnection));
	GetConVarString(g_Cvar_TablePrefix, g_TablePrefix, sizeof(g_TablePrefix));
	
	if(g_DBConnectionOld[0] != EOS && strcmp(g_DBConnectionOld, g_DBConnection) != 0 && db != null)
	{
		delete db;
		db = null;
	}
	
	if(db == null)
	{
		Database.Connect(SQLConnectCallback, g_DBConnection);
	}
	
	strcopy(g_DBConnectionOld, sizeof(g_DBConnectionOld), g_DBConnection);
	
	g_Cvar_ChatPrefix.GetString(g_ChatPrefix, sizeof(g_ChatPrefix));
	g_iKnifeStatTrakMode = g_Cvar_KnifeStatTrakMode.IntValue;
	g_iEnableFloat = g_Cvar_EnableFloat.IntValue;
	g_iEnableNameTag = g_Cvar_EnableNameTag.IntValue;
	g_iEnableStatTrak = g_Cvar_EnableStatTrak.IntValue;
	g_fFloatIncrementSize = g_Cvar_FloatIncrementSize.FloatValue;
	g_iFloatIncrementPercentage = RoundFloat(g_fFloatIncrementSize * 100.0);
	ReadConfig();
}

public Action CommandWeaponSkins(int client, int args)
{
	if (IsValidClient(client))
	{
		CreateMainMenu(client).Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action CommandKnife(int client, int args)
{
	if (IsValidClient(client))
	{
		CreateKnifeMenu(client).Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action CommandWSLang(int client, int args)
{
	if (IsValidClient(client))
	{
		CreateLanguageMenu(client).Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action CommandNameTag(int client, int args)
{
	if(g_iEnableNameTag == 0)
	{
		ReplyToCommand(client, "%s %T", g_ChatPrefix, "NameTagDisabled", client);
		return Plugin_Handled;
	}
	if(GetTime() - g_iNameTagTime[client] < 2)
	{
		ReplyToCommand(client, "%s %T", g_ChatPrefix, "DontSpamNameTag", client);
		return Plugin_Handled;
	}
	if(args < 1)
	{
		ReplyToCommand(client, "%s %T", g_ChatPrefix, "NameTagNeedsParams", client);
		return Plugin_Handled;
	}
	char nameTag[128];
	GetCmdArgString(nameTag, sizeof(nameTag));
	
	if (IsValidClient(client))
	{
		int entity = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (entity != -1)
		{
			int index = GetWeaponIndex(entity);
			
			if (index > -1)
			{
				CleanNameTag(nameTag, sizeof(nameTag));
				
				g_NameTag[client][index] = nameTag;
				
				RefreshWeapon(client, index);
				
				char updateFields[300];
				char escaped[257];
				db.Escape(nameTag, escaped, sizeof(escaped));
				char weaponName[32];
				char weaponClass[32];
				GetWeaponClass(entity, weaponClass, sizeof(weaponClass));
				RemoveWeaponPrefix(weaponClass, weaponName, sizeof(weaponName));
				Format(updateFields, sizeof(updateFields), "%s_tag = '%s'", weaponName, escaped);
				UpdatePlayerData(client, updateFields);
				
				g_iNameTagTime[client] = GetTime();
			}
		}
	}
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	if(IsFakeClient(client))
	{
		if(g_iEnableStatTrak == 1)
			SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	else if(IsValidClient(client))
	{
		HookPlayer(client);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(IsValidClient(client))
	{
		char steam32[20];
		char temp[20];
		GetClientAuthId(client, AuthId_Steam3, steam32, sizeof(steam32));
		strcopy(temp, sizeof(temp), steam32[5]);
		int index;
		if((index = StrContains(temp, "]")) > -1)
		{
			temp[index] = '\0';
		}
		g_iSteam32[client] = StringToInt(temp);
		GetPlayerData(client);
		QueryClientConVar(client, "cl_language", ConVarCallBack);
	}
}

public void ConVarCallBack(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(!g_smLanguageIndex.GetValue(cvarValue, g_iClientLanguage[client]))
	{
		g_iClientLanguage[client] = 0;
	}
}

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client))
	{
		if(g_iEnableStatTrak == 1)
			SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	else if(IsValidClient(client))
	{
		UnhookPlayer(client);
		g_iSteam32[client] = 0;
	}
}

public void SetWeaponProps(int client, int entity)
{
	int index = GetWeaponIndex(entity);
	if (index > -1 && g_iSkins[client][index] != 0)
	{
		SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
		SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", g_iSkins[client][index] == -1 ? GetRandomSkin(client, index) : g_iSkins[client][index]);
		SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", g_iEnableFloat == 0 || g_fFloatValue[client][index] == 0.0 ? 0.000001 : g_fFloatValue[client][index] == 1.0 ? 0.999999 : g_fFloatValue[client][index]);
		SetEntProp(entity, Prop_Send, "m_nFallbackSeed", GetRandomInt(0, 8192));
		if(!IsKnife(entity))
		{
			if(g_iEnableStatTrak == 1)
			{
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 1 ? g_iStatTrakCount[client][index] : -1);
				SetEntProp(entity, Prop_Send, "m_iEntityQuality", g_iStatTrak[client][index] == 1 ? 9 : 0);
			}
		}
		else
		{
			if(g_iEnableStatTrak == 1)
				SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", g_iStatTrak[client][index] == 0 ? -1 : g_iKnifeStatTrakMode == 0 ? GetTotalKnifeStatTrakCount(client) : g_iStatTrakCount[client][index]);
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 3);
		}
		if (g_iEnableNameTag == 1 && strlen(g_NameTag[client][index]) > 0)
			SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), g_NameTag[client][index], 128);
		SetEntProp(entity, Prop_Send, "m_iAccountID", g_iSteam32[client]);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);
	}
}

void RefreshWeapon(int client, int index, bool defaultKnife = false)
{
	int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
	
	for (int i = 0; i < size; i++)
	{
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
		if (IsValidWeapon(weapon))
		{
			bool isKnife = IsKnife(weapon);
			if ((!defaultKnife && GetWeaponIndex(weapon) == index) || (isKnife && (defaultKnife || IsKnifeClass(g_WeaponClasses[index]))))
			{
				int clip = -1;
				int ammo = -1;
				int offset = -1;
				int reserve = -1;
					
				if (!isKnife)
				{
					offset = FindDataMapInfo(client, "m_iAmmo") + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);
					ammo = GetEntData(client, offset);
					clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
					reserve = GetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount");
				}
				
				RemovePlayerItem(client, weapon);
				AcceptEntityInput(weapon, "KillHierarchy");
				
				if (!isKnife)
				{
					weapon = GivePlayerItem(client, g_WeaponClasses[index]);
					if (clip != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
					}
					if (reserve != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
					}
					if (offset != -1 && ammo != -1)
					{
						DataPack pack;
						CreateDataTimer(0.1, ReserveAmmoTimer, pack);
						pack.WriteCell(client);
						pack.WriteCell(offset);
						pack.WriteCell(ammo);
					}
				}
				else
				{
					GivePlayerItem(client, "weapon_knife");
				}
				break;
			}
		}
	}
}

public Action ReserveAmmoTimer(Handle timer, DataPack pack)
{
	ResetPack(pack);
	int clientIndex = pack.ReadCell();
	int offset = pack.ReadCell();
	int ammo = pack.ReadCell();
	
	if(IsClientInGame(clientIndex))
	{
		SetEntData(clientIndex, offset, ammo, 4, true);
	}
}

/*
public void ReportEconData(int client, const CEconItemView item)
{
	PrintToConsole(client, "GetDefinitionIndex: %d", item.GetItemDefinition().GetDefinitionIndex());
	PrintToConsole(client, "GetCustomPaintKitIndex: %d", item.GetCustomPaintKitIndex());
	PrintToConsole(client, "GetCustomPaintKitWear: %f", item.GetCustomPaintKitWear());
	PrintToConsole(client, "GetCustomPaintKitSeed: %d", item.GetCustomPaintKitSeed());
	PrintToConsole(client, "GetStatTrakKill: %d", item.GetStatTrakKill());
	PrintToConsole(client, "GetQuality: %d", item.GetQuality());
	PrintToConsole(client, "GetAccountID: %d", item.GetAccountID());
	PrintToConsole(client, "GetOrigin: %d", item.GetOrigin());
	PrintToConsole(client, "GetFlags: %d", item.GetFlags());
	PrintToConsole(client, "GetRarity: %d", item.GetRarity());
	char tag[128];
	item.GetCustomName(tag, sizeof(tag));
	PrintToConsole(client, "GetCustomName: %s", tag);
	PrintToConsole(client, "IsCustomItemView: %d", item.IsCustomItemView());
}

public void ReportWeaponData(int client, int entity)
{
	PrintToConsole(client, "m_iItemIDLow: %d", GetEntProp(entity, Prop_Send, "m_iItemIDLow"));
	PrintToConsole(client, "m_nFallbackPaintKit: %d", GetEntProp(entity, Prop_Send, "m_nFallbackPaintKit"));
	PrintToConsole(client, "m_flFallbackWear: %f", GetEntPropFloat(entity, Prop_Send, "m_flFallbackWear"));
	PrintToConsole(client, "m_nFallbackSeed: %d", GetEntProp(entity, Prop_Send, "m_nFallbackSeed"));
	PrintToConsole(client, "m_nFallbackStatTrak: %d", GetEntProp(entity, Prop_Send, "m_nFallbackStatTrak"));
	PrintToConsole(client, "m_iEntityQuality: %d", GetEntProp(entity, Prop_Send, "m_iEntityQuality"));
	PrintToConsole(client, "m_iAccountID: %d", GetEntProp(entity, Prop_Send, "m_iAccountID"));
	PrintToConsole(client, "m_OriginalOwnerXuidLow: %d", GetEntProp(entity, Prop_Send, "m_OriginalOwnerXuidLow"));
	PrintToConsole(client, "m_nModelIndex: %d", GetEntProp(entity, Prop_Send, "m_nModelIndex"));
	PrintToConsole(client, "m_nViewModelIndex: %d", GetEntProp(entity, Prop_Send, "m_nViewModelIndex"));
	PrintToConsole(client, "m_hOwnerEntity: %d", GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity"));
	PrintToConsole(client, "m_hPrevOwner: %d", GetEntPropEnt(entity, Prop_Send, "m_hPrevOwner"));
	PrintToConsole(client, "m_iPrimaryReserveAmmoCount: %d", GetEntProp(entity, Prop_Send, "m_iPrimaryReserveAmmoCount"));
	PrintToConsole(client, "m_iClip1: %d", GetEntProp(entity, Prop_Send, "m_iClip1"));
}

public Action CommandReportData(int client, int args)
{
	int activeWeaponClient = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	ReportWeaponData(client, activeWeaponClient);
	ReportEconData(client, PTaH_GetEconItemViewFromWeapon(activeWeaponClient));
}
*/
