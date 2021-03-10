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

public int WeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        int index = g_iIndex[client];

        char skinIdStr[32];
        menu.GetItem(selection, skinIdStr, sizeof(skinIdStr));
        int skinId = StringToInt(skinIdStr);

        char updateFields[256];
        char weaponName[32];
        RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));
        char currentWeaponName[32];
        strcopy(currentWeaponName, sizeof(currentWeaponName), weaponName);

        int team = IsWeaponIndexInOnlyOneTeam(index) ? CS_TEAM_T : GetClientTeam(client);
        char teamName[4];
        teamName = team == CS_TEAM_T ? "" : "ct_";
        g_iSkins[client][index][team] = skinId;

        Format(updateFields, sizeof(updateFields), "%s%s = %d", teamName, currentWeaponName, skinId);
        UpdatePlayerData(client, updateFields);

        RefreshWeapon(client, index);

        DataPack pack;
        CreateDataTimer(0.5, WeaponsMenuTimer, pack);
        pack.WriteCell(menu);
        pack.WriteCell(GetClientUserId(client));
        pack.WriteCell(GetMenuSelectionPosition());
      }
    }
    case MenuAction_DisplayItem: {
      if (IsClientInGame(client)) {
        char info[32];
        char display[64];
        menu.GetItem(selection, info, sizeof(info));

        if (StrEqual(info, "0")) {
          Format(display, sizeof(display), "%T", "DefaultSkin", client);
          return RedrawMenuItem(display);
        } else if (StrEqual(info, "-1")) {
          Format(display, sizeof(display), "%T", "RandomSkin", client);
          return RedrawMenuItem(display);
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateWeaponMenu(client).Display(client, menuTime);
        }
      }
    }
  }
  return 0;
}

public Action WeaponsMenuTimer(Handle timer, DataPack pack) {
  ResetPack(pack);
  Menu menu = pack.ReadCell();
  int clientIndex = GetClientOfUserId(pack.ReadCell());
  int menuSelectionPosition = pack.ReadCell();

  if (IsValidClient(clientIndex)) {
    int menuTime;
    if ((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0) {
      menu.DisplayAt(clientIndex, menuSelectionPosition, menuTime);
    }
  }
}

public int WeaponMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);

        char buffer[30];
        menu.GetItem(selection, buffer, sizeof(buffer));
        if (StrEqual(buffer, "skin")) {
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            menuWeapons[g_iClientLanguage[client]][g_iIndex[client]].Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "float")) {
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateFloatMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "stattrak")) {
          char updateFields[256];
          char weaponName[32];
          RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));

          g_iStatTrak[client][g_iIndex[client]][team] = 1 - g_iStatTrak[client][g_iIndex[client]][team];

          char teamName[4];
          teamName = team == CS_TEAM_T ? "" : "ct_";
          Format(updateFields, sizeof(updateFields), "%s%s_trak = %d", teamName, weaponName,
                 g_iStatTrak[client][g_iIndex[client]][team]);
          UpdatePlayerData(client, updateFields);

          RefreshWeapon(client, g_iIndex[client]);

          CreateTimer(1.0, StatTrakMenuTimer, GetClientUserId(client));
        } else if (StrEqual(buffer, "nametag")) {
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateNameTagMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "seed")) {
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateSeedMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "paints")) {
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateAllWeaponsPaintsMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "applyother")) {
          if (IsWeaponIndexInOnlyOneTeam(g_iIndex[client])) {
            return;
          }

          char weaponName[32];
          RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));

          int otherTeam = team == CS_TEAM_CT ? CS_TEAM_T : CS_TEAM_CT;

          g_iSkins[client][g_iIndex[client]][otherTeam] = g_iSkins[client][g_iIndex[client]][team];
          g_fFloatValue[client][g_iIndex[client]][otherTeam] = g_fFloatValue[client][g_iIndex[client]][team];
          g_iWeaponSeed[client][g_iIndex[client]][otherTeam] = g_iWeaponSeed[client][g_iIndex[client]][team];
          g_iStatTrak[client][g_iIndex[client]][otherTeam] = g_iStatTrak[client][g_iIndex[client]][team];
          g_iStatTrakCount[client][g_iIndex[client]][otherTeam] = g_iStatTrakCount[client][g_iIndex[client]][team];
          strcopy(g_NameTag[client][g_iIndex[client]][otherTeam], 128, g_NameTag[client][g_iIndex[client]][team]);

          char otherTeamName[4];
          otherTeamName = team == CS_TEAM_T ? "ct_" : "";
          char updateFields[512];
          Format(updateFields, sizeof(updateFields), "%s%s = %d,			\
																%s%s_float = %.2f,		\
																%s%s_trak = %d,		\
																%s%s_trak_count = %d,	\
																%s%s_tag = '%s',		\
																%s%s_seed = %d",
                 otherTeamName, weaponName, g_iSkins[client][g_iIndex[client]][otherTeam], otherTeamName, weaponName,
                 g_fFloatValue[client][g_iIndex[client]][otherTeam], otherTeamName, weaponName,
                 g_iStatTrak[client][g_iIndex[client]][otherTeam], otherTeamName, weaponName,
                 g_iStatTrakCount[client][g_iIndex[client]][otherTeam], otherTeamName, weaponName,
                 g_NameTag[client][g_iIndex[client]][otherTeam], otherTeamName, weaponName,
                 g_iWeaponSeed[client][g_iIndex[client]][otherTeam]);
          UpdatePlayerData(client, updateFields);

          RefreshWeapon(client, g_iIndex[client]);

          CreateTimer(1.0, StatTrakMenuTimer, GetClientUserId(client));
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateMainMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

public Action StatTrakMenuTimer(Handle timer, int userid) {
  int clientIndex = GetClientOfUserId(userid);
  if (IsValidClient(clientIndex)) {
    int menuTime;
    if ((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0) {
      CreateWeaponMenu(clientIndex).Display(clientIndex, menuTime);
    }
  }
}

Menu CreateFloatMenu(int client) {
  char buffer[60];
  Menu menu = new Menu(FloatMenuHandler);

  int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);

  float fValue = g_fFloatValue[client][g_iIndex[client]][team];
  fValue = fValue * 100.0;
  int wear = 100 - RoundFloat(fValue);

  menu.SetTitle("%T%d%%(%f)", "SetFloat", client, wear, g_fFloatValue[client][g_iIndex[client]][team]);

  Format(buffer, sizeof(buffer), "%T", "Increase", client, g_iFloatIncrementPercentage);
  menu.AddItem("increase", buffer, wear == 100 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

  Format(buffer, sizeof(buffer), "%T", "Decrease", client, g_iFloatIncrementPercentage);
  menu.AddItem("decrease", buffer, wear == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

  Format(buffer, sizeof(buffer), "%T", "FloatSet", client);
  menu.AddItem("set", buffer, wear == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

  menu.ExitBackButton = true;

  return menu;
}

public int FloatMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);

        char buffer[30];
        menu.GetItem(selection, buffer, sizeof(buffer));
        if (StrEqual(buffer, "increase")) {
          g_fFloatValue[client][g_iIndex[client]][team] =
              g_fFloatValue[client][g_iIndex[client]][team] - g_fFloatIncrementSize;
          if (g_fFloatValue[client][g_iIndex[client]][team] < 0.0) {
            g_fFloatValue[client][g_iIndex[client]][team] = 0.0;
          }
          if (g_FloatTimer[client] != INVALID_HANDLE) {
            KillTimer(g_FloatTimer[client]);
            g_FloatTimer[client] = INVALID_HANDLE;
          }
          DataPack pack;
          g_FloatTimer[client] = CreateDataTimer(1.0, FloatTimer, pack);
          pack.WriteCell(GetClientUserId(client));
          pack.WriteCell(g_iIndex[client]);
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateFloatMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "decrease")) {
          g_fFloatValue[client][g_iIndex[client]][team] =
              g_fFloatValue[client][g_iIndex[client]][team] + g_fFloatIncrementSize;
          if (g_fFloatValue[client][g_iIndex[client]][team] > 1.0) {
            g_fFloatValue[client][g_iIndex[client]][team] = 1.0;
          }
          if (g_FloatTimer[client] != INVALID_HANDLE) {
            KillTimer(g_FloatTimer[client]);
            g_FloatTimer[client] = INVALID_HANDLE;
          }
          DataPack pack;
          g_FloatTimer[client] = CreateDataTimer(1.0, FloatTimer, pack);
          pack.WriteCell(GetClientUserId(client));
          pack.WriteCell(g_iIndex[client]);
          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateFloatMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(buffer, "set")) {
          g_bWaitingForWear[client] = true;
          PrintToChat(client, " %s \x04%t", g_ChatPrefix, "FloatSetInstruction");
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateWeaponMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

public Action FloatTimer(Handle timer, DataPack pack) {
  ResetPack(pack);
  int clientIndex = GetClientOfUserId(pack.ReadCell());
  int index = pack.ReadCell();

  if (IsValidClient(clientIndex)) {
    char updateFields[256];
    char weaponName[32];
    RemoveWeaponPrefix(g_WeaponClasses[index], weaponName, sizeof(weaponName));

    int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[clientIndex]) ? CS_TEAM_T : GetClientTeam(clientIndex);
    char teamName[4];
    teamName = team == CS_TEAM_T ? "" : "ct_";
    Format(updateFields, sizeof(updateFields), "%s%s_float = %.2f", teamName, weaponName,
           g_fFloatValue[clientIndex][g_iIndex[clientIndex]][team]);
    UpdatePlayerData(clientIndex, updateFields);

    RefreshWeapon(clientIndex, index);
  }

  g_FloatTimer[clientIndex] = INVALID_HANDLE;
}

Menu CreateSeedMenu(int client) {
  int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);

  Menu menu = new Menu(SeedMenuHandler);

  char buffer[128];
  if (g_iWeaponSeed[client][g_iIndex[client]][team] != -1) {
    Format(buffer, sizeof(buffer), "%T", "SeedTitle", client, g_iWeaponSeed[client][g_iIndex[client]][team]);
  } else if (g_iSeedRandom[client][g_iIndex[client]] > 0) {
    Format(buffer, sizeof(buffer), "%T", "SeedTitle", client, g_iSeedRandom[client][g_iIndex[client]]);
  } else {
    Format(buffer, sizeof(buffer), "%T", "SeedTitleNoSeed", client);
  }
  menu.SetTitle(buffer);

  Format(buffer, sizeof(buffer), "%T", "SeedRandom", client);
  menu.AddItem("rseed", buffer);

  Format(buffer, sizeof(buffer), "%T", "SeedManual", client);
  menu.AddItem("cseed", buffer);

  Format(buffer, sizeof(buffer), "%T", "SeedSave", client);
  menu.AddItem("sseed", buffer, g_iSeedRandom[client][g_iIndex[client]] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

  Format(buffer, sizeof(buffer), "%T", "ResetSeed", client);
  menu.AddItem("seedr", buffer,
               g_iWeaponSeed[client][g_iIndex[client]][team] == -1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

  menu.ExitBackButton = true;

  return menu;
}

public int SeedMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);

        char buffer[30];
        menu.GetItem(selection, buffer, sizeof(buffer));
        if (StrEqual(buffer, "rseed")) {
          g_iWeaponSeed[client][g_iIndex[client]][team] = -1;
          RefreshWeapon(client, g_iIndex[client]);
          CreateTimer(0.1, SeedMenuTimer, GetClientUserId(client));
        } else if (StrEqual(buffer, "cseed")) {
          g_bWaitingForSeed[client] = true;
          PrintToChat(client, " %s \x04%t", g_ChatPrefix, "SeedInstruction");
        } else if (StrEqual(buffer, "sseed")) {
          if (g_iSeedRandom[client][g_iIndex[client]] > 0) {
            g_iWeaponSeed[client][g_iIndex[client]][team] = g_iSeedRandom[client][g_iIndex[client]];
          }
          g_iSeedRandom[client][g_iIndex[client]] = 0;
          RefreshWeapon(client, g_iIndex[client]);

          char updateFields[256];
          char weaponName[32];
          RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));

          char teamName[4];
          teamName = team == CS_TEAM_T ? "" : "ct_";
          Format(updateFields, sizeof(updateFields), "%s%s_seed = %d", teamName, weaponName,
                 g_iWeaponSeed[client][g_iIndex[client]][team]);
          UpdatePlayerData(client, updateFields);
          CreateTimer(0.1, SeedMenuTimer, GetClientUserId(client));

          PrintToChat(client, " %s \x04%t", g_ChatPrefix, "SeedSaved");
        } else if (StrEqual(buffer, "seedr")) {
          g_iWeaponSeed[client][g_iIndex[client]][team] = -1;
          g_iSeedRandom[client][g_iIndex[client]] = 0;

          char updateFields[256];
          char weaponName[32];
          RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));

          char teamName[4];
          teamName = team == CS_TEAM_T ? "" : "ct_";
          Format(updateFields, sizeof(updateFields), "%s%s_seed = -1", teamName, weaponName);
          UpdatePlayerData(client, updateFields);
          CreateTimer(0.1, SeedMenuTimer, GetClientUserId(client));

          PrintToChat(client, " %s \x04%t", g_ChatPrefix, "SeedReset");
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateWeaponMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

public Action SeedMenuTimer(Handle timer, int userid) {
  int clientIndex = GetClientOfUserId(userid);
  if (IsValidClient(clientIndex)) {
    int menuTime;
    if ((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0) {
      CreateSeedMenu(clientIndex).Display(clientIndex, menuTime);
    }
  }
}

Menu CreateNameTagMenu(int client) {
  Menu menu = new Menu(NameTagMenuHandler);

  char buffer[128];
  int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);
  StripHtml(g_NameTag[client][g_iIndex[client]][team], buffer, sizeof(buffer));
  menu.SetTitle("%T: %s", "SetNameTag", client, buffer);

  Format(buffer, sizeof(buffer), "%T", "ChangeNameTag", client);
  menu.AddItem("nametag", buffer);

  /* NAMETAGCOLOR
  Format(buffer, sizeof(buffer), "%T", "NameTagColor", client);
  menu.AddItem("color", buffer, strlen(g_NameTag[client][g_iIndex[client]]) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  */

  Format(buffer, sizeof(buffer), "%T", "DeleteNameTag", client);
  menu.AddItem("delete", buffer,
               strlen(g_NameTag[client][g_iIndex[client]][team]) > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  menu.ExitBackButton = true;

  return menu;
}

public int NameTagMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        char buffer[30];
        menu.GetItem(selection, buffer, sizeof(buffer));
        if (StrEqual(buffer, "nametag")) {
          g_bWaitingForNametag[client] = true;
          PrintToChat(client, " %s \x04%t", g_ChatPrefix, "NameTagInstruction");
        }
        /* NAMETAGCOLOR
        else if(StrEqual(buffer, "color"))
        {
                int menuTime;
                if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
                {
                        CreateColorsMenu(client).Display(client, menuTime);
                }
        }
        */
        else if (StrEqual(buffer, "delete")) {
          char updateFields[256];
          char weaponName[32];
          RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));

          int team = IsWeaponIndexInOnlyOneTeam(g_iIndex[client]) ? CS_TEAM_T : GetClientTeam(client);
          g_NameTag[client][g_iIndex[client]][team] = "";
          char teamName[4];
          teamName = team == CS_TEAM_T ? "" : "ct_";
          Format(updateFields, sizeof(updateFields), "%s%s_tag = ''", teamName, weaponName);
          UpdatePlayerData(client, updateFields);

          RefreshWeapon(client, g_iIndex[client]);

          int menuTime;
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateWeaponMenu(client).Display(client, menuTime);
          }
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateWeaponMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

/* NAMETAGCOLOR
Menu CreateColorsMenu(int client)
{
        Menu menu = new Menu(ColorsMenuHandler);
        menu.SetTitle("%T", "ChooseColor", client);

        char buffer[128];

        Format(buffer, sizeof(buffer), "%T", "DefaultColor", client);
        menu.AddItem("default", buffer);

        Format(buffer, sizeof(buffer), "%T", "Black", client);
        menu.AddItem("000000", buffer);

        Format(buffer, sizeof(buffer), "%T", "Yellow", client);
        menu.AddItem("FFFF00", buffer);

        Format(buffer, sizeof(buffer), "%T", "Red", client);
        menu.AddItem("FF0000", buffer);

        Format(buffer, sizeof(buffer), "%T", "Green", client);
        menu.AddItem("00FF00", buffer);

        Format(buffer, sizeof(buffer), "%T", "Blue", client);
        menu.AddItem("0000AA", buffer);

        menu.ExitBackButton = true;

        return menu;
}

public int ColorsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
        switch(action)
        {
                case MenuAction_Select:
                {
                        if(IsClientInGame(client))
                        {
                                char buffer[30];
                                menu.GetItem(selection, buffer, sizeof(buffer));

                                char stripped[128];
                                char escaped[257];
                                char colored[128];
                                char updateFields[512];
                                StripHtml(g_NameTag[client][g_iIndex[client]], stripped, sizeof(stripped));
                                if (StrEqual(buffer, "default"))
                                {
                                        g_NameTag[client][g_iIndex[client]] = stripped;

                                        db.Escape(stripped, escaped, sizeof(escaped));
                                }
                                else
                                {
                                        Format(colored, sizeof(colored), "<font color='#%s'>%s</font>", buffer,
stripped); g_NameTag[client][g_iIndex[client]] = colored;

                                        db.Escape(colored, escaped, sizeof(escaped));
                                }

                                char weaponName[32];
                                RemoveWeaponPrefix(g_WeaponClasses[g_iIndex[client]], weaponName, sizeof(weaponName));
                                Format(updateFields, sizeof(updateFields), "%s_tag = '%s'", weaponName, escaped);
                                UpdatePlayerData(client, updateFields);

                                RefreshWeapon(client, g_iIndex[client]);

                                CreateTimer(1.0, NameTagColorsMenuTimer, GetClientUserId(client));
                        }
                }
                case MenuAction_Cancel:
                {
                        if(IsClientInGame(client) && selection == MenuCancel_ExitBack)
                        {
                                int menuTime;
                                if((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0)
                                {
                                        CreateNameTagMenu(client).Display(client, menuTime);
                                }
                        }
                }
                case MenuAction_End:
                {
                        delete menu;
                }
        }
}

public Action NameTagColorsMenuTimer(Handle timer, int userid)
{
        int clientIndex = GetClientOfUserId(userid);
        if(IsValidClient(clientIndex))
        {
                int menuTime;
                if((menuTime = GetRemainingGracePeriodSeconds(clientIndex)) >= 0)
                {
                        CreateColorsMenu(clientIndex).Display(clientIndex, menuTime);
                }
        }
}
*/

Menu CreateAllWeaponsPaintsMenu(int client) {
  int index = g_iIndex[client];

  Menu menu = new Menu(AllWeaponsPaintsMenuHandler);
  menu.SetTitle("%T", g_WeaponClasses[index], client);

  char name[32];
  for (int i = 0; i < sizeof(g_WeaponClasses); i++) {
    Format(name, sizeof(name), "%T", g_WeaponClasses[i], client);
    menu.AddItem(g_WeaponClasses[i], name);
  }

  menu.ExitBackButton = true;

  return menu;
}

public int AllWeaponsPaintsMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        char class[30];
        menu.GetItem(selection, class, sizeof(class));

        int temp;
        g_smWeaponIndex.GetValue(class, temp);
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          menuWeapons[g_iClientLanguage[client]][temp].Display(client, menuTime);
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateWeaponMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

Menu CreateAllWeaponsMenu(int client) {
  Menu menu = new Menu(AllWeaponsMenuHandler);
  menu.SetTitle("%T", "AllWeaponsMenuTitle", client);

  char name[32];
  for (int i = 0; i < sizeof(g_WeaponClasses); i++) {
    Format(name, sizeof(name), "%T", g_WeaponClasses[i], client);
    menu.AddItem(g_WeaponClasses[i], name);
  }

  menu.ExitBackButton = true;

  return menu;
}

public int AllWeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        char class[30];
        menu.GetItem(selection, class, sizeof(class));

        g_smWeaponIndex.GetValue(class, g_iIndex[client]);
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateWeaponMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          CreateMainMenu(client).Display(client, menuTime);
        }
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

Menu CreateWeaponMenu(int client) {
  int index = g_iIndex[client];

  Menu menu = new Menu(WeaponMenuHandler);
  menu.SetTitle("%T", g_WeaponClasses[index], client);

  char buffer[128];

  Format(buffer, sizeof(buffer), "%T", "SetSkin", client);
  menu.AddItem("skin", buffer);

  int team = IsWeaponIndexInOnlyOneTeam(index) ? CS_TEAM_T : GetClientTeam(client);
  bool weaponHasSkin = (g_iSkins[client][index][team] != 0);

  if (g_bEnablePaints) {
    Format(buffer, sizeof(buffer), "%T", "Paints", client);
    menu.AddItem("paints", buffer);
  }

  if (!IsWeaponIndexInOnlyOneTeam(index)) {
    Format(buffer, sizeof(buffer), "%T", "Applyother", client);
    menu.AddItem("applyother", buffer);
  }

  if (g_bEnableFloat) {
    float fValue = g_fFloatValue[client][index][team];
    fValue = fValue * 100.0;
    int wear = 100 - RoundFloat(fValue);
    Format(buffer, sizeof(buffer), "%T%d%%", "SetFloat", client, wear);
    menu.AddItem("float", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (g_bEnableNameTag) {
    Format(buffer, sizeof(buffer), "%T", "SetNameTag", client);
    menu.AddItem("nametag", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (g_bEnableSeed) {
    Format(buffer, sizeof(buffer), "%T", "Seed", client);
    menu.AddItem("seed", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (g_bEnableStatTrak) {
    if (g_iStatTrak[client][index][team] == 1) {
      Format(buffer, sizeof(buffer), "%T%T", "StatTrak", client, "On", client);
    } else {
      Format(buffer, sizeof(buffer), "%T%T", "StatTrak", client, "Off", client);
    }
    menu.AddItem("stattrak", buffer, weaponHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  menu.ExitBackButton = true;

  return menu;
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        char info[32];
        menu.GetItem(selection, info, sizeof(info));
        int menuTime;
        if (StrEqual(info, "all")) {
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateAllWeaponsMenu(client).Display(client, menuTime);
          }
        } else if (StrEqual(info, "lang")) {
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateLanguageMenu(client).Display(client, menuTime);
          }
        } else {
          g_smWeaponIndex.GetValue(info, g_iIndex[client]);
          if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
            CreateWeaponMenu(client).Display(client, menuTime);
          }
        }
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        ClientCommand(client, "sm_diy");
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}

Menu CreateMainMenu(int client) {
  char buffer[60];
  Menu menu = new Menu(MainMenuHandler, MENU_ACTIONS_DEFAULT);

  menu.SetTitle("%T", "WSMenuTitle", client);

  Format(buffer, sizeof(buffer), "%T", "ConfigAllWeapons", client);
  menu.AddItem("all", buffer);

  int index = 2;

  if (IsPlayerAlive(client)) {
    char weaponClass[32];
    char weaponName[32];

    int size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");

    for (int i = 0; i < size; i++) {
      int weaponEntity = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
      if (weaponEntity != -1 && GetWeaponClass(weaponEntity, weaponClass, sizeof(weaponClass))) {
        int team = GetClientTeam(client);
        Format(weaponName, sizeof(weaponName), "%T", weaponClass, client);
        menu.AddItem(weaponClass, weaponName,
                     (IsKnifeClass(weaponClass) && g_iKnife[client][team] == 0) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
        index++;
      }
    }
  }

  for (int i = index; i < 6; i++) {
    menu.AddItem("", "", ITEMDRAW_SPACER);
  }

  Format(buffer, sizeof(buffer), "%T", "ChangeLang", client);
  menu.AddItem("lang", buffer);

  if (LibraryExists("diy")) {
    menu.ExitBackButton = true;
  }

  return menu;
}

public int KnifeMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        char knifeIdStr[32];
        menu.GetItem(selection, knifeIdStr, sizeof(knifeIdStr));
        int knifeId = StringToInt(knifeIdStr);

        int team = GetClientTeam(client);

        g_iKnife[client][team] = knifeId;
        char teamName[4];
        teamName = team == CS_TEAM_T ? "" : "_ct";
        char updateFields[50];
        Format(updateFields, sizeof(updateFields), "knife%s = %d", teamName, knifeId);
        UpdatePlayerData(client, updateFields);

        RefreshWeapon(client, knifeId, knifeId == 0);

        int menuTime;
        if ((menuTime = GetRemainingGracePeriodSeconds(client)) >= 0) {
          menuKnife.DisplayAt(client, GetMenuSelectionPosition(), menuTime);
        }
      }
    }
    case MenuAction_DrawItem: {
      char info[32];
      menu.GetItem(selection, info, sizeof(info));
      int team = GetClientTeam(client);
      if (g_iKnife[client][team] == StringToInt(info)) {
        return ITEMDRAW_DISABLED;
      }
    }
    case MenuAction_Cancel: {
      if (IsClientInGame(client) && selection == MenuCancel_ExitBack) {
        ClientCommand(client, "sm_diy");
      }
    }
  }

  return 0;
}

Menu CreateLanguageMenu(int client) {
  Menu menu = new Menu(LanguageMenuHandler);
  menu.SetTitle("%T", "ChooseLanguage", client);

  char buffer[4];

  for (int i = 0; i < sizeof(g_Language); i++) {
    if (strlen(g_Language[i]) == 0)
      break;
    IntToString(i, buffer, sizeof(buffer));
    menu.AddItem(buffer, g_Language[i]);
  }

  return menu;
}

public int LanguageMenuHandler(Menu menu, MenuAction action, int client, int selection) {
  switch (action) {
    case MenuAction_Select: {
      if (IsClientInGame(client)) {
        char langIndexStr[4];
        menu.GetItem(selection, langIndexStr, sizeof(langIndexStr));
        int langIndex = StringToInt(langIndexStr);

        g_iClientLanguage[client] = langIndex;
      }
    }
    case MenuAction_End: {
      delete menu;
    }
  }
}
