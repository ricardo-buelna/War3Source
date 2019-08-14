#pragma semicolon 1

#include <sourcemod>
#include "W3SIncs/War3Source_Interface"

//test commit
public Plugin:myinfo = 
{
    name = "War3Source - Race - Undead Scourge",
    author = "War3Source Team",
    description = "The Undead Scourge race for War3Source"
};

new thisRaceID;

new bool:RaceDisabled=true;
public OnWar3RaceEnabled(newrace)
{
    if(newrace==thisRaceID)
    {
        RaceDisabled=false;
    }
}
public OnWar3RaceDisabled(oldrace)
{
    if(oldrace==thisRaceID)
    {
        RaceDisabled=true;
    }
}

new Float:SuicideBomberRadius[5] = {0.0, 300.0, 350.0, 400.0, 450.0}; 
new Float:SuicideBomberDamage[5] = {0.0, 166.0, 200.0, 233.0, 266.0};
new Float:SuicideBomberDamageTF[5] = {0.0, 133.0, 175.0, 250.0, 300.0}; 

new Float:UnholySpeed[5] = {1.0, 1.10, 1.20, 1.30, 1.40};
new Float:LevitationGravity[5] = {1.0, 0.75, 0.6, 0.5, 0.4};
new Float:VampirePercent[5] = {0.0, 0.10, 0.15, 0.20, 0.25};

new bool:UltimatePrimed = false;
new Float:UltimatePrimedTime = 5.0;
new Float:UltimateSoundPrimedTime = 1.0;
new String:primedSound[256];
new Handle:UltimatePrimedTimerHandle;

new String:explosionSound[256];

new SKILL_LEECH, SKILL_SPEED, SKILL_LOWGRAV, SKILL_SUICIDE;

public OnPluginStart()
{
    LoadTranslations("w3s.race.undead.phrases.txt");
}

public OnMapStart()
{
    War3_AddSoundFolder(primedSound, sizeof(primedSound), "primed.mp3");
    War3_AddCustomSound(primedSound);

    War3_AddSoundFolder(explosionSound, sizeof(explosionSound), "explosion.mp3");
    War3_AddCustomSound(explosionSound);
}

public OnWar3LoadRaceOrItemOrdered(num)
{
    if(num == 10)
    {
        thisRaceID = War3_CreateNewRaceT("undead");
        SKILL_LEECH = War3_AddRaceSkillT(thisRaceID, "VampiricAura", false, 4, "20%");
        SKILL_SPEED = War3_AddRaceSkillT(thisRaceID, "UnholyAura", false, 4, "20%");
        SKILL_LOWGRAV = War3_AddRaceSkillT(thisRaceID, "Levitation", false, 4, "0.5");
        SKILL_SUICIDE = War3_AddRaceSkillT(thisRaceID, "SuicideBomber", true, 4); 
        
        War3_CreateRaceEnd(thisRaceID);
        
        War3_AddSkillBuff(thisRaceID, SKILL_LEECH, fVampirePercent, VampirePercent);
        War3_AddSkillBuff(thisRaceID, SKILL_SPEED, fMaxSpeed, UnholySpeed);
        War3_AddSkillBuff(thisRaceID, SKILL_LOWGRAV, fLowGravitySkill, LevitationGravity);
    }
}

public OnUltimateCommand(client, race, bool:pressed)
{
    if(RaceDisabled)
    {
        return;
    }

    if(pressed && War3_GetRace(client) == thisRaceID && IsPlayerAlive(client) && !Silenced(client))
    {
        new ult_level = War3_GetSkillLevel(client, race, SKILL_SUICIDE);
        if(ult_level > 0)
        {
            if ( UltimatePrimed )
            {
                CloseHandle(UltimatePrimedTimerHandle);
                ForcePlayerSuicide(client);
            }
            else
            {
                UltimatePrimed = true;
                W3EmitSoundToAll(primedSound, client);
                UltimatePrimedTimerHandle = CreateTimer(UltimateSoundPrimedTime, EmitUltimatePrimedSound, client, TIMER_REPEAT);
                CreateTimer(UltimatePrimedTime,UnReadyUltimate,client);
            }
        }
        else
        {
            W3MsgUltNotLeveled(client);
	    }
    }
}

public Action:UnReadyUltimate(Handle:h,any:client)
{
    UltimatePrimed = false;
    CloseHandle(UltimatePrimedTimerHandle);
}

public Action:EmitUltimatePrimedSound(Handle:h,any:client)
{
    W3EmitSoundToAll(primedSound, client);
}

public OnWar3EventDeath(victim, attacker)
{
    if(RaceDisabled)
    {
        return;
    }

    if( UltimatePrimed )
    {
        UltimatePrimed = false;
        CloseHandle(UltimatePrimedTimerHandle);
    }

    new race = W3GetVar(DeathRace);
    new skill = War3_GetSkillLevel(victim, thisRaceID, SKILL_SUICIDE);
    if(race == thisRaceID && skill > 0 && !Hexed(victim))
    {
        decl Float:fVictimPos[3];
        GetClientAbsOrigin(victim, fVictimPos);
        W3EmitSoundToAll(explosionSound, client);
        War3_SuicideBomber(victim, fVictimPos, GameTF() ? SuicideBomberDamageTF[skill] : SuicideBomberDamage[skill], SKILL_SUICIDE, SuicideBomberRadius[skill]);        
    } 
}