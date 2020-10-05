#include <YSI\y_hooks>

/*
	- Defines & Enums
*/

#define MAX_LINE_MESSAGE_LENGTH (90)

enum {
	MESSAGE_TYPE_NONE = 0,
	MESSAGE_TYPE_ERROR,
	MESSAGE_TYPE_INFO,
	MESSAGE_TYPE_SUCCESS
};

/*
	- Vars(32bit)
*/

new
	bool: _PopUpActivated[MAX_PLAYERS] = { false, ... },
	_PopUpTimer[MAX_PLAYERS],
	PlayerText:MessageTextdraw[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ... };

/*
	- Functions
*/

CreateMessage(playerid, bool: status) {
	if(status == false)
		PlayerTextDrawHide(playerid, MessageTextdraw[playerid]);
	else if(status == true) {
		MessageTextdraw[playerid] = CreatePlayerTextDraw(playerid, 328.000091, 350.947723, "");
		//PlayerTextDrawLetterSize(playerid, MessageTextdraw[playerid], 0.163333, 0.936296);
		PlayerTextDrawLetterSize(playerid, MessageTextdraw[playerid], 0.2, 1.0);
		PlayerTextDrawAlignment(playerid, MessageTextdraw[playerid], 2);
		PlayerTextDrawColor(playerid, MessageTextdraw[playerid], -1);
		PlayerTextDrawSetShadow(playerid, MessageTextdraw[playerid], 0);
		PlayerTextDrawSetOutline(playerid, MessageTextdraw[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, MessageTextdraw[playerid], 255);
		PlayerTextDrawFont(playerid, MessageTextdraw[playerid], 1);
		PlayerTextDrawSetProportional(playerid, MessageTextdraw[playerid], 1);
		PlayerTextDrawSetShadow(playerid, MessageTextdraw[playerid], 0);
		PlayerTextDrawShow(playerid, MessageTextdraw[playerid]);
	}
	return (true);
}

GetMessagePrefix(MESSAGE_TYPE = MESSAGE_TYPE_NONE) {
	new prefix[21];
	switch(MESSAGE_TYPE) {
		case MESSAGE_TYPE_ERROR: prefix = "~r~~h~[ ! ]";
		case MESSAGE_TYPE_INFO: prefix = "~y~[ ! ]";
		case MESSAGE_TYPE_SUCCESS: prefix = "~g~~h~[ ! ]";
		default: prefix = "~b~~h~~h~~h~[CoA.RP]";
	}
	return prefix;
}

DetermineMessageDuration(const message[])
{
    // Calculate the amount of time needed to read the notification '''
    new wpm = 180, // Readable words per minute
		word_length = 5, // Standardized number of chars in calculable word
		words = strlen(message)/word_length, // word_length
		words_time = ((words/wpm)*60)*1000,
		delay = 1500,  // Milliseconds before user starts reading the notification
		bonus = 2500;  // Extra time

    return delay + words_time + bonus;
}

SendTextDrawMessage(playerid, MESSAGE_TYPE, const message[])
{
    new len = strlen(message),
		format_message[192],
		final_msg[192];
	
	if(_PopUpActivated[playerid] == true)
		PlayerTextDrawHide(playerid, MessageTextdraw[playerid]);
	
	CreateMessage(playerid, true);	
    if(len >= MAX_LINE_MESSAGE_LENGTH)
    {
		new buffer[MAX_LINE_MESSAGE_LENGTH+10],	
			buffer2[128], spacepos = 0, bool:broken = false;
			
		for(new j = MAX_LINE_MESSAGE_LENGTH - 20; j < len; j++)
		{
			if(message[j] == ' ')
				spacepos = j;

			if(j >= MAX_LINE_MESSAGE_LENGTH && spacepos >= MAX_LINE_MESSAGE_LENGTH - 20)
			{
				broken = true;
				strmid(buffer, message, 0, spacepos);
				format(buffer, sizeof(buffer), "%s", buffer);
				strmid(buffer2, message, spacepos+1, len);
				format(buffer2, sizeof(buffer2), "%s", buffer2);
				break;
			}
		}
		if(!broken)
			goto no_split;
			
		format(final_msg, sizeof(final_msg), "%s: ~w~%s~n~%s~n~", GetMessagePrefix(MESSAGE_TYPE), buffer, buffer2);
	}
    else
	{
		no_split:
		format(format_message, sizeof(format_message), "%s\n", message);
		format(final_msg, sizeof(final_msg), "%s: ~w~%s", GetMessagePrefix(MESSAGE_TYPE), message);
	}
	KillTimer(_PopUpTimer[playerid]);
	new messagetime = DetermineMessageDuration(message);
	_PopUpTimer[playerid] = SetTimerEx("RemoveMessage", messagetime, (false), "i", playerid);
	return PlayerTextDrawSetString(playerid, MessageTextdraw[playerid], final_msg);
}

SendFormatMessage(playerid, MESSAGE_TYPE = MESSAGE_TYPE_NONE, const message[],  va_args<>) {	
	new format_message[192];
	
	if(MESSAGE_TYPE == MESSAGE_TYPE_NONE)
		return (true);
	
	_PopUpActivated[playerid] = true;
	
	va_format(format_message, sizeof (format_message), message, va_start<3>);
	return SendTextDrawMessage(playerid, MESSAGE_TYPE, format_message);
}

SendMessage(playerid, MESSAGE_TYPE = MESSAGE_TYPE_NONE, message[])  {	
	if(MESSAGE_TYPE == MESSAGE_TYPE_NONE)
		return (true);
	
	_PopUpActivated[playerid] = true;
	
	return SendTextDrawMessage(playerid, MESSAGE_TYPE, message);
}

Function: RemoveMessage(playerid) {
	if(_PopUpActivated[playerid] == true)
		PlayerTextDrawHide(playerid, MessageTextdraw[playerid]);
		
	_PopUpActivated[playerid] = false;
	CreateMessage(playerid, false);
	KillTimer(_PopUpTimer[playerid]);
	return (true);
}

/*
	- Hooks
*/
hook OnPlayerDisconnect(playerid, reason) {
	_PopUpActivated[playerid] = (false);
	CreateMessage(playerid, (false));
	KillTimer(_PopUpTimer[playerid]);
	return (true);
}