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

public void ReadConfig()
{
	delete g_smWeaponIndex;
	g_smWeaponIndex = new StringMap();
	delete g_smWeaponDefIndex;
	g_smWeaponDefIndex = new StringMap();
	delete g_smLanguageIndex;
	g_smLanguageIndex = new StringMap();

	for (int i = 0; i < sizeof(g_WeaponClasses); i++)
	{
		g_smWeaponIndex.SetValue(g_WeaponClasses[i], i);
		g_smWeaponDefIndex.SetValue(g_WeaponClasses[i], g_iWeaponDefIndex[i]);
	}

	int langCount = GetLanguageCount();
	int langCounter = 0;
	for (int i = 0; i < langCount; i++)
	{
		char code[4];
		char language[32];
		GetLanguageInfo(i, code, sizeof(code), language, sizeof(language));

		BuildPath(Path_SM, configPath, sizeof(configPath), "configs/weapons/weapons_%s.cfg", language);

		if(!FileExists(configPath)) continue;

		g_smLanguageIndex.SetValue(language, langCounter);
		FirstCharUpper(language);
		strcopy(g_Language[langCounter], 32, language);

		KeyValues kv = CreateKeyValues("Skins");
		FileToKeyValues(kv, configPath);

		if (!KvGotoFirstSubKey(kv))
		{
			SetFailState("CFG File not found: %s", configPath);
			CloseHandle(kv);
		}

		delete g_smSkinMenuMap[langCounter];
		g_smSkinMenuMap[langCounter] = new StringMap();

		for (int k = 0; k < sizeof(g_WeaponClasses); k++)
		{
			if(menuWeapons[langCounter][k] != null)
			{
				delete menuWeapons[langCounter][k];
			}
			menuWeapons[langCounter][k] = new Menu(WeaponsMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_DisplayItem);
			menuWeapons[langCounter][k].SetTitle("%T", g_WeaponClasses[k], LANG_SERVER);
			menuWeapons[langCounter][k].AddItem("0", "Default");
			menuWeapons[langCounter][k].AddItem("-1", "Random");
			menuWeapons[langCounter][k].ExitBackButton = true;
		}

		int counter = 0;
		char weaponTemp[20];

		do {
			char name[64];
			char index[5];
			char classes[1024];

			KvGetSectionName(kv, name, sizeof(name));
			KvGetString(kv, "classes", classes, sizeof(classes));
			KvGetString(kv, "index", index, sizeof(index));

			Menu menuSkins[MAX_SKIN];

			for (int k = 0; k < sizeof(g_WeaponClasses); k++)
			{
				Format(weaponTemp, sizeof(weaponTemp), "%s;", g_WeaponClasses[k]);
				if(StrContains(classes, weaponTemp) > -1)
				{
					menuWeapons[langCounter][k].AddItem(index, name);

					if (g_bEnableSearch)
					{
						if (menuSkins[counter] == null)
						{
							menuSkins[counter] = new Menu(SkinsMenuHandler, MENU_ACTIONS_DEFAULT | MenuAction_DisplayItem);
							menuSkins[counter].SetTitle(name);
							menuSkins[counter].AddItem("-1", "Apply all");
							menuSkins[counter].AddItem("-2", "Apply current");
							menuSkins[counter].ExitBackButton = true;
						}

						char weaponName[32];
						Format(weaponName, sizeof(weaponName), "%T (%s)", g_WeaponClasses[k], LANG_SERVER, index);
						char weaponIndexStr[32];
						Format(weaponIndexStr, sizeof(weaponIndexStr), "%d", k);
						menuSkins[counter].AddItem(weaponIndexStr, weaponName);
					}

				}
			}

			if (g_bEnableSearch)
			{
				for (int j = 0; j < MAX_SKIN; j++)
				{
					Menu currentMenu = menuSkins[j];
					if (currentMenu == null)continue;

					char currentMenuName[32];
					currentMenu.GetTitle(currentMenuName, sizeof(currentMenuName));
					if (g_smSkinMenuMap[langCounter].ContainsKey(name))
					{
						Menu fatherMenu;
						g_smSkinMenuMap[langCounter].GetValue(name, fatherMenu);
						for (int l = 2; l < currentMenu.ItemCount; l++)
						{
							char info[32];
							char display[64];
							int a;
							currentMenu.GetItem(l, info, sizeof(info), a, display, sizeof(display));
							fatherMenu.AddItem(info, display);
						}

						delete currentMenu;
					}
					else
					{
						g_smSkinMenuMap[langCounter].SetValue(name, currentMenu);
					}
				}
			}

			counter++;
		} while (KvGotoNextKey(kv));

		CloseHandle(kv);

		langCounter++;
	}

	if(langCounter == 0)
	{
		SetFailState("Could not find a config file for any languages.");
	}
}
