#include <YSI_Coding\y_hooks>

// Save/Load Player related func. modules - named after adjacent database tables
#include "modules/Player\SaveLoad/player_inventory.pwn"
#include "modules/Player\SaveLoad/player_crashes.pwn"
#include "modules/Player\SaveLoad/player_health.pwn"
#include "modules/Player\SaveLoad/player_appearance.pwn"
#include "modules/Player\SaveLoad/player_jail.pwn"
#include "modules/Player\SaveLoad/player_cooldowns.pwn"

/*
	##     ##    ###    ########   ######  
	##     ##   ## ##   ##     ## ##    ## 
	##     ##  ##   ##  ##     ## ##       
	##     ## ##     ## ########   ######  
	##   ##  #########  ##   ##         ## 
	 ## ##   ##     ##  ##    ##  ##    ## 
	  ###    ##     ##  ##     ##  ######  
*/
static  
		dialogtext[MAX_DIALOG_TEXT],
		Timer:LoginCheckTimer[MAX_PLAYERS],
		bool:SigningIn[MAX_PLAYERS],
		bool:SecurityBreach[MAX_PLAYERS];

/*
	######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######  
	##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ## 
	##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##       
	######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######  
	##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ## 
	##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ## 
	##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######  
*/

stock bool:Player_SecurityBreach(playerid)
{
	return SecurityBreach[playerid];
}

stock Player_SetSecurityBreach(playerid, bool:v)
{
	SecurityBreach[playerid] = v;
}

// Timers
timer FinishPlayerSpawn[5000](playerid)
{
	if(Bit1_Get(gr_PlayerLoggedIn, playerid))
		SafeSpawnPlayer(playerid);
	
	return 1;
}

timer SafeHealPlayer[250](playerid)
{
	SetPlayerHealth(playerid, 100);
	return 1;
}


// Forwards
forward CheckPlayerInBase(playerid);
forward LoadPlayerStats(playerid); // Loading all data non-related to 'accounts' database table
forward SavePlayerStats(playerid); // Saving all data non-related to 'accounts database table
forward LoadPlayerData(playerid);
forward SavePlayerData(playerid); 
forward RegisterPlayer(playerid);
forward OnAccountFinish(playerid);

// Publics
CheckPlayerInactivity(playerid)
{
	inline OnPlayerInactivityCheck()
	{
		if(!cache_num_rows())
			return 1;
		
		mysql_fquery(g_SQL, "DELETE FROM inactive_accounts WHERE sqlid = '%d'", PlayerInfo[playerid][pSQLID]);
		va_SendClientMessage(playerid, COLOR_LIGHTRED, 
			"[%s]: Registered inactivity on current account has been deactivated.",
			SERVER_NAME
		);		
		return 1;
	}
	MySQL_TQueryInline(g_SQL,  
		using inline OnPlayerInactivityCheck, 
		va_fquery(g_SQL, "SELECT sqlid FROM inactive_accounts WHERE sqlid = '%d'", 
			PlayerInfo[playerid][pSQLID]), 
		"i", 
		playerid
	);
	return 1;
}

Public: OnPasswordChecked(playerid)
{
	new bool:match = bcrypt_is_equal();
	if(match)
	{
		mysql_pquery(g_SQL, 
			va_fquery(g_SQL, "SELECT * FROM accounts WHERE name = '%e'", GetName(playerid, false)),
			"LoadPlayerData", 
			"i", 
			playerid
		);
	}
	else
	{
		Bit8_Set(gr_LoginInputs, playerid, Bit8_Get(gr_LoginInputs, playerid) + 1);
		if( !( MAX_LOGIN_TRIES - Bit8_Get(gr_LoginInputs, playerid) ) )
		{
			va_SendClientMessage(playerid, COLOR_RED, 
				"[%s]: You have reached maximum(%d) attempts, you got an IP ban!",
				SERVER_NAME,
				MAX_LOGIN_TRIES
			);
			BanMessage(playerid);
			return 1;
		}
		if(Bit8_Get(gr_LoginInputs, playerid) < 3) 
		{
			format(dialogtext, sizeof(dialogtext), 
				""COL_RED"You have entered wrong password!\n\
					"COL_WHITE"Check your upper/lower case sensitivity and try again.\n\
					You have "COL_LIGHTBLUE"%d "COL_WHITE"attempts to input valid password!\n\n\n\
					"COL_RED"If you exceed max attempt limit, you will be kicked!", 
				MAX_LOGIN_TRIES - Bit8_Get(gr_LoginInputs, playerid)
			);

			ShowPlayerDialog(playerid, 
				DIALOG_LOGIN, 
				DIALOG_STYLE_PASSWORD, 
				""COL_WHITE"Login", 
				dialogtext, 
				"Proceed", 
				"Abort"
			);
		}
	}
	return 1;
}

public CheckPlayerInBase(playerid)
{
	if(cache_num_rows()) 
	{
		TogglePlayerControllable(playerid, false);
		SetCameraBehindPlayer(playerid);
		RandomPlayerCameraView(playerid);

		format(dialogtext, 
			sizeof(dialogtext), 
			""COL_WHITE"Greetings "COL_LIGHTBLUE"%s!\n\n\
				"COL_WHITE"It's nice to see you again on our server.\n\
				Please enter your account's password and log in.\n\
				You have "COL_LIGHTBLUE"%d"COL_WHITE" seconds to\n\
				sign in, otherwise you'll be kicked out.\n\n\
				Thank you and we hope you'll enjoy your gameplay\n\
				on %s!",
			GetName(playerid),
			MAX_LOGIN_TIME
		);					
		
		ShowPlayerDialog(playerid, 
			DIALOG_LOGIN, 
			DIALOG_STYLE_PASSWORD, 
			""COL_WHITE"Login", 
			dialogtext, 
			"Proceed", 
			"Abort"
		);
		
		Bit8_Set(gr_LoginInputs, playerid, 0);
		SigningIn[playerid] = true;
		LoginCheckTimer[playerid] = defer LoginCheck(playerid);
	} 
	else 
	{
		if(regenabled)
		{				
			#if defined COA_UCP
				va_SendClientMessage(playerid, COLOR_RED, "You haven't registered your account on %s!",
					WEB_URL
				);
				KickMessage(playerid);
			#else
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Welcome "COL_LIGHTBLUE"%s!\n\n\
						"COL_WHITE"Your account isn't registered on our server.\n\
						If you want to Sign Up, please press \"Register\".\n\
						Otherwise, you'll be kicked out of the server!",GetName(playerid)
				);
				ShowPlayerDialog(playerid, 
					DIALOG_REGISTER, 
					DIALOG_STYLE_MSGBOX, 
					""COL_WHITE"Sign Up (1/6)", 
					dialogtext, 
					"Register", 
					"Abort"
				);
			#endif
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, 
				"Administrator currently disabled registration on server. Please try again later.");
			KickMessage(playerid);
		}
	}
	return 1;
}

public LoadPlayerStats(playerid) // Main func. for hooking database loads
{
	return 1;
}

public LoadPlayerData(playerid)
{
	new 
		rows, 
		ban_reason[32],
		unban_time = 0;
    cache_get_row_count(rows);
    if(rows)
	{
		stop LoginCheckTimer[playerid];
		SigningIn[playerid] = false;

		cache_get_value_name_int(0, "sqlid"			, PlayerInfo[playerid][pSQLID]);
		cache_get_value_name(0, 	"password"		, PlayerInfo[playerid][pPassword]		, BCRYPT_HASH_LENGTH);
		cache_get_value_name(0, 	"teampin"		, PlayerInfo[playerid][pTeamPIN]		, BCRYPT_HASH_LENGTH);
		cache_get_value_name(0, 	"lastlogin"		, PlayerInfo[playerid][pLastLogin]		, 24);
		cache_get_value_name_int(0, "lastloginstamp", PlayerInfo[playerid][pLastLoginTimestamp]);
		cache_get_value_name_int(0, "spawnchange"	, PlayerInfo[playerid][pSpawnChange]);
		cache_get_value_name_int(0, "secquestion"	, PlayerInfo[playerid][pSecQuestion]);
		cache_get_value_name(0, 	"secawnser"		, PlayerInfo[playerid][pSecQuestAnswer]	, 31);
		cache_get_value_name(0, 	"forumname"		, PlayerInfo[playerid][pForumName]		, 24);
		cache_get_value_name(0, 	"email"			, PlayerInfo[playerid][pEmail]			, MAX_PLAYER_MAIL);
		cache_get_value_name(0, 	"SAMPid"		, PlayerInfo[playerid][pSAMPid]			, 128);
		cache_get_value_name(0, 	"lastupdatever"	, PlayerInfo[playerid][pLastUpdateVer]	, 24);
		cache_get_value_name_int(0, "registered"	, PlayerInfo[playerid][pRegistered]);
		cache_get_value_name_int(0, "adminLvl"		, PlayerInfo[playerid][pTempRank][0]);
		cache_get_value_name_int(0, "helper"		, PlayerInfo[playerid][pTempRank][1]);
		cache_get_value_name_int(0, "playaWarns"	, PlayerInfo[playerid][pWarns]);
		cache_get_value_name_int(0, "levels"		, PlayerInfo[playerid][pLevel]);
		cache_get_value_name_int(0, "connecttime"	, PlayerInfo[playerid][pConnectTime]);
		cache_get_value_name_int(0, "muted"			, PlayerInfo[playerid][pMuted]);
		cache_get_value_name_int(0, "respects"		, PlayerInfo[playerid][pRespects]);
		cache_get_value_name_int(0,  "sex"			, PlayerInfo[playerid][pSex]);
		cache_get_value_name_int(0,  "age"			, PlayerInfo[playerid][pAge]);
		cache_get_value_name_int(0,  "changenames"	, PlayerInfo[playerid][pChangenames]);
		cache_get_value_name_int(0,  "changetimes"	, PlayerInfo[playerid][pChangeTimes]);
		cache_get_value_name_int(0,  "handMoney"	, PlayerInfo[playerid][pMoney]);
		cache_get_value_name_int(0,  "bankMoney"	, PlayerInfo[playerid][pBank]);
		cache_get_value_name_int(0,  "rentkey"		, PlayerKeys[playerid][pRentKey]);
		cache_get_value_name_int(0,	"playaUnbanTime", unban_time);
		cache_get_value_name(0, 	"playaBanReason", ban_reason							, 32);
		cache_get_value_name_int(0,	"voted"			, PlayerInfo[playerid][pVoted]);
		cache_get_value_name_int(0, "FurnPremium"	, PlayerInfo[playerid][pExtraFurniture]); 
		cache_get_value_name_int(0,	"mustread"		, PlayerInfo[playerid][pMustRead]);
				
		if( unban_time == -1 )
		{
			va_SendClientMessage( playerid, COLOR_RED, 
				"[%s]: You have been banned for life on this server!\n\
					If you think your ban was unfair/a mistake, please post an unban request on\n\
					\n%s",
				SERVER_NAME,
				WEB_URL
			);
			BanMessage(playerid);
			return 1;
		}
		else if( unban_time == -2 ) 
		{
			va_SendClientMessage( playerid, COLOR_RED, 
				"[%s]: Your user account has been blocked by the system!\n\
					You must create it on User Control Panel (%s) in order for it to be playable!",
				SERVER_NAME,
				WEB_URL
			);
			KickMessage(playerid);
			return 1;
		}
		else if( unban_time == -3)
		{
		    va_SendClientMessage( playerid, COLOR_RED, 
				"[%s]: Your account has been locked by security system!",
				SERVER_NAME
			);
		    va_SendClientMessage( playerid, COLOR_RED,
				"[%s]: Please post an unban request on our pages! (%s)",
				SERVER_NAME,
				WEB_URL
			);
		    KickMessage(playerid);
		    return 1;
		}

		if( unban_time < gettimestamp() ) 
		{
			mysql_fquery(g_SQL, "UPDATE accounts SET playaUnbanTime = '0' WHERE sqlid = '%d'", 
				PlayerInfo[playerid][pSQLID]
			);
		} 
		else 
		{
			new date[12], time[12];
			TimeFormat(Timestamp:unban_time, HUMAN_DATE, date);
			TimeFormat(Timestamp:unban_time, ISO6801_TIME, time);
	
			va_SendClientMessage(playerid, COLOR_LIGHTRED, 
				"[%s]: Your ban expires on date: "COL_SERVER"%s %s.", 
				SERVER_NAME,
				date, 
				time
			);
			va_SendClientMessage(playerid, COLOR_LIGHTRED, "Ban reason: %s", ban_reason);

			KickMessage(playerid);
			return 1;
		}

		LoadPlayerStats(playerid);
		
		PlayerKeys[playerid][pHouseKey] = INVALID_HOUSE_ID;
		PlayerKeys[playerid][pBizzKey] 	= INVALID_BIZNIS_ID;
		PlayerKeys[playerid][pComplexKey] = INVALID_COMPLEX_ID;
		PlayerKeys[playerid][pComplexRoomKey] = INVALID_COMPLEX_ID;
		PlayerKeys[playerid][pGarageKey] = -1;
		PlayerKeys[playerid][pIllegalGarageKey]	= -1;
		PlayerKeys[playerid][pVehicleKey] = -1;
		
		foreach(new house : Houses)
		{
			if(HouseInfo[house][hOwnerID] == PlayerInfo[playerid][pSQLID]) 
			{
				PlayerKeys[playerid][pHouseKey] = house;
				break;
			}
		}

		foreach(new biznis : Bizzes) 
		{
			if(BizzInfo[biznis][bOwnerID] == PlayerInfo[playerid][pSQLID]) 
			{
				PlayerKeys[playerid][pBizzKey] = biznis;
				ReloadBizzFurniture(biznis);
				break;
			}
		}
		
		foreach(new complex : Complex)
		{
			if(ComplexInfo[complex][cOwnerID] == PlayerInfo[playerid][pSQLID]) 
			{
				PlayerKeys[playerid][pComplexKey] = complex;
				break;
			}
		}
		
		foreach(new complexr : ComplexRooms)
		{
			if(ComplexRoomInfo[complexr][cOwnerID] == PlayerInfo[playerid][pSQLID]) 
			{
				PlayerKeys[playerid][pComplexRoomKey] = complexr;
				break;
			}
		}
		
		foreach(new igarage : IllegalGarages)
		{
			if(IlegalGarage[ igarage ][ igOwner ] == PlayerInfo[playerid][pSQLID])
			{
				PlayerKeys[playerid][pIllegalGarageKey] = igarage;
				break;
			}
		}
		foreach(new garage : Garages)
		{
			if(GarageInfo[garage][gOwnerID] == PlayerInfo[playerid][pSQLID]) 
			{
				PlayerKeys[playerid][pGarageKey] = garage;
				break;
			}
		}
		foreach(new vehicleid : Vehicles[VEHICLE_USAGE_PRIVATE])
		{
			if(VehicleInfo[vehicleid][vOwnerID] == PlayerInfo[playerid][pSQLID])
			{
				PlayerKeys[playerid][pVehicleKey] = vehicleid;
				break;
			}
		}
		
		Bit1_Set( gr_PlayerLoggingIn, playerid, true );
  		SetPlayerSpawnInfo(playerid);
        Bit1_Set( gr_FristSpawn, playerid, true );

        if(!isnull(PlayerInfo[playerid][pSAMPid]) && PlayerInfo[playerid][pSecQuestion] != 1 
			&& !isnull(PlayerInfo[playerid][pSecQuestAnswer]))
        {
            new
                n_gpci[128];
            gpci(playerid, n_gpci, 128);
            if(strcmp(n_gpci, PlayerInfo[playerid][pSAMPid])) 
			{
                Player_SetSecurityBreach(playerid, true);
                
				va_SendClientMessage(playerid, 
					COLOR_RED, 
					"[%s]: Semms to be you are using unknown computer to log in to our server! \n\
						Please input security answer to continue.",
					SERVER_NAME
				);

                va_ShowPlayerDialog(playerid, 
					DIALOG_SEC_SAMPID, 
					DIALOG_STYLE_PASSWORD, 
					""COL_RED"SECURITY BREACH", 
					""COL_WHITE"Please answer your security question to continue:\n%s", 
					"Answer", 
					"Abort", 
					secQuestions[PlayerInfo[playerid][pSecQuestion]]
				);
                return 1;
            }
        }

        Bit1_Set(gr_PlayerLoggedIn, playerid, true);
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Please wait for 5 seconds. Loading in progres...");
		defer FinishPlayerSpawn(playerid);
    }
    return 1;
}

public RegisterPlayer(playerid) // TODO: mandatory checkup!
{
	format(PlayerInfo[playerid][pLastLogin], 24, ReturnDate());
    mysql_pquery(g_SQL,
		va_fquery(g_SQL, 
			"INSERT INTO accounts (online,registered,register_date,name,password,teampin,email,\n\
				secawnser,levels,age,sex,handMoney,bankMoney,casinocool) \n\
				VALUES ('1','0','%e','%e','%e','','%e','','%d','%d','%d','%d','%d','%d')",
			PlayerInfo[playerid][pLastLogin],
			GetName(playerid, false),
			PlayerInfo[playerid][pPassword],
			PlayerInfo[playerid][pEmail],
			1,
			PlayerInfo[playerid][pAge],
			PlayerInfo[playerid][pSex],
			NEW_PLAYER_MONEY,
			NEW_PLAYER_BANK,
			5), 
		"OnAccountFinish", 
		"i", 
		playerid
	);
	return 1;
}

public OnAccountFinish(playerid)
{	
	//Enum set
	PlayerInfo[playerid][pSQLID] 			= cache_insert_id();
	PlayerInfo[playerid][pRegistered] 		= 0;
	PlayerInfo[playerid][pLevel] 			= 1;
	PlayerAppearance[playerid][pSkin] 			= 29;
	PaydayInfo[playerid][pPayDayMoney] 		= 0;
	PaydayInfo[playerid][pProfit]			= 0;
	PlayerJob[playerid][pFreeWorks] 		= 15;
	PlayerInfo[playerid][pMuted] 			= true;
	PlayerInfo[playerid][pAdmin] 			= 0;
	PlayerInfo[playerid][pHelper] 			= 0; 
	PlayerCoolDown[playerid][pCasinoCool]		= 5;
	PlayerCoolDown[playerid][pCasinoCool]		= 5;

	PlayerKeys[playerid][pHouseKey]			= INVALID_HOUSE_ID;
	PlayerKeys[playerid][pRentKey]			= INVALID_HOUSE_ID;
	PlayerKeys[playerid][pBizzKey]			= INVALID_BIZNIS_ID;
	PlayerKeys[playerid][pComplexRoomKey]	= INVALID_COMPLEX_ID;
	PlayerKeys[playerid][pComplexKey]		= INVALID_COMPLEX_ID;
	PlayerKeys[playerid][pVehicleKey]		= -1;
	
	UpdateRegisteredPassword(playerid);
	
	TogglePlayerSpectating(playerid, 0);
	SetCameraBehindPlayer(playerid);
	SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
	
	PlayerNewUser_Set(playerid,true);
	Bit1_Set(gr_PlayerLoggedIn, playerid, true);
	DestroyLoginTextdraws(playerid);
	
	CreateLogoTD(playerid);
	
	SpawnPlayer(playerid);
    return 1;
}

SetPlayerOnlineStatus(playerid, status)
{
	mysql_fquery(g_SQL, 
		"UPDATE accounts set online = '%d' WHERE sqlid = '%d'", 
		status,
		PlayerInfo[playerid][pSQLID]
	);
	return 1;
}

stock IsEMailInDB(const email[])
{
	new 
		Cache:result,
		counts;
	
	result = mysql_query(g_SQL, va_fquery(g_SQL, "SELECT sqlid FROM accounts WHERE email = '%e'", email));
	counts = cache_num_rows();
	cache_delete(result);
	return counts;
}

SafeSpawnPlayer(playerid)
{
	new currentday, day;
	TimeFormat(Timestamp:gettimestamp(), DAY_OF_MONTH, "%d", currentday);
	TimeFormat(Timestamp:ExpInfo[playerid][eLastPayDayStamp], DAY_OF_MONTH, "%d", day);
	if(currentday != day)
	{
		ExpInfo[playerid][eGivenEXP] = false;
		ExpInfo[playerid][eDayPayDays] = 0;
	}

	// Micanje ulaznih textdrawova
	DestroyLoginTextdraws(playerid);
	// Forum URL Textdraw
	CreateLogoTD(playerid);
	// AFK Timer
	SetPlayerAFKLimit(playerid);

	#if defined MODULE_LOGS
	Log_Write("/logfiles/connects.txt", "(%s) %s(%s) sucessfully connected on the server.",
		ReturnDate(),
		GetName(playerid, false),
		ReturnPlayerIP(playerid)
	);
	#endif
	
	Player_SetSecurityBreach(playerid, false);
	
	mysql_fquery(g_SQL,
		"INSERT INTO player_connects(player_id, time, aip) VALUES ('%d','%d','%e')",
		PlayerInfo[playerid][pSQLID],
		gettimestamp(),
		ReturnPlayerIP(playerid)
	);
	
	
	if( ( 10 <= PlayerJob[playerid][pJob] <= 12 ) && ( !PlayerFaction[playerid][pMember] && !PlayerFaction[playerid][pLeader])  )
		PlayerJob[playerid][pJob] = 0;

	if( !PlayerInfo[playerid][pRegistered] )
		PlayerNewUser_Set(playerid, true);
		
	if( PlayerVIP[playerid][pDonateTime] < gettimestamp() && PlayerVIP[playerid][pDonateRank] > 0 ) 
	{
		va_SendClientMessage( playerid, COLOR_ORANGE, 
			"[%s]: Your InGame Premium VIP status has expired. Please donate again if you want to extend it!",
			SERVER_NAME
		);
		
		PlayerVIP[playerid][pDonateTime] = 0;
		PlayerVIP[playerid][pDonateRank] = 0;
		if(PlayerKeys[playerid][pBizzKey] != INVALID_BIZNIS_ID)
			UpdatePremiumBizFurSlots(playerid);
		if(PlayerKeys[playerid][pHouseKey] != INVALID_HOUSE_ID)
			UpdatePremiumHouseFurSlots(playerid, -1, PlayerKeys[playerid][pHouseKey]);
		SavePlayerVIP(playerid);
	}

	if( isnull(PlayerInfo[playerid][pSecQuestAnswer]) && isnull(PlayerInfo[playerid][pEmail]) )
	{
		SendClientMessage(playerid, COLOR_RED, 
			"[ ! ]: Your account is unprotected. Please setup your e-mail and security question & answer! (/account)");
		va_SendClientMessage(playerid, COLOR_RED, 
			"[ ! ]: If you don't fill up your e-mail and security question & answer, \n\
				%s won't be responsible for your account loss.",
			SERVER_NAME
		);
	}
	else if(PlayerInfo[playerid][pSecQuestion] == 1 && isnull(PlayerInfo[playerid][pSecQuestAnswer]))
	{
		SendClientMessage(playerid, COLOR_RED, "[ ! ]: Please setup your security question and answer! (/account)");
		gpci(playerid, PlayerInfo[playerid][pSAMPid], 128);
	}
	else if(isnull(PlayerInfo[playerid][pSAMPid]))
	{
		SendClientMessage(playerid, COLOR_RED, 
			"[ ! ]: Next time you login from different computer, the server will require answer to safety question!");
		gpci(playerid, PlayerInfo[playerid][pSAMPid], 128);
	}

	defer SafeHealPlayer(playerid);
	FinalPlayerCheck(playerid); // Crash, Private Vehicle, Mask, Interiors and Inactivity Check 

	Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, OBJECT_STREAM_LIMIT, playerid);
	Bit1_Set( gr_FristSpawn, playerid, true );
	Bit1_Set(gr_PlayerLoggedIn, playerid, true);
	Bit1_Set(gr_PlayerLoggingIn, playerid, false);
	TogglePlayerSpectating(playerid, 0);
	SetCameraBehindPlayer(playerid);
	SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
	TogglePlayerControllable(playerid, false);
	StopAudioStreamForPlayer(playerid);
	
	va_SendClientMessage(playerid, COLOR_LIGHTBLUE, 
		"[%s]: "COL_WHITE"Welcome back, "COL_LIGHTBLUE"%s"COL_WHITE"!", 
		SERVER_NAME,
		GetName(playerid)
	);
	return 1;
}

public SavePlayerStats(playerid) // Main func. for hooking database updates 
{
	return 1;
}

public SavePlayerData(playerid)
{
    if( !SafeSpawned[playerid] )	
		return 1;
	
	mysql_pquery(g_SQL, "START TRANSACTION");

	mysql_fquery_ex(g_SQL, 
		"UPDATE accounts SET lastlogin = '%e', lastloginstamp = '%d', lastip = '%e', forumname = '%e', \n\
			lastupdatever = '%e', registered = %d', playaWarns = '%d', levels = '%d', connecttime = '%d', \n\
			muted = '%d', respects = '%d', changenames = '%d', changetimes = '%d',\n\
			mustread = '%d' WHERE sqlid = '%d'",
		PlayerInfo[playerid][pLastLogin],
		PlayerInfo[playerid][pLastLoginTimestamp],
		PlayerInfo[playerid][pIP],
		PlayerInfo[playerid][pForumName],
		PlayerInfo[playerid][pLastUpdateVer],
		PlayerInfo[playerid][pRegistered],
		PlayerInfo[playerid][pWarns],
		PlayerInfo[playerid][pLevel],
		PlayerInfo[playerid][pConnectTime],
		PlayerInfo[playerid][pMuted],
		PlayerInfo[playerid][pRespects],
		PlayerInfo[playerid][pChangenames],
		PlayerInfo[playerid][pChangeTimes],
		PlayerInfo[playerid][pMustRead],
		PlayerInfo[playerid][pSQLID]
	);

	SavePlayerStats(playerid); // Saving data non-related to 'accounts' database table.

	mysql_pquery(g_SQL, "COMMIT");
	return 1;
}

#include <YSI_Coding\y_hooks>
hook ResetPlayerVariables(playerid)
{
	PlayerInfo[playerid][pForumName] 		= EOS;
	PlayerInfo[playerid][pLastLogin] 		= EOS;
	PlayerInfo[playerid][pSAMPid] 			= EOS;
	PlayerInfo[playerid][pEmail][0] 		= EOS;

	PlayerInfo[playerid][pSecQuestAnswer][0]= EOS;
	PlayerInfo[playerid][pLastUpdateVer] 	= EOS;

	PlayerInfo[playerid][pSQLID] 			= 0; 	//Integer
	PlayerInfo[playerid][pLastLoginTimestamp] = 0;
	PlayerInfo[playerid][pRegistered] 		= 0;
	PlayerInfo[playerid][pSecQuestion] 		= -1;
	PlayerInfo[playerid][pBanned]			= 0;
	PlayerInfo[playerid][pWarns]			= 0;
	PlayerInfo[playerid][pLevel]			= 0;
	PlayerInfo[playerid][pAdmin]			= 0;
	PlayerInfo[playerid][pTempRank][0]		= 0;
	PlayerInfo[playerid][pTempRank][1]		= 0;
	PlayerInfo[playerid][pHelper]			= 0;
	PlayerInfo[playerid][pConnectTime]		= 0;
	PlayerInfo[playerid][pMuted]			= 0;
	PlayerInfo[playerid][pRespects]			= 0;
	PlayerInfo[playerid][pSex]				= 0;
	PlayerInfo[playerid][pAge]				= 0;
	PlayerInfo[playerid][pChangenames]		= 0;
	PlayerInfo[playerid][pChangeTimes]		= 0;
	PlayerInfo[playerid][pMoney]			= 0;
	PlayerInfo[playerid][pBank]				= 0;	
	
	PlayerKeys[playerid][pHouseKey]			= INVALID_HOUSE_ID;
	PlayerKeys[playerid][pRentKey]			= INVALID_HOUSE_ID;
	PlayerKeys[playerid][pBizzKey]			= INVALID_BIZNIS_ID;
	PlayerKeys[playerid][pComplexKey]		= INVALID_COMPLEX_ID;
	PlayerKeys[playerid][pComplexRoomKey]	= INVALID_COMPLEX_ID;
	PlayerKeys[playerid][pGarageKey]		= -1;
	PlayerKeys[playerid][pIllegalGarageKey]	= -1;
	PlayerKeys[playerid][pVehicleKey]		= -1;
	PlayerKeys[playerid][pWarehouseKey] 	= -1;
	PlayerInfo[playerid][pVoted]	 		= false;
	PlayerInfo[playerid][pMustRead]			= false;

	return 1;
}

stock SetPlayerSpawnInfo(playerid)
{
	if(PlayerJail[playerid][pJailed] == 2)
	{
		SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], -10.9639, 2329.3030, 24.4, 0, 0, 0, 0, 0, 0, 0);
		Streamer_UpdateEx(playerid,  -10.9639, 2329.3030, 24.4);
	}
	else if(PlayerJail[playerid][pJailed] == 3)
	{
		SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin],  1199.1404,1305.8285,-54.7172, 0, 0, 0, 0, 0, 0, 0);
		SetPlayerInterior(playerid, 17);
		Streamer_UpdateEx(playerid,  1199.1404,1305.8285,-54.7172);
	}
	else if(PlayerDeath[playerid][pKilled] == 1) 
	{
		SetSpawnInfo(playerid, 0, 
			PlayerAppearance[playerid][pSkin],
			PlayerDeath[playerid][pDeathX] , 
			PlayerDeath[playerid][pDeathY] , 
			PlayerDeath[playerid][pDeathZ] , 
			0, 0, 0, 0, 0, 0, 0
		);
		Streamer_UpdateEx(playerid, 
			PlayerDeath[playerid][pDeathX] , 
			PlayerDeath[playerid][pDeathY] , 
			PlayerDeath[playerid][pDeathZ] 
		);
	}
	else
	{
		switch( PlayerInfo[ playerid ][ pSpawnChange ] ) 
		{
			case 0: 
			{
				SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], SPAWN_X, SPAWN_Y, SPAWN_Z, 0, 0, 0, 0, 0, 0, 0);
				Streamer_UpdateEx(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
			}
			case 1:
			{
				if( ( PlayerKeys[playerid][pHouseKey] != INVALID_HOUSE_ID  ) ||  
					( PlayerKeys[playerid][pRentKey] != INVALID_HOUSE_ID ) )
				{
					new house;
					if(  PlayerKeys[playerid][pHouseKey] != INVALID_HOUSE_ID  )
					{
						house = PlayerKeys[playerid][pHouseKey];
						if(!HouseInfo[house][hFurLoaded])
							ReloadHouseFurniture(house);
						ReloadHouseExterior(house);
					}
					else if( PlayerKeys[playerid][pRentKey] != INVALID_HOUSE_ID )
					{
						house = PlayerKeys[playerid][pRentKey];
						if(!HouseInfo[house][hFurLoaded])
							ReloadHouseFurniture(house);
						ReloadHouseExterior(house);
					}
					SetSpawnInfo(playerid, 0, 
						PlayerAppearance[playerid][pSkin], 
						HouseInfo[ house ][ hEnterX ], 
						HouseInfo[ house ][ hEnterY], 
						HouseInfo[ house ][ hEnterZ ], 
						0, 0, 0, 0, 0, 0, 0
					);
					Streamer_UpdateEx(playerid,
						HouseInfo[ house ][ hEnterX ], 
						HouseInfo[ house ][ hEnterY], 
						HouseInfo[ house ][ hEnterZ ], 
						HouseInfo[ house ][ hVirtualWorld ], 
						HouseInfo[ house ][ hInt ]
					);
				}
				else
				{
					SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], SPAWN_X, SPAWN_Y, SPAWN_Z, 0, 0, 0, 0, 0, 0, 0);
					Streamer_UpdateEx(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
				}
			}
			case 2:
			{
				switch(PlayerFaction[playerid][pMember])
				{
					case 1:
					{
						SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 1543.1218,-1675.8065,13.5558, 0, 0, 0, 0, 0, 0, 0);
						Streamer_UpdateEx(playerid, 1543.1218,-1675.8065,13.5558);
					}
					case 2:
					{
						SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 1179.1440, -1324.0720, 13.9063, 0, 0, 0, 0, 0, 0, 0);
						Streamer_UpdateEx(playerid, 1179.1440, -1324.0720, 13.9063); 
					}
					case 3:
					{
						SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 635.5733,-572.5349,16.3359, 0, 0, 0, 0, 0, 0, 0);
						Streamer_UpdateEx(playerid, 635.5733,-572.5349,16.3359);
					}
					case 4:
					{
						SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 1481.0284,-1766.5795,18.7958, 0, 0, 0, 0, 0, 0, 0);
						Streamer_UpdateEx(playerid, 1481.0284,-1766.5795,18.7958);
					}
					case 5:
					{
						SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 1415.0668,-1177.3187,25.9922, 0, 0, 0, 0, 0, 0, 0);
						Streamer_UpdateEx(playerid, 1466.6505,-1172.4191,23.8956);
					}
					default:
					{
						SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], SPAWN_X, SPAWN_Y, SPAWN_Z, 0, 0, 0, 0, 0, 0, 0);
						Streamer_UpdateEx(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
					}
				}
			} 
			case 3:
			{
				if( PlayerKeys[playerid][pComplexRoomKey] != INVALID_COMPLEX_ID )
				{
					new complex = PlayerKeys[playerid][pComplexRoomKey];
					SetSpawnInfo(playerid, 0, 
						PlayerAppearance[playerid][pSkin], 
						ComplexRoomInfo[complex][cExitX], 
						ComplexRoomInfo[complex][cExitY], 
						ComplexRoomInfo[complex][cExitZ], 
						0, 0, 0, 0, 0, 0, 0
					);
					Streamer_UpdateEx(playerid, 
						ComplexRoomInfo[complex][cExitX], 
						ComplexRoomInfo[complex][cExitY], 
						ComplexRoomInfo[complex][cExitZ], 
						ComplexRoomInfo[complex][cViwo], 
						ComplexRoomInfo[complex][cInt]
					);
				}
				else
				{
					SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], SPAWN_X, SPAWN_Y, SPAWN_Z, 0, 0, 0, 0, 0, 0, 0);
					Streamer_UpdateEx(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
				}
			}
			
			case 4:
			{
				SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 738.8747,-1415.2773,13.5168, 0, 0, 0, 0, 0, 0, 0);
				Streamer_UpdateEx(playerid, 738.8747,-1415.2773,13.5168);
			}
			case 5:
			{
				SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], 2139.9543,-2167.1189,13.5469, 0, 0, 0, 0, 0, 0, 0);
				Streamer_UpdateEx(playerid, 2139.9543,-2167.1189,13.5469);
			}
			default:
			{
				SetSpawnInfo(playerid, 0, PlayerAppearance[playerid][pSkin], SPAWN_X, SPAWN_Y, SPAWN_Z, 0, 0, 0, 0, 0, 0, 0);
				Streamer_UpdateEx(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
			}
		}
	}
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

#include <YSI_Coding\y_hooks>
hook OnPlayerDisconnect(playerid, reason)
{
	if(SigningIn[playerid])
		stop LoginCheckTimer[playerid];

	SigningIn[playerid] = false;
	Player_SetSecurityBreach(playerid, false);
	SetPlayerOnlineStatus(playerid, 0);
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_LOGIN:
		{
			if(!response) 
				Kick(playerid);

			if(isnull(inputtext))
			{
				format(dialogtext, sizeof(dialogtext), 
					""COL_RED"You have left empty input password field!\n\
						"COL_WHITE"Check your upper/lower case sensitivity and try again.\n\
						You have "COL_LIGHTBLUE"%d "COL_WHITE"attempts to input valid password!\n\n\n\
						"COL_RED"If you exceed max attempt limit, you will be kicked!", 
					MAX_LOGIN_TRIES - Bit8_Get(gr_LoginInputs, playerid)
				);

				ShowPlayerDialog(playerid, 
					DIALOG_LOGIN, 
					DIALOG_STYLE_PASSWORD, 
					""COL_WHITE"Login", 
					dialogtext, 
					"Proceed", 
					"Abort"
				);
				Bit8_Set(gr_LoginInputs, playerid, Bit8_Get(gr_LoginInputs, playerid) + 1);
				return 1;
			}
			if( !( MAX_LOGIN_TRIES - Bit8_Get(gr_LoginInputs, playerid) ) )
			{
				//Kick
				va_SendClientMessage(playerid, COLOR_RED, 
					"[%s]: You reached %d unsucessful login attempts and you got an IP ban!",
					SERVER_NAME,
					MAX_LOGIN_TRIES
				);
				BanMessage(playerid);
				return 1;
			}
			new input_password[12];
			strcpy(input_password, inputtext, 12);
			inline PasswordForQuery()
			{
				new sqlid, sql_password[BCRYPT_HASH_LENGTH];

				cache_get_value_name_int(0, "sqlid", sqlid);
				cache_get_value_name(0, "password", sql_password, BCRYPT_HASH_LENGTH);
			
				bcrypt_check(input_password, sql_password,  "OnPasswordChecked", "d", playerid);
				return 1;
			}
			MySQL_TQueryInline(g_SQL, 
				using inline PasswordForQuery,
				va_fquery(g_SQL, "SELECT sqlid, password FROM accounts WHERE name = '%e'", GetName(playerid, false)) 
			);
			return 1;
		}
		case DIALOG_SEC_SAMPID:
		{
		    if(!response)
				return Kick(playerid);

			if( strfind(inputtext, "%", true) != -1 || strfind(inputtext, "=", true) != -1 || 
				strfind(inputtext, "+", true) != -1 || strfind(inputtext, "'", true) != -1 || 
				strfind(inputtext, ">", true) != -1 || strfind(inputtext, "^", true) != -1 || 
				strfind(inputtext, "|", true) != -1 || strfind(inputtext, "?", true) != -1 || 
				strfind(inputtext, "*", true) != -1 || strfind(inputtext, "#", true) != -1 || 
				strfind(inputtext, "!", true) != -1 || strfind(inputtext, "$", true) != -1 )
				return Kick(playerid);
			
			if(isnull(inputtext))
			    return Kick(playerid);
			    
			if(strlen(inputtext) > 31)
			    return Kick(playerid);
			    
            if(!strcmp(inputtext, PlayerInfo[playerid][pSecQuestAnswer]))
            {
				Player_SetSecurityBreach(playerid, false);

				#if defined MODULE_LOGS
                Log_Write("logfiles/GPCI.txt", 
					"(%s) Player %s[%d]{%d}<%s> logged in with unknown GPCI for his account.", 
					ReturnDate(), 
					GetName(playerid), 
					playerid, 
					PlayerInfo[playerid][pSQLID], 
					ReturnPlayerIP(playerid)
				);
				#endif
				
				new log_gpci[128];
				format(log_gpci, 
					sizeof(log_gpci), 
					"Player %s[%d] logged in with unknown GPCI for his account!", 
					GetName(playerid), 
					playerid
				);
				ABroadCast(COLOR_LIGHTRED, log_gpci, 1);
				gpci(playerid, PlayerInfo[playerid][pSAMPid], 128);
				
				Bit1_Set(gr_PlayerLoggedIn, playerid, true);
				SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Please wait for 5 seconds. Loading in progres...");
				defer FinishPlayerSpawn(playerid);
				return 1;
            }
            else
			{
			    if(-- secquestattempt[playerid] == 0)
			    {
			        ClearPlayerChat(playerid);
			        
			        SendClientMessage(playerid, COLOR_RED, "You account is now locked by security system!");
			        va_SendClientMessage(playerid, COLOR_RED, "Please post an unban request on %s.", WEB_URL);

					#if defined MODULE_BANS
					HOOK_Ban(playerid, INVALID_PLAYER_ID, "Wrong safety answer", -3,  true);
					#endif
					return 1;
				}
				else
				{
				    va_SendClientMessage(playerid, 
						COLOR_RED, 
						"If you don't remember your safety answer, please contact our Developers on %s!",
						WEB_URL
					);

    				va_ShowPlayerDialog(playerid,
						DIALOG_SEC_SAMPID, 
						DIALOG_STYLE_PASSWORD, 
						""COL_RED"SECURITY BREACH", 
						""COL_WHITE"Please answer the safety question if you want to proceed.\n\
							Attempts left: "COL_RED"%d\n\
							\n"COL_WHITE"%s", 
						"Answer", 
						"Abort", 
						secquestattempt[playerid], 
						secQuestions[PlayerInfo[playerid][pSecQuestion]]
					);
				}
			}
			return 1;
		}
		case DIALOG_REGISTER:
		{
			#if defined COA_UCP
				va_SendClientMessage(playerid, COLOR_RED, "You haven't registered your account on %s!", WEB_URL);
				KickMessage(playerid);
			#else
				if(!response) 
					Kick(playerid);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_AGREE, 
					DIALOG_STYLE_MSGBOX, 
					""COL_WHITE"Sign Up - EULA(2/6)", 
					""COL_WHITE"With accepting, you agree that while gaming on our server\n\
						you won't be breaking server rules, exploiting bugs/glitches,\n\
						insult other players, making false pretenses, use malicious software,\n\
						hacks, cheats, or in any other way obstruct pleasant gaming experience\n\
						to other players on this server.\n\
						"COL_RED"CAUTION: "COL_WHITE"Breaking EULA(End User License Agreement)\n\
						will lead to "COL_RED"serious "COL_WHITE"sanctions.\n\
						If you accept our EULA, please klick "COL_LIGHTBLUE"\"Accept\""COL_WHITE"!",
					"I agree", 
					"Abort"
				);
			#endif
		}
		case DIALOG_REG_AGREE:
		{
			if(!response) 
			{
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Welcome "COL_LIGHTBLUE"%s!\n\n\
						"COL_WHITE"Your account isn't registered on our server.\n\
						If you want to Sign Up, please press \"Register\".\n\
						Otherwise, you'll be kicked out of the server!",GetName(playerid)
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REGISTER, 
					DIALOG_STYLE_MSGBOX, 
					""COL_WHITE"Sign Up (1/6)", 
					dialogtext, 
					"Register", 
					"Abort"
				);
				return 1;
			}

			format(dialogtext, sizeof(dialogtext), 
				""COL_WHITE"Please enter a password for your account.\n\
					Don't share your account password with anyone!\n\
					\nPassword must be "COL_LIGHTBLUE"6-12 "COL_WHITE"characters long."
			);

			ShowPlayerDialog(playerid, 
				DIALOG_REG_PASS, 
				DIALOG_STYLE_PASSWORD, 
				""COL_WHITE"Sign Up - Password(3/6)", 
				dialogtext, 
				"Input", 
				"Abort"
			);
		}
		case DIALOG_REG_PASS:
		{
			if(!response) 
			{
				ShowPlayerDialog(playerid, 
					DIALOG_REG_AGREE, 
					DIALOG_STYLE_MSGBOX, 
					""COL_WHITE"Sign Up - EULA(2/6)", 
					""COL_WHITE"With accepting, you agree that while gaming on our server\n\
						you won't be breaking server rules, exploiting bugs/glitches,\n\
						insult other players, making false pretenses, use malicious software,\n\
						hacks, cheats, or in any other way obstruct pleasant gaming experience\n\
						to other players on this server.\n\
						"COL_RED"CAUTION: "COL_WHITE"Breaking EULA(End User License Agreement)\n\
						will lead to "COL_RED"serious "COL_WHITE"sanctions.\n\
						If you accept our EULA, please klick "COL_LIGHTBLUE"\"Accept\""COL_WHITE"!",
					"Accept", 
					"Decline"
				);
				return 1;
			}
			
			if(isnull(inputtext) || !strlen(inputtext))
			{
				format(dialogtext, sizeof(dialogtext), 
					""COL_WHITE"Please enter a password for your account.\n\
						Don't share your account password with anyone!\n\
						\nPassword must be "COL_LIGHTBLUE"6-12 "COL_WHITE"characters long.\n\
						"COL_RED"\nYour input password field was empty!\""
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_PASS, 
					DIALOG_STYLE_PASSWORD, 
					""COL_WHITE"Sign Up - Password(3/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
			if( strfind(inputtext, "%", true) != -1 || strfind(inputtext, "\n", true) != -1 || 
				strfind(inputtext, "=", true) != -1 || strfind(inputtext, "+", true) != -1 || 
				strfind(inputtext, "'", true) != -1 || strfind(inputtext, ">", true) != -1 || 
				strfind(inputtext, "^", true) != -1 || strfind(inputtext, "|", true) != -1 || 
				strfind(inputtext, "?", true) != -1 || strfind(inputtext, "*", true) != -1 || 
				strfind(inputtext, "#", true) != -1 || strfind(inputtext, "!", true) != -1 || 
				strfind(inputtext, "$", true) != -1 )
			{
				format(dialogtext, sizeof(dialogtext), 
					""COL_WHITE"Please enter a password for your account.\n\
						Don't share your account password with anyone!\n\
						\nPassword must be "COL_LIGHTBLUE"6-12 "COL_WHITE"characters long.\n\
						"COL_RED"\nYour input can't contain: "COL_WHITE"%+^|?*#!$>' "COL_RED"in password!\""
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_PASS, 
					DIALOG_STYLE_PASSWORD, 
					""COL_WHITE"Sign Up - Password(3/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
			if(6 <= strlen(inputtext) <= 12) 
			{
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Please enter valid E-Mail for safety\nof your account:"
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_MAIL, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - E-Mail(4/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				format(PlayerInfo[playerid][pPassword], BCRYPT_HASH_LENGTH, inputtext);
				Bit8_Set(gr_RegisterInputs, playerid, 0);
				return 1;
			}
			if( (Bit8_Get(gr_RegisterInputs, playerid)) > 3 )
			{
				SendClientMessage(playerid, COLOR_RED, 
					"[ ! ]: You have reached a maximal limit of wrong register inputs. You have been kicked from server.");
				KickMessage(playerid);
				return 1;
			}
			else 
			{
				format(dialogtext, sizeof(dialogtext), 
					""COL_WHITE"Please enter a password for your account.\n\
						Don't share your account password with anyone!\n\
						\nPassword must be "COL_LIGHTBLUE"6-12 "COL_WHITE"characters long."
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_PASS, 
					DIALOG_STYLE_PASSWORD, 
					""COL_WHITE"Sign Up - Password(3/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
		}
		case DIALOG_REG_MAIL:
		{
			if(!response) 
			{
				format(dialogtext, sizeof(dialogtext), 
					""COL_WHITE"Please enter a password for your account.\n\
						Don't share your account password with anyone!\n\
						\nPassword must be "COL_LIGHTBLUE"6-12 "COL_WHITE"characters long."
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_PASS, 
					DIALOG_STYLE_PASSWORD, 
					""COL_WHITE"Sign Up - Password(3/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				return 1;
			}
			if(!strlen(inputtext) || isnull(inputtext)) 
			{
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Please enter valid E-Mail for safety\nof your account:\n\
						\n"COL_RED"Your input field was empty!"
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_MAIL, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - E-Mail(4/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
			if( strfind(inputtext, "%", true) != -1 || strfind(inputtext, "\n", true) != -1 
				|| strfind(inputtext, "=", true) != -1 || strfind(inputtext, "+", true) != -1 
				|| strfind(inputtext, "'", true) != -1 || strfind(inputtext, ">", true) != -1 
				|| strfind(inputtext, "^", true) != -1 || strfind(inputtext, "|", true) != -1 
				|| strfind(inputtext, "?", true) != -1 || strfind(inputtext, "*", true) != -1 
				|| strfind(inputtext, "#", true) != -1 || strfind(inputtext, "!", true) != -1 
				|| strfind(inputtext, "$", true) != -1 )
			{	
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Please enter valid E-Mail for safety\nof your account:\n\
						"COL_RED"\nYour input can't contain: "COL_WHITE"%+^|?*#!$>' "COL_RED"in E-Mail adress!"
				);
				
				ShowPlayerDialog(playerid, 
					DIALOG_REG_MAIL, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - E-mail(4/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
			if(!IsValidEMail(inputtext)) 
			{
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Please enter valid E-Mail for safety\nof your account:\n\
						\n"COL_RED"E-Mail adress you entered isn't valid!"
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_MAIL, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - E-Mail(4/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
			if(IsEMailInDB(inputtext)) 
			{
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Please enter valid E-Mail for safety\nof your account:\n\
						\n"COL_RED"E-Mail is already registered in database!"
				);

				ShowPlayerDialog(playerid, 
					DIALOG_REG_MAIL, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - E-Mail(4/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				Bit8_Set(gr_RegisterInputs, playerid, Bit8_Get(gr_RegisterInputs, playerid) + 1);
				return 1;
			}
			if( (Bit8_Get(gr_RegisterInputs, playerid)) > 3 )
			{
				SendClientMessage(playerid, COLOR_RED,
					"[ ! ]: You have reach maximal limit of wrong inputs on registration. You have been kicked."
				);
				KickMessage(playerid);
				return 1;
			}
			format(PlayerInfo[playerid][pEmail], MAX_PLAYER_MAIL, "%s", inputtext);
			Bit8_Set(gr_RegisterInputs, playerid, 0);
			ShowPlayerDialog(playerid, 
				DIALOG_REG_SEX, 
				DIALOG_STYLE_LIST, 
				""COL_WHITE"Sign Up - Spol(5/6)", 
				"Male\nFemale", 
				"Input", 
				"Abort"
			);
		}
		case DIALOG_REG_SEX:
		{
			if(!response) 
			{
				format(dialogtext, 
					sizeof(dialogtext), 
					""COL_WHITE"Please enter valid E-Mail for safety\nof your account:"
				);
				ShowPlayerDialog(playerid, 
					DIALOG_REG_MAIL, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - E-Mail(4/6)", 
					dialogtext, 
					"Input", 
					"Abort"
				);
				return 1;
			}
			switch(listitem)
			{
				case 0: PlayerInfo[playerid][pSex] = 1; //musko
				case 1: PlayerInfo[playerid][pSex] = 2; //zensko
			}
			ShowPlayerDialog(playerid, 
				DIALOG_REG_AGE, 
				DIALOG_STYLE_INPUT, 
				""COL_WHITE"SIGN UP - Age(6/6)", 
				""COL_WHITE"How old is your character?\n\
				\n"COL_RED"CAUTION:"COL_WHITE"Minimal age is 16, maximal 80!", 
				"Input", 
				"Abort"
			);
		}
		case DIALOG_REG_AGE:
		{
			if(!response) 
			{
				ShowPlayerDialog(playerid, 
					DIALOG_REG_SEX, 
					DIALOG_STYLE_LIST, 
					""COL_WHITE"Sign Up - Sex(5/6)", 
					"Male\nFemale", 
					"Input", 
					"Abort"
				);
				return 1;
			}
			
			if (!strlen(inputtext)) // Nothing typed in
			{
				ShowPlayerDialog(playerid, 
					DIALOG_REG_AGE, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"SIGN UP - Age(6/6)", 
					""COL_WHITE"How old is your character?\n\
					\n"COL_RED"CAUTION:"COL_WHITE"Minimal age is 16, maximal 80!", 
					"Input", 
					"Abort"
				);
				return 1;
			}
			if (strval(inputtext) >= 16 && strval(inputtext) <= 80)
			{
				PlayerInfo[playerid][pAge] = strval(inputtext);
				RegisterPlayer(playerid);
			}
			else 
			{
				ShowPlayerDialog(playerid, 
					DIALOG_REG_AGE, 
					DIALOG_STYLE_INPUT, 
					""COL_WHITE"Sign Up - Age(6/6)", 
					""COL_WHITE"How old is your character?\n\
					\n"COL_RED"CAUTION:"COL_WHITE"Minimal age is 16, maximal 80!", 
					"Input", 
					"Abort"
				);
				return 1;
			}
		}
	}
	return 0;
}