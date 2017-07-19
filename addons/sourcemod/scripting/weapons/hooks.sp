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

public void HookPlayer(int client)
{
	if(g_iEnableStatTrak == 1)
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

public void UnhookPlayer(int client)
{
	if(g_iEnableStatTrak == 1)
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

public Action GiveNamedItemPre(int client, char classname[64], CEconItemView &item)
{
	if (IsValidClient(client))
	{
		if (g_iKnife[client] != 0 && IsKnifeClass(classname) && !StrEqual(classname, g_WeaponClasses[g_iKnife[client]]))
		{
			Format(classname, sizeof(classname), g_WeaponClasses[g_iKnife[client]]);
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public void GiveNamedItem(int client, const char[] classname, const CEconItemView item, int entity)
{
	if (entity > -1 && IsValidClient(client))
	{
		int index;
		if (g_smWeaponIndex.GetValue(classname, index))
		{
			if (IsKnifeClass(classname))
			{
				int defIndex;
				g_smWeaponDefIndex.GetValue(g_WeaponClasses[g_iKnife[client]], defIndex);
				char knifeClassName[32];
				GetWeaponClass(entity, knifeClassName, sizeof(knifeClassName));
				int playerTeam = GetClientTeam(client);
				if(!StrEqual(knifeClassName, g_WeaponClasses[g_iKnife[client]]) || (CS_TEAM_T <= playerTeam <= CS_TEAM_CT && defIndex == g_iPlayerKnifeDefIndex[playerTeam - 2][client]))
				{
					float origin[3], angles[3];
					GetClientAbsOrigin(client, origin);
					GetClientAbsAngles(client, angles);
					RemovePlayerItem(client, entity);
					AcceptEntityInput(entity, "KillHierarchy");
					entity = PTaH_SpawnItemFromDefIndex(defIndex, origin, angles);
				}
				EquipPlayerWeapon(client, entity);
			}
			SetWeaponProps(client, entity);
		}
	}
}

public Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (float(GetClientHealth(victim)) - damage > 0.0)
		return Plugin_Continue;
		
	if (!(damagetype & DMG_SLASH) && !(damagetype & DMG_BULLET))
		return Plugin_Continue;
		
	if (!IsValidClient(attacker))
		return Plugin_Continue;
		
	if (!IsValidWeapon(weapon))
		return Plugin_Continue;
		
	int index = GetWeaponIndex(weapon);
	
	if (index != -1 && g_iSkins[attacker][index] != 0 && g_iStatTrak[attacker][index] != 1)
		return Plugin_Continue;
		
	if (GetEntProp(weapon, Prop_Send, "m_nFallbackStatTrak") == -1)
		return Plugin_Continue;
		
	int previousOwner;
	if ((previousOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && previousOwner != attacker)
		return Plugin_Continue;
	
	g_iStatTrakCount[attacker][index]++;
	if (IsKnife(weapon))
	{
		SetEntProp(weapon, Prop_Send, "m_nFallbackStatTrak", g_iKnifeStatTrakMode == 0 ? GetTotalKnifeStatTrakCount(attacker) : g_iStatTrakCount[attacker][index]);
	}
	else
	{
		SetEntProp(weapon, Prop_Send, "m_nFallbackStatTrak", g_iStatTrakCount[attacker][index]);
	}

	char updateFields[50];
	char weaponName[32];
	RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
	Format(updateFields, sizeof(updateFields), "%s_trak_count = %d", weaponName, g_iStatTrakCount[attacker][index]);
	UpdatePlayerData(attacker, updateFields);
	return Plugin_Continue;
}
