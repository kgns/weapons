#include "include/weapons.inc"

native int Weapons_SetClientSkin(int client, const char[] weapon, int skin);

public void OnPluginStart()
{
	RegConsoleCmd("sm_test", test_native);
}

public Action test_native(int client, int args)
{
	Weapons_SetClientSkin(client, "weapon_glock", 1039);
	Weapons_SetClientKnife(client, "weapon_knife_karambit", true);
	Weapons_SetClientSkin(client, "weapon_knife_karambit", 572);
	return Plugin_Handled;
}