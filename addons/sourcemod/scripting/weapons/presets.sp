void SavePresset(int client, char[] name)
{
	char buffer[64];
	
	g_hPresets.Rewind();
	g_hPresets.JumpToKey(name, true);

	for(int i = 0; i < sizeof(g_WeaponClasses); i++) 
	{
		Format(buffer, sizeof(buffer), "%i", g_iSkins[client][i]);

		g_hPresets.SetString(g_WeaponClasses[i], buffer);
	}
	
	g_hPresets.Rewind();
	g_hPresets.ExportToFile(g_sPressetsFile);

	PrintToChat(client, " %s \x04%t", g_ChatPrefix, "PressetSaved", client);
}

void ShowPressets(int client, bool deleteMode = false)
{
	char buffer[128];
	Menu menu;

	switch(deleteMode)
	{
		case true: menu = new Menu(SeeDeletePressetsHandler);
		case false: menu = new Menu(SeePressetsHandler);
	}

	Format(buffer, sizeof(buffer), "%T", "LoadPressetsTitle", client);
	menu.SetTitle(buffer);

	menu.ExitBackButton = true;
	
	g_hPresets.Rewind();
	if(g_hPresets.GotoFirstSubKey())
	{
		do
		{
			g_hPresets.GetSectionName(buffer, sizeof(buffer));

			menu.AddItem(buffer, buffer);
		}
		while(g_hPresets.GotoNextKey());
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T", "NoPressetsAvalabile", client);
		menu.AddItem("", buffer, ITEMDRAW_DISABLED);
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

void ShowPressetInfo(int client, char[] name)
{
	char buffer[128], key[10];
	
	g_hPresets.Rewind();
	if(g_hPresets.JumpToKey(name))
	{
		Menu menu = new Menu(SeePressetSkinsHandler);

		Format(buffer, sizeof(buffer), "%T", "LoadPressetsTitle", client);
		menu.SetTitle(buffer);
		
		Format(buffer, sizeof(buffer), "%T\n ", "LoadThisPresset", client);
		menu.AddItem(name, buffer);

		for(int i = 0; i < sizeof(g_WeaponClasses); i++) 
		{
			strcopy(buffer, sizeof(buffer), "");
			
			Format(key, sizeof(key), "%i", g_hPresets.GetNum(g_WeaponClasses[i]));
			
			if(g_smSkinsNames.GetString(key, buffer, sizeof(buffer)))
			{
				Format(buffer, sizeof(buffer), "%T | %s", g_WeaponClasses[i], client, buffer);		
				menu.AddItem(name, buffer, ITEMDRAW_DISABLED);
			}
		}
		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

void LoadPresset(int client, char[] name)
{
	char updateFields[1024 * 2], buffer[32], weaponName[32];

	g_hPresets.Rewind();
	if(g_hPresets.JumpToKey(name))
	{
		for(int i = 0; i < sizeof(g_WeaponClasses); i++)
		{
			g_hPresets.GetString(g_WeaponClasses[i], buffer, sizeof(buffer));
			g_iSkins[client][i] = StringToInt(buffer);

			RemoveWeaponPrefix(g_WeaponClasses[i], weaponName, sizeof(weaponName));

			if(!updateFields[0])
			{
				Format(updateFields, sizeof(updateFields), "%s = %d", weaponName, g_iSkins[client][i]);
			}
			else
			{
				Format(updateFields, sizeof(updateFields), "%s, %s = %d", updateFields, weaponName, g_iSkins[client][i]);
			}
		}
	}

	UpdatePlayerData(client, updateFields);
	
	PrintToChat(client, " %s \x04%T", g_ChatPrefix, "PressetLoaded", client, name);
}

void DeletePresset(int client, char[] name)
{
	g_hPresets.Rewind();
	if(g_hPresets.JumpToKey(name))
	{
		g_hPresets.DeleteThis();
	}
	
	g_hPresets.Rewind();
	g_hPresets.ExportToFile(g_sPressetsFile);

	PrintToChat(client, " %s \x04%T", g_ChatPrefix, "PressetDeleted", client, name);
}

/**
"Skins"
{
	"Test"
	{
		"123"		"123"
	}
}

 */