public int Weapons_GetClientKnife_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	char KnifeName[64];
	GetClientKnife(client, KnifeName, sizeof(KnifeName));
	SetNativeString(2, KnifeName, GetNativeCell(3));
	return 0;
}

public int Weapons_SetClientKnife_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	char KnifeName[64];
	GetNativeString(2, KnifeName, 64);
	bool update = !!GetNativeCell(3);
	SetClientKnife(client, KnifeName, true, update);
	return 0;
}

public int Weapons_SetClientSkin_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	
	char weaponName[32], updateFields[64];
	GetNativeString(2, weaponName, sizeof(weaponName));
	
	int index = GetIndex(weaponName);
	int skinid = GetNativeCell(3);
	
	RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
	Format(updateFields, sizeof(updateFields), "%s = %d", weaponName, skinid);
	UpdatePlayerData(client, updateFields);
	
	g_iSkins[client][index] = skinid;
	RefreshWeapon(client, index);
	
	return 0;
}

public int Weapons_SetClientWear_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	
	char weaponName[32], updateFields[64];
	GetNativeString(2, weaponName, sizeof(weaponName));
	int index = GetIndex(weaponName);
	
	g_fFloatValue[client][index] = GetNativeCell(3);
	
	RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
	Format(updateFields, sizeof(updateFields), "%s_float = %.2f", weaponName, g_fFloatValue[client][index]);
	UpdatePlayerData(client, updateFields);
		
	RefreshWeapon(client, index);
		
	return 0;
}

public int Weapons_SetClientSeed_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	
	char weaponName[32], updateFields[64];
	GetNativeString(2, weaponName, sizeof(weaponName));
	int index = GetIndex(weaponName);
	
	g_iWeaponSeed[client][index] = GetNativeCell(3);
	
	RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
	Format(updateFields, sizeof(updateFields), "%s_seed = %.2f", weaponName, g_fFloatValue[client][index]);
	UpdatePlayerData(client, updateFields);
		
	RefreshWeapon(client, index);
	
	return 0;
}

public int Weapons_SetClientNameTag_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	
	char weaponName[32], updateFields[64], name[64];
	GetNativeString(2, weaponName, sizeof(weaponName));
	GetNativeString(3, name, sizeof(name));
	int index = GetIndex(weaponName);
	
	g_NameTag[client][index] = name;
	
	char escaped[257];
	db.Escape(name, escaped, sizeof(escaped));
	RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
	Format(updateFields, sizeof(updateFields), "%s_tag = '%s'", weaponName, escaped);
	UpdatePlayerData(client, updateFields);

	RefreshWeapon(client, index);
	
	return 0;
}

public int Weapons_ToggleClientStarTrack_Native(Handle plugin, int numparams)
{
	int client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d).", client);
	}
	if(!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client (%d) is not in game.", client);
	}
	
	char weaponName[32], updateFields[64];
	GetNativeString(2, weaponName, sizeof(weaponName));
	int index = GetIndex(weaponName);
	
	g_iStatTrak[client][index] = 1 - g_iStatTrak[client][index];
	
	RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
	Format(updateFields, sizeof(updateFields), "%s_trak = %d", weaponName, g_iStatTrak[client][index]);
	UpdatePlayerData(client, updateFields);
	
	RefreshWeapon(client, index);
	
	return 0;
}