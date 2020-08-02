public int Weapons_GetClientKnife(Handle plugin, int numparams)
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

void GetClientKnife(int client, char[] KnifeName, int Size)
{
	if(g_iKnife[client] == 0)
	{
		Format(KnifeName, Size, "weapon_knife");
	}
	else
	{
		Format(KnifeName, Size, g_WeaponClasses[g_iKnife[client]]);
	}
}

public int Weapons_SetClientKnife(Handle plugin, int numparams)
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
	SetClientKnife(client, KnifeName, true);
	return 0;
}

int SetClientKnife(int client, char[] sKnife, bool Native = false)
{
	int knife;
	if(strcmp(sKnife, "weapon_knife") == 0)
	{
		knife = 0;
	}
	else
	{
		int count = -1;
		for(int i = 33; i < sizeof(g_WeaponClasses); i++)
		{
			if(strcmp(sKnife, g_WeaponClasses[i]) == 0)
			{
				count = i;
				break;
			}
		}
		if(count == -1)
		{
			if(Native)
			{
				return ThrowNativeError(25, "Knife (%s) is not valid.", sKnife);
			}
			else
			{
				return -1;
			}
		}
		knife = count;
	}
	g_iKnife[client] = knife;
	char updateFields[16];
	Format(updateFields, sizeof(updateFields), "knife = %d", knife);
	UpdatePlayerData(client, updateFields);
	RefreshWeapon(client, knife, knife == 0);
	return 0;
}