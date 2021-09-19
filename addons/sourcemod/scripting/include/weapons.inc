#if defined _weapons_included_
  #endinput
#endif
#define _weapons_included_

//Retrieves and stores client's knife entity name in 'sKnife'. returns 'weapon_knife' if selection is 'OwnKnife'.
native void Weapons_GetClientKnife(int client, char[] sKnife, int Size);

//Sets client's knife to what is stored in 'sKnife'. Throws Native Error if knife name isn't valid. Update = Store the 'sKnife' in client's mysql table?
native void Weapons_SetClientKnife(int client, char[] sKnife, bool update);

//Called before client selects a knife from !knife. return Plugin_Handled to block.
forward Action Weapons_OnClientKnifeSelectPre(int client, int knifeId, char[] knifeName);

//Called after client selects a knife from !knife.
forward void Weapons_OnClientKnifeSelectPost(int client, int knifeId, char[] knifeName);

//Sets client's skins for a weapons.
native void Weapons_SetClientSkin(int client, const char[] weapon, int skin);

// Set client's float(wear) for a weapon. 
native void Weapons_SetClientWear(int client, const char[] weapon, float wear);

// Set client's seed for a weapon. 
native void Weapons_SetClientSeed(int client, const char[] weapon, int seed);

// Set client's nametag for a weapon
native void Weapons_SetClientNameTag(int client, const char[] weapon, const char[] name);

// Set client's startrack for a weapon
native void Weapons_ToggleClientStarTrack(int client, const char[] weapon);