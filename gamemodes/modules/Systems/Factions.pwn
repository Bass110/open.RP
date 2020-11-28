/*
    #### ##    ##  ######  ##       ##     ## ########  ######## 
     ##  ###   ## ##    ## ##       ##     ## ##     ## ##       
     ##  ####  ## ##       ##       ##     ## ##     ## ##       
     ##  ## ## ## ##       ##       ##     ## ##     ## ######   
     ##  ##  #### ##       ##       ##     ## ##     ## ##       
     ##  ##   ### ##    ## ##       ##     ## ##     ## ##       
    #### ##    ##  ######  ########  #######  ########  ######## 
*/

#include <YSI_Coding\y_hooks>


/*
    ########  ######## ######## #### ##    ## ######## 
    ##     ## ##       ##        ##  ###   ## ##       
    ##     ## ##       ##        ##  ####  ## ##       
    ##     ## ######   ######    ##  ## ## ## ######   
    ##     ## ##       ##        ##  ##  #### ##       
    ##     ## ##       ##        ##  ##   ### ##       
    ########  ######## ##       #### ##    ## ######## 
*/

#define FACTION_TYPE_NONE               (0)
#define FACTION_TYPE_LAW                (1)
#define FACTION_TYPE_FD                 (2)
#define FACTION_TYPE_LEGAL              (3)
#define FACTION_TYPE_MAFIA              (4)
#define FACTION_TYPE_GANG               (5)
#define FACTION_TYPE_RACERS             (6)
#define FACTION_TYPE_NEWS               (7)
#define FACTION_TYPE_LAW2               (8)


/*
    ##     ##    ###    ########   ######
    ##     ##   ## ##   ##     ## ##    ##
    ##     ##  ##   ##  ##     ## ##
    ##     ## ##     ## ########   ######
     ##   ##  ######### ##   ##         ##
      ## ##   ##     ## ##    ##  ##    ##
       ###    ##     ## ##     ##  ######
*/

static
    deletingFaction[MAX_PLAYERS],
    Timer:BackupTimer[MAX_PLAYERS],
    creatingInfoId[MAX_PLAYERS],
    creatingFaction,
    blockfam[MAX_FACTIONS];


/*
    ######## ##     ## ##    ##  ######   ######  
    ##       ##     ## ###   ## ##    ## ##    ## 
    ##       ##     ## ####  ## ##       ##       
    ######   ##     ## ## ## ## ##        ######  
    ##       ##     ## ##  #### ##             ## 
    ##       ##     ## ##   ### ##    ## ##    ## 
    ##        #######  ##    ##  ######   ######  
*/

Public:FetchPlayerFaction(playerid)
{
    return PlayerInfo[playerid][pMember];
}

Public:FetchPlayerFactionType(playerid)
{
    if (!Iter_Contains(Factions, PlayerInfo[playerid][pMember]))
    {
        return 0;
    }
    return FactionInfo[PlayerInfo[playerid][pMember]][fType];
}

stock IsFreeSlot(orgid)
{
    if (FactionInfo[orgid][fUsed] != 0)
    {
        return 0;
    }
    return 1;
}

stock NotFDSkin(playerid)
{
    new skin = GetPlayerSkin(playerid);
    if (skin == 277 ||skin == 278 || skin == 279)
    {
        return 1;
    }
    return 0;
}

stock DeleteFaction(orgid)
{
    mysql_fquery(g_SQL, "DELETE FROM server_factions WHERE id = '%d'", FactionInfo[orgid][fID]);
    mysql_fquery(g_SQL, "DELETE FROM faction_logs WHERE faction_id = '%d'", FactionInfo[orgid][fID]);
    
    FactionInfo[orgid][fUsed] = 0;
    FactionInfo[orgid][fType] = 0;
    FactionInfo[orgid][fRanks] = 0;
    FactionInfo[orgid][fFactionBank] = 0;

    RemoveLeaders(orgid);
    RemoveMembers(orgid);
    Iter_Remove(Factions, orgid);

    ResetFaction(orgid);
    return 1;
}

stock LoadServerFactions()
{
    mysql_tquery(g_SQL, 
        va_fquery(g_SQL, "SELECT * FROM server_factions"), 
        "OnFactionLoaded",
        ""
    );
    return 1;
}

stock LoadFactionPermissions(factionid)
{
    mysql_tquery(g_SQL, 
        va_fquery(g_SQL, "SELECT * FROM server_factions_permissions WHERE id = '%d'", FactionInfo[factionid][fID]), 
        "OnFactionPermissionsLoaded", 
        "i", 
        factionid
    );
    return 1;
}

// TODO: move to a common helper/utility functions file
IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
    new
        Float:fX,
        Float:fY,
        Float:fZ;

    GetPlayerPos(targetid, fX, fY, fZ);
    // TODO: introduce a new variable and do all these checks nicely formatted. Don't go over 110 chars per line.
    return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

forward OnFactionLoaded();
public OnFactionLoaded()
{
    new
        tmp[64],
        tmpId,
        rows = cache_num_rows();

    if (!rows) return printf("MySQL Report: No factions exist to load.");

    for (new i = 0; i < rows; i++)
    {
        cache_get_value_name_int(i, "id", tmpId);
        // TODO: nije dobro indeksirati array sa indeksima iz SQL-a
        // cemu onda sluze iteratori?! također, treba provjeriti da rows
        // ne prelazi MAX_FACTIONS (vece jednako) u startu

        // FactionInfo[index] - neka index ide od 0..MAX_FACTIONS-1
        // kako se ne bi izgubilo jedan index slot ako kreću bzvz od 1
        // zatim samo indeksiras unutra pomocu iteratora
        // svugdje u kodu napravis neki getter koji ti povezuje taj index u array
        // sa SQL ID-em te fakcije u bazi
        FactionInfo[tmpId][fID] = tmpId;

        cache_get_value_name_int(i, "used"  , FactionInfo[tmpId][fUsed]);
        cache_get_value_name(i, "name", tmp);
        format(FactionInfo[tmpId][fName], 24, tmp);
        cache_get_value_name_int(i, "type", FactionInfo[tmpId][fType]);
        cache_get_value_name(i, "rank1", tmp);
        format(FactionInfo[tmpId][fRankName1], 24, tmp);
        cache_get_value_name(i, "rank2", tmp);
        format(FactionInfo[tmpId][fRankName2], 24, tmp);
        cache_get_value_name(i, "rank3", tmp);
        format(FactionInfo[tmpId][fRankName3], 24, tmp);
        cache_get_value_name(i, "rank4", tmp);
        format(FactionInfo[tmpId][fRankName4], 24, tmp);
        cache_get_value_name(i, "rank5", tmp);
        format(FactionInfo[tmpId][fRankName5], 24, tmp);
        cache_get_value_name(i, "rank6", tmp);
        format(FactionInfo[tmpId][fRankName6], 24, tmp);
        cache_get_value_name(i, "rank7", tmp);
        format(FactionInfo[tmpId][fRankName7], 24, tmp);
        cache_get_value_name(i, "rank8", tmp);
        format(FactionInfo[tmpId][fRankName8], 24, tmp);
        cache_get_value_name(i, "rank9", tmp);
        format(FactionInfo[tmpId][fRankName9], 24, tmp);
        cache_get_value_name(i, "rank10", tmp);
        format(FactionInfo[tmpId][fRankName10], 24, tmp);
        cache_get_value_name(i, "rank11", tmp);
        format(FactionInfo[tmpId][fRankName11], 24, tmp);
        cache_get_value_name(i, "rank12", tmp);
        format(FactionInfo[tmpId][fRankName12], 24, tmp);
        cache_get_value_name(i, "rank13", tmp);
        format(FactionInfo[tmpId][fRankName13], 24, tmp);
        cache_get_value_name(i, "rank14", tmp);
        format(FactionInfo[tmpId][fRankName14], 24, tmp);
        cache_get_value_name(i, "rank15", tmp);
        format(FactionInfo[tmpId][fRankName15], 24, tmp);
        cache_get_value_name_int(i, "ranks", FactionInfo[tmpId][fRanks]);
        format(FactionInfo[tmpId][fFactionBank], 24, tmp);
        cache_get_value_name_int(i, "factionbank", FactionInfo[tmpId][fFactionBank]);

        LoadFactionPermissions(tmpId);
        Iter_Add(Factions, tmpId);
    }
    printf("MySQL Report: Factions loaded (%d)!", Iter_Count(Factions));
    LoadWarehouses();
    return 1;
}

forward OnFactionPermissionsLoaded(factionid);
public OnFactionPermissionsLoaded(factionid)
{
    if (!cache_num_rows()) return 0;

    cache_get_value_name_int(0,    "siren"       ,    FactionInfo[factionid][rSiren]);
    cache_get_value_name_int(0,    "cargun"      ,    FactionInfo[factionid][rCarGun]);
    cache_get_value_name_int(0,    "carsign"     ,    FactionInfo[factionid][rCarSign]);
    cache_get_value_name_int(0,    "abuygun"     ,    FactionInfo[factionid][rABuyGun]);
    cache_get_value_name_int(0,    "buygun"      ,    FactionInfo[factionid][rBuyGun]);
    cache_get_value_name_int(0,    "aswat"       ,    FactionInfo[factionid][rASwat]);
    cache_get_value_name_int(0,    "govrepair"   ,    FactionInfo[factionid][rGovRepair]);
    cache_get_value_name_int(0,    "agovrepair"  ,    FactionInfo[factionid][rAGovRepair]);
    cache_get_value_name_int(0,    "unfree"      ,    FactionInfo[factionid][rUnFree]);
    cache_get_value_name_int(0,    "cleartrunk"  ,    FactionInfo[factionid][rClrTrunk]);
    cache_get_value_name_int(0,    "listennumber",    FactionInfo[factionid][rLstnNumber]);
    cache_get_value_name_int(0,    "race"        ,    FactionInfo[factionid][rRace]);
    cache_get_value_name_int(0,    "undercover"  ,    FactionInfo[factionid][rUndercover]);
    cache_get_value_name_int(0,    "aundercover" ,    FactionInfo[factionid][rAUndercover]);
    cache_get_value_name_int(0,    "listensms"   ,    FactionInfo[factionid][rLstnSMS]);
    return 1;
}

stock SaveFaction(orgid)
{
    // TODO: this is an abomination; refactor this. make a helper function
    if (isnull(FactionInfo[orgid][fRankName1]))
        format(FactionInfo[orgid][fRankName1], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName2]))
        format(FactionInfo[orgid][fRankName2], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName3]))
        format(FactionInfo[orgid][fRankName3], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName4]))
        format(FactionInfo[orgid][fRankName4], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName5]))
        format(FactionInfo[orgid][fRankName5], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName6]))
        format(FactionInfo[orgid][fRankName6], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName7]))
        format(FactionInfo[orgid][fRankName7], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName8]))
        format(FactionInfo[orgid][fRankName8], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName9]))
        format(FactionInfo[orgid][fRankName9], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName10]))
        format(FactionInfo[orgid][fRankName10], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName11]))
        format(FactionInfo[orgid][fRankName11], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName12]))
        format(FactionInfo[orgid][fRankName12], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName13]))
        format(FactionInfo[orgid][fRankName13], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName14]))
        format(FactionInfo[orgid][fRankName14], 24, "None");
    if (isnull(FactionInfo[orgid][fRankName15]))
        format(FactionInfo[orgid][fRankName15], 24, "None");

    mysql_tquery(g_SQL, 
        va_fquery(g_SQL, 
            "INSERT INTO server_factions (id, used,name,type,rank1,rank2,rank3,rank4,rank5,rank6,rank7,rank8,rank9,\n\
                rank10,rank11,rank12,rank13,rank14,rank15,ranks,factionbank) \n\
                VALUES ('%d','%d','%e','%d','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%e','%d','%d')",
            orgid,
            FactionInfo[orgid][fUsed],
            FactionInfo[orgid][fName],
            FactionInfo[orgid][fType],
            FactionInfo[orgid][fRankName1],
            FactionInfo[orgid][fRankName2],
            FactionInfo[orgid][fRankName3],
            FactionInfo[orgid][fRankName4],
            FactionInfo[orgid][fRankName5],
            FactionInfo[orgid][fRankName6],
            FactionInfo[orgid][fRankName7],
            FactionInfo[orgid][fRankName8],
            FactionInfo[orgid][fRankName9],
            FactionInfo[orgid][fRankName10],
            FactionInfo[orgid][fRankName11],
            FactionInfo[orgid][fRankName12],
            FactionInfo[orgid][fRankName13],
            FactionInfo[orgid][fRankName14],
            FactionInfo[orgid][fRankName15],
            FactionInfo[orgid][fRanks],
            FactionInfo[orgid][fFactionBank]

        ), 
        "OnAdminFactionCreate", 
        "i", 
        orgid
    );
    return 1;
}

forward OnAdminFactionCreate(orgid);
public OnAdminFactionCreate(orgid)
{
    // TODO: bounds checking, also, this function is wrong. Do not equate faction SQL ID's to FactionInfo indices!!!
    FactionInfo[orgid][fID] = orgid;
    return 1;
}

stock ResetFaction(fid)
{
    static const
		e_factionInfo[E_FACTION_DATA];
		
	FactionInfo[fid] = e_factionInfo;
    
    return 1;
}

stock RemoveLeaders(orgid)
{
    mysql_fquery(g_SQL, 
        "UPDATE accounts SET facLeadId = '0', facMemId = '0' WHERE facLeadId = '%d'",
        orgid
    );

    foreach(new i : Player)
    {
        if (PlayerInfo[i][pLeader] == orgid)
        {
            PlayerInfo[i][pLeader] = 0;
            SendClientMessage(i, COLOR_RED, "[ ! ] Dobili ste kick iz organizacije zbog njenog brisanja!");
        }
    }
    return 1;
}

stock RemoveMembers(orgid)
{
    mysql_fquery(g_SQL, 
        "UPDATE accounts SET facMemId = '0' WHERE facMemId = '%d'",
        orgid
    );

    foreach(new i : Player)
    {
        if (PlayerInfo[i][pMember] == orgid)
        {
            PlayerInfo[i][pMember] = 0;
            SendClientMessage(i, COLOR_RED, "[ ! ] Dobili ste kick iz organizacije zbog njenog brisanja!");
        }
    }
    return 1;
}

stock ReturnPlayerRankName(playerid)
{
    new
        member  = PlayerInfo[playerid][pMember],
        rank    = PlayerInfo[playerid][pRank],
        rtext[64];

    // TODO: total abomination. no need for switch, refactor FactionInfo
    switch (rank)
    {
        case 1: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName1]);
        case 2: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName2]);
        case 3: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName3]);
        case 4: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName4]);
        case 5: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName5]);
        case 6: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName6]);
        case 7: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName7]);
        case 8: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName8]);
        case 9: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName9]);
        case 10: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName10]);
        case 11: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName11]);
        case 12: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName12]);
        case 13: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName13]);
        case 14: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName14]);
        case 15: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName15]);
    }
    return rtext;
}

stock ReturnPlayerFactionName(playerid)
{
    new
        string[25],
        faction = PlayerInfo[playerid][pMember];
    // TODO: strcpy
    if (faction < 1 || faction > MAX_FACTIONS-1)
        format(string, sizeof(string), "Civil");
    else
        format(string, sizeof(string), FactionInfo[faction][fName]);

    return string;
}

stock ReturnRankName(rank, playerid)
{
    new
        member = PlayerInfo[playerid][pMember],
        rtext[64];

    // TODO: total abomination. no need for switch, refactor FactionInfo
    switch (rank)
    {
        case 1: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName1]);
        case 2: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName2]);
        case 3: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName3]);
        case 4: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName4]);
        case 5: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName5]);
        case 6: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName6]);
        case 7: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName7]);
        case 8: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName8]);
        case 9: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName9]);
        case 10: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName10]);
        case 11: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName11]);
        case 12: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName12]);
        case 13: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName13]);
        case 14: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName14]);
        case 15: format(rtext,sizeof(rtext),"%s",FactionInfo[member][fRankName15]);
    }
    return rtext;
}

stock SendFactionMessage(family, color, sstring[])
{
    foreach(new i : Player)
    {
        if (PlayerInfo[i][pMember] == family && Bit1_Get(gr_FactionChatTog, i))
        {
            SendClientMessage(i, color, sstring);
        }
    }
}

stock SendRadioMessage(member, color, sstring[])
{
    foreach(new i : Player)
    {
        if (PlayerInfo[i][pMember] == member && PlayerInfo[i][pLawDuty] != 0)
        {
            SendClientMessage(i, color, sstring);
            PlayerPlaySound(i, 1058, 0.0, 0.0, 0.0);
        }
    }
}

stock SendPoliceMessage(color, const string[])
{
    foreach(new i : Player)
    {
        if (IsACop(i))
        {
            SendClientMessage(i, color, string);
        }
    }
}

stock SendLawMessage(color, sstring[])
{
    foreach(new i : Player)
    {
        if ((IsACop(i) || IsASD(i) || IsFDMember(i) || IsAGov(i)) && PlayerInfo[i][pLawDuty] != 0)
        {
            SendClientMessage(i, color, sstring);
        }
    }
}

stock CountMembers(orgid)
{
    new count;
    foreach(new i : Player)
    {
        if (PlayerInfo[i][pMember] == orgid) count++;
    }
    return count;
}

// TODO: delete this function, try to make functions for general use.
stock CountFDMembers()
{
    new count;
    foreach(new i : Player)
    {
        new member = PlayerInfo[i][pMember];
        if (FactionInfo[member][fType] == 2) count++;
    }
    return count;
}

// TODO:
// Instead of doing 10,000 of functions for each faction, make one general function
// to check if player belongs to that faction: PlayerInFaction(playerid, faction)
// PlayerLeaderOfFaction(playerid, faction) or similar. Also, make these funcs bool:
stock IsADoC(playerid)
{
    if (PlayerInfo[playerid][pMember] == 3 || PlayerInfo[playerid][pLeader] == 3)
    {
        return 1;
    }
    return 0;
}

stock IsAFM(playerid)
{
    if (PlayerInfo[playerid][pMember] == 6 || PlayerInfo[playerid][pLeader] == 6)
    {
        return 1;
    }
    return 0;
}

stock IsAGov(playerid)
{
    if (FactionInfo[PlayerInfo[playerid][pMember]][fType] == FACTION_TYPE_LEGAL)
    {
        return 1;
    }
    return 0;
}

stock IsACop(playerid)
{
    if (FactionInfo[PlayerInfo[playerid][pMember]][fType] == FACTION_TYPE_LAW && PlayerInfo[playerid][pMember] == 1)
    {
        return 1;
    }
    return 0;
}

stock IsASD(playerid)
{
    if (FactionInfo[PlayerInfo[playerid][pMember]][fType] == FACTION_TYPE_LAW2 && PlayerInfo[playerid][pMember] == 3)
    {
        return 1;
    }
    return 0;
}

stock IsFDMember(playerid)
{
    if (FactionInfo[PlayerInfo[playerid][pMember]][fType] == FACTION_TYPE_FD)
    {
        return 1;
    }
    return 0;
}

stock IsANews(playerid)
{
    if (FactionInfo[PlayerInfo[playerid][pMember]][fType] == FACTION_TYPE_NEWS)
    {
        return 1;
    }
    return 0;
}

stock IsARacer(playerid)
{
    if (FactionInfo[PlayerInfo[playerid][pMember]][fType] == FACTION_TYPE_RACERS)
    {
        return 1;
    }
    return 0;
}

stock IsInFDCar(playerid)
{
    if (GetVehicleModel(GetPlayerVehicleID(playerid)) == 407 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 601)
    {
        return 1;
    }
    return 0;
}

stock IsInStateVehicle(playerid) // PD/FD/DoC/GOV
{
    new vehicleid = GetPlayerVehicleID(playerid);
    if (vehicleid == INVALID_VEHICLE_ID)
    {
        return 0;
    }

    if (VehicleInfo[vehicleid][vFaction] == 1 || VehicleInfo[vehicleid][vFaction] == 2 ||
        VehicleInfo[vehicleid][vFaction] == 3 || VehicleInfo[vehicleid][vFaction] == 4)
    {
        return 1;
    }
    return 0;
}

// TODO: move to utility functions file related to player camera and camera calculations
stock Float:DistanceCameraTargetToLocation(Float:CamX, Float:CamY, Float:CamZ, Float:ObjX, Float:ObjY, Float:ObjZ, Float:FrX, Float:FrY, Float:FrZ)
{
    new Float:TGTDistance;

    // get distance from camera to target
    TGTDistance = floatsqroot((CamX - ObjX) * (CamX - ObjX) + (CamY - ObjY) * (CamY - ObjY) + (CamZ - ObjZ) * (CamZ - ObjZ));

    new Float:tmpX, Float:tmpY, Float:tmpZ;

    tmpX = FrX * TGTDistance + CamX;
    tmpY = FrY * TGTDistance + CamY;
    tmpZ = FrZ * TGTDistance + CamZ;

    return floatsqroot((tmpX - ObjX) * (tmpX - ObjX) + (tmpY - ObjY) * (tmpY - ObjY) + (tmpZ - ObjZ) * (tmpZ - ObjZ));
}

// TODO: move to utility functions file related to player camera and camera calculations
stock IsPlayerAimingAt(playerid, Float:x, Float:y, Float:z, Float:radius)
{
    new Float:cx,Float:cy,Float:cz,Float:fx,Float:fy,Float:fz;
    GetPlayerCameraPos(playerid, cx, cy, cz);
    GetPlayerCameraFrontVector(playerid, fx, fy, fz);
    return (radius >= DistanceCameraTargetToLocation(cx, cy, cz, x, y, z, fx, fy, fz));
}

timer OnPlayerBackup[1000](playerid)
{
    if (Bit4_Get(gr_Backup, playerid) != 0)
    {
        foreach(new i : Player)
        {
            if (Bit4_Get(gr_Backup, playerid) == 1)
            {
                if (IsACop(i))
                    SetPlayerMarkerForPlayer(i, playerid, 0x8D8DFFFF);
            }
            else if (Bit4_Get(gr_Backup, playerid) == 2)
            {
                if (IsFDMember(i))
                    SetPlayerMarkerForPlayer(i, playerid, 0xFF9499FF);
            }
            else if (Bit4_Get(gr_Backup, playerid) == 5)
            {
                if (IsASD(i))
                    SetPlayerMarkerForPlayer(i, playerid, 0xFF9499FF);
            }
        }
    }
    return 1;
}

forward UninvitePlayer(playerid, const targetname[]);
public UninvitePlayer(playerid, const targetname[])
{
    new rows, string[128];
    cache_get_row_count(rows);

    if (!rows)
    {
        SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne postoji korisnik s tim nickom!");
        return 1;
    }

    new playerMember, playerLeader, playerSQLID;
    cache_get_value_name_int(0, "facMemId", playerMember);
    cache_get_value_name_int(0, "facLeadId", playerLeader);
    cache_get_value_name_int(0, "sqlid", playerSQLID);

    if (playerMember != PlayerInfo[playerid][pMember] || playerLeader != PlayerInfo[playerid][pLeader])
    {
        SendClientMessage(playerid, COLOR_RED, "Igrac nije u tvojoj organizaciji! ");
        return 1;
    }

    mysql_fquery(g_SQL, 
        "UPDATE accounts SET spawnchange = '0', facMemId = 0, facLeadId = 0, facRank = 0 WHERE name = '%e'", 
        targetname
    );

    mysql_fquery(g_SQL, "DELETE FROM player_weapons WHERE player_id = '%d'", playerSQLID);

    format(string, sizeof(string), "[ ! ] Uspjesno ste izbacili igraca %s", targetname);
    SendClientMessage(playerid, COLOR_GREEN, string);
    return 1;
}

forward OnFactionMembersList(playerid);
public OnFactionMembersList(playerid)
{
    if (!cache_num_rows())
    {
        SendClientMessage(playerid, COLOR_RED, "[ ! ] Nema nikoga u trazenoj organizaciji!");
        return 1;
    }

    new
        memberName[MAX_PLAYER_NAME],
        memberRank;

    SendClientMessage(playerid, COLOR_LIGHTBLUE, "*__________________________[SVI CLANOVI]__________________________*");
    for (new row = 0; row < cache_num_rows(); row++)
    {
        cache_get_value_name( row, "name", memberName, 25);
        cache_get_value_name_int( row, "facRank", memberRank);
        va_SendClientMessage(playerid, COLOR_WHITE, "[IME]: %s | [RANK]: %d", memberName, memberRank);
    }
    return 1;
}

forward OnFactionCountings(playerid);
public OnFactionCountings(playerid)
{
    new num_rows = cache_num_rows();
    if (!num_rows)
    {
        SendClientMessage(playerid, COLOR_RED, "[ ! ] Nema nikoga u vasoj organizaciji!");
        return 1;
    }

    SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Stanje organizacije (%d/%d)", CountMembers(PlayerInfo[playerid][pMember]), num_rows);
    return 1;
}


/*
    ##     ##  #######   #######  ##    ##  ######  
    ##     ## ##     ## ##     ## ##   ##  ##    ## 
    ##     ## ##     ## ##     ## ##  ##   ##       
    ######### ##     ## ##     ## #####     ######  
    ##     ## ##     ## ##     ## ##  ##         ## 
    ##     ## ##     ## ##     ## ##   ##  ##    ## 
    ##     ##  #######   #######  ##    ##  ######  
*/

hook OnGameModeInit()
{
    CreateDynamic3DTextLabel("/buyweapon\n/buyarmour", COLOR_LIGHTBLUE, 296.000031, -38.203281, 1001.515625, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, 1, -1, 5.0);
    CreateDynamicPickup(1239, 1, 296.000031, -38.203281, 1001.515625, -1, 1, -1);
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new fid = PlayerInfo[playerid][pMember];
    switch (dialogid)
    {
        case DIALOG_AFACTIONC:
        {
            if (!response)
            {
                creatingFaction = 0;
                return 1;
            }
            new id = strval(inputtext);
            if (id < 1 || id > MAX_FACTIONS)
            {
                // TODO: don't hardcode limits in messages
                ShowPlayerDialog(playerid, DIALOG_AFACTIONC, DIALOG_STYLE_INPUT, "Unos ID-a", "NEDOZVOLJEN ID! \nUnesi ID na kojem ce organizacija da bude.\nDozvoljeni IDovi: 1-20", "Next", "Abort");
                return 1;
            }
            id--;
            if (!IsFreeSlot(id))
            {
                // TODO: don't hardcode limits in messages
                ShowPlayerDialog(playerid, DIALOG_AFACTIONC, DIALOG_STYLE_INPUT, "Unos ID-a", "NEDOZVOLJEN ID - Vec zauzet! \nUnesi ID na kojem ce organizacija da bude.\nDozvoljeni IDovi: 1-20", "Next", "Abort");
                return 1;
            }

            creatingInfoId[playerid] = id;
            ShowPlayerDialog(playerid, DIALOG_AFACTIONN, DIALOG_STYLE_INPUT, "Unos imena organizacije", "Unesi Zeljeno ime za organizaciju (promjenjivo)", "Next", "Abort");
            va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Odabrao si ID %d!", id + 1);
            return 1;
        }
        case DIALOG_AFACTIONN:
        {
            if (!response)
            {
                creatingFaction = 0;
                return 1;
            }
            new fcid = creatingInfoId[playerid];
            if (fcid < 0 || fcid > MAX_FACTIONS-1)
            {
                SendClientMessage(playerid, COLOR_RED, "[ ! ] Invalidan ID fakcije!");
                return 1;
            }
            FactionInfo[fcid][fID]      = fcid;
            // TODO: strcpy
            format(FactionInfo[fcid][fName], 24, "%s", inputtext);
            FactionInfo[fcid][fUsed]    = 1;
            FactionInfo[fcid][fRanks]   = 6;
            FactionInfo[fcid][fFactionBank] = 0;

            SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Kreirao si fakciju pod IDom %d sa imenom '%s'!",
                creatingInfoId[playerid] + 1,
                FactionInfo[fcid][fName]
            );
            creatingFaction = 0;

            SaveFaction(fcid);
            Iter_Add(Factions, fcid);
            return 1;
        }
        case DIALOG_FDELETE:
        {
            if (!response)
            {
                deletingFaction[playerid] = -1;
                return 1;
            }
            DeleteFaction(deletingFaction[playerid]);
            deletingFaction[playerid] = -1;

            SendClientMessage(playerid, COLOR_RED, "[ ! ] Uspjesno si obrisao fakciju!");
            return 1;
        }
        case DIALOG_SWATS:
        {
            if (!response)
            {
                return 1;
            }

            switch (listitem)
            {
                case 0:
                {
                    SetPlayerArmour(playerid, 150.0);
                    SetPlayerSkin(playerid, 285);
                    SendClientMessage(playerid,COLOR_LIGHTBLUE,"Uzeo si SWAT Skin!");
                }
                case 1:
                {
                    SetPlayerArmour(playerid, 150.0);
                    SetPlayerSkin(playerid, 287);
                    SendClientMessage(playerid,COLOR_LIGHTBLUE,"Uzeo si Army Skin!");
                }
            }
            return 1;
        }
        case DIALOG_FACTION_PICK:
        {
            if (!response)
            {
                return 1;
            }

            switch (listitem)
            {
                case 0: // info
                {
                    va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Trenutni iznos na %s Faction Banku: %d$", FactionInfo[fid][fName], FactionInfo[fid][fFactionBank]);
                    return 1;
                }
                case 1: // deposit
                {
                    ShowPlayerDialog(playerid, DIALOG_FACTION_DEPOSIT, DIALOG_STYLE_INPUT, "Faction Bank", "Molimo Vas unesite iznos koji zelite staviti u Faction Bank", "Input", "Exit");
                }
                case 2: // withdraw
                {
                    ShowPlayerDialog(playerid, DIALOG_FACTION_WITHDRAW, DIALOG_STYLE_INPUT, "Faction Bank", "Molimo Vas unesite iznos koji zelite podici iz Faction Banka", "Input", "Exit");
                }
            }
            return 1;
        }
        case DIALOG_FACTION_DEPOSIT:
        {
            if (!response)
            {
                ShowPlayerDialog(playerid, DIALOG_FACTION_PICK, DIALOG_STYLE_LIST, "Faction Bank", "Info\nStavi novce u Faction Bank\nPodigni novce iz Faction Banka", "Choose", "Exit");
                return 1;
            }

            new money = strval(inputtext);
            if (money < 1) return SendClientMessage(playerid, COLOR_RED, "Ne mozete staviti/povuci manje od 1$ iz faction banka!");
            if (money > AC_GetPlayerMoney(playerid)) return SendClientMessage(playerid, COLOR_RED, "Nemate toliko novaca u ruci da bi ih mogli staviti u Faction Bank!");

            PlayerToFactionMoney( playerid, FactionInfo[fid][fType], money); // Stavljanje novca u organizaciju
            va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Uspjesno ste stavili %d$ na %s Faction Bank.", money, FactionInfo[fid][fName]);

            #if defined MODULE_LOGS
            Log_Write("logfiles/faction_bank.txt", "(%s) Leader %s[%s](SQLID:%d) deposited %d$ in Faction Bank.",
                ReturnDate(),
                GetName(playerid),
                FactionInfo[fid][fName],
                PlayerInfo[playerid][pSQLID],
                money
            );
            #endif
            return 1;
        }
        case DIALOG_FACTION_WITHDRAW:
        {
            new money = strval(inputtext);
            if (money < 1) return SendClientMessage(playerid, COLOR_RED, "Ne mozete staviti/povuci manje od 1$ iz faction banka!");
            if (money > FactionInfo[fid][fFactionBank]) return SendClientMessage(playerid, COLOR_RED, "Uneseni iznos je veci od trenutnog na faction banki!");

            FactionToPlayerMoney( playerid, FactionInfo[fid][fType], money); // Podizanje novca iz org
            va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Uspjesno ste podigli %d$ sa %s Faction Banka.", money, FactionInfo[fid][fName]);

            #if defined MODULE_LOGS
            Log_Write("logfiles/faction_bank.txt", "(%s) Leader %s[%s](SQLID:%d) withdrawed %d$ from Faction Bank.",
                ReturnDate(),
                GetName(playerid),
                FactionInfo[fid][fName],
                PlayerInfo[playerid][pSQLID],
                money
            );
            #endif
            return 1;
        }
    }
    return 0;
}


/*
     ######  ##     ## ########  
    ##    ## ###   ### ##     ## 
    ##       #### #### ##     ## 
    ##       ## ### ## ##     ## 
    ##       ##     ## ##     ## 
    ##    ## ##     ## ##     ## 
     ######  ##     ## ########  
*/

// TODO: refactor this
CMD:afaction(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] < 1337)
    {
        SendClientMessage(playerid, COLOR_RED, "Niste ovlasteni za koristenje ove komande.");
        return 1;
    }

    new option[16], otext[128], string[1024];
    if (sscanf(params, "s[16]",option))
    {
        SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction [OPCIJA]");
        SendClientMessage(playerid, COLOR_RED, "[ ! ] create, list, type, changename, ranks, rankname, checkranks");
        SendClientMessage(playerid, COLOR_RED, "[ ! ] delete, makeleader, removeleader, checkonline, save");
        return 1;
    }

    if (!strcmp(option, "create", true))
    {
        // TODO: make it a per-player variable and just use the input faction ID like EditingFactionID[playerid]
        // Remove this check and setting of this variable and place it in DIALOG_AFACTIONC where the ID is input
        if (creatingFaction == 1) return SendClientMessage(playerid, COLOR_RED, "Vec netko pravi organizaciju!");

        // TODO: remove hardcoded limit, use va_ShowPlayerDialog
        ShowPlayerDialog(playerid, DIALOG_AFACTIONC, DIALOG_STYLE_INPUT, "Unos ID-a", "Unesi ID na kojem ce organizacija da bude.\nDozvoljeni IDovi: 1-20", "Next", "Abort");
        creatingFaction = 1;
        return 1;
    }
    else if (!strcmp(option, "delete", true))
    {
        new fid;
        if (sscanf(params, "s[16]i", option, fid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction delete [ID]");
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");
        fid--;
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");

        va_ShowPlayerDialog(playerid, DIALOG_FDELETE, DIALOG_STYLE_MSGBOX, "Obrisi fakciju", "Jesi li siguran da zelis obrisati organizaciju iz slota ID "COL_WHITE"%d (%s)"COL_DEFAULT"?", "Yes", "No", fid+1, FactionInfo[fid][fName]);
        // TODO: EditingFactionID
        deletingFaction[playerid] = fid;
        return 1;
    }
    else if (!strcmp(option, "checkonline", true))
    {
        new fid, name[MAX_PLAYER_NAME];
        if (sscanf(params, "s[16]i", option, fid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction checkoline [ID]");
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");
        fid--;
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");

        SendClientMessage(playerid, COLOR_WHITE, "");
        format(string, sizeof(string), "Online clanovi organizacije ID %d - %s", fid+1, FactionInfo[fid][fName]);
        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

        foreach(new i : Player)
        {
            if (PlayerInfo[i][pMember] == fid)
            {
                GetPlayerName(i, name, sizeof(name));
                format(string, sizeof(string), "%s, %s (( Rank: %d))", name, ReturnPlayerRankName(i), PlayerInfo[i][pRank]);
                SendClientMessage(playerid, COLOR_WHITE, string);
            }
        }
        SendClientMessage(playerid, COLOR_WHITE, "");
        return 1;
    }
    else if (!strcmp(option, "list", true))
    {
        new
            tip[16],
            count = 0;
        foreach(new i : Factions)
        {
            // TODO: extract to helper function, GetFactionName(factionid)
            if (FactionInfo[i][fType] == FACTION_TYPE_NONE)      { tip = "Nema"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_LAW)       { tip = "Law1"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_LAW2)      { tip = "Law2"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_FD)        { tip = "Medic"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_LEGAL)     { tip = "Legalna"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_MAFIA)     { tip = "Mafija"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_GANG)      { tip = "Banda"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_RACERS)    { tip = "Racer"; }
            if (FactionInfo[i][fType] == FACTION_TYPE_NEWS)      { tip = "News"; }

            if (FactionInfo[i][fUsed] != 0)
            {
                // TODO: choose, shall you display the Faction SQLID, or some human-friendly ID from 1..N or
                // the internal script (FactionInfo array) ID 0..N-1 and then use that throughout.
                // For better player experience just use normalised ID's from 1..N (personal opinion).
                format(otext, sizeof(otext), ""COL_DEFAULT"ID: "COL_WHITE"%d"COL_DEFAULT"Ime: "COL_WHITE"%s"COL_DEFAULT"-- Tip: %s\n", i+1, FactionInfo[i][fName], tip);
            }
            else
            {
                format(otext, sizeof(otext), "ID: %d Nije iskoristeno\n", i+1);
            }
            strcat(string, otext, sizeof(string));
            count++;
        }
        if (!count)
        {
            SendClientMessage(playerid, COLOR_RED, "Nema kreiranih fakcija!");
            return 1;
        }
        ShowPlayerDialog(playerid, DIALOG_FLIST, DIALOG_STYLE_MSGBOX, "Fakcije", string, "Close", "");
        return 1;
    }
    else if (!strcmp(option, "type", true))
    {
        // TODO: refactor this whole thing, make a generic type function which gets types from SQLID database
        // fetch the type names, list them
        new type, fid;
        if (sscanf(params, "s[16]ii", option, fid, type))
        {
            SendClientMessage(playerid, COLOR_WHITE, "[ ? ]: /afaction type [ID] [TIP FAKCIJE] ");
            SendClientMessage(playerid, COLOR_WHITE, "Tipovi: 1 - Law, 2 - FireDept, 3 - Legalna, 4 - Mafija, 5 - Banda, 6 - Raceri, 7 - News, 8 - Law2");
            return 1;
        }
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");
        if (type < 1 || type > 9) return SendClientMessage(playerid, COLOR_RED, "Tipovi su od 1-7.");
        fid--;
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");

        // TODO: make another helper function for this, make an array of faction names and print it out once,
        // don't repeat yourself!
        FactionInfo[fid][fType] = type;
        switch (type)
        {
            case FACTION_TYPE_LAW:    SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na law1!");
            case FACTION_TYPE_FD:     SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na firedept!");
            case FACTION_TYPE_LEGAL:  SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na legalnu!");
            case FACTION_TYPE_MAFIA:  SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na mafija!");
            case FACTION_TYPE_GANG:   SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na banda!");
            case FACTION_TYPE_RACERS: SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na raceri!");
            case FACTION_TYPE_NEWS:   SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na News!");
            case FACTION_TYPE_LAW2:   SendClientMessage(playerid, COLOR_RED, "[ ! ] Promijenio si tip fakcije na law2!");
        }

        mysql_fquery(g_SQL, "UPDATE server_factions SET type = '%d' WHERE id = '%d'",
            FactionInfo[fid][fType],
            FactionInfo[fid][fID]
        );
        return 1;
    }
    else if (!strcmp(option, "changename", true))
    {
        new newname[64], fid;
        if (sscanf(params, "s[16]is[64]", option, fid, newname)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction changename [ID] [NOVO IME]");
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");
        fid--;
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");
        // TODO: strcpy
        format(FactionInfo[fid][fName],24,"%s",newname);
        SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Promjenio si ime fakcije ID %d na %s.", fid+1, newname);

        mysql_fquery(g_SQL, "UPDATE server_factions SET name = '%e' WHERE id = '%d'", 
            newname, 
            FactionInfo[fid][fID]
        );
        return 1;
    }
    else if (!strcmp(option, "ranks", true))
    {
        new ranks, fid;
        if (sscanf(params, "s[16]ii", option, fid, ranks)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction ranks [ID] [Broj rankova (1-15)]");
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");
        FactionInfo[fid][fRanks] = ranks;
        SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Promjenio si broj rankova fakcije ID %d na %d.", fid+1, ranks);

        mysql_fquery(g_SQL, "UPDATE server_factions SET ranks = '%d' WHERE id = '%d'",
            FactionInfo[fid][fRanks],
            FactionInfo[fid][fID]
        );
        return 1;
    }
    else if (!strcmp(option, "makeleader", true))
    {
        new targetid, fid;
        if (sscanf(params, "s[16]ui", option, targetid, fid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction makeleader [ID/Dio Imena] [ID Organizacije]");
        if (targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID igraca!");
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");

        fid--;
        PlayerInfo[targetid][pLeader]   = fid;
        PlayerInfo[targetid][pMember]   = fid;
        PlayerInfo[targetid][pRank]     = FactionInfo[fid][fRanks];

        #if defined MODULE_LOGS
        Log_Write("/logfiles/orgs_leader.txt", "(%s) %s(%s) made %s(%s) the leader of faction %s.",
            ReturnDate(),
            GetName(playerid, false),
            GetPlayerIP(playerid),
            GetName(targetid, false),
            GetPlayerIP(targetid),
            FactionInfo[fid][fName]
        );
        #endif

        mysql_fquery(g_SQL, "UPDATE accounts SET facLeadId = '%d', facMemId = '%d', facRank = '%d' WHERE sqlid = '%d'",
            PlayerInfo[targetid][pLeader],
            PlayerInfo[targetid][pMember],
            PlayerInfo[targetid][pRank],
            PlayerInfo[targetid][pSQLID]
        );

        format(otext, sizeof(otext), "%s je postao lider %s", GetName(playerid, false), FactionInfo[fid][fName]);
       
        mysql_fquery(g_SQL, "INSERT INTO faction_logs(faction_id, log_text, time) VALUES ('%d','%e',NOW())",
            FactionInfo[fid][fID],
            otext
        );

        va_SendClientMessage(playerid, COLOR_LIGHTBLUE, "Postavio si %s (ID: %d) za lidera organizacije ID %d (%s).", GetName(targetid, true), targetid, fid, FactionInfo[fid][fName]);
        va_SendClientMessage(targetid, COLOR_LIGHTBLUE, "Postavljen si za lidera organizacije %s od strane Admina %s.", FactionInfo[fid][fName], GetName(playerid, true));
        return 1;
    }
    else if (!strcmp(option, "removeleader", true))
    {
        new targetid;
        if (sscanf(params, "s[16]u", option, targetid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction removeleader [ID/Dio Imena]");
        if (targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID igraca!");
        if (PlayerInfo[targetid][pLeader] == 0) return SendClientMessage(playerid, COLOR_RED, "Taj igrac nije lider!");

        mysql_fquery(g_SQL, "UPDATE accounts SET facLeadId = '0', facMemId = '0', facRank = '0' WHERE sqlid = '%d'", 
            PlayerInfo[targetid][pSQLID]
        );

        #if defined MODULE_LOGS
        Log_Write("/logfiles/orgs_leader.txt", "(%s) %s(%s) removed %s(%s) the leader of faction %s status.",
            ReturnDate(),
            GetName(playerid, false),
            GetPlayerIP(playerid),
            GetName(targetid, false),
            GetPlayerIP(targetid),
            FactionInfo[PlayerInfo[targetid][pMember]][fName]
        );
        #endif

        PlayerInfo[targetid][pLeader] = 0;
        PlayerInfo[targetid][pMember] = 0;
        PlayerInfo[targetid][pRank]   = 0;

        va_SendClientMessage(playerid, COLOR_LIGHTBLUE, "Skinuo si %s sa lidera organizacije.", GetName(targetid, true));
        va_SendClientMessage(targetid, COLOR_LIGHTBLUE, "Skinut si sa lidera organizacije od strane Admina %s.", GetName(playerid, true));
        return 1;
    }
    else if (!strcmp(option, "rankname", true))
    {
        new rankid, rankname[24], fid;
        if (sscanf(params, "s[16]iis[24]", option, fid, rankid, rankname))
        {
            SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction rankname [ID] [Broj ranka (1-11)] [Ime ranka]");
            return 1;
        }
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");
        fid--;
        // TODO: doing len is pointless as sscanf will cutoff the string at 23 characters
        new rankname_len = strlen(rankname);
        if (rankname_len < 1 || rankname_len > 24) return SendClientMessage(playerid, COLOR_RED, "Prevelik ili premal broj slova!");
        if (rankid < 1 || rankid > FactionInfo[fid][fRanks]) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID ranka!");
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");

        // TODO: extract into a function which gets the rank name given the rank index
        if (rankid == 1) { format(FactionInfo[fid][fRankName1],24,"%s",rankname); }
        if (rankid == 2) { format(FactionInfo[fid][fRankName2],24,"%s",rankname); }
        if (rankid == 3) { format(FactionInfo[fid][fRankName3],24,"%s",rankname); }
        if (rankid == 4) { format(FactionInfo[fid][fRankName4],24,"%s",rankname); }
        if (rankid == 5) { format(FactionInfo[fid][fRankName5],24,"%s",rankname); }
        if (rankid == 6) { format(FactionInfo[fid][fRankName6],24,"%s",rankname); }
        if (rankid == 7) { format(FactionInfo[fid][fRankName7],24,"%s",rankname); }
        if (rankid == 8) { format(FactionInfo[fid][fRankName8],24,"%s",rankname); }
        if (rankid == 9) { format(FactionInfo[fid][fRankName9],24,"%s",rankname); }
        if (rankid == 10) { format(FactionInfo[fid][fRankName10],24,"%s",rankname); }
        if (rankid == 11) { format(FactionInfo[fid][fRankName11],24,"%s",rankname); }
        if (rankid == 12) { format(FactionInfo[fid][fRankName12],24,"%s",rankname); }
        if (rankid == 13) { format(FactionInfo[fid][fRankName13],24,"%s",rankname); }
        if (rankid == 14) { format(FactionInfo[fid][fRankName14],24,"%s",rankname); }
        if (rankid == 15) { format(FactionInfo[fid][fRankName15],24,"%s",rankname); }

        mysql_fquery(g_SQL, "UPDATE server_factions SET rank%d = '%e' WHERE id = '%d'", 
            rankid, 
            rankname, 
            FactionInfo[fid][fID]
        );

        format(string, sizeof(string), "[ ! ] Promjenio si ime ranka fakcije ID %d (ID RANKA: %d) na %s.", fid+1, rankid, rankname);
        SendClientMessage(playerid, COLOR_RED, string);
        return 1;
    }
    else if (!strcmp(option, "checkranks", true))
    {
        new fid;
        if (sscanf(params, "s[16]i", option, fid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /afaction checkranks [ID fakcije]");
        if (fid < 1 || fid > MAX_FACTIONS) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID fakcije");
        fid--;
        if (IsFreeSlot(fid)) return SendClientMessage(playerid, COLOR_RED, "Na tom slotu nije kreirana fakcija!");

        // TODO: va_ShowPlayerDialog
        // TODO: extract into a function and refactor FactionInfo rankNames
        format(string, sizeof(string), "Rankovi fakcije ID %d\n\nRank 1: %s\nRank 2: %s\nRank 3: %s\nRank 4: %s\nRank 5: %s\n\
Rank 6: %s\nRank 7: %s\nRank 8: %s\nRank 9: %s\nRank 10: %s\nRank 11: %s\nRank 12: %s\nRank 13: %s\nRank 14: %s\nRank 15: %s",
            fid+1,
            FactionInfo[fid][fRankName1],
            FactionInfo[fid][fRankName2],
            FactionInfo[fid][fRankName3],
            FactionInfo[fid][fRankName4],
            FactionInfo[fid][fRankName5],
            FactionInfo[fid][fRankName6],
            FactionInfo[fid][fRankName7],
            FactionInfo[fid][fRankName8],
            FactionInfo[fid][fRankName9],
            FactionInfo[fid][fRankName10],
            FactionInfo[fid][fRankName11],
            FactionInfo[fid][fRankName12],
            FactionInfo[fid][fRankName13],
            FactionInfo[fid][fRankName14],
            FactionInfo[fid][fRankName15]
        );
        ShowPlayerDialog(playerid, DIALOG_RLIST, DIALOG_STYLE_MSGBOX, "Rankovi", string, "Close", "");
        return 1;
    }
    return 1;
}

CMD:faction(playerid, params[])
{
    new option[16], string[256];

    if (!PlayerInfo[playerid][pMember])
    {
        SendClientMessage(playerid, COLOR_RED, "Nisi clan organizacije!");
        return 1;
    }
    if (sscanf(params, "s[16]", option))
    {
        SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction [OPCIJA]");
        if (PlayerInfo[playerid][pLeader] != 0)
        {
            SendClientMessage(playerid, COLOR_RED, "[ ! ] invite - uninvite - setrank - blockchat - uninviteex - allmembers - permissions - resetcars - skin");
        }
        SendClientMessage(playerid, COLOR_RED, "[ ! ] members - counts - bank");
        return 1;
    }

    if (!strcmp(option, "invite", true))
    {
        new targetid;
        if (!PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        if (sscanf(params, "s[16]u", option, targetid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction invite [ID/DioImena]");
        if (targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID igraca!");
        if (PlayerInfo[targetid][pMember] != 0) return SendClientMessage(playerid, COLOR_RED, "Taj igrac je vec u nekoj organizaciji!");

        PlayerInfo[targetid][pMember] = PlayerInfo[playerid][pLeader];
        PlayerInfo[targetid][pRank]   = 1;

        if (IsACop(targetid) || IsASD(targetid) || IsFDMember(targetid))
        {
            RemovePlayerJob(targetid);
        }

        mysql_fquery(g_SQL, "UPDATE accounts SET facMemId = '%d', facRank = '%d' WHERE sqlid = '%d'",
            PlayerInfo[targetid][pMember],
            PlayerInfo[targetid][pRank],
            PlayerInfo[targetid][pSQLID]
        );

        new logText[100];
        format(logText, sizeof(logText), "%s je pozvao %s u %s", GetName(playerid,false), GetName(targetid,false), FactionInfo[PlayerInfo[targetid][pMember]][fName]);
        
        mysql_fquery(g_SQL, "INSERT INTO faction_logs(faction_id, log_text, time) VALUES ('%d','%e',NOW())",
            PlayerInfo[targetid][pMember],
            logText
        );
        #if defined MODULE_LOGS
        Log_Write("/logfiles/orgs_invite.txt", "(%s) %s(%s) invited %s(%s) to join %s.", GetName(playerid,false), GetPlayerIP(playerid), GetName(targetid,false), GetPlayerIP(targetid), FactionInfo[PlayerInfo[playerid][pMember]][fName]);
        #endif

        va_SendClientMessage(targetid, COLOR_LIGHTBLUE, "Dodan si u organizaciju %s od strane lidera %s.",
            FactionInfo[ PlayerInfo[playerid][pLeader] ][fName], GetName(playerid, true));
        va_SendClientMessage(playerid, COLOR_LIGHTBLUE, "Dodao si %s u organizaciju.", GetName(targetid, true));
        return 1;
    }
    else if (!strcmp(option, "permissions", true))
    {
        new
            rnk,
            cmdname[16],
            mmbr = PlayerInfo[playerid][pMember];
        if (!PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        if (sscanf(params, "s[16]s[16]d", option, cmdname, rnk))
        {
            SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction permissions [komanda][rank]");
            switch (FactionInfo[mmbr][fType])
            {
                case FACTION_TYPE_LAW:
                {
                    SendClientMessage(playerid, COLOR_GREY, "[KOMANDE]: siren - cargun - carsign - (a)buygun - aswat - (a)undercover");
                    SendClientMessage(playerid, COLOR_GREY, "[KOMANDE]:(a)govrepair - unfree - cleartrunk - listennumber");
                }
                case FACTION_TYPE_FD:
                {
                    SendClientMessage(playerid, COLOR_GREY, "[KOMANDE]: siren - carsign - govrepair - agovrepair");
                }
                case FACTION_TYPE_RACERS:
                {
                    SendClientMessage(playerid, COLOR_GREY, "[KOMANDE]: race");
                }
            }
            return 1;
        }

        if (isnull(cmdname)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste postavili komandu!");
        if (rnk > FactionInfo[mmbr][fRanks] || rnk < 0) return SendClientMessage(playerid, COLOR_RED, "Ne postoji taj rank u fakciji!");

        new bool:found = true;
        switch (FactionInfo[mmbr][fType])
        {
            case FACTION_TYPE_LAW:
            {
                if (!strcmp(cmdname, "siren", true))
                    FactionInfo[mmbr][rSiren] = rnk;
                else if (!strcmp(cmdname, "cargun", true))
                    FactionInfo[mmbr][rCarGun] = rnk;
                else if (!strcmp(cmdname, "carsign", true))
                    FactionInfo[mmbr][rCarSign] = rnk;
                else if (!strcmp(cmdname, "abuygun", true))
                    FactionInfo[mmbr][rABuyGun] = rnk;
                else if (!strcmp(cmdname, "buygun", true))
                    FactionInfo[mmbr][rBuyGun] = rnk;
                else if (!strcmp(cmdname, "aswat", true))
                    FactionInfo[mmbr][rASwat] = rnk;
                else if (!strcmp(cmdname, "govrepair", true))
                    FactionInfo[mmbr][rGovRepair] = rnk;
                else if (!strcmp(cmdname, "agovrepair", true))
                    FactionInfo[mmbr][rAGovRepair] = rnk;
                else if (!strcmp(cmdname, "unfree", true))
                    FactionInfo[mmbr][rUnFree] = rnk;
                else if (!strcmp(cmdname, "cleartrunk", true))
                    FactionInfo[mmbr][rClrTrunk] = rnk;
                else if (!strcmp(cmdname, "listennumber", true))
                    FactionInfo[mmbr][rLstnNumber] = rnk;
                else if (!strcmp(cmdname, "undercover", true))
                    FactionInfo[mmbr][rUndercover] = rnk;
                else if (!strcmp(cmdname, "aundercover", true))
                    FactionInfo[mmbr][rAUndercover] = rnk;
                else if (!strcmp(cmdname, "listensms", true))
                    FactionInfo[mmbr][rLstnSMS] = rnk;
                else found = false;
            }
            case FACTION_TYPE_FD:
            {
                if (!strcmp(cmdname, "siren", true))
                    FactionInfo[mmbr][rSiren] = rnk;
                else if (!strcmp(cmdname, "carsign", true))
                    FactionInfo[mmbr][rCarSign] = rnk;
                else if (!strcmp(cmdname, "govrepair", true))
                    FactionInfo[mmbr][rGovRepair] = rnk;
                else if (!strcmp(cmdname, "agovrepair", true))
                    FactionInfo[mmbr][rAGovRepair] = rnk;
                else found = false;
            }
            case FACTION_TYPE_RACERS:
            {
                if (!strcmp(cmdname, "race", true))
                    FactionInfo[mmbr][rRace] = rnk;
                else found = false;
            }
        }

        if (!found) 
            return SendFormatMessage(playerid, MESSAGE_TYPE_ERROR, "Komanda %s ne postoji u permisijama!", cmdname);

        va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Postavio si komandu %s na rank %d.", cmdname, rnk);

        mysql_fquery(g_SQL, "UPDATE server_factions_permissions SET %e = '%d' WHERE server_factions_permissions.id = '%d'",
            cmdname,
            rnk,
            mmbr
        );
        return 1;
    }
    else if (!strcmp(option, "uninvite", true))
    {
        new playername[MAX_PLAYER_NAME], targetname[MAX_PLAYER_NAME], targetid;
        if (PlayerInfo[playerid][pLeader] == 0) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        if (sscanf(params, "s[16]u", option, targetid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction uninvite [ID/DioImena]");
        if (targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID igraca!");
        if (PlayerInfo[targetid][pMember] != PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Taj igrac nije u tvojoj organizaciji!");

        GetPlayerName(playerid, playername, sizeof(playername));
        GetPlayerName(targetid, targetname, sizeof(targetname));

        if (IsACop(targetid) || IsASD(targetid) || IsFDMember(targetid) || IsAGov(targetid))
        {
            AC_ResetPlayerWeapons(targetid);
        }

        PlayerInfo[targetid][pMember] = 0;
        PlayerInfo[targetid][pRank] = 0;
        PlayerInfo[playerid][pRadio] = 0;
        PlayerInfo[playerid][pRadioSlot] = 0;

        if (IsACop(targetid) || IsFDMember(targetid))
        {
            AC_ResetPlayerWeapons(targetid);
            SetPlayerSkin(playerid,299);
            PlayerObject[playerid][0][poModelid] = 0;
            PlayerObject[playerid][1][poModelid] = 0;
            PlayerObject[playerid][2][poModelid] = 0;
            PlayerObject[playerid][3][poModelid] = 0;
            PlayerObject[playerid][4][poModelid] = 0;
            PlayerObject[playerid][5][poModelid] = 0;
            PlayerObject[playerid][6][poModelid] = 0;
            PlayerInfo[playerid][pSkin] = 299;
        }

        mysql_fquery(g_SQL, "UPDATE accounts SET facMemId = '0', facRank = '0' WHERE sqlid = '%d'",
            PlayerInfo[targetid][pSQLID]
        );

        new logText[100];
        format(logText, sizeof(logText), "%s je izbacio %s iz %s", GetName(playerid,false), GetName(targetid,false), FactionInfo[ PlayerInfo[playerid][pLeader] ][fName]);
        mysql_fquery(g_SQL, "INSERT INTO faction_logs(faction_id, log_text, time) VALUES ('%d','%e',NOW())",
            PlayerInfo[playerid][pLeader],
            logText
        );

        mysql_fquery(g_SQL, "DELETE FROM accounts WHERE sqlid = '%d'",
            PlayerInfo[targetid][pRadio],
            PlayerInfo[targetid][pRadioSlot],
            PlayerInfo[targetid][pSQLID]
        );

        #if defined MODULE_LOGS
        Log_Write("/logfiles/orgs_invite.txt", "(%s) %s(%s) kicked out %s(%s) from %s.", GetName(playerid,false), GetPlayerIP(playerid), GetName(targetid,false), GetPlayerIP(targetid), FactionInfo[PlayerInfo[playerid][pMember]][fName]);
        #endif

        new fid = PlayerInfo[playerid][pLeader];
        va_SendClientMessage(targetid, COLOR_RED, "[ ! ] Izbacen si iz organizacije %s od strane lidera %s.", FactionInfo[fid][fName], GetName(playerid, true));
        va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Izbacio si %s iz organizacije.", targetname);
        return 1;
    }
    else if (!strcmp(option, "setrank", true))
    {
        new playername[MAX_PLAYER_NAME], targetname[MAX_PLAYER_NAME], targetid, rank;
        if (PlayerInfo[playerid][pLeader] == 0) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        if (sscanf(params, "s[16]ui", option, targetid, rank)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction setrank [ID/DioImena] [Broj ranka]");
        if (targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID igraca!");
        if (PlayerInfo[targetid][pMember] != PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Taj igrac nije u tvojoj organizaciji!");
        if (rank < 1 || rank > FactionInfo[PlayerInfo[playerid][pLeader]][fRanks]) return SendClientMessage(playerid, COLOR_RED, "Nepravilan rank!");

        GetPlayerName(playerid, playername, sizeof(playername));
        GetPlayerName(targetid, targetname, sizeof(targetname));
        PlayerInfo[targetid][pRank] = rank;

        #if defined MODULE_LOGS
        Log_Write("/logfiles/orgs_invite.txt", "(%s) %s(%s) gave %s(%s) Rank %d in faction %s.", GetName(playerid,false), GetPlayerIP(playerid), GetName(targetid,false), GetPlayerIP(targetid), rank, FactionInfo[PlayerInfo[playerid][pMember]][fName]);
        #endif

        mysql_fquery(g_SQL, "UPDATE accounts SET facRank = '%d' WHERE sqlid = '%d'",
            PlayerInfo[targetid][pRank],
            PlayerInfo[targetid][pSQLID]
        );

        new
            logText[100];
        format(logText, sizeof(logText), "%s je stavio %s rank %d", GetName(playerid,false), GetName(targetid,false), PlayerInfo[targetid][pRank]);
        mysql_fquery(g_SQL, "INSERT INTO faction_logs(faction_id, log_text, time) VALUES ('%d','%e',NOW())",
            PlayerInfo[playerid][pLeader],
            logText
        );

        va_SendClientMessage(targetid, COLOR_LIGHTBLUE, "Postavljen ti je Rank (%s)[%d] na organizaciji %s od strane %s %s.",
            ReturnPlayerRankName(targetid),
            rank,
            FactionInfo[PlayerInfo[playerid][pLeader]][fName],
            ReturnPlayerRankName(playerid),
            GetName(playerid, true)
        );
        va_SendClientMessage(playerid, COLOR_LIGHTBLUE, "Postavio si %s Rank (%s)[%d].",
            targetname,
            ReturnPlayerRankName(playerid),
            rank
        );
        return 1;
    }
    else if (!strcmp(option, "members", true))
    {
        new fid, name[MAX_PLAYER_NAME];
        fid = PlayerInfo[playerid][pMember];

        SendClientMessage(playerid, COLOR_WHITE, "");
        format(string, sizeof(string), "Online clanovi organizacije ID %d - %s", fid+1, FactionInfo[fid][fName]);
        SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

        // TODO: extract this to a helper function getting all the online/offline members of a faction
        foreach(new i : Player)
        {
            if (PlayerInfo[i][pMember] != fid)
            {
                continue;
            }

            GetPlayerName(i, name, sizeof(name));
            // TODO: use defines
            if (fid == 1 || fid == 2 || fid == 5)
            {
                va_SendClientMessage(playerid, COLOR_WHITE, "%s, %s (( Rank: %d[S:%d] | %s))",
                    name,
                    ReturnPlayerRankName(i),
                    PlayerInfo[i][pRank],
                    PlayerInfo[i][pLawDuty],
                    GetPlayerStreet(i)
                );
            }
            else
            {
                va_SendClientMessage(playerid, COLOR_WHITE, "%s, %s (( Rank: %d))",
                    name,
                    ReturnPlayerRankName(i),
                    PlayerInfo[i][pRank]
                );
            }
        }
        SendClientMessage(playerid, COLOR_WHITE, "");
        return 1;
    }
    else if (!strcmp(option, "blockchat", true))
    {
        new fid = PlayerInfo[playerid][pLeader];
        if (!fid) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");

        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, sizeof(name));

        format(string, sizeof(string), "[ ! ] Lider %s je %s chat organizacije!",
            (blockfam[fid]) ? ("upalio") : ("ugasio"),
            name
        );
        SendFactionMessage(fid, COLOR_RED, string);
        blockfam[fid] ^= 1; // toggle
        return 1;
    }
    else if (!strcmp(option, "uninviteex", true))
    {
        if (!PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");

        new targetname[MAX_PLAYER_NAME];
        if (sscanf(params, "s[16]s[24]", option, targetname)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction uninviteex [ime]");
        if (!IsValidNick(targetname)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate unijeti roleplay nick!");

        mysql_tquery(g_SQL, 
            va_fquery(g_SQL, "SELECT sqlid, facMemId, facLeadId FROM accounts WHERE name = '%e'", targetname), 
            "UninvitePlayer", 
            "is", 
            playerid, 
            targetname
        );
        return 1;
    }
    else if (!strcmp(option, "allmembers", true))
    {
        if (!PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        
        mysql_tquery(g_SQL, 
            va_fquery(g_SQL,  "SELECT name, facRank FROM accounts WHERE facMemId = '%d' OR facLeadId = '%d'", 
                PlayerInfo[playerid][pLeader], 
                PlayerInfo[playerid][pLeader]
            ), 
            "OnFactionMembersList", 
            "i", 
            playerid
        );
        return 1;
    }
    else if (!strcmp(option, "counts", true))
    {
        mysql_tquery(g_SQL, 
            va_fquery(g_SQL, 
                "SELECT sqlid FROM accounts WHERE facMemId = '%d' OR facLeadId = '%d'", 
                PlayerInfo[playerid][pLeader], 
                PlayerInfo[playerid][pLeader]
            ), 
            "OnFactionCountings",
            "i", 
            playerid
        );
        return 1;
    }
    else if (!strcmp(option, "resetcars", true))
    {
        new fid = PlayerInfo[playerid][pLeader];
        if (!fid) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");

        foreach(new x : Vehicles[VEHICLE_USAGE_FACTION])
        {
            if (VehicleInfo[x][vFaction] == fid)
            {
                if (!IsVehicleOccupied(x))
                    SetVehicleToRespawn(x);
            }
        }
        SendClientMessage(playerid, COLOR_WHITE, "Respawnao si sva vozila u organizaciji!");
        return 1;
    }
    else if (!strcmp(option, "bank", true))
    {
        new fid = PlayerInfo[playerid][pLeader];
        if (!fid) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        if (!IsAtBank(playerid)) return SendClientMessage(playerid, COLOR_RED, "Morate biti u banci da bi ste mogli koristiti ovu komandu !");
        if (FactionInfo[fid][fType] != FACTION_TYPE_LAW && FactionInfo[fid][fType] != FACTION_TYPE_LAW2 && FactionInfo[fid][fType] != FACTION_TYPE_FD && FactionInfo[fid][fType] != FACTION_TYPE_NEWS)
        {
            SendMessage(playerid, MESSAGE_TYPE_ERROR, "Trebate biti Leader legalne fakcije da bi mogli upravljati faction bankom!");
            return 1;
        }

        ShowPlayerDialog(playerid, DIALOG_FACTION_PICK, DIALOG_STYLE_LIST, "Faction Bank", "Info\nStavi novce u Faction Bank\nPodigni novce iz Faction Banka", "Choose", "Exit");
        return 1;
    }
    else if (!strcmp(option, "skin", true))
    {
        new targetid, skin;
        if (!PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Da bi koristili ovu komandu morate biti lider!");
        if (sscanf(params, "s[16]ui", option, targetid, skin)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /faction skin [ID/DioImena] [ID SKINA]");
        if (PlayerInfo[targetid][pMember] != PlayerInfo[playerid][pLeader]) return SendClientMessage(playerid, COLOR_RED, "Taj igrac nije u tvojoj organizaciji!");
        if (targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Invalidan ID igraca!");

        SetPlayerSkin(targetid, skin);
        PlayerInfo[targetid][pSkin] = skin;
        PlayerInfo[targetid][pChar] = skin;

        PlayerToBudgetMoney(targetid, 300);
        mysql_fquery(g_SQL, "UPDATE accounts SET playaSkin = '%d' WHERE sqlid = '%d'", PlayerInfo[targetid][pChar], PlayerInfo[targetid][pSQLID]);
    }
    return 1;
}

CMD:f(playerid, params[])
{
    if (strlen(params) >= 64)
    {
        SendMessage(playerid,MESSAGE_TYPE_ERROR, "Predugacka poruka. Maksimalno 64 karaktera!");
        return 1;
    }

    new member = PlayerInfo[playerid][pMember], result[64], playername[MAX_PLAYER_NAME], string[256];
    if (member == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Moras biti clan organizacije da bi koristio ovu komandu!");
    if (blockfam[member] == 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Chat organizacije je blokiran!");
    if (!Bit1_Get(gr_FactionChatTog, playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Iskljucen vam je faction chat!");

    if (sscanf(params, "s[64]", result)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /f [TEKST]");

    new color = -1;
    if (IsACop(playerid))
        color = COLOR_COP;
    else if (IsASD(playerid))
        color = 0x219683AA;
    else
        color = 0xBDF2F2FF;

    GetPlayerName(playerid, playername, sizeof(playername));
    format(string, sizeof(string), "** %s (%d) %s: %s))", ReturnPlayerRankName(playerid), playerid, playername, result);
    SendFactionMessage(member, color, string);
    return 1;
}

CMD:togf(playerid, params[])
{
    Bit1_Set(gr_FactionChatTog, playerid, !Bit1_Get(gr_FactionChatTog, playerid));
    va_SendClientMessage(playerid, COLOR_RED, "[ ! ] %s vidjeti faction chat!",
        (Bit1_Get(gr_FactionChatTog, playerid)) ? ("Sada cete") : ("Vise necete")
    );
    return 1;
}

CMD:quitfaction(playerid, params[])
{
    if (PlayerInfo[playerid][pMember] > 0 || PlayerInfo[playerid][pLeader] > 0)
    {
        SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nisi u organizaciji!");
        return 1;
    }

    SendMessage(playerid, MESSAGE_TYPE_INFO, "Napustili ste organizaciju i sada ste civil.");

    if (10 <= PlayerInfo[playerid][pJob] <= 12)
    {
        PlayerInfo[playerid][pJob] = 0;
    }
    if (IsACop(playerid) || IsASD(playerid) || IsFDMember(playerid) || IsAGov(playerid))
    {
        AC_ResetPlayerWeapons(playerid);
    }

    mysql_fquery(g_SQL, "UPDATE accounts SET spawnchange = '0', facMemId = '0', facRank = '0', facLeadId = '0' WHERE sqlid = '%d'",
        PlayerInfo[playerid][pSQLID]
    );

    new logText[80];
    format(logText, sizeof(logText), "%s je izasao iz %s", GetName(playerid,false), FactionInfo[PlayerInfo[playerid][pLeader]][fName]);
    mysql_fquery(g_SQL, "INSERT INTO faction_logs(faction_id, log_text, time) VALUES ('%d','%e',NOW())",
        PlayerInfo[playerid][pMember],
        logText
    );

    #if defined MODULE_LOGS
    Log_Write("logfiles/faction_quit.txt", "(%s) Player %s quitted faction %s.",
        ReturnDate(),
        GetName(playerid, false),
        FactionInfo[PlayerInfo[playerid][pMember]][fName]
    );
    #endif

    PlayerInfo[playerid][pTeam]         = 3;
    PlayerInfo[playerid][pLeader]       = 0;
    PlayerInfo[playerid][pMember]       = 0;
    PlayerInfo[playerid][pRank]         = 0;
    PlayerInfo[playerid][pSkin]         = 60;
    PlayerInfo[playerid][pSpawnChange]  = 0;
    PlayerInfo[playerid][pRadio]        = 0;
    PlayerInfo[playerid][pRadioSlot]    = 0;
    return 1;
}

CMD:m(playerid, params[])
{
    // TODO: max client message is 144 (143 characters), unless this is circumvented by some split text functionality...
    new motd[256], playername[MAX_PLAYER_NAME];
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: (/m)egaphone [megaphone chat]");
    if (PlayerInfo[playerid][pMuted] == 1) return SendClientMessage(playerid, COLOR_RED, "Nemozete pricati, usutkani ste");

    GetPlayerName(playerid, playername, sizeof(playername));
    if (IsACop(playerid) || IsASD(playerid))
    {
        if (PlayerInfo[playerid][pMember] == 1 && PlayerInfo[playerid][pRank] < 1)
        {
            SendMessage(playerid, MESSAGE_TYPE_ERROR, "Suspendirani ste!");
            return 1;
        }

        if (IsPlayerInAnyVehicle(playerid))
        {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(playerid, x, y, z);

            foreach(new i : Player)
            {
                if (!IsPlayerInRangeOfPoint(i, 20.0, x, y, z)) continue;
                PlayerPlaySound(i, 15800, 0, 0, 0);
            }
        }
        format(motd, sizeof(motd), "[%s:o< %s]", playername, params);
        ProxDetector(60.0, playerid, motd,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
    }
    else if (IsFDMember(playerid) || IsAGov(playerid))
    {
        format(motd, sizeof(motd), "[%s:o< %s]", playername, params);
        ProxDetector(60.0, playerid, motd,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW,COLOR_YELLOW);
    }
    return 1;
}

// TODO: if this is obsolete, remove it
/*
CMD:r(playerid, params[])
{
    if (isnull(params))
        return SendErrorMessage(playerid, "Ne mozete poslati prazan /r!");
    new member = PlayerInfo[playerid][pMember],string[256];
    if (!IsACop(playerid) && !IsFDMember(playerid)&& !IsASD(playerid) && !IsAGov(playerid)) return SendClientMessage(playerid, COLOR_RED, "Niste ovla?teni!");
    if (member == 0) return SendClientMessage(playerid, COLOR_RED, "Moras biti clan organizacije da bi koristio ovu komandu!");
    #if defined EVENTSTARTED
    new StaticRand = random(2);
    if (StaticRand == 1) return SendClientMessage( playerid, COLOR_RED, "** Static **");
    #endif
    if (PlayerInfo[playerid][pLawDuty] == 0) return SendClientMessage(playerid, COLOR_RED, "Niste na duznosti!");

    if (IsACop(playerid)) {
        format(string, sizeof(string), "**[CH: PD DISPATCH] %s: %s", GetName(playerid, true), params);
        SendRadioMessage(member, TEAM_YELLOW_COLOR, string);
    }

    if (IsFDMember(playerid)) {
        format(string, sizeof(string), "** [FD DISPATCH] %s: %s **", GetName(playerid, true), params);
        SendRadioMessage(member, TEAM_YELLOW_COLOR, string);
    }

    if (IsAGov(playerid)) // ako je gov onda prica u slusalicu
    {
        format(string, sizeof(string), "*  %s prica u slusalicu.", GetName(playerid, true));
        SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 2000);
    } else { // ako je ostalo prica na radio
        format(string, sizeof(string), "*  %s prica na radio.", GetName(playerid, true));
        SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 2000);
    }
    if (!IsPlayerReconing(playerid)) {
        format(string, 256, "** %s [radio]: %s", GetName(playerid, true), params);
        ProxDetector(4.0, playerid, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, true);
    }
    return 1;
}
*/

CMD:d(playerid, params[])
{
    // TODO: 144 is max message len
    new string[256];
    if (isnull(params)) return SendErrorMessage(playerid, "Ne mozete poslati prazan /d!");
    if (PlayerInfo[playerid][pMember] == 0) return SendClientMessage(playerid, COLOR_RED, "Moras biti clan organizacije da bi koristio ovu komandu!");
    if (!IsACop(playerid) && !IsFDMember(playerid) && !IsASD(playerid) && !IsAGov(playerid)) return SendClientMessage(playerid, COLOR_RED, "Niste ovla?teni!");
    if (PlayerInfo[playerid][pLawDuty] == 0) return SendClientMessage(playerid, COLOR_RED, "Niste na duznosti!");

    format(string, sizeof(string), "** [%s] %s %s: %s **", ReturnPlayerFactionName(playerid), ReturnPlayerRankName(playerid), GetName(playerid, true), params);
    SendLawMessage(COLOR_ALLDEPT, string);

    if (IsAGov(playerid)) // ako je gov onda prica u slusalicu
    {
        format(string, sizeof(string), "* %s prica u slusalicu.", GetName(playerid, true));
        SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 2000);
    }
    else
    {
        format(string, sizeof(string), "* %s prica na radio.", GetName(playerid, true));
        SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 2000);
    }

    if (!IsPlayerReconing(playerid))
    {
        format(string, sizeof(string), "** %s [radio]: %s", GetName(playerid, true), params);
        ProxDetector(4.0, playerid, string, COLOR_FADE1, COLOR_FADE2, COLOR_FADE3, COLOR_FADE4, COLOR_FADE5, true);
    }
    else
    {
        // ???
        SendClientMessage(playerid, COLOR_RED, "Niste ovlasteni!");
    }
    return 1;
}

CMD:bk(playerid, params[])
{
    if (!IsACop(playerid) || !IsASD(playerid) || !IsFDMember(playerid))
    {
        SendClientMessage(playerid, COLOR_RED, "Nisi LSPD/LSFD!");
        return 1;
    }
    if (Bit4_Get(gr_Backup, playerid) != 1)
    {
        SendClientMessage(playerid, COLOR_RED, "Vec imate aktivan zahtjev za pojacanje!");
        return 1;
    }

    new message_color = -1, marker_color = -1, backup_type = -1;
    if (IsACop(playerid))
    {
        message_color = COLOR_COP;
        marker_color = COLOR_COP;
        backup_type = 1;
    }
    else if (IsASD(playerid))
    {
        message_color = 0xE30040FF;
        marker_color = 0x002FC7FF;
        backup_type = 5;
    }
    else if (IsFDMember(playerid))
    {
        message_color = 0xE30040FF;
        marker_color = 0x002FC7FF;
        backup_type = 2;
    }

    foreach(new i : Player)
    {
        if ((IsACop(playerid) && IsACop(i)) ||
            (IsASD(playerid) && IsASD(i))   ||
            (IsFDMember(playerid) && IsFDMember(i)))
        {
            if (IsPlayerInVehicle(i, GetPlayerVehicleID(i)))
            {
                va_SendClientMessage(i, message_color, "[GPS VOZILA] %s %s zahtjeva pomoc na podrucju %s!", ReturnPlayerRankName(playerid), GetName(playerid), GetPlayerStreet(playerid));
                SetPlayerMarkerForPlayer(i, playerid, marker_color);
            }
            else
            {
                va_SendClientMessage(i, message_color, "[HQ DISPECER] %s %s zahtjeva pomoc na podrucju %s!", ReturnPlayerRankName(playerid), GetName(playerid), GetPlayerStreet(playerid));
            }
        }
    }

    Bit4_Set(gr_Backup, playerid, backup_type);
    SendClientMessage(playerid, COLOR_RED, "Pozvali ste pojacanje na svojoj lokaciji, dispatcher ce obavijestiti aktivne jedinice.");
    SendClientMessage(playerid, COLOR_RED, "[ ! ] Ukucajte /bkc da bi ste izbrisali pojacanje.");
    BackupTimer[playerid] = repeat OnPlayerBackup(playerid);
    return 1;
}

CMD:bkc(playerid, params[])
{
    if (!IsACop(playerid) || !IsASD(playerid) || !IsFDMember(playerid))
    {
        SendClientMessage(playerid, COLOR_RED, "Nisi LSPD/LSFD!");
        return 1;
    }
    if (Bit4_Get(gr_Backup, playerid) == 0)
    {
        SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate aktivan zahtjev za pojacanje!");
        return 1;
    }

    foreach(new i : Player)
    {
        SetPlayerMarkerForPlayer(i, playerid, TEAM_HIT_COLOR);
    }
    SendMessage(playerid, MESSAGE_TYPE_INFO, "Ugasili ste aktivni GPS backup. Vase kolege ne vide vasu lokaciju!");
    Bit4_Set(gr_Backup,playerid, 0);
    stop BackupTimer[playerid];
    return 1;
}

CMD:bkall(playerid, params[])
{
    if (!IsACop(playerid) || !IsASD(playerid) || !IsFDMember(playerid))
    {
        SendClientMessage(playerid, COLOR_RED, "Nisi LSPD/LSFD!");
        return 1;
    }

    new string[144];
    if (Bit4_Get(gr_Backup, playerid) == 0)
    {
        format(string, sizeof(string), "[%s DISPACER]: %s %s zahtjeva hitnu pomoc svih law agencija! Lokacija: GPS", ReturnPlayerFactionName(playerid), ReturnPlayerRankName(playerid), GetName(playerid));
        SendLawMessage(0xE30040FF, string);

        foreach(new i : Player)
        {
            if (IsACop(i) || IsASD(i) || IsFDMember(i))
            {
                SetPlayerMarkerForPlayer(i, playerid, 0x002FC7FF);
            }
        }
        SendClientMessage(playerid, COLOR_RED, "Pozvali ste pojacanje na svojoj lokaciji, dispatcher ce obavijestiti sve sluzbe!");
        SendClientMessage(playerid, COLOR_WHITE, "Ukucajte /bkall da bi ste ugasili GPS.");
        Bit4_Set(gr_Backup,playerid, 2);
        BackupTimer[playerid] = repeat OnPlayerBackup(playerid);
    }
    else if (Bit4_Get(gr_Backup, playerid) == 2)
    {
        foreach(new i : Player)
        {
            if (IsACop(i) || IsASD(i) || IsFDMember(i))
            {
                SetPlayerMarkerForPlayer(i, playerid, TEAM_HIT_COLOR);
            }
        }
        SendMessage(playerid, MESSAGE_TYPE_INFO, "Opozvao si GPS, kolege vise nece vidjeti tvoju lokaciju!");
        Bit4_Set(gr_Backup,playerid, 0);
        stop BackupTimer[playerid];
    }
    return 1;
}

CMD:emsbk(playerid, params[])
{
    if (!IsACop(playerid) || !IsASD(playerid))
    {
        SendClientMessage(playerid, COLOR_RED, "Nisi LSPD / SASD!");
        return 1;
    }

    if (Bit4_Get(gr_Backup, playerid) == 0)
    {
        new string[128];
        format(string, sizeof(string), "[%s DISPACER]: %s %s zahtjeva hitnu pomoc LSFD! Lokacija: GPS", ReturnPlayerFactionName(playerid), ReturnPlayerRankName(playerid), GetName(playerid));
        SendLawMessage(0xFF6347AA, string);

        foreach(new i : Player)
        {
            if (IsACop(i) || IsASD(i) || IsFDMember(i))
            {
                SetPlayerMarkerForPlayer(i, playerid,  0xFF6347AA);
            }
        }
        SendClientMessage(playerid, COLOR_RED, "Pozvali ste pojacanje na svojoj lokaciji, dispatcher ce obavijestiti sve sluzbe!");
        SendClientMessage(playerid, COLOR_WHITE, "Ukucajte /bkall da bi ste ugasili GPS.");
        Bit4_Set(gr_Backup,playerid, 2);
        BackupTimer[playerid] = repeat OnPlayerBackup(playerid);
    }
    else if (Bit4_Get(gr_Backup, playerid) == 2)
    {
        foreach(new i : Player)
        {
            if (IsACop(i) || IsASD(i) || IsFDMember(i))
            {
                SetPlayerMarkerForPlayer(i, playerid, TEAM_HIT_COLOR);
            }
        }
        SendMessage(playerid, MESSAGE_TYPE_INFO, "Opozvao si GPS, kolege vise nece vidjeti tvoju lokaciju!");
        Bit4_Set(gr_Backup,playerid, 0);
        stop BackupTimer[playerid];
    }
    return 1;
}

CMD:gov(playerid, params[])
{
    if (isnull(params)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /gov [text]");
    if (PlayerInfo[playerid][pMuted] == 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemozete pricati, usutkani ste");

    if ((IsACop(playerid)     && PlayerInfo[playerid][pRank] >= 4) ||
        (IsFDMember(playerid) && PlayerInfo[playerid][pRank] >= 4) ||
        (IsAGov(playerid)     && PlayerInfo[playerid][pRank] >= 6) ||
        (IsASD(playerid)      && PlayerInfo[playerid][pRank] >= 6))
    {
        va_SendClientMessageToAll(0x6CA1FFFF, "[Government Announcement] %s", params);
        PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);

        new string[128];
        format(string, sizeof(string), "AdmWarn: Igrac %s ID:[%d] je koristio CMD /gov.", GetName(playerid, false), playerid);
        ABroadCast(COLOR_RED, string, 1);
    }
    else
    {
        SendClientMessage(playerid, COLOR_RED, "Niste ovlasteni!");
    }
    return 1;
}

CMD:showbadge(playerid, params[])
{
    new member = PlayerInfo[playerid][pMember], giveplayerid;
    if (sscanf(params, "u", giveplayerid))
        return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /showbadge [ID/Dio Imena]");
    if (member == 0)
        return SendClientMessage(playerid, COLOR_RED, "Moras biti clan organizacije da bi koristio ovu komandu!");
    if (giveplayerid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, giveplayerid, 5.0))
        return SendClientMessage(playerid, COLOR_RED, "Igrac nije na serveru ili nije blizu vas!");

    if (IsFDMember(playerid) || IsACop(playerid) || IsASD(playerid) || IsAGov(playerid))
    {
        va_SendClientMessage(giveplayerid, 0xFF9E9EFF, "*____ %s BADGE _____*", ReturnPlayerFactionName(playerid));
        va_SendClientMessage(giveplayerid, COLOR_WHITE, "- %s [ %s ]", GetName(playerid, true), ReturnPlayerRankName(playerid));
    }
    new string[128];
    format(string, sizeof(string), "* %s vadi svoju znacku i pokazuje ju %s.", GetName(playerid), GetName(giveplayerid));
    ProxDetector(7.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    return 1;
}

CMD:showaccreditation(playerid, params[])
{
    new member = PlayerInfo[playerid][pMember], giveplayerid;
    if (sscanf(params, "u", giveplayerid))
        return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /showaccreditation [ID/Dio Imena]");
    if (member == 0)
        return SendClientMessage(playerid, COLOR_RED, "Moras biti clan LSN organizacije da bi koristio ovu komandu!");
    if (giveplayerid == INVALID_PLAYER_ID || !IsPlayerNearPlayer(playerid, giveplayerid, 5.0))
        return SendClientMessage(playerid, COLOR_RED, "Igrac nije na serveru ili nije blizu vas!");

    if (!IsANews(playerid) || PlayerInfo[playerid][pLeader] != 8)
    {
        SendMessage(playerid, MESSAGE_TYPE_ERROR, "Moras biti clan LSN organizacije da bi koristio ovu komandu!");
        return 1;
    }

    SendClientMessage(giveplayerid, 0xFF9E9EFF, "*____ LOS SANTOS NEWS ACCREDITATION _____*");
    va_SendClientMessage(giveplayerid, COLOR_WHITE, "- %s [ %s ]", GetName(playerid, true), ReturnPlayerRankName(playerid));
    new string[128];
    format(string, sizeof(string), "* %s vadi svoju akreditaciju i pokazuje ju %s.", GetName(playerid), GetName(giveplayerid));
    ProxDetector(7.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
    return 1;
}

CMD:carsign(playerid, params[])
{
    new
        pick[8],
        vehicleid = GetPlayerVehicleID(playerid);

    if (!IsAGov(playerid) || !IsFDMember(playerid) || !IsACop(playerid) || !IsASD(playerid))
    {
        SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nisi ovlasten za koristenje ove komande!");
        return 1;
    }
    if (PlayerInfo[playerid][pRank] < FactionInfo[PlayerInfo[playerid][pMember]][rCarSign])
    {
        SendFormatMessage(playerid, MESSAGE_TYPE_ERROR, "Morate biti rank %d kako bi ste mogli koristiti ovu komandu!", FactionInfo[PlayerInfo[playerid][pMember]][rCarSign]);
        return 1;
    }
    if (sscanf(params, "s[8] ", pick))
    {
        SendClientMessage(playerid, COLOR_RED, "[ ? ]: /carsign [odabir]");
        SendClientMessage(playerid, COLOR_RED, "[ ! ] update, detach, attach");
        return 1;
    }

    if (!strcmp(pick, "update", true))
    {
        new text[21];
        if (sscanf(params, "s[8]s[21]", pick, text)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /carsign update [text]");
        if (strlen(text) >  20 || strlen(text) < 0) return SendClientMessage(playerid, COLOR_RED, "Text ne moze biti prazan ili veci od 20 karaktera!");
        if (VehicleInfo[vehicleid][vFactionTextOn] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Automobil nema 3DText! Koristi /carsign attach.");

        // TODO: use defines and or extract this check to a function, is Government vehicle or sth like that
        if (VehicleInfo[vehicleid][vFaction] != 1 || VehicleInfo[vehicleid][vFaction] != 2 ||
            VehicleInfo[vehicleid][vFaction] != 3 || VehicleInfo[vehicleid][vFaction] != 4)
        {
            SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne smijes stavljati na druga auta text (samo PD/FD/GOV)!");
            return 1;
        }

        // TODO: use strcpy
        VehicleInfo[vehicleid][vText][0] = EOS;
        strcat(VehicleInfo[vehicleid][vText], text, 23);

        DestroyDynamic3DTextLabel(VehicleInfo[vehicleid][vFactionText]);
        VehicleInfo[vehicleid][vFactionText] = CreateDynamic3DTextLabel(VehicleInfo[vehicleid][vText], 0xD2D2D2FF, -0.6969, -2.8092, -0.3000, 10.0, INVALID_PLAYER_ID, vehicleid, 0, -1, -1, -1, 15.0);

        mysql_fquery(g_SQL, "UPDATE server_cars SET text = '%e' WHERE id = '%d'",
            text,
            VehicleInfo[vehicleid][vSQLID]
        );

        va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Uspjesno si promjenio 3dText na automobilu %d u %s.", vehicleid, text);
        return 1;
    }
    else if (!strcmp(pick, "detach", true))
    {
        if (VehicleInfo[vehicleid][vFactionTextOn] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Automobil nema 3dText!");

        DestroyDynamic3DTextLabel(VehicleInfo[vehicleid][vFactionText]);
        SendClientMessage(playerid, COLOR_RED, "Uspjesno si skinio 3dText s automobila!");
        VehicleInfo[vehicleid][vFactionTextOn] = 0;
        return 1;
    }
    else if (!strcmp(pick, "attach", true))
    {
        if (VehicleInfo[vehicleid][vFactionTextOn] == 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Automobil vec ima 3dText!");

        VehicleInfo[vehicleid][vFactionText] = CreateDynamic3DTextLabel(VehicleInfo[vehicleid][vText], 0xD2D2D2FF, -0.6969, -2.8092, -0.3000, 10.0, INVALID_PLAYER_ID, vehicleid, 0, -1, -1, -1, 15.0);
        SendMessage(playerid, MESSAGE_TYPE_INFO, "Uspjesno si stavio 3dText na automobil!");
        VehicleInfo[vehicleid][vFactionTextOn] = 1;
        return 1;
    }
    return 1;
}

// TODO: if this is obsolete, remove it
/*
CMD:callsign(playerid, params[])
{
    new
        pick[6],
        globalstring[128];
    if (sscanf(params, "s[6] ", pick)) {
        SendClientMessage(playerid, COLOR_RED, "[ ? ]: /callsign [odabir]");
        SendClientMessage(playerid, COLOR_RED, "[ ! ] set, show, all");
        return 1;
    }
    if (strcmp(pick, "set") == 0)
    {
        if (PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pLeader] == 4)
        {
            new sign[26], gplayerid;
            if (sscanf(params, "s[6]us[20]", pick, gplayerid, sign)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /callsign set [playerid/dio imena][text]");
            if (gplayerid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Krivi playerid!");
            if ((PlayerInfo[gplayerid][pMember] != 1 && PlayerInfo[gplayerid][pRank] < 1) && PlayerInfo[playerid][pLeader] == 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "On nije pripadnik LSPDa ili nema rank 1+!");
            else if ((PlayerInfo[gplayerid][pMember] != 2 && PlayerInfo[gplayerid][pRank] < 1) && PlayerInfo[playerid][pLeader] == 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "On nije pripadnik LSFDa ili nema rank 1+!");
            else if ((PlayerInfo[gplayerid][pMember] != 3 && PlayerInfo[gplayerid][pRank] < 1) && PlayerInfo[playerid][pLeader] == 3) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "On nije pripadnik SASDa ili nema rank 1+!");

            strmid(PlayerInfo[gplayerid][pSign], sign, 0, strlen(sign), 26);
            new gplayername[MAX_PLAYER_NAME];
            GetPlayerName(gplayerid, gplayername, MAX_PLAYER_NAME);
            format(globalstring, sizeof(globalstring), "* Dao si %s callsign: %s", gplayername, PlayerInfo[gplayerid][pSign]);
            SendClientMessage(playerid, -1, globalstring);
            new playername[MAX_PLAYER_NAME];
            GetPlayerName(playerid, playername, MAX_PLAYER_NAME);
            format(globalstring, sizeof(globalstring), "* %s ti je stavio callsign %s", playername, PlayerInfo[gplayerid][pSign]);
            SendClientMessage(gplayerid, -1, globalstring);
        }
        else SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nisi lider LSPDa/LSFDa!");
    }
    else if (strcmp(pick, "show") == 0)
    {
        if (IsACop(playerid))
        {
            new gplayerid;
            if (sscanf(params, "s[6]u", pick, gplayerid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /callsign show [playerid/dio imena]");
            if (gplayerid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Krivi playerid!");
            if (strlen(PlayerInfo[gplayerid][pSign]) < 3) return SendClientMessage(playerid, COLOR_WHITE, "Nema stavljen callsign!");
            format(globalstring, sizeof(globalstring), "* %s callsign: %s *", GetName(gplayerid), PlayerInfo[gplayerid][pSign]);
            SendClientMessage(playerid, 0x143C9BFF, globalstring);
        }
        else if (IsFDMember(playerid))
        {
            new gplayerid;
            if (sscanf(params, "s[6]u", pick, gplayerid)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /callsign show [playerid/dio imena]");
            if (gplayerid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Krivi playerid!");
            if (strlen(PlayerInfo[gplayerid][pSign]) < 3) return SendClientMessage(playerid, COLOR_WHITE, "Nema stavljen callsign!");
            format(globalstring, sizeof(globalstring), "* %s callsign: %s *", GetName(gplayerid), PlayerInfo[gplayerid][pSign]);
            SendClientMessage(playerid, 0x143C9BFF, globalstring);
        }
        else SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nisi lider ili clan LSFDa/LSPDa!");
    }
    else if (strcmp(pick, "all") == 0)
    {
        new string[86], gplayername[MAX_PLAYER_NAME];
        SendClientMessage(playerid, COLOR_WHITE, "CALLSIGNS:");
        if (IsACop(playerid))
        {
            foreach(new i : Player) {
                if (PlayerInfo[i][pMember] == 1) {
                    if (strlen(PlayerInfo[i][pSign]) != 0) {
                        GetPlayerName(i, gplayername, sizeof(gplayername));
                        format(string, sizeof(string), "* %s callsign: %s *", gplayername, PlayerInfo[i][pSign]);
                        SendClientMessage(playerid, 0x143C9BFF, string);
                    }
                }
            }
        }
        else if (IsASD(playerid))
        {
            foreach(new i : Player) {
                if (PlayerInfo[i][pMember] == 5) {
                    if (strlen(PlayerInfo[i][pSign]) != 0) {
                        GetPlayerName(i, gplayername, sizeof(gplayername));
                        format(string, sizeof(string), "* %s callsign: %s *", gplayername, PlayerInfo[i][pSign]);
                        SendClientMessage(playerid, 0x143C9BFF, string);
                    }
                }
            }
        }
        else if (IsFDMember(playerid))
        {
            foreach(new i : Player) {
                if (PlayerInfo[i][pMember] == 2) {
                    if (strlen(PlayerInfo[i][pSign]) > 0) {
                        GetPlayerName(i, gplayername, sizeof(gplayername));
                        format(string, sizeof(string), "* %s callsign: %s *", gplayername, PlayerInfo[i][pSign]);
                        SendClientMessage(playerid, 0x143C9BFF, string);
                    }
                }
            }
        }
        else SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nisi lider LSPDa/LSFDa!");
    }
    return 1;
}
*/

CMD:frtc(playerid, params[])
{
    new vehid;
    if (sscanf(params, "i", vehid))
    {
        SendClientMessage(playerid, COLOR_RED, "[ ? ]: /frtc [vehicleid]");
        return 1;
    }

    // TODO: rewrite this and use defines
    if (PlayerInfo[playerid][pLeader] == 0 || /* player cant rtc if not leader */
        PlayerInfo[playerid][pLeader] != 1 || PlayerInfo[playerid][pLeader] != 2 ||
        PlayerInfo[playerid][pLeader] != 4 || PlayerInfo[playerid][pLeader] != 5)
        /* player cant rtc if not leader of these orgs: 1,2,4,5 */
    {
        SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste lider organizacije!");
        return 1;
    }

    if (PlayerInfo[playerid][pLeader] == VehicleInfo[vehid][vFaction])
    {
        SetVehicleToRespawn(vehid);
        SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Respawnao si vozilo ID %d. (/frtc)", vehid);
    }
    return 1;
}
