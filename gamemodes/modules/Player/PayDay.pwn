#include <YSI_Coding\y_hooks>

#if defined MODULE_PAY_DAY
	#endinput
#endif
#define MODULE_PAY_DAY

#define SOCIAL_HELP 		(1000) 
#define PD_SD_SALARY 		(700)
#define FD_LSN_SALARY 		(800) 
#define GOV_SALARY	 		(1000) 

/*
                                                                      
	88b           d88              ad88888ba    ,ad8888ba,   88           
	888b         d888             d8"     "8b  d8"'    `"8b  88           
	88`8b       d8'88             Y8,         d8'        `8b 88           
	88 `8b     d8' 88 8b       d8 `Y8aaaaa,   88          88 88           
	88  `8b   d8'  88 `8b     d8'   `"""""8b, 88          88 88           
	88   `8b d8'   88  `8b   d8'          `8b Y8,    "88,,8P 88           
	88    `888'    88   `8b,d8'   Y8a     a8P  Y8a.    Y88P  88           
	88     `8'     88     Y88'     "Y88888P"    `"Y8888Y"Y8a 88888888888  
						d8'                                             
						d8'                             

*/

LoadPlayerPayday(playerid)
{
    mysql_pquery(g_SQL, 
        va_fquery(g_SQL, "SELECT * FROM player_job WHERE sqlid = '%d'", PlayerInfo[playerid][pSQLID]),
        "LoadingPlayerPayday", 
        "i", 
        playerid
    );
    return 1;
}

Public: LoadingPlayerPayday(playerid)
{
    if(!cache_num_rows())
    {
        mysql_fquery_ex(g_SQL, 
            "INSERT INTO player_job(sqlid, payday, paydaymoney, paydayhad, profit, dialog, date) \n\
                VALUES('%d', '0', '0', '0', '0', ' ', ' ')",
            PlayerInfo[playerid][pSQLID]
        );
        return 1;
    }
    cache_get_value_name_int(0, "payday"	    , PaydayInfo[playerid][pPayDay]);	
    cache_get_value_name_int(0, "paydaymoney"	, PaydayInfo[playerid][pPayDayMoney]);
    cache_get_value_name_int(0, "paydayhad"	    , PaydayInfo[playerid][pPayDayHad]);
    cache_get_value_name_int(0, "profit"		, PaydayInfo[playerid][pProfit]);
    cache_get_value_name(0, 	"dialog"	    , PaydayInfo[playerid][pPayDayDialog], 1536);
    cache_get_value_name(0, 	"date"	        , PaydayInfo[playerid][pPayDayDate], 32);
    return 1;
}

hook LoadPlayerStats(playerid)
{
    LoadPlayerPayday(playerid);
    return 1;
}

SavePlayerPayday(playerid)
{
    mysql_fquery_ex(g_SQL,
        "UPDATE player_payday SET payday = '%d', paydaymoney = '%d', paydayhad = '%d', profit = '%d',\n\
            dialog = '%e', date = '%e' WHERE sqlid = '%d'",
        PaydayInfo[playerid][pPayDay],
        PaydayInfo[playerid][pPayDayMoney],
        PaydayInfo[playerid][pPayDayHad],
        PaydayInfo[playerid][pProfit],
        PaydayInfo[playerid][pPayDayDialog],
        PaydayInfo[playerid][pPayDayDate],
        PlayerInfo[playerid][pSQLID]
    );
    return 1;
}

hook SavePlayerStats(playerid)
{
    SavePlayerPayday(playerid);
    return 1;
}

hook ResetPlayerVariables(playerid)
{
    PaydayInfo[playerid][pPayDay] = 0;
    PaydayInfo[playerid][pPayDayMoney] = 0;
    PaydayInfo[playerid][pPayDayHad] = 0;
    PaydayInfo[playerid][pProfit] = 0;
    PaydayInfo[playerid][pPayDayDialog][0] = EOS;
    PaydayInfo[playerid][pPayDayDate][0] = EOS;
    return 1;
}



/*
	######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######
	##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ##
	##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##
	######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######
	##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ##
	##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ##
	##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######
*/

GivePlayerPayCheck(playerid)
{
	//CheckCityBudget(); // Provjera stanja legalnog i ilegalnog proracuna
	new
		houselost 			= 0,
		rentlost 			= 0,
		complexlost			= 0,
		kreditlost			= 0,
		complexroomlost 	= 0,
		orgsalary			= 400, // minimalna placa
		orgbonus			= 0,
		profit 				= 0,
		p_dialog[2048],
		f_dialog[256];
	
	strcpy(PaydayInfo[playerid][pPayDayDate], ReturnDate(), 32);
	
	format(p_dialog, sizeof(p_dialog), "\t %s - Financijsko izvjesce - %s", PaydayInfo[playerid][pPayDayDate], GetName(playerid));
	
	// Pretplata na CRYPTO 50 dolara
	if(PlayerMobile[playerid][pCryptoNumber] != 0 || PlayerMobile[playerid][pMobileCost] > 0)
	{
		format(f_dialog,sizeof(f_dialog), "\n{3C95C2}Troskovi pretplate:");
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
	}
	if(PlayerMobile[playerid][pCryptoNumber] != 0){

		format(f_dialog,sizeof(f_dialog), "\n\tCrypto pretplata: -50$");
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		PlayerToIllegalBudgetMoney(playerid, 50);
		profit -= 50;
	}
	// Mobilna pretplata - 1$ po SMS-u, 2$ po minuti poziva
	if(PlayerMobile[playerid][pMobileCost] > 0)
	{
		format(f_dialog, sizeof(f_dialog), "\n\tMobilna pretplata: -%d$", PlayerMobile[playerid][pMobileCost]); 
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		PlayerToBudgetMoney(playerid, PlayerMobile[playerid][pMobileCost]);
		PlayerMobile[playerid][pMobileCost] = 0;
		profit -= PlayerMobile[playerid][pMobileCost];
		
		mysql_fquery(g_SQL, "UPDATE player_phones SET money = '%d' WHERE player_id = '%d' AND type = '1'",
			PlayerMobile[playerid][pMobileCost],
			PlayerInfo[playerid][pSQLID]
		);
	}
	format(f_dialog,sizeof(f_dialog), "\n{3C95C2}Imovina:");
	strcat(p_dialog,f_dialog, sizeof(p_dialog));
	// Posjeduje kucu -> bills
	if(PlayerKeys[playerid][pHouseKey] != INVALID_HOUSE_ID && PlayerKeys[playerid][pHouseKey] > 0) {
		new house = PlayerKeys[playerid][pHouseKey];

		houselost += floatround( 0.001 * HouseInfo[ house ][ hValue ] );
		format(f_dialog,sizeof(f_dialog), "\n\tTroskovi kuce + porez: %s", FormatNumber(houselost));
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		PlayerBankToBudgetMoney(playerid, houselost); // u proracun novac od kuce
		profit -= houselost;
	}
	// Ako kod nekoga renta
	if( PlayerKeys[playerid][pRentKey] != INVALID_HOUSE_ID && PlayerKeys[playerid][pRentKey] >= 0 )  {
		new house = PlayerKeys[playerid][pRentKey];
		if(PlayerInfo[playerid][pBank] >= HouseInfo[ house ][ hRent ])
		{
			rentlost += HouseInfo[ house ][ hRent ];
			format(f_dialog,sizeof(f_dialog), "\n\tTroskovi najma kuce: %s", FormatNumber(rentlost));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			PlayerBankToHouseMoneyTAX(playerid, house, HouseInfo[ house ][ hRent ]); // Novac iz banke igraca ide u kucu vlasnika kuce koji renta
			profit -= HouseInfo[ house ][ hRent ];
		}
		else {
			SendMessage(playerid, MESSAGE_TYPE_INFO, "Izbaceni ste iz podstanarstva jer nemate za najamninu na bankovnom racunu.");
			PlayerKeys[playerid][pRentKey] = INVALID_HOUSE_ID;
			PlayerKeys[playerid][pRentKey] = INVALID_HOUSE_ID;
			PlayerInfo[ playerid ][ pSpawnChange ] = 0;
			SetPlayerSpawnInfo(playerid);
		}
	}
	//Rentroom complex - ako igra? renta kompleks room (**oporezivo**)
	if(PlayerKeys[playerid][pComplexRoomKey] != INVALID_COMPLEX_ID)
	{
		new price = ComplexRoomInfo[PlayerKeys[playerid][pComplexRoomKey]][cValue];
		complexroomlost += price;
		foreach(new c : Complex)
		{
		    if(ComplexInfo[c][cSQLID] == ComplexRoomInfo[PlayerKeys[playerid][pComplexRoomKey]][cComplexID])
		    {
				profit -= complexroomlost;
				PlayerBankToComplexMoneyTAX(playerid, c, complexroomlost);
				format(f_dialog,sizeof(f_dialog), "\n\tNajam complex sobe: %s", FormatNumber(complexroomlost));
				strcat(p_dialog,f_dialog, sizeof(p_dialog));
				break;
		    }
		}
	}
	// Posjeduje kompleks
    if(PlayerKeys[playerid][pComplexKey] != INVALID_COMPLEX_ID) {
        //complexlost += floatround( 25 * PlayerInfo[ playerid ][ pLevel ] );
		// pogurati malo komplekse da ih ljudi kupuju
		complexlost += minrand(200, 1000);
		format(f_dialog,sizeof(f_dialog), "\n\tDobit complexa: +%s", FormatNumber(complexlost)); // Troskovi prebaceni u dobit
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		BudgetToPlayerBankMoney(playerid, complexlost);
		profit += complexlost;
    }
	// Ako posjeduje biznis
	if( PlayerKeys[playerid][pBizzKey] != INVALID_BIZNIS_ID ) {
		new bizid = PlayerKeys[playerid][pBizzKey],
			possibility = minrand(0, 800);
		if (possibility >= 200) {
			BudgetToBusinessMoney ( bizid, possibility);
			format(f_dialog,sizeof(f_dialog), "\n\tPoslovanja biznisa: +%s", FormatNumber(possibility));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			profit += possibility;
		}
		else {
			BusinessToBudgetMoney ( bizid, possibility); // novac iz blagajne biznisa ide u proracun
			format(f_dialog,sizeof(f_dialog), "\n\tPoslovanja biznisa: -%s", FormatNumber(possibility));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			profit -= possibility;
		}
	}
	// Troskovi kredita
	if(CreditInfo[playerid][cCreditType] > 0) 
	{
		format(f_dialog,sizeof(f_dialog), "\n{3C95C2}Banka:");
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		switch(CreditInfo[playerid][cCreditType])
		{
			case 1:  {
				if(CreditInfo[playerid][cRate] >= 1 && CreditInfo[playerid][cRate] <= 250)
					kreditlost += 50;
			}
			case 2:  {
				if(CreditInfo[playerid][cRate] >= 1 && CreditInfo[playerid][cRate] <= 250)
					kreditlost += 100;
			}
			case 3:  {
				if(CreditInfo[playerid][cRate] >= 1 && CreditInfo[playerid][cRate] <= 250)
					kreditlost += 250;
			}
			case 4:  {
				if(CreditInfo[playerid][cRate] >= 1 && CreditInfo[playerid][cRate] <= 250)
					kreditlost += 400;
			}
			case 5 .. 7:  
			{ // Namjenski krediti
				if(!CreditInfo[playerid][cUsed])
					goto payday_savings;
					
				new amount = CreditInfo[playerid][cAmount] / 250;
				if(CreditInfo[playerid][cRate] >= 1 && CreditInfo[playerid][cRate] <= 250)
					kreditlost += amount;
			}
			
		}
		if(PlayerInfo[playerid][pBank] < kreditlost)
		{
			CreditInfo[playerid][cUnpaid]++;
			if(CreditInfo[playerid][cUnpaid] > 3) // Ukoliko ima 3 neplacene rate kredita, 4. payday mu automatski naplacuje potrazivanje iz imovine
			{	
				TakePlayerProperty(playerid);
				ResetCreditVars(playerid);
				SavePlayerCredit(playerid);
			}
			else
			{
				format(f_dialog,sizeof(f_dialog), "\n\tNemate dovoljno novaca na racunu da bi se naplatilo %d$ za ratu kredita. Ovo vam je %d. neplacena rata.\nUkoliko imate vise od 3 neplacene rate kredita, banka naplacuje potrazivanja "COL_RED"oduzimanjem imovine.",
					kreditlost,
					CreditInfo[playerid][cUnpaid]
				);
				strcat(p_dialog,f_dialog, sizeof(p_dialog));
			}
		}
		else 
		{
			PlayerBankToBudgetMoney(playerid, kreditlost); // Novac od rate kredita ide u proracun
			CreditInfo[ playerid ][ cRate ] += 1; // dodaje mu ratu kredita za jedan
			format(f_dialog,sizeof(f_dialog), "\n\tRata kredita: -%s", FormatNumber(kreditlost));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
		if( CreditInfo[ playerid ][ cRate ] >= 250 ) { //ako je rata kredita 250(250.), kredit mu je otplacen
			CreditInfo[ playerid ][ cRate ] 		= 0;
			CreditInfo[ playerid ][ cCreditType ] 	= 0;
			format(f_dialog,sizeof(f_dialog), "\n\tOtplatili ste zadnju ratu kredita!");
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
	}
	payday_savings:
	// Savings
	if(PlayerSavings[playerid][pSavingsType] > 0)
	{
		PlayerSavings[playerid][pSavingsTime]--;
		if(PlayerSavings[playerid][pSavingsTime] <= 0)
		{
			new	
				Float:savingsmoneyfloat = PlayerSavings[playerid][pSavingsMoney] 
						* floatdiv(PlayerSavings[playerid][pSavingsType], 100), 	
				savingsmoney = floatround(savingsmoneyfloat), // zaokruzuje ga
				totalmoney = PlayerSavings[playerid][pSavingsMoney] + savingsmoney; // dodaje stopu na glavnicu


			BudgetToPlayerBankMoney(playerid, totalmoney);

			PlayerSavings[playerid][pSavingsCool] = 30;
			PlayerSavings[playerid][pSavingsTime] = 0;
			PlayerSavings[playerid][pSavingsType] = 0;
			PlayerSavings[playerid][pSavingsMoney] = 0;

			mysql_fquery(g_SQL, 
				"UPDATE accounts SET bankMoney = '%d'WHERE sqlid = '%d'",
				PlayerInfo[playerid][pBank],
				PlayerInfo[playerid][pSQLID]
			);
			format(f_dialog,sizeof(f_dialog), "\n\t{3C95C2}Stednja:");
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			format(f_dialog,sizeof(f_dialog), "\nProslo je vase vrijeme orocene stednje, te se primili %s na svoj bankovni racun!", FormatNumber(totalmoney));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
		SavePlayerSavings(playerid);
	}
	if(PlayerSavings[playerid][pSavingsCool] > 0)
	{
		PlayerSavings[playerid][pSavingsCool] -= 1;
		if(PlayerSavings[playerid][pSavingsCool] < 0)
			PlayerSavings[playerid][pSavingsCool] = 0;

		SavePlayerSavings(playerid);
	}
	format(f_dialog,sizeof(f_dialog), "\n{3C95C2}Prihodi:");
	strcat(p_dialog,f_dialog, sizeof(p_dialog));
	// Dobitak ako je u organizaciji I AKO NIJE
	if(PlayerFaction[playerid][pMember] > 0 )
	{
		new
			factionbank = FactionInfo[PlayerFaction[playerid][pMember]][fFactionBank], //dohvati koliko novaca ima fakcija u kojoj je igrac
			orgranks = FactionInfo[PlayerFaction[playerid][pMember]][fRanks], 					//dohvati koliko rankova ima fakcija u kojoj je igrac
			Float:salarypercent = 0.01;

		switch (PlayerFaction[playerid][pMember] ) {
			case 1, 3: { //LSPD i SASD
				for( new i = 0; i <= PlayerFaction[playerid][pRank]; i++ )
					orgsalary += floatround(PD_SD_SALARY/orgranks);
			}
			case 2, 5: { //LSFD i LSN
				for( new i = 0; i <= PlayerFaction[playerid][pRank]; i++ )
					orgsalary += floatround(FD_LSN_SALARY/orgranks);
			}
			case 4: { //GOV 1400
				for( new i = 0; i <= PlayerFaction[playerid][pRank]; i++ )
					orgsalary += floatround(GOV_SALARY/orgranks);
			}
			default: {
				orgsalary = 200;
			}
		}

		orgbonus = floatround(factionbank * salarypercent); 											// 0.01$% od FactionBanke organizacije
		BudgetToPlayerBankMoney(playerid, orgsalary); 													// Novac iz proracuna igracu na bank. racun
		FactionToPlayerBankMoney( playerid, FactionInfo[PlayerFaction[playerid][pMember]][fType], orgbonus); 		// Novac iz factionbanke igra?u na bank.ra?un.
		orgsalary += orgbonus;
		profit += orgsalary;
		format(f_dialog,sizeof(f_dialog), "\n\tPlaca: +%s (Bonus: %s)", FormatNumber(orgsalary), FormatNumber(orgbonus));
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
	}
	if(PaydayInfo[playerid][pPayDayMoney] > 0)
	{
		format(f_dialog,sizeof(f_dialog), "\n\tIsplata odradjenog posla: +%s", FormatNumber(PaydayInfo[playerid][pPayDayMoney]));
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		profit += PaydayInfo[playerid][pPayDayMoney];
	}
	if(PlayerVIP[playerid][pDonateRank] > 0)
	{
		new vipmoney = 0;
		switch(PlayerVIP[playerid][pDonateRank])
		{
			case PREMIUM_BRONZE, PREMIUM_SILVER, PREMIUM_GOLD: 
				vipmoney = 200;
			case PREMIUM_PLATINUM: 
				vipmoney = 300;
		}
		BudgetToPlayerBankMoney(playerid, vipmoney); // treba prebaciti na bankovni racun
		profit += vipmoney;
		format(f_dialog,sizeof(f_dialog), "\n\tBonus gradskog ureda za demografiju: %s", FormatNumber(vipmoney));
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
	}
	if(PlayerInfo[playerid][pLevel] < 5) // Ako nema posao dobiva socijalnu pomoc
	{
		new levelrespect = ( PlayerInfo[playerid][pLevel] + 1 ) * 4; // Trenutni respekti za njegov level
		if ( PlayerInfo[playerid][pRespects] <= levelrespect ) 
		{ // Ako ima manje respekata od za trenutni level
			new level = PlayerInfo[playerid][pLevel],
				fsalary = 1000 / level, // SOCIAL_HELP
				bsalary = floatround(floatabs(fsalary));

			BudgetToPlayerBankMoney(playerid, bsalary); // treba prebaciti na bankovni racun
			profit += bsalary;
			format(f_dialog,sizeof(f_dialog), "\n\tSocijalna pomoc: %s", FormatNumber(bsalary));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
	}
	if(PlayerJob[playerid][pJob] == 6 || PlayerJob[playerid][pJob] == 3) { // IC POSLOVI
		if(PlayerJob[playerid][pJob] == 6) {
			new taxi_job = PlayerJob[playerid][pContractTime] * 8, calculate = 0;
			if(taxi_job > 700)
				taxi_job = 700;
				
			BudgetToPlayerBankMoney(playerid, taxi_job);  // bonus

			profit += taxi_job;
			format(f_dialog,sizeof(f_dialog), "\n\tTaxi Company bonus: %s", FormatNumber(calculate));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			PaydayInfo[playerid][pPayDayMoney] = 0;
		}
		else if(PlayerJob[playerid][pJob] == 3) {
			new workingbonus = PlayerJob[playerid][pContractTime] * 8;
			if(workingbonus > 700)
				workingbonus = 700;

			profit += workingbonus;
			BudgetToPlayerBankMoney(playerid, workingbonus); // bonus
			format(f_dialog,sizeof(f_dialog), "\n\tMechanic Company bonus: %s", FormatNumber(workingbonus));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
	}
	if(PlayerJob[playerid][pJob] > 0 && PlayerJob[playerid][pContractTime] >= 1) // OOC poslovi
	{
		if(PlayerJob[playerid][pJob] != 9 && PlayerJob[playerid][pJob] != 10 && PlayerJob[playerid][pJob] != 12 && PlayerJob[playerid][pJob] != 13 && PlayerJob[playerid][pJob] != 6 && PlayerJob[playerid][pJob] != 3)
		{
			new workingbonus;
			workingbonus = PlayerJob[playerid][pContractTime] * 10;
			if(workingbonus > 500)
				workingbonus = 500; // Maksimum je 500$ po paydayu
			BudgetToPlayerBankMoney(playerid, workingbonus); // treba prebaciti na bankovni racun
			profit += workingbonus;
			format(f_dialog,sizeof(f_dialog), "\n\tPoticaj na radni staz: %s", FormatNumber(workingbonus));
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
	}
	// HAPPY HOURS
	if( HappyHours )
		PlayerInfo[playerid][pRespects] += ( PlayerInfo[playerid][pLevel] < HappyHoursLVL ) ? 2 : 1;
	else 
	{
	    if( ExpInfo[playerid][eDayPayDays] > 5 )
	        PlayerInfo[playerid][pRespects] += ExpInfo[playerid][eDayPayDays];
		else
			PlayerInfo[playerid][pRespects]++;
 	}
	format(f_dialog,sizeof(f_dialog), "\nUkupni profit: "COL_GREEN"+%s "COL_RED"(Izracun ne sadrzi troskove kredita i dobitke stednje)", FormatNumber(profit));
	strcat(p_dialog,f_dialog, sizeof(p_dialog));
	PaydayInfo[playerid][pProfit] = profit;

	// OSTALO
	PaydayInfo[playerid][pPayDayHad]++;
	PaydayInfo[playerid][pPayDay] 		= 0; 	// resetiranje payday minuta na 0

	PlayerInfo[playerid][pConnectTime]++; 		// sati igranja

	switch(PlayerVIP[playerid][pDonateRank])
	{
		case 0: 				
			PlayerJob[playerid][pFreeWorks] = NORMAL_FREE_WORKS;
		case PREMIUM_BRONZE: 	
			PlayerJob[playerid][pFreeWorks] = BRONZE_DONATOR_FREE_WORKS;
		case PREMIUM_SILVER: 	
			PlayerJob[playerid][pFreeWorks] = SILVER_DONATOR_FREE_WORKS;
		case PREMIUM_GOLD: 		
			PlayerJob[playerid][pFreeWorks] = GOLD_DONATOR_FREE_WORKS;
		case PREMIUM_PLATINUM: 	
			PlayerJob[playerid][pFreeWorks] = PLATINUM_DONATOR_FREE_WORKS;
	}

	PlayerFish[playerid][pFishWorks] 	= 0;

	// Dodavanje sati ugvora za posao
	if(PlayerJob[playerid][pJob] != 0)
		PlayerJob[playerid][pContractTime]++;


	// GYM izgled
	if( ++PlayerGym[playerid][pGymCounter] >= 6 ) {
		PlayerGym[playerid][pMuscle]--;
		if( PlayerGym[playerid][pMuscle] <= 0 ) PlayerGym[playerid][pMuscle] = 0;
		else
		{
			format(f_dialog,sizeof(f_dialog), "\n{3C95C2}(MUSCLE) Zbog nemara vas se Muscle Level spustio na %d!", PlayerGym[playerid][pMuscle]);
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			PlayerGym[playerid][pGymCounter] = 0;
		}
	}
	if( PlayerHealth[playerid][pHunger] == 5.0 ) 
	{
		PlayerGym[playerid][pGymCounter] += 2;
		if( PlayerGym[playerid][pGymCounter] >= 6 ) 
		{
			PlayerGym[playerid][pMuscle]--;
			format(f_dialog,sizeof(f_dialog), "\n{3C95C2}(MUSCLE) Zbog nemara i lose prehrane Muscle Level Vam se spustio na %d!\n", PlayerGym[playerid][pMuscle]);
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
			PlayerGym[playerid][pGymCounter] = 0;
		}
	}
	if(PlayerGym[playerid][pGymTimes] > 0) 
	{
		PlayerGym[playerid][pGymTimes]++;
		if(PlayerGym[playerid][pGymTimes] == 4)
		{
			PlayerGym[playerid][pGymTimes] = 0;
			format(f_dialog,sizeof(f_dialog), "\n{3C95C2}(GYM) Ponovno mozete u teretanu. Odradite trening ukoliko ne zelite izgubiti snagu!\n", PlayerGym[playerid][pMuscle]);
			strcat(p_dialog,f_dialog, sizeof(p_dialog));
		}
	}

	new expamount = (PlayerInfo[playerid][pLevel] + 1) * 4;
	if (PlayerInfo[playerid][pRespects] == expamount) {
		LevelUp(playerid);
		va_GameTextForPlayer(playerid,"~g~LEVEL UP!~n~%s -> %s",5000,1, PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pLevel]+1);
	}
	ResetBH_Script(playerid);
	
	// CoolDown Reset
	PlayerCoolDown[playerid][pCasinoCool] = 10;	
	PlayerCoolDown[playerid][pJackerCool] = 0;

	// Experience
	
	new currentday, day;
	TimeFormat(Timestamp:gettimestamp(), DAY_OF_MONTH, "%d", currentday);
	TimeFormat(Timestamp:ExpInfo[playerid][eLastPayDayStamp], DAY_OF_MONTH, "%d", day);
	ExpInfo[playerid][eLastPayDayStamp] = gettimestamp();
	ExpInfo[playerid][eMonthPayDays]++;
	if((ExpInfo[playerid][eMonthPayDays] % 2) == 0)
		PlayerInfo[playerid][pLastLoginTimestamp] = gettimestamp();

	if(currentday == day)
	{
		PlayerInfo[playerid][pLastLoginTimestamp] = gettimestamp();
		ExpInfo[playerid][eDayPayDays] ++;
	}
	else
	{
		ExpInfo[playerid][eGivenEXP] = false;
		ExpInfo[playerid][eDayPayDays] = 1;
	}
	if(PlayerInfo[playerid][pLevel] >= HappyHoursLVL && HappyHours && ExpInfo[playerid][eDayPayDays] >= MIN_GIVER_EXP_PAYDAYS && ExpInfo[playerid][eGivenEXP])
	{
		ExpInfo[playerid][eGivenEXP] = false;
		ExpInfo[playerid][eDayPayDays] = 1;
		format(f_dialog,sizeof(f_dialog), "\n[EXP]: Posto su aktivirani Happy Hoursi. fali vam jos 1 payday da nagradite EXP-om omiljenog igraca dana sa /exp give.");
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
	}
	if(ExpInfo[playerid][eDayPayDays] >= MIN_GIVER_EXP_PAYDAYS && !ExpInfo[playerid][eGivenEXP])
	{
		format(f_dialog,sizeof(f_dialog), "\n[EXP]: Posto Vam je %d. payday za redom, nagradite EXP-om omiljenog igraca dana sa /exp give.", ExpInfo[playerid][eDayPayDays]);
		strcat(p_dialog,f_dialog, sizeof(p_dialog));
		va_SendClientMessage(playerid, COLOR_ORANGE, "[EXP]: Posto Vam je %d. payday za redom, nagradite EXP-om omiljenog igraca dana sa /exp give.", ExpInfo[playerid][eDayPayDays]);
	}
	SavePlayerExperience(playerid);
	
	// Dialog - Payday
	new title[64];
	if(!IsPlayerInVehicle(playerid, GetPlayerVehicleID(playerid))) {
		format(title, sizeof(title), "* Placa");
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, title, p_dialog, "Close", "");
	}
	else if(IsPlayerInVehicle(playerid, GetPlayerVehicleID(playerid))) {
		SendMessage(playerid, MESSAGE_TYPE_INFO, "Stigao vam je PayDay (( /payday ))");
	}
	strcpy(PaydayInfo[playerid][pPayDayDialog], p_dialog, 1536);
	PaydayInfo[playerid][pPayDayMoney] = 0;
	return 1;
}