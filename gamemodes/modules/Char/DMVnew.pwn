#include <YSI\y_hooks>


enum E_DMV_QUESTION
{
	dmvQuestion[56],
	dmvAnswers[153],
	dmvCAnswer
}

static stock 
	DMVQuestions[][E_DMV_QUESTION] = 
{
	{"Glavni uzrok prometnih nesreca u Los Santosu je...", 		"A) Prestrojavanje.\nB) Nedovoljan razmak vozila.\nC) Prebrza voznja.\nD) Voznja pod utjecajem.", 															2},
	{"Kad vidis ili cujes sirene policijskog vozila trebas...", "A) Usporiti dok te ne prestigne.\nB) Upalit mu zmigavac kako bi te presao.\nC) Nastavit vozit istom brzinom\nD) Stati sa desne strane ceste.", 			3},
	{"Pjesaci koji idu prijeci pjesacki imaju...", 				"A) Prednost prije vozila.\nB) Nemaju prednost prije vozila.", 																								0},
	{"Distanca zaustavljanja vozila na mokroj cesti je..", 		"A) Jednaka kao na suhoj.\nB) Malo manja nego na suhoj.\nC) 2 do 10 puta visa nego na suhoj.\nD) Ni jedan tocan odgovor.", 									2},
	{"Crveno svijetlo na semaforu...", 							"A) Vas upozorava da ocistite intersekciju.\nB) Ima isto znacenje kao znak stop.\nC) Znaci da trebate usporiti i nastaviti.\nD) Znaci da semafor ne radi.", 1}
};

new
	PlayerAnswers[MAX_PLAYERS],
	PlayerQuestion[MAX_PLAYERS] = { -1, ... };


CMD:license(playerid, params[]) 
{
	if(!IsPlayerInRangeOfPoint( playerid, 3.0, -2033.0352,-117.5965,1035.1719)) 
		return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u auto skoli.");
		
	Dialog_Open(playerid, eDIALOG_LICENSE, DIALOG_STYLE_LIST, "DMV", "Vozacka dozvola\nDozvola za oruzje\nDozvola za letenje\nDozvola za brodove\nDozvola za ribolov", "Odaberi", "Izlaz");
	return 1;
}

Dialog:eDIALOG_LICENSE(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				if(PlayerInfo[playerid][pCarLic] == 1)
					return SendClientMessage(playerid, COLOR_RED, "ERROR: Vec imas vozacku dozvolu!");
				
				Dialog_Open(playerid, eDIALOG_LICENSE_CONFIRM, DIALOG_STYLE_MSGBOX, "Vozacka Dozvola", "Jeste li sigurni da zelite zapoceti test?\nTest ce vas kostati 1000$, 100$ po pokusaju.", "Da", "Natrag");
				PlayerAnswers[playerid] = 0;
			}
			case 1:
				SendClientMessage(playerid, COLOR_RED, "ERROR: Trenutno nije dozvoljena kupovina license za oruzje. ((Zahtjev za licensu postavite na forumu!))");
			case 2:
			{
				if(PlayerInfo[playerid][pFlyLic] == 1)
					return SendClientMessage(playerid, COLOR_RED, "ERROR: Vec imas dozvolu za letenje!");
				
				Dialog_Open(playerid, eDIALOG_LICENSE_CONFIRM, DIALOG_STYLE_MSGBOX, "Dozvola za letenje", "Jeste li sigurni da zelite kupiti dozvolu za letenje?\nDozvola kosta 3000$.", "Da", "Natrag");
				PlayerAnswers[playerid] = -1;
			}
			case 3:
			{
				if(PlayerInfo[playerid][pBoatLic] == 1)
					return SendClientMessage(playerid, COLOR_RED, "ERROR: Vec imas dozvolu za brod!");
				
				Dialog_Open(playerid, eDIALOG_LICENSE_CONFIRM, DIALOG_STYLE_MSGBOX, "Dozvola za brod", "Jeste li sigurni da zelite kupiti dozvolu za brod?\nDozvola kosta 3000$.", "Da", "Natrag");
				PlayerAnswers[playerid] = -2;
			}
			case 4:
			{
				if(PlayerInfo[playerid][pFishLic] == 1)
					return SendClientMessage(playerid, COLOR_RED, "ERROR: Vec imas dozvolu za ribolov!");
				
				Dialog_Open(playerid, eDIALOG_LICENSE_CONFIRM, DIALOG_STYLE_MSGBOX, "Dozvola za ribolov", "Jeste li sigurni da zelite kupiti dozvolu za ribolov?\nDozvola kosta 800$.", "Da", "Natrag");
				PlayerAnswers[playerid] = -3;
			}
		}
	}
	return 1;
}

Dialog:eDIALOG_LICENSE_CONFIRM(playerid, response, listitem, inputtext[]) 
{
	if(!response)
		return Dialog_Open(playerid, eDIALOG_LICENSE, DIALOG_STYLE_LIST, "DMV", "Vozacka dozvola\nDozvola za oruzje\nDozvola za letenje\nDozvola za brodove", "Odaberi", "Izlaz"), PlayerAnswers[playerid] = 0;
	
	switch(PlayerAnswers[playerid])
	{
		case 0:
		{
			if(GetPlayerMoney(playerid) < 1000) 
				return SendClientMessage(playerid, COLOR_RED, "ERROR: Nemas dovoljno novca (1000$).");
			
			if(response)
			{
				PlayerToBudgetMoney(playerid, 100);
				
				Dialog_Open(playerid, eDIALOG_DRIVINGTEST, DIALOG_STYLE_LIST, DMVQuestions[0][dmvQuestion], DMVQuestions[0][dmvAnswers], "Dalje", "Izlaz");
				PlayerQuestion[playerid] = 0;
			}
		}
		case -1:
		{
			if(GetPlayerMoney(playerid) < 3000) 
				return SendClientMessage(playerid, COLOR_RED, "ERROR: Nemas dovoljno novca (3000$).");
			
			Dialog_Open(playerid, empty, DIALOG_STYLE_MSGBOX, "Dozvola za letenje", "Kupio si dozvolu za letenje!\nZelimo vam siguran i ugodan let.", "Izlaz", "");
			PlayerInfo[playerid][pFlyLic] = 1;
			
			PlayerToBudgetMoney(playerid, 3000);
		}
		case -2:
		{
			if(GetPlayerMoney(playerid) < 3000) 
				return SendClientMessage(playerid, COLOR_RED, "ERROR: Nemas dovoljno novca (3000$).");
			
			Dialog_Open(playerid, empty, DIALOG_STYLE_MSGBOX, "Dozvola za brod", "Kupio si dozvolu za brod!\nZelimo vam sigurnu i ugodnu voznju.", "Izlaz", "");
			PlayerInfo[playerid][pBoatLic] = 1;
			
			PlayerToBudgetMoney(playerid, 3000);
		}
		case -3:
		{
			if(GetPlayerMoney(playerid) < 800) 
				return SendClientMessage(playerid, COLOR_RED, "ERROR: Nemas dovoljno novca (800$).");
			
			Dialog_Open(playerid, empty, DIALOG_STYLE_MSGBOX, "Dozvola za letenje", "Kupio si dozvolu za ribolov!.", "Izlaz", "");
			PlayerInfo[playerid][pFishLic] = 1;
			
			PlayerToBudgetMoney(playerid, 800);
		}
	}
	return 1;
}

Dialog:eDIALOG_DRIVINGTEST(playerid, response, listitem, inputtext[]) 
{
	if(response)
	{
		new
			curquestion = PlayerQuestion[playerid] + 1;

		if(listitem == DMVQuestions[curquestion - 1][dmvCAnswer])
			PlayerAnswers[playerid] ++;

		if((++PlayerQuestion[playerid]) == 5)
		{
			if(PlayerAnswers[playerid] != 5)
			{
				Dialog_Open(playerid, eDIALOG_LICENSE_CONFIRM, DIALOG_STYLE_MSGBOX, "Vozacka dozvola", "Nazalost pali ste ispit iz voznje.\nImali ste %d od 5 tocnih odgovora\nZelite li pokusati ponovo?", "Da", "Natrag", PlayerAnswers[playerid]);
				
				PlayerQuestion[playerid] = -1;
				PlayerAnswers[playerid] = 0;
			}
			else
			{
				Dialog_Open(playerid, empty, DIALOG_STYLE_MSGBOX, "Vozacka dozvola", "Cestitamo, prosli ste ispit za vozacku dozvolu!\nZelimo vam sigurnu i ugodnu voznju.", "Izlaz", "");
				
				PlayerInfo[playerid][pCarLic] = 1;
				
				PlayerQuestion[playerid] = -1;
				PlayerAnswers[playerid] = 0;
				
				PlayerToBudgetMoney(playerid, 900);
			}
		}
		else
			Dialog_Open(playerid, eDIALOG_DRIVINGTEST, DIALOG_STYLE_LIST, DMVQuestions[curquestion][dmvQuestion], DMVQuestions[curquestion][dmvAnswers], "Dalje", "Izlaz");
	}	
	else
	{
		va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Prekinuli ste test! Imali ste %d tocnih odgovora te %d neodgovorenih.", PlayerAnswers[playerid], (5 - PlayerQuestion[playerid]));
		Dialog_Open(playerid, eDIALOG_LICENSE, DIALOG_STYLE_LIST, "DMV", "Vozacka dozvola\nDozvola za oruzje\nDozvola za letenje\nDozvola za brodove", "Odaberi", "Izlaz");
		
		PlayerQuestion[playerid] = -1;
		PlayerAnswers[playerid] = 0;
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	PlayerQuestion[playerid] = -1;
	PlayerAnswers[playerid] = 0;
	return 1;
}