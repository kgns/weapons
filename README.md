# [CS:GO] Weapon & Knives (Skins, Name Tags, StatTrak, Wear/Float)

[![License](https://img.shields.io/github/license/kgns/weapons.svg?style=flat-square)](https://github.com/kgns/weapons/blob/master/LICENSE)
[![Build Status](https://build.kgns.dev/job/csgo-weapons/badge/icon?style=flat-square)](https://build.kgns.dev/job/csgo-weapons)
[![GitHub Downloads](https://img.shields.io/github/downloads/kgns/weapons/total.svg?style=flat-square)](https://github.com/kgns/weapons/releases/latest)

## DESCRIPTION
This plugin allows you to:
- Use any knife that is available inside CS:GO environment;
- Apply any skin that is available inside CS:GO environment; ***(Including new cases skins)***
- Change the wear/float value of your skins;
- Enable/Disable StatTrak technology on your weapons and knives;
- Add Nametags to your weapons and knives;

 **Note:** **IN THE PAST**, Valve banned GSLTs (tokens) of servers for using this plugin or its variants. But, Valve stopped banning GSLTs (tokens) a long time ago for some reason.

**AlliedModders:** https://forums.alliedmods.net/showthread.php?t=298770

## REQUIREMENTS
- **[PTaH 1.1.0+](https://ptah.zizt.ru/)**
  - **[Auto Updater](https://forums.alliedmods.net/showthread.php?p=1570806)** ***(Required if you want to compile)***
  - **[SteamWorks](https://github.com/hexa-core-eu/SteamWorks)** ***(Required if you want to compile)***

## INSTALLATION
- Use this without a GSLT token (LAN server), or use a token service for your servers, or your account will be banned from operating game servers, and a month cooldown from playing the game.
- Edit csgo/addons/sourcemod/configs/core.cfg => Change "FollowCSGOServerGuidelines" "yes" to "no"
- Install PTaH 1.1.0+ (DOWNLOAD PTaH)
- Copy the folder structure to your gameserver.
  - (OPTIONAL) If you want to use MySQL instead of SQLite (storage-local), edit addons/sourcemod/configs/databases.cfg file and add the MySQL db connection details under "weapons" title, then change "sm_weapons_db_connection" cvar inside cfg/sourcemod/weapons.cfg file to "weapons"
- Restart server.

## DONATE
If you want to donate, I'd appreciate it: https://steamcommunity.com/tradeoffer/new/?partner=37011238&token=yGo05pTn

## FAQ | TROUBLESHOOTING
- **Is there a way for me to update the skins list myself when new skins are released and even for my language?**

There is a small **`java`** utility I coded to create config files when new skins arrive or for different languages: https://github.com/kaganus/CSGOItemParserForWeaponsPlugin

- **I'm getting the following error `"FollowCSGOServerGuidelines" option enabled`**

Locate the file **`core.cfg`** in the folder **`csgo/addons/sourcemod/configs`** and change **`"FollowCSGOServerGuidelines" "yes"`** to **`"FollowCSGOServerGuidelines" "no "`**.
