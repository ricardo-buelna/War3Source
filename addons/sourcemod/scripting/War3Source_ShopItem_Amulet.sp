#pragma semicolon 1

#include "sdkhooks"
#include "W3SIncs/War3Source_Interface"

new thisItem;

public Plugin:myinfo = 
{
    name = "War3Source - Shopitem - Amulet",
    author = "Ricardo Buelna",
    description = "Your footsteps are silet to all players"
};

public OnMapStart()
{   
    LoadTranslations("w3s.item.amulet.phrases.txt");
}
public OnWar3LoadRaceOrItemOrdered2(num)
{
    if(num==200){
    
        thisItem = War3_CreateShopItemT("amulet", 20, true);
    }    
}
public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_TraceAttack, SDK_Forwarded_TraceAttack);
}
public OnClientDisconnect(client)
{
    SDKUnhook(client, SDKHook_TraceAttack, SDK_Forwarded_TraceAttack); 
}

public Action:SDK_Forwarded_TraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
    return Plugin_Continue;
}
