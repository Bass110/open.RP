#include <YSI_Coding\y_hooks>

/*
	########  ######## ######## #### ##    ## ########  ######  
	##     ## ##       ##        ##  ###   ## ##       ##    ## 
	##     ## ##       ##        ##  ####  ## ##       ##       
	##     ## ######   ######    ##  ## ## ## ######    ######  
	##     ## ##       ##        ##  ##  #### ##             ## 
	##     ## ##       ##        ##  ##   ### ##       ##    ## 
	########  ######## ##       #### ##    ## ########  ######  
*/
// new edit by Woo - 22.12.17. - Matt
#define SLOT_ZADAH                  (9)                                         //Attach Object Slot

// Snijeg
#define SNOW_OBJECT 			(18864)
#define MAX_SNOW_FLAKES			(2)
#define COLOR_ICE        		(0xA0E1EBFF)
#define SNOWING_RANGE			(55.0)


/*
	##     ##    ###    ########   ######  
	##     ##   ## ##   ##     ## ##    ## 
	##     ##  ##   ##  ##     ## ##       
	##     ## ##     ## ########   ######  
	 ##   ##  ######### ##   ##         ## 
	  ## ##   ##     ## ##    ##  ##    ## 
	   ###    ##     ## ##     ##  ######  
*/
// new edit by Woo - 22.12.17. - Matt
//new bool:PlayerIceSkates[MAX_PLAYERS] = false
//new IceUpdateTimer[MAX_PLAYERS];

static stock
	CurrentlyServerTemperature = 5,
	// 32 bit
	temperatureUpdateTime[ MAX_PLAYERS ],
	snowObject[ MAX_PLAYERS ][ 2 ],
	snowBallObj[ MAX_PLAYERS ],
	snowBallTarget[ MAX_PLAYERS ],
	snowTimer[ MAX_PLAYERS ],
	Float:snowPos[ MAX_PLAYERS ][ 3 ],
	Float:snowBallTargetPos[ MAX_PLAYERS ][ 3 ],
	iceArea[ 8 ],
	PlayerText:tempTextdraw[ 3 ][ MAX_PLAYERS ],
	bool:ServerSnowing = false,
	Float:FireBarrelPos[12][3] =
	{
		{2074.65454, -1821.76636, 13.15000},
		{2126.18091, -1759.99414, 13.15000},
		{2087.87183, -1746.06970, 13.15000},
		{1539.78687, -1722.13403, 13.15000},
		{1953.59644, -1941.10718, 13.12000},
		{1829.99304, -1604.07385, 13.15000},
		{1951.22852, -1759.74854, 13.15000},
		{2101.11499, -1605.39197, 13.15000},
		{1962.13550, -1144.06982, 25.55000},
		{2241.75928, -1311.16870, 23.55000},
		{2219.68018, -1656.52075, 14.95000},
		{2421.25488, -2001.52905, 13.15000}
	},
	
	// rBits
	Bit1: gr_PlayerSnowing <MAX_PLAYERS>,
	Bit1: gr_PlayerHaveSnowBall <MAX_PLAYERS>,
	Bit1: gr_PlayerOutside <MAX_PLAYERS>,
	Bit1: gr_PlayerNearFireBarrel <MAX_PLAYERS>,
	Bit1: gr_PlayerInsideIce <MAX_PLAYERS>,
	Bit1: gr_SlidOnIce <MAX_PLAYERS>,
	Bit1: gr_PlayerUsingTemp <MAX_PLAYERS>;

/*
	 ######  ########  #######   ######  ##    ##  ######  
	##    ##    ##    ##     ## ##    ## ##   ##  ##    ## 
	##          ##    ##     ## ##       ##  ##   ##       
	 ######     ##    ##     ## ##       #####     ######  
		  ##    ##    ##     ## ##       ##  ##         ## 
	##    ##    ##    ##     ## ##    ## ##   ##  ##    ## 
	 ######     ##     #######   ######  ##    ##  ######  
*/
stock ResetWinterVars(playerid)
{
	Bit1_Set( gr_PlayerInsideIce, playerid ,false );
	Bit1_Set( gr_SlidOnIce, playerid, false );
	//DestroyTempTextDraws(playerid);
	Bit1_Set( gr_PlayerOutside, playerid, false );
	
	snowPos[ playerid ][ 0 ] = snowPos[ playerid ][ 1 ] = snowPos[ playerid ][ 2 ] = 0.0;
	if( Bit1_Get(gr_PlayerSnowing,playerid) ) {
		DestroyPlayerSnow(playerid);
	}
	/*if( SkiInfo[ playerid ][ spVehicleId ] != 0 ) {
		DestroyVehicle(SkiInfo[ playerid ][ spVehicleId ]);
		SkiInfo[ playerid ][ spVehicleId ] = 0;
		
		for( new i = 0; i < 12; i++ ) {
			if( IsValidDynamicObject(SkiInfo[ playerid ][ spObject ][ i ]) ) {
				DestroyDynamicObject(SkiInfo[ playerid ][ spObject ][ i ]);
				SkiInfo[ playerid ][ spObject ][ i ] = INVALID_OBJECT_ID;
			}
		}
	}*/
	return 1;
}

stock SetServerWeather()
{
    // Get Server Time
	WeatherTimer = gettimestamp() + 3000;
    new hours, minute, seconds, wstring[80], temp = CurrentlyServerTemperature;  
	gettime(hours, minute, seconds);
	
    // Od 06:00(jutro) do 12(podne)
    if(hours >= 6 && hours <= 12)
    {
        temp = minrand(2, 6);
        CurrentlyServerTemperature = temp;
    }
    // Od 13:00(podne) do 18(predvecer)
    else if(hours >= 13 && hours <= 18)
    {
        temp = minrand(6, 9);
        CurrentlyServerTemperature = temp;
    }
    // Od 19:00(vecer) do 18(predvecer)
    else if(hours >= 19 && hours <= 22)
    {
        temp = minrand(-3, 3);
        CurrentlyServerTemperature = temp;
    }
    // Od 23:00(vecer) do 00:05(vecer)
    else if(hours >= 23 && hours <= 5)
    {
        temp = minrand(-10, -3);
        CurrentlyServerTemperature = temp;
		
    }
	format(wstring, sizeof(wstring), "[811 NEWS]: Trenutno je %02d:%02d sati, a temperatura iznosi %d�C.", hours+1,minute,temp);
    SendClientMessageToAll(COLOR_ORANGE, wstring);
	DynamicWeather();
    return 1;
}

/* stock AddSnowObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:d_stream = 200.0)
{
    new
            object = CreateDynamicObject(modelid, (x + 0.075), (y + 0.15), (z + 0.15), rx, ry, rz, .streamdistance = d_stream);
    for(new a = 0; a < 30; a++)
        SetDynamicObjectMaterial(object, a, 17944, "lngblok_lae2", "white64bumpy");
    return object;
} */

/*
	.d8888. d8b   db d888888b    d88b d88888b  d888b  
	88'  YP 888o  88   88'      8P' 88'     88' Y8b 
	8bo.   88V8o 88    88        88  88ooooo 88      
	  Y8b. 88 V8o88    88        88  88~~~~~ 88  ooo 
	db   8D 88  V888   .88.   db. 88  88.     88. ~8~ 
	8888Y' VP   V8P Y888888P Y8888P  Y88888P  Y888P  
*/
stock StartSnowFallingForPlayer(playerid)
{
	if( !ServerSnowing ) 					return 0;
	if( !IsPlayerAlive(playerid) ) 			return 0;
	if( GetPlayerInterior(playerid) != 0 ) 	return 0;
	if( GetPlayerState(playerid) == PLAYER_STATE_NONE || GetPlayerState(playerid) == PLAYER_STATE_WASTED || GetPlayerState(playerid) == PLAYER_STATE_SPECTATING  )
		return 0;
	
	Bit1_Set(gr_PlayerSnowing, playerid, true);
	
	new
		Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	
	snowObject[ playerid ][ 0 ] = CreatePlayerObject(playerid, SNOW_OBJECT, X, Y, Z, 0.0, 0.0, 90.0, 0.0);
	MoveSnowObject(playerid, snowObject[ playerid ][0]);
	
	GetXYInFrontOfPlayer(playerid, X, Y, 1.5);
	snowObject[ playerid ][ 1 ] = CreatePlayerObject(playerid, SNOW_OBJECT, X, Y, Z, 0.0, 0.0, 24.0, 0.0);
	MoveSnowObject(playerid, snowObject[ playerid ][1]);
	return 1;
}

stock static MoveSnowObject(playerid, objectid)
{
	if( !Bit1_Get( gr_PlayerSnowing, playerid ) ) return 0;
		
	new
		Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	GetXYInFrontOfPlayer(playerid, x, y, 1);
	SetPlayerObjectPos(playerid, objectid, x, y, z);
	MovePlayerObject(playerid, objectid, x, y, z - 0.00000000000001, 0.00000000000000001);
	return 1;
}

stock DestroyPlayerSnow(playerid)
{
	if( !ServerSnowing ) 							return 0;
	if( !IsPlayerConnected(playerid) ) 				return 0;
	if( !Bit1_Get( gr_PlayerSnowing, playerid ) ) 	return 0;
	
	KillTimer(snowTimer[playerid]);
	Bit1_Set(gr_PlayerSnowing,playerid,false);
	DestroyPlayerObject(playerid, snowObject[playerid][0]);
	DestroyPlayerObject(playerid, snowObject[playerid][1]);
	return 1;
}

/*
	db      d88888b d8888b.
	88      88'     88  8D
	88      88ooooo 88   88
	88      88~~~~~ 88   88
	88booo. 88.     88  .8D
	Y88888P Y88888P Y8888D'
*/
stock IceCheck(playerid)
{
    new
		Float:vx, Float:vy, Float:vz,
		keys, ud, lr,
		Float:health;

	if( Bit1_Get( gr_PlayerInsideIce, playerid ) ) {
		if( !Bit1_Get( gr_SlidOnIce, playerid ) ) {
			switch( random(random(100)) ) {
				case 5, 8, 18, 25, 63, 42, 96, 50: {
					if( IsPlayerInAnyVehicle(playerid) && !( IsAHelio(GetVehicleModel(GetPlayerVehicleID(playerid))) || IsAPlane(GetVehicleModel(GetPlayerVehicleID(playerid))) ) ) {
						GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);
						if( ( floatsqroot( ( ( vx * vx ) + ( vy * vy ) ) + ( vz * vz ) ) * 181.5 ) >= 70.0 ) {
							SetVehicleAngularVelocity(GetPlayerVehicleID(playerid), 0.0, 0.0, 0.1);
						}
					} else {
						GetPlayerKeys(playerid, keys, ud, lr);
						if( keys & KEY_SPRINT ) {
							GetPlayerHealth(playerid, health);
							ClearAnimations(playerid);
							ApplyAnimationEx(playerid, "ped", "KO_skid_back", 4.1, 0, 0, 0, 1000, 1, 0);
							SetPlayerHealth(playerid, health-2.5);
						}
					}
					Bit1_Set( gr_SlidOnIce, playerid, true );
				}
			}
		} else
			Bit1_Set( gr_SlidOnIce, playerid, false );
	}
	return 1;
}

forward OnPlayerSnowingMove(playerid);
public OnPlayerSnowingMove(playerid)
{
	if( !IsPlayerAlive(playerid) ) 					return 0;
	if( !Bit1_Get( gr_PlayerSnowing, playerid ) ) 	return 0;
	if( GetPlayerInterior(playerid) ) {
		DestroyPlayerSnow(playerid);
		return 0;
	}
	
	if( GetPlayerDistanceFromPoint(playerid, snowPos[ playerid ][ 0 ], snowPos[ playerid ][ 1 ], snowPos[ playerid ][ 2 ]) > SNOWING_RANGE ) {
		GetPlayerPos(playerid, snowPos[ playerid ][ 0 ], snowPos[ playerid ][ 1 ], snowPos[ playerid ][ 2 ]);
		MoveSnowObject(playerid, snowObject[ playerid ][ 0 ]);
		MoveSnowObject(playerid, snowObject[ playerid ][ 1 ]);
	}
	return 1;
}

/*
	d888888b d88888b .88b  d88. d8888b. d88888b d8888b.  .d8b.  d888888b db    db d8888b.  .d8b.
	~~88~~' 88'     88'YbdP88 88  8D 88'     88  8D d8' 8b ~~88~~' 88    88 88  8D d8' 8b
	   88    88ooooo 88  88  88 88oodD' 88ooooo 88oobY' 88ooo88    88    88    88 88oobY' 88ooo88
	   88    88~~~~~ 88  88  88 88~~~   88~~~~~ 888b   88~~~88    88    88    88 888b   88~~~88
	   88    88.     88  88  88 88      88.     88 88. 88   88    88    88b  d88 88 88. 88   88
	   YP    Y88888P YP  YP  YP 88      Y88888P 88   YD YP   YP    YP    ~Y8888P' 88   YD YP   YP
*/
/* stock CreateTempTextdraws(playerid)
{
	DestroyTempTextDraws(playerid);
	
	new
	    string[5];
	Bit1_Set( gr_PlayerUsingTemp, playerid, true );

	tempTextdraw[ playerid ][ 0 ] = CreatePlayerTextDraw(playerid, 507.000091, 114.903678, "Temp:");
	PlayerTextDrawLetterSize(playerid, tempTextdraw[ playerid ][ 0 ], 0.449999, 1.600000);
	PlayerTextDrawColor(playerid, tempTextdraw[ playerid ][ 0 ], -1);
	PlayerTextDrawSetOutline(playerid, tempTextdraw[ playerid ][ 0 ], 1);
	PlayerTextDrawBackgroundColor(playerid, tempTextdraw[ playerid ][ 0 ], 51);
	PlayerTextDrawFont(playerid, tempTextdraw[ playerid ][ 0 ], 1);
	PlayerTextDrawAlignment(playerid, tempTextdraw[ playerid ][ 0 ], 1);
	PlayerTextDrawSetShadow(playerid, tempTextdraw[ playerid ][ 0 ], 0);
	PlayerTextDrawSetProportional(playerid, tempTextdraw[ playerid ][ 0 ], 1);
	PlayerTextDrawShow(playerid, tempTextdraw[ playerid ][ 0 ]);

	tempTextdraw[ playerid ][ 1 ] = CreatePlayerTextDraw(playerid, 591.666687, 110.181480, "usebox");
	PlayerTextDrawLetterSize(playerid, tempTextdraw[ playerid ][ 1 ], 0.000000, 3.047942);
	PlayerTextDrawTextSize(playerid, tempTextdraw[ playerid ][ 1 ], 500.333343, 0.000000);
	PlayerTextDrawColor(playerid, tempTextdraw[ playerid ][ 1 ], 0);
	PlayerTextDrawUseBox(playerid, tempTextdraw[ playerid ][ 1 ], true);
	PlayerTextDrawBoxColor(playerid, tempTextdraw[ playerid ][ 1 ], 102);
	PlayerTextDrawSetOutline(playerid, tempTextdraw[ playerid ][ 1 ], 0);
	PlayerTextDrawAlignment(playerid, tempTextdraw[ playerid ][ 1 ], 1);
	PlayerTextDrawSetShadow(playerid, tempTextdraw[ playerid ][ 1 ], 0);
	PlayerTextDrawFont(playerid, tempTextdraw[ playerid ][ 1 ], 0);
	PlayerTextDrawShow(playerid, tempTextdraw[ playerid ][ 1 ]);

    tempTextdraw[ playerid ][ 2 ] = CreatePlayerTextDraw(playerid, 558.666687, 117.392547, "0.0");
	PlayerTextDrawLetterSize(playerid, tempTextdraw[ playerid ][ 2 ], 0.320000, 1.371851);
	PlayerTextDrawAlignment(playerid, tempTextdraw[ playerid ][ 2 ], 1);
	PlayerTextDrawColor(playerid, tempTextdraw[ playerid ][ 2 ], COLOR_ICE);
	PlayerTextDrawSetShadow(playerid, tempTextdraw[ playerid ][ 2 ], 0);
	PlayerTextDrawSetOutline(playerid, tempTextdraw[ playerid ][ 2 ], 1);
	PlayerTextDrawBackgroundColor(playerid, tempTextdraw[ playerid ][ 2 ], 51);
	PlayerTextDrawFont(playerid, tempTextdraw[ playerid ][ 2 ], 1);
	PlayerTextDrawSetProportional(playerid, tempTextdraw[ playerid ][ 2 ], 1);
	format(string, sizeof(string), "%.1f", PlayerInfo[ playerid ][ pTemperature ]);
	PlayerTextDrawSetString(playerid, tempTextdraw[ playerid ][ 2 ], string);
	PlayerTextDrawShow(playerid, tempTextdraw[ playerid ][ 2 ]);
	return 1;
}

stock DestroyTempTextDraws(playerid)
{
	Bit1_Set( gr_PlayerUsingTemp, playerid, false );
	
	if( tempTextdraw[playerid][0] != PlayerText:INVALID_TEXT_DRAW ) {
		PlayerTextDrawDestroy(playerid, tempTextdraw[playerid][0]);
		tempTextdraw[playerid][0] = PlayerText:INVALID_TEXT_DRAW;
	}
	if( tempTextdraw[playerid][1] != PlayerText:INVALID_TEXT_DRAW ) {
		PlayerTextDrawDestroy(playerid, tempTextdraw[playerid][1]);
		tempTextdraw[playerid][1] = PlayerText:INVALID_TEXT_DRAW;
	}
	if( tempTextdraw[playerid][2] != PlayerText:INVALID_TEXT_DRAW ) {
		PlayerTextDrawDestroy(playerid, tempTextdraw[playerid][2]);
		tempTextdraw[playerid][2] = PlayerText:INVALID_TEXT_DRAW;
	}
	return 1;
}
 */
/* stock IsPlayerNearFireBarrel(playerid)
{
	Bit1_Set( gr_PlayerNearFireBarrel, playerid, false );
	for(new i=0;i<12;i++) {
	    if( IsPlayerInRangeOfPoint(playerid, 3.0, FireBarrelPos[i][0], FireBarrelPos[i][1], FireBarrelPos[i][2]) ) {
	        Bit1_Set( gr_PlayerNearFireBarrel, playerid, true );
			break;
		}
	}
	if( Bit1_Get( gr_PlayerNearFireBarrel, playerid ) )
	    return 1;
	else
	    return 0;
} */

/* stock TemperatureCheck(playerid)
{
	new
		Float:health, string[5];
	if( Bit1_Get( gr_PlayerOutside, playerid ) && IsPlayerNearFireBarrel(playerid) ) {
		if( PlayerInfo[ playerid ][ pTemperature ] < 36.5 ) {
			PlayerInfo[ playerid ][ pTemperature ] += 0.05;
	    	format(string, sizeof(string), "%.1f", PlayerInfo[ playerid ][ pTemperature ]);
	    	PlayerTextDrawSetString(playerid, tempTextdraw[ playerid ][ 2 ], string);
		}
	} 
	else if( Bit1_Get( gr_PlayerOutside, playerid ) && PlayerInfo[ playerid ][ pTemperature ] <= 32.0 ) {
		GetPlayerHealth(playerid, health);
		SetPlayerHealth(playerid, health - 0.35);
	} 
	else if( Bit1_Get( gr_PlayerOutside, playerid ) && !IsPlayerNearFireBarrel(playerid) && PlayerInfo[ playerid ][ pTemperature ] > 32.0 ) {
		PlayerInfo[ playerid ][ pTemperature ] -= 0.05;
		format(string, sizeof(string), "%.1f", PlayerInfo[ playerid ][ pTemperature ]);
	    PlayerTextDrawSetString(playerid, tempTextdraw[ playerid ][ 2 ], string);
	    if( PlayerInfo[ playerid ][ pTemperature ] <= 32.0)
		    SendClientMessage(playerid, COLOR_RED, "[ ! ] Imate hipotermiju. Udite u neko vozilo sa grijanjem ili kucu kako bi se ugrijali!");
	}
	else if( !Bit1_Get( gr_PlayerOutside, playerid ) && PlayerInfo[ playerid ][ pTemperature ] < 36.5 ) {
	    PlayerInfo[ playerid ][ pTemperature ] += 0.1;
	    format(string, sizeof(string), "%.1f", PlayerInfo[ playerid ][ pTemperature ]);
	    PlayerTextDrawSetString(playerid, tempTextdraw[ playerid ][ 2 ], string);
	} 
	//else
	//    DestroyTempTextDraws(playerid);
	return 1;
} */
/*
	##     ##  #######   #######  ##    ##  ######  
	##     ## ##     ## ##     ## ##   ##  ##    ## 
	##     ## ##     ## ##     ## ##  ##   ##       
	######### ##     ## ##     ## #####     ######  
	##     ## ##     ## ##     ## ##  ##         ## 
	##     ## ##     ## ##     ## ##   ##  ##    ## 
	##     ##  #######   #######  ##    ##  ######  
*/
/*
	d888888b d88888b .88b  d88. d8888b. d88888b d8888b.  .d8b.  d888888b db    db d8888b.  .d8b.
	~~88~~' 88'     88'YbdP88 88  8D 88'     88  8D d8' 8b ~~88~~' 88    88 88  8D d8' 8b
	   88    88ooooo 88  88  88 88oodD' 88ooooo 88oobY' 88ooo88    88    88    88 88oobY' 88ooo88
	   88    88~~~~~ 88  88  88 88~~~   88~~~~~ 888b   88~~~88    88    88    88 888b   88~~~88
	   88    88.     88  88  88 88      88.     88 88. 88   88    88    88b  d88 88 88. 88   88
	   YP    Y88888P YP  YP  YP 88      Y88888P 88   YD YP   YP    YP    ~Y8888P' 88   YD YP   YP
*/
hook OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if( newinteriorid != 0) {
		DestroyPlayerSnow(playerid);
	    Bit1_Set( gr_PlayerOutside, playerid, false);
	} else {
		StartSnowFallingForPlayer(playerid);
		Bit1_Set( gr_PlayerOutside, playerid, true);
		//if( !Bit1_Get( gr_PlayerUsingTemp, playerid ) )
		//	CreateTempTextdraws(playerid);
	}
	return 1;
}

/* hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if( ( newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER ) && oldstate == PLAYER_STATE_ONFOOT ) {
	    new
			model = GetVehicleModel( GetPlayerVehicleID( playerid ) );
	    if( !IsABike(model) && !IsABoat(model) && !IsAMotorBike(model) && model != 447 && model != 469 && model != 530 && model != 531 && model != 572 && model != 441 )
			Bit1_Set( gr_PlayerOutside, playerid, false);
	} else if( newstate == PLAYER_STATE_ONFOOT && ( oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER ) && !Bit1_Get( gr_PlayerOutside, playerid ) ) {
	    Bit1_Set( gr_PlayerOutside, playerid, true);
	    //if( !Bit1_Get( gr_PlayerUsingTemp, playerid ) )
		//    CreateTempTextdraws(playerid);
	}
	return 1;
} */

/*hook OnPlayerUpdate(playerid)
{
	if(IsPlayerAlive(playerid) && temperatureUpdateTime[playerid] < gettimestamp())
	{
		TemperatureCheck(playerid);
		temperatureUpdateTime[playerid] = gettimestamp() + 9;
	}
	return 1;
}*/

/*hook OnPlayerDeath(playerid, killerid, reason)
{
	if( SkiInfo[ playerid ][ spVehicleId ] != 0 ) {
		DestroyVehicle(SkiInfo[ playerid ][ spVehicleId ]);
		SkiInfo[ playerid ][ spVehicleId ] = 0;
		
		for( new i = 0; i < 12; i++ ) {
			if( IsValidDynamicObject(SkiInfo[ playerid ][ spObject ][ i ]) ) {
				DestroyDynamicObject(SkiInfo[ playerid ][ spObject ][ i ]);
				SkiInfo[ playerid ][ spObject ][ i ] = INVALID_OBJECT_ID;
			}
		}
	}
	return 1;
}*/

/*public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if( ( newkeys & KEY_SECONDARY_ATTACK ) && !( oldkeys & KEY_SECONDARY_ATTACK ) ) {
		if( SkiInfo[ playerid ][ spVehicleId ] != 0 ) {
			SetPlayerInterior(playerid, 0);
			
			new
				Float:X, Float:Y, Float:Z;
			GetVehiclePos(SkiInfo[ playerid ][ spVehicleId ], X, Y, Z);
			SetPlayerPos(playerid, X, Y, Z + 1.5);
		
			DestroyVehicle(SkiInfo[ playerid ][ spVehicleId ]);
			SkiInfo[ playerid ][ spVehicleId ] = 0;
			
			for( new i = 0; i < 12; i++ ) {
				if( IsValidDynamicObject(SkiInfo[ playerid ][ spObject ][ i ]) ) {
					DestroyDynamicObject(SkiInfo[ playerid ][ spObject ][ i ]);
					SkiInfo[ playerid ][ spObject ][ i ] = INVALID_OBJECT_ID;
				}
			}
		}
	}
	#if defined WINT_OnPlayerKeyStateChange
        WINT_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
    #endif
    return 1;
}
#if defined _ALS_OnPlayerKeyStateChange
    #undef OnPlayerKeyStateChange
#else
    #define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange WINT_OnPlayerKeyStateChange
#if defined WINT_OnPlayerKeyStateChange
    forward WINT_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif*/

hook OnPlayerSpawn(playerid)
{
	ApplyAnimationEx(playerid, "SKATE", "null", 0.0, 0, 0, 0, 0, 0, 1, 0); // Pre-loads the skate anim.
	
	if( GetPlayerInterior(playerid) ) {
		Bit1_Set( gr_PlayerOutside, playerid, false);
	} else if( !GetPlayerInterior(playerid) && !Bit1_Get( gr_PlayerUsingTemp, playerid ) ) {
		Bit1_Set( gr_PlayerOutside, playerid, true);
	    //CreateTempTextdraws(playerid);
	}
	if( !GetPlayerInterior(playerid) ) 
	{
		if( ServerSnowing && !Bit1_Get(gr_PlayerSnowing,playerid) )
			StartSnowFallingForPlayer(playerid);
	}
	return 1;
}

/*
	db      d88888b d8888b.
	88      88'     88  8D
	88      88ooooo 88   88
	88      88~~~~~ 88   88
	88booo. 88.     88  .8D
	Y88888P Y88888P Y8888D'
*/

hook OnGameModeInit()
{
	iceArea[ 0 ] = CreateDynamicCircle(2090.1941, -1753.5481, 85.0, -1, -1, -1); //Idlewood (oko Pizza Stacka)
	iceArea[ 1 ] = CreateDynamicCircle(2731.7244, -1652.7697, 60.0, -1, -1, -1); //East Beach (pokraj stadiona)
	iceArea[ 2 ] = CreateDynamicCircle(2450.2771, -1257.6332, 80.0, -1, -1, -1); //East Los Santos (pokraj Pig Pena)
	iceArea[ 3 ] = CreateDynamicCircle(1976.2997, -1253.1206, 70.0, -1, -1, -1); //Glen Park (pokraj 24/7)
	iceArea[ 4 ] = CreateDynamicCircle(1201.6918, -1325.2523, 90.0, -1, -1, -1); //Market (ispred bolnice)
	iceArea[ 5 ] = CreateDynamicCircle(1369.7676, -936.7969, 130.0, -1, -1, -1); //Vinewood (povise Main St. Ammunationa)
	iceArea[ 6 ] = CreateDynamicCircle(406.0366, -1772.8468, 110.0, -1, -1, -1); //Santa Maria Beach (pokraj Pay 'n' Spraya)
	iceArea[ 7 ] = CreateDynamicCircle(529.2660,-1416.4286, 95.0, -1, -1, -1); //Rodeo (poviSe mjesta za izdavanje oglasa)
	
	CreateDynamicObject(19076, 1948.99646, -2151.20557, 12.52280,   0.00000, 0.00000, -40.00000);
	CreateDynamicObject(19054, 1949.30151, -2150.27051, 13.14020,   0.00000, 0.00000, 62.00000);
	CreateDynamicObject(19057, 1949.54871, -2152.08130, 13.14370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1297, 1952.17773, -2156.68359, 15.92270,   0.00000, 0.00000, 156.00000);
	CreateDynamicObject(19060, 1952.71423, -2156.93213, 18.72620,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19059, 1964.60425, -2134.42041, 19.64260,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19061, 1964.56592, -2082.46875, 19.64400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19063, 1958.98035, -2082.33350, 19.65420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19062, 1964.53870, -2034.87646, 19.63460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19060, 1964.46472, -2014.01550, 19.65450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19059, 1958.70837, -1982.56238, 19.65240,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19061, 1966.52808, -1937.22485, 19.61380,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19063, 1956.79016, -1927.50049, 19.59270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19062, 1958.85828, -1867.44751, 19.58290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19060, 1964.39307, -1841.75977, 19.60390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19061, 1958.99036, -1822.40259, 19.61370,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19062, 1964.54138, -1800.68958, 19.57450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19063, 1956.85828, -1792.14160, 19.65320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19076, 1945.37170, -1794.20020, 12.53920,   0.00000, 0.00000, 280.00000);
	CreateDynamicObject(19054, 1946.31189, -1794.04602, 13.16150,   0.00000, 0.00000, -69.00000);
	CreateDynamicObject(19057, 1944.93909, -1793.36670, 13.16630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19056, 1944.57629, -1795.00195, 13.16510,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1877, 1950.40234, -1773.06995, 18.24260,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1877, 1950.39343, -1776.86511, 18.24260,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1877, 1950.40283, -1780.69971, 18.24260,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1877, 1950.38684, -1769.22632, 18.24260,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1877, 1950.39624, -1765.38892, 18.24260,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19076, 2094.46704, -1702.89270, 12.48400,   0.00000, 0.00000, 16.00000);
	CreateDynamicObject(19054, 2095.39063, -1703.19690, 13.18630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19057, 2094.13110, -1704.05298, 13.16700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19055, 2093.90210, -1702.07117, 13.12620,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(3472, 2248.44849, -1742.35010, 12.54278,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 2279.95288, -1742.21167, 12.53958,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 2348.52197, -1742.54053, 12.53946,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3472, 2383.33960, -1741.80933, 12.53823,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19297, 2387.16162, -1741.72424, 22.26165,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19060, 2071.98730, -1787.34045, 15.66710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19061, 1952.10437, -1755.26233, 19.60180,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19060, 1979.27148, -1749.47021, 19.67950,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19062, 2015.74902, -1755.01501, 19.69720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19059, 2048.81567, -1749.55444, 19.65990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7666, 2114.66821, -1790.15186, 18.70020,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(3038, 2104.67065, -1794.34998, 16.12400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3038, 2104.57813, -1803.02332, 16.24420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3038, 2104.60498, -1811.97815, 16.26290,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3038, 2104.57690, -1819.02393, 16.35720,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3038, 2071.68921, -1794.94202, 17.41630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3038, 2148.96362, -1761.75049, 16.10720,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3038, 2140.63379, -1761.80518, 16.01610,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3038, 2132.42847, -1761.75330, 15.91920,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3038, 1946.31946, -1763.25964, 18.15590,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3038, 1937.60620, -1763.17810, 18.12440,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3038, 2069.37524, -1775.86206, 15.95600,   0.00000, 0.00000, 0.00000);
	// ------------------ texture snijega po gradu ---------------------------------
	/* AddSnowObject(5145, 2716.79687, -2447.87500, 2.15625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5146, 2498.19531, -2408.00781, 1.80468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5147, 2533.76562, -2330.82812, 22.19531, 0.00000, 0.00000, 315.00000);
	AddSnowObject(3753, 2702.39843, -2324.25781, 3.03906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5333, 2374.38281, -2171.46875, 21.17968, 0.00000, 0.00000, 135.00000);
	AddSnowObject(5191, 2381.44531, -2397.43750, 6.67187, 0.00000, 0.00000, 45.00000);
	AddSnowObject(5176, 2521.53906, -2606.95312, 17.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3753, 2615.10937, -2464.61718, 3.03906, 0.00000, 0.00000, 180.00000);
	AddSnowObject(3753, 2748.01562, -2571.59375, 3.03906, 0.00000, 0.00000, 180.00000);
	AddSnowObject(5115, 2523.40625, -2217.46093, 12.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3753, 2511.47656, -2256.03125, 3.03906, 0.00000, 0.00000, 180.00000);
	AddSnowObject(5108, 2333.55468, -2308.71093, 3.27343, 0.00000, 0.00000, 45.00000);
	AddSnowObject(5353, 2543.75000, -2163.78906, 14.20312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5250, 2743.43750, -2120.64062, 15.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5184, 2699.03125, -2227.74218, 31.42968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5114, 2831.68750, -2161.52343, 5.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5125, 2397.82031, -2183.05468, 15.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5124, 2278.89843, -2286.31250, 15.33593, 0.00000, 0.00000, 45.00000);
	AddSnowObject(3753, 2299.18750, -2405.39843, 3.03906, 0.00000, 0.00000, 225.00000);
	AddSnowObject(3753, 2368.16406, -2523.86718, 3.03906, 0.00000, 0.00000, 90.00000);
	AddSnowObject(3753, 2454.82812, -2702.91406, 3.03906, 0.00000, 0.00000, 180.00000);
	AddSnowObject(5109, 2219.33593, -2558.80468, 4.98437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4844, 2086.57031, -2733.68750, 1.64062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4841, 2123.78906, -2576.32812, 15.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5003, 2018.43750, -2585.50000, 18.78125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4864, 1996.06250, -2677.55468, 14.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4822, 2179.89843, -2407.41406, 15.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5004, 2030.14062, -2417.69531, 12.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4867, 1780.80468, -2604.14062, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4847, 1710.74218, -2745.40625, 3.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4842, 1383.79687, -2707.74218, 3.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4863, 1533.08593, -2677.43750, 11.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4865, 1515.40625, -2602.50781, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4843, 1274.56250, -2551.86718, 3.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4839, 1383.60937, -2633.05468, 15.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4883, 1339.23437, -2456.69531, 15.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4866, 1517.15625, -2449.64843, 12.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4816, 1210.71093, -2467.78906, 1.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4840, 1233.50000, -2438.00000, 8.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4845, 1222.82812, -2291.23437, 7.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4835, 1466.76562, -2286.43750, 16.58593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4838, 1411.57812, -2265.07031, 12.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4834, 1315.84375, -2286.33593, 13.43750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4833, 1528.74218, -2252.64062, 12.68750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4871, 1569.93750, -2378.24218, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4831, 1756.08593, -2286.50000, 16.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4830, 1687.78125, -2286.53906, 10.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4869, 1893.39062, -2269.60156, 14.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5002, 1780.35937, -2437.60156, 12.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5009, 2065.13281, -2269.60156, 15.32031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4868, 2139.60937, -2292.42187, 15.32031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5123, 2195.08593, -2266.61718, 12.56250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5276, 2219.60156, -2200.49218, 12.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4827, 2056.88281, -2187.35156, 6.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5185, 2143.91406, -2166.92187, 13.85156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5135, 2109.53125, -2163.91406, 16.78906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5314, 2085.17968, -2132.70312, 12.41406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5271, 2275.40625, -2095.26562, 12.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5279, 2137.28906, -2063.27343, 13.85156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5278, 2290.30468, -2170.43750, 16.05468, 0.00000, 0.00000, 45.00000);
	AddSnowObject(5274, 2317.71875, -2210.57812, 8.80468, 0.00000, 0.00000, 315.00000);
	AddSnowObject(5277, 2235.91406, -2282.46093, 13.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5275, 2293.80468, -2172.77343, 11.71093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5192, 2360.71875, -2117.00781, 16.25781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5106, 2390.24218, -2013.87500, 16.04687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5107, 2496.76562, -2108.36718, 19.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5112, 2521.09375, -2049.24218, 18.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5297, 2393.06250, -2049.24218, 18.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5330, 2303.75000, -1982.78125, 12.42968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5311, 2287.34375, -2024.38281, 12.53906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5174, 2371.25781, -2024.32031, 16.58593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5149, 2479.82812, -2009.00000, 15.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5105, 2543.46093, -2142.28125, 10.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5120, 2243.64843, -2021.01562, 12.41406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5270, 2112.30468, -2001.79687, 9.76562, 0.00000, 0.00000, 45.00000);
	AddSnowObject(5273, 2153.40625, -2051.42968, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5272, 2213.17187, -2033.06250, 12.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5343, 2136.50781, -1992.89062, 12.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5347, 2130.63281, -1987.89843, 13.14843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5122, 2184.43750, -1932.95312, 14.38281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5119, 2176.06250, -1911.87500, 12.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5329, 2216.18750, -1912.33593, 13.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5111, 2271.35937, -1912.38281, 14.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17567, 2288.18750, -1851.62500, 5.71093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17594, 2314.85156, -1799.42187, 13.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5513, 2200.72656, -1811.33593, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17595, 2217.48437, -1810.83593, 12.36718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5141, 2271.19531, -1928.39062, 12.49218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5349, 2143.67187, -1894.47656, 12.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5181, 2167.03906, -1925.20312, 15.82812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5118, 2107.77343, -1958.81250, 12.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5182, 2115.00000, -1921.52343, 15.39062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5117, 2031.25000, -1962.31250, 13.28906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5121, 2041.65625, -1904.81250, 12.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5116, 2361.27343, -1918.74218, 16.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5168, 2385.18750, -1906.51562, 18.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5178, 2479.85156, -1930.21093, 12.41406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5187, 2439.28125, -1979.96093, 15.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5142, 2489.23437, -1962.01562, 19.03906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5355, 2582.42968, -1979.37500, 9.14843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5296, 2652.92968, -2049.24218, 18.12500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5143, 2639.40625, -2102.39843, 36.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5113, 2758.53906, -2104.89843, 18.28125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5188, 2718.44531, -1977.50000, 11.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5133, 2845.64843, -1969.99218, 9.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5172, 2906.73437, -1975.26562, 4.46875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5173, 2768.44531, -2012.09375, 14.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5144, 2768.56250, -1942.69531, 11.30468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17582, 2739.21875, -1770.08593, 17.55468, 0.00000, 0.00000, 175.00000);
	AddSnowObject(17927, 2771.17187, -1901.49218, 11.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17602, 2678.68750, -1849.80468, 9.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4372, 2930.64843, -1778.92187, -60.81250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17606, 2848.87500, -1799.57031, 10.32031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17675, 2893.58593, -1586.53125, 10.22656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17605, 2798.70312, -1657.29687, 10.98437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17607, 2854.89843, -1525.40625, 9.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17541, 2803.39843, -1573.80468, 20.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17604, 2690.29687, -1657.30468, 10.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17609, 2730.14062, -1572.89843, 20.63281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17682, 2674.94531, -1622.54687, 14.17968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17680, 2642.69531, -1540.80468, 19.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17538, 2682.80468, -1507.41406, 44.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17603, 2642.79687, -1733.10156, 9.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17568, 2586.85937, -1744.06250, 6.58593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17507, 2587.07812, -1589.44531, 15.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17600, 2585.25781, -1732.34375, 11.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17506, 2582.54687, -1872.63281, 6.58593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17601, 2674.18750, -1860.69531, 11.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5151, 2674.10156, -1990.78906, 15.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17500, 2478.60156, -1851.48437, 6.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5128, 2516.59375, -1875.55468, 11.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5110, 2443.63281, -1901.32031, 18.00781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5267, 2485.76562, -1900.43750, 18.53125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17599, 2522.19531, -1773.00000, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17548, 2482.32812, -1783.14843, 14.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17596, 2413.75000, -1820.83593, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17598, 2469.38281, -1732.21093, 12.57812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17520, 2497.76562, -1762.39062, 15.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17613, 2489.29687, -1668.50000, 12.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17617, 2502.32031, -1649.58593, 15.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17616, 2521.68750, -1692.85937, 14.86718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17574, 2459.80468, -1714.88281, 12.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17612, 2408.09375, -1658.90625, 12.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17881, 2429.78906, -1681.84375, 12.64062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17615, 2459.59375, -1695.60156, 13.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17654, 2556.35156, -1612.91406, 15.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17865, 2510.47656, -1543.27343, 21.71093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17864, 2520.72656, -1530.25000, 22.74218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17655, 2433.07031, -1611.55468, 12.03125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17829, 2413.68750, -1576.64062, 16.20312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17657, 2431.03906, -1603.49218, 20.20312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17656, 2431.05468, -1677.42968, 20.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17597, 2314.95312, -1741.32812, 12.48437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17614, 2387.80468, -1695.64843, 13.74218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17621, 2342.59375, -1682.70312, 12.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17620, 2281.21093, -1695.64843, 13.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17611, 2284.66406, -1656.71093, 13.42968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17619, 2303.41406, -1622.42187, 9.05468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17622, 2342.60937, -1608.81250, 16.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17867, 2308.45312, -1599.38281, 4.63281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17866, 2339.78906, -1583.99218, 14.96093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17638, 2431.69531, -1514.35156, 22.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17624, 2386.78906, -1524.35937, 22.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17862, 2458.38281, -1532.43750, 22.99218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17623, 2342.50000, -1534.00000, 22.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17503, 2386.64062, -1454.34375, 27.22656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17639, 2490.90625, -1504.32812, 22.92187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17921, 2560.86718, -1474.34375, 22.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17688, 2604.99218, -1465.86718, 25.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17687, 2577.24218, -1447.23437, 30.77343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17640, 2461.39062, -1445.78125, 25.82031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17852, 2490.90625, -1474.34375, 27.34375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17920, 2295.01562, -1564.46875, 12.32031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5511, 2193.25000, -1543.54687, 9.70312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5478, 2269.08593, -1487.55468, 20.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5479, 2234.16406, -1590.25781, 16.66406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17513, 2288.89843, -1525.50000, 17.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17610, 2224.03906, -1680.64062, 13.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5480, 2208.37500, -1698.24218, 13.39062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5510, 2192.79687, -1665.03906, 13.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5440, 2207.67968, -1588.39062, 19.34375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5509, 2150.39062, -1741.82812, 12.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5430, 2148.95312, -1791.83593, 19.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5419, 2078.15625, -1847.70312, 7.76562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5183, 2111.65625, -1873.36718, 16.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5180, 2163.67187, -1873.61718, 15.82031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5418, 2112.93750, -1797.09375, 19.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5508, 2085.85937, -1812.77343, 13.17968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5528, 2101.29687, -1688.77343, 18.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5506, 2079.83593, -1699.94531, 12.46093, 0.00000, 0.00000, 275.57501);
	AddSnowObject(5521, 2049.57812, -1781.67968, 18.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5411, 2021.65625, -1810.72656, 18.60156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5139, 2021.15625, -1893.27343, 15.17968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5134, 2045.49218, -1903.61718, 16.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5404, 1952.71875, -1856.78125, 7.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4895, 1899.15625, -1936.33593, 14.26562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5052, 1961.65625, -1863.11718, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5013, 1961.66406, -2001.89843, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5186, 2014.81250, -2041.14062, 12.53906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4807, 1964.64062, -2109.42187, 14.10937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4808, 1892.33593, -2037.64843, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4806, 1880.33593, -2001.92187, 12.57031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4859, 1868.95312, -2003.65625, 13.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5064, 1855.45312, -1958.46093, 12.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4858, 1891.74218, -1872.28125, 14.85937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5420, 1835.82031, -1815.14062, 7.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5489, 1932.59375, -1782.10156, 12.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5397, 1866.32812, -1789.78125, 20.94531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4821, 1745.20312, -1882.85156, 26.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5026, 1821.66406, -1872.31250, 12.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4819, 1815.45312, -1958.46093, 12.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4817, 1739.30468, -1951.95312, 12.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4860, 1722.75000, -2014.63281, 16.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4873, 1734.39843, -2019.70312, 14.34375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4837, 1823.00781, -2087.17187, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4849, 1892.33593, -2109.50781, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4861, 1873.01562, -2101.83593, 15.89062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4846, 1827.13281, -2158.85937, 14.51562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5036, 1694.60156, -2131.11718, 12.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5034, 1742.81250, -2292.75781, 3.92968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4829, 1645.38281, -2292.75781, 3.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4870, 1569.98437, -2194.72656, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4836, 1441.90625, -2166.64843, 13.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4872, 1610.92968, -2010.62500, 23.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5028, 1624.00000, -2113.61718, 23.10937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4820, 1738.39062, -2117.02343, 13.93750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4876, 1582.29687, -2002.23437, 26.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4878, 1530.82812, -1969.13281, 26.39062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4852, 1401.46093, -1994.58593, 35.43750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4823, 1338.32812, -1976.65625, 36.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4875, 1270.68750, -2196.78906, 42.56250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4824, 1224.42968, -2037.00781, 62.92968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4825, 1145.95312, -2037.00000, 65.51562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4851, 1182.00781, -1987.63281, 39.99218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4810, 1095.06250, -2214.21875, 41.72656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5046, 1105.50000, -2355.95312, 16.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4809, 1036.52343, -2204.43750, 14.16406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4815, 1074.58593, -2321.74218, 10.85156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4898, 992.85937, -2126.61718, 12.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4896, 981.70312, -2155.85156, 1.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4814, 1071.03125, -2354.00781, 1.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4812, 1023.39843, -2166.10156, 23.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5023, 1046.05468, -2251.50781, 33.64062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4811, 1069.67187, -2270.89843, 23.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4897, 985.72656, -2050.53125, 3.04687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5021, 1044.91406, -2023.39062, 17.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4813, 1042.27343, -2029.80468, 23.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6065, 887.46093, -1878.39062, 3.12500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6118, 1050.07812, -1864.31250, 12.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6117, 1109.32031, -1852.37500, 12.56250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4168, 1217.45312, -1852.26562, 12.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4103, 1104.09375, -1780.90625, 25.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4101, 1224.69531, -1782.20312, 29.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4108, 1177.46093, -1782.25000, 12.66406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4182, 1304.98437, -1792.28125, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4107, 1360.75781, -1802.25000, 12.49218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4010, 1350.75781, -1802.28125, 12.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4165, 1469.52343, -1872.37500, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3997, 1479.33593, -1802.28906, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4207, 1603.81250, -1863.34375, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4133, 1625.09375, -1834.20312, 24.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4209, 1569.93750, -1802.28906, 12.32031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4122, 1629.46093, -1812.28906, 13.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4160, 1686.62500, -1806.42968, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3991, 1608.19531, -1721.80468, 26.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6116, 997.56250, -1798.51562, 12.95312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6054, 1036.41406, -1689.17968, 12.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6042, 952.34375, -1822.82031, 15.17968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6122, 798.09375, -1763.10156, 12.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6123, 917.39843, -1672.90625, 12.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6203, 956.19531, -1689.60156, 12.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6213, 880.30468, -1696.25000, 12.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6115, 1087.46093, -1712.26562, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6128, 1207.46093, -1712.19531, 12.66406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6126, 1149.89843, -1642.14843, 12.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6102, 1226.95312, -1656.15625, 24.77343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3978, 1380.26562, -1655.53906, 10.80468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4197, 1380.26562, -1655.53906, 10.80468, 0.00000, 0.00000, 270.00000);
	AddSnowObject(4198, 1380.26562, -1655.53906, 10.80468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6127, 1306.51562, -1630.35937, 12.46875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4163, 1469.33593, -1732.28906, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4148, 1427.05468, -1662.28906, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4186, 1479.55468, -1693.14062, 19.57812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4158, 1609.55468, -1732.32812, 12.46875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4150, 1532.05468, -1662.28906, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3975, 1578.46875, -1676.42187, 13.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4029, 1629.54687, -1756.08593, 8.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3985, 1479.56250, -1631.45312, 12.07812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4129, 1595.00000, -1603.02343, 27.03906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3989, 1646.00781, -1662.71875, 8.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3993, 1719.93750, -1662.28906, 12.46875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4013, 1654.59375, -1637.74218, 28.64062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3987, 1722.05468, -1702.28906, 12.81250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3992, 1755.60156, -1782.30468, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3983, 1722.50000, -1775.39843, 14.51562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3977, 1384.36718, -1511.43750, 10.10937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4146, 1371.00000, -1582.34375, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4144, 1442.15625, -1517.53125, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3994, 1479.55468, -1592.28906, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4020, 1544.83593, -1516.85156, 32.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4142, 1494.75781, -1410.87500, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4139, 1406.17187, -1418.10156, 12.78906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4712, 1546.98437, -1356.61718, 14.95312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3990, 1593.95312, -1416.35156, 26.66406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3996, 1596.35937, -1440.87500, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4131, 1588.44531, -1509.14062, 27.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4128, 1666.91406, -1456.75000, 26.04687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4127, 1664.12500, -1560.85156, 23.35156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4152, 1658.10937, -1516.69531, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4233, 1603.90625, -1592.29687, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4156, 1739.81250, -1602.19531, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4033, 1721.87500, -1643.05468, 12.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4001, 1700.47656, -1517.69531, 17.93750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4000, 1787.13281, -1565.67968, 11.96875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3998, 1734.30468, -1560.71093, 18.88281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4125, 1769.51562, -1509.48437, 12.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4154, 1706.21093, -1432.35156, 12.44531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4645, 1605.72656, -1370.82812, 15.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4557, 1714.74218, -1350.87500, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4590, 1780.00000, -1360.00000, 12.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5498, 1849.32812, -1373.39843, 12.48437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5390, 1919.52343, -1400.89843, 16.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3995, 1797.16406, -1464.39062, 7.99218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4110, 1807.46093, -1475.98437, 8.53125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5439, 1887.79687, -1536.60156, 7.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5474, 1931.64843, -1577.57031, 12.35937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5501, 1884.66406, -1613.42187, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5502, 1822.89062, -1725.25781, 12.46875, 0.00000, 0.00000, 270.00000);
	AddSnowObject(5503, 1927.70312, -1754.31250, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4027, 1783.10156, -1702.30468, 14.35156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3984, 1783.10156, -1647.31250, 23.25781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4012, 1777.43750, -1782.30468, 12.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5441, 1941.65625, -1682.57031, 12.47656, 0.00000, 0.00000, 270.00000);
	AddSnowObject(5412, 1971.65625, -1682.31250, 13.74218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5407, 2041.64843, -1682.18750, 12.57031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5505, 2002.48437, -1700.98437, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5507, 2041.66406, -1672.31250, 12.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5442, 2041.72656, -1752.31250, 12.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5518, 2137.98437, -1672.55468, 12.77343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5504, 2046.00000, -1613.00000, 12.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5512, 2069.92187, -1535.78125, 10.49218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5471, 2088.10937, -1568.11718, 11.05468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5472, 2117.29687, -1541.57812, 23.53906, 0.00000, 0.00000, 270.00000);
	AddSnowObject(5391, 2148.80468, -1627.12500, 13.42968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5519, 2159.81250, -1595.92187, 12.89062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5438, 2222.67187, -1462.91406, 22.78906, 0.00000, 0.00000, 270.00000);
	AddSnowObject(17509, 2511.75781, -1544.31250, 18.51562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17505, 2339.78906, -1583.99218, 12.76562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17877, 2374.30468, -1640.43750, 12.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5429, 2244.69531, -1518.75000, 22.23437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17625, 2315.35937, -1444.20312, 22.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17563, 2307.92187, -1434.03906, 21.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17637, 2391.17968, -1414.32812, 22.92968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17636, 2411.16406, -1402.88281, 28.01562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17645, 2481.21875, -1350.49218, 27.77343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17644, 2511.76562, -1349.52343, 30.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17634, 2411.02343, -1301.75000, 25.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17642, 2411.08593, -1235.32812, 27.80468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17635, 2411.02343, -1352.10156, 23.70312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17630, 2371.07812, -1216.36718, 24.71093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17628, 2371.08593, -1320.45312, 22.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17633, 2337.21875, -1228.52343, 24.74218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17976, 2414.39843, -1362.20312, 32.60156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17643, 2451.01562, -1230.28906, 29.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17646, 2511.00000, -1256.60156, 33.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17641, 2454.60156, -1350.46093, 22.82812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17627, 2347.67187, -1384.31250, 22.92968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17545, 2337.17968, -1342.62500, 23.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17626, 2303.43750, -1338.03906, 22.98437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5674, 2286.37500, -1371.27343, 22.95312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5428, 2252.00000, -1434.14062, 23.25781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5494, 2263.21093, -1368.70312, 22.92968, 0.00000, 0.00000, 270.00000);
	AddSnowObject(5426, 2218.89062, -1342.55468, 25.24218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5437, 2155.00000, -1382.00000, 23.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5427, 2170.97656, -1461.12500, 25.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5496, 2120.00000, -1440.00000, 23.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5497, 2060.19531, -1463.40625, 18.94531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5402, 2049.86718, -1400.89062, 20.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5495, 2066.00000, -1358.00000, 23.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5425, 2116.32031, -1342.85937, 26.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5492, 2168.21093, -1300.80468, 22.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5477, 2287.09375, -1217.65625, 24.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17632, 2307.52343, -1225.10156, 23.80468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5490, 2269.78125, -1224.53125, 24.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5491, 2171.39062, -1220.82031, 22.88281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5424, 2218.89062, -1260.81250, 24.28906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5493, 2169.97656, -1260.46093, 22.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5482, 2172.57031, -1171.20312, 23.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5459, 2123.93750, -1159.00000, 24.16406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5406, 2223.26562, -1202.18750, 27.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5650, 2213.50000, -1124.90625, 24.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5413, 2222.99218, -1162.60156, 30.03906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5423, 2121.10156, -1260.87500, 26.15625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5435, 2069.36718, -1260.99218, 22.89843, 0.00000, 0.00000, 90.00000);
	AddSnowObject(5434, 1946.82812, -1260.90625, 17.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5499, 1944.00000, -1341.00000, 18.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5487, 1972.60937, -1198.31250, 23.97656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5458, 1995.01562, -1198.35156, 21.10937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5483, 2069.29687, -1149.20312, 22.94531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5432, 2110.09375, -1098.80468, 23.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5485, 1950.59375, -1135.88281, 24.02343, 0.00000, 0.00000, 180.00000);
	AddSnowObject(5486, 2005.50000, -1081.30468, 24.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5443, 2019.40625, -1107.13281, 24.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5481, 2023.25781, -1034.48437, 29.12500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5445, 2105.96093, -1038.55468, 40.41406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5444, 2143.05468, -1048.40625, 48.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5453, 2179.78906, -1082.48437, 42.72656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5446, 2086.29687, -1077.07812, 29.05468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5484, 2190.58593, -1063.07031, 45.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5452, 2258.35937, -1099.41406, 39.99218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5456, 2185.09375, -1013.21093, 59.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5642, 2229.60937, -1063.46875, 46.68750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5643, 2202.56250, -1041.62500, 58.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13706, 2372.03125, -1056.34375, 57.03906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13823, 2284.00781, -929.46875, 88.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5451, 2256.03125, -1019.92187, 59.38281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13795, 2422.11718, -1093.34375, 48.15625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17631, 2336.93750, -1153.14062, 26.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17669, 2378.03125, -1110.17187, 33.61718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17906, 2440.30468, -1120.25000, 43.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17670, 2463.75000, -1151.64843, 34.96875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17647, 2420.95312, -1179.13281, 31.01562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17678, 2506.88281, -1167.06250, 46.24218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17648, 2511.03906, -1184.53906, 48.20312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17892, 2511.02343, -1220.26562, 42.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17893, 2553.97656, -1205.13281, 60.65625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17894, 2524.44531, -1205.61718, 56.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17651, 2636.89062, -1184.08593, 64.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17650, 2570.89843, -1230.30468, 52.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17652, 2646.79687, -1257.00000, 51.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17649, 2571.00000, -1350.40625, 33.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17679, 2540.82812, -1350.58593, 40.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17681, 2682.64843, -1456.39843, 29.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17653, 2642.78906, -1350.25781, 39.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17666, 2642.67187, -1217.78125, 58.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17658, 2730.13281, -1445.92187, 32.68750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17608, 2806.30468, -1488.45312, 19.58593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17556, 2804.71093, -1451.60937, 19.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17561, 2769.53125, -1446.67187, 22.06250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17683, 2866.69531, -1355.90625, 15.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17674, 2903.42968, -1336.88281, 9.97656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17676, 2928.05468, -1298.13281, 8.16406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17660, 2825.99218, -1386.36718, 15.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17685, 2810.67187, -1263.75000, 39.12500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17589, 2801.78125, -1392.64062, 20.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17661, 2796.89062, -1323.23437, 32.82812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17673, 2882.54687, -1146.64062, 10.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17684, 2847.09375, -1148.80468, 16.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17659, 2729.00000, -1330.70312, 47.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17663, 2730.19531, -1220.90625, 63.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17662, 2777.29687, -1259.00000, 52.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17664, 2685.25781, -1220.95312, 59.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17671, 2633.64843, -1152.68750, 47.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17696, 2690.39062, -1154.14062, 56.71093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17677, 2587.65625, -1101.25781, 56.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17849, 2642.73437, -1086.32031, 66.02343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17667, 2642.71875, -1164.50000, 59.16406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17693, 2730.23437, -1117.64843, 64.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17691, 2778.79687, -1099.79687, 41.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17672, 2789.42187, -1144.94531, 29.95312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13810, 2948.41406, -951.76562, -28.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13708, 2778.64843, -930.35156, 39.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13709, 2856.43750, -930.17968, 16.14843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13809, 2734.87500, -917.96093, 47.82031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13497, 2870.02343, -662.57812, 26.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13121, 2870.02343, -662.57812, 26.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12877, 2870.77343, -677.79687, 10.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13120, 2629.58593, -662.28906, 89.49218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13156, 2379.60156, -670.41406, 112.02343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13123, 2631.27343, -415.71875, 54.14843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13134, 2372.07031, -407.32812, 73.57031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13710, 2523.76562, -915.31250, 85.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13707, 2563.92187, -1047.17187, 68.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17692, 2681.78125, -1078.75000, 68.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17694, 2704.28906, -1095.78906, 62.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17668, 2506.70312, -1079.83593, 54.94531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13122, 2862.23437, -413.64062, -4.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12878, 2807.10937, -480.72656, 16.26562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12974, 2793.53125, -447.35937, 18.17968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12876, 2815.46875, -278.23437, 10.93750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12879, 2732.03906, -231.38281, 29.75781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13824, 2039.82031, -904.82031, 79.06250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13157, 2148.91406, -662.00000, 90.57031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13158, 1941.59375, -686.10156, 75.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13825, 1826.08593, -882.76562, 75.32031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5433, 2044.59375, -1007.20312, 38.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5448, 2068.20312, -965.95312, 47.88281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5656, 2046.64843, -1009.96875, 40.89062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4695, 1898.47656, -1016.67968, 29.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5431, 1914.17968, -1073.31250, 23.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5668, 1928.90625, -1026.75781, 28.71875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5457, 1923.60937, -1088.34375, 24.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5640, 1914.03125, -1198.32812, 19.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5488, 1852.26562, -1196.06250, 20.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4700, 1807.28125, -1049.87500, 23.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4604, 1757.00781, -1127.25781, 23.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4658, 1810.93750, -1001.45312, 34.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4692, 1702.95312, -1031.42968, 39.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4701, 1722.28906, -1043.25000, 23.01562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4595, 1634.42968, -1115.53125, 23.03125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4702, 1647.33593, -1033.16406, 22.99218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4666, 1614.67968, -1024.67968, 42.78125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4653, 1661.97656, -910.81250, 46.05468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4664, 1643.16406, -1128.23437, 41.56250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4662, 1624.82031, -1229.85937, 34.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4656, 1693.95312, -766.04687, 50.00781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13826, 1805.02343, -699.98437, 69.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13672, 1700.89062, -556.53906, 38.35937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13723, 1496.91406, -790.91406, 48.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13821, 1530.92187, -532.64062, 62.98437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13751, 1650.02343, -559.67187, 42.35156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13820, 1701.62500, -489.19531, 59.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13502, 1935.17968, -526.87500, 51.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13146, 1935.17968, -526.87500, 51.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13719, 1437.55468, -669.28906, 86.81250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13673, 1284.30468, -677.42187, 81.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13674, 1411.90625, -562.96875, 67.58593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13818, 1317.85937, -474.10156, 52.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13323, 1245.20312, -430.53906, 22.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13237, 1148.69531, -528.16406, 57.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13752, 1210.70312, -625.61718, 78.71093, 0.00000, 0.00000, 10.44999);
	AddSnowObject(13720, 1192.34375, -669.16406, 52.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4660, 1507.78125, -966.94531, 33.83593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4703, 1569.92187, -1041.07812, 22.97656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13882, 1376.50000, -788.78906, 67.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4694, 1425.03906, -947.82812, 34.28125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5803, 1376.42968, -912.18750, 36.17968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13756, 1349.29687, -809.14062, 68.88281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13801, 1341.02343, -839.93750, 58.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13757, 1250.80468, -833.01562, 63.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5845, 1323.66406, -884.63281, 36.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5851, 1323.66406, -884.63281, 36.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5744, 1268.44531, -935.32031, 37.70312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13715, 1041.32031, -707.45312, 90.02343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13718, 1063.58593, -626.98437, 112.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13528, 1138.66406, -311.89062, 38.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13212, 1138.66406, -311.89062, 38.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13324, 979.50781, -500.17968, 33.12500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13213, 896.94531, -285.84375, 22.55468, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13214, 871.25781, -411.43750, 38.10156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13236, 953.02343, -569.69531, 68.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13211, 594.83593, -299.83593, 6.28125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13129, 786.71093, -539.52343, 15.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12999, 681.71093, -574.88281, 15.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3316, 769.21875, -558.86718, 18.67187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3315, 750.86718, -594.17968, 16.32812, 0.00000, 0.00000, 270.00000);
	AddSnowObject(3317, 744.21875, -558.86718, 18.67187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3314, 740.15625, -500.96875, 16.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3317, 769.20312, -501.39843, 18.67187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3353, 798.24218, -500.96875, 16.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(3314, 815.15625, -500.96875, 16.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12998, 811.71875, -580.96875, 15.25781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12981, 857.21093, -609.96875, 17.41406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13531, 797.70312, -707.14062, 64.24218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13235, 797.70312, -707.14062, 64.24218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13845, 667.54687, -853.20312, 52.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13704, 653.58593, -841.35156, 39.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13730, 767.57031, -927.32812, 48.36718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13702, 696.50781, -849.16406, 54.88281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13726, 809.36718, -778.78125, 80.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12976, 681.47656, -459.00000, 15.53125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13001, 701.06250, -507.64062, 15.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13127, 631.71093, -507.64062, 15.25000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13000, 563.56250, -438.88281, 36.09375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12989, 536.89062, -578.04687, 32.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13128, 640.57031, -660.17968, 12.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12855, 622.94531, -577.06250, 21.81250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12971, 548.76562, -626.98437, 26.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13370, 543.13281, -807.58593, 52.84375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13371, 422.06250, -782.47656, 42.61718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13021, 387.11718, -941.69531, 51.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12864, 183.82812, -697.42968, 24.14843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13019, 141.58593, -858.93750, 5.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12973, 421.21093, -570.23437, 37.92187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13020, 317.19531, -869.16406, 33.00781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13342, 133.44531, -655.82812, 14.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12970, 310.78906, -591.55468, 33.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13017, 155.79687, -1140.15625, 6.23437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13683, 339.72656, -1086.42968, 73.91406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13871, 415.52343, -1080.00000, 76.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13789, 191.51562, -1207.74218, 52.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13692, 252.23437, -1211.92968, 64.96093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13685, 428.91406, -1103.67187, 77.15625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13735, 313.93750, -1203.23437, 74.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13678, 223.12500, -1150.96875, 64.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13736, 239.78906, -1283.89843, 61.64062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13733, 329.53906, -1237.81250, 62.83593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13679, 269.46875, -1271.35937, 70.92968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13738, 319.97656, -1289.57031, 52.48437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13734, 366.11718, -1226.23437, 58.15625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13732, 449.83593, -1233.48437, 33.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13684, 495.02343, -1153.19531, 62.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13742, 508.64062, -1244.42968, 40.16406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6509, 529.00781, -1268.35937, 15.51562, 0.00000, 0.00000, 39.00000);
	AddSnowObject(6327, 377.28909, -1362.66406, 13.58593, 0.00000, 0.00000, 30.10199);
	AddSnowObject(6330, 525.21093, -1443.21875, 14.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13741, 332.99218, -1331.38281, 32.97656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6356, 381.28125, -1323.17187, 24.49218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6328, 294.97656, -1366.74218, 18.92968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13691, 258.95309, -1366.19531, 62.80468, 0.00000, 0.00000, 38.38000);
	AddSnowObject(13740, 179.30468, -1448.42968, 28.01562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6326, 207.59375, -1484.50781, 11.90625, 0.00000, 0.00000, 207.04595);
	AddSnowObject(6497, 227.78906, -1423.03125, 18.60937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13737, 252.86718, -1288.48437, 64.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13739, 216.09375, -1361.97656, 49.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13690, 135.64062, -1455.68750, 25.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13675, 116.01563, -1393.33593, 24.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6325, 128.12500, -1551.03125, 8.20312, 0.00000, 0.00000, 352.20999);
	AddSnowObject(17281, -42.50780, -1476.89062, 4.31250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17121, -65.05467, -1572.94531, -3.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17118, -52.24219, -1395.50781, 4.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17186, -39.32030, -1566.71875, 1.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17279, -111.00781, -1362.33593, 5.23437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13676, 78.41406, -1270.49218, 13.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13677, 92.21875, -1291.65625, 14.11718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17301, -49.39062, -1140.86718, 5.20312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17297, -28.64842, -1020.34375, 16.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6292, 137.72656, -1026.68750, 24.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17117, 5.04687, -1000.33593, 17.08593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17305, -153.19531, -971.96093, 34.26562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(12851, -51.97655, -842.67187, 19.74218, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17115, -283.96875, -960.07031, 33.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17302, -160.82812, -1100.76562, 6.42968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17296, -178.11718, -1049.76562, 14.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17303, -114.95313, -1179.69531, 3.14843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17119, -226.96093, -1253.90625, 7.86718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6428, 245.19531, -1736.70312, 3.63281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6315, 205.46093, -1656.82031, 8.96875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6416, 95.64842, -1593.14843, -19.21093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6314, 127.64842, -1659.70312, 7.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6293, 125.69531, -1768.54687, -10.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6280, 260.02343, -1839.91406, -1.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6417, 156.53906, -1908.78125, -13.68750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6427, 293.21875, -1691.21875, 7.84375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6448, 335.30468, -1711.90625, 25.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6449, 387.76562, -1823.63281, 12.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6311, 400.69531, -1755.70312, 6.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6297, 432.81250, -1856.28906, 1.22656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6450, 379.72656, -1945.95312, -1.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6300, 379.53906, -2050.86718, -1.21875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6310, 437.89843, -1715.10156, 8.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6281, 570.74218, -1868.34375, 1.67968, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6443, 301.93750, -1657.81250, 19.64843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6313, 437.19531, -1679.44531, 19.22656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6316, 199.40629, -1626.73437, 12.37500, 0.00000, 0.00000, 133.05000);
	AddSnowObject(6312, 202.71093, -1580.11718, 22.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6317, 270.29687, -1613.60156, 32.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6305, 328.57031, -1612.57812, 31.93750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6320, 297.50000, -1490.30468, 32.09375, 0.00000, 0.00000, 31.96500);
	AddSnowObject(6345, 236.54690, -1498.31250, 21.75000, 0.00000, 0.00000, 337.82998);
	AddSnowObject(6347, 238.17968, -1509.85156, 22.11718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6321, 270.69531, -1576.20312, 31.89843, 0.00000, 0.00000, 345.65499);
	AddSnowObject(6341, 332.89062, -1500.06250, 29.87500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6323, 416.46881, -1446.08593, 30.79687, 0.00000, 0.00000, 36.04999);
	AddSnowObject(6319, 444.21881, -1376.51562, 24.67187, 0.00000, 0.00000, 28.30500);
	AddSnowObject(6318, 572.95312, -1328.72656, 13.07031, 0.00000, 0.00000, 14.27000);
	AddSnowObject(6324, 632.57812, -1443.09375, 13.68750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6508, 624.70312, -1252.11718, 14.87500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6331, 473.82031, -1437.41406, 21.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6302, 576.14062, -1406.25781, 13.76562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6322, 496.27343, -1500.14062, 16.66406, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6304, 444.00000, -1521.40625, 27.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6303, 359.21090, -1523.76562, 31.59375, 0.00000, 0.00000, 38.40999);
	AddSnowObject(6343, 389.48437, -1528.78906, 28.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6333, 422.00000, -1583.10156, 23.69531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6329, 557.53906, -1577.91406, 15.03125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6307, 491.46875, -1630.75000, 20.07812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6306, 428.05468, -1654.95312, 24.92187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6308, 565.81250, -1671.28125, 16.36718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6398, 552.53125, -1695.57812, 15.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6064, 688.53125, -1877.96093, 2.01562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6309, 576.64062, -1730.42187, 11.88281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6291, 631.66406, -1647.45312, 14.38281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6225, 724.81250, -1673.65625, 11.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6227, 676.61718, -1668.96093, 3.85156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6231, 753.04687, -1676.26562, 8.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6119, 810.87500, -1703.42968, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6229, 773.20312, -1667.99218, 2.93750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6188, 836.31250, -1866.75781, -0.53906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6120, 845.66406, -1607.29687, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6189, 836.44531, -2003.52343, -2.64062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6114, 1044.78906, -1572.26562, 12.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6121, 926.75000, -1572.27343, 12.51562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6124, 742.40625, -1595.16406, 13.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6111, 784.50000, -1496.20312, 12.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6135, 764.32031, -1509.04687, 16.82812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6094, 731.15625, -1506.53125, 3.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6132, 674.67187, -1483.29687, 17.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6301, 717.48437, -1362.77343, 12.51562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6487, 713.56250, -1236.21875, 17.82031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13700, 536.40625, -1087.24218, 64.62500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13703, 495.41406, -957.49218, 79.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13872, 587.67187, -958.76562, 65.35156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13689, 567.82812, -1031.39843, 71.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13688, 689.69531, -1023.00000, 50.46875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13698, 650.87500, -1076.07812, 38.83593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5765, 819.57812, -986.02337, 35.93750, 0.00000, 0.00000, 116.42299);
	AddSnowObject(5753, 850.82812, -1013.78125, 30.25781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5755, 796.46093, -1111.12500, 23.18750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6507, 696.89837, -1138.50000, 18.19531, 0.00000, 0.00000, 191.77600);
	AddSnowObject(6488, 723.09375, -1144.20312, 24.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5756, 797.91406, -1234.44531, 17.71875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5805, 869.92187, -1144.73437, 22.75781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5871, 879.57031, -1092.87500, 26.15625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5864, 849.91406, -1196.68750, 19.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5865, 892.79687, -1268.61718, 19.72656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5863, 912.88281, -1194.32812, 20.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5705, 830.86718, -1269.12500, 20.85937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5796, 859.89062, -1323.78906, 12.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6490, 717.48437, -1357.30468, 20.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5798, 797.35156, -1357.64062, 12.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5862, 847.35156, -1400.48437, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13693, 560.28125, -1184.89843, 44.22656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13686, 553.59375, -1164.53125, 51.34375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5754, 962.60156, -1056.30468, 30.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5807, 1041.99218, -1039.29687, 30.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5875, 1022.64062, -1080.32812, 27.25781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5758, 1012.59375, -1145.08593, 22.75781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5757, 943.43750, -1220.53125, 17.61718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5759, 1058.11718, -1234.76562, 17.60156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5747, 1084.46875, -1048.88281, 32.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5748, 1133.00781, -1145.96875, 22.77343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5878, 1122.65625, -1080.45312, 26.73437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5752, 989.11718, -966.10156, 39.50781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5866, 916.57812, -952.71093, 43.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5718, 901.23437, -967.47662, 47.65625, 0.00000, 0.00000, 10.00000);
	AddSnowObject(5987, 913.71875, -918.58593, 49.34375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5853, 1018.16412, -908.97662, 43.64843, 0.00000, 0.00000, 7.71999);
	AddSnowObject(5896, 1103.52343, -896.92968, 63.89843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13711, 994.05468, -841.23437, 75.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5802, 1124.57031, -950.24218, 41.75781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13814, 850.87500, -912.80468, 58.14062, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13813, 817.73437, -917.84375, 54.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13716, 849.37500, -828.64843, 73.56250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13713, 970.15625, -818.52343, 90.96093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13887, 967.20312, -715.27343, 107.97656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(13804, 1077.60937, -651.60937, 114.28906, 0.00000, 0.00000, 144.86500);
	AddSnowObject(13717, 1161.32031, -755.01562, 84.80468, 0.00000, 0.00000, 8.92500);
	AddSnowObject(13784, 1156.85937, -852.75781, 49.35937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5741, 1196.84375, -914.86718, 41.96875, 0.00000, 0.00000, 9.50000);
	AddSnowObject(5743, 1265.29687, -889.95312, 40.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5746, 1163.17187, -1046.42968, 32.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5745, 1262.95312, -1037.64843, 32.07031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5801, 1266.13281, -1037.72656, 28.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5806, 1149.63281, -1039.24218, 30.94531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5881, 1310.02343, -985.43750, 41.90625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5793, 1365.47656, -998.26562, 30.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5887, 1212.76562, -1090.07812, 26.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5717, 1212.91406, -988.73437, 42.75781, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5823, 1140.17968, -1207.25781, 18.82031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4649, 1425.16406, -1035.25781, 24.19531, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4650, 1482.25000, -1097.30468, 22.85937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5800, 1355.72656, -1089.84375, 24.33593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4584, 1419.78906, -1096.96093, 20.06250, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5799, 1350.15625, -1170.82031, 19.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6007, 1308.24218, -1088.84375, 26.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4651, 1539.85937, -1087.31250, 22.72656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4568, 1529.90625, -1096.78125, 22.40625, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4652, 1539.84375, -1161.74218, 23.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4567, 1646.46093, -1161.70312, 22.86718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4710, 1762.11718, -1170.89062, 22.76562, 0.00000, 0.00000, 180.00000);
	AddSnowObject(4591, 1753.75781, -1231.39843, 12.44531, 0.00000, 0.00000, 180.00000);
	AddSnowObject(4654, 1715.46093, -1230.87500, 18.26562, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4643, 1654.76562, -1246.28906, 16.17187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5436, 1987.00000, -1408.00000, 17.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5500, 1948.95312, -1461.20312, 12.46875, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4589, 1780.00000, -1281.00000, 13.00000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4592, 1798.46093, -1223.46093, 17.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4556, 1660.04687, -1340.72656, 15.63281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4646, 1650.83593, -1300.85937, 15.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4684, 1661.54687, -1216.45312, 16.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4562, 1574.59375, -1248.10156, 15.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4685, 1572.59375, -1216.50000, 17.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4565, 1513.69531, -1204.80468, 18.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4648, 1419.67968, -1150.12500, 22.86718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4679, 1607.88281, -1324.62500, 32.72656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4553, 1530.83593, -1300.85156, 15.54687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4647, 1454.75781, -1309.12500, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4551, 1410.16406, -1333.39062, 9.92187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(4644, 1416.19531, -1210.87500, 17.59375, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5750, 1350.15625, -1250.83593, 14.13281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5859, 1350.14843, -1353.36718, 12.47656, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5739, 1288.04687, -1203.77343, 17.68750, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5751, 1283.73437, -1145.08593, 22.61718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5804, 1213.76562, -1177.09375, 19.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5707, 1269.39843, -1256.96093, 14.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6006, 1183.69531, -1241.35937, 16.27343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5857, 1259.43750, -1246.81250, 17.10937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5749, 1144.40625, -1251.48437, 15.10937, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5703, 998.15625, -1220.82031, 15.83593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5812, 1230.89062, -1337.98437, 12.53906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5794, 1200.90625, -1337.99218, 12.39843, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5810, 1114.31250, -1348.10156, 17.98437, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5994, 1259.22656, -1400.40625, 10.78125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5995, 1130.05468, -1400.70312, 12.52343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5860, 1058.14843, -1363.26562, 12.61718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5795, 985.72656, -1324.79687, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5732, 1014.02343, -1361.46093, 20.35156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5808, 1255.24218, -1337.96093, 12.32812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5809, 1281.43750, -1337.95312, 12.37500, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6035, 1329.03125, -1479.07812, 12.46093, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6101, 1268.24218, -1467.84375, 11.82031, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6129, 1205.11718, -1572.27343, 12.42187, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6125, 1196.03906, -1489.07031, 12.37500, 0.00000, 0.00000, 0.00000);
	//AddSnowObject(6130, 1117.58593, -1490.00781, 32.71875, 0.00000, 0.00000, 0.00000); Verona Mall
	AddSnowObject(5861, 979.94531, -1400.49218, 12.36718, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6055, 1050.08593, -1489.03906, 12.53906, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6113, 984.29687, -1491.40625, 12.50000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6152, 990.08593, -1450.08593, 12.77343, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6160, 982.61718, -1530.82812, 12.83593, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6112, 917.50000, -1489.10156, 12.29687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6217, 846.45312, -1523.52343, 12.35156, 0.00000, 0.00000, 0.00000);
	AddSnowObject(6059, 855.09375, -1461.80468, 12.79687, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5815, 877.16406, -1361.20312, 12.45312, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5797, 917.35937, -1361.24218, 12.38281, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5784, 988.27337, -1289.63281, 15.37500, 0.00000, 0.00000, 180.00000);
	AddSnowObject(5760, 1016.92968, -1249.92968, 18.50000, 0.00000, 0.00000, 270.00000);
	AddSnowObject(4879, 1374.25781, -2184.03906, 21.07812, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17665, 2604.34375, -1220.23437, 54.75000, 0.00000, 0.00000, 0.00000);
	AddSnowObject(17629, 2338.92968, -1299.60156, 23.03125, 0.00000, 0.00000, 0.00000);
	AddSnowObject(5624, 2136.72656, -975.82812, 58.10937, 0.00000, 0.00000, 345.00500); */
// ------------------ texture snijega po gradu ---------------------------------
	return 1;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	for( new i=0 ; i<8 ; i++ ) {
		if( areaid == iceArea[ i ] ) {
		    Bit1_Set( gr_PlayerInsideIce, playerid, true );
		}
	}
	return 1;
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
    for( new i=0 ; i<8 ; i++ ) {
		if( areaid == iceArea[ i ] ) {
		    Bit1_Set( gr_PlayerInsideIce, playerid, false );
		}
	}
	return 1;
}

/*
	.d8888. d8b   db d888888b    d88b d88888b  d888b  
	88'  YP 888o  88   88'      8P' 88'     88' Y8b 
	8bo.   88V8o 88    88        88  88ooooo 88      
	  Y8b. 88 V8o88    88        88  88~~~~~ 88  ooo 
	db   8D 88  V888   .88.   db. 88  88.     88. ~8~ 
	8888Y' VP   V8P Y888888P Y8888P  Y88888P  Y888P  
*/

public OnPlayerObjectMoved(playerid, objectid)
{
	if( Bit1_Get( gr_PlayerSnowing, playerid ) ) {
		if(objectid == snowObject[ playerid ][ 0 ]) {
			MoveSnowObject(playerid, objectid);
		}
		if(objectid == snowObject[ playerid ][ 1 ]) {
			MoveSnowObject(playerid, objectid);
		}
	}

	#if defined WINT_OnPlayerObjectMoved
        WINT_OnPlayerObjectMoved(playerid, objectid);
    #endif
    return 1;
}
#if defined _ALS_OnPlayerObjectMoved
    #undef OnPlayerObjectMoved
#else
    #define _ALS_OnPlayerObjectMoved
#endif
#define OnPlayerObjectMoved WINT_OnPlayerObjectMoved
#if defined WINT_OnPlayerObjectMoved
    forward WINT_OnPlayerObjectMoved(playerid, objectid);
#endif


hook OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, COLOR_PURPLE, "** U Los Santosu je trenutno zimska temperatura i vani je hladno.");
	RemoveBuildingForPlayer(playerid, 1226, 1945.0547, -2162.4531, 16.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 1951.6172, -2156.4844, 12.7500, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 1952.0313, -1801.0156, 11.7188, 0.25);
	return 1;
}
	
/* hook OnPlayerDisconnect(playerid, reason)
{
    if(PlayerIceSkates[playerid])
    {
        KillTimer(IceUpdateTimer[playerid]);
        PlayerIceSkates[playerid] = false;
    }
	temperatureUpdateTime[playerid] = 0;
    return 1;
} */
hook OnPlayerText(playerid, text[])
{
    // Zadah - Kada igrac napiSe neku poruku izaci ce mu iz usta Dim
    SetPlayerAttachedObject(playerid, SLOT_ZADAH, 18696, 2,0.0,0.1,-0.2,-25.5000,0.0,0.0,0.10,0.3,0.15);
    return 1;
}
 
/* /// TIMER
forward OnPlayerIceUpdate(playerid);
public OnPlayerIceUpdate(playerid)
{
	if(!PlayerIceSkates[playerid]) 
	{ 
		KillTimer(IceUpdateTimer[playerid]); 
		return 1;
	}
    if(!IsPlayerInRangeOfPoint(playerid, 35.0, 1947.5088, -1198.3165, 18.7285) && !IsPlayerInRangeOfPoint(playerid, 35.0, 1996.2863, -1200.5106, 18.7355) && !IsPlayerInRangeOfPoint(playerid, 60.0, 1971.9452, -1200.5581, 18.7339))
    {
        SendClientMessage(playerid, COLOR_RED, "Napustili ste klizaliste pa se ne mozete klizati!");
        PlayerIceSkates[playerid] = false;
        ApplyAnimationEx(playerid, "CARRY","crry_prtial",4.0,0,0,0,0,0,1,0);
        KillTimer(IceUpdateTimer[playerid]);
    }
    return 1;
} */

/*
	 ######  ##     ## ########
	##    ## ###   ### ##     ## 
	##       #### #### ##     ## 
	##       ## ### ## ##     ## 
	##       ##     ## ##     ## 
	##    ## ##     ## ##     ## 
	 ######  ##     ## ########  
*/
/*
CMD:rent_skije(playerid, params[])
{
	if( !IsPlayerInRangeOfPoint(playerid, 8.0, -1463.7601, -953.3459, 204.3 ) ) return SendClientMessage(playerid, COLOR_RED, "Niste blizu resort shopa!");
	if( AC_GetPlayerMoney(playerid) < 80 ) return SendClientMessage(playerid, COLOR_RED, "Nemate 80$!");
	
	PlayerToBudgetMoney(playerid, 80);
	new
		Float:X, Float:Y, Float:Z, Float:Angle;
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, Angle);
	GetXYInFrontOfPlayer(playerid, X, Y, 2.0);
	SkiInfo[ playerid ][ spVehicleId ] = AC_CreateVehicle(441, -1450.7699, -960.3964, 202.1185, Angle, 0, 0, -1);
	
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vModel ] 	= 441;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vColor1 ] 	= 0;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vColor2 ] 	= 0;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vParkX ]		= -1450.7699;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vParkY ]     = -960.3964;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vParkZ ]     = 202.1185;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vAngle ]     = Angle;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vHealth ]	= 2000.0;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vType ]		= VEHICLE_TYPE_CAR;
	VehicleInfo[ SkiInfo[ playerid ][ spVehicleId ] ][ vUsage ] 	= VEHICLE_USAGE_NORMAL;
	
	new
		engine,lights,alarm,doors,bonnet,boot,objective;
	GetVehicleParamsEx(SkiInfo[ playerid ][ spVehicleId ],engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(SkiInfo[ playerid ][ spVehicleId ],VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
	
	SendClientMessage(playerid, COLOR_RED, "[ ! ] Koristite ~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~ za kontrolu skija!");
	PutPlayerInVehicle(playerid, SkiInfo[ playerid ][ spVehicleId ], 0);
	LinkVehicleToInterior(SkiInfo[ playerid ][ spVehicleId ], 99);
	SetVehicleHealth(SkiInfo[ playerid ][ spVehicleId ], 2000.0);
	
	new
		tmpobjid;
	SkiInfo[ playerid ][ spObject ][ 0 ] = tmpobjid = CreateDynamicObject(2907, X,Y,Z,   -90.0000, 0.0000, 0.0000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", -1);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], -0.0141, 0.0692, 1.1000,   -90.0000, 0.0000, 0.0000);

	SkiInfo[ playerid ][ spObject ][ 1 ] = tmpobjid = CreateDynamicObject(18645, X,Y,Z,   0.00000, 0.00000, 85.92000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", -1);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.03450, 0.03500, 1.62000,   0.00000, 0.00000, 85.92000);

	SkiInfo[ playerid ][ spObject ][ 2 ] = tmpobjid = CreateDynamicObject(2906, X,Y,Z,   0.00000, 0.00000, -5.40000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", -1);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.18058, 0.25796, 1.38000,   0.00000, 0.00000, -5.40000);

	SkiInfo[ playerid ][ spObject ][ 3 ] = tmpobjid = CreateDynamicObject(2906, X,Y,Z,   180.00000, 0.00000, -172.08000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", -1);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], -0.19010, 0.26024, 1.38800,   180.00000, 0.00000, -172.08000);

	SkiInfo[ playerid ][ spObject ][ 4 ] = tmpobjid = CreateDynamicObject(2905, X,Y,Z,   -90.00000, 0.00000, 270.00000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", -1);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], -0.0889, 0.1020, 0.3500,   -90.00000, 0.00000, 270.00000);

	SkiInfo[ playerid ][ spObject ][ 5 ] = tmpobjid = CreateDynamicObject(2905, X,Y,Z,   -90.00000, 0.00000, 270.00000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", -1);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.10770, 0.10800, 0.35000,   -90.00000, 0.00000, 270.00000);

	SkiInfo[ playerid ][ spObject ][ 6 ] = tmpobjid = CreateDynamicObject(1897, X,Y,Z,   90.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(tmpobjid, 0, 8947, "vgslockup", "vegasoffice05_128", -16750849);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], -0.11500, 0.25160, -0.18500,   90.00000, 0.00000, 0.00000);

	SkiInfo[ playerid ][ spObject ][ 7 ] = tmpobjid = CreateDynamicObject(1897, X,Y,Z,   90.00000, 0.00000, 0.00000);
	SetDynamicObjectMaterial(tmpobjid, 0, 8947, "vgslockup", "vegasoffice05_128", -16750849);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.11080, 0.25160, -0.18500,   90.00000, 0.00000, 0.00000);

	SkiInfo[ playerid ][ spObject ][ 8 ] = tmpobjid = CreateDynamicObject(3004, X,Y,Z,   90.00000, 0.00000, 783.95880);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", -16777216);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], -0.28202, 0.57011, -0.08900,   90.00000, 0.00000, 783.95880);

	SkiInfo[ playerid ][ spObject ][ 9 ] = tmpobjid = CreateDynamicObject(3004, X,Y,Z,   90.00000, 0.00000, 996.05957);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", -16777216);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.24599, 0.51881, -0.08900,   90.00000, 0.00000, 996.05957);
	
	SkiInfo[ playerid ][ spObject ][ 10 ] = tmpobjid = CreateDynamicObject(1313, X,Y,Z,   0.00000, 0.00000, 2.50000);
	SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF55ADE8);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.0213, -0.0599, 1.3000,   0.0000, 0.0000, 3.1200);
	
	SkiInfo[ playerid ][ spObject ][ 11 ] = tmpobjid = CreateDynamicObject(1274, X,Y,Z,   1.50000, 0.00000, 7.80000);
	SetDynamicObjectMaterial(tmpobjid, 0, 10765, "airportgnd_sfse", "white", 0xFF55ADE8);
	AttachDynamicObjectToVehicle(tmpobjid, SkiInfo[ playerid ][ spVehicleId ], 0.00500, 0.17500, 1.15000,   1.50000, 0.00000, 7.80000);
	return 1;
}*/

/* CMD:make_snowball(playerid, params[])
{
	if( GetPlayerInterior(playerid) ) return SendClientMessage(playerid, COLOR_RED, "Morate biti vani da biste uzeli snijeg!");
	if( Bit1_Get(gr_PlayerHaveSnowBall, playerid ) ) return SendClientMessage(playerid, COLOR_RED, "Vec imate grudu u rukama! Pucate s tipkom ~k~~PED_FIREWEAPON~!");
	
	ApplyAnimationEx(playerid, "BOMBER", "BOM_Plant_Loop", 3.1, 1,0,0,1000,0,1,0);
	Bit1_Set(gr_PlayerHaveSnowBall, playerid, true );
	SendClientMessage(playerid, COLOR_RED, "[ ! ] Napravili ste grudu, pucate s tipkom ~k~~PED_FIREWEAPON~!");
	return 1;
} */
CMD:snow_on(playerid, params[])
{
	if( PlayerInfo[playerid][pAdmin] < 4 ) return SendClientMessage(playerid,COLOR_RED, "Niste ovlasteni!");
	ServerSnowing = true;
	foreach(new i : Player) 
	{
		SendClientMessage(i, 0xA9C4E4FF, "HO HO HO! Sretne blagdane Vam zeli City of Angels Server Team!");
		StartSnowFallingForPlayer(i);
		snowTimer[playerid] = SetTimerEx("OnPlayerSnowingMove", 1000, true, "i", playerid);
	}
	return 1;
}
CMD:snow_off(playerid, params[])
{
	if( PlayerInfo[playerid][pAdmin] < 4 ) return SendClientMessage(playerid,COLOR_RED, "Niste ovlasteni!");
	foreach(new i : Player) 
	{
		DestroyPlayerSnow(i);
	}	
	ServerSnowing = false;
	return 1;
}
/* CMD:wish(playerid, params[])
{
	if( PlayerInfo[playerid][pWish] != 0 ) return SendClientMessage(playerid,COLOR_RED, "Vec ste zazeljeli zelju!");
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /wish [zelja]");
		
	new insertQuery[ 256 ], string[128];
	format(insertQuery, sizeof(insertQuery), "INSERT INTO wish (playerid, wish) VALUES ('%d', '%e')",
		PlayerInfo[ playerid ][ pSQLID ],
		params
	);
	mysql_tquery( g_SQL, insertQuery, "", "" );
	PlayerInfo[ playerid ][ pWish ] = 1;
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Zazeljeo si zelju :)");
	va_SendClientMessage(playerid, COLOR_WHITE, "Tekst: %s", params);
	format(string, sizeof(string), "AdmWISH: %s je upravo zaljezeo zelju.", GetName(playerid,false));
	SendAdminMessage(COLOR_RED, string);
	return 1;
} */

/* CMD:ice_skates(playerid, params[])
{
    if(PlayerIceSkates[playerid])
    {
		KillTimer(IceUpdateTimer[playerid]);
        PlayerIceSkates[playerid] = false;
        SendClientMessage(playerid, COLOR_RED, "[ ! ] Skinuli ste klizaljke!");
        ApplyAnimationEx(playerid, "CARRY","crry_prtial",4.0,0,0,0,0,0,1,0);
        return 1;
    }
    if(IsPlayerInRangeOfPoint(playerid, 35.0, 1947.5088, -1198.3165, 18.7285) || IsPlayerInRangeOfPoint(playerid, 35.0, 1996.2863, -1200.5106, 18.7355) || IsPlayerInRangeOfPoint(playerid, 60.0, 1971.9452, -1200.5581, 18.7339))
    {
        SendClientMessage(playerid, COLOR_RED, "[ ! ] Obukli ste klizaljke sada se moZete klizati! Koristite ");
        PlayerIceSkates[playerid] = true;
        IceUpdateTimer[playerid] = SetTimerEx("OnPlayerIceUpdate", 500, true, "i", playerid);
    }
    else
    {
        return SendClientMessage(playerid, COLOR_RED, "Niste blizu klizaliSta!");
    }
    return 1;
}
 */