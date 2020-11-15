#include <YSI_Coding\y_hooks>

// Header - Functions forward
#include "modules/Systems/LSPD\Tickets/Header.pwn"

/*
	########  ######## ######## #### ##    ## ########  ######
	##     ## ##       ##        ##  ###   ## ##       ##    ##
	##     ## ##       ##        ##  ####  ## ##       ##
	##     ## ######   ######    ##  ## ## ## ######    ######
	##     ## ##       ##        ##  ##  #### ##             ##
	##     ## ##       ##        ##  ##   ### ##       ##    ##
	########  ######## ##       #### ##    ## ########  ######
*/
///////////////////////////////////////////////////////////////////

// How much seconds can test car be driven
#define CAR_TEST_SEC			(300) 		// 5 min = 300 sec!
#define CAR_GIVEBACK_MIL 		(300000) 	// 5 min = 300.000 ms

//Oduzimanja
#define ENGINE_DEDUCATION		(1)

//Vijek trajanja
#define ENGINE_LIFE_STOCK		(130000)

//Car tow
#define VEHICLE_TOW_TIME 			(480) // 8 minuta za normalnog igraca
#define BRONZE_VEHICLE_TOW_TIME		(360) // 6 minuta za Donator Bronze
#define SILVER_VEHICLE_TOW_TIME		(240) // 4 minute za Donator Silver
#define GOLD_VEHICLE_TOW_TIME		(120) // 2 minute za Donator Gold
#define PLATINUM_VEHICLE_TOW_TIME	(60)  // 1 minuta za Donator Platinuma

/*
	######## ##    ## ##     ## ##     ##  ######
	##       ###   ## ##     ## ###   ### ##    ##
	##       ####  ## ##     ## #### #### ##
	######   ## ## ## ##     ## ## ### ##  ######
	##       ##  #### ##     ## ##     ##       ##
	##       ##   ### ##     ## ##     ## ##    ##
	######## ##    ##  #######  ##     ##  ######
*/
///////////////////////////////////////////////////////////////////

new GlobalVehicleStamp 	= 0,	// VehicleGlobalTimer
	VehicleTimer		= 0;

enum {
	HOT_BATTERY		= 10,
	HOT_ENGINE,
	HOT_ALARM,
	HOT_WINDOWS,
	HOT_LIGHTS
}

enum {
	VEH_DEALER_CARS 	= 0,
	VEH_DEALER_BOAT,
	VEH_DEALER_PLANE
}

enum {
	ENGINE_TYPE_NONE		= 0,
	ENGINE_TYPE_DIESEL,
	ENGINE_TYPE_PETROL
}

enum {
	BATTERY_TYPE_STOCK			= 0,
	BATTERY_TYPE_CYCLONE,
	BATTERY_TYPE_VARTIO,
	BATTERY_TYPE_BOCHE
}

enum {
	BATTERY_LIFE_STOCK			= 20000.0,
	BATTERY_LIFE_CYCLONE		= 30000.0,
	BATTERY_LIFE_VARTIO			= 50000.0,
	BATTERY_LIFE_BOCHE          = 80000.0
}

enum E_VEHICLE_DEALERSHIP
{
	szText[35],
	Float:flPosX,
	Float:flPosY,
	Float:flPosZ
};
stock
	DealerInfo[3][E_VEHICLE_DEALERSHIP] = {
		{"Wang Cars\nCar dealership", 			543.3019, -1292.3534, 16.9408},
		{"Spotties Boats\nBoat dealership", 	87.9080, 	-1812.1689, 0.2989},
		{"Berkley's Planes\nPlane dealership", 	2112.7898, 	-2413.7971, 12.5295}
};

enum E_LAND_VEHICLES 
{
	viModelid,
	viName[18],
	viPrice,
	viCarJackerPrice,
	viSeats,
	Float:viFuel,
	viEngineType,
	viPremium,
	viSlots
};

static
   LandVehicles[123][E_LAND_VEHICLES] = {
	{ 400, "Landstalker",      72500, 7050,   4,   65.0,    ENGINE_TYPE_PETROL, 0, 4 },
	{ 401, "Bravura",          33437,    3698,   2,   40.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 402, "Buffalo",          129625, 8241,   2,   70.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 404, "Perrenial",         6000,    2222,    4,   40.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 405, "Sentinel",         64500,    6759,   4,   55.0,    ENGINE_TYPE_DIESEL, 0, 4 },
	{ 408, "Trashmaster",      4875,    0,      2,   85.0,    ENGINE_TYPE_PETROL, 0, 0  },
	{ 409, "Stretch",          300752, 8969,   4,   50.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 410, "Manana",         10250,    2329,    2,   45.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 411, "Infernus",         0,      9955,   2,    70.0,    ENGINE_TYPE_PETROL, 3, 1  },//{ 411, "Infernus",          0,      9955,   2,    70.0,    ENGINE_TYPE_PETROL, 3, 1  },
	{ 412, "Voodoo",          12500,    2420,   2,   55.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 413, "Pony",             18500,    2826,   2,   55.0,    ENGINE_TYPE_PETROL, 0, 7  },
	{ 414, "Mule",             15300,    2818,   2,   60.0,    ENGINE_TYPE_PETROL, 0,  8 },
	{ 415, "Cheetah",          0,     9824,   2,   60.0,    ENGINE_TYPE_PETROL, 3, 1  },
	{ 418, "Moonbeam",          14000,    2500,   4,   55.0,    ENGINE_TYPE_DIESEL, 0, 6  },
	{ 419, "Esperanto",         16750,    2690,   2,   58.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 420, "Taxi",             14750,    2805,   4,   47.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 421, "Washington",      40250,    4283,    4,    58.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 422, "Bobcat",          12500,    2404,   2,   65.0,    ENGINE_TYPE_PETROL, 0, 6  },
	{ 423, "Mr Whoopee",       13500,    2398,   2,    65.0,    ENGINE_TYPE_DIESEL, 0, 3 },
	{ 424, "BF Injection",       84062, 7589,    2,   20.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 426, "Premier",          89200, 7779,   4,   50.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 429, "Banshee",          281500, 8690,   2,   60.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 434, "Hotknife",          20250, 2904,   2,   56.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 436, "Previon",          14000,    2474,   2,   50.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 438, "Cabbie",          13500,    2391,   4,   47.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 439, "Stallion",          45587,    5405,   2,   49.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 440, "Rumpo",          13500,    2381,   2,   55.0,    ENGINE_TYPE_PETROL, 0, 7  },
	{ 442, "Romero",          17750,    2792,   4,   40.0,    ENGINE_TYPE_DIESEL, 0, 5  },
	{ 445, "Admiral",          28250,    2960,   4,   55.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 448, "Pizzaboy",         7000,    0,       1,   5.0,     ENGINE_TYPE_DIESEL, 0, 1  },
	{ 451, "Turismo",          0,       9728,    2,   60.0,    ENGINE_TYPE_PETROL, 2, 1  },
	{ 456, "Yankee",          25750,    2933,    2,   68.0,    ENGINE_TYPE_PETROL, 0, 9  },
	{ 458, "Solair",          27800,    2960,   4,   40.0,    ENGINE_TYPE_DIESEL, 0, 6 },
	{ 459, "Berkley's Van",      15000,    0,       2,   55.0,    ENGINE_TYPE_PETROL, 0, 7   },
	{ 461, "PCJ-600",          61693,    0,      2,   7.0,     ENGINE_TYPE_PETROL, 0, 1  },
	{ 462, "Faggio",          8500,    0,       1,   5.0,     ENGINE_TYPE_DIESEL, 0, 1  },
	{ 463, "Freeway",          7500,    0,      2,   7.0,     ENGINE_TYPE_PETROL, 0, 1   },
	{ 466, "Glendale",          14250,    2455,    4,   47.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 467, "Oceanic",          17250,    2687,   4,   48.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 468, "Sanchez",          11250,    0,      2,   5.0,     ENGINE_TYPE_PETROL, 0, 1  },
	{ 470, "Patriot",          0,       9668,   4,   80.0,    ENGINE_TYPE_PETROL, 1, 6  },
	{ 471, "Quad",             16250,    0,       1,   6.0,     ENGINE_TYPE_PETROL, 0, 1   },
	{ 474, "Hermes",          17250,    2658,    2,   50.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 475, "Sabre",          41500,    4642,   2,   80.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 477, "ZR-350",          0,       9634,   2,   105.0,    ENGINE_TYPE_PETROL, 1, 2  },
	{ 478, "Walton",          13500,    2362,    2,   40.0,    ENGINE_TYPE_DIESEL, 0, 6   },
	{ 479, "Regina",          7500,    2259,    4,   43.0,    ENGINE_TYPE_DIESEL, 0, 5  },
	{ 480, "Comet",          180250, 8247,   2,   96.0,    ENGINE_TYPE_PETROL, 0, 1   },
	{ 481, "BMX",             500,    2017,     1,   0.0 ,    ENGINE_TYPE_NONE  , 0, 1   },
	{ 482, "Burrito",          26750,    2936,    2,   73.0,    ENGINE_TYPE_PETROL, 0, 7   },
	{ 483, "Camper",          25800,    2936,   2,   51.0,    ENGINE_TYPE_PETROL, 0, 8  },
	{ 489, "Rancher",          38500,    3958,   2,   62.0,    ENGINE_TYPE_PETROL, 0, 4  },
	{ 491, "Virgo",          24100,    2930,    2,   30.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 492, "Greenwood",         14800,    2617,   4,   42.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 496, "Blista Compact",   17750,    2774,    2,   40.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 498, "Boxville",          16500,    0,   2,      46.0,    ENGINE_TYPE_PETROL, 0, 8  },
	{ 499, "Benson",          30000,    0,     2,   40.0,    ENGINE_TYPE_PETROL, 0, 8  },
	{ 500, "Mesa",             35750,    3906,   2,   54.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 505, "Rancher",          36500,    0,     2,   69.0,    ENGINE_TYPE_PETROL, 0,  4 },
	{ 506, "Super GT",          405187, 9078,   2,   81.0,    ENGINE_TYPE_PETROL, 0, 1 },
	{ 507, "Elegant",          44750,    5252,   4,   78.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 508, "Journey",          33500,    3332,   2,   60.0,    ENGINE_TYPE_PETROL, 0,  9 },
	{ 509, "Bike",             500,    2000,     1,   0.0,    ENGINE_TYPE_NONE  , 0, 1  },
	{ 510, "Mountain Bike",      750,    2069,     1,   0.0,    ENGINE_TYPE_NONE  , 0, 1  },
	{ 516, "Nebula",          17037,    2691,   4,   72.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 517, "Majestic",          20500,    2921,   2,   44.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 518, "Buccaneer",         16500,    2591,   2,   30.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 521, "FCR-900",          280750,   0,      2,   10.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 522, "NRG-500",          0, 0,      2,   11.0,    ENGINE_TYPE_PETROL, 4, 1   },
	{ 524, "Cement Truck",      9750,    0,        2,   66.0,    ENGINE_TYPE_PETROL, 0, 5 },
	{ 525, "Tow Truck",         6000,   2198,   2,   50.0,    ENGINE_TYPE_PETROL, 0, 5 },
	{ 526, "Fortune",          19500,   2905,    2,   63.0,    ENGINE_TYPE_DIESEL, 0, 2 },
	{ 527, "Cadrona",          15600,   2504,   2,   56.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 529, "Willard",          20250,   2893,    4,   60.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 530, "Forklift",         4500,    0,      1,   25.0,    ENGINE_TYPE_DIESEL, 0, 1  },
	{ 531, "Tractor",          4500,    0,      1,   26.0,    ENGINE_TYPE_DIESEL, 0, 1  },
	{ 532, "Combine",          9750,    0,      1,   40.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 533, "Feltzer",          40250,    4168,   2,    55.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 534, "Remington",         13160,    2369,    2,    64.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 535, "Slamvan",          50700,    5426,   2,    58.0,    ENGINE_TYPE_PETROL, 0, 3  },
	{ 536, "Blade",          13500,    2376,    4,    45.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 540, "Vincent",          21400,    2910,    4,    40.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 541, "Bullet",          0,      9459,   2,   67.0,    ENGINE_TYPE_PETROL, 2, 1  },
	{ 542, "Clover",          16000,    2653,    2,    40.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 543, "Sadler",          12750,    2340,    2,    45.0,    ENGINE_TYPE_PETROL, 0 , 5   },
	{ 545, "Hustler",          59250,    6151,   2,    43.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 546, "Intruder",          13000,    2433,    4,   40.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 547, "Primo",          21000,    2928,    4,    40.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 549, "Tampa",          7500,    2257,    2,    37.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 550, "Sunrise",          25325,    2934,    4,    46.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 551, "Merit",          26785,    2939,   4,    42.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 552, "Utility",          24750,    2930,    2,    74.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 554, "Yosemite",          35000,    3787,    2,    70.0,    ENGINE_TYPE_PETROL, 0, 5  },
	{ 555, "Windsor",          126500, 8229,   2,   55.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 558, "Uranus",          188750, 8608,   2,   58.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 559, "Jester",          289875, 8894,   2,   55.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 560, "Sultan",          402820, 9031,   4,   60.0,    ENGINE_TYPE_PETROL, 0, 4  },
	{ 561, "Stratum",          40750,    4619,   4,   58.0,    ENGINE_TYPE_PETROL, 0, 4   },
	{ 562, "Elegy",          212700, 8616,   2,   64.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 565, "Flash",          110375, 8041,   2,   55.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 566, "Tahoma",          14750,    2524,    4,   42.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 567, "Savanna",          14500,    2501,    4,    43.0,    ENGINE_TYPE_DIESEL, 0, 4   },
	{ 568, "Bandito",          80750, 7312,   1,    30.0,    ENGINE_TYPE_PETROL, 0, 1   },
	{ 572, "Mower",          4500,    2094,    1,    10.0,    ENGINE_TYPE_DIESEL, 0, 1   },
	{ 574, "Sweeper",          3750,    2085,    1,    20.0,    ENGINE_TYPE_DIESEL, 0, 1   },
	{ 575, "Broadway",          19000,    2851,    2,    43.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 576, "Tornado",          7500,    2236,    2,    43.0,    ENGINE_TYPE_DIESEL, 0, 2  },
	{ 578, "DFT-30",          44000,    0,      2,    101.0,    ENGINE_TYPE_PETROL, 0, 6 },
	{ 579, "Huntley",          51500,    5655,   4,    75.0,    ENGINE_TYPE_PETROL, 0, 5  },
	{ 580, "Stafford",          32500,    3175,   4,    50.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 581, "BF-400",          53500,    0,       2,    6.0,     ENGINE_TYPE_PETROL, 0, 1  },
	{ 585, "Emperor",          20250,    2869,    4,    45.0,    ENGINE_TYPE_DIESEL, 0, 4  },
	{ 586, "Wayfarer",          11200,  0,       2,   7.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 587, "Euros",          60500,    5972,   2,    60.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 588, "Hotdog",          9500,    0,      2,    45.0,    ENGINE_TYPE_DIESEL, 0, 5  },
	{ 589, "Club",             20900,    2921,   2,    44.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 600, "Picador",          6000,    2165,    2,    20.0,    ENGINE_TYPE_DIESEL, 0, 2 },
	{ 602, "Alpha",          91875, 7786,   2,   55.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 603, "Phoenix",         89500, 7669,   2,   60.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 609, "Boxville",          17750,    0,      2,  70.0,    ENGINE_TYPE_PETROL, 0, 8  },
	{ 403, "Linerunner",       75000, 6812,   2,  100.0,    ENGINE_TYPE_PETROL, 0, 1  },
	{ 514, "Tanker",          60000,    6105,   2,  100.0,    ENGINE_TYPE_PETROL, 0, 2  },
	{ 515, "Roadtrain",       61750,    6392,   2,  100.0,    ENGINE_TYPE_PETROL, 0, 1   }
};

enum E_SEA_VEHICLES {
	viModelid,
	viName[18],
	viPrice,
	viCarJackerPrice,
	viSeats,
	Float:viFuel,
	viEngineType
};
static SeaVehicles[9][E_SEA_VEHICLES] = {
	{472, "Coastguard", 67500,    0, 1, 110.0,   ENGINE_TYPE_NONE   },
	{473, "Dinghy",    11250,    0, 1, 88.0,      ENGINE_TYPE_NONE   },
	{493, "Jetmax",    156000, 0, 1, 88.0,      ENGINE_TYPE_NONE   },
	{595, "Launch",      262500, 0, 1, 150.0,   ENGINE_TYPE_NONE   },
	{484, "Marquis",   367500, 0, 1, 99.0,      ENGINE_TYPE_NONE    },
	{453, "Reefer",      108750, 0, 1, 75.0,      ENGINE_TYPE_NONE    },
	{452, "Speeder",    227812, 0, 1, 35.0,      ENGINE_TYPE_NONE    },
	{446, "Squallo",   192375, 0, 1, 48.0,      ENGINE_TYPE_NONE    },
	{454, "Tropic",      240000, 0, 1, 50.0,      ENGINE_TYPE_NONE    }
};

enum E_AIR_VEHICLES {
	viModelid,
	viName[11],
	viPrice,
	viCarJackerPrice,
	viSeats,
	Float:viFuel,
	viEngineType
};
static AirVehicles[13][E_SEA_VEHICLES] = {
	{417, "Leviathan",    412500,    0, 2, 180.0,   ENGINE_TYPE_NONE   },
	{460, "Skimmer",    337500,    0, 1, 150.0,   ENGINE_TYPE_NONE   },
	{469, "Sparrow",    405000,    0, 2, 35.0,      ENGINE_TYPE_NONE   },
	{487, "Maverick",   285000,    0, 4, 95.0,      ENGINE_TYPE_NONE   },
	{511, "Beagle",      352500,    0, 2, 120.0,   ENGINE_TYPE_NONE   },
	{512, "Cropduster",   285000,    0, 1, 80.0,      ENGINE_TYPE_NONE   },
	{513, "Stuntplane",  247500,    0, 1, 75.0,      ENGINE_TYPE_NONE   },
	{519, "Shamal",      1125000,    0, 1, 180.0,   ENGINE_TYPE_NONE   },
	{548, "Cargobob",   247500,    0, 1, 100.0,   ENGINE_TYPE_NONE   },
	{553, "Nevada",      487500,    0, 1, 1000.0,   ENGINE_TYPE_NONE   },
	{563, "Raindance",   180000,    0, 2, 200.0,   ENGINE_TYPE_NONE   },
	{577, "AT-400",      900000,    0, 2, 1500.0,   ENGINE_TYPE_NONE   },
	{593, "Dodo",      217500,    0, 2, 100.0,   ENGINE_TYPE_NONE   }
};



/*
	##     ##    ###    ########   ######
	##     ##   ## ##   ##     ## ##    ##
	##     ##  ##   ##  ##     ## ##
	##     ## ##     ## ########   ######
	 ##   ##  ######### ##   ##         ##
	  ## ##   ##     ## ##    ##  ##    ##
	   ###    ##     ## ##     ##  ######
*/
///////////////////////////////////////////////////////////////////
//Pozicija automobila prilikom kupovine
static stock
	Float:PreviewPos[][5] = {
		{-1949.2162, 263.9120, 42.1694, 186.6725}, 		// Automobili
		{97.3713, 	-1804.4332, 	0.2928, 	0.00000}, 		// Brodovi
		{2108.9519, -2442.6082, 	15.5000, 	61.6200} 		// Avioni

};

//Pozicija kamera
static stock
	Float:CarCamera[][3] = {
		{-1943.2965, 254.7310, 43.4619},
		{-1954.3184, 254.7566, 43.5870},
		{-1958.1102, 269.5474, 43.5870}
};

static stock
	Float:BoatCamera[3][3] = {
		{98.0562, 	-1773.3486, 13.2786},
		{80.5686, 	-1812.5903, 12.0000},
		{109.0792, 	-1816.3854, 12.0000}
};

static stock
	Float:AeroCamera[][3] = {
		{2090.2615, -2436.5383, 22.7000},
		{2116.8860, -2429.4585, 21.3000},
		{2111.9265, -2458.9102, 22.0000}
};

//Pozicije za testiranje vozila
static stock
	Float:TestPositions[][5] = {
		{563.5918, -1289.4908, 17.5516,	2.8243}, 		// Automobili
		{13.4737, 	-1899.6497, -0.0158, 93.5000}, 		// Brodovi
		{2024.8286, -2493.9761, 15.5000, 90.5000} 		// Avioni
};

static stock
	Float:GiveBackPos[][3] = {
		{563.5918, -1289.4908, 17.5516}, 		// Automobili
		{13.4737, 	-1899.6497, -0.0158}, 		// Brodovi
		{2024.8286, -2493.9761, 15.5000} 		// Avioni
};

//Pozicije za spawn vozila nakon kupnje
static stock
	Float:VehicleBuyPos[][5] = {
		{563.5918, -1289.4908, 17.5516,	2.8243},	// Automobili
		{42.7703, 	-1940.5421, -0.0158,	0.0000},	// Brodovi
		{1963.5498, -2445.6072, 15.5000,	90.5000}	// Avioni
};

//TextDraws
static stock
	PlayerText:MainBackground[MAX_PLAYERS]	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:InfoText[MAX_PLAYERS]     	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:InfoTextBcg[MAX_PLAYERS] 	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:DenyButton[MAX_PLAYERS]  	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:FirstBcg[MAX_PLAYERS]    	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CarLeft[MAX_PLAYERS]    		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CarRight[MAX_PLAYERS]    	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CarText[MAX_PLAYERS]    		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color1Bcg[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color1Left[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color1Right[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color1Text[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color2Bcg[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color2Left[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color2Info[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:Color2Right[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:MainInfoBcg[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:ModelText[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CarInfoText[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:BuyButton[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:TryButton[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:ModelTextBcg[MAX_PLAYERS]	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CameraLeft[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CameraBcg[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CameraRight[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:CameraText[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:MainHotWireBcg[MAX_PLAYERS]	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:SecHotWireBcg[MAX_PLAYERS]	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireText[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireRed[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireBlue[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireYell[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireBrown[MAX_PLAYERS]	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireBlack[MAX_PLAYERS]	= { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:HotWireInfo[MAX_PLAYERS]		= { PlayerText:INVALID_TEXT_DRAW, ...};

// Player vars
new
	VehicleInfoSQLID[MAX_PLAYERS][MAX_PLAYER_CARS],
	VehicleInfoModel[MAX_PLAYERS][MAX_PLAYER_CARS],
	Float:VehicleInfoParkX[MAX_PLAYERS][MAX_PLAYER_CARS],
	Float:VehicleInfoParkY[MAX_PLAYERS][MAX_PLAYER_CARS],
	Float:VehicleInfoParkZ[MAX_PLAYERS][MAX_PLAYER_CARS];

new
	TestCar				[MAX_PLAYERS],
	PlayerDealer		[MAX_PLAYERS],
	PreviewColor1		[MAX_PLAYERS],
	PreviewColor2		[MAX_PLAYERS],
	PreviewType			[MAX_PLAYERS],
	CameraPos			[MAX_PLAYERS],
	PlayerParkLocation	[MAX_PLAYERS],
	PlayerGiveBackCP	[MAX_PLAYERS];	// Global CP

static stock
		PreviewModel		[MAX_PLAYERS],
		PreviewCar			[MAX_PLAYERS],
		PlayerTowTimer		[MAX_PLAYERS],
		CopStreamVeh		[MAX_PLAYERS],
		PlayerInputHotWire	[MAX_PLAYERS][3],
		PlayerHotWire		[MAX_PLAYERS][5],
		Timer:HotWiringTimer[MAX_PLAYERS],
		HotWiringSeconds	[MAX_PLAYERS],
		PlayerHotWiringVeh	[MAX_PLAYERS],
		PlayerHotWireType	[MAX_PLAYERS],
		PlayerSellingPrice	[MAX_PLAYERS],
		PlayerCarSeller		[MAX_PLAYERS],
		PlayerModel			[MAX_PLAYERS],
		PlayerEngine		[MAX_PLAYERS];

// Vehicle vars
new
	Float:vOldPos			[MAX_VEHICLES][3];

//rBits
static stock
	Bit1:	gr_CarSlide				<MAX_PLAYERS>,
	Bit1: 	gr_VehicleLights		<MAX_VEHICLES> = Bit1: false,
	Bit1:	gr_PlayerLocateVeh		<MAX_PLAYERS>,
	Bit1:	gr_ColorDialogActive	<MAX_PLAYERS>,
	Bit2:	gr_HotWireClicks		<MAX_PLAYERS>,
	Bit1:	gr_PlayerBreaking		<MAX_PLAYERS>,
	Bit1: 	gr_PlayerBreakingTrunk	<MAX_PLAYERS>,
	Bit8:	gr_BreakLockTDSecs		<MAX_PLAYERS>,
	Bit8:	gr_UsingDealer			<3>,
	Bit16: 	gr_PlayerTestSeconds	<MAX_PLAYERS>;

// Global global vars
new
	Bit1:	gr_PlayerTestingCar		<MAX_PLAYERS>,
	Bit1:	gr_PreviewCar			<MAX_PLAYERS>,
	Bit1:	gr_PlayerHotWiring		<MAX_PLAYERS>,
	Bit2:	gr_PlayerLockBreaking	<MAX_PLAYERS>,

	BreakLockKickTick	[MAX_PLAYERS],
	BreakTrunkKickTick	[MAX_PLAYERS],
	BreakLockVehicleID	[MAX_PLAYERS],
	BreakTrunkVehicleID	[MAX_PLAYERS];

new const VehicleColoursTableRGB[256][] = {
	"000000", "F5F5F5", "2A77A1", "840410", "263739", "86446E", "D78E10", "4C75B7", "BDBEC6", "5E7072",
	"46597A", "656A79", "5D7E8D", "58595A", "D6DAD6", "9CA1A3", "335F3F", "730E1A", "7B0A2A", "9F9D94",
	"3B4E78", "732E3E", "691E3B", "96918C", "515459", "3F3E45", "A5A9A7", "635C5A", "3D4A68", "979592",
	"421F21", "5F272B", "8494AB", "767B7C", "646464", "5A5752", "252527", "2D3A35", "93A396", "6D7A88",
	"221918", "6F675F", "7C1C2A", "5F0A15", "193826", "5D1B20", "9D9872", "7A7560", "989586", "ADB0B0",
	"848988", "304F45", "4D6268", "162248", "272F4B", "7D6256", "9EA4AB", "9C8D71", "6D1822", "4E6881",
	"9C9C98", "917347", "661C26", "949D9F", "A4A7A5", "8E8C46", "341A1E", "6A7A8C", "AAAD8E", "AB988F",
	"851F2E", "6F8297", "585853", "9AA790", "601A23", "20202C", "A4A096", "AA9D84", "78222B", "0E316D",
	"722A3F", "7B715E", "741D28", "1E2E32", "4D322F", "7C1B44", "2E5B20", "395A83", "6D2837", "A7A28F",
	"AFB1B1", "364155", "6D6C6E", "0F6A89", "204B6B", "2B3E57", "9B9F9D", "6C8495", "4D8495", "AE9B7F",
	"406C8F", "1F253B", "AB9276", "134573", "96816C", "64686A", "105082", "A19983", "385694", "525661",
	"7F6956", "8C929A", "596E87", "473532", "44624F", "730A27", "223457", "640D1B", "A3ADC6", "695853",
	"9B8B80", "620B1C", "5B5D5E", "624428", "731827", "1B376D", "EC6AAE", "000000",
	// SA-MP extended colours (0.3x)
	"177517", "210606", "125478", "452A0D", "571E1E", "010701", "25225A", "2C89AA", "8A4DBD", "35963A",
	"B7B7B7", "464C8D", "84888C", "817867", "817A26", "6A506F", "583E6F", "8CB972", "824F78", "6D276A",
	"1E1D13", "1E1306", "1F2518", "2C4531", "1E4C99", "2E5F43", "1E9948", "1E9999", "999976", "7C8499",
	"992E1E", "2C1E08", "142407", "993E4D", "1E4C99", "198181", "1A292A", "16616F", "1B6687", "6C3F99",
	"481A0E", "7A7399", "746D99", "53387E", "222407", "3E190C", "46210E", "991E1E", "8D4C8D", "805B80",
	"7B3E7E", "3C1737", "733517", "781818", "83341A", "8E2F1C", "7E3E53", "7C6D7C", "020C02", "072407",
	"163012", "16301B", "642B4F", "368452", "999590", "818D96", "99991E", "7F994C", "839292", "788222",
	"2B3C99", "3A3A0B", "8A794E", "0E1F49", "15371C", "15273A", "375775", "060820", "071326", "20394B",
	"2C5089", "15426C", "103250", "241663", "692015", "8C8D94", "516013", "090F02", "8C573A", "52888E",
	"995C52", "99581E", "993A63", "998F4E", "99311E", "0D1842", "521E1E", "42420D", "4C991E", "082A1D",
	"96821D", "197F19", "3B141F", "745217", "893F8D", "7E1A6C", "0B370B", "27450D", "071F24", "784573",
	"8A653A", "732617", "319490", "56941D", "59163D", "1B8A2F", "38160B", "041804", "355D8E", "2E3F5B",
	"561A28", "4E0E27", "706C67", "3B3E42", "2E2D33", "7B7E7D", "4A4442", "28344E"
};

//Timers
static stock
	Timer:PlayerTestTimer[MAX_PLAYERS],
	Timer:PlayerTestBackTimer[MAX_PLAYERS],
	EditingTrunkWeaponModel[MAX_PLAYERS],
	EditingTrunkWeaponObject[MAX_PLAYERS];
	//TrailRespawnTimer = 0;

/*
	 ######  ########  #######   ######  ##    ##  ######
	##    ##    ##    ##     ## ##    ## ##   ##  ##    ##
	##          ##    ##     ## ##       ##  ##   ##
	 ######     ##    ##     ## ##       #####     ######
		  ##    ##    ##     ## ##       ##  ##         ##
	##    ##    ##    ##     ## ##    ## ##   ##  ##    ##
	 ######     ##     #######   ######  ##    ##  ######
*/
///////////////////////////////////////////////////////////////////

stock BuyVehicle(playerid, bool:credit_activated = false)
{
	//Car
	AC_DestroyVehicle(PreviewCar[playerid]);
	PreviewCar[playerid] = INVALID_VEHICLE_ID;
	Streamer_UpdateEx(playerid, VehicleBuyPos[PlayerDealer[playerid]][0],VehicleBuyPos[PlayerDealer[playerid]][1],VehicleBuyPos[PlayerDealer[playerid]][2]);

	//TD
	DestroyCarsTextDraws(playerid);

	// Vehicle List Reset
	ResetVehicleList(playerid);

	//Variables
	new
		modelid,
		price,
		engineType;

	switch(PlayerDealer[playerid])
	{
		case VEH_DEALER_CARS: { 	modelid = LandVehicles[PreviewType[playerid]][viModelid]; price = LandVehicles[PreviewType[playerid]][viPrice]; engineType = LandVehicles[PreviewType[playerid]][viEngineType]; }
		case VEH_DEALER_BOAT: {		modelid = SeaVehicles[PreviewType[playerid]][viModelid];  price = SeaVehicles[PreviewType[playerid]][viPrice];  engineType = SeaVehicles[PreviewType[playerid]][viEngineType]; }
		case VEH_DEALER_PLANE: 
		{	
			modelid = AirVehicles[PreviewType[playerid]][viModelid];			
			price = AirVehicles[PreviewType[playerid]][viPrice];  
			if(PlayerInfo[playerid][pDonateRank] == 4 && AirVehicles[PreviewType[playerid]][viModelid] == 469)
				price /= 2;
			engineType = AirVehicles[PreviewType[playerid]][viEngineType]; 
		}
	}
	if(credit_activated)
		price -= CreditInfo[playerid][cAmount];
	new
		cCar = AC_CreateVehicle(modelid, VehicleBuyPos[PlayerDealer[playerid]][0],VehicleBuyPos[PlayerDealer[playerid]][1],VehicleBuyPos[PlayerDealer[playerid]][2],VehicleBuyPos[PlayerDealer[playerid]][3], PreviewColor1[playerid], PreviewColor2[playerid], -1, 0);
	ResetVehicleInfo(cCar);

	VehiclePrevInfo[cCar][vPosX] = VehicleBuyPos[PlayerDealer[playerid]][0];
	VehiclePrevInfo[cCar][vPosY] = VehicleBuyPos[PlayerDealer[playerid]][1];
	VehiclePrevInfo[cCar][vPosZ] = VehicleBuyPos[PlayerDealer[playerid]][2];
	VehiclePrevInfo[cCar][vRotZ] = VehicleBuyPos[PlayerDealer[playerid]][3];
	VehiclePrevInfo[cCar][vPosDiff] = 0.0;

	PlayerInfo[playerid][pSpawnedCar] 	= cCar;
	PlayerModel[playerid]				= modelid;
	PlayerEngine[playerid] 				= engineType;
	VehicleInfo[cCar][vInt] 			= 0;
	VehicleInfo[cCar][vViwo] 			= 0;

	//SQL
	new insertCoQuery[1500];

	mysql_tquery(g_SQL, "BEGIN", "");
	mysql_format(g_SQL, insertCoQuery, 1500, "INSERT INTO `cocars`(`modelid`, `color1`, `color2`, `numberplate`, `parkX`, `parkY`, `parkZ`, `angle`, `interior`, `viwo`, `ownerid`, `enginetype`, `enginelife`, `enginescrewed`, `heat`, `overheated`, `fuel`, `batterylife`, `insurance`, `panels`, `doors`, `tires`, `lights`, `travel`, `lock`, `alarm`, `immob`, `audio`, `canstart`, `parts`, `destroys`, `health`, `batterytype`, `hydraulics`, `impounded`, `sirenon`, `sparekey1`, `sparekey2`, `bodyarmor`, `tirearmor`, `nos`) VALUES ('%d','%d','%d','%e','%.2f','%.2f','%.2f','%.2f','%d','%d','%d','%d','%d','%d','%f','%d','%d','%d','%d','%d','%d','%d','%d','%f','%d','%d','%d','%d','%d','%d','%d','%f','%d','%d','%d','%d','%d','%d','%d','%d', '%d')",
		modelid,
		PreviewColor1[playerid],
		PreviewColor2[playerid],
		"",
		VehicleBuyPos[PlayerDealer[playerid]][0],
		VehicleBuyPos[PlayerDealer[playerid]][1],
		VehicleBuyPos[PlayerDealer[playerid]][2],
		VehicleBuyPos[PlayerDealer[playerid]][3],
		0,
		0,
		PlayerInfo[playerid][pSQLID],
		engineType,
		ENGINE_LIFE_STOCK,
		0,
		0.0,
		0,
		100,
		BATTERY_LIFE_STOCK,
		0,
		0,
		0,
		0,
		0,
		0.0,
		1,
		1,
		1,
		1,
		1,
		0,
		0,
		1000.0,
		BATTERY_TYPE_STOCK,
		0,
		0,
		0,
		-1,
		-1,
		0.0,
		0.0,
		0
	);
	mysql_tquery(g_SQL, insertCoQuery, "OnVehicleBuy", "ii", playerid, cCar);
	mysql_tquery(g_SQL, "COMMIT", "");

	SetVehicleNumberPlate(cCar, "");
	
	ResetVehicleTrunkWeapons(cCar);
	ResetVehiclePackages(cCar);

	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(cCar, engine, lights, alarm, doors, bonnet, boot, objective);

	if(IsABike(modelid) || IsAPlane(modelid)) {
		SetVehicleParamsEx(cCar,VEHICLE_PARAMS_ON,VEHICLE_PARAMS_OFF,alarm,doors,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,objective);
		VehicleInfo[cCar][vEngineRunning] = 1;
	} else {
		SetVehicleParamsEx(cCar,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,alarm,doors,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,objective);
		VehicleInfo[cCar][vEngineRunning] = 0;
	}

	// Money
	PlayerToBudgetMoney(playerid, price); // Novac dolazi u proracun od kupljenog vozila

	// Get data
	GetPlayerVehicleList(playerid);

	//Pos
	TogglePlayerControllable(playerid, true);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, DealerInfo[PlayerDealer[playerid]][flPosX], DealerInfo[PlayerDealer[playerid]][flPosY], DealerInfo[PlayerDealer[playerid]][flPosZ]+1.0);
	SetCameraBehindPlayer(playerid);
	Bit1_Set(gr_PreviewCar, playerid, false);

	//Koristi li dealera?
	Bit8_Set(gr_UsingDealer, PlayerDealer[playerid], 0);

	// Donator vozilo
	if(LandVehicles[PreviewType[playerid]][viPremium] && PlayerInfo[playerid][pDonateRank] != 0)
	{
		PlayerInfo[playerid][pDonatorVehicle] = modelid;
		
		new donatorVehUpdate[128];
		format(donatorVehUpdate, 128, "UPDATE accounts SET `donateveh` = '%d' WHERE sqlid = '%d'", PlayerInfo[playerid][pDonatorVehicle], PlayerInfo[playerid][pSQLID]);
		mysql_tquery(g_SQL, donatorVehUpdate);
	}


    if(LandVehicles[PreviewType[playerid]][viPremium]){
        PlayerInfo[playerid][pDonatorVehPerms] -= 1;
        SendClientMessage(playerid, COLOR_RED, "[ ! ] Kupili ste VIP vozilo, potrosili ste jednu donatorsku dozvolu.");

        new donatorVehPerms[128];
		format(donatorVehPerms, 128, "UPDATE accounts SET `dvehperms` = '%d' WHERE sqlid = '%d'", PlayerInfo[playerid][pDonatorVehPerms], PlayerInfo[playerid][pSQLID]);
		mysql_tquery(g_SQL, donatorVehPerms);
	}
	
	#if defined MODULE_LOGS
	Log_Write("logfiles/car_carbuy.txt", "(%s) %s{%d} bought %s[SQLID: %d] for %d$.",
		ReturnDate(),
		GetName(playerid,false),
		PlayerInfo[playerid][pSQLID],
		ReturnVehicleName(modelid),
		VehicleInfo[cCar][vSQLID],
		price
	);
	#endif
	
	// Message
	va_SendClientMessage(playerid, COLOR_GREEN, "[ ! ]: Uspjesno ste kupili %s.", ReturnVehicleName(modelid));

	//Preview Vars
	PreviewColor1[playerid] = 0;
	PreviewColor2[playerid] = 0;
	PreviewType[playerid]	= 0;
	CameraPos[playerid] 	= 0;
	PlayerDealer[playerid] 	= 0;
	return 1;
}

stock GetClosestGasPump(playerid, bizid, pumpslot)
{
	new Float: minrange = 5.0, Float: range;

	bizid = INVALID_BUSINESS_ID;

    for(new b = 0; b < MAX_BUSINESSES; b++)
    {
	    for(new i = 0; i < MAX_BUSINESS_GAS_PUMPS; i++)
	    {
	        range = GetPlayerDistanceFromPoint(playerid, Businesses[b][GasPumpPosX][i], Businesses[b][GasPumpPosY][i], Businesses[b][GasPumpPosZ][i]);
	 	    if (range < minrange)
			{
				bizid = b;
				pumpslot = i;
			    minrange = range;
		    }
	   	}
 	}
}

stock ResetCarBuyVars(playerid)
{
	DestroyCarsTextDraws(playerid);

	Bit1_Set(gr_CarSlide,	playerid, false);
	Bit1_Set(gr_PreviewCar,	playerid, false);

	PreviewModel	[playerid]	= 0;
	PreviewCar		[playerid]	= INVALID_VEHICLE_ID;
	TestCar			[playerid]	= INVALID_VEHICLE_ID;
	PreviewColor1	[playerid]	= 0;
	PreviewColor2	[playerid]	= 0;
	PreviewType		[playerid]	= 0;
	CameraPos		[playerid]	= 0;
	PlayerDealer	[playerid]	= 0;
	PlayerGiveBackCP[playerid]	= 0;
	PlayerModel[playerid] 		= 0;
	PlayerEngine[playerid] 		= 0;

	stop PlayerTestTimer[playerid];
	stop PlayerTestBackTimer[playerid];
}

stock CheckVehicleList(playerid)
{
	if(PlayerInfo[playerid][pDonateRank] == 4)
	{
		if( VehicleInfoModel[playerid][0] != -1 && VehicleInfoModel[playerid][1] != -1 && VehicleInfoModel[playerid][2] != -1 && VehicleInfoModel[playerid][3] != -1 && VehicleInfoModel[playerid][4] != -1 &&
			VehicleInfoModel[playerid][5] != -1 && VehicleInfoModel[playerid][6] != -1 && VehicleInfoModel[playerid][7] != -1 && VehicleInfoModel[playerid][8] != -1 && VehicleInfoModel[playerid][9] != -1)
			return 0;
	}
	else
	{
		if( VehicleInfoModel[playerid][0] != -1 && VehicleInfoModel[playerid][1] != -1 && VehicleInfoModel[playerid][2] != -1 && VehicleInfoModel[playerid][3] != -1 && VehicleInfoModel[playerid][4] != -1 &&
			VehicleInfoModel[playerid][5] != -1 && VehicleInfoModel[playerid][6] != -1 && VehicleInfoModel[playerid][7] != -1)
			return 0;
	}
	return 1;
}

DeleteVehicleFromBase(vsqlid)
{
	new query[128];
	
	format(query, 128, "DELETE FROM `cocars_weapons` WHERE `vehicle_id` = '%d'", vsqlid);
	mysql_tquery(g_SQL, query);
	
	format(query, 128, "DELETE FROM `cocars_tickets` WHERE `vehicle_id` = '%d'", vsqlid);
	mysql_tquery(g_SQL, query);
	
	format(query, 128, "DELETE FROM `cocars` WHERE `id` = '%d'", vsqlid);
	mysql_tquery(g_SQL, query);
	
	return 1;
}

stock DeleteWeaponObject(vehicleid, slotid)
{
	new string[100];
	format(string, sizeof(string), "DELETE FROM `cocars_wobjects` WHERE `weaponsql` = '%d'", VehicleInfo[vehicleid][vWeaponSQLID][slotid]);
	mysql_tquery(g_SQL, string);
	return 1;
}

stock PutPlayerWeaponInTrunk(playerid, vehicleid, weaponid)
{
	new Float:x, Float:y, Float:z, Float: rz,
		model = WeaponModels(weaponid),
		vmodel = GetVehicleModel(vehicleid),
		slot = Iter_Free(VehWeapon[vehicleid]);
	
	if(!IsVehicleWithoutTrunk(vmodel) && !IsABike(model) && !IsAMotorBike(model))
	{
		StoreWeaponInTrunk(playerid, vehicleid, slot);
		GetVehicleZAngle(vehicleid, rz);
		GetPlayerPos(playerid, x, y, z);
		EditingTrunkWeaponModel[playerid] = WeaponModels(weaponid);
		Bit1_Set(gr_PlayerTrunkEdit, playerid, true);
		Bit4_Set(gr_WeaponTrunkEditSlot, playerid, slot);
		VehicleInfo[vehicleid][vWeaponObjectID][slot] = CreatePlayerObject(playerid, model, x, y, z, 0.0, 0.0, 0.0, 80.0);
		EditPlayerObject(playerid, VehicleInfo[vehicleid][vWeaponObjectID][slot]);
		EditingTrunkWeaponObject[playerid] = VehicleInfo[vehicleid][vWeaponObjectID][slot];
		SendMessage(playerid, MESSAGE_TYPE_INFO, "Namjestate poziciju oruzja u prtljazniku.Mozete mjenjati poziciju i rotaciju.");
		SendClientMessage(playerid, COLOR_RED, "HINT: Koristi SPACE da okrenes kameru. Zadnje dugme koristite za pohranu.");
	}
	else
	{
		if (!IsWeaponHideable(VehicleInfo[vehicleid][vWeaponId][slot]))
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Mozete sakriti samo manja oruzja(microSMG/Tec-9/Colt/Deagle).");
		new wname[32],
			carname[36];
		GetWeaponName(VehicleInfo[vehicleid][vWeaponId][slot], wname, 32);
		strunpack(carname, Model_Name(VehicleInfo[vehicleid][vModel]));
		SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste pohranili %s(%d metaka) u %s.", wname, VehicleInfo[vehicleid][vWeaponAmmo][slot], carname);
		StoreWeaponInTrunk(playerid, vehicleid, slot);
		CheckVehicleWeaponTrunkSpace(playerid, vehicleid);
	}
	AntiSpamInfo[playerid][asCarTrunk] = gettimestamp() + ANTI_SPAM_CAR_WEAPON;
	return 1;
}

stock StoreWeaponInTrunk(playerid, vehicleid, slot)
{
	new weaponid = AC_GetPlayerWeapon(playerid),
		ammo = AC_GetPlayerAmmo(playerid),
		gunname[32];
		
	GetWeaponName(weaponid, gunname, sizeof(gunname));
	
	new weaponInsertQuery[160];
	if(AC_GetPlayerAmmo(playerid) <= 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate oruzje u rukama!");
	if(AC_GetPlayerWeapon(playerid) == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate oruzje u rukama!");
	VehicleInfo[vehicleid][vWeaponId][slot] 	= weaponid;
	VehicleInfo[vehicleid][vWeaponAmmo][slot] 	+= ammo;
	AC_ResetPlayerWeapon(playerid, weaponid);
	
	// Query
	format(weaponInsertQuery, sizeof(weaponInsertQuery), "INSERT INTO `cocars_weapons`(`vehicle_id`, `weapon_id`, `ammo`) VALUES ('%d','%d','%d')",
		VehicleInfo[vehicleid][vSQLID],
		VehicleInfo[vehicleid][vWeaponId][slot],
		VehicleInfo[vehicleid][vWeaponAmmo][slot]
	);
	mysql_tquery(g_SQL, weaponInsertQuery, "OnVehicleWeaponInsert", "ii", vehicleid, slot);

	#if defined MODULE_LOGS	
	Log_Write("logfiles/weapon_trunkput.txt", "(%s) %s [Vehicle SQLID:%d] stored %s with %d bullets in %s(Slot %d).", 
		ReturnDate(), 
		GetName(playerid),
		VehicleInfo[vehicleid][vSQLID],
		gunname,
		ammo,
		ReturnVehicleName(GetVehicleModel(vehicleid)),
		slot
	);
	#endif
	
	Iter_Add(VehWeapon[vehicleid], slot);
	return 1;
}

stock TakePlayerWeaponFromTrunk(playerid, vehicleid, slot)
{	
	new	deleteWeaponQuery[128],
		gunname[32],
		carname[36];
	
	if (! CheckPlayerWeapons(playerid, VehicleInfo[vehicleid][vWeaponId][slot])) return 1;
	AC_GivePlayerWeapon(playerid, VehicleInfo[vehicleid][vWeaponId][slot], VehicleInfo[vehicleid][vWeaponAmmo][slot]);
	new	puzavac = IsCrounching(playerid);
	SetAnimationForWeapon(playerid, VehicleInfo[vehicleid][vWeaponId][slot], puzavac);
	
	// Query			
	format(deleteWeaponQuery, 128, "DELETE FROM `cocars_weapons` WHERE `id` = '%d'",
		VehicleInfo[vehicleid][vWeaponSQLID][slot]
	);
	mysql_tquery(g_SQL, deleteWeaponQuery);
	
	GetWeaponName(VehicleInfo[vehicleid][vWeaponId][slot], gunname, sizeof(gunname));
	
	#if defined MODULE_LOGS
	Log_Write("logfiles/weapon_trunktake.txt", "(%s) %s [Vehicle SQLID:%d] took %s with %d bullets from %s(Slot %d).", 
		ReturnDate(), 
		GetName(playerid),
		VehicleInfo[vehicleid][vSQLID],
		gunname,
		VehicleInfo[vehicleid][vWeaponAmmo][slot],
		ReturnVehicleName(GetVehicleModel(vehicleid)),
		slot
	);
	#endif
	
	strunpack(carname, Model_Name(VehicleInfo[vehicleid][vModel]));
	SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste uzeli %s(%d metaka) iz %s-a.", gunname, VehicleInfo[vehicleid][vWeaponAmmo][slot], carname);
	DeleteWeaponObject(vehicleid, slot);
	ClearWeaponObject(vehicleid, slot);
	
	// Enum
	VehicleInfo[vehicleid][vWeaponSQLID][slot] = -1;
	VehicleInfo[vehicleid][vWeaponId][slot] 	= 0;
	VehicleInfo[vehicleid][vWeaponAmmo][slot] 	= 0;
	
	Iter_Remove(VehWeapon[vehicleid], slot);
	ResetPlayerWeaponList(playerid);
	AntiSpamInfo[playerid][asCarTrunk] = gettimestamp() + ANTI_SPAM_CAR_WEAPON;
	return 1;
}

stock ClearWeaponObject(vehicleid, slot) 
{
	if(VehicleInfo[vehicleid][vWeaponId][slot] != 0)
	{
		if(IsValidObject(VehicleInfo[vehicleid][vWeaponObjectID][slot]))
		{
			DestroyObject(VehicleInfo[vehicleid][vWeaponObjectID][slot]);
			VehicleInfo[vehicleid][vWeaponObjectID][slot] = INVALID_OBJECT_ID;
		}
		VehicleInfo[vehicleid][vOffsetx][slot]      		= 0;
		VehicleInfo[vehicleid][vOffsety][slot]      		= 0;
		VehicleInfo[vehicleid][vOffsetz][slot]      		= 0;
		VehicleInfo[vehicleid][vOffsetxR][slot]     		= 0;
		VehicleInfo[vehicleid][vOffsetyR][slot]      		= 0;
		VehicleInfo[vehicleid][vOffsetzR][slot]      		= 0;
	}
	Iter_Remove(VehWeaponObject[vehicleid], slot);
	return 1;
}

stock ResetVehicleTrunkWeapons(vehicleid)
{
	foreach(new wslot: VehWeapon[vehicleid])
	{
		ClearWeaponObject(vehicleid, wslot);
		VehicleInfo[vehicleid][vWeaponSQLID][wslot] 		= -1;
		VehicleInfo[vehicleid][vWeaponId][wslot]			= 0;
		VehicleInfo[vehicleid][vWeaponAmmo][wslot]		= 0;
	}
	Iter_Clear(VehWeapon[vehicleid]);
	return 1;
}


/*
.88b  d88. d888888b .d8888.  .o88b.
88'YbdP`88   `88'   88'  YP d8P  Y8
88  88  88    88    `8bo.   8P
88  88  88    88      `Y8b. 8b
88  88  88   .88.   db   8D Y8b  d8
YP  YP  YP Y888888P `8888Y'  `Y88P'
*/

stock GetVehicleInfoOwner(vehicleid)
{
	new playerid = INVALID_PLAYER_ID;
	foreach(new i : Player)
	{
		if(PlayerInfo[i][pSQLID] == VehicleInfo[vehicleid][vOwnerID]) {
			playerid = i;
			break;
		}
	}
	return playerid;
}

stock GetVehicleByModel(modelid)
{
	for(new i = 0; i < sizeof(LandVehicles); i++)
	{
		if(LandVehicles[i][viModelid] == modelid)
		{
			return i;
		}
	}
	for(new i = 0; i < sizeof(SeaVehicles); i++)
	{
		if(SeaVehicles[i][viModelid] == modelid)
		{
			return i;
		}
	}
	for(new i = 0; i < sizeof(AirVehicles); i++)
	{
		if(AirVehicles[i][viModelid] == modelid)
		{
			return i;
		}
	}
	return -1;
}

stock GetVehicleCapacityByModel(modelid)
{
	for(new i = 0; i < sizeof(LandVehicles); i++)
	{
		if(LandVehicles[i][viModelid] == modelid)
		{
			return LandVehicles[i][viSlots];
		}
	}
	return -1;
}


stock ResetCarOwnershipVariables(playerid)
{
	if(Bit1_Get(gr_PreviewCar, 	playerid))
		DestroyPreviewScene(playerid);
	
	if(PlayerDealer[playerid] > 0)
	{
		if(Bit8_Get(gr_UsingDealer, PlayerDealer[playerid]) == playerid)
			Bit8_Set(gr_UsingDealer, PlayerDealer[playerid], 0);
	}

	// Regular vars
	PreviewModel		[playerid]		= 0;
	PreviewColor1		[playerid]		= 0;
	PreviewColor2		[playerid]		= 0;
	PreviewType			[playerid]		= 0;
	CameraPos			[playerid]		= 0;
	PlayerDealer		[playerid]		= 0;
	PlayerCarTow		[playerid]		= false;
	PlayerTowTimer		[playerid]		= 0;
	HotWiringSeconds	[playerid]		= 0;
	PlayerHotWireType	[playerid]		= 0;
	BreakLockKickTick	[playerid]		= 0;
	BreakTrunkKickTick	[playerid] 		= 0;
	PlayerSellingPrice	[playerid]		= 0;

	// Vehicles
	PreviewCar			[playerid]		= INVALID_VEHICLE_ID;
	TestCar				[playerid]		= INVALID_VEHICLE_ID;
	BreakLockVehicleID	[playerid]		= INVALID_VEHICLE_ID;
	BreakTrunkVehicleID	[playerid]		= INVALID_VEHICLE_ID;
	CopStreamVeh		[playerid]		= INVALID_VEHICLE_ID;
	PlayerHotWiringVeh	[playerid]		= INVALID_VEHICLE_ID;
	PlayerCarSeller		[playerid]	 	= INVALID_PLAYER_ID;

	PlayerGiveBackCP	[playerid] 		= 0;
	PlayerParkLocation	[playerid] 	= -1;

	// Vehicle List Reset
	ResetVehicleList(playerid);

	// Timers
	stop HotWiringTimer[playerid];

	// TextDraws
	DestroyCarsTextDraws(playerid);
	
	// Checkpoints
	DisablePlayerCheckpoint(playerid);
		
	//rBits
	Bit1_Set(	gr_CarSlide, 			playerid, false);
	Bit1_Set(	gr_PlayerLocateVeh, 	playerid, false);
	Bit1_Set(	gr_PreviewCar, 			playerid, false);
	Bit1_Set(	gr_PlayerTestingCar, 	playerid, false);
	Bit1_Set(	gr_PlayerHotWiring,		playerid, false);
	Bit1_Set(	gr_ColorDialogActive, 	playerid, false);
	Bit2_Set(	gr_PlayerLockBreaking, 	playerid, 0);
	Bit2_Set(	gr_HotWireClicks, 		playerid, 0);
	Bit1_Set(	gr_PlayerBreaking, 		playerid, false);
	Bit1_Set(	gr_PlayerBreakingTrunk,	playerid, false);
	Bit8_Set(	gr_BreakLockTDSecs, 	playerid, 0);
	Bit16_Set(	gr_PlayerTestSeconds, 	playerid, 0);
	return 1;
}

stock CheckVehicleWeaponCapacities(playerid, vehicleid)
{
	new vmodel = GetVehicleModel(vehicleid),
		maxweapons = GetVehicleCapacityByModel(vmodel);
	
	if(PlayerInfo[playerid][pDonateRank] > 0)
		maxweapons += 1;
	if(Iter_Count(VehWeapon[vehicleid]) >= maxweapons)
		return 0;
	else return 1;
}

stock CheckVehicleWeaponTrunkSpace(playerid, vehicleid)
{
	new vmodel = GetVehicleModel(vehicleid),
		maxweapons = GetVehicleCapacityByModel(vmodel),
		carname[36];
	
	strunpack(carname, Model_Name(VehicleInfo[vehicleid][vModel]));
	if(PlayerInfo[playerid][pDonateRank] > 0)
		maxweapons += 1;
		
	if(Iter_Count(VehWeapon[vehicleid]) >= maxweapons)
		va_SendClientMessage(playerid, COLOR_RED, "[ ! ] Zapunili ste sve skladisne prostore za oruzje u %s-u.", carname);
	else
	{
		new rest = maxweapons - Iter_Count(VehWeapon[vehicleid]);
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Preostalo je jos mjesta za %d oruzja u prtljazniku %s-a.", rest, carname);
	}
	return 1;
}

stock ResetVehiclePackages(vehicleid) 
{
	foreach(new slots: V_PACKAGES[vehicleid]) 
	{
		VehicleInfo[vehicleid][packSQLID] = -1;
		VehicleInfo[vehicleid][packWepID][slots] = 0;
		VehicleInfo[vehicleid][packAmmo][slots] = 0;
	}
	Iter_Clear(V_PACKAGES[vehicleid]);
	return (true);
}

stock ResetPlayerWeaponList(playerid)
{
	WeaponListID[playerid] = -1;
	for(new i=0; i < MAX_WAREHOUSE_WEAPONS; i++)
		WeaponToList[playerid][i] = -1;
	return 1;
}

stock LoadVehiclePackage(vehicleid) 
{
	new
		query[128];
	format(query, sizeof(query), "SELECT * FROM `cocars_wpackages` WHERE `vehicleid` = '%d' LIMIT 0,15",
		VehicleInfo[vehicleid][vSQLID]
	);
	mysql_pquery(g_SQL, query, "LoadingVehiclePackages", "i", vehicleid);
	return (true);
}

stock LoadVehicleWeapons(vehicleid)
{
	new
		tmpQuery[128];
	format(tmpQuery, 128, "SELECT * FROM `cocars_weapons` WHERE `vehicle_id` = '%d' LIMIT 0,7",
		VehicleInfo[vehicleid][vSQLID]
	);
	mysql_pquery(g_SQL, tmpQuery, "LoadingVehicleWeapons", "i", vehicleid);
	return 1;
}

stock LoadVehicleWeaponPos(vehicleid)
{
	new
		tmpQuery[128];
	format(tmpQuery, 128, "SELECT * FROM `cocars_wobjects` WHERE `vehicle_id` = '%d'",
		VehicleInfo[vehicleid][vSQLID]
	);
	mysql_pquery(g_SQL, tmpQuery, "LoadingVehicleWeaponPos", "i", vehicleid);
	return 1;
}

Public:LoadingPlayerVehicle(playerid)
{
	#if defined MOD_DEBUG
		printf("DEBUG CARS: count(%d)", cache_num_rows());
	#endif

	if(cache_num_rows()) {
	    for(new i = 0; i < cache_num_rows(); i++) {
			cache_get_value_name_int(i, 	"id"		, VehicleInfoSQLID[playerid][i]);
			cache_get_value_name_int(i, 	"modelid"	, VehicleInfoModel[playerid][i]);
			cache_get_value_name_float(i,  	"parkX"		, VehicleInfoParkX[playerid][i]);
			cache_get_value_name_float(i,  	"parkY"		, VehicleInfoParkY[playerid][i]);
			cache_get_value_name_float(i,  	"parkZ"		, VehicleInfoParkZ[playerid][i]);
		}
	}
	return 1;
}

Public:LoadingVehicleWeapons(vehicleid)
{
	if(cache_num_rows()) 
	{
	    for(new i = 0; i < cache_num_rows(); i++) 
		{	
			cache_get_value_name_int(i, "id"		, VehicleInfo[vehicleid][vWeaponSQLID][i]);
			cache_get_value_name_int(i, "weapon_id"	, VehicleInfo[vehicleid][vWeaponId][i]);
			cache_get_value_name_int(i, "ammo"		, VehicleInfo[vehicleid][vWeaponAmmo][i]);
			
			Iter_Add(VehWeapon[vehicleid], i);
		}
	}
	LoadVehicleWeaponPos(vehicleid);
	return 1;
}

stock ListPlayerVehicleWeapons(playerid, vehicleid)
{
	new buffer[756], wname[32], counter = 0;
	foreach(new wslot: VehWeapon[vehicleid])
	{
		GetWeaponName(VehicleInfo[vehicleid][vWeaponId][wslot], wname, 32);
		format(buffer, 756, "%s"COL_WHITE"%s(%d metaka)\n", 
			buffer,
			wname,
			VehicleInfo[vehicleid][vWeaponAmmo][wslot]
		);
		WeaponToList[playerid][counter] = wslot;
		counter++;
	}
	return buffer;
}

forward LoadingVehicleWeaponPos(vehicleid);
public LoadingVehicleWeaponPos(vehicleid)
{
	if(cache_num_rows()) 
	{
		new tmpSQL;
	    for(new i = 0; i < cache_num_rows(); i++) 
		{	
			cache_get_value_name_int(i,    "weaponsql"	, tmpSQL);
			foreach(new wslot: VehWeapon[vehicleid])
			{
				if(VehicleInfo[vehicleid][vWeaponSQLID][wslot] == tmpSQL)
				{
					cache_get_value_name_float(i,  "offsetx"	, VehicleInfo[vehicleid][vOffsetx][wslot]);
					cache_get_value_name_float(i,  "offsety"	, VehicleInfo[vehicleid][vOffsety][wslot]);
					cache_get_value_name_float(i,  "offsetz"	, VehicleInfo[vehicleid][vOffsetz][wslot]);
					cache_get_value_name_float(i,  "offsetrx"	, VehicleInfo[vehicleid][vOffsetxR][wslot]);
					cache_get_value_name_float(i,  "offsetry"	, VehicleInfo[vehicleid][vOffsetyR][wslot]);
					cache_get_value_name_float(i,  "offsetrz"	, VehicleInfo[vehicleid][vOffsetzR][wslot]);	
				
					if(VehicleInfo[vehicleid][vOffsetx][wslot] == 0 && VehicleInfo[vehicleid][vOffsety][wslot] == 0 && VehicleInfo[vehicleid][vOffsetz][wslot] == 0)
						continue;
				
					VehicleInfo[vehicleid][vWeaponObjectID][wslot] = CreateObject(WeaponModels(VehicleInfo[vehicleid][vWeaponId][wslot]), 0.0, 0.0, 0.0, 0, 0, 0, 0);	
					AttachObjectToVehicle(VehicleInfo[vehicleid][vWeaponObjectID][wslot], vehicleid, VehicleInfo[vehicleid][vOffsetx][wslot], VehicleInfo[vehicleid][vOffsety][wslot], VehicleInfo[vehicleid][vOffsetz][wslot], VehicleInfo[vehicleid][vOffsetxR][wslot], VehicleInfo[vehicleid][vOffsetyR][wslot], VehicleInfo[vehicleid][vOffsetzR][wslot]);
					Iter_Add(VehWeaponObject[vehicleid], wslot);
				}
			}
		}
	}
	return 1;
}	

forward OnVehicleBuy(playerid, vehicleid);
public OnVehicleBuy(playerid, vehicleid)
{

	// VehicleInfo enum
	VehicleInfo[vehicleid][vSQLID]				= cache_insert_id();
	VehicleInfo[vehicleid][vModel]				= PlayerModel[playerid];
	VehicleInfo[vehicleid][vColor1]				= PreviewColor1[playerid];
	VehicleInfo[vehicleid][vColor2]				= PreviewColor2[playerid];
	VehicleInfo[vehicleid][vSpawned]			= 1;
	VehicleInfo[vehicleid][vOwnerID] 			= PlayerInfo[playerid][pSQLID];
	format(VehicleInfo[vehicleid][vNumberPlate], 8, "");
	VehicleInfo[vehicleid][vParkX]				= VehicleBuyPos[PlayerDealer[playerid]][0];
	VehicleInfo[vehicleid][vParkY]				= VehicleBuyPos[PlayerDealer[playerid]][1];
	VehicleInfo[vehicleid][vParkZ]				= VehicleBuyPos[PlayerDealer[playerid]][2];
	VehicleInfo[vehicleid][vAngle]				= VehicleBuyPos[PlayerDealer[playerid]][3];
	VehicleInfo[vehicleid][vEngineType]			= PlayerEngine[playerid];
	VehicleInfo[vehicleid][vEngineLife]			= ENGINE_LIFE_STOCK;
	VehicleInfo[vehicleid][vEngineScrewed]		= 0;
	VehicleInfo[vehicleid][vHeat]				= 0.0;
	VehicleInfo[vehicleid][vOverHeated]			= 0;
	VehicleInfo[vehicleid][vFuel]				= 100;
	VehicleInfo[vehicleid][vBatteryType]		= BATTERY_TYPE_STOCK;
	VehicleInfo[vehicleid][vBatteryLife]		= BATTERY_LIFE_STOCK;
	VehicleInfo[vehicleid][vInsurance]			= 0;
	VehicleInfo[vehicleid][vPanels]				= 0;
	VehicleInfo[vehicleid][vDoors]				= 0;
	VehicleInfo[vehicleid][vTires]				= 0;
	VehicleInfo[vehicleid][vLights]				= 0;
	VehicleInfo[vehicleid][vTravel]				= 0.0;
	
	for(new wslot = 0; wslot < MAX_WEAPON_SLOTS; wslot++)
	{
		VehicleInfo[vehicleid][vWeaponSQLID][wslot] 		= -1;
		VehicleInfo[vehicleid][vWeaponId][wslot]			= 0;
		VehicleInfo[vehicleid][vWeaponAmmo][wslot]			= 0;
		VehicleInfo[vehicleid][vWeaponObjectID][wslot]		= INVALID_OBJECT_ID;
		VehicleInfo[vehicleid][vOffsetx][wslot]      		= 0;
		VehicleInfo[vehicleid][vOffsety][wslot]      		= 0;
		VehicleInfo[vehicleid][vOffsetz][wslot]      		= 0;
		VehicleInfo[vehicleid][vOffsetxR][wslot]     		= 0;
		VehicleInfo[vehicleid][vOffsetyR][wslot]      		= 0;
		VehicleInfo[vehicleid][vOffsetzR][wslot]      		= 0;
	}
	
	VehicleInfo[vehicleid][vSpareKey1]     		= -1;
	VehicleInfo[vehicleid][vSpareKey2]     		= -1;
	VehicleInfo[vehicleid][vUsage] 				= VEHICLE_USAGE_PRIVATE;
	VehicleInfo[vehicleid][vLock]				= 1;
	VehicleInfo[vehicleid][vLocked]				= 0;
	VehicleInfo[vehicleid][vAlarm]				= 1;
	VehicleInfo[vehicleid][vImmob]				= 1;
	VehicleInfo[vehicleid][vAudio]				= 0;
	VehicleInfo[vehicleid][vCanStart]       	= 1;
	VehicleInfo[vehicleid][vParts]          	= 0;
	VehicleInfo[vehicleid][vDestroys]			= 0;
	VehicleInfo[vehicleid][vImpounded]			= 0;

	Iter_Add(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid);
	return 1;
}

forward OnVehicleWeaponInsert(vehicleid, slot);
public OnVehicleWeaponInsert(vehicleid, slot)
{
	VehicleInfo[vehicleid][vWeaponSQLID][slot] = cache_insert_id();
	return 1;
}

/*
	d888888b d8888b. .d8888.
	`~~88~~' 88  `8D 88'  YP
	   88    88   88 `8bo.
	   88    88   88   `Y8b.
	   88    88  .8D db   8D
	   YP    Y8888D' `8888Y'
*/

stock static CreateCarsTextDraws(playerid)
{
	DestroyCarsTextDraws(playerid);
	MainBackground[playerid] = CreatePlayerTextDraw(playerid, 612.479980, 127.686668, "usebox");
	PlayerTextDrawLetterSize(playerid, 		MainBackground[playerid], 0.000000, 28.145353);
	PlayerTextDrawTextSize(playerid, 		MainBackground[playerid], 469.799987, 0.000000);
	PlayerTextDrawAlignment(playerid, 		MainBackground[playerid], 1);
	PlayerTextDrawColor(playerid, 			MainBackground[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			MainBackground[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		MainBackground[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		MainBackground[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		MainBackground[playerid], 0);
	PlayerTextDrawFont(playerid, 			MainBackground[playerid], 0);
	PlayerTextDrawShow(playerid,			MainBackground[playerid]);

	InfoText[playerid] = CreatePlayerTextDraw(playerid, 478.000030, 134.026626, "KUPI VOZILO");
	PlayerTextDrawLetterSize(playerid, 		InfoText[playerid], 0.424000, 1.572000);
	PlayerTextDrawAlignment(playerid, 		InfoText[playerid], 1);
	PlayerTextDrawColor(playerid, 			InfoText[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		InfoText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		InfoText[playerid], 1);
	PlayerTextDrawFont(playerid, 			InfoText[playerid], 3);
	PlayerTextDrawSetProportional(playerid, InfoText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, InfoText[playerid], 51);
	PlayerTextDrawShow(playerid,			InfoText[playerid]);

	InfoTextBcg[playerid] = CreatePlayerTextDraw(playerid, 612.490051, 134.406677, "usebox");
	PlayerTextDrawLetterSize(playerid, 		InfoTextBcg[playerid], 0.000000, 1.627136);
	PlayerTextDrawTextSize(playerid, 		InfoTextBcg[playerid], 470.399993, 0.000000);
	PlayerTextDrawAlignment(playerid, 		InfoTextBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			InfoTextBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			InfoTextBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		InfoTextBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		InfoTextBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		InfoTextBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			InfoTextBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			InfoTextBcg[playerid]);

	DenyButton[playerid] = CreatePlayerTextDraw(playerid, 592.750000, 132.533355, "X");
	PlayerTextDrawTextSize(playerid, 		DenyButton[playerid], 470.399993, 10.050029);
	PlayerTextDrawLetterSize(playerid, 		DenyButton[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, 		DenyButton[playerid], 1);
	PlayerTextDrawColor(playerid, 			DenyButton[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, 		DenyButton[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		DenyButton[playerid], 1);
	PlayerTextDrawFont(playerid, 			DenyButton[playerid], 1);
	PlayerTextDrawSetProportional(playerid, DenyButton[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, DenyButton[playerid], 51);
	PlayerTextDrawSetSelectable(playerid, 	DenyButton[playerid], true);
	PlayerTextDrawShow(playerid,			DenyButton[playerid]);

	FirstBcg[playerid] = CreatePlayerTextDraw(playerid, 609.600036, 165.268844, "usebox");
	PlayerTextDrawLetterSize(playerid, 		FirstBcg[playerid], 0.000000, 2.614690);
	PlayerTextDrawTextSize(playerid, 		FirstBcg[playerid], 473.199981, 0.000000);
	PlayerTextDrawAlignment(playerid, 		FirstBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			FirstBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			FirstBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		FirstBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		FirstBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		FirstBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			FirstBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			FirstBcg[playerid]);

	CarLeft[playerid] = CreatePlayerTextDraw(playerid, 479.100006, 168.746704, "~<~");
	PlayerTextDrawLetterSize(playerid, 		CarLeft[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		CarLeft[playerid], 495.312011, 20.050029);
	PlayerTextDrawAlignment(playerid, 		CarLeft[playerid], 1);
	PlayerTextDrawColor(playerid, 			CarLeft[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		CarLeft[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CarLeft[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CarLeft[playerid], 51);
	PlayerTextDrawFont(playerid, 			CarLeft[playerid], 1);
	PlayerTextDrawSetProportional(playerid, CarLeft[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	CarLeft[playerid], true);
	PlayerTextDrawShow(playerid,			CarLeft[playerid]);

	CarRight[playerid] = CreatePlayerTextDraw(playerid, 591.198974, 169.244476, "~>~");
	PlayerTextDrawLetterSize(playerid, 		CarRight[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		CarRight[playerid], 600.187500, 20.233352);
	PlayerTextDrawAlignment(playerid, 		CarRight[playerid], 1);
	PlayerTextDrawColor(playerid, 			CarRight[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		CarRight[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CarRight[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CarRight[playerid], 51);
	PlayerTextDrawFont(playerid, 			CarRight[playerid], 1);
	PlayerTextDrawSetProportional(playerid, CarRight[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	CarRight[playerid], true);
	PlayerTextDrawShow(playerid,			CarRight[playerid]);

	CarText[playerid] = CreatePlayerTextDraw(playerid, 539.599914, 170.737808, "VOZILO");
	PlayerTextDrawLetterSize(playerid, 		CarText[playerid], 0.380919, 1.276444);
	PlayerTextDrawAlignment(playerid, 		CarText[playerid], 2);
	PlayerTextDrawColor(playerid, 			CarText[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, 		CarText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CarText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CarText[playerid], 255);
	PlayerTextDrawFont(playerid, 			CarText[playerid], 2);
	PlayerTextDrawSetProportional(playerid, CarText[playerid], 1);
	PlayerTextDrawShow(playerid,			CarText[playerid]);

	Color1Bcg[playerid] = CreatePlayerTextDraw(playerid, 609.600036, 224.802780, "usebox");
	PlayerTextDrawLetterSize(playerid, 		Color1Bcg[playerid], 0.000000, 2.614690);
	PlayerTextDrawTextSize(playerid, 		Color1Bcg[playerid], 473.199951, 0.000000);
	PlayerTextDrawAlignment(playerid, 		Color1Bcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color1Bcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			Color1Bcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		Color1Bcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		Color1Bcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color1Bcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			Color1Bcg[playerid], 0);
	PlayerTextDrawShow(playerid,			Color1Bcg[playerid]);


	Color1Right[playerid] = CreatePlayerTextDraw(playerid, 591.439025, 198.165130, "~>~");
	PlayerTextDrawLetterSize(playerid, 		Color1Right[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		Color1Right[playerid], 601.625000, 20.491455);
	PlayerTextDrawAlignment(playerid, 		Color1Right[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color1Right[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		Color1Right[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color1Right[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Color1Right[playerid], 51);
	PlayerTextDrawFont(playerid, 			Color1Right[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Color1Right[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	Color1Right[playerid], true);
	PlayerTextDrawShow(playerid,			Color1Right[playerid]);

	Color1Left[playerid] = CreatePlayerTextDraw(playerid, 478.800079, 198.115631, "~<~");
	PlayerTextDrawLetterSize(playerid, 		Color1Left[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		Color1Left[playerid], 496.250000, 20.333740);
	PlayerTextDrawAlignment(playerid, 		Color1Left[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color1Left[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		Color1Left[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color1Left[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Color1Left[playerid], 51);
	PlayerTextDrawFont(playerid, 			Color1Left[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Color1Left[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	Color1Left[playerid], true);
	PlayerTextDrawShow(playerid,			Color1Left[playerid]);

	Color1Text[playerid] = CreatePlayerTextDraw(playerid, 540.359924, 199.757995, "BOJA");
	PlayerTextDrawLetterSize(playerid, 		Color1Text[playerid], 0.379999, 1.276000);
	PlayerTextDrawAlignment(playerid, 		Color1Text[playerid], 2);
	PlayerTextDrawColor(playerid, 			Color1Text[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, 		Color1Text[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color1Text[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Color1Text[playerid], 255);
	PlayerTextDrawFont(playerid, 			Color1Text[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Color1Text[playerid], 1);
	PlayerTextDrawShow(playerid,			Color1Text[playerid]);

	Color2Bcg[playerid] = CreatePlayerTextDraw(playerid, 478.632354, 195.405029, "usebox");
	PlayerTextDrawLetterSize(playerid, 		Color2Bcg[playerid], 0.000000, 2.562497);
	PlayerTextDrawTextSize(playerid, 		Color2Bcg[playerid], 605.413024, 0.000000);
	PlayerTextDrawAlignment(playerid, 		Color2Bcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color2Bcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			Color2Bcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		Color2Bcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		Color2Bcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color2Bcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			Color2Bcg[playerid], 0);
	PlayerTextDrawShow(playerid,			Color2Bcg[playerid]);

	Color2Left[playerid] = CreatePlayerTextDraw(playerid, 479.040069, 227.583770, "~<~");
	PlayerTextDrawLetterSize(playerid, 		Color2Left[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		Color2Left[playerid], 495.000000, 20.833007);
	PlayerTextDrawAlignment(playerid, 		Color2Left[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color2Left[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		Color2Left[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color2Left[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Color2Left[playerid], 51);
	PlayerTextDrawFont(playerid, 			Color2Left[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Color2Left[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	Color2Left[playerid], true);
	PlayerTextDrawShow(playerid,			Color2Left[playerid]);

	Color2Info[playerid] = CreatePlayerTextDraw(playerid, 520.319641, 229.724243, "BOJA");
	PlayerTextDrawLetterSize(playerid, 		Color2Info[playerid], 0.379999, 1.276000);
	PlayerTextDrawAlignment(playerid, 		Color2Info[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color2Info[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, 		Color2Info[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color2Info[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Color2Info[playerid], 255);
	PlayerTextDrawFont(playerid,			Color2Info[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Color2Info[playerid], 1);
	PlayerTextDrawShow(playerid,			Color2Info[playerid]);

	Color2Right[playerid] = CreatePlayerTextDraw(playerid, 592.719970, 227.733306, "~>~");
	PlayerTextDrawLetterSize(playerid, 		Color2Right[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		Color2Right[playerid], 602.500000, 20.583007);
	PlayerTextDrawAlignment(playerid,		Color2Right[playerid], 1);
	PlayerTextDrawColor(playerid, 			Color2Right[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		Color2Right[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		Color2Right[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Color2Right[playerid], 51);
	PlayerTextDrawFont(playerid, 			Color2Right[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Color2Right[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	Color2Right[playerid], true);
	PlayerTextDrawShow(playerid,			Color2Right[playerid]);

	MainInfoBcg[playerid] = CreatePlayerTextDraw(playerid, 609.640197, 255.814422, "usebox");
	PlayerTextDrawLetterSize(playerid, 		MainInfoBcg[playerid], 0.000000, 11.076915);
	PlayerTextDrawTextSize(playerid, 		MainInfoBcg[playerid], 472.839935, 0.000000);
	PlayerTextDrawAlignment(playerid, 		MainInfoBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			MainInfoBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			MainInfoBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		MainInfoBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		MainInfoBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		MainInfoBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			MainInfoBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			MainInfoBcg[playerid]);

	CarInfoText[playerid] = CreatePlayerTextDraw(playerid, 482.270050, 291.504455, "~n~                  ~n~");
	PlayerTextDrawLetterSize(playerid, 		CarInfoText[playerid], 0.322960, 1.157476);
	PlayerTextDrawAlignment(playerid, 		CarInfoText[playerid], 1);
	PlayerTextDrawColor(playerid, 			CarInfoText[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, 		CarInfoText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CarInfoText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CarInfoText[playerid], 255);
	PlayerTextDrawFont(playerid, 			CarInfoText[playerid], 1);
	PlayerTextDrawSetProportional(playerid, CarInfoText[playerid], 1);
	PlayerTextDrawShow(playerid,			CarInfoText[playerid]);

	BuyButton[playerid] = CreatePlayerTextDraw(playerid, 560.750366, 357.217590, "Buy");
	PlayerTextDrawLetterSize(playerid, 		BuyButton[playerid], 0.584000, 2.603022);
	PlayerTextDrawTextSize(playerid, 		BuyButton[playerid], 603.125000, 30.916664);
	PlayerTextDrawAlignment(playerid, 		BuyButton[playerid], 1);
	PlayerTextDrawColor(playerid, 			BuyButton[playerid], 8388863);
	PlayerTextDrawSetShadow(playerid, 		BuyButton[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		BuyButton[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, BuyButton[playerid], 51);
	PlayerTextDrawFont(playerid, 			BuyButton[playerid], 3);
	PlayerTextDrawSetProportional(playerid, BuyButton[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	BuyButton[playerid], true);
	PlayerTextDrawShow(playerid,			BuyButton[playerid]);

	TryButton[playerid] = CreatePlayerTextDraw(playerid, 480.610260, 358.842102, "PROBAJ");
	PlayerTextDrawLetterSize(playerid, 		TryButton[playerid], 0.512440, 2.305849);
	PlayerTextDrawTextSize(playerid, 		TryButton[playerid], 541.875000, 19.833337);
	PlayerTextDrawAlignment(playerid, 		TryButton[playerid], 1);
	PlayerTextDrawColor(playerid, 			TryButton[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, 		TryButton[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		TryButton[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, TryButton[playerid], 51);
	PlayerTextDrawFont(playerid, 			TryButton[playerid], 3);
	PlayerTextDrawSetProportional(playerid, TryButton[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	TryButton[playerid], true);
	PlayerTextDrawShow(playerid,			TryButton[playerid]);

	ModelTextBcg[playerid] = CreatePlayerTextDraw(playerid, 609.500000, 256.300018, "usebox");
	PlayerTextDrawLetterSize(playerid, 		ModelTextBcg[playerid], 0.000000, 2.068516);
	PlayerTextDrawTextSize(playerid, 		ModelTextBcg[playerid], 473.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, 		ModelTextBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			ModelTextBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			ModelTextBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		ModelTextBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		ModelTextBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		ModelTextBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			ModelTextBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			ModelTextBcg[playerid]);

	ModelText[playerid] = CreatePlayerTextDraw(playerid, 541.49945, 257.786804, "                ");
	PlayerTextDrawLetterSize(playerid, 		ModelText[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		ModelText[playerid], 473.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, 		ModelText[playerid], 2);
	PlayerTextDrawColor(playerid, 			ModelText[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		ModelText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		ModelText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, ModelText[playerid], 51);
	PlayerTextDrawFont(playerid, 			ModelText[playerid], 3);
	PlayerTextDrawSetProportional(playerid, ModelText[playerid], 1);
	PlayerTextDrawShow(playerid,			ModelText[playerid]);

	CameraLeft[playerid] = CreatePlayerTextDraw(playerid, 477.875000, 383.483398, "~<~");
	PlayerTextDrawLetterSize(playerid, 		CameraLeft[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		CameraLeft[playerid], 493.125000, 21.349998);
	PlayerTextDrawAlignment(playerid, 		CameraLeft[playerid], 1);
	PlayerTextDrawColor(playerid, 			CameraLeft[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		CameraLeft[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CameraLeft[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CameraLeft[playerid], 51);
	PlayerTextDrawFont(playerid, 			CameraLeft[playerid], 3);
	PlayerTextDrawSetProportional(playerid, CameraLeft[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	CameraLeft[playerid], true);
	PlayerTextDrawShow(playerid,			CameraLeft[playerid]);

	CameraBcg[playerid] = CreatePlayerTextDraw(playerid, 612.625000, 385.624908, "usebox");
	PlayerTextDrawLetterSize(playerid, 		CameraBcg[playerid], 0.000000, 2.022916);
	PlayerTextDrawTextSize(playerid, 		CameraBcg[playerid], 469.687500, 0.000000);
	PlayerTextDrawAlignment(playerid, 		CameraBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			CameraBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			CameraBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		CameraBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		CameraBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CameraBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			CameraBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			CameraBcg[playerid]);

	CameraRight[playerid] = CreatePlayerTextDraw(playerid, 590.375000, 383.483398, "~>~");
	PlayerTextDrawLetterSize(playerid, 		CameraRight[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		CameraRight[playerid], 604.625000, 21.349998);
	PlayerTextDrawAlignment(playerid, 		CameraRight[playerid], 1);
	PlayerTextDrawColor(playerid, 			CameraRight[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		CameraRight[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CameraRight[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CameraRight[playerid], 51);
	PlayerTextDrawFont(playerid, 			CameraRight[playerid], 1);
	PlayerTextDrawSetProportional(playerid, CameraRight[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	CameraRight[playerid], true);
	PlayerTextDrawShow(playerid,			CameraRight[playerid]);

	CameraText[playerid] = CreatePlayerTextDraw(playerid, 545.375000, 385.816436, "Camera");
	PlayerTextDrawLetterSize(playerid, 		CameraText[playerid], 0.396375, 1.310083);
	PlayerTextDrawTextSize(playerid, 		CameraText[playerid], 469.687500, 0.000000);
	PlayerTextDrawAlignment(playerid, 		CameraText[playerid], 2);
	PlayerTextDrawColor(playerid, 			CameraText[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		CameraText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		CameraText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, CameraText[playerid], 51);
	PlayerTextDrawFont(playerid, 			CameraText[playerid], 2);
	PlayerTextDrawSetProportional(playerid, CameraText[playerid], 1);
	PlayerTextDrawShow(playerid,			CameraText[playerid]);
}

stock DestroyCarsTextDraws(playerid)
{
	PlayerTextDrawDestroy(playerid,			MainBackground[playerid]);
	PlayerTextDrawDestroy(playerid,			InfoText[playerid]);
	PlayerTextDrawDestroy(playerid,			InfoTextBcg[playerid]);
	PlayerTextDrawDestroy(playerid,			DenyButton[playerid]);
	PlayerTextDrawDestroy(playerid,			FirstBcg[playerid]);
	PlayerTextDrawDestroy(playerid,			CarLeft[playerid]);
	PlayerTextDrawDestroy(playerid,			CarRight[playerid]);
	PlayerTextDrawDestroy(playerid,			CarText[playerid]);
	PlayerTextDrawDestroy(playerid,			Color1Bcg[playerid]);
	PlayerTextDrawDestroy(playerid,			Color1Left[playerid]);
	PlayerTextDrawDestroy(playerid,			Color1Right[playerid]);
	PlayerTextDrawDestroy(playerid,			Color1Text[playerid]);
	PlayerTextDrawDestroy(playerid,			Color2Bcg[playerid]);
	PlayerTextDrawDestroy(playerid,			Color2Left[playerid]);
	PlayerTextDrawDestroy(playerid,			Color2Info[playerid]);
	PlayerTextDrawDestroy(playerid,			Color2Right[playerid]);
	PlayerTextDrawDestroy(playerid,			MainInfoBcg[playerid]);
	PlayerTextDrawDestroy(playerid,			CarInfoText[playerid]);
	PlayerTextDrawDestroy(playerid,			BuyButton[playerid]);
	PlayerTextDrawDestroy(playerid,			TryButton[playerid]);
	PlayerTextDrawDestroy(playerid,			ModelTextBcg[playerid]);
	PlayerTextDrawDestroy(playerid,			ModelText[playerid]);
	PlayerTextDrawDestroy(playerid,			CameraLeft[playerid]);
	PlayerTextDrawDestroy(playerid,			CameraBcg[playerid]	);
	PlayerTextDrawDestroy(playerid,			CameraRight[playerid]);
	PlayerTextDrawDestroy(playerid,			CameraText[playerid]);

	MainBackground[playerid]	= PlayerText:INVALID_TEXT_DRAW;
	InfoText[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	InfoTextBcg[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	DenyButton[playerid]	    = PlayerText:INVALID_TEXT_DRAW;
	FirstBcg[playerid]	        = PlayerText:INVALID_TEXT_DRAW;
	CarLeft[playerid]	        = PlayerText:INVALID_TEXT_DRAW;
	CarRight[playerid]	        = PlayerText:INVALID_TEXT_DRAW;
	CarText[playerid]	        = PlayerText:INVALID_TEXT_DRAW;
	Color1Bcg[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	Color1Left[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	Color1Right[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	Color1Text[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	Color2Bcg[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	Color2Left[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	Color2Info[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	Color2Right[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	MainInfoBcg[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	CarInfoText[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	BuyButton[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	TryButton[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	ModelTextBcg[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	ModelText[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	CameraLeft[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	CameraBcg[playerid]			= PlayerText:INVALID_TEXT_DRAW;
	CameraRight[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	CameraText[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	return 1;
}

/*
	.d8888.  .o88b. d88888b d8b   db d88888b
	88'  YP d8P  Y8 88'     888o  88 88'
	`8bo.   8P      88ooooo 88V8o 88 88ooooo
	  `Y8b. 8b      88~~~~~ 88 V8o88 88~~~~~
	db   8D Y8b  d8 88.     88  V888 88.
	`8888Y'  `Y88P' Y88888P VP   V8P Y88888P
*/
stock static CreatePreviewScene(playerid, dealer)
{
	//Reseting vars
	PreviewColor1[playerid] = 0;
	PreviewColor2[playerid] = 0;
	PreviewType[playerid]	= 0;
	CameraPos[playerid]		= 0;
	PlayerDealer[playerid]	= dealer;

	stop PlayerTestTimer[playerid];
	stop PlayerTestBackTimer[playerid];

	//Koristi li dealera?
	Bit8_Set(gr_UsingDealer, 	dealer, 	playerid);
	Bit1_Set(gr_PreviewCar, 	playerid, 	true);

	//Destroying old vehicle
	AC_DestroyVehicle(PreviewCar[playerid]);
	PreviewCar[playerid] = INVALID_VEHICLE_ID;

	//Creating textdraws
	CreateCarsTextDraws(playerid);

	//Which dealer he use?
	new modelid;
	switch(dealer) {
		case VEH_DEALER_CARS: {
			modelid = LandVehicles[PreviewType[playerid]][viModelid];

			//TextDraws
			PlayerTextDrawSetString(playerid, ModelText[playerid], LandVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  LandVehicles[PreviewType[playerid]][viSeats], LandVehicles[PreviewType[playerid]][viFuel], LandVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
		case VEH_DEALER_BOAT: {
			modelid = SeaVehicles[PreviewType[playerid]][viModelid];

			//TextDraws
			PlayerTextDrawSetString(playerid, ModelText[playerid], "");
			PlayerTextDrawSetString(playerid, ModelText[playerid], SeaVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  SeaVehicles[PreviewType[playerid]][viSeats], SeaVehicles[PreviewType[playerid]][viFuel], SeaVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
		case VEH_DEALER_PLANE: {
			modelid = AirVehicles[PreviewType[playerid]][viModelid];

			//TextDraws
			PlayerTextDrawSetString(playerid, ModelText[playerid], "");
			PlayerTextDrawSetString(playerid, ModelText[playerid], AirVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  AirVehicles[PreviewType[playerid]][viSeats], AirVehicles[PreviewType[playerid]][viFuel], AirVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
	}

	PreviewCar[playerid] = AC_CreateVehicle(modelid, PreviewPos[dealer][0], PreviewPos[dealer][1], PreviewPos[dealer][2], PreviewPos[dealer][3], 0, 0, -1, 0);
	SetVehicleVirtualWorld(PreviewCar[playerid], playerid);

	//TextDraws
	CreateCarsTextDraws(playerid);
	PlayerTextDrawSetString(playerid, ModelText[playerid], LandVehicles[PreviewType[playerid]][viName]);

	new tmpString[108];
	format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  LandVehicles[PreviewType[playerid]][viSeats], LandVehicles[PreviewType[playerid]][viFuel], LandVehicles[PreviewType[playerid]][viPrice]);
	PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);

	SelectTextDraw(playerid, 0xFF4040AA);
	return 1;
}

stock DestroyPreviewScene(playerid)
{
	//Destroying vehicle
	DestroyVehicle(PreviewCar[playerid]);
	PreviewCar[playerid] = INVALID_VEHICLE_ID;

	//Koristi li dealera?
	Bit8_Set(gr_UsingDealer, 	PlayerDealer[playerid], 0);
	Bit1_Set(gr_PreviewCar, 	playerid, 				false);

	//TD
	DestroyCarsTextDraws(playerid);

	//Pos
	TogglePlayerControllable(playerid, true);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, DealerInfo[PlayerDealer[playerid]][flPosX], DealerInfo[PlayerDealer[playerid]][flPosY], DealerInfo[PlayerDealer[playerid]][flPosZ]);
	SetCameraBehindPlayer(playerid);

	//Clearing vars
	PreviewColor1[playerid] = 0;
	PreviewColor2[playerid] = 0;
	PreviewType[playerid]	= 0;
	CameraPos[playerid] 	= 0;
	PlayerDealer[playerid]	= 0;

	stop PlayerTestTimer[playerid];
	stop PlayerTestBackTimer[playerid];
	return 1;
}

stock static NextShopCamera(playerid)
{
	new
		cam = CameraPos[playerid];

	CameraPos[playerid]++;
	if(CameraPos[playerid] > 2) CameraPos[playerid] = 0;

	switch(PlayerDealer[playerid])
	{
		case VEH_DEALER_CARS: {
			InterpolateCameraPos(playerid, CarCamera[cam][0],  CarCamera[cam][1],  CarCamera[cam][2], CarCamera[CameraPos[playerid]][0], CarCamera[CameraPos[playerid]][1], CarCamera[CameraPos[playerid]][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[0][0], PreviewPos[0][1], PreviewPos[0][2], PreviewPos[0][0], PreviewPos[0][1], PreviewPos[0][2],  1000000, CAMERA_MOVE);
		}
		case VEH_DEALER_BOAT: {
			InterpolateCameraPos(playerid, BoatCamera[cam][0],  BoatCamera[cam][1],  BoatCamera[cam][2], BoatCamera[CameraPos[playerid]][0], BoatCamera[CameraPos[playerid]][1], BoatCamera[CameraPos[playerid]][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[1][0], PreviewPos[1][1], PreviewPos[1][2], PreviewPos[1][0], PreviewPos[1][1], PreviewPos[1][2],  1000000, CAMERA_MOVE);
		}
		case VEH_DEALER_PLANE: {
			InterpolateCameraPos(playerid, AeroCamera[cam][0],  AeroCamera[cam][1],  AeroCamera[cam][2], AeroCamera[CameraPos[playerid]][0], AeroCamera[CameraPos[playerid]][1], AeroCamera[CameraPos[playerid]][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[2][0], PreviewPos[2][1], PreviewPos[2][2], PreviewPos[2][0], PreviewPos[2][1], PreviewPos[2][2],  1000000, CAMERA_MOVE);
		}
	}
}

stock static LastShopCamera(playerid)
{
	new
		cam = CameraPos[playerid];

	CameraPos[playerid]--;
	if(CameraPos[playerid] < 0) CameraPos[playerid] = 2;

	switch(PlayerDealer[playerid])
	{
		case VEH_DEALER_CARS: {
			InterpolateCameraPos(playerid, CarCamera[cam][0],  CarCamera[cam][1],  CarCamera[cam][2], CarCamera[CameraPos[playerid]][0], CarCamera[CameraPos[playerid]][1], CarCamera[CameraPos[playerid]][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[0][0], PreviewPos[0][1], PreviewPos[0][2], PreviewPos[0][0], PreviewPos[0][1], PreviewPos[0][2],  1000000, CAMERA_MOVE);
		}
		case VEH_DEALER_BOAT: {
			InterpolateCameraPos(playerid, BoatCamera[cam][0],  BoatCamera[cam][1],  BoatCamera[cam][2], BoatCamera[CameraPos[playerid]][0], BoatCamera[CameraPos[playerid]][1], BoatCamera[CameraPos[playerid]][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[1][0], PreviewPos[1][1], PreviewPos[1][2], PreviewPos[1][0], PreviewPos[1][1], PreviewPos[1][2],  1000000, CAMERA_MOVE);
		}
		case VEH_DEALER_PLANE: {
			InterpolateCameraPos(playerid, AeroCamera[cam][0],  AeroCamera[cam][1],  AeroCamera[cam][2], AeroCamera[CameraPos[playerid]][0], AeroCamera[CameraPos[playerid]][1], AeroCamera[CameraPos[playerid]][2], 5000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[2][0], PreviewPos[2][1], PreviewPos[2][2], PreviewPos[2][0], PreviewPos[2][1], PreviewPos[2][2],  1000000, CAMERA_MOVE);
		}
	}
}

/*
db    db d88888b db   db d888888b  .o88b. db      d88888b
88    88 88'     88   88   `88'   d8P  Y8 88      88'
Y8    8P 88ooooo 88ooo88    88    8P      88      88ooooo
`8b  d8' 88~~~~~ 88~~~88    88    8b      88      88~~~~~
 `8bd8'  88.     88   88   .88.   Y8b  d8 88booo. 88.
   YP    Y88888P YP   YP Y888888P  `Y88P' Y88888P Y88888P
*/
stock static NextVehicle(playerid)
{
	//Destroying old car
	AC_DestroyVehicle(PreviewCar[playerid]);
	PreviewCar[playerid] = INVALID_VEHICLE_ID;

	//Dodjeljivanje modela vozila varijabli modelid
	new
		dealer = PlayerDealer[playerid],
		modelid;

	PreviewType[playerid]++;
	switch(dealer)
	{
		case VEH_DEALER_CARS: {
			if(PreviewType[playerid] > sizeof(LandVehicles)-1) PreviewType[playerid] = 0;
			modelid = LandVehicles[PreviewType[playerid]][viModelid];

			//TextDraw
			PlayerTextDrawSetString(playerid, ModelText[playerid], LandVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  LandVehicles[PreviewType[playerid]][viSeats], LandVehicles[PreviewType[playerid]][viFuel], LandVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
		case VEH_DEALER_BOAT: {
			if(PreviewType[playerid] > sizeof(SeaVehicles)-1) PreviewType[playerid] = 0;
			modelid = SeaVehicles[PreviewType[playerid]][viModelid];

			//TextDraw
			PlayerTextDrawSetString(playerid, ModelText[playerid], SeaVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  SeaVehicles[PreviewType[playerid]][viSeats], SeaVehicles[PreviewType[playerid]][viFuel], SeaVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
		case VEH_DEALER_PLANE: {
			if(PreviewType[playerid] > sizeof(AirVehicles)-1) PreviewType[playerid] = 0;
			modelid = AirVehicles[PreviewType[playerid]][viModelid];

			//TextDraw
			PlayerTextDrawSetString(playerid, ModelText[playerid], AirVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  AirVehicles[PreviewType[playerid]][viSeats], AirVehicles[PreviewType[playerid]][viFuel], AirVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
	}

	//Kreiranje automobila
	PreviewCar[playerid] = AC_CreateVehicle(modelid, PreviewPos[dealer][0], PreviewPos[dealer][1], PreviewPos[dealer][2], PreviewPos[dealer][3], PreviewColor1[playerid], PreviewColor2[playerid], -1, 0);
	SetVehicleVirtualWorld(PreviewCar[playerid], playerid+1);
	SetPlayerVirtualWorld(playerid, playerid+1);
	return 1;
}

stock static PreviouseVehicle(playerid)
{
	//Destroying old car
	AC_DestroyVehicle(PreviewCar[playerid]);
	PreviewCar[playerid] = INVALID_VEHICLE_ID;

	//Dodjeljivanje modela vozila varijabli modelid
	new
		dealer = PlayerDealer[playerid],
		modelid;

	PreviewType[playerid]--;
	switch(dealer)
	{
		case VEH_DEALER_CARS: {
			if(PreviewType[playerid] < 0) PreviewType[playerid] = (sizeof(LandVehicles)-1);
			modelid = LandVehicles[PreviewType[playerid]][viModelid];

			//TextDraw
			PlayerTextDrawSetString(playerid, ModelText[playerid], LandVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  LandVehicles[PreviewType[playerid]][viSeats], LandVehicles[PreviewType[playerid]][viFuel], LandVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
		case VEH_DEALER_BOAT: {
			if(PreviewType[playerid] < 0) PreviewType[playerid] = (sizeof(SeaVehicles)-1);
			modelid = SeaVehicles[PreviewType[playerid]][viModelid];

			//TextDraw
			PlayerTextDrawSetString(playerid, ModelText[playerid], SeaVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  SeaVehicles[PreviewType[playerid]][viSeats], SeaVehicles[PreviewType[playerid]][viFuel], SeaVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
		case VEH_DEALER_PLANE: {
			if(PreviewType[playerid] < 0) PreviewType[playerid] = (sizeof(AirVehicles)-1);
			modelid = AirVehicles[PreviewType[playerid]][viModelid];

			//TextDraw
			PlayerTextDrawSetString(playerid, ModelText[playerid], AirVehicles[PreviewType[playerid]][viName]);

			new tmpString[108];
			format(tmpString, sizeof(tmpString), "Sjedala: %d~n~Gorivo: %.0fl~n~Cijena: %d~g~$",  AirVehicles[PreviewType[playerid]][viSeats], AirVehicles[PreviewType[playerid]][viFuel], AirVehicles[PreviewType[playerid]][viPrice]);
			PlayerTextDrawSetString(playerid, CarInfoText[playerid], tmpString);
		}
	}

	//Kreiranje automobila
	PreviewCar[playerid] = AC_CreateVehicle(modelid, PreviewPos[dealer][0], PreviewPos[dealer][1], PreviewPos[dealer][2], PreviewPos[dealer][3], PreviewColor1[playerid], PreviewColor2[playerid], -1, 0);
	SetVehicleVirtualWorld(PreviewCar[playerid], playerid+1);
	SetPlayerVirtualWorld(playerid, playerid+1);
	return 1;
}

/*
	 .o88b.  .d88b.  db       .d88b.  d8888b. .d8888.
	d8P  Y8 .8P  Y8. 88      .8P  Y8. 88  `8D 88'  YP
	8P      88    88 88      88    88 88oobY' `8bo.
	8b      88    88 88      88    88 88`8b     `Y8b.
	Y8b  d8 `8b  d8' 88booo. `8b  d8' 88 `88. db   8D
	 `Y88P'  `Y88P'  Y88888P  `Y88P'  88   YD `8888Y'
*/
stock static NextVehColor(playerid, type)
{
	switch(type)
	{
		case 1: {
			PreviewColor1[playerid]++;
			if(PreviewColor1[playerid] == 255) PreviewColor1[playerid] = 0;
		}
		case 2: {
			PreviewColor2[playerid]++;
			if(PreviewColor2[playerid] == 255) PreviewColor2[playerid] = 0;
		}
	}
	ChangeVehicleColor(PreviewCar[playerid], PreviewColor1[playerid], PreviewColor2[playerid]);
	return 1;
}

stock static PrevVehColor(playerid, type)
{
	switch(type)
	{
		case 1: {
			PreviewColor1[playerid]--;
			if(PreviewColor1[playerid] <= 0) PreviewColor1[playerid] = 255;
		}
		case 2: {
			PreviewColor2[playerid]--;
			if(PreviewColor2[playerid] <= 0) PreviewColor2[playerid] = 255;
		}
	}
	ChangeVehicleColor(PreviewCar[playerid], PreviewColor1[playerid], PreviewColor2[playerid]);
	return 1;
}

/*
	d888888b d88888b .d8888. d888888b      d8888b. d888888b d8888b. d88888b
	`~~88~~' 88'     88'  YP `~~88~~'      88  `8D   `88'   88  `8D 88'
	   88    88ooooo `8bo.      88         88oobY'    88    88   88 88ooooo
	   88    88~~~~~   `Y8b.    88         88`8b      88    88   88 88~~~~~
	   88    88.     db   8D    88         88 `88.   .88.   88  .8D 88.
	   YP    Y88888P `8888Y'    YP         88   YD Y888888P Y8888D' Y88888P
*/

stock static CreateTestCar(playerid)
{
	//Brisanje preview auta
	AC_DestroyVehicle(PreviewCar[playerid]);
	PreviewCar[playerid] = INVALID_VEHICLE_ID;

	//Koristi li dealera?
	Bit8_Set(gr_UsingDealer, PlayerDealer[playerid], 0);

	//Player Sets
	DestroyCarsTextDraws(playerid);
	Bit1_Set(gr_PlayerTestingCar, playerid, true);
	TogglePlayerControllable(playerid, 	true);
	SetCameraBehindPlayer(playerid);

	//Kreiranje test auta
	new modelid;
	switch(PlayerDealer[playerid])
	{
		case VEH_DEALER_CARS: 	modelid = LandVehicles[PreviewType[playerid]][viModelid];
		case VEH_DEALER_BOAT: 	modelid = SeaVehicles[PreviewType[playerid]][viModelid];
		case VEH_DEALER_PLANE: 	modelid = AirVehicles[PreviewType[playerid]][viModelid];
	}
	TestCar[playerid] = AC_CreateVehicle(modelid, TestPositions[PlayerDealer[playerid]][0], TestPositions[PlayerDealer[playerid]][1], TestPositions[PlayerDealer[playerid]][2], TestPositions[PlayerDealer[playerid]][3], PreviewColor1[playerid], PreviewColor2[playerid], -1, 0);
	SetPlayerVirtualWorld(playerid, 				playerid+1);
	SetVehicleVirtualWorld(TestCar[playerid], 		playerid+1);
	PutPlayerInVehicle(playerid, 					TestCar[playerid], 0);
	SetVehicleNumberPlate(TestCar[playerid], 		"Test Ride");
	VehicleInfo[TestCar[playerid]][vFuel]			= 100;

	//Vehicle Sets
	new
		engine, lights, alarm, doors, bonnet, boot, objective;

	GetVehicleParamsEx(TestCar[playerid], engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(TestCar[playerid], VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
	VehicleInfo[TestCar[playerid]][vEngineRunning] = 1;


	// Timer for returning test car
	Bit16_Set(gr_PlayerTestSeconds, playerid, CAR_TEST_SEC);
	PlayerTestTimer[playerid] = repeat VehicleTestTimer(playerid);
	return 1;
}

/*
	d88888b d8b   db  d888b  d888888b d8b   db d88888b
	88'     888o  88 88' Y8b   `88'   888o  88 88'
	88ooooo 88V8o 88 88         88    88V8o 88 88ooooo
	88~~~~~ 88 V8o88 88  ooo    88    88 V8o88 88~~~~~
	88.     88  V888 88. ~8~   .88.   88  V888 88.
	Y88888P VP   V8P  Y888P  Y888888P VP   V8P Y88888P
*/
stock GetEngineType(modelid)
{
	new engine = -1;
	for(new x=0; x < sizeof(LandVehicles); x++) {
		if(LandVehicles[x][viModelid] == modelid) {
			engine = LandVehicles[x][viEngineType];
		}
	}
	return engine;
}

stock CheckVehicleEngine(vehicleid)
{
	new playerid = GetVehicleDriver(vehicleid);
	VehicleInfo[vehicleid][vEngineLife] -= ENGINE_DEDUCATION;
	if(VehicleInfo[vehicleid][vEngineLife] == 0) {		// Ako je motor zaribao
		VehicleInfo[vehicleid][vEngineScrewed]	= 1;

		new engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

		GameTextForPlayer(playerid, "~r~Vozilo je ugaseno radi zaribanog motora", 3000, 6);
		VehicleInfo[vehicleid][vEngineRunning] 	= 0;
		return 1;
	}
	if(1 <= VehicleInfo[vehicleid][vEngineLife] <= 10000) { // Ako motor ulazi u onu kriticnu dob
		VehicleInfo[vehicleid][vHeat] += 40.0;
		switch(random(40))
		{
			case 0 .. 10:  {	// Curenje goriva
				VehicleInfo[vehicleid][vFuel] -= 1;
			}
			case 11 .. 20: {	// Pregirajvanje motora
				VehicleInfo[vehicleid][vHeat] += 50.0;

				new engine, lights, alarm, doors, bonnet, boot, objective;
				GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

				VehicleInfo[vehicleid][vEngineRunning] 	= 0;
				GameTextForPlayer(playerid, "~r~Vozilo je ugaseno radi pregrijanog motora", 3000, 6);
			}
			case 21 .. 30: {	// Iskljucivanje motora
				new engine, lights, alarm, doors, bonnet, boot, objective;
				GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

				VehicleInfo[vehicleid][vEngineRunning] 	= 0;
				GameTextForPlayer(playerid, "~r~Vozilo je ugaseno radi slabog motora", 3000, 6);
			}
			case 31 .. 41:
				return 1;
		}
	}
	return 1;
}

stock CheckEngineHeat(vehicleid)
{
	if(VehicleInfo[vehicleid][vEngineRunning])
	{
		new playerid = GetVehicleDriver(vehicleid);
		if(VehicleInfo[vehicleid][vOverHeated]) return 1;

		VehicleInfo[vehicleid][vHeat] += 0.05;
		if(VehicleInfo[vehicleid][vHeat] == 100.0) {

			VehicleInfo[vehicleid][vEngineLife] -= (VehicleInfo[vehicleid][vEngineLife] / 125.0);
			VehicleInfo[vehicleid][vBatteryLife] -= (VehicleInfo[vehicleid][vBatteryLife] / 150.0);

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

			VehicleInfo[vehicleid][vEngineRunning] 	= 0;
			GameTextForPlayer(playerid, "~r~Vozilo je ugaseno radi pregrijanog motora", 3000, 6);
			VehicleInfo[vehicleid][vOverHeated] = true;
		}
		if(75.0 <= VehicleInfo[vehicleid][vHeat] <= 99.9) {
			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

			VehicleInfo[vehicleid][vEngineRunning] 	= 0;
			GameTextForPlayer(playerid, "~r~Vozilo je ugaseno radi pregrijanog motora", 3000, 6);
		}
	}
	else { //Ne radi motor
		if(VehicleInfo[vehicleid][vHeat] > 5.0) {
			VehicleInfo[vehicleid][vHeat] -= 5.0;
			if(0.0 <= VehicleInfo[vehicleid][vHeat] <= 50.0)
				if(VehicleInfo[vehicleid][vOverHeated]) VehicleInfo[vehicleid][vOverHeated] = false;
		}
	}
	return 1;
}

stock GetEngineLifeString(vehicleid)
{
	new engineString[16];
	if(VehicleInfo[vehicleid][vEngineScrewed]) 					format(engineString, 16, "{CD1414}Zariban");
	else if(VehicleInfo[vehicleid][vEngineLife] > 10000) 		format(engineString, 16, "{339933}Odlican");
	else if(1 <= VehicleInfo[vehicleid][vEngineLife] <= 10000) 	format(engineString, 16, "{CC3300}Los");
	return engineString;
}

stock GetEngineLifeStringTD(vehicleid)
{
	new engineString[16];
	if(VehicleInfo[vehicleid][vEngineScrewed]) 					format(engineString, 16, "~r~Zariban~w~");
	else if(VehicleInfo[vehicleid][vEngineLife] > 10000) 		format(engineString, 16, "~g~Odlican~w~");
	else if(1 <= VehicleInfo[vehicleid][vEngineLife] <= 10000) 	format(engineString, 16, "~y~Los~w~");
	return engineString;
}

stock GetEngineTypeString(type)
{
	new engineString[9];
	switch(type)
	{
		case ENGINE_TYPE_NONE:		format(engineString, 9, "Nista");
		case ENGINE_TYPE_DIESEL: 	format(engineString, 9, "Dizelas");
		case ENGINE_TYPE_PETROL: 	format(engineString, 9, "Benzinac");
	}
	return engineString;
}

/*
	d8888b.  .d8b.  d888888b d888888b d88888b d8888b. db    db
	88  `8D d8' `8b `~~88~~' `~~88~~' 88'     88  `8D `8b  d8'
	88oooY' 88ooo88    88       88    88ooooo 88oobY'  `8bd8'
	88~~~b. 88~~~88    88       88    88~~~~~ 88`8b      88
	88   8D 88   88    88       88    88.     88 `88.    88
	Y8888P' YP   YP    YP       YP    Y88888P 88   YD    YP
*/

stock GetBatteryTypeString(type)
{
	new batteryString[16];

	switch(type)
	{
		case BATTERY_TYPE_STOCK:	format(batteryString, 16, "Tvornicki");
		case BATTERY_TYPE_CYCLONE:	format(batteryString, 16, "Cyclone");
		case BATTERY_TYPE_VARTIO:	format(batteryString, 16, "Vartio Original");
		case BATTERY_TYPE_BOCHE: 	format(batteryString, 16, "Boche");
	}
	return batteryString;
}

stock GetBatteryLifeString(vehicleid)
{
	new batteryString[16];
	if(VehicleInfo[vehicleid][vBatteryLife] > 5000.0)				format(batteryString, 16, "{339933}Odlican");
	if(0.001 <= VehicleInfo[vehicleid][vBatteryLife] <= 5000.0)	format(batteryString, 16, "{CC3300}Los");
	return batteryString;
}

stock GetBatteryLifeStringTD(vehicleid)
{
	new batteryString[16];
	if(VehicleInfo[vehicleid][vBatteryLife] > 5000.0)				format(batteryString, 16, "~g~Odlican~w~");
	if(0.001 <= VehicleInfo[vehicleid][vBatteryLife] <= 5000.0)	format(batteryString, 16, "~r~Los~w~");
	return batteryString;
}

/*
	d888888b d8b   db .d8888. db    db d8888b.  .d8b.  d8b   db  .o88b. d88888b
	  `88'   888o  88 88'  YP 88    88 88  `8D d8' `8b 888o  88 d8P  Y8 88'
	   88    88V8o 88 `8bo.   88    88 88oobY' 88ooo88 88V8o 88 8P      88ooooo
	   88    88 V8o88   `Y8b. 88    88 88`8b   88~~~88 88 V8o88 8b      88~~~~~
	  .88.   88  V888 db   8D 88b  d88 88 `88. 88   88 88  V888 Y8b  d8 88.
	Y888888P VP   V8P `8888Y' ~Y8888P' 88   YD YP   YP VP   V8P  `Y88P' Y88888P
*/

stock CalculateVehiclePrice(vehicleid, type = 1)
{
	new price,
		modelid = GetVehicleByModel(GetVehicleModel(vehicleid));
	
	if(type == 1) 	// Auti
	{
		if(!IsABike(GetVehicleModel(vehicleid))) price = LandVehicles[modelid][viPrice] / 2;
		else price = floatround(LandVehicles[modelid][viPrice] * 0.5);
		
		if(price > LandVehicles[modelid][viPrice])
			return 0;
	}
	else if(type == 2) // Brodovi
	{
		price = SeaVehicles[modelid][viPrice] / 2;
		
		if(price > SeaVehicles[modelid][viPrice])
			return 0;
	}
	else if(type == 3) // Avioni
	{
		price = AirVehicles[modelid][viPrice] / 2;
		
		if(price > AirVehicles[modelid][viPrice])
			return 0;
	}
	return price;
}

/*
	d8888b.  .d8b.  d8888b. db   dD
	88  `8D d8' `8b 88  `8D 88 ,8P'
	88oodD' 88ooo88 88oobY' 88,8P
	88~~~   88~~~88 88`8b   88`8b
	88      88   88 88 `88. 88 `88.
	88      YP   YP 88   YD YP   YD
*/

stock ParkVehicleInfo(vehicleid)
{
	// Uzimanje Trenutnog Stanja CO-a
	new Float:vehHealth;
	GetVehicleHealth(vehicleid, vehHealth);
	GetVehicleDamageStatus(vehicleid, VehicleInfo[vehicleid][vPanels], VehicleInfo[vehicleid][vDoors], VehicleInfo[vehicleid][vLights], VehicleInfo[vehicleid][vTires]);

	// SQL spremanje
	new
		saveQuery[400];
	format(saveQuery, sizeof(saveQuery), "UPDATE `cocars` SET panels = '%d', doors = '%d', lights = '%d', tires = '%d', fuel = '%d', travel = '%f', batterylife = '%d', heat = '%f', overheated = '%d', enginelife = '%d', enginescrewed = '%d', health = '%f', destroys = '%d', batterytype = '%d', nos = '%d' WHERE id = '%d'",
		VehicleInfo[vehicleid][vPanels],
		VehicleInfo[vehicleid][vDoors],
		VehicleInfo[vehicleid][vLights],
		VehicleInfo[vehicleid][vTires],
		VehicleInfo[vehicleid][vFuel],
		VehicleInfo[vehicleid][vTravel],
		VehicleInfo[vehicleid][vBatteryLife],
		VehicleInfo[vehicleid][vHeat],
		VehicleInfo[vehicleid][vOverHeated],
		VehicleInfo[vehicleid][vEngineLife],
		VehicleInfo[vehicleid][vEngineScrewed],
		vehHealth,
		VehicleInfo[vehicleid][vDestroys],
		VehicleInfo[vehicleid][vBatteryType],
		VehicleInfo[vehicleid][vNOSCap],
		VehicleInfo[vehicleid][vSQLID]
	);
	mysql_tquery(g_SQL, saveQuery);	

	// Unistavanje vozila
	AC_DestroyVehicle(vehicleid);

	// Resetiranje Enuma
	ResetVehicleTrunkWeapons(vehicleid);
	ResetVehiclePackages(vehicleid);
	ResetVehicleInfo(vehicleid);
	ResetVehicleDrugs(vehicleid);

	return 1;
}

stock ResetVehicleList(playerid)
{
	for(new i = 0; i < MAX_PLAYER_CARS; i++)
	{
		VehicleInfoSQLID	[playerid][i]		= -1;
		VehicleInfoModel	[playerid][i]		= -1;
		VehicleInfoParkX	[playerid][i]		= 0.0;
		VehicleInfoParkY	[playerid][i]		= 0.0;
		VehicleInfoParkZ	[playerid][i]		= 0.0;
	}
	return 1;
}

stock SpawnVehicleInfo(playerid, pick)
{
	new
		tmpQuery[64];
	format(tmpQuery, 64, "SELECT * FROM `cocars` WHERE `id` = '%d' LIMIT 0,1", pick);

	inline SpawningPlayerVehicle()
	{
		if(cache_num_rows()) {
			new
				modelid,
				color[2],
				Float:Pos[4],
				vehicleid,
				string[8],
				Float:health,
				interior,
				viwo;		
			
			// Load
			cache_get_value_name_int(0,  	"modelid"	, modelid);
			cache_get_value_name_int(0,  	"color1"	, color[0]);
			cache_get_value_name_int(0,  	"color2"	, color[1]);
			cache_get_value_name_float(0,  	"parkX"		, Pos[0]);
			cache_get_value_name_float(0,  	"parkY"		, Pos[1]);
			cache_get_value_name_float(0,  	"parkZ"		, Pos[2]);
			cache_get_value_name_float(0,  	"angle"		, Pos[3]);
			cache_get_value_name_int(0,  	"interior"	, interior);
			cache_get_value_name_int(0,  	"viwo"		, viwo);

			// Kreiranje vozila
			vehicleid = AC_CreateVehicle(modelid, Pos[0], Pos[1], Pos[2], Pos[3], color[0], color[1], -1, 0);
			// Resetiranje varijabli
			ResetVehicleInfo(vehicleid);

			VehiclePrevInfo[vehicleid][vPosX] = Pos[0];
			VehiclePrevInfo[vehicleid][vPosY] = Pos[1];
			VehiclePrevInfo[vehicleid][vPosZ] = Pos[2];
			VehiclePrevInfo[vehicleid][vRotZ] = Pos[3];
			VehiclePrevInfo[vehicleid][vPosDiff] = 0.0;
			
			LinkVehicleToInterior(vehicleid, interior);
			SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid)); //viwo??

			// Popunjavanje enuma
			cache_get_value_name_int(0,  "id", VehicleInfo[vehicleid][vSQLID]);
			VehicleInfo[vehicleid][vModel] 		= 	modelid;
			VehicleInfo[vehicleid][vColor1] 	= 	color[0];
			VehicleInfo[vehicleid][vColor2] 	= 	color[1];
			VehicleInfo[vehicleid][vParkX] 		= 	Pos[0];
			VehicleInfo[vehicleid][vParkY] 		= 	Pos[1];
			VehicleInfo[vehicleid][vParkZ] 		= 	Pos[2];
			VehicleInfo[vehicleid][vAngle] 		= 	Pos[3];
			VehicleInfo[vehicleid][vInt] 		= 	interior;
			VehicleInfo[vehicleid][vViwo] 		= 	viwo;
			
			cache_get_value_name_int(0,  "sparekey1"	, VehicleInfo[vehicleid][vSpareKey1]);
			cache_get_value_name_int(0,  "sparekey2"	, VehicleInfo[vehicleid][vSpareKey2]);
			cache_get_value_name_int(0,  "tirearmor"	, VehicleInfo[vehicleid][vTireArmor]);
			cache_get_value_name_int(0,  "bodyarmor"	, VehicleInfo[vehicleid][vBodyArmor]);

			new Float:vehcHealth;
			GetVehicleHealth(vehicleid, vehcHealth);

			if(VehicleInfo[vehicleid][vBodyArmor] == 1 && vehcHealth == 1000.0) 
				AC_SetVehicleHealth(vehicleid, 1600.0);
			
			if(VehicleInfo[vehicleid][vTireArmor] == 1)
			{
			    AddVehicleComponent(vehicleid, 1025);
			    if(VehicleInfo[vehicleid][vTires] == 0)
			    {
			    	vTireHP[vehicleid][0] = 100;
			    	vTireHP[vehicleid][1] = 100;
			    	vTireHP[vehicleid][2] = 100;
			    	vTireHP[vehicleid][3] = 100;
		    	}
		    	VOSDelay(vehicleid);
			}
			
			// Ostatak loada
			cache_get_value_name_int(0,  "ownerid", VehicleInfo[vehicleid][vOwnerID]);
			cache_get_value_name(0,  "numberplate", string);
			format(VehicleInfo[vehicleid][vNumberPlate], 8, string);

			cache_get_value_name_float(0,  "health", health);

			if(health <= 390.0)
				VehicleInfo[vehicleid][vDestroyed] = true;

			cache_get_value_name_int(0,  	"enginetype"		, VehicleInfo[vehicleid][vEngineType]);
			cache_get_value_name_int(0,  	"enginelife"		, VehicleInfo[vehicleid][vEngineLife]);
			cache_get_value_name_int(0,  	"enginescrewed"		, VehicleInfo[vehicleid][vEngineScrewed]);
			cache_get_value_name_float(0,  	"heat"				, VehicleInfo[vehicleid][vHeat]);
			cache_get_value_name_int(0,  	"overheated"		, VehicleInfo[vehicleid][vOverHeated]);
			cache_get_value_name_int(0,  	"fuel"				, VehicleInfo[vehicleid][vFuel]);
			cache_get_value_name_float(0,  	"batterylife"		, VehicleInfo[vehicleid][vBatteryLife]);
			cache_get_value_name_int(0,  	"batterytype"		, VehicleInfo[vehicleid][vBatteryType]);
			cache_get_value_name_int(0,  	"insurance"			, VehicleInfo[vehicleid][vInsurance]);
			cache_get_value_name_int(0,  	"panels"			, VehicleInfo[vehicleid][vPanels]);
			cache_get_value_name_int(0,  	"doors"				, VehicleInfo[vehicleid][vDoors]);
			cache_get_value_name_int(0,  	"tires"				, VehicleInfo[vehicleid][vTires]);
			cache_get_value_name_int(0,  	"lights"			, VehicleInfo[vehicleid][vLights]);
			cache_get_value_name_float(0,  	"travel"			, VehicleInfo[vehicleid][vTravel]);
			cache_get_value_name_int(0,  	"lock"				, VehicleInfo[vehicleid][vLock]);
			cache_get_value_name_int(0,  	"alarm"				, VehicleInfo[vehicleid][vAlarm]);
			cache_get_value_name_int(0,  	"immob"				, VehicleInfo[vehicleid][vImmob]);
			cache_get_value_name_int(0,  	"audio"				, VehicleInfo[vehicleid][vAudio]);
			VehicleInfo[vehicleid][vUsage] 			= VEHICLE_USAGE_PRIVATE;
			VehicleInfo[vehicleid][vLocked]			= 1;
			cache_get_value_name_int(0,  	"canstart"			, VehicleInfo[vehicleid][vCanStart]);
			cache_get_value_name_int(0,  	"parts"				, VehicleInfo[vehicleid][vParts]);
			cache_get_value_name_int(0,  	"destroys"			, VehicleInfo[vehicleid][vDestroys]);
			cache_get_value_name_int(0,  	"hydraulics"		, VehicleInfo[vehicleid][vHydraulics]);
			cache_get_value_name_int(0,  	"impounded"			, VehicleInfo[vehicleid][vImpounded]);
			cache_get_value_name_int(0,  	"tuned"				, VehicleInfo[vehicleid][vTuned]);
			cache_get_value_name_int(0,  	"nos"				, VehicleInfo[vehicleid][vNOSCap]);
			
			// Vehicle Sets
			AC_SetVehicleHealth(vehicleid, health);
			UpdateVehicleDamageStatus(vehicleid, VehicleInfo[vehicleid][vPanels], VehicleInfo[vehicleid][vDoors], VehicleInfo[vehicleid][vLights], VehicleInfo[vehicleid][vTires]);

			if(VehicleInfo[vehicleid][vNumberPlate][0] == '0')
				SetVehicleNumberPlate(vehicleid, " ");
			else
				SetVehicleNumberPlate(vehicleid, VehicleInfo[vehicleid][vNumberPlate]);
			new
				engine,lights,alarm,doors,bonnet,boot,objective;
			GetVehicleParamsEx(vehicleid,engine,lights,alarm,doors,bonnet,boot,objective);
			if(IsABike(modelid) || IsAPlane(modelid) || IsABike(modelid)) {
				SetVehicleParamsEx(vehicleid,VEHICLE_PARAMS_ON,VEHICLE_PARAMS_OFF,alarm,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,VEHICLE_PARAMS_OFF,objective);
				VehicleInfo[vehicleid][vEngineRunning] = 1;
			} else {
				SetVehicleParamsEx(vehicleid,engine,lights,alarm,VEHICLE_PARAMS_ON,bonnet,boot,objective);
				VehicleInfo[vehicleid][vEngineRunning] = 0;
			}
			
			// Extern Load
			RemoveAllVehicleTuning(vehicleid);
			LoadVehicleWeapons(vehicleid);
			LoadVehiclePackage(vehicleid);
			if(VehicleInfo[vehicleid][vTuned])
				LoadVehicleTuning(vehicleid);
			LoadVehicleTickets(vehicleid);
			LoadVehicleDrugs(vehicleid);

			//
			Iter_Add(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid);
			PlayerInfo[playerid][pSpawnedCar] = vehicleid;
		} 
		else return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne posjedujete vozilo na tome slotu!");
	}
	mysql_tquery_inline_new(g_SQL, tmpQuery, using inline SpawningPlayerVehicle, "i", playerid);
	return PlayerInfo[playerid][pSpawnedCar];
}

/*
d888888b d8888b. d88888b db    db d88888b db
   88    88   8D 88'     88    88 88'     88
   88    88oobY' 88ooooo Y8    8P 88ooooo 88
   88    88 8b   88      `8b  d8' 88      88
   88    88  88. 88.      `8bd8'  88.     88
   YP    88   YD Y88888P    YP    Y88888P Y88888P
*/

stock static GetVehicleTravel(vehicleid)
{
    if(GetVehicleDistanceFromPoint(vehicleid, vOldPos[vehicleid][0], vOldPos[vehicleid][1], vOldPos[vehicleid][2]) <= 100.0)
	{
        VehicleInfo[vehicleid][vTravel] += (GetVehicleDistanceFromPoint(vehicleid, vOldPos[vehicleid][0], vOldPos[vehicleid][1], vOldPos[vehicleid][2]) * 0.001);
	}
    GetVehiclePos(vehicleid, vOldPos[vehicleid][0], vOldPos[vehicleid][1], vOldPos[vehicleid][2]);
}

/*
	d8888b.  .d88b.   .d88b.  d8888b.      			db   db d88888b  .d8b.  db      d888888b db   db
	88  `8D .8P  Y8. .8P  Y8. 88  `8D      			88   88 88'     d8' `8b 88      `~~88~~' 88   88
	88   88 88    88 88    88 88oobY'      			88ooo88 88ooooo 88ooo88 88         88    88ooo88
	88   88 88    88 88    88 88`8b    & Trunk  	88~~~88 88~~~~~ 88~~~88 88         88    88~~~88
	88  .8D `8b  d8' `8b  d8' 88 `88.     			88   88 88.     88   88 88booo.    88    88   88
	Y8888D'  `Y88P'   `Y88P'  88   YD      			YP   YP Y88888P YP   YP Y88888P    YP    YP   YP
*/

stock static CheckVehicleDoorHealth(playerid, vehicleid)
{
	if(VehicleInfo[vehicleid][vDoorHealth] <= 0.0)
	{
		if(!IsPlayerNearDoor(playerid, vehicleid)) {

			SendMessage(playerid, MESSAGE_TYPE_ERROR, " Vozilo je otislo!");
			// Destroy
			// Player vars sets
			BreakLockVehicleID[playerid] 	= INVALID_VEHICLE_ID;

			// 3dText - Destroy
			DestroyDynamic3DTextLabel(DoorHealth3DText[vehicleid]);
			DoorHealth3DText[vehicleid] = Text3D:INVALID_3DTEXT_ID;
			return 1;
		}
		// Vehicle sets
		new engine, lights, alarm, bonnet, boot, objective, panels, tires, doors;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);

		VehicleInfo[vehicleid][vLocked] = false;
		GameTextForPlayer(playerid, "~g~Vozilo otkljucano", 500, 5);
		
		Bit1_Set(gr_PlayerBreaking, playerid, true);
		Bit2_Set(gr_PlayerLockBreaking, playerid, 0);
		
		// Destroy
		// Player vars sets
		BreakLockVehicleID[playerid] 	= INVALID_VEHICLE_ID;

		// 3dText - Destroy
		DestroyDynamic3DTextLabel(DoorHealth3DText[vehicleid]);
		DoorHealth3DText[vehicleid] = Text3D:INVALID_3DTEXT_ID;

		// Vrata otpadaju
		GetVehicleDamageStatus(vehicleid,panels,doors,lights,tires);
		doors = encode_doors(0, 0, 4, 0, 0, 0);
		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	}
	if(1.0 <= VehicleInfo[vehicleid][vDoorHealth] <= 100.0) StartVehicleAlarm(vehicleid);
	return 1;
}

stock static CheckVehicleTrunkHealth(playerid, vehicleid)
{
	if(VehicleInfo[vehicleid][vTrunkHealth] <= 0.0)
	{
		if(!IsPlayerInRangeOfVehicle(playerid, vehicleid, 5.0)) 
		{
			SendMessage(playerid, MESSAGE_TYPE_ERROR, " Vozilo je otislo!");
			// Destroy
			// Player vars sets
			BreakTrunkVehicleID[playerid] 	= INVALID_VEHICLE_ID;

			// 3dText - Destroy
			DestroyDynamic3DTextLabel(TrunkHealth3DText[vehicleid]);
			TrunkHealth3DText[vehicleid] = Text3D:INVALID_3DTEXT_ID;
			return 1;
		}
		// Vehicle sets
		new engine, lights, alarm, bonnet, boot, objective, panels, tires, doors;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_ON, objective);

		VehicleInfo[vehicleid][vTrunk] = VEHICLE_PARAMS_ON;
		GameTextForPlayer(playerid, "~g~Gepek obijen", 500, 5);
		
		SendClientMessage(playerid, COLOR_RED, "[ ! ] Sada mozete provijeriti informacije o gepeku, /trunk take.");

		// Destroy
		// Player vars sets
		BreakTrunkVehicleID[playerid] 	= INVALID_VEHICLE_ID;

		// 3dText - Destroy
		DestroyDynamic3DTextLabel(TrunkHealth3DText[vehicleid]);
		TrunkHealth3DText[vehicleid] = Text3D:INVALID_3DTEXT_ID;

		// Karoserija gepeka otpada
		GetVehicleDamageStatus(vehicleid,panels,doors,lights,tires);
		new flp, frp, rlp, rrp, ws, fb, rb;
		decode_panels(panels, flp, frp, rlp, rrp, ws, fb, rb);
		panels = encode_panels(flp, frp, 1, 1, ws, fb, rb);
		UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
		
		#if defined MODULE_LOGS
		Log_Write("logfiles/trunkbreak.txt", "(%s) %s{%d} broke into the trunk of %s[SQLID: %d]!", 
			ReturnDate(), 
			GetName(playerid),
			PlayerInfo[playerid][pSQLID],
			ReturnVehicleName(VehicleInfo[vehicleid][vModel]),
			VehicleInfo[vehicleid][vSQLID]
		);
		#endif
	}
	if(1.0 <= VehicleInfo[vehicleid][vTrunkHealth] <= 100.0) StartVehicleAlarm(vehicleid);
	return 1;
}

/*
	 .d8b.  db       .d8b.  d8888b. .88b  d88.
	d8' `8b 88      d8' `8b 88  `8D 88'YbdP`88
	88ooo88 88      88ooo88 88oobY' 88  88  88
	88~~~88 88      88~~~88 88`8b   88  88  88
	88   88 88booo. 88   88 88 `88. 88  88  88
	YP   YP Y88888P YP   YP 88   YD YP  YP  YP
*/

stock StartVehicleAlarm(vehicleid)
{
	if(vehicleid == -1) 			return 0;
	if(VehicleAlarmStarted[vehicleid]) return 0;
	if(!VehicleInfo[vehicleid][vGPS]) return 1;	// Vehicle hotwired and disabled GPS/Alarm by Car Jacker
	switch(VehicleInfo[vehicleid][vAlarm])
	{
		case 1: 
		{
			// Alarm timer;
			VehicleAlarmTimer[vehicleid] = defer DisableVehicleAlarm(vehicleid);

			// Lights
			VehicleLightsBlinker[vehicleid] = 41;
			VehicleBlinking[vehicleid] = false;
			VehicleLightsTimer[vehicleid] = repeat VehicleLightsBlink(vehicleid);

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, doors, bonnet, boot, objective);
		}
		case 2: 
		{
			/****************** LEVEL 1 ******************/
			// Alarm timer
			VehicleAlarmTimer[vehicleid] = defer DisableVehicleAlarm(vehicleid);

			// Lights
			VehicleLightsBlinker[vehicleid] = 41;
			VehicleBlinking[vehicleid] = false;
			VehicleLightsTimer[vehicleid] = repeat VehicleLightsBlink(vehicleid);

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, doors, bonnet, boot, objective);

			/****************** LEVEL 2 ******************/
			SendAlarmMessageToPolice(vehicleid, false);
		}
		case 3: 
		{
			/****************** LEVEL 1 ******************/
			// Alarm timer
			VehicleAlarmTimer[vehicleid] = defer DisableVehicleAlarm(vehicleid);

			// Lights
			VehicleLightsBlinker[vehicleid] = 41;
			VehicleBlinking[vehicleid] = false;
			VehicleLightsTimer[vehicleid] = repeat VehicleLightsBlink(vehicleid);

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, doors, bonnet, boot, objective);

			/****************** LEVEL 2 ******************/
			SendAlarmMessageToPolice(vehicleid, false);

			/****************** LEVEL 3 ******************/
			new Float:vPos[3];
			CreateGangZoneAroundPoint(vPos[0], vPos[1], 100.0, 100.0);
			SendPlayerGTAMessage(GetVehicleInfoOwner(vehicleid));
		}
		case 4: 
		{
			/****************** LEVEL 1 ******************/
			// Alarm timer
			VehicleAlarmTimer[vehicleid] = defer DisableVehicleAlarm(vehicleid);

			// Lights
			VehicleLightsBlinker[vehicleid] = 41;
			VehicleBlinking[vehicleid] = false;
			VehicleLightsTimer[vehicleid] = repeat VehicleLightsBlink(vehicleid);

			new engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, doors, bonnet, boot, objective);

			/****************** LEVEL 2 ******************/
			SendAlarmMessageToPolice(vehicleid, true);

			/****************** LEVEL 3 ******************/
			new Float:vPos[3];
			CreateGangZoneAroundPoint(vPos[0], vPos[1], 100.0, 100.0);
			SendPlayerGTAMessage(GetVehicleInfoOwner(vehicleid));
		}
	}
	VehicleAlarmStarted[vehicleid] = true;
	return 1;
}

stock static SendPlayerGTAMessage(playerid)
{
	if(playerid == INVALID_PLAYER_ID) return 1;
	SendClientMessage(playerid, COLOR_RED, "SMS: Netko pokusava provaliti u vase vozilo! POSLAO: Osiguravajuca kuca");
	return 1;
}

stock static SendAlarmMessageToPolice(vehicleid, bool:streaming)
{
	if(vehicleid == -1) return 0;

	foreach(new playerid : Player) {
		if(IsACop(playerid) || IsASD(playerid) && PlayerInfo[playerid][pLawDuty] == 1)
		{
			new vehicleName[MAX_VEHICLE_NAME];
			GetVehicleNameById(vehicleid, vehicleName, MAX_VEHICLE_NAME);
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "*________________________ [GTA IN PROGRESS] ________________________*");
			va_SendClientMessage(playerid, -1, "\tModel vozila: %s | Registracija: %s", vehicleName, VehicleInfo[vehicleid][vNumberPlate]);
			va_SendClientMessage(playerid, -1, "\tBoja vozila: %d %d", VehicleInfo[vehicleid][vColor1], VehicleInfo[vehicleid][vColor2]);
			va_SendClientMessage(playerid, -1, "\tLokacija vozila: %s", GetVehicleZone(vehicleid));
			SendClientMessage(playerid, COLOR_LIGHTBLUE, "*____________________________________________________________________*");
			if(streaming) CopStreamVeh[playerid] = vehicleid;
		}
	}
	return 1;
}

/*
	db   db  .d88b.  d888888b db   d8b   db d888888b d8888b. d88888b
	88   88 .8P  Y8. `~~88~~' 88   I8I   88   `88'   88  `8D 88'
	88ooo88 88    88    88    88   I8I   88    88    88oobY' 88ooooo
	88~~~88 88    88    88    Y8   I8I   88    88    88`8b   88~~~~~
	88   88 `8b  d8'    88    `8b d8'8b d8'   .88.   88 `88. 88.
	YP   YP  `Y88P'     YP     `8b8' `8d8'  Y888888P 88   YD Y88888P
*/

stock ResetHotWireVars(playerid)
{
	// Timer & TDs
	stop HotWiringTimer[playerid];
	DestroyHotWiringTD(playerid);

	// Var sets
	PlayerInputHotWire[playerid][0] = 0;
	PlayerInputHotWire[playerid][1] = 0;

	PlayerHotWire[playerid][0] 		= 0;
	PlayerHotWire[playerid][1] 		= 0;
	PlayerHotWire[playerid][2] 		= 0;
	PlayerHotWire[playerid][3] 		= 0;
	PlayerHotWire[playerid][4] 		= 0;

	PlayerHotWiringVeh[playerid] = INVALID_VEHICLE_ID;
	Bit2_Set(gr_HotWireClicks, playerid, 	0);
	Bit1_Set(gr_PlayerHotWiring, playerid, false);
	return 1;
}

stock static CreateHotWiringTD(playerid)
{
	MainHotWireBcg[playerid] = CreatePlayerTextDraw(playerid, 393.250000, 334.583312, "usebox");
	PlayerTextDrawLetterSize(playerid, 		MainHotWireBcg[playerid], 0.000000, 7.655555);
	PlayerTextDrawTextSize(playerid,		MainHotWireBcg[playerid], 251.750000, 0.000000);
	PlayerTextDrawAlignment(playerid, 		MainHotWireBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			MainHotWireBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			MainHotWireBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		MainHotWireBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		MainHotWireBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		MainHotWireBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			MainHotWireBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			MainHotWireBcg[playerid]);

	SecHotWireBcg[playerid] = CreatePlayerTextDraw(playerid, 392.812500, 334.291595, "usebox");
	PlayerTextDrawLetterSize(playerid, 		SecHotWireBcg[playerid], 0.000000, 2.001389);
	PlayerTextDrawTextSize(playerid, 		SecHotWireBcg[playerid], 252.562500, 0.000000);
	PlayerTextDrawAlignment(playerid, 		SecHotWireBcg[playerid], 1);
	PlayerTextDrawColor(playerid, 			SecHotWireBcg[playerid], 0);
	PlayerTextDrawUseBox(playerid, 			SecHotWireBcg[playerid], true);
	PlayerTextDrawBoxColor(playerid, 		SecHotWireBcg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, 		MainHotWireBcg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		SecHotWireBcg[playerid], 0);
	PlayerTextDrawFont(playerid, 			SecHotWireBcg[playerid], 0);
	PlayerTextDrawShow(playerid,			SecHotWireBcg[playerid]);

	HotWireText[playerid] = CreatePlayerTextDraw(playerid, 259.812500, 337.108154, "HOTWIRING");
	PlayerTextDrawLetterSize(playerid, 		HotWireText[playerid], 0.370249, 1.159000);
	PlayerTextDrawAlignment(playerid, 		HotWireText[playerid], 1);
	PlayerTextDrawColor(playerid, 			HotWireText[playerid], -1);
	PlayerTextDrawSetShadow(playerid, 		HotWireText[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireText[playerid], 1);
	PlayerTextDrawFont(playerid, 			HotWireText[playerid], 2);
	PlayerTextDrawSetProportional(playerid, HotWireText[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, HotWireText[playerid], 51);
	PlayerTextDrawShow(playerid,			HotWireText[playerid]);

	HotWireRed[playerid] = CreatePlayerTextDraw(playerid, 275.437500, 365.691802, "C");
	PlayerTextDrawLetterSize(playerid, 		HotWireRed[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		HotWireRed[playerid], 283.875000, 15.00);
	PlayerTextDrawAlignment(playerid, 		HotWireRed[playerid], 1);
	PlayerTextDrawColor(playerid, 			HotWireRed[playerid], -16776961);
	PlayerTextDrawBoxColor(playerid, 		HotWireRed[playerid], 255);
	PlayerTextDrawSetShadow(playerid, 		HotWireRed[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireRed[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, HotWireRed[playerid], -1);
	PlayerTextDrawFont(playerid, 			HotWireRed[playerid], 3);
	PlayerTextDrawSetProportional(playerid, HotWireRed[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	HotWireRed[playerid], true);
	PlayerTextDrawShow(playerid,				HotWireRed[playerid]);

	HotWireBlue[playerid] = CreatePlayerTextDraw(playerid, 292.875000, 366.100189, "P");
	PlayerTextDrawLetterSize(playerid, 		HotWireBlue[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		HotWireBlue[playerid], 301.437500, 15.00);
	PlayerTextDrawAlignment(playerid, 		HotWireBlue[playerid], 1);
	PlayerTextDrawColor(playerid,			HotWireBlue[playerid], 65535);
	PlayerTextDrawBoxColor(playerid, 		HotWireBlue[playerid], 255);
	PlayerTextDrawSetShadow(playerid, 		HotWireBlue[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireBlue[playerid], 1);
	PlayerTextDrawFont(playerid, 			HotWireBlue[playerid], 3);
	PlayerTextDrawSetProportional(playerid, HotWireBlue[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, HotWireBlue[playerid], -1);
	PlayerTextDrawSetSelectable(playerid, 	HotWireBlue[playerid], true);
	PlayerTextDrawShow(playerid,				HotWireBlue[playerid]);

	HotWireYell[playerid] = CreatePlayerTextDraw(playerid, 311.937500, 366.391723, "Z");
	PlayerTextDrawLetterSize(playerid, 		HotWireYell[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		HotWireYell[playerid], 319.937500, 15.00);
	PlayerTextDrawAlignment(playerid, 		HotWireYell[playerid], 1);
	PlayerTextDrawColor(playerid, 			HotWireYell[playerid], -5963521);
	PlayerTextDrawBoxColor(playerid, 		HotWireYell[playerid], 255);
	PlayerTextDrawSetShadow(playerid, 		HotWireYell[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireYell[playerid], 1);
	PlayerTextDrawFont(playerid, 			HotWireYell[playerid], 3);
	PlayerTextDrawBackgroundColor(playerid, HotWireYell[playerid], -1);
	PlayerTextDrawSetProportional(playerid, HotWireYell[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	HotWireYell[playerid], true);
	PlayerTextDrawShow(playerid,				HotWireYell[playerid]);

	HotWireBrown[playerid] = CreatePlayerTextDraw(playerid, 330.625000, 366.975067, "S");
	PlayerTextDrawLetterSize(playerid, 		HotWireBrown[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		HotWireBrown[playerid], 339.500000, 15.00);
	PlayerTextDrawAlignment(playerid, 		HotWireBrown[playerid], 1);
	PlayerTextDrawColor(playerid, 			HotWireBrown[playerid], -1523963137);
	PlayerTextDrawBoxColor(playerid, 		HotWireBrown[playerid], 255);
	PlayerTextDrawSetShadow(playerid, 		HotWireBrown[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireBrown[playerid], 1);
	PlayerTextDrawFont(playerid, 			HotWireBrown[playerid], 3);
	PlayerTextDrawBackgroundColor(playerid, HotWireBrown[playerid], -1);
	PlayerTextDrawSetProportional(playerid, HotWireBrown[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	HotWireBrown[playerid], true);
	PlayerTextDrawShow(playerid,				HotWireBrown[playerid]);

	HotWireBlack[playerid] = CreatePlayerTextDraw(playerid, 346.812500, 366.624908, "C");
	PlayerTextDrawLetterSize(playerid, 		HotWireBlack[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, 		HotWireBlack[playerid], 355.625000, 15.00);
	PlayerTextDrawAlignment(playerid, 		HotWireBlack[playerid], 1);
	PlayerTextDrawColor(playerid, 			HotWireBlack[playerid], 255);
	PlayerTextDrawBoxColor(playerid,		HotWireBlack[playerid], 255);
	PlayerTextDrawSetShadow(playerid, 		HotWireBlack[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireBlack[playerid], 1);
	PlayerTextDrawFont(playerid, 			HotWireBlack[playerid], 3);
	PlayerTextDrawBackgroundColor(playerid, HotWireBlack[playerid], -1);
	PlayerTextDrawSetProportional(playerid, HotWireBlack[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, 	HotWireBlack[playerid], true);
	PlayerTextDrawShow(playerid,				HotWireBlack[playerid]);

	HotWireInfo[playerid] = CreatePlayerTextDraw(playerid, 217.500000, 409.383270, "Pronadji prave zice za paljenje~n~motora prije isteka vremena!");
	PlayerTextDrawLetterSize(playerid, 		HotWireInfo[playerid], 0.295874, 0.929750);
	PlayerTextDrawAlignment(playerid, 		HotWireInfo[playerid], 1);
	PlayerTextDrawColor(playerid, 			HotWireInfo[playerid], -5963521);
	PlayerTextDrawSetShadow(playerid, 		HotWireInfo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, 		HotWireInfo[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, HotWireInfo[playerid], 255);
	PlayerTextDrawFont(playerid, 			HotWireInfo[playerid], 2);
	PlayerTextDrawSetProportional(playerid, HotWireInfo[playerid], 1);
	PlayerTextDrawShow(playerid,			HotWireInfo[playerid]);
}

stock DestroyHotWiringTD(playerid)
{
	PlayerTextDrawDestroy(playerid,			HotWireYell[playerid]);
	PlayerTextDrawDestroy(playerid,			HotWireBlue[playerid]);
	PlayerTextDrawDestroy(playerid,			HotWireRed[playerid]);
	PlayerTextDrawDestroy(playerid,			HotWireText[playerid]);
	PlayerTextDrawDestroy(playerid,			SecHotWireBcg[playerid]);
	PlayerTextDrawDestroy(playerid,			MainHotWireBcg[playerid]);
	PlayerTextDrawDestroy(playerid,			HotWireBrown[playerid]);
	PlayerTextDrawDestroy(playerid,			HotWireBlack[playerid]);
	PlayerTextDrawDestroy(playerid,			HotWireInfo[playerid]);

	HotWireYell[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	HotWireBlue[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	HotWireRed[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	HotWireText[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	SecHotWireBcg[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	MainHotWireBcg[playerid]	= PlayerText:INVALID_TEXT_DRAW;
	HotWireBrown[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	HotWireBlack[playerid]		= PlayerText:INVALID_TEXT_DRAW;
	HotWireInfo[playerid]		= PlayerText:INVALID_TEXT_DRAW;
}

stock static CreateHotWiringWires(playerid)
{
	PlayerHotWireType[playerid] = minrand(0, 3);
	switch(PlayerHotWireType[playerid]) {
		case 0: {
			PlayerHotWire[playerid][0] = HOT_ENGINE;
			PlayerHotWire[playerid][1] = HOT_BATTERY;
			PlayerHotWire[playerid][2] = HOT_ALARM;
			PlayerHotWire[playerid][3] = HOT_WINDOWS;
			PlayerHotWire[playerid][4] = HOT_LIGHTS;
		}
		case 1: {
			PlayerHotWire[playerid][0] = HOT_LIGHTS;
			PlayerHotWire[playerid][1] = HOT_BATTERY;
			PlayerHotWire[playerid][2] = HOT_WINDOWS;
			PlayerHotWire[playerid][3] = HOT_ENGINE;
			PlayerHotWire[playerid][4] = HOT_ALARM;
		}
		case 2: {
			PlayerHotWire[playerid][0] = HOT_WINDOWS;
			PlayerHotWire[playerid][1] = HOT_BATTERY;
			PlayerHotWire[playerid][2] = HOT_ENGINE;
			PlayerHotWire[playerid][3] = HOT_ALARM;
			PlayerHotWire[playerid][4] = HOT_LIGHTS;
		}
		case 3: {
			PlayerHotWire[playerid][0] = HOT_ENGINE;
			PlayerHotWire[playerid][1] = HOT_BATTERY;
			PlayerHotWire[playerid][2] = HOT_ALARM;
			PlayerHotWire[playerid][3] = HOT_LIGHTS;
			PlayerHotWire[playerid][4] = HOT_WINDOWS;
		}
	}
	return 1;
}

stock StartHotWiring(playerid, vehicleid)
{
	// Player Sets
	Bit1_Set(gr_PlayerHotWiring, playerid, 	true);
	Bit2_Set(gr_HotWireClicks, 	playerid, 	0);
	CreateHotWiringWires(playerid);

	PlayerHotWiringVeh[playerid] 		= vehicleid;
	PlayerInputHotWire[playerid][0] = 0;
	PlayerInputHotWire[playerid][1] = 0;

	// TextDraws
	DestroyHotWiringTD(playerid);
	CreateHotWiringTD(playerid);

	// Timer
	new imobTime;
	switch(VehicleInfo[vehicleid][vImmob]) {
		case 1: imobTime = 100;
		case 2: imobTime = 80;
		case 3: imobTime = 60;
		case 4: imobTime = 40;
		case 5: imobTime = 20;
	}

	stop HotWiringTimer[playerid];
	HotWiringSeconds[playerid] = imobTime;
	HotWiringTimer[playerid] = repeat PlayerHotWiring(playerid);
	SelectTextDraw(playerid, 0x00FF00FF);
	return 1;
}

stock static SetPlayerHotWireInput(playerid, type, slot)
{
	if(slot > 2) {
		Bit2_Set(gr_HotWireClicks, playerid, 0);

		PlayerInputHotWire[playerid][0] = 0;
		PlayerInputHotWire[playerid][1] = 0;
		return 1;
	}
	switch(PlayerHotWireType[playerid]) {
		case 0: {
			switch(type) {
				case 0: PlayerInputHotWire[playerid][slot] = HOT_ENGINE;
				case 1: PlayerInputHotWire[playerid][slot] = HOT_BATTERY;
				case 2: PlayerInputHotWire[playerid][slot] = HOT_ALARM;
				case 3: PlayerInputHotWire[playerid][slot] = HOT_WINDOWS;
				case 4: PlayerInputHotWire[playerid][slot] = HOT_LIGHTS;
			}
		}
		case 1: {
			switch(type) {
				case 0: PlayerInputHotWire[playerid][slot] = HOT_LIGHTS;
				case 1: PlayerInputHotWire[playerid][slot] = HOT_BATTERY;
				case 2: PlayerInputHotWire[playerid][slot] = HOT_WINDOWS;
				case 3: PlayerInputHotWire[playerid][slot] = HOT_ENGINE;
				case 4: PlayerInputHotWire[playerid][slot] = HOT_ALARM;
			}
		}
		case 2: {
			switch(type) {
				case 0: PlayerInputHotWire[playerid][slot] = HOT_WINDOWS;
				case 1: PlayerInputHotWire[playerid][slot] = HOT_BATTERY;
				case 2: PlayerInputHotWire[playerid][slot] = HOT_ENGINE;
				case 3: PlayerInputHotWire[playerid][slot] = HOT_ALARM;
				case 4: PlayerInputHotWire[playerid][slot] = HOT_LIGHTS;
			}
		}
		case 3: {
			switch(type) {
				case 0: PlayerInputHotWire[playerid][slot] = HOT_ENGINE;
				case 1: PlayerInputHotWire[playerid][slot] = HOT_BATTERY;
				case 2: PlayerInputHotWire[playerid][slot] = HOT_ALARM;
				case 3: PlayerInputHotWire[playerid][slot] = HOT_LIGHTS;
				case 4: PlayerInputHotWire[playerid][slot] = HOT_WINDOWS;
			}
		}
	}
	return 1;
}

stock static CheckHotWireInput(playerid, bool:endtick = false)
{
	if((PlayerInputHotWire[playerid][0] == 0 && PlayerInputHotWire[playerid][1] == 0) && endtick) 
	{
		// Timer & TDs
		stop HotWiringTimer[playerid];
		DestroyHotWiringTD(playerid);

		// Var sets
		PlayerInputHotWire[playerid][0] = 0;
		PlayerInputHotWire[playerid][1] = 0;

		PlayerHotWire[playerid][0] 		= 0;
		PlayerHotWire[playerid][1] 		= 0;
		PlayerHotWire[playerid][2] 		= 0;
		PlayerHotWire[playerid][3] 		= 0;
		PlayerHotWire[playerid][4] 		= 0;

		PlayerHotWiringVeh[playerid] = INVALID_VEHICLE_ID;
		Bit2_Set(gr_HotWireClicks, playerid, 	0);
		Bit1_Set(gr_PlayerHotWiring, playerid, false);

		// Player Sets
		CancelSelectTextDraw(playerid);
		return 0;
	}

	new
		vehicleid = PlayerHotWiringVeh[playerid];

	if(PlayerInputHotWire[playerid][0] == HOT_BATTERY && PlayerInputHotWire[playerid][1] == HOT_ENGINE ||
		PlayerInputHotWire[playerid][0] == HOT_ENGINE  && PlayerInputHotWire[playerid][1] == HOT_BATTERY) {
		VehicleInfo[vehicleid][vBatteryLife] 	-= 0.001;
		new
			engine, lights, alarm, doors, bonnet, boot, objective;
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		if(0.001 <= VehicleInfo[vehicleid][vBatteryLife] <= 5000.0) {
			switch(random(50)) {
				case 0 .. 25: { // NeÄ‡e se ukljuÄiti
					GameTextForPlayer(playerid, "~r~Motor nije upalio radi slabog akumulatora", 3000, 1);
					engine = VEHICLE_PARAMS_OFF;
					VehicleInfo[vehicleid][vEngineRunning] = 0;
				}
				case 26 .. 50: 
				{ // HoÄ‡e
					if(PlayerInfo[playerid][pJob] == 13)
					{
						GameTextForPlayer(playerid, "~g~Motor ukljucen, GPS lokator i alarm iskljuceni", 5000, 4);
						VehicleInfo[vehicleid][vGPS] = false;
						DisableVehicleAlarm(vehicleid);
					}
					else GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
					engine = VEHICLE_PARAMS_ON;
					VehicleInfo[vehicleid][vEngineRunning] = 1;
				}
			}
		} else { // Akumulator je u savrÅ¡enom stanju!

			if(VehicleInfo[vehicleid][vEngineLife] > 10000) {
				if(PlayerInfo[playerid][pJob] == 13)
				{
					GameTextForPlayer(playerid, "~g~Motor ukljucen, GPS lokator i alarm iskljuceni", 5000, 4);
					VehicleInfo[vehicleid][vGPS] = false;
					DisableVehicleAlarm(vehicleid);
				}
				else GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
				engine = VEHICLE_PARAMS_ON;
				VehicleInfo[vehicleid][vEngineRunning] = 1;
			}
			else if(1 <= VehicleInfo[vehicleid][vEngineLife] <= 10000)
			{
				switch(random(50)) {
					case 0 .. 25: {
						if(PlayerInfo[playerid][pJob] == 13)
						{
							GameTextForPlayer(playerid, "~g~Motor ukljucen, GPS lokator i alarm iskljuceni", 5000, 4);
							VehicleInfo[vehicleid][vGPS] = false;
							DisableVehicleAlarm(vehicleid);
						}
						else GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
						engine = VEHICLE_PARAMS_ON;
						VehicleInfo[vehicleid][vEngineRunning] = 1;
					}
					case 26 .. 50: {
						GameTextForPlayer(playerid, "~r~Motor nije upalio radi loseg motora", 3000, 1);
						engine = VEHICLE_PARAMS_OFF;
						VehicleInfo[vehicleid][vEngineRunning] = 0;
					}
				}
			}

		}
		SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	}
	else if(PlayerInputHotWire[playerid][0] == HOT_BATTERY && PlayerInputHotWire[playerid][1] == HOT_ALARM ||
		PlayerInputHotWire[playerid][0] == HOT_ALARM  && PlayerInputHotWire[playerid][1] == HOT_BATTERY)
			StartVehicleAlarm(vehicleid);
	else if(PlayerInputHotWire[playerid][0] == HOT_BATTERY && PlayerInputHotWire[playerid][1] == HOT_WINDOWS ||
		PlayerInputHotWire[playerid][0] == HOT_WINDOWS  && PlayerInputHotWire[playerid][1] == HOT_BATTERY) {
		if(IsABoat(GetVehicleModel(vehicleid)) || IsAPlane(GetVehicleModel(vehicleid)) || IsAHelio(GetVehicleModel(vehicleid)))
		{
			Bit2_Set(gr_HotWireClicks, playerid, 0);

			PlayerInputHotWire[playerid][0] = 0;
			PlayerInputHotWire[playerid][1] = 0;

			SendMessage(playerid, MESSAGE_TYPE_ERROR, " Krivi unos zica!");
			if(!endtick) return 1;
		} else {
			new
				tmpString[44];
			if(!Bit1_Get(gr_VehicleWindows, vehicleid)) {
    			Bit1_Set(gr_VehicleWindows, vehicleid, true);
				format(tmpString, sizeof(tmpString), "* %s otvara prozore.", GetName(playerid, true));
				ProxDetector(30.0, playerid, tmpString, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			} else {
		 		Bit1_Set(gr_VehicleWindows, vehicleid, false);
				format(tmpString, sizeof(tmpString), "* %s zatvara prozore.", GetName(playerid, true));
				ProxDetector(30.0, playerid, tmpString, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
			}
		}
	}
	else if(PlayerInputHotWire[playerid][0] == HOT_BATTERY && PlayerInputHotWire[playerid][1] == HOT_LIGHTS ||
		PlayerInputHotWire[playerid][0] == HOT_LIGHTS  && PlayerInputHotWire[playerid][1] == HOT_BATTERY) {
		if(IsABoat(GetVehicleModel(vehicleid)) || IsAPlane(GetVehicleModel(vehicleid)) || IsAHelio(GetVehicleModel(vehicleid)))
		{
			Bit2_Set(gr_HotWireClicks, playerid, 0);

			PlayerInputHotWire[playerid][0] = 0;
			PlayerInputHotWire[playerid][1] = 0;

			SendMessage(playerid, MESSAGE_TYPE_ERROR, " Krivi unos zica!");
			if(!endtick) return 1;
		} else {
			new
				param[4];
			GetVehicleDamageStatus(vehicleid, param[0], param[1], param[2], param[3]);
			if(!Bit1_Get(gr_VehicleLights, vehicleid)) {
				param[2] = encode_lights(0, 0, 0, 0);
				Bit1_Set(gr_VehicleLights, vehicleid, true);
			} else {
				param[2] = encode_lights(1, 1, 0, 0);
				Bit1_Set(gr_VehicleLights, vehicleid, false);
			}
			UpdateVehicleDamageStatus(vehicleid, param[0], param[1], param[2], param[3]);
		}

	} else {
		Bit2_Set(gr_HotWireClicks, playerid, 0);

		PlayerInputHotWire[playerid][0] = 0;
		PlayerInputHotWire[playerid][1] = 0;

		SendMessage(playerid, MESSAGE_TYPE_ERROR, " Krivi unos zica!");
		if(!endtick) return 1;
	}

	// Timer & TDs
	stop HotWiringTimer[playerid];
	DestroyHotWiringTD(playerid);

	// Var sets
	PlayerInputHotWire[playerid][0] = 0;
	PlayerInputHotWire[playerid][1] = 0;

	PlayerHotWire[playerid][0] 		= 0;
	PlayerHotWire[playerid][1] 		= 0;
	PlayerHotWire[playerid][2] 		= 0;
	PlayerHotWire[playerid][3] 		= 0;
	PlayerHotWire[playerid][4] 		= 0;

	PlayerHotWiringVeh[playerid] = INVALID_VEHICLE_ID;
	Bit2_Set(gr_HotWireClicks, playerid, 	0);
	Bit1_Set(gr_PlayerHotWiring, playerid, false);

	// Player Sets
	CancelSelectTextDraw(playerid);
	return 1;
}

stock GetNearestGasBiznis(playerid)
{
	new gbizid = INVALID_BIZNIS_ID;
	foreach(new bizid: Bizzes)
	{
		if(BizzInfo[bizid][bType] == BIZZ_TYPE_GASSTATION)
		{
			if(IsPlayerInRangeOfPoint(playerid, 50.0, BizzInfo[bizid][bEntranceX], BizzInfo[bizid][bEntranceY], BizzInfo[bizid][bEntranceZ]))
			{
				gbizid = bizid;
				break;
			}	
		}
	}
	return gbizid;
}

/*
	######## #### ##     ## ######## ########   ######
	   ##     ##  ###   ### ##       ##     ## ##    ##
	   ##     ##  #### #### ##       ##     ## ##
	   ##     ##  ## ### ## ######   ########   ######
	   ##     ##  ##     ## ##       ##   ##         ##
	   ##     ##  ##     ## ##       ##    ##  ##    ##
	   ##    #### ##     ## ######## ##     ##  ######
*/
///////////////////////////////////////////////////////////////////
stock VehicleTowTimer(vehicleid, playerid)
{
	if(PlayerInfo[playerid][pSpawnedCar] == -1)
		return 1;
	
	if(gettimestamp() >= PlayerTowTimer[playerid])
	{
		PlayerCarTow[playerid] = false;
		PlayerTowTimer[playerid] = 0;
		SetVehiclePos(vehicleid, VehicleInfo[vehicleid][vParkX], VehicleInfo[vehicleid][vParkY], VehicleInfo[vehicleid][vParkZ]);
		SetVehicleZAngle(vehicleid, VehicleInfo[vehicleid][vAngle]);
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Vase vozilo je dostavljeno na zeljenu lokaciju!");
	}
	return 1;
}

timer DisableVehicleAlarm[20000](vehicleid)
{
	new engine, lights, alarm, doors, bonnet, boot, objective;
	GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(vehicleid, engine, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective);

	foreach(new playerid : Player)
	{
		if(CopStreamVeh[playerid] != INVALID_VEHICLE_ID) 
		{
			CopStreamVeh[playerid] = INVALID_VEHICLE_ID;
			SetVehicleParamsForPlayer(vehicleid, playerid, VEHICLE_PARAMS_OFF, doors);
		}
	}
}

timer VehicleLightsBlink[500](vehicleid)
{
	VehicleLightsBlinker[vehicleid]--;
	new param[4];
	if(!VehicleLightsBlinker[vehicleid]) 
	{
		GetVehicleDamageStatus(vehicleid, param[0], param[1], param[2], param[3]);
		param[2] = encode_lights(0, 0, 0, 0);
		UpdateVehicleDamageStatus(vehicleid, param[0], param[1], param[2], param[3]);
		VehicleLightsBlinker[vehicleid] = 0;
		stop VehicleLightsTimer[vehicleid];
	} 
	else 
	{
		GetVehicleDamageStatus(vehicleid, param[0], param[1], param[2], param[3]);
		if(!VehicleBlinking[vehicleid])
		{
			param[2] = encode_lights(1, 1, 0, 0);
			VehicleBlinking[vehicleid] = true;
		}
		else
		{
			param[2] = encode_lights(0, 0, 1, 1);
			VehicleBlinking[vehicleid] = false;
		}
		UpdateVehicleDamageStatus(vehicleid, param[0], param[1], param[2], param[3]);
	}
}

timer PlayerHotWiring[1000](playerid)
{
	HotWiringSeconds[playerid]--;

	new gmTxt[33];
	format(gmTxt, sizeof(gmTxt),"~w~Preostalo sekundi: ~g~%d", HotWiringSeconds[playerid]);
	GameTextForPlayer(playerid, gmTxt, 1100, 4);
	PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);

	if(!HotWiringSeconds[playerid])
	{
		if(!CheckHotWireInput(playerid, true))
			GameTextForPlayer(playerid, "~r~Nisi uspio upaliti motor!", 2000, 1);
	}
	return 1;
}

timer VehicleTestTimer[1000](playerid)
{
	Bit16_Set(gr_PlayerTestSeconds, playerid, Bit16_Get(gr_PlayerTestSeconds, playerid) - 1);
	if(!Bit16_Get(gr_PlayerTestSeconds, playerid)) 
	{
		SendMessage(playerid, MESSAGE_TYPE_INFO, "Vase testiranje autmobila je zavrsilo, molimo vratite vozilo inace cete platiti punu cijenu vozila. Imate 5 minuta za vracanje vozila!");
		PlayerGiveBackCP[playerid] = 1;
		SetPlayerCheckpoint(playerid, GiveBackPos[PlayerDealer[playerid]][0],GiveBackPos[PlayerDealer[playerid]][1],GiveBackPos[PlayerDealer[playerid]][2], 10.0);
		Bit16_Set(gr_PlayerTestSeconds, playerid, 0);
		stop PlayerTestTimer[playerid];
		PlayerTestBackTimer[playerid] = defer VehicleTestBackTimer(playerid);
	}
}

task VehicleGlobalTask[1000]()
{
	if(gettimestamp() >= VehicleTimer && gettimestamp() >= GlobalVehicleStamp)
	{
		VehicleTimer = gettimestamp() + 100;
		GlobalVehicleStamp = gettimestamp() + 45;
		for(new i = 0; i < MAX_VEHICLE_TYPES; i++)
		{
			foreach(new vehicleid : Vehicles[i])
			{
				if(i == VEHICLE_USAGE_PRIVATE)
				{
					if(VehicleInfo[vehicleid][vEngineRunning]) CheckVehicleEngine(vehicleid);
					if(!IsVehicleOccupied(vehicleid))
					CheckEngineHeat(vehicleid);
					
					if(VehicleInfo[ vehicleid ][ vBodyArmor ] == 1)
					{
						new Float:Vhealth;
						GetVehicleHealth(vehicleid, Vhealth);
						if(Vhealth > 600.00)
						{
							static 
								vcpanels, 
								vcdoors, 
								vclights, 
								vctires;
							
							GetVehicleDamageStatus(vehicleid, vcpanels, vcdoors, vclights, vctires); // pripazi
							UpdateVehicleDamageStatus(vehicleid, 0, 0, 0, vctires);
						}
					}
				}
				VehicleInfo[vehicleid][vSpawned] = 0;
				VehicleInfo[vehicleid][vServerTeleport] = false;
				if(IsAHelio(GetVehicleModel(vehicleid)) || IsAPlane(GetVehicleModel(vehicleid)) || IsABike(GetVehicleModel(vehicleid)) ||
					VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_NORMAL || VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_JOB ||
					VehicleInfo[vehicleid][vUsage] ==  VEHICLE_USAGE_LICENSE) continue;
					
				if(VehicleInfo[vehicleid][vEngineRunning])
				{
					new
						Float:health;
					GetVehicleHealth(vehicleid, health);
					if(health <= 390.0) {
						if(!VehicleInfo[vehicleid][vDestroyed]) {
							new
								playerid = GetVehicleDriver(vehicleid);
								
							SendClientMessage(playerid, COLOR_RED, "Vase je vozilo unisteno, zovite mehanicara!");
							AC_SetVehicleHealth(vehicleid, 390.0);
							VehicleInfo[vehicleid][vDestroyed] = true;

							new
								engine, lights, alarm, doors, bonnet, boot, objective;
							GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
							SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
							VehicleInfo[vehicleid][vEngineRunning] = false;
						}
					}

					if(VehicleInfo[vehicleid][vFuel] > 0)
						VehicleInfo[vehicleid][vFuel]--;
					if(VehicleInfo[vehicleid][vFuel] == 0) {
						GameTextForPlayer(GetVehicleDriver(vehicleid), "~r~Ostali ste bez goriva...", 1000, 1);
						new
							engine, lights, alarm, doors, bonnet, boot, objective;

						GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
						SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

						VehicleInfo[vehicleid][vEngineRunning] = false;
					}
				}
			}
		}
		return 1;
	}
	if(gettimestamp() >= VehicleTimer)
	{
		VehicleTimer = gettimestamp() + 60;
		foreach(new vehicleid : Vehicles[VEHICLE_USAGE_PRIVATE])
		{
			if(VehicleInfo[vehicleid][vEngineRunning]) CheckVehicleEngine(vehicleid);
			if(!IsVehicleOccupied(vehicleid))
			CheckEngineHeat(vehicleid);
		}
		return 1;
	}
	if(gettimestamp() >= GlobalVehicleStamp)
	{
		GlobalVehicleStamp = gettimestamp() + 90;
		for(new i = 0; i < MAX_VEHICLE_TYPES; i++)
		{
			foreach(new vehicleid : Vehicles[i])
			{
				VehicleInfo[vehicleid][vSpawned] = 0;
				VehicleInfo[vehicleid][vServerTeleport] = false;
				if(IsAHelio(GetVehicleModel(vehicleid)) || IsAPlane(GetVehicleModel(vehicleid)) || IsABike(GetVehicleModel(vehicleid)) ||
					VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_NORMAL || VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_JOB ||
					VehicleInfo[vehicleid][vUsage] ==  VEHICLE_USAGE_LICENSE) continue;
				if(VehicleInfo[vehicleid][vEngineRunning])
				{
					new
						Float:health;
					GetVehicleHealth(vehicleid, health);
					if(health <= 390.0) {
						if(!VehicleInfo[vehicleid][vDestroyed]) {
							SendClientMessage(GetVehicleDriver(vehicleid), COLOR_RED, "Vase je vozilo unisteno, zovite mehanicara!");
							AC_SetVehicleHealth(vehicleid, 390.0);
							VehicleInfo[vehicleid][vDestroyed] = true;

							new
								engine, lights, alarm, doors, bonnet, boot, objective;
							GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
							SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
							VehicleInfo[vehicleid][vEngineRunning] = false;
						}
					}

					if(VehicleInfo[vehicleid][vFuel] > 0)
						VehicleInfo[vehicleid][vFuel]--;
					if(VehicleInfo[vehicleid][vFuel] == 0) {
						GameTextForPlayer(GetVehicleDriver(vehicleid), "~r~Ostali ste bez goriva...", 1000, 1);
						new
							engine, lights, alarm, doors, bonnet, boot, objective;

						GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
						SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);

						VehicleInfo[vehicleid][vEngineRunning] = false;
					}
				}
			}
		}
		return 1;
	}
	return 1;
}

timer VehicleTestBackTimer[CAR_GIVEBACK_MIL](playerid)
{
	if(PlayerGiveBackCP[playerid] == 1) {
		AC_DestroyVehicle(TestCar[playerid]);
		TestCar[playerid] = INVALID_VEHICLE_ID;

		SendClientMessage(playerid, COLOR_RED, "[ ! ] Niste vratili vozilo unutar 5 minuta te ste respawnani!");

		stop PlayerTestBackTimer[playerid];
		PlayerGiveBackCP[playerid] = 0;
		DisablePlayerCheckpoint(playerid);
	}
	return 1;
}

timer ParkPlayerVehicle[5000](playerid, vehicleid)
{
	ParkVehicleInfo(vehicleid);
	DestroyFarmerObjects(playerid);
	PlayerInfo[playerid][pSpawnedCar] = -1;
	TogglePlayerControllable(playerid, 1);
	SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste parkirali vozilo!");
	return 1;
}

hook OnVehicleDeath(vehicleid, killerid)
{
	RemovePlayerFromVehicle(killerid);
	
	new driverid = LastVehicleDriver[vehicleid];
	
	if(driverid == INVALID_PLAYER_ID)
		return AC_SetVehicleToRespawn(vehicleid, true); 
	
	//GetVehicleHealth(vehicleid, VehicleInfo[vehicleid][vHealth]);
	
	VehicleInfo[vehicleid][vHealth] = 254.0;
	
	if(VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_PRIVATE) 
	{
		if((PlayerInfo[driverid][pSpawnedCar] != vehicleid && PlayerInfo[killerid][pSpawnedCar] != vehicleid) || driverid != killerid)
			return AC_SetVehicleToRespawn(vehicleid, true); 
		if(PlayerInfo[killerid][pSQLID] == VehicleInfo[vehicleid][vOwnerID] && GetPlayerState(killerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(killerid) == vehicleid) 
		{
			if(PlayerInfo[killerid][pAdmin] > 0 || PlayerInfo[killerid][pHelper] > 0)
				return AC_SetVehicleToRespawn(vehicleid);
			
			VehicleInfo[vehicleid][vDestroys]++;
			VehicleInfo[vehicleid][vPanels]		= encode_panels(1, 1, 1, 1, 3, 3, 3);
			VehicleInfo[vehicleid][vDoors]		= encode_doors(4, 4, 4, 4, 0, 0);
			VehicleInfo[vehicleid][vLights]		= encode_lights(1, 1, 1, 1);

			VehicleInfo[vehicleid][vEngineLife] 	-= 1000;
			VehicleInfo[vehicleid][vBatteryLife] 	-= 100;
			VehicleInfo[vehicleid][vDestroyed] 	= true;
			
			if(VehicleInfo[vehicleid][vDestroys] >= 6)
			{
				new mod = VehicleInfo[vehicleid][vDestroys] % 6;
				if(mod == 0)
				{
					VehicleInfo[vehicleid][vInsurance] = 0;
					SendClientMessage(driverid, COLOR_RED, "[ ! ] Izgubili ste policu osiguranja nakon 6 unistenja! Iduce unistenje ce rezultirati brisanjem vozila!");
					SendClientMessage(driverid, COLOR_RED, "[ ! ] Da bi izbjegli brisanje vozila, obnovite svoju policu osiguranja (/car upgrade)");
				}
				else if(mod == 1 && VehicleInfo[vehicleid][vInsurance] == 0)
				{
					// Vehicle List Reset
					ResetVehicleList(driverid);

					// SQL
					DeleteVehicleFromBase(VehicleInfo[PlayerInfo[driverid][pSpawnedCar]][vSQLID]);
					
					// Brisanje vozila
					DestroyFarmerObjects(driverid);
					AC_DestroyVehicle(PlayerInfo[driverid][pSpawnedCar]);
					ResetVehicleInfo(PlayerInfo[driverid][pSpawnedCar]);
					PlayerInfo[driverid][pSpawnedCar] = -1;

					// List
					GetPlayerVehicleList(driverid);

					// Message
					SendClientMessage(driverid, COLOR_RED, "[ ! ] Vozilo je unisteno nakon 7 uzastopnih unistenja!");
					return 1;
				}
			}
		}
		AC_SetVehicleToRespawn(vehicleid);
		return 1;
	}
	if(TestCar[driverid] != INVALID_VEHICLE_ID && TestCar[driverid] == vehicleid)
	{
		//Timer & CP
		stop PlayerTestBackTimer[driverid];
		PlayerGiveBackCP[driverid] = 0;
		DisablePlayerCheckpoint(driverid);

		//Vehicle
		AC_DestroyVehicle(TestCar[driverid]);
		TestCar[driverid] 	= INVALID_VEHICLE_ID;

		//Pos
		SetPlayerVirtualWorld(driverid, 0);
		SetPlayerPos(driverid, DealerInfo[PlayerDealer[driverid]][flPosX], DealerInfo[PlayerDealer[driverid]][flPosY], DealerInfo[PlayerDealer[driverid]][flPosZ]);
		SetCameraBehindPlayer(driverid);

		//Preview Vars
		PreviewColor1[driverid] 	= 0;
		PreviewColor2[driverid] 	= 0;
		PreviewType[driverid]		= 0;
		CameraPos[driverid] 		= 0;
		PlayerDealer[driverid] 	= 0;

		//Money
		PlayerToBudgetMoney(driverid, 5000); // Novac od igraca ide u proracun
		//Message
		SendClientMessage(driverid, COLOR_RED, "[ ! ] Unistili ste testni primjerak, te ste platili 5.000$!");
		return 1;
	}
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
///////////////////////////////////////////////////////////////////


hook OnPlayerEnterCheckpoint(playerid)
{
	if(Bit1_Get(gr_PlayerLocateVeh, playerid)) 
	{
		DisablePlayerCheckpoint(playerid);
		GameTextForPlayer(playerid, "~g~Dosli ste do svoga vozila!", 2000, 1);
		Bit1_Set(gr_PlayerLocateVeh, playerid, false);
	}
	if(PlayerGiveBackCP[playerid] == 1)
	{
		//Timer & CP
		stop PlayerTestBackTimer[playerid];
		PlayerGiveBackCP[playerid] = 0;
		DisablePlayerCheckpoint(playerid);

		//Vehicle
		AC_DestroyVehicle(TestCar[playerid]);
		TestCar[playerid] 	= INVALID_VEHICLE_ID;

		//Pos
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerPos(playerid, DealerInfo[PlayerDealer[playerid]][flPosX], DealerInfo[PlayerDealer[playerid]][flPosY], DealerInfo[PlayerDealer[playerid]][flPosZ]);

		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);

		//Preview Vars
		PreviewColor1[playerid] = 0;
		PreviewColor2[playerid] = 0;
		PreviewType[playerid]	= 0;
		CameraPos[playerid] 	= 0;
		PlayerDealer[playerid] 	= 0;
		Bit1_Set(gr_PlayerTestingCar, playerid, false);
		return 1;
	}
	if(PlayerParkLocation[playerid] == 1)
	{
		DisablePlayerCheckpoint(playerid);
		GameTextForPlayer(playerid, "~g~odrediste", 2000, 1);
		PlayerParkLocation[playerid] = 0;
		return 1;
	}
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT) 
	{
		if(Bit1_Get(gr_PlayerTestingCar, playerid)) 
		{
			stop PlayerTestTimer[playerid];
			stop PlayerTestBackTimer[playerid];
			PlayerGiveBackCP[playerid] = 0;
			DisablePlayerCheckpoint(playerid);

			//Vehicle
			AC_DestroyVehicle(TestCar[playerid]);
			TestCar[playerid] 	= INVALID_VEHICLE_ID;

			//Pos
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, DealerInfo[PlayerDealer[playerid]][flPosX], DealerInfo[PlayerDealer[playerid]][flPosY], DealerInfo[PlayerDealer[playerid]][flPosZ]);
			SetCameraBehindPlayer(playerid);

			//Preview Vars
			PreviewColor1[playerid] = 0;
			PreviewColor2[playerid] = 0;
			PreviewType[playerid]	= 0;
			CameraPos[playerid] 	= 0;
			PlayerDealer[playerid] 	= 0;

			Bit1_Set(gr_PlayerTestingCar, playerid, false);
			SendClientMessage(playerid, COLOR_RED, "[ ! ] Izasli ste iz vozila dok ste ga testirali, te ste vraceni u salon!");
		}
		else if(Bit1_Get(gr_PlayerHotWiring, playerid)) 
		{
			if(PlayerHotWiringVeh[playerid] != INVALID_VEHICLE_ID && !IsPlayerInVehicle(playerid, PlayerHotWiringVeh[playerid])) {
				// Timer & TDs
				stop HotWiringTimer[playerid];
				DestroyHotWiringTD(playerid);

				// Var sets
				PlayerInputHotWire[playerid][0] = 0;
				PlayerInputHotWire[playerid][1] = 0;

				PlayerHotWire[playerid][0] 		= 0;
				PlayerHotWire[playerid][1] 		= 0;
				PlayerHotWire[playerid][2] 		= 0;
				PlayerHotWire[playerid][3] 		= 0;
				PlayerHotWire[playerid][4] 		= 0;

				PlayerHotWiringVeh[playerid] = INVALID_VEHICLE_ID;
				CancelSelectTextDraw(playerid);
				SendMessage(playerid, MESSAGE_TYPE_ERROR, " Izasli ste iz vozila!");
			}
		}
	}
	if (oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER) 
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(vehicleid == PlayerInfo[playerid][pSpawnedCar])
			CheckVehicleTickets(playerid, vehicleid);
		if(VehicleInfo[GetPlayerVehicleID(playerid)][vUsage] == VEHICLE_USAGE_PRIVATE && VehicleInfo[GetPlayerVehicleID(playerid)][vImpounded])
			SendClientMessage(playerid, COLOR_RED, "[ ! ] Vozilo je impoundano, morate platiti 1.000$ da biste mogli voziti ovo vozilo! Koristite /payimpound.");
	}
    return 1;
}

hook OnPlayerUpdate(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleTravel(GetPlayerVehicleID(playerid));
	}
    return 1;
}

hook OnPlayerConnect(playerid)
{
	ResetCarOwnershipVariables(playerid);
	return 1;
}

hook OnVehicleStreamIn(vehicleid, forplayerid)
{
	if(CopStreamVeh[forplayerid] == vehicleid && (PlayerInfo[forplayerid][pMember] == 1 || PlayerInfo[forplayerid][pLeader] == 1))
		SetVehicleParamsForPlayer(vehicleid, forplayerid, 1, 0);
    return 1;
}

hook OnVehicleStreamOut(vehicleid, forplayerid)
{
	if(CopStreamVeh[forplayerid] == vehicleid && (PlayerInfo[forplayerid][pMember] == 1 || PlayerInfo[forplayerid][pLeader] == 1))
		SetVehicleParamsForPlayer(vehicleid, forplayerid, 0, 0);
    return 1;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid != PlayerText:INVALID_TEXT_DRAW)
	{
		if(playertextid == DenyButton[playerid]) {
			DestroyPreviewScene(playerid);
			CancelSelectTextDraw(playerid);
		}
		if(playertextid == CarLeft[playerid]) {
			PreviouseVehicle(playerid);
		}
		if(playertextid == CarRight[playerid]) {
			NextVehicle(playerid);
		}
		if(playertextid == Color1Left[playerid]) {
			PrevVehColor(playerid, 1);
		}
		if(playertextid == Color1Right[playerid]) {
			NextVehColor(playerid, 1);
		}
		if(playertextid == Color2Left[playerid]) {
			PrevVehColor(playerid, 2);
		}
		if(playertextid == Color2Right[playerid]) {
			NextVehColor(playerid, 2);
		}
		if(playertextid == CameraRight[playerid]) {
			NextShopCamera(playerid);
		}
		if(playertextid == CameraLeft[playerid]) {
			LastShopCamera(playerid);
		}
		if(playertextid == BuyButton[playerid]) {
			new buyprice = 0;
			switch(PlayerDealer[playerid]) 
			{
				case VEH_DEALER_CARS:
				{
					if(CalculatePlayerBuyMoney(playerid, BUY_TYPE_VEHICLE) < LandVehicles[PreviewType[playerid]][viPrice]) 
						return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemas dovoljno novca za kupovinu ovog vozila!");
					buyprice = LandVehicles[PreviewType[playerid]][viPrice];
				}
				case VEH_DEALER_BOAT:
				{
					if(CalculatePlayerBuyMoney(playerid, BUY_TYPE_VEHICLE) < SeaVehicles[PreviewType[playerid]][viPrice]) 
						return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemas dovoljno novca za kupovinu ovog vozila!");
					buyprice = SeaVehicles[PreviewType[playerid]][viPrice];
				}
				case VEH_DEALER_PLANE:
				{
					if(PlayerInfo[playerid][pDonateRank] == 4 && AirVehicles[PreviewType[playerid]][viModelid] == 469) // Premium Diamond Sparrow
					{
						if(CalculatePlayerBuyMoney(playerid, BUY_TYPE_VEHICLE) < (AirVehicles[PreviewType[playerid]][viPrice]/2)) 
							return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Diamond VIP pokriva samo polovinu vrijednosti ovog vozila!");
					}
					else
					{
						if(CalculatePlayerBuyMoney(playerid, BUY_TYPE_VEHICLE) < AirVehicles[PreviewType[playerid]][viPrice]) 
							return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemas dovoljno novca za kupovinu ovog vozila!");
					}
					buyprice = AirVehicles[PreviewType[playerid]][viPrice];
				}
			}
			if(LandVehicles[PreviewType[playerid]][viPremium] == 1 && PlayerInfo[playerid][pDonateRank] != 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Bronze korisnik!");
			if(LandVehicles[PreviewType[playerid]][viPremium] == 2 && PlayerInfo[playerid][pDonateRank] != 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Silver korisnik!");
			if(LandVehicles[PreviewType[playerid]][viPremium] == 3 && PlayerInfo[playerid][pDonateRank] != 3) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Gold korisnik!");
			if(LandVehicles[PreviewType[playerid]][viPremium] == 4 && PlayerInfo[playerid][pDonateRank] != 4) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Platinum korisnik!");

			if(LandVehicles[PreviewType[playerid]][viPremium] && PlayerInfo[playerid][pDonatorVehPerms] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nije vam ostalo vise mjesta za donator vozila");

			Bit1_Set(gr_PreviewCar, playerid, false);
			paymentBuyPrice[playerid] = buyprice;
			GetPlayerPaymentOption(playerid, BUY_TYPE_VEHICLE);
			CancelSelectTextDraw(playerid);
		}
		if(playertextid == TryButton[playerid]) {
			switch(PlayerDealer[playerid]) {
				case VEH_DEALER_CARS: {
					if(AC_GetPlayerMoney(playerid) < LandVehicles[PreviewType[playerid]][viPrice]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Moras imati dovoljno novca da bi testirao ovo auto!");
					if(LandVehicles[PreviewType[playerid]][viPremium] == 1 && PlayerInfo[playerid][pDonateRank] != 1 && PlayerInfo[playerid][pDonatorVehPerms] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Bronze korisnik!");
					if(LandVehicles[PreviewType[playerid]][viPremium] == 2 && PlayerInfo[playerid][pDonateRank] != 2 && PlayerInfo[playerid][pDonatorVehPerms] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Silver korisnik!");
					if(LandVehicles[PreviewType[playerid]][viPremium] == 3 && PlayerInfo[playerid][pDonateRank] != 3 && PlayerInfo[playerid][pDonatorVehPerms] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Gold korisnik!");
					if(LandVehicles[PreviewType[playerid]][viPremium] == 4 && PlayerInfo[playerid][pDonateRank] != 4 && PlayerInfo[playerid][pDonatorVehPerms] == 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste VIP Platinum korisnik!");
				}
				case VEH_DEALER_BOAT: {
					if(AC_GetPlayerMoney(playerid) < SeaVehicles[PreviewType[playerid]][viPrice]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Moras imati dovoljno novca da bi testirao ovo auto!");
				}
				case VEH_DEALER_PLANE: {
					if(AC_GetPlayerMoney(playerid) < AirVehicles[PreviewType[playerid]][viPrice]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Moras imati dovoljno novca da bi testirao ovo auto!");
				}
			}
			Bit1_Set(gr_PreviewCar, playerid, false);
			CreateTestCar(playerid);
			CancelSelectTextDraw(playerid);
		}
		if(playertextid == HotWireRed[playerid])	{
			Bit2_Set(gr_HotWireClicks, playerid, Bit2_Get(gr_HotWireClicks, playerid) + 1);
			SetPlayerHotWireInput(playerid, 1, (Bit2_Get(gr_HotWireClicks, playerid) - 1));
			if(Bit2_Get(gr_HotWireClicks, playerid) == 2) CheckHotWireInput(playerid, false);
		}
		if(playertextid == HotWireBlue[playerid])	{
			Bit2_Set(gr_HotWireClicks, playerid, Bit2_Get(gr_HotWireClicks, playerid) + 1);
			SetPlayerHotWireInput(playerid, 2, (Bit2_Get(gr_HotWireClicks, playerid) - 1));
			if(Bit2_Get(gr_HotWireClicks, playerid) == 2) CheckHotWireInput(playerid, false);
		}
		if(playertextid == HotWireYell[playerid])	{
			Bit2_Set(gr_HotWireClicks, playerid, Bit2_Get(gr_HotWireClicks, playerid) + 1);
			SetPlayerHotWireInput(playerid, 3, (Bit2_Get(gr_HotWireClicks, playerid) - 1));
			if(Bit2_Get(gr_HotWireClicks, playerid) == 2) CheckHotWireInput(playerid, false);
		}
		if(playertextid == HotWireBrown[playerid]) {
			Bit2_Set(gr_HotWireClicks, playerid, Bit2_Get(gr_HotWireClicks, playerid) + 1);
			SetPlayerHotWireInput(playerid, 4, (Bit2_Get(gr_HotWireClicks, playerid) - 1));
			if(Bit2_Get(gr_HotWireClicks, playerid) == 2) CheckHotWireInput(playerid, false);
		}
		if(playertextid == HotWireBlack[playerid]) {
			Bit2_Set(gr_HotWireClicks, playerid, Bit2_Get(gr_HotWireClicks, playerid) + 1);
			SetPlayerHotWireInput(playerid, 5, (Bit2_Get(gr_HotWireClicks, playerid) - 1));
			if(Bit2_Get(gr_HotWireClicks, playerid) == 2) CheckHotWireInput(playerid, false);
		}
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_FIRE))
	{
		if(Bit2_Get(gr_PlayerLockBreaking, playerid) == 2)
		{
			if(BreakLockKickTick[playerid] < gettimestamp()) {
				new vehicleid = BreakLockVehicleID[playerid];
				if(!IsPlayerNearDoor(playerid, vehicleid)) return 1;

				switch(AC_GetPlayerWeapon(playerid))
				{
					case 0: {
						switch(GetPlayerAnimationIndex(playerid)) {
							case 504, 505, 473, 474, 483, 484, 494, 495, 1136, 1137, 1138, 1165:
								VehicleInfo[vehicleid][vDoorHealth] -= (3.2 + ((PlayerInfo[playerid][pMuscle] / 50) * 2.36));
						}
					}
					case 1 .. 14: {
						switch(GetPlayerAnimationIndex(playerid)) {
							case 17, 18, 19, 312, 313, 314, 473, 474, 483, 484, 494, 495, 423, 424, 425, 504, 505, 533, 749, 750, 751, 1136, 1137, 1138, 1165, 1545, 1546, 1547 :
								VehicleInfo[vehicleid][vDoorHealth] -= (16.0 + ((PlayerInfo[playerid][pMuscle] / 50) * 2.36));
						}
					}
				}

				CheckVehicleDoorHealth(playerid, vehicleid);

				new dTxt[35];
				format(dTxt, 35, "Door HP: {00CCCC}%.1f", VehicleInfo[vehicleid][vDoorHealth]);
				UpdateDynamic3DTextLabelText(DoorHealth3DText[vehicleid], 0xFFFFFFFF, dTxt);

				BreakLockKickTick[playerid] = gettimestamp();
			}
		}
		if(Bit1_Get(gr_PlayerBreakingTrunk, playerid))
		{
			if(BreakTrunkKickTick[playerid] < gettimestamp()) {
				new vehicleid = BreakTrunkVehicleID[playerid];
				if(!IsPlayerNearTrunk(playerid, vehicleid)) 
					return 1;

				switch(AC_GetPlayerWeapon(playerid))
				{
					case 0: {
						switch(GetPlayerAnimationIndex(playerid)) {
							case 504, 505, 473, 474, 483, 484, 494, 495, 1136, 1137, 1138, 1165:
								VehicleInfo[vehicleid][vTrunkHealth] -= (3.2 + ((PlayerInfo[playerid][pMuscle] / 50) * 1));
						}
					}
					case 1 .. 14: {
						switch(GetPlayerAnimationIndex(playerid)) {
							case 17, 18, 19, 312, 313, 314, 473, 474, 483, 484, 494, 495, 423, 424, 425, 504, 505, 533, 749, 750, 751, 1136, 1137, 1138, 1165, 1545, 1546, 1547 :
								VehicleInfo[vehicleid][vTrunkHealth] -= (16.0 + ((PlayerInfo[playerid][pMuscle] / 50) * 1));
						}
					}
				}

				CheckVehicleTrunkHealth(playerid, vehicleid);

				new dTxt[35];
				format(dTxt, 35, "Trunk HP: {00CCCC}%.1f", VehicleInfo[vehicleid][vTrunkHealth]);
				UpdateDynamic3DTextLabelText(TrunkHealth3DText[vehicleid], 0xFFFFFFFF, dTxt);

				BreakTrunkKickTick[playerid] = gettimestamp();
			}
		}
	}
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_VEH_GET:
		{
			if(!response) return 1;
			if(VehicleInfoSQLID[playerid][listitem] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate automobil pohranjen u tome slotu!");
			SpawnVehicleInfo(playerid, VehicleInfoSQLID[playerid][listitem]);
			new model = GetVehicleByModel(VehicleInfoModel[playerid][listitem]);
			SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste spawnali vas %s!", LandVehicles[model][viName]);
			return 1;
		}
		case DIALOG_VEH_UPGRADE: {
			if(!response) return 1;
			switch(listitem)
			{
				case 0: //Osiguranje
				{
					new
						policytxt[25];
					format(policytxt, 25, "Trenutna polica: Level %d", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance]);
					ShowPlayerDialog(playerid, DIALOG_VEH_INSURANCE, DIALOG_STYLE_LIST, policytxt, "Polica level 1\nPolica level 2\nPolica 3", "Choose", "Abort");
				}
				case 1: // Akumulator
				{
					ShowPlayerDialog(playerid, DIALOG_VEH_BATTERY, DIALOG_STYLE_LIST, "ODABIR AKUMULATORA", "Cyclone (4.000$)\nVartio Original (7.000$)\nBoche (10.000$)", "Choose", "Abort");
				}
				case 2: // Brava
				{
					ShowPlayerDialog(playerid, DIALOG_VEH_LOCK, DIALOG_STYLE_LIST, "ODABIR LEVELA BRAVE", "Level 1 (2.000$)\nLevel 2 (5.000$)\nLevel 3 (8.000$)", "Choose", "Abort");
				}
				case 3: // Immob
				{
					ShowPlayerDialog(playerid, DIALOG_VEH_IMMOB, DIALOG_STYLE_LIST, "ODABIR LEVELA IMMOBILIZATORA", "Level 1 (3.000$)\nLevel 2 (6.000$)\nLevel 3 (9.000$)\nLevel 4 (12.000$)\nLevel 5 (15.000$)", "Choose", "Abort");
				}
				case 4: // Audio
				{
					if(AC_GetPlayerMoney(playerid) < 1000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 1.000$!");
					PlayerToBudgetMoney(playerid, 1000); // Novac ide u proracun od igraca
					SendClientMessage(playerid, COLOR_RED, "[ ! ] Kupili ste audio sistem!");
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAudio] = 1;

					// Query
					new
						tmpQuery[128];
					format(tmpQuery, 128, "UPDATE `cocars` SET `audio` = '%d' WHERE `id` = '%d'",
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAudio],
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]
					);
					mysql_tquery(g_SQL, tmpQuery);

					PlayerPlaySound(playerid, 1133, 0, 0, 0);
				}
				case 5: // Alarm
					ShowPlayerDialog(playerid, DIALOG_VEH_ALARM, DIALOG_STYLE_LIST, "ODABIR ALARMA", "Keeper (1.000$)\nWatcher (3.000$)\nDefender (6.000$)\nCenturion(9.000$)", "Choose", "Abort");
				case 6: // Brava
				{
					if(AC_GetPlayerMoney(playerid) < 2000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 2.000$!");
					PlayerToBudgetMoney(playerid, 2000); // Novac ide u proracun od igraca
					new
						dkeyquery[138];
					format(dkeyquery, sizeof(dkeyquery), "UPDATE `cocars` SET `sparekey1` = '-1', `sparekey2` = '-1' WHERE `id` = '%d'", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
					mysql_tquery(g_SQL, dkeyquery);
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSpareKey1] = -1;
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSpareKey2] = -1;
					SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste zamjenili bravu, te su svi duplicirani kljucevi beskorisni.");
				}
				
			}
		}
		case DIALOG_VEH_IMMOB: {
			if(!response) return 1;
			switch(listitem) {
				case 0: {
					if(AC_GetPlayerMoney(playerid) < 3000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 3.000$!");
					PlayerToBudgetMoney(playerid, 3000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob] = 1;
				}
				case 1: {
					if(AC_GetPlayerMoney(playerid) < 6000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 6.000$!");
					PlayerToBudgetMoney(playerid, 6000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob] = 2;
				}
				case 2: {
					if(AC_GetPlayerMoney(playerid) < 9000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 9.000$!");
					PlayerToBudgetMoney(playerid, 9000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob] = 3;
				}
				case 3: {
					if(AC_GetPlayerMoney(playerid) < 12000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 12.000$!");
					PlayerToBudgetMoney(playerid, 12000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob] = 4;
				}
				case 4: {
					if(AC_GetPlayerMoney(playerid) < 15000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 15.000$!");
					PlayerToBudgetMoney(playerid, 15000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob] = 5;
				}
			}

			// Query
			new
				tmpQuery[54];
			format(tmpQuery, 54, "UPDATE `cocars` SET `immob` = '%d' WHERE `id` = '%d'",
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob],
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
			mysql_tquery(g_SQL, tmpQuery);

			// Message
			new
				tmpString[51];
			format(tmpString, 51, "[ ! ] Unaprijedili ste immobilizator na level %d!", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob]);
			SendClientMessage(playerid, COLOR_RED, tmpString);
		}
		case DIALOG_VEH_INSURANCE: {
			if(!response) return 1;
			new
				poliString[43];
			if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vDestroys] < 10) {
				switch(listitem) {
					case 0: {
						if(AC_GetPlayerMoney(playerid) < 2500) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 2.500$!");
						PlayerToBudgetMoney(playerid, 2500); // Novac ide u proracun od igraca
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] = 1;
					}
					case 1: {
						if(AC_GetPlayerMoney(playerid) < 5000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 5.000$!");
						PlayerToBudgetMoney(playerid, 5000); // Novac ide u proracun od igraca
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] = 2;
					}
					case 2: {
						if(AC_GetPlayerMoney(playerid) < 7500) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 7.500$!");
						PlayerToBudgetMoney(playerid, 7500); // Novac ide u proracun od igraca
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] = 3;
					}
				}
			} else {
				switch(listitem) {
					case 0: {
						if(AC_GetPlayerMoney(playerid) < 10000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 10.000$!");
						PlayerToBudgetMoney(playerid, 10000); // Novac ide u proracun od igraca
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] = 1;
					}
					case 1: {
						if(AC_GetPlayerMoney(playerid) < 20000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 20.000$!");
						PlayerToBudgetMoney(playerid, 20000); // Novac ide u proracun od igraca
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] = 2;
					}
					case 2: {
						if(AC_GetPlayerMoney(playerid) < 30000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 30.000$!");
						PlayerToBudgetMoney(playerid, 30000); // Novac ide u proracun od igraca
						VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] = 3;
					}
				}
			}

			// Query
			new
				tmpQuery[128];
			format(tmpQuery, 128, "UPDATE `cocars` SET `insurance` = '%d' WHERE `id` = '%d'",
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance],
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]
			);
			mysql_tquery(g_SQL, tmpQuery);

			// Message
			format(poliString, 43, "[ ! ] Nova polica osiguranja je Level %d!", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance]);
			SendClientMessage(playerid, COLOR_RED, poliString);
		}
		case DIALOG_VEH_ALARM: {
			if(!response) return 1;
			switch(listitem) {
				case 0: {
					if(AC_GetPlayerMoney(playerid) < 1000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 1.000$!");
					PlayerToBudgetMoney(playerid, 1000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm] = 1;
				}
				case 1: {
					if(AC_GetPlayerMoney(playerid) < 3000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 3.000$!");
					PlayerToBudgetMoney(playerid, 3000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm] = 2;
				}
				case 2: {
					if(AC_GetPlayerMoney(playerid) < 6000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 6.000$!");
					PlayerToBudgetMoney(playerid, 6000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm] = 3;
				}
				case 3: {
					if(AC_GetPlayerMoney(playerid) < 9000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 9.000$!");
					PlayerToBudgetMoney(playerid, 9000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm] = 4;
				}
			}

			// Query
			new
				tmpQuery[128];
			format(tmpQuery, 128, "UPDATE `cocars` SET `alarm` = '%d' WHERE `id` = '%d'",
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm],
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]
			);
			mysql_tquery(g_SQL, tmpQuery);

			// Message
			SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Novi level alarma je %d!", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm]);
		}
		case DIALOG_VEH_BATTERY: {
			if(!response) return 1;

			switch(listitem) {
				case 0: {
					if(AC_GetPlayerMoney(playerid) < 4000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 4.000$!");
					PlayerToBudgetMoney(playerid, 4000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryType] = BATTERY_TYPE_CYCLONE;
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryLife] = BATTERY_LIFE_CYCLONE;
				}
				case 1: {
					if(AC_GetPlayerMoney(playerid) < 7000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 7.000$!");
					PlayerToBudgetMoney(playerid, 7000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryType] = BATTERY_TYPE_VARTIO;
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryLife] = BATTERY_LIFE_VARTIO;
				}
				case 2: {
					if(AC_GetPlayerMoney(playerid) < 10000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 10.000$!");
					PlayerToBudgetMoney(playerid, 10000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryType] = BATTERY_TYPE_BOCHE;
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryLife] = BATTERY_LIFE_BOCHE;
				}
			}

			// Query
			new
				tmpQuery[90];
			format(tmpQuery, 90, "UPDATE `cocars` SET `batterylife` = '%d' WHERE `id` = '%d'",
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryLife],
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
			mysql_tquery(g_SQL, tmpQuery);

			// Message
			new
				tmpString[76];
			format(tmpString, sizeof(tmpString), "[ ! ] Zivotni vijek trajanja akumulatora je poboljsan na %d minuta!", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryLife]);
			SendClientMessage(playerid, COLOR_RED, tmpString);
		}
		case DIALOG_VEH_LOCK: {
			if(!response) return 1;

			switch(listitem) {
				case 0: {
					if(AC_GetPlayerMoney(playerid) < 2000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 2.000$!");
					PlayerToBudgetMoney(playerid, 2000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock] = 1;
				}
				case 1: {
					if(AC_GetPlayerMoney(playerid) < 5000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 5.000$!");
					PlayerToBudgetMoney(playerid, 5000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock] = 2;
				}
				case 2: {
					if(AC_GetPlayerMoney(playerid) < 8000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 8.000$!");
					PlayerToBudgetMoney(playerid, 8000); // Novac ide u proracun od igraca
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock] = 3;
				}
			}

			// Query
			new
				tmpQuery[90];
			format(tmpQuery, 90, "UPDATE `cocars` SET `lock` = '%d' WHERE `id` = '%d'",
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock],
				VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
			mysql_tquery(g_SQL, tmpQuery);

			// Message
			new
				tmpString[45];
			format(tmpString, sizeof(tmpString), "[ ! ] Vasa brava je poboljsana na level %d!", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock]);
			SendClientMessage(playerid, COLOR_RED, tmpString);
		}
		case DIALOG_VEH_TAKEGUN: 
		{
			if(!response)
			{
				ResetPlayerWeaponList(playerid);
				return 1;
			}
			new 
				vehicleid = GetNearestVehicle(playerid, VEHICLE_USAGE_PRIVATE),
				wslot = WeaponToList[playerid][listitem];
				
			if(VehicleInfo[vehicleid][vTrunk] == VEHICLE_PARAMS_OFF) 
				return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Prtljaznik je zatvoren!");
			
			TakePlayerWeaponFromTrunk(playerid, vehicleid, wslot);
		}
		case DIALOG_VEH_DELETE: 
		{
			if(!response) return 1;
			
			// Vehicle List Reset
			ResetVehicleList(playerid);

			DeleteVehicleTuning(PlayerInfo[playerid][pSpawnedCar]);
			ResetTuning(PlayerInfo[playerid][pSpawnedCar]);
			DeleteVehicleDrug(PlayerInfo[playerid][pSpawnedCar], -1);
			
			// SQL
			DeleteVehicleFromBase(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);

			#if defined MODULE_LOGS
			Log_Write("/logfiles/car_delete.txt", "(%s) %s deleted his %s from database.",
				ReturnDate(),
				GetName(playerid,false),
				ReturnVehicleName(GetVehicleModel(PlayerInfo[playerid][pSpawnedCar]))
			);
			#endif

			// Brisanje vozila
			DestroyFarmerObjects(playerid);
			AC_DestroyVehicle(PlayerInfo[playerid][pSpawnedCar]);
			ResetVehicleInfo(PlayerInfo[playerid][pSpawnedCar]);

			PlayerInfo[playerid][pSpawnedCar] = -1;

			// List
			GetPlayerVehicleList(playerid);

			// Message
			SendClientMessage(playerid, COLOR_RED, "[ ! ] Uspjesno ste obrisali vozilo iz databaze!");
		}
		case DIALOG_VEH_COLORS:
			return 1;
		case DIALOG_VEH_SELLING: {
			if(!response) {
				SendClientMessage(playerid, COLOR_RED, "[ ! ] Odustali ste od kupovine vozila!");
				PlayerCarSeller[playerid] 	= INVALID_PLAYER_ID;
				PlayerSellingPrice[playerid] 	= 0;
				return 1;
			}
			if(!CheckVehicleList(playerid))
				return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Svi slotovi za vozila su vam popunjeni!");

			new
				sellerid 	= PlayerCarSeller[playerid],
				sellVehid 	= PlayerInfo[sellerid][pSpawnedCar];

			if(sellerid == INVALID_PLAYER_ID) {
				SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nitko vam nije ponudio prodaju vozila!");
				PlayerCarSeller[playerid] = INVALID_PLAYER_ID;
				return 1;
			}
			if(!IsPlayerConnected(sellerid)) {
				SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ponuditelj prodaje vozila nije online!");
				PlayerCarSeller[playerid] = INVALID_PLAYER_ID;
				return 1;
			}
			if(AC_GetPlayerMoney(playerid) < PlayerSellingPrice[playerid]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate toliko novca!");
			PlayerInfo[sellerid][pSpawnedCar] = -1;

			// Vehicle List Reset
			ResetVehicleList(playerid);
			ResetVehicleList(sellerid);
			
			// Vehicleid
			PlayerInfo[playerid][pSpawnedCar] 	= sellVehid;
			
			new sellprice = PlayerSellingPrice[playerid];
			PlayerToPlayerMoneyTAX (playerid, sellerid, sellprice, true, LOG_TYPE_VEHICLESELL);

			#if defined MODULE_LOGS
			Log_Write("logfiles/car_carsell.txt", "(%s) %s{%d} sold %s{%d} %s[SQLID: %d] for %d$.",
				ReturnDate(),
				GetName(sellerid, false),
				PlayerInfo[sellerid][pSQLID],
				GetName(playerid, false),
				PlayerInfo[playerid][pSQLID],
				ReturnVehicleName(GetVehicleModel(sellVehid)),
				VehicleInfo[sellVehid][vSQLID],
				PlayerSellingPrice[playerid]
			);
			#endif
			
			PlayerSellingPrice[playerid] 	= 0;
			PlayerCarSeller[playerid]		= -1;

			SendClientMessage(playerid, COLOR_RED, "[ ! ] Uspjesno ste kupili vozilo, odmah kupite parking!");
			SendClientMessage(sellerid, COLOR_RED, "[ ! ] Uspjesno ste prodali vozilo!");

			// SQL
			new
				tmpQuery[256];
			format(tmpQuery, 256, "UPDATE `cocars` SET `ownerid` = '%d' WHERE `id` = '%d'",
				PlayerInfo[playerid][pSQLID],
				VehicleInfo[sellVehid][vSQLID]
			);
			mysql_tquery(g_SQL, tmpQuery);
			VehicleInfo[sellVehid][vOwnerID] 	= PlayerInfo[playerid][pSQLID];
			PlayerInfo[sellerid][pSpawnedCar] 	= -1;
			#if defined MOD_DEBUG
			    printf("[COCARS DEBUG]: ids(s:%d, b:%d) | sql(s:%d, b:%d) | vehicleid(%d)",
					sellerid,
					playerid,
					PlayerInfo[sellerid][pSQLID],
					PlayerInfo[playerid][pSQLID],
					sellVehid
				);
				printf("[COCARS DEBUG]: query(%s)", tmpQuery);
			#endif

			GetPlayerVehicleList(playerid);
			GetPlayerVehicleList(sellerid);
			
			
			return 1;
		}
		case DIALOG_VEH_JUNK_SELL:
		{
			if(!response) return 1;
			new vehicleid = GetPlayerVehicleID(playerid),
				moneys = CalculateVehiclePrice(vehicleid, 1);
			
			if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vase vozilo nije CO!");
			if(PlayerInfo[playerid][pSpawnedCar] != vehicleid) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate se nalaziti u svome CO-u!");

			if(IsPlayerInRangeOfPoint(playerid, 100.0, DealerInfo[1][flPosX], DealerInfo[1][flPosY], DealerInfo[1][flPosZ])) moneys = CalculateVehiclePrice(vehicleid, 2);
			else if(IsPlayerInRangeOfPoint(playerid, 100.0, DealerInfo[2][flPosX], DealerInfo[2][flPosY], DealerInfo[2][flPosZ])) moneys = CalculateVehiclePrice(vehicleid, 3);
			
			// Give Money
			BudgetToPlayerMoney(playerid, moneys); // Igrac dobiva novac iz budgeta za vozilo
			SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste prodali svoje vozilo za %d$!", moneys);
						
			#if defined MODULE_LOGS
			Log_Write("logfiles/car_junk_sell.txt", "(%s) %s[%d] sold %s for %d$ on Junkyard.",
				ReturnDate(),
				GetName(playerid, false),
				PlayerInfo[playerid][pSQLID],
				ReturnVehicleName(GetVehicleModel(vehicleid)),
				moneys
			);
			#endif
			
			// Vehicle List Reset
			ResetVehicleList(playerid);

			DeleteVehicleTuning(PlayerInfo[playerid][pSpawnedCar]);
			ResetTuning(PlayerInfo[playerid][pSpawnedCar]); 
			
			// SQL
			DeleteVehicleFromBase(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
			
			// Brisanje vozila
			DestroyFarmerObjects(playerid);
			AC_DestroyVehicle(PlayerInfo[playerid][pSpawnedCar]);
			ResetVehicleInfo(PlayerInfo[playerid][pSpawnedCar]);

			PlayerInfo[playerid][pSpawnedCar] = -1;
			
			// List
			GetPlayerVehicleList(playerid);
			return 1;
		}
	}
    return 0;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(Bit1_Get(gr_PlayerBreakingTrunk, playerid)) {
		BreakTrunkVehicleID[playerid] 	= INVALID_VEHICLE_ID;
		BreakTrunkKickTick[playerid]		= gettimestamp();
		Bit1_Set(gr_PlayerBreakingTrunk, playerid, false);
	}
	if( Bit2_Get(gr_PlayerLockBreaking, playerid) == 2 ) {
		BreakLockVehicleID[playerid] 	= INVALID_VEHICLE_ID;
		BreakLockKickTick[playerid]		= gettimestamp();
		Bit2_Set(gr_PlayerLockBreaking, playerid, 0);
	}

	EditingTrunkWeaponObject[playerid] = 0;
	EditingTrunkWeaponModel[playerid] = 0;
	
	PlayerParkLocation[playerid] = 0;
	DisablePlayerCheckpoint(playerid);
	ResetCarBuyVars(playerid);
	return 1;
}

hook OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	if(Bit1_Get(gr_PlayerTrunkEdit, playerid))
	{
		switch(response)
		{
			case 0:
			{
				CancelEdit(playerid);
				SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nazalost, niste uspjesno spremili lokaciju oruzja. Pokusajte ponovno!");
				EditPlayerObject(playerid, EditingTrunkWeaponObject[playerid]);
			}
			case 1:
			{
					
				Bit1_Set(gr_PlayerTrunkEdit, playerid, false);
				new model = EditingTrunkWeaponModel[playerid],
					wslot = Bit4_Get(gr_WeaponTrunkEditSlot, playerid),
					AttachVehID = INVALID_VEHICLE_ID;
					
				AttachVehID = GetNearestVehicle(playerid, VEHICLE_USAGE_PRIVATE);
				if(AttachVehID != INVALID_VEHICLE_ID)
				{	
					if(VehicleInfo[AttachVehID][vWeaponSQLID][wslot] <= 0) // 0, -1, ..
					{
						CancelEdit(playerid);
						SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nazalost, dogodila se greska u pohrani lokacije oruzja. Pokusajte ponovno!");
						EditPlayerObject(playerid, EditingTrunkWeaponObject[playerid]);
						return 1;
					}
					new	Float:ofx, Float:ofy, Float:ofz, Float:ofaz,
						Float:finalx, Float:finaly,
						Float:px, Float:py, Float:pz, Float:roz;
						
					GetVehiclePos(PlayerInfo[playerid][pSpawnedCar], px, py, pz);
					GetVehicleZAngle(PlayerInfo[playerid][pSpawnedCar], roz);
					ofx = fX-px;
					ofy = fY-py;
					ofz = fZ-pz;
					ofaz = fRotZ-roz;
					finalx = ofx*floatcos(roz, degrees)+ofy*floatsin(roz, degrees);
					finaly = -ofx*floatsin(roz, degrees)+ofy*floatcos(roz, degrees);
					
					VehicleInfo[AttachVehID][vOffsetx][wslot] = finalx;
					VehicleInfo[AttachVehID][vOffsety][wslot] = finaly;
					VehicleInfo[AttachVehID][vOffsetz][wslot] = ofz;
					VehicleInfo[AttachVehID][vOffsetxR][wslot] = fRotX;
					VehicleInfo[AttachVehID][vOffsetyR][wslot] = fRotY;
					VehicleInfo[AttachVehID][vOffsetzR][wslot] = ofaz;
					DestroyPlayerObject(playerid, VehicleInfo[AttachVehID][vWeaponObjectID][wslot]);
					VehicleInfo[AttachVehID][vWeaponObjectID][wslot] = CreateObject(model, 0, 0, 0, 0, 0, 0, 100.0);
					AttachObjectToVehicle(VehicleInfo[AttachVehID][vWeaponObjectID][wslot], AttachVehID, finalx, finaly, ofz, fRotX, fRotY, ofaz);

					new tmpQuery[300];
					mysql_format(g_SQL, tmpQuery, sizeof(tmpQuery), "INSERT INTO cocars_wobjects (model, weaponsql, vehicle_id, offsetx, offsety, offsetz, offsetrx, offsetry, offsetrz) VALUES ('%d', '%d', %d, %f, %f, %f, %f, %f, %f)", 
						model,
						VehicleInfo[AttachVehID][vWeaponSQLID][wslot], 
						VehicleInfo[AttachVehID][vSQLID], 
						VehicleInfo[AttachVehID][vOffsetx][wslot],
						VehicleInfo[AttachVehID][vOffsety][wslot],
						VehicleInfo[AttachVehID][vOffsetz][wslot],
						VehicleInfo[AttachVehID][vOffsetxR][wslot],
						VehicleInfo[AttachVehID][vOffsetyR][wslot],
						VehicleInfo[AttachVehID][vOffsetzR][wslot]
					);
					mysql_tquery(g_SQL, tmpQuery);
					EditingTrunkWeaponObject[playerid] = 0;
					EditingTrunkWeaponModel[playerid] = 0;
					Bit1_Set(gr_PlayerTrunkEdit, playerid, false);
					Streamer_Update(playerid);
					new wname[32],
						carname[36];
					GetWeaponName(VehicleInfo[AttachVehID][vWeaponId][wslot], wname, 32);
					strunpack(carname, Model_Name(VehicleInfo[AttachVehID][vModel]));
					SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste pohranili %s(%d metaka) u prtljaznik %s-a.", wname, VehicleInfo[AttachVehID][vWeaponAmmo][wslot], carname);
					CheckVehicleWeaponTrunkSpace(playerid, AttachVehID);
				}
			}
		}
	}
	return 1;
}


hook OnVehicleSpawn(vehicleid)
{
	if(VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_PRIVATE) 
	{
		CheckVehicleInsurance(vehicleid);
		SetTune(vehicleid);
		RespawnTrunkObjects(vehicleid);
	}
	return 1;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(  Bit2_Get(gr_PlayerLockBreaking, playerid ) != 0 &&
		!Bit1_Get( gr_PlayerHotWiring, playerid ) &&
		!Bit1_Get(gr_PreviewCar, playerid)  &&
		!Bit1_Get( gr_PlayerInTuningMode, playerid ) &&
		!Bit1_Get( gr_PlayerPickingJack, playerid ) &&
		!Bit1_Get( gr_PlayerJackSure, playerid ) )
	return 0;

	if(clickedid == Text:INVALID_TEXT_DRAW)
	{
		if( Bit1_Get( gr_PlayerHotWiring, playerid ) ) {
			ResetHotWireVars(playerid);
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		else if( Bit1_Get( gr_PreviewCar, playerid ) ) {
			DestroyPreviewScene(playerid);
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
	}
	return 1;
}

public OnPlayerCrashVehicle(playerid, vehicleid, Float:damage)
{
	new Float:ahealth;
	GetVehicleHealth(vehicleid, ahealth);
	if(ahealth <= 390.0) 
	{
		if(!VehicleInfo[vehicleid][vDestroyed]) {
			SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vase je vozilo unisteno, zovite mehanicara!");
			AC_SetVehicleHealth(vehicleid, 390.0);
			VehicleInfo[vehicleid][vDestroyed] = true;

			new
				engine, lights, alarm, doors, bonnet, boot, objective;
			GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
			VehicleInfo[vehicleid][vEngineRunning] = false;
		}
	}
	if(VehicleInfo[vehicleid][vUsage] == VEHICLE_USAGE_PRIVATE) 
	{
		if(650.0 <= ahealth <= 1000.0) {
			VehicleInfo[vehicleid][vEngineLife] 	-= 1;
			VehicleInfo[vehicleid][vBatteryLife] 	-= 1.0;
		}
		else if(550.0 <= ahealth <= 649.0) {
			VehicleInfo[vehicleid][vEngineLife] 	-= floatround(floatdiv(damage, 125.0));
			VehicleInfo[vehicleid][vBatteryLife] 	-= floatdiv(damage, 150.0);
		}
		else if(390.0 <= ahealth <= 549.0) {
			VehicleInfo[vehicleid][vEngineLife] 	-= floatround(floatdiv(damage, 100.0));
			VehicleInfo[vehicleid][vBatteryLife] 	-= floatdiv(damage, 125.0);
		}
		else if(250.0 <= ahealth <= 389.0) {
			VehicleInfo[vehicleid][vEngineLife] 	-= floatround(floatdiv(damage, 75.0));
			VehicleInfo[vehicleid][vBatteryLife] 	-= floatdiv(damage, 100.0);
		}
	}
	return 1;
}

/*
	 ######  ##     ## ########   ######
	##    ## ###   ### ##     ## ##    ##
	##       #### #### ##     ## ##
	##       ## ### ## ##     ##  ######
	##       ##     ## ##     ##       ##
	##    ## ##     ## ##     ## ##    ##
	 ######  ##     ## ########   ######
*/
///////////////////////////////////////////////////////////////////

CMD:duplicatekey(playerid, params[])
{
	new pickstr[8], vehicleid = GetPlayerVehicleID(playerid), plid = -1, string[128];

	if(PlayerInfo[playerid][pSpawnedCar] != vehicleid) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Morate se nalaziti u svom vozilu!");
	if(sscanf(params, "s[8] ", pickstr)) {
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /duplicatekey [odabir]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ] give, keys");
		return 1;
	}
	if(!strcmp(pickstr, "give", true))
	{
     	if(sscanf(params, "s[8]d", pickstr, plid))  return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /duplicatekey give [playerid]");
	    if(plid == INVALID_PLAYER_ID)
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne valjan unos playerida!");

		if(plid == playerid)
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozete sami sebi dati kljuc!");

		if(!ProxDetectorS(5.0, playerid, plid))
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Niste blizu igraca!");

		if(VehicleInfo[vehicleid][vSpareKey1] < 0)
		{
		    VehicleInfo[vehicleid][vSpareKey1] = PlayerInfo[plid][pSQLID];
			format(string, sizeof(string), "* %s daje rezervni kljuc %s.", GetName(playerid, true), GetName(plid, true));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
		    new
			tmpString[128];
			format(tmpString, sizeof(tmpString), "[ ! ] %s vam je dao rezervni kljuc svog vozila.", GetName(playerid, true));
			SendClientMessage(plid, COLOR_YELLOW, tmpString);
			format(tmpString, sizeof(tmpString), "[ ! ] Dali ste rezervni kljuc svog vozila %s. (SLOT: 1 - KEYID: %d)", GetName(plid, true), PlayerInfo[plid][pSQLID]);
			SendClientMessage(playerid, COLOR_RED, tmpString);
            new dkeyquery[128];
			format(dkeyquery, sizeof(dkeyquery), "UPDATE `cocars` SET `sparekey1` = '%d' WHERE `id` = '%d'", VehicleInfo[vehicleid][vSpareKey1], VehicleInfo[vehicleid][vSQLID]);
			mysql_tquery(g_SQL, dkeyquery);
			return 1;
		}
		if(VehicleInfo[vehicleid][vSpareKey2] < 0)
		{
		    VehicleInfo[vehicleid][vSpareKey2] = PlayerInfo[plid][pSQLID];
			format(string, sizeof(string), "* %s daje rezervni kljuc %s.", GetName(playerid, true), GetName(plid, true));
			SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
		    new
			tmpString[77];
			format(tmpString, sizeof(tmpString), "[ ! ] %s vam je dao rezervni kljuc svog vozila.", GetName(playerid, true));
			SendClientMessage(plid, COLOR_YELLOW, tmpString);
			format(tmpString, sizeof(tmpString), "[ ! ] Dali ste rezervni kljuc svog vozila %s. (SLOT: 2 - KEYID: %d)", GetName(plid, true), PlayerInfo[plid][pSQLID]);
			SendClientMessage(playerid, COLOR_RED, tmpString);
            new dkeyquery[128];
			format(dkeyquery, sizeof(dkeyquery), "UPDATE `cocars` SET `sparekey2` = '%d' WHERE `id` = '%d'", VehicleInfo[vehicleid][vSpareKey2], VehicleInfo[vehicleid][vSQLID]);
			mysql_tquery(g_SQL, dkeyquery);
			return 1;
		}
		SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate vise rezervnih kljuceva!");
		return 1;
	}
	else if(!strcmp(pickstr, "keys", true))
	{
	    new
		tmpString[128];
		strunpack(tmpString, Model_Name(VehicleInfo[vehicleid][vModel]));
		format(tmpString, sizeof(tmpString), "*___________[%s(%d)]___________*", tmpString, VehicleInfo[vehicleid][vModel]);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, tmpString);

		if(VehicleInfo[vehicleid][vSpareKey1] > 0)
			va_SendClientMessage(playerid, -1, "Key 1 ID: %d", VehicleInfo[vehicleid][vSpareKey1]);
		else
			SendClientMessage(playerid, -1, "Key 1 ID: N/A");

		if(VehicleInfo[vehicleid][vSpareKey2] > 0)
			va_SendClientMessage(playerid, -1, "Key 2 ID: %d", VehicleInfo[vehicleid][vSpareKey2]);
		else
			SendClientMessage(playerid, -1, "Key 2 ID: N/A");

		SendClientMessage(playerid, COLOR_LIGHTBLUE, "* _______________________________________________ *");
		return 1;
	}
	return 1;
}

CMD:car(playerid, params[])
{
	new pick[11];
	if(sscanf(params, "s[11] ", pick)) {
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /car [odabir]");
		SendClientMessage(playerid, COLOR_GREY, "[ODABIR]: buy - delete - info - get - tickets - buypark - park");
		SendClientMessage(playerid, COLOR_GREY, "[ODABIR]: parklocate - locate - tow - upgrade - breaklock");
		SendClientMessage(playerid, COLOR_GREY, "[ODABIR]: register - unregister - sell - junksell - refresh");
		return 1;
	}
	if(!strcmp(pick, "buy", true))
	{
		if(PlayerInfo[playerid][pLevel] == 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Morate biti level 2+ za koristenje ove komande!");
		if(PlayerInfo[playerid][pSpawnedCar] != -1 && PlayerInfo[playerid][pSpawnedCar] != 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Vec imate spawnano vozilo!");
		if(!CheckVehicleList(playerid))
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Svi slotovi za vozila su vam popunjeni!");
			
		if(IsPlayerInRangeOfPoint(playerid, 10.0, DealerInfo[0][flPosX], DealerInfo[0][flPosY], DealerInfo[0][flPosZ])) {		// Auti
			//Dali netko vec koristi tog dealera?
			if(Bit8_Get(gr_UsingDealer, VEH_DEALER_CARS)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Netko vec gleda vozila! Probajte malo kasnije!");

			//Kreiranje scene
			CreatePreviewScene(playerid, VEH_DEALER_CARS);

			//Player Sets
			SetPlayerVirtualWorld(playerid, playerid);
			SetPlayerPos(playerid, CarCamera[0][0]-5.0, CarCamera[0][1]+8.0, CarCamera[0][2]+2.0);
			InterpolateCameraPos(playerid, CarCamera[0][0], CarCamera[0][1], CarCamera[0][2], CarCamera[0][0], CarCamera[0][1], CarCamera[0][2], 500000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[0][0], PreviewPos[0][1], PreviewPos[0][2], PreviewPos[0][0], PreviewPos[0][1], PreviewPos[0][2],  1000000, CAMERA_MOVE);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 5.0, DealerInfo[1][flPosX], DealerInfo[1][flPosY], DealerInfo[1][flPosZ])) {	// Brodovi
			if(Bit8_Get(gr_UsingDealer, VEH_DEALER_BOAT)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Netko vec gleda vozila! Probajte malo kasnije!");

			//Player Sets
			SetPlayerPos(playerid, 123.7875, -1766.9968, 3.5263);
			InterpolateCameraPos(playerid, BoatCamera[0][0], BoatCamera[0][1], BoatCamera[0][2], BoatCamera[0][0], BoatCamera[0][1], BoatCamera[0][2], 5000000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[1][0], PreviewPos[1][1], PreviewPos[1][2], PreviewPos[1][0], PreviewPos[1][1], PreviewPos[1][2],  1000000, CAMERA_MOVE);

			//Kreiranje scene
			CreatePreviewScene(playerid, VEH_DEALER_BOAT);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 5.0, DealerInfo[2][flPosX], DealerInfo[2][flPosY], DealerInfo[2][flPosZ])) {	// Avioni

			if(Bit8_Get(gr_UsingDealer, VEH_DEALER_PLANE)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Netko vec gleda vozila! Probajte malo kasnije!");

			//Player Sets
			SetPlayerPos(playerid, 2110.7529, -2405.1841, 14.3317);
			InterpolateCameraPos(playerid, AeroCamera[0][0], AeroCamera[0][1], AeroCamera[0][2], AeroCamera[0][0], AeroCamera[0][1], AeroCamera[0][2], 5000000, CAMERA_MOVE);
			InterpolateCameraLookAt(playerid, PreviewPos[2][0], PreviewPos[2][1], PreviewPos[2][2], PreviewPos[2][0], PreviewPos[2][1], PreviewPos[2][2],  1000000, CAMERA_MOVE);

			//Kreiranje scene
			CreatePreviewScene(playerid, VEH_DEALER_PLANE);
		}
		else return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u blizini salona vozila (Automobili/Brodovi/Avioni)! Za vise koristite GPS.");
	}
	else if(!strcmp(pick, "color", true))
	{
		new
			take;
		if(sscanf(params, "s[11]i ", pick, take)) {
			SendClientMessage(playerid, COLOR_RED, "[ ? ]: /car color [odabir]");
			SendClientMessage(playerid, COLOR_GREY, "[ODABIR]: 1 - Lista boja, 2 - Obojaj vozilo");
			return 1;
		}

		switch(take)
		{
			case 1: {
				new
					buffer[3464],
					count = 0;

				for(new x = 0; x < 256; x++) {
					if(count == 15) {
						format(buffer, 3464, "%s{%s}%d\n", buffer, VehicleColoursTableRGB[x], x);
						count = 0;
					}
					else {
						if(x == 255)
							format(buffer, 3464, "%s{%s}%d", buffer, VehicleColoursTableRGB[x], x);
						else if(x < 255)
							format(buffer, 3464, "%s {%s}%d - ", buffer, VehicleColoursTableRGB[x], x);
					}
					count++;
				}
				ShowPlayerDialog(playerid, DIALOG_VEH_COLORS, DIALOG_STYLE_MSGBOX, "LISTA BOJA", buffer, "Ok", "");
			}
			case 2: {
				new
					vehicleid = GetPlayerVehicleID(playerid);

				if(vehicleid != PlayerInfo[playerid][pSpawnedCar]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Morate biti u svome CO vozilu!");

				if(vehicleid != PlayerInfo[playerid][pSpawnedCar]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Morate biti u svome osobnom vozilu!");
				if(AC_GetPlayerMoney(playerid) < 500) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate dovoljno novca (500$)! ");
				new
					slot, color;
				if(sscanf(params, "s[11]iii", pick, take, slot, color)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /car color [boja (1/2)][ID boje]");

				if(IsAPlane(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel])) {
					if(!IsPlayerInRangeOfPoint(playerid, 9.0, 114.3532, -1937.9978, 0.2384)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste ispod dizalice za bojanje brodova.");
				} else if(IsABoat(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel])) {
					if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1922.2289, -2242.9053, 12.5353)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste kod hangara za bojanje aviona.");
				} else {
					if(!IsPlayerInRangeOfPoint(playerid, 20.0, 2321.9822, -1355.6526, 23.3999)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste ispod dizalice za bojanje automobila.");
				}
				if(slot > 2 || slot < 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Broj boja nemoze biti manji od 1 i veci od 2.");
				if(color > 255 || color < 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Broj boje nemoze biti manji od 0 i veci od 255.");

				new
					colorString[26],
					colorQuery[128];
				if(slot == 1)
				{
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vColor1] = color;
					ChangeVehicleColor( vehicleid, color, VehicleInfo[ PlayerInfo[ playerid ][ pSpawnedCar ] ][ vColor2 ] );

					format(colorString, sizeof(colorString), "1. boja auta je sada %d.", color);
					SendClientMessage(playerid, COLOR_GREEN,colorString);

					format(colorQuery, sizeof(colorQuery), "UPDATE `cocars` SET `color1` = '%d' WHERE `id` = '%d'", color, VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
					mysql_tquery(g_SQL, colorQuery);
				} else {
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vColor2] = color;
					ChangeVehicleColor( vehicleid, VehicleInfo[ PlayerInfo[ playerid ][ pSpawnedCar ] ][ vColor1 ], color );

					format(colorString, sizeof(colorString), "2. boja auta je sada %d.",color);
					SendClientMessage(playerid, COLOR_GREEN,colorString);

					format(colorQuery, sizeof(colorQuery), "UPDATE `cocars` SET `color2` = '%d' WHERE `id` = '%d'", color, VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]);
					mysql_tquery(g_SQL, colorQuery);
				}
				PlayerPlaySound(playerid, 1134, 0, 0, 0);
				PlayerToBudgetMoney(playerid, 500); // Novac ide u proracun od igraca
				GameTextForPlayer(playerid, "~r~-500$", 5000, 1);
				SendClientMessage(playerid, COLOR_RED, "[ ! ] Vase vozilo je uspjesno obojano.");
			}
		}
	}
	else if(!strcmp(pick, "info", true))
	{
		if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate spawnati vozilo!");
		if(!IsPlayerInAnyVehicle(playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Morate biti unutar vozila za koristenje ove komande!");
		new
			vehicleid = PlayerInfo[playerid][pSpawnedCar],
			tmpString[128];

		if(VehicleInfo[vehicleid][vUsage] != VEHICLE_USAGE_PRIVATE) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ovo nije osobno vozilo!");
		strunpack(tmpString, Model_Name(VehicleInfo[vehicleid][vModel]));

		format(tmpString, sizeof(tmpString), "*___________[%s(%d)]___________*", tmpString, VehicleInfo[vehicleid][vModel]);
		SendClientMessage(playerid, COLOR_LIGHTBLUE, tmpString);

		if(VehicleInfo[vehicleid][vNumberPlate] != ' ')
			va_SendClientMessage(playerid, -1, "Registracija: %s", VehicleInfo[vehicleid][vNumberPlate]);
		else
			SendClientMessage(playerid, -1, "Registracija: Nista");
		va_SendClientMessage(playerid, -1, "Puta unisten: %d", 			VehicleInfo[vehicleid][vDestroys]);
		va_SendClientMessage(playerid, -1, "Osiguranje: %d", 			VehicleInfo[vehicleid][vInsurance]);
		va_SendClientMessage(playerid, -1, "Tip motora: %s", 			GetEngineTypeString(VehicleInfo[vehicleid][vEngineType]));
		va_SendClientMessage(playerid, -1, "Stanje motora: %s", 		GetEngineLifeString(vehicleid));
		va_SendClientMessage(playerid, -1, "Tip akumulatora: %s", 		GetBatteryTypeString(VehicleInfo[vehicleid][vBatteryType]));
		va_SendClientMessage(playerid, -1, "Stanje akumulatora: %s", 	GetBatteryLifeString(vehicleid));
		SendClientMessage(playerid, COLOR_LIGHTBLUE, "* _______________________________________________ *");
	}
	else if(!strcmp(pick, "upgrade", true))
	{
		if(GetPlayerVehicleID(playerid) != PlayerInfo[playerid][pSpawnedCar]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Morate biti u svome CO vozilu!");
		if(IsABoat(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel])) {
			if(!IsPlayerInRangeOfPoint(playerid, 9.0, 114.3532, -1937.9978, 0.2384)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste ispod dizalice za upgrade brodova.");
		} else if(IsAPlane(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel]) || IsAHelio(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel])) {
			if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1922.2289, -2242.9053, 12.5353)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste kod hangara za upgrade aviona.");
		} else {
			if(!IsPlayerInRangeOfPoint(playerid, 20.0, 2321.9822, -1355.6526, 23.3999)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u garazi za upgrade automobila.");
		}
		ShowPlayerDialog(playerid, DIALOG_VEH_UPGRADE, DIALOG_STYLE_LIST, "UPGRADE PRIVATNIH VOZILA", "Osiguranje\nAkumulator\nBrava\nImmobilizator\nAudio (1.000$)\nAlarm\nPromjena brave", "Choose", "Abort");
	}
	else if(!strcmp(pick, "tow", true))
	{
		new
			vehicleid = PlayerInfo[playerid][pSpawnedCar];

		//Errors :)
		if(vehicleid == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate spawnano vozilo!");
		if(0 <= VehicleInfo[vehicleid][vInsurance] <= 1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate osiguranje level 2 ili 3!");
		if(!VehicleInfo[vehicleid][vGPS]) return SendErrorMessage(playerid, "GPS je onemogucen na vasem vozilu, vucna sluzba ga ne moze locirati!");
		if(PlayerCarTow[playerid]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vec ste aktivirali vucu vozila do parkirnog mjesta!");
		if(VehicleInfo[vehicleid][vImpounded] > 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vase vozilo je zaplijenjeno od strane policije!");
		if(!VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vGPS]) return SendErrorMessage(playerid, "GPS je onemogucen na vasem vozilu, nemoguce ga je locirati!");
		//Netko koristi vozilo?
		foreach (new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid)) 
				return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Netko vec koristi vase vozilo.");
		}
		if(PlayerInfo[playerid][pDonateRank] < 2)
		{
			if(AC_GetPlayerMoney(playerid) < 1000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate dovoljno novca za naknadu za vucu od 1000$!");
			PlayerToOrgMoneyTAX(playerid, 1, 1000); // Novac ide PDu uz porez koji ide drzavi
		}
		// Timer
		PlayerCarTow[playerid] = true;
		
		if(PlayerInfo[playerid][pDonateRank] == 0)
			PlayerTowTimer[playerid] = gettimestamp() + VEHICLE_TOW_TIME;
		else
		{
			if(PlayerInfo[playerid][pDonateRank] == 1)
				PlayerTowTimer[playerid] = gettimestamp() + BRONZE_VEHICLE_TOW_TIME;
			else if(PlayerInfo[playerid][pDonateRank] == 2)
				PlayerTowTimer[playerid] = gettimestamp() + SILVER_VEHICLE_TOW_TIME;
			else if(PlayerInfo[playerid][pDonateRank] == 3)
				PlayerTowTimer[playerid] = gettimestamp() + GOLD_VEHICLE_TOW_TIME;
			else if(PlayerInfo[playerid][pDonateRank] == 4)
				PlayerTowTimer[playerid] = gettimestamp() + PLATINUM_VEHICLE_TOW_TIME;
		}
		new duration = (PlayerTowTimer[playerid] - gettimestamp()) / 60;
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Vase vozilo ce biti dovuceno za %d minuta!", duration);
	}
	else if(!strcmp(pick, "delete", true)) // brisanje bez spawnanja vozila to ti je fix za onaj bug sa osobom koja spawna nakon brisanja vozila auto
	{
		new vehicleid = PlayerInfo[playerid][pSpawnedCar];
		if(vehicleid == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(!IsPlayerInVehicle(playerid, vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u svome automobilu!");

		ShowPlayerDialog(playerid, DIALOG_VEH_DELETE, DIALOG_STYLE_MSGBOX, "BRISANJE VOZILA", "Zelite li obrisati svoje vozilo?\nOno ce biti potpuno obrisano iz databaze!", "Yes", "No");
	}
	else if(!strcmp(pick, "refresh", true)) {
		new vehicleid = PlayerInfo[playerid][pSpawnedCar];
		if(vehicleid == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
	}
	else if(!strcmp(pick, "park", true))
	{
		new vehicleid = PlayerInfo[playerid][pSpawnedCar];
		if(vehicleid == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(!IsPlayerInVehicle(playerid, vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u svome automobilu!");
		if(!IsPlayerInRangeOfPoint(playerid, 5.0, VehicleInfo[vehicleid][vParkX], VehicleInfo[vehicleid][vParkY], VehicleInfo[vehicleid][vParkZ])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u blizini parkinga! Kucajte /car parklocate za lociranje parkinga!");

		// Mici ga odatle
		TogglePlayerControllable(playerid, 0);
		RemovePlayersFromVehicle(vehicleid);
		SendMessage(playerid, MESSAGE_TYPE_INFO, "U toku je proces sigurnog parkiranja. Uklonjeni ste iz vozila i zamrznuti na 5 sekundi.");
        // Timer	
		defer ParkPlayerVehicle(playerid, vehicleid);
	}
	else if(!strcmp(pick, "buypark", true))
	{
		new
			vehicleid = PlayerInfo[playerid][pSpawnedCar];
		if(vehicleid == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(!IsPlayerInVehicle(playerid, vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u svome automobilu!");
		if(AC_GetPlayerMoney(playerid) < 100 && PlayerInfo[playerid][pDonateRank] < 3) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate 100$!");

		new
			Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		VehicleInfo[vehicleid][vParkX]	= X;
		VehicleInfo[vehicleid][vParkY]	= Y;
		VehicleInfo[vehicleid][vParkZ]	= Z;
		new
			Float:z_rot;
		GetVehicleZAngle(vehicleid, z_rot);
		VehicleInfo[vehicleid][vAngle] 	= z_rot;
		VehicleInfo[vehicleid][vInt] = GetPlayerInterior(playerid);
		VehicleInfo[vehicleid][vViwo] = GetPlayerVirtualWorld(playerid);

		new
			bigquery[256];
		format(bigquery, sizeof(bigquery), "UPDATE `cocars` SET `parkX` = '%.4f', `parkY` = '%.4f', `parkZ` = '%.4f', `angle` = '%.4f', `interior` = '%d', `viwo` = '%d' WHERE `id` = '%d'",
			X,
			Y,
			Z,
			z_rot,
			GetPlayerInterior(playerid),
			GetPlayerVirtualWorld(playerid),
			VehicleInfo[vehicleid][vSQLID]
		);
		mysql_tquery(g_SQL, bigquery);

		if(PlayerInfo[playerid][pDonateRank] < 3) {
			PlayerToBudgetMoney(playerid, 100); // Novac ide u proracun
			GameTextForPlayer(playerid, "~r~-100$", 5000, 1);
		}
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Kupili ste parking!");
	}
	else if(!strcmp(pick, "parklocate", true))
	{
		if(Bit1_Get(gr_IsWorkingJob, playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozete koristiti GPS dok radite!");
		if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(PlayerParkLocation[playerid] == 0)
		{
			new vehicleid = PlayerInfo[playerid][pSpawnedCar];
			PlayerParkLocation[playerid] = 1;
			SetPlayerCheckpoint(playerid, VehicleInfo[vehicleid][vParkX], VehicleInfo[vehicleid][vParkY], VehicleInfo[vehicleid][vParkZ]-1.5, 5.0);
			GameTextForPlayer(playerid, "~g~gps online", 2000, 1);
		} 
		else 
		{
			DisablePlayerCheckpoint(playerid);
			PlayerParkLocation[playerid] = 0;
			GameTextForPlayer(playerid, "~r~gps offline", 2000, 1);
		}
	}
	else if(!strcmp(pick, "locate", true))
	{
		if(Bit1_Get(gr_IsWorkingJob, playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozete koristiti GPS dok radite!");
		if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(IsVehicleOccupied(PlayerInfo[playerid][pSpawnedCar])) return SendClientMessage(playerid, COLOR_RED, "[ ! ] Neko se nalazi u vasem vozilu");
		//if(!VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vGPS]) return SendErrorMessage(playerid, "GPS je onemogucen na vasem vozilu, vozite ga na popravak!");
		if(Bit1_Get(gr_PlayerLocateVeh, playerid)) {
			DisablePlayerCheckpoint(playerid);
			GameTextForPlayer(playerid, "~r~gps offline", 2000, 1);
			Bit1_Set(gr_PlayerLocateVeh, playerid, false);
			return 1;
		}
		Bit1_Set(gr_PlayerLocateVeh, playerid, true);
		new
			Float:Pos[3],
			Float:z;
		
		GetVehiclePos(PlayerInfo[playerid][pSpawnedCar], Pos[0], Pos[1], Pos[2]);
		z = Pos[2] - 0.5;
		SetPlayerCheckpoint(playerid, Pos[0], Pos[1], z, 5.0);
		GameTextForPlayer(playerid, "~g~gps online", 2000, 1);
	}

	else if(!strcmp(pick, "get", true))
	{
		if (VehicleInfoModel[playerid][0] == -1 && VehicleInfoModel[playerid][1] == -1 && VehicleInfoModel[playerid][2] == -1 && VehicleInfoModel[playerid][3] == -1 &&
			VehicleInfoModel[playerid][4] == -1 && VehicleInfoModel[playerid][5] == -1 && VehicleInfoModel[playerid][6] == -1 && VehicleInfoModel[playerid][7] == -1 && VehicleInfoModel[playerid][8] == -1 && VehicleInfoModel[playerid][9] == -1 )
			return SendClientMessage(playerid, COLOR_RED, "[GRESKA]: Nemate vozilo!");

		new slot;
		if(sscanf(params, "s[8]i", pick, slot))
		{
			SendClientMessage(playerid, -1, "[ ? ]: /car get [slot vozila]");
			SendClientMessage(playerid, COLOR_YELLOW, "[INFO]: Ukoliko ne znate slot u kojem se vozilo nalazi, kucajte /car list.");
			return 1;
		}
		if(slot <= 0 || slot > 10) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Krivi unos slota u kojem se vozilo nalazi!");
		if(PlayerInfo[playerid][pSpawnedCar] != -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vec ste spawnali svoje vozilo!");
		if( VehicleInfoSQLID[ playerid ][ slot-1 ] == -1 ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate automobil pohranjen u tome slotu!");
		SpawnVehicleInfo( playerid, VehicleInfoSQLID[ playerid ][ slot-1 ] );
		SendFormatMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uspjesno ste spawnali vas %s!", ReturnVehicleName(VehicleInfoModel[ playerid ][ slot-1 ]));
	}

	else if(!strcmp(pick,"list", true))
	{
		if (VehicleInfoModel[playerid][0] == -1 && VehicleInfoModel[playerid][1] == -1 && VehicleInfoModel[playerid][2] == -1 && VehicleInfoModel[playerid][3] == -1 &&
			VehicleInfoModel[playerid][4] == -1 && VehicleInfoModel[playerid][5] == -1 && VehicleInfoModel[playerid][6] == -1 && VehicleInfoModel[playerid][7] == -1  && VehicleInfoModel[playerid][8] != -1 && VehicleInfoModel[playerid][9])
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate vozilo!");

		new
			tmpString[42],
			vehName[ 32 ];

		for(new i = 0; i < MAX_PLAYER_CARS; i++)
		{
			if(VehicleInfoModel[playerid][i] != -1)
			{
				strunpack(vehName, Model_Name(VehicleInfoModel[playerid][i]) );
				format(tmpString, sizeof(tmpString), "Vozilo: %d    ||    Ime: %s", (i+1), vehName);
				SendClientMessage(playerid, -1, tmpString);
			}
		}
	}
	if(!strcmp(pick, "tickets", true))
	{
		new vehicleid;
		if(PlayerInfo[playerid][pSpawnedCar] == -1) 
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate spawnano svoje vozilo!");
		vehicleid = PlayerInfo[playerid][pSpawnedCar];
		if(!VehicleInfo[vehicleid][vTickets][0] && !VehicleInfo[vehicleid][vTickets][1] && !VehicleInfo[vehicleid][vTickets][2] && !VehicleInfo[vehicleid][vTickets][3] && !VehicleInfo[vehicleid][vTickets][4]) 
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Trenutno vozilo nema kazna na sebi!");
		ShowVehicleTickets(playerid, vehicleid);
	}
	else if(!strcmp(pick,"breaklock", true))
	{
		if(PlayerInfo[playerid][pLevel] < 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Samo level 2+ mogu koristiti ovu komandu!");
		if(Bit1_Get(gr_PlayerBreaking, playerid)) 
		{

			if(BreakLockVehicleID[playerid] == INVALID_VEHICLE_ID) return 1;
			if(DoorHealth3DText[BreakLockVehicleID[playerid]] == Text3D:INVALID_3DTEXT_ID) return 1;
			
			DestroyDynamic3DTextLabel(DoorHealth3DText[BreakLockVehicleID[playerid]]);
			DoorHealth3DText[BreakLockVehicleID[playerid]] = Text3D:INVALID_3DTEXT_ID;

			BreakLockVehicleID[playerid] 	= INVALID_VEHICLE_ID;
			BreakLockKickTick[playerid]		= 0;
			Bit2_Set(gr_PlayerLockBreaking, playerid, 0);
		}
		new vehicleid = GetNearestVehicle(playerid, VEHICLE_USAGE_PRIVATE);
		if(vehicleid == INVALID_VEHICLE_ID) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste blizu privatnog vozila.");
		if(!VehicleInfo[vehicleid][vLocked]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vozilo je otkljucano!");
		if(vehicleid == PlayerInfo[playerid][pSpawnedCar]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozes obijati svoje vozilo!");

		switch(VehicleInfo[vehicleid][vLock]) 
		{
			case 1: VehicleInfo[vehicleid][vDoorHealth] = 236.0;
			case 2: VehicleInfo[vehicleid][vDoorHealth] = 445.0;
			case 3: VehicleInfo[vehicleid][vDoorHealth] = 525.0;
		}

		// Player vars sets
		BreakLockVehicleID[playerid] 	= vehicleid;
		BreakLockKickTick[playerid]		= gettimestamp();

		// 3dText - Destroy
		DestroyDynamic3DTextLabel(DoorHealth3DText[vehicleid]);
		DoorHealth3DText[vehicleid] = Text3D:INVALID_3DTEXT_ID;

		// Setting 3dtext
		new dTxt[35];
		format(dTxt, 35, "Door HP: {00CCCC}%.1f", VehicleInfo[vehicleid][vDoorHealth]);
		DoorHealth3DText[vehicleid] = CreateDynamic3DTextLabel(dTxt, 0x00CCCCFF, -0.9681, 0.2947, -0.0456, 30.0, INVALID_PLAYER_ID, vehicleid, 0, -1, -1, playerid, 50.0);

		// Poruka i timer
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Udarajte po vozilu dok mu ne skinete HP! Ne udaljavajte se od automobila!");
		Bit2_Set(gr_PlayerLockBreaking, playerid, 2);
		Bit1_Set(gr_PlayerBreaking, playerid, true);
	}
	else if(!strcmp(pick, "register", true))
	{
		if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(!IsPlayerInVehicle(playerid, PlayerInfo[playerid][pSpawnedCar])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate biti u svom vozilu!");
		if(!IsPlayerInRangeOfPoint(playerid, 50.0, VehicleBuyPos[0][0],VehicleBuyPos[0][1],VehicleBuyPos[0][2])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste blizu Wang Carsa.");
		if(IsHaveNoNumberPlate(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozete staviti registraciju na to vozilo!");
		if(AC_GetPlayerMoney(playerid) < 1000) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate 1.000$!");

		PlayerToOrgMoneyTAX(playerid, 1, 1000); // Novac ide u PD, dok oporezivi dio ide drZavi

		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

		new
			rand = 100000 + random(8999999),
			registracija[8], tmpString[42];
		format(registracija, sizeof(registracija), "%d", rand);

		format(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate], 8, "%s", registracija);
    	SetVehicleNumberPlate(GetPlayerVehicleID(playerid), registracija);

		format(tmpString, sizeof(tmpString), "[ ! ] Uspjesno ste registrovali vase vozilo!");
		SendClientMessage(playerid, COLOR_GREEN, tmpString);
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Parkirajte vase vozilo pa ga opet spawnajte da vidite vasu registraciju!");

		new
			bigquery[128];
		mysql_format(g_SQL, bigquery, sizeof(bigquery), "UPDATE `cocars` SET `numberplate` = '%e' WHERE `id` = '%d'",
			VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate],
			VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]
		);
		mysql_tquery(g_SQL, bigquery);
	}
	else if(!strcmp(pick, "unregister", true))
	{
		if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste spawnali vozilo!");
		if(!IsPlayerInVehicle(playerid, PlayerInfo[playerid][pSpawnedCar])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate biti u svom vozilu!");
		if(!IsPlayerInRangeOfPoint(playerid, 50.0, VehicleBuyPos[0][0],VehicleBuyPos[0][1],VehicleBuyPos[0][2])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste blizu Wang Carsa.");
		if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate][0] == '0') return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vozilo nije registrirano!");

		strdel(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate], 0, 8);

		strcat(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate], "0", 8);

		SetVehicleNumberPlate(GetPlayerVehicleID(playerid), "");

		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Uklonili ste registraciju vasem vozilu!");
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Registracija ce nestati nakon sto parkirate vozilo i ponovno ga spawnate!");

		new
			bigquery[128];
		format(bigquery, sizeof(bigquery), "UPDATE `cocars` SET `numberplate` = '0' WHERE `id` = '%d'",
			VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vSQLID]
		);
		mysql_tquery(g_SQL, bigquery);
	}
	else if(!strcmp(pick, "sell", true)) 
	{
		if(PlayerInfo[playerid][pLevel] < 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne smijete prodavati vozila, ako ste level 1!");
		new
			giveplayerid,
			vehiclePrice;

		if(sscanf(params, "s[11]ui", pick, giveplayerid, vehiclePrice)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /car sell [playerid/dio imena][cijena]");
		if(giveplayerid == INVALID_PLAYER_ID) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nevaljan unos igraceva ID-a!");
		if(giveplayerid == playerid) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne mozete samom sebi prodati vozilo!");
		if(!IsPlayerConnected(giveplayerid) || !SafeSpawned[giveplayerid]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Taj igrac nije sigurno spawnan/online!");
		if(PlayerInfo[giveplayerid][pLevel] < 3) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne smijete prodavati vozila level 2 igracima (anti-abuse)!");
		if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate spawnano vozilo!");
		//if(IsABike(PlayerInfo[playerid][pSpawnedCar]) && vehiclePrice < 100) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Minimalna cijena prodaje bicikla je 100$!");
		//if(!IsABike(PlayerInfo[playerid][pSpawnedCar]) && vehiclePrice < CalculateVehiclePrice(PlayerInfo[playerid][pSpawnedCar])) return SendFormatMessage(playerid, MESSAGE_TYPE_ERROR, " Minimalna cijena prodaje vaseg vozila je %d$!", CalculateVehiclePrice(PlayerInfo[playerid][pSpawnedCar]));
		if(!ProxDetectorS(8.0, playerid, giveplayerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Niste blizu igraca kojem prodajete vozilo!");
		if(PlayerInfo[giveplayerid][pSpawnedCar] != -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Igrac vec ima spawnano vozilo!");
	
		new vehicleid = PlayerInfo[playerid][pSpawnedCar],
			model = GetVehicleModel(vehicleid),
			carid = GetVehicleByModel(model);
			
		if(LandVehicles[carid][viPremium] > 0)
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne mozete prodavati VIP vozila!");
			
		if(vehiclePrice < 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nevaljan unos cijene!");
		
		if(!CheckVehicleList(giveplayerid))
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Svi slotovi za vozila su popunjeni igracu!");

		PlayerCarSeller[giveplayerid] 		= playerid;
		PlayerSellingPrice[giveplayerid] 		= vehiclePrice;

		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Ponudili ste %s vase vozilo za %d$", GetName(giveplayerid), vehiclePrice);

		new
			tmpString[128], vehicleName[MAX_VEHICLE_NAME];
		GetVehicleNameById(PlayerInfo[playerid][pSpawnedCar], vehicleName, MAX_VEHICLE_NAME);
		format(tmpString, sizeof(tmpString), ""COL_WHITE"Zelite li kupiti vozilo marke "COL_LIGHTBLUE"%s"COL_WHITE"od "COL_LIGHTBLUE"%s"COL_WHITE"za "COL_LIGHTBLUE"%d"COL_WHITE"$?",
			vehicleName,
			GetName(playerid),
			vehiclePrice
		);
		ShowPlayerDialog(giveplayerid, DIALOG_VEH_SELLING, DIALOG_STYLE_MSGBOX, "KUPOVINA VOZILA", tmpString, "Buy", "Abort");
	}
	else if(!strcmp(pick, "junksell", true))
	{
		if(PlayerInfo[playerid][pLevel] < 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne smijete prodavati vozila, ako ste level 1!");
		if(!IsPlayerInRangeOfPoint(playerid, 20.0, 2101.1802, -2002.6816, 12.5390) && 
			!IsPlayerInRangeOfPoint(playerid, 100.0, DealerInfo[1][flPosX], DealerInfo[1][flPosY], DealerInfo[1][flPosZ]) && 
			!IsPlayerInRangeOfPoint(playerid, 100.0, DealerInfo[2][flPosX], DealerInfo[2][flPosY], DealerInfo[2][flPosZ])) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste kod Los Santos Junkyard-a!");
		if(!IsPlayerInAnyVehicle(playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate biti u vozilu!");
		new vehicleid = GetPlayerVehicleID(playerid);
		if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vase vozilo nije CO!");
		if(PlayerInfo[playerid][pSpawnedCar] != vehicleid) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate se nalaziti u svome CO-u!");		
		new modelid = GetVehicleByModel(GetVehicleModel(vehicleid));
		if(modelid == -1) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "To vozilo nije iz Wangs Cars!");	
		if(LandVehicles[modelid][viPremium] != 0) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "To vozilo nije moguce prodati!");

		new moneys = CalculateVehiclePrice(vehicleid, 1);
		if(IsPlayerInRangeOfPoint(playerid, 100.0, DealerInfo[1][flPosX], DealerInfo[1][flPosY], DealerInfo[1][flPosZ])) moneys = CalculateVehiclePrice(vehicleid, 2);
		else if(IsPlayerInRangeOfPoint(playerid, 100.0, DealerInfo[2][flPosX], DealerInfo[2][flPosY], DealerInfo[2][flPosZ])) moneys = CalculateVehiclePrice(vehicleid, 3);

		va_ShowPlayerDialog(playerid, DIALOG_VEH_JUNK_SELL, DIALOG_STYLE_MSGBOX, "Prodaja vozila", ""COL_WHITE"Zelite li prodati vozilo smetlistu za "COL_LIGHTBLUE"%d$"COL_WHITE"?", "Da", "Ne", moneys);	
	}
	return 1;
}

CMD:trunk(playerid, params[])
{
	if(strlen(params) >= 10)
		return SendClientMessage(playerid, -1, "[ ? ]: /trunk [open/take/put/break]");
		
	new
		vehicleid = GetNearestVehicle(playerid, VEHICLE_USAGE_PRIVATE),
		engine, lights, alarm, doors, bonnet, boot, objective,
		pick[10];

	if(vehicleid == INVALID_VEHICLE_ID) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u blizini privatnog vozila!");
	if(!IsPlayerNearTrunk(playerid, vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste kod prtljaznika privatnog vozila!");
	if(sscanf(params, "s[10]", pick)) return SendClientMessage(playerid, -1, "[ ? ]: /trunk [open/take/put/break]");
	if(PlayerInfo[playerid][pLevel] < 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne mozete koristiti ovu komandu kao level 1.");
	if(!strcmp(pick, "open", true)) 
	{
		if(vehicleid != PlayerInfo[playerid][pSpawnedCar]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Samo vlastitom vozilu mozete otvarati prtljaznik!");
		if(IsVehicleWithoutTrunk(GetVehicleModel(vehicleid))) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ovo vozilo nema prtljaznik!");
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate biti na nogama da biste zatvorili/otvorili prtljaznik.");
		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		if(VehicleInfo[vehicleid][vTrunk] == VEHICLE_PARAMS_OFF) {
			SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_ON, objective);
			VehicleInfo[vehicleid][vTrunk] = VEHICLE_PARAMS_ON;
			GameTextForPlayer(playerid, "~w~gepek otvoren", 1000, 3);
		}
		else if(VehicleInfo[vehicleid][vTrunk] == VEHICLE_PARAMS_ON) {
			SetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
			VehicleInfo[vehicleid][vTrunk] = VEHICLE_PARAMS_OFF;
			GameTextForPlayer(playerid, "~w~gepek zatvoren", 1000, 3);
		}
	}
	else if(!strcmp(pick, "put", true)) 
	{
		if(VehicleInfo[vehicleid][vTrunk] == VEHICLE_PARAMS_OFF) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Prtljaznik nije otvoren!");
		if(AntiSpamInfo[playerid][asCarTrunk] > gettimestamp()) return va_SendClientMessage(playerid, COLOR_RED, "[ANTI-SPAM]: Ne spamajte sa komandom! Pricekajte %d sekundi pa nastavite!", ANTI_SPAM_CAR_WEAPON);
		if(IsPlayerInAnyVehicle(playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne smijete biti u vozilu!");
		if(IsACop(playerid) || IsASD(playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne smijete to koristiti!");
		if(!CheckVehicleWeaponCapacities(playerid, vehicleid))
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "U vozilu vise nema mjesta za oruzja.");
			
		new weaponid = AC_GetPlayerWeapon(playerid),
			ammo = AC_GetPlayerAmmo(playerid);
		if(weaponid == 0 || ammo == 0)
			return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate nikakvo oruzje u ruci/oruzje nema municije.");
			
		else PutPlayerWeaponInTrunk(playerid, vehicleid, weaponid);
		return 1;
	}
	else if(!strcmp(pick, "take", true)) 
	{
		if(VehicleInfo[vehicleid][vTrunk] == VEHICLE_PARAMS_OFF) 	return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Prtljaznik nije otvoren!");
		if(AntiSpamInfo[playerid][asCarTrunk] > gettimestamp()) 	return va_SendClientMessage(playerid, COLOR_RED, "[ANTI-SPAM]: Ne spamajte sa komandom! Pricekajte %d sekundi pa nastavite!", ANTI_SPAM_CAR_WEAPON);
		if(IsPlayerInAnyVehicle(playerid)) 						return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne smijete biti u vozilu!");
		
		if(IsACop(playerid) || IsASD(playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Ne smijete to koristiti!");
		
		ShowPlayerDialog(playerid, DIALOG_VEH_TAKEGUN, DIALOG_STYLE_LIST, "Prtljaznik - uzimanje oruzja", ListPlayerVehicleWeapons(playerid, vehicleid), "Choose", "Abort");
		return 1;
	}
	else if(!strcmp(pick,"break", true))
	{
		if(PlayerInfo[playerid][pLevel] < 2) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Samo level 2+ mogu koristiti ovu komandu!");
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Morate biti na nogama da biste obili prtljaznik.");
		if(Bit1_Get(gr_PlayerBreakingTrunk, playerid)) 
		{

			if(BreakTrunkVehicleID[playerid] == INVALID_VEHICLE_ID) return 1;
			if(TrunkHealth3DText[BreakTrunkVehicleID[playerid]] == Text3D:INVALID_3DTEXT_ID) return 1;
			
			DestroyDynamic3DTextLabel(TrunkHealth3DText[BreakTrunkVehicleID[playerid]]);
			TrunkHealth3DText[BreakTrunkVehicleID[playerid]] = Text3D:INVALID_3DTEXT_ID;

			BreakTrunkVehicleID[playerid] 	= INVALID_VEHICLE_ID;
			BreakTrunkKickTick[playerid]		= 0;
		}
		if(VehicleInfo[vehicleid][vTrunk] == VEHICLE_PARAMS_ON) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vozilo ima otvoren prtljaznik!");
		if(vehicleid == PlayerInfo[playerid][pSpawnedCar]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozes obijati svoje vozilo!");
		if(IsVehicleWithoutTrunk(GetVehicleModel(vehicleid))) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ovo vozilo nema prtljaznik!");
		
		switch(VehicleInfo[vehicleid][vLock]) 
		{
			case 1: VehicleInfo[vehicleid][vTrunkHealth] = 536.0;
			case 2: VehicleInfo[vehicleid][vTrunkHealth] = 745.0;
			case 3: VehicleInfo[vehicleid][vTrunkHealth] = 900.0;
		}

		// Player vars sets
		BreakTrunkVehicleID[playerid] 	= vehicleid;
		BreakTrunkKickTick[playerid]		= gettimestamp();

		// 3dText - Destroy
		DestroyDynamic3DTextLabel(TrunkHealth3DText[vehicleid]);
		TrunkHealth3DText[vehicleid] = Text3D:INVALID_3DTEXT_ID;

		// Setting 3dtext
		new dTxt[35];
		format(dTxt, 35, "Trunk HP: {00CCCC}%.1f", VehicleInfo[vehicleid][vTrunkHealth]);
		TrunkHealth3DText[vehicleid] = CreateDynamic3DTextLabel(dTxt, 0x00CCCCFF, 0.0, -2.5947, -0.0456, 30.0, INVALID_PLAYER_ID, vehicleid, 0, -1, -1, playerid, 50.0);

		// Poruka i timer
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Udarajte po vozilu dok mu ne skinete health! Ne udaljavajte se od automobila!");
		Bit1_Set(gr_PlayerBreakingTrunk, playerid, true);
	}
	return 1;
}

CMD:fill(playerid, params[])
{
	new
		vehicleid = GetPlayerVehicleID(playerid),
		fuel;

	new bizid = GetNearestGasBiznis(playerid);
	if( bizid == INVALID_BIZNIS_ID ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Niste u blizini benzinske postaje!");
	if( ( vehicleid == 0 || vehicleid == -1 ) || IsABike( GetVehicleModel( vehicleid ) ) ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nepravilno vozilo!");
	if( sscanf(params, "i", fuel ) ) {
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /fill [litara]");
		return 1;
	}
	#if defined EVENTSTARTED
	SendClientMessage( playerid, COLOR_RED, "** Nema struje u pumpi **");
	return 1;
	#endif
	if( fuel > ( 100 - VehicleInfo[ vehicleid ][ vFuel ] ) ) return SendClientMessage(playerid, COLOR_RED, "U vase vozilo ne moze stati toliko goriva.");
	if( 1 <= fuel <= 100 ) {
	    if(AC_GetPlayerMoney(playerid) < BizzInfo[bizid][bGasPrice]) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate toliko novca!");
        PlayerToBusinessMoneyTAX(playerid, bizid, BizzInfo[bizid][bGasPrice] * fuel);
		VehicleInfo[ vehicleid ][ vFuel ] += fuel;
		GameTextForPlayer( playerid, "~g~Napunili se gorivo", 2000, 1 );

	} else SendMessage(playerid, MESSAGE_TYPE_ERROR, " Unos mora biti izmedju 1 i 100!");
	return 1;
}

CMD:showcostats(playerid, params[])
{
	new giveplayerid,
		globalstring[100];
	if (sscanf(params, "u", giveplayerid))
	{
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /showcostats [playerid/PartOfName]");
		return 1;
	}
    if(IsPlayerConnected(giveplayerid))
	{
        if(giveplayerid != INVALID_PLAYER_ID)
		{
            if(ProxDetectorS(3.0, playerid, giveplayerid))
			{
				if(PlayerInfo[playerid][pSpawnedCar] == -1) return SendClientMessage(playerid, COLOR_RED, "Niste spawnali vozilo!");
				new
					name[36];
				strunpack(name, Model_Name(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel]));
                format(globalstring, sizeof(globalstring), "Vozilo: %s [Model ID: %d] | Vlasnik: %s",
					name,
					VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vModel],
					GetName(playerid, true)
				);

				SendClientMessage(giveplayerid, COLOR_SKYBLUE, globalstring);
				if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate] != 0)
				{
				    format(globalstring, sizeof(globalstring), "Registriran    ||    Registracija: %s", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vNumberPlate]);
					SendClientMessage(giveplayerid, COLOR_WHITE, globalstring);
				}
				else SendClientMessage(giveplayerid, COLOR_WHITE, "Neregistriran");
				if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock] == 0) SendClientMessage(giveplayerid, COLOR_WHITE, "Kvaliteta brave: Nekvalitetna");
				else
				{
					format(globalstring, sizeof(globalstring), "Kvaliteta brave: %d", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vLock]);
					SendClientMessage(giveplayerid, COLOR_WHITE, globalstring);
				}
				if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob] == 0) SendClientMessage(giveplayerid, COLOR_WHITE, "Imobilizator: Nema");
				else
				{
				    format(globalstring, sizeof(globalstring), "Imobilizator level: %d", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vImmob]);
					SendClientMessage(giveplayerid, COLOR_WHITE, globalstring);
				}
				if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm] > 0)
				{
					format(globalstring, sizeof(globalstring), "Alarm level: %d", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vAlarm]);
					SendClientMessage(giveplayerid, COLOR_WHITE, globalstring);
				}
				else SendClientMessage(giveplayerid, COLOR_WHITE, "Alarm: Nema");
				va_SendClientMessage(giveplayerid, COLOR_WHITE, "Akumulator: %s", GetBatteryTypeString(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vBatteryType]));
				if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance] == 0) SendClientMessage(giveplayerid, COLOR_WHITE, "Osiguranje: Neosigurano");
				else
				{
					format(globalstring, sizeof(globalstring), "Osiguranje: %d", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vInsurance]);
					SendClientMessage(giveplayerid, COLOR_WHITE, globalstring);
				}
				if(VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vDestroys] == 0) SendClientMessage(giveplayerid, COLOR_WHITE, "Puta unisteno: Nikada");
				else
				{
				    format(globalstring, sizeof(globalstring), "Puta unisteno: %d", VehicleInfo[PlayerInfo[playerid][pSpawnedCar]][vDestroys]);
				    SendClientMessage(giveplayerid, COLOR_WHITE, globalstring);
				}
            }
			else SendClientMessage(playerid, COLOR_RED, "Nisi dovoljno blizu tog igraca!");
        }
    }
    return 1;
}

CMD:veh_plate(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1338) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Niste ovlasteni za koristenje komande!");
	if(!IsPlayerInAnyVehicle(playerid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Niste u vozilu!");
	new
		plate[8];
	if(sscanf(params, "s[8]", plate)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /veh_plate [tablica]");
	if(1 <= strlen(plate) <= 7) {
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		new
			vehicleid = GetPlayerVehicleID(playerid),
			tmpString[42];

		format(VehicleInfo[vehicleid][vNumberPlate], 8, "%s", plate);
    	SetVehicleNumberPlate(vehicleid, plate);

		format(tmpString, sizeof(tmpString), "[ ! ] Vasa nova registracija je %s", plate);
		SendClientMessage(playerid, COLOR_GREEN, tmpString);
		SendMessage(playerid, MESSAGE_TYPE_SUCCESS, "Parkirajte vase vozilo pa ga opet spawnajte da vidite vasu registraciju!");

		new
			bigquery[128];
		mysql_format(g_SQL, bigquery, sizeof(bigquery), "UPDATE `cocars` SET `numberplate` = '%e' WHERE `id` = '%d'",
			VehicleInfo[vehicleid][vNumberPlate],
			VehicleInfo[vehicleid][vSQLID]
		);
		mysql_tquery(g_SQL, bigquery);
	}
	return 1;
}

CMD:setcostats(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1337) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste ovlasteni!");
	new
		pick[10],
		input, vehicleid;
	if(sscanf(params, "s[10]i ", pick, vehicleid)) {
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats [odabir][vehicleid]");
		SendClientMessage(playerid, COLOR_GREY, "[ODABIR]: destroys - alarm - immob - lock - insurance");
		return 1;
	}
	if(!strcmp(pick, "destroys", true)) {
		if(sscanf(params, "s[10]ii", pick, vehicleid, input)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats destroys [kolicina]");
		if(input < 0 || input > 7) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nevaljan unos (0-7)!");
		if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste unijeli CO vozilo (/dl)!");
		VehicleInfo[vehicleid][vDestroys] = input;
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Namjestili ste unistenja na vozilu id %d na %d.", vehicleid, input);
	}
	else if(!strcmp(pick, "alarm", true)) {
		if(sscanf(params, "s[10]ii", pick, vehicleid, input)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats alarm [level]");
		if(input < 1 || input > 4) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nevaljan unos (1-4)!");
		if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste unijeli CO vozilo (/dl)!");
		VehicleInfo[vehicleid][vAlarm] = input;
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Namjestili ste alarm na vozilu id %d na level %d.", vehicleid, input);
	}
	else if(!strcmp(pick, "immob", true)) {
		if(sscanf(params, "s[10]ii", pick, vehicleid, input)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats immob [level]");
		if(input < 1 || input > 5) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nevaljan unos (1-5)!");
		if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste unijeli CO vozilo (/dl)!");
		VehicleInfo[vehicleid][vImmob] = input;
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Namjestili ste imobilizator na vozilu id %d na level %d.", vehicleid, input);
	}
	else if(!strcmp(pick, "lock", true)) {
		if(sscanf(params, "s[10]ii", pick, vehicleid, input)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats lock [level]");
		if(input < 1 || input > 3) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nevaljan unos (1-3)!");
		if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste unijeli CO vozilo (/dl)!");
		VehicleInfo[vehicleid][vLock] = input;
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Namjestili ste bravu na vozilu id %d na level %d.", vehicleid, input);
	}
	else if(!strcmp(pick, "insurance", true)) {
		if(sscanf(params, "s[10]ii", pick, vehicleid, input)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats lock [level]");
		if(input < 0 || input > 3) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nevaljan unos (0-3)!");
		if(!Iter_Contains(Vehicles[VEHICLE_USAGE_PRIVATE], vehicleid)) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste unijeli CO vozilo (/dl)!");
		VehicleInfo[vehicleid][vInsurance] = input;
		SendFormatMessage(playerid, MESSAGE_TYPE_INFO, "Namjestili ste osiguranje na vozilu id %d na level %d.", vehicleid, input);
	} else {
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /setcostats [odabir]");
		SendClientMessage(playerid, COLOR_GREY, "[ODABIR]: destroys - alarm - immob - lock - insurance");
	}
	return 1;
}

static
	enginet[MAX_PLAYERS];

CMD:engine(playerid, params[])
{
	#pragma unused params
		
	new
		engine, lights, alarm, doors, bonnet, boot, objective,
		vehicleid = GetPlayerVehicleID( playerid ),
		vstring[81],
		Float:vhp;
		
	GetVehicleHealth(vehicleid, vhp);
		
	if((enginet[playerid] > gettime()) && VehicleInfo[vehicleid][vDestroyed])
		return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Pricekajte prije ponovnog paljenja vozila!");
	
	new EngineChance = 1;

	if( PlayerWoundedAnim[playerid] ) 				return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ranjeni ste, trenutno niste u stanju upravljati vozilom!");
	if( IsABike(GetVehicleModel(vehicleid) ) ) 		return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nepravilno vozilo!");
	if( !IsPlayerInVehicle(playerid, vehicleid)) 	return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste unutar vozila!");
	if( GetPlayerState(playerid) != PLAYER_STATE_DRIVER ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Niste vozac auta!");
	if( VehicleInfo[vehicleid][vEngineScrewed]) 	return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozete upaliti motor jer je zaribao!");
	if( VehicleInfo[vehicleid][vOverHeated])		return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Ne mozete upaliti motor, svjecice su dotrajale.");
	if( VehicleInfo[vehicleid][vDestroyed] && vhp >= 255.0 && !VehicleInfo[vehicleid][vEngineRunning])
	{
		switch(random(99))
		{
			case 0 .. 15:
				format(vstring, sizeof(vstring), "* %s okrece kljuc te pali unisteno vozilo.", GetName(playerid, true));
			case 16 .. 99:
			{
				format(vstring, sizeof(vstring), "* %s pokusava upaliti unisteno vozilo ali ne uspijeva.", GetName(playerid, true));
				enginet[playerid] = gettime() + 2;
				return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nisi uspio upaliti motor! Koristi /engine kako bi pokusao ponovno.");
			}
		}
		SetPlayerChatBubble(playerid, vstring, COLOR_PURPLE, 20, 2000);
	}
	else if(VehicleInfo[vehicleid][vDestroyed] && vhp < 255.0)
		return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Vozilo se ne moze upaliti jer je motor unisten.");
		
	if(VehicleInfo[vehicleid][vEngineRunning]) {
		GameTextForPlayer(playerid, "~r~Motor iskljucen", 3000, 4);

		GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective);
		VehicleInfo[vehicleid][vEngineRunning] = 0;
	} else {
		if( !VehicleInfo[ vehicleid ][ vFuel ] ) 	return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Vozilo je ostalo bez goriva!");
		if( !VehicleInfo[ vehicleid ][ vCanStart ] && VehicleInfo[vehicleid][vGPS] && PlayerInfo[playerid][pJob] != 13) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Vozilo je unisteno! Zovite mehanicara na /call 555!");
		if( VehicleInfo[ vehicleid ][ vImpounded ] ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Vozilo je zaplijenjeno od strane policije!");

		#if defined MODULE_BOMBS
		foreach(new i : Player) {
			if( BombInfo[ i ][ bVehicleid ] == vehicleid ) {
				if( BombInfo[ i ][ bPlanted ] ) {
					DetonateBomb(i);
					return 1;
				}
			}
		}
		#endif

		if( PlayerInfo[ playerid ][ pSpawnedCar ] == vehicleid || PlayerInfo[ playerid ][ pVehKey ] == vehicleid || VehicleInfo[ vehicleid ][ vSpareKey1 ] == PlayerInfo[playerid][pSQLID] || VehicleInfo[ vehicleid ][ vSpareKey2 ] == PlayerInfo[playerid][pSQLID] ) {
			if( VehicleInfo[ vehicleid ][ vUsage ] == VEHICLE_USAGE_PRIVATE ) {

				VehicleInfo[vehicleid][vBatteryLife] 	-= 0.001;
				if(0.001 <= VehicleInfo[vehicleid][vBatteryLife] <= 5000.0) {
					switch(random(50)) {
						case 0 .. 25: { // Ne�e se uklju�iti
							GameTextForPlayer(playerid, "~r~Motor nije upalio radi slabog akumulatora", 3000, 1);

							GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
							SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
							VehicleInfo[vehicleid][vEngineRunning] = 0;
						}
						case 26 .. 50: { // Ho�e
							#if defined EVENTSTARTED
							EngineChance = random(2);
							#endif
							if(EngineChance == 1)
							{
								GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
								GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
								SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
								VehicleInfo[vehicleid][vEngineRunning] = 1;
							}
							else return GameTextForPlayer(playerid, "~r~Motor nije upalio~n~Problem s elektronikom~n~~g~Pokusajte opet", 3000, 1);
						}
					}
				} else { // Akumulator je u savrsenom stanju!

					if(VehicleInfo[vehicleid][vEngineLife] > 10000) {
						#if defined EVENTSTARTED
						EngineChance = random(2);
						#endif
						if(EngineChance == 1)
						{
							GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
							GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
							SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
							VehicleInfo[vehicleid][vEngineRunning] = 1;
						}
						else return GameTextForPlayer(playerid, "~r~Motor nije upalio~n~Problem s elektronikom~n~~g~Pokusajte opet", 3000, 1);
					}
					else if(1 <= VehicleInfo[vehicleid][vEngineLife] <= 10000)
					{
						switch(random(50)) {
							case 0 .. 25: {
								#if defined EVENTSTARTED
								EngineChance = random(2);
								#endif
								if(EngineChance == 1)
								{
									GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
									GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
									SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
									VehicleInfo[vehicleid][vEngineRunning] = 1;
								}
								else return GameTextForPlayer(playerid, "~r~Motor nije upalio~n~Problem s elektronikom~n~~g~Pokusajte opet", 3000, 1);
							}
							case 26 .. 50: {
								GameTextForPlayer(playerid, "~r~Motor nije upalio radi loseg motora", 3000, 1);
								GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
								SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
								VehicleInfo[vehicleid][vEngineRunning] = 0;
							}
						}
					}

				}
			}
		} else {
			switch( VehicleInfo[ vehicleid ][ vUsage ] )
			{
				case VEHICLE_USAGE_PRIVATE:
					StartHotWiring( playerid, vehicleid );
				case VEHICLE_USAGE_NORMAL, VEHICLE_USAGE_FACTION, VEHICLE_USAGE_JOB, VEHICLE_USAGE_LICENSE: {
         			GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
					GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
					VehicleInfo[vehicleid][vEngineRunning] = 1;
				}
				case VEHICLE_USAGE_RENT: {
					if( rentedVehID[playerid] == vehicleid ) {
						#if defined EVENTSTARTED
						EngineChance = random(2);
						#endif
						if(EngineChance == 1)
						{
							GameTextForPlayer(playerid, "~g~Motor ukljucen", 3000, 4);
							GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
							SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
							VehicleInfo[vehicleid][vEngineRunning] = 1;
						}
						else return GameTextForPlayer(playerid, "~r~Motor nije upalio~n~Problem s elektronikom~n~~g~Pokusajte opet", 3000, 1);
					} else return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate kljuc od ovog vozila!");
				}
			}
		}
	}
	return 1;
}

CMD:lock(playerid, params[])
{
	new vehicleid = GetNearestVehicle(playerid);
	if(vehicleid == INVALID_VEHICLE_ID) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste blizu vozila.");
	new
		engine, lights, alarm, doors, bonnet, boot, objective,
		string[ 47 ];
	GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );

	switch( VehicleInfo[ vehicleid ][ vUsage ] ) {
		case VEHICLE_USAGE_PRIVATE: {
			if( PlayerInfo[ playerid ][ pSpawnedCar ] != vehicleid && VehicleInfo[ vehicleid ][ vSpareKey1 ] != PlayerInfo[playerid][pSQLID] && VehicleInfo[ vehicleid ][ vSpareKey2 ] != PlayerInfo[playerid][pSQLID] ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate kljuc od ovoga vozila!");
			if( !VehicleInfo[ vehicleid ][ vLocked ] ) {
				GameTextForPlayer( playerid, "~w~Vozilo ~r~zakljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 1, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = true;

				format( string, sizeof(string), "* %s zakljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			
			} else {
				GameTextForPlayer( playerid, "~w~Vozilo ~g~otkljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 0, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = false;

				format( string, sizeof(string), "* %s otkljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			}
		}
		case VEHICLE_USAGE_JOB: {
			if( VehicleInfo[ vehicleid ][ vJob ] != PlayerInfo[ playerid ][ pJob ] ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate kljuc od ovog vozila!");
			if( !VehicleInfo[ vehicleid ][ vLocked ] ) {
				GameTextForPlayer( playerid, "~w~Vozilo ~r~zakljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 1, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = true;

				format( string, sizeof(string), "* %s zakljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			} else {
				GameTextForPlayer( playerid, "~w~Vozilo ~g~otkljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 0, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = false;

				format( string, sizeof(string), "* %s otkljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			}
		}
		case VEHICLE_USAGE_FACTION: {
			if( VehicleInfo[ vehicleid ][ vFaction ] != ( !PlayerInfo[playerid ][ pLeader ] ? PlayerInfo[playerid ][ pMember ] : PlayerInfo[playerid ][ pLeader ] ) ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate kljuc od ovog vozila!");
			if( !VehicleInfo[ vehicleid ][ vLocked ] ) {
				GameTextForPlayer( playerid, "~w~Vozilo ~r~zakljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 1, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = true;

				format( string, sizeof(string), "* %s zakljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			} else {
				GameTextForPlayer( playerid, "~w~Vozilo ~g~otkljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 0, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = false;

				format( string, sizeof(string), "* %s otkljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			}
		}
		case VEHICLE_USAGE_RENT: {
			if( rentedVehID[playerid] != vehicleid ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, " Nemate kljuc od ovog vozila!");
			if( !VehicleInfo[ vehicleid ][ vLocked ] ) {
				GameTextForPlayer( playerid, "~w~Vozilo ~r~zakljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 1, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = true;

				format( string, sizeof(string), "* %s zakljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			} else {
				GameTextForPlayer( playerid, "~w~Vozilo ~g~otkljucano", 800, 4 );
				SetVehicleParamsEx( vehicleid, engine, lights, alarm, 0, bonnet, boot, objective );
				VehicleInfo[ vehicleid ][ vLocked ] = false;

				format( string, sizeof(string), "* %s otkljucava vozilo.", GetName(playerid, true) );
				SetPlayerChatBubble(playerid, string, COLOR_PURPLE, 20, 20000);
			}
		}
	}
	return 1;
}
CMD:createvehicle(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1338) return SendClientMessage(playerid, COLOR_RED, "Nisi ovlasten za koristenje ove komande.");
	new
		model, color1, color2, respawndelay, usage, type, faction, job, Float:health,
		vehCarId, registracija[32],sirenon,
		Float:X, Float:Y, Float:Z, Float:Angle;

	new engine,lights,alarm,doors,bonnet,boot,objective;
	if(sscanf(params, "iiiiiiiifi", model, color1, color2, respawndelay, usage, type, faction, job, health, sirenon)) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /createvehicle [model][color1][color2][respawndelay][usage][type][faction][job][health][siren]");
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, Angle);

	vehCarId = AC_CreateVehicle(model, X, Y, Z, floatround(Angle), color1, color2, respawndelay, sirenon);
	ResetVehicleInfo(vehCarId);

	VehiclePrevInfo[vehCarId][vPosX] = X;
	VehiclePrevInfo[vehCarId][vPosY] = Y;
	VehiclePrevInfo[vehCarId][vPosZ] = Z;
	VehiclePrevInfo[vehCarId][vRotZ] = floatround(Angle);
	VehiclePrevInfo[vehCarId][vPosDiff] = 0.0;

	VehicleInfo[vehCarId][vModel]		= model;
	VehicleInfo[vehCarId][vParkX] 		= X;
	VehicleInfo[vehCarId][vParkY] 		= Y;
	VehicleInfo[vehCarId][vParkZ] 		= Z;
	VehicleInfo[vehCarId][vAngle] 		= floatround(Angle);
	VehicleInfo[vehCarId][vInt]			= GetPlayerInterior(playerid);
	VehicleInfo[vehCarId][vViwo]		= GetPlayerVirtualWorld(playerid);
	VehicleInfo[vehCarId][vFuel] 		= 100;
	VehicleInfo[vehCarId][vHealth] 		= health;

	SetVehicleVirtualWorld(vehCarId, GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(vehCarId, GetPlayerInterior(playerid));
	SetVehicleHealth(vehCarId, health);
	PutPlayerInVehicle(playerid, vehCarId, 0);

	GetVehicleParamsEx(vehCarId,engine,lights,alarm,doors,bonnet,boot,objective);
	SetVehicleParamsEx(vehCarId, IsABike(model) ? VEHICLE_PARAMS_ON : VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective);

	VehicleInfo[vehCarId][vUsage] = usage;
	VehicleInfo[vehCarId][vColor1] = color1;
	VehicleInfo[vehCarId][vColor2] = color2;
	VehicleInfo[vehCarId][vPaintJob] = 0;
	VehicleInfo[vehCarId][vBodyArmor] = 0;
	VehicleInfo[vehCarId][vTireArmor] = 0;

	ChangeVehiclePaintjob(vehCarId, 3);
	ChangeVehicleColor(vehCarId, color1, color2);

	new rand = 100000 + random(8999999);
	format(registracija, sizeof(registracija), "%d", rand);
	format(VehicleInfo[vehCarId][vNumberPlate], 8, "%s",registracija);
   	SetVehicleNumberPlate(vehCarId, registracija);

	VehicleInfo[vehCarId][vModel] 			= model;
	VehicleInfo[vehCarId][vType] 			= type;
	VehicleInfo[vehCarId][vAngle] 			= floatround(Angle);
	VehicleInfo[vehCarId][vRespawn] 		= respawndelay;
	VehicleInfo[vehCarId][vSirenon] 		= sirenon;
	VehicleInfo[vehCarId][vFaction] 		= faction;
	VehicleInfo[vehCarId][vJob] 			= job;
	VehicleInfo[vehCarId][vLocked] 			= 1;
	VehicleInfo[vehCarId][vInt] 			= GetPlayerInterior(playerid);
	VehicleInfo[vehCarId][vViwo] 			= GetPlayerVirtualWorld(playerid);
	VehicleInfo[vehCarId][vImpounded] 		= 0;
	VehicleInfo[vehCarId][vTravel] 			= 0;
	VehicleInfo[vehCarId][vEngineRunning]   = 0;
	VehicleInfo[vehCarId][vCanStart]        = 1;

	CreateNewVehicle(playerid, vehCarId);
	return 1;
}

CMD:cl(playerid, params[])
{
	new
		engine, lights, alarm, doors, bonnet, boot, objective,
		vehicle = GetPlayerVehicleID(playerid),
		modelid = GetVehicleModel(vehicle);

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "Morate biti vozac da bi ste mogli koristit ovu komandu.");
	if(IsABike(modelid) || IsAPlane(modelid) || IsABoat(modelid)) return SendClientMessage(playerid, COLOR_RED, "Nepoznata akcija.");

	if( !VehicleInfo[ vehicle ][ vLights ] ) {
	    VehicleInfo[ vehicle ][ vLights ] = 1;
		GetVehicleParamsEx(vehicle,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(vehicle,engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
		if( IsTrailerAttachedToVehicle( vehicle ) ) {
			GetVehicleParamsEx( GetVehicleTrailer( vehicle ),engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx( GetVehicleTrailer( vehicle ),engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
		}
	} else {
		VehicleInfo[ vehicle ][ vLights ] = 0;
		GetVehicleParamsEx(vehicle,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(vehicle,engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
		if( IsTrailerAttachedToVehicle( vehicle ) ) {
			GetVehicleParamsEx( GetVehicleTrailer( vehicle ),engine,lights,alarm,doors,bonnet,boot,objective);
			SetVehicleParamsEx( GetVehicleTrailer( vehicle ),engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
		}
	}
	return 1;
}
CMD:bonnet(playerid, params[])
{
    new engine,lights,alarm,doors,bonnet,boot,objective,vehicle = GetPlayerVehicleID(playerid),modelid = GetVehicleModel(vehicle);
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "Morate biti vozac da bi ste mogli koristit ovu komandu.");
	if(IsABike(modelid) || IsAPlane(modelid) || IsABoat(modelid)) return SendClientMessage(playerid, COLOR_RED, "Nepoznata akcija.");
	if(VehicleInfo[vehicle][vBonnets] == 0) {
	    VehicleInfo[vehicle][vBonnets] = 1;
		GetVehicleParamsEx(vehicle,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(vehicle,engine,lights,alarm,doors,VEHICLE_PARAMS_ON,boot,objective);
	} else {
		VehicleInfo[vehicle][vBonnets] = 0;
		GetVehicleParamsEx(vehicle,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(vehicle,engine,lights,alarm,doors,VEHICLE_PARAMS_OFF,boot,objective);
	}
	return 1;
}

CMD:fillcar(playerid, params[])
{
	if( !PlayerInfo[ playerid ][ pCanisterLiters ] || PlayerInfo[ playerid ][ pCanisterType ] == -1 ) return SendClientMessage( playerid, COLOR_RED, "[GRESKA]: Niste usipali nista u svoj kanister!");
	new
		vehicleid = GetPlayerVehicleID(playerid);
	if( ( vehicleid == 0 || vehicleid == INVALID_VEHICLE_ID ) || IsABike( GetVehicleModel( vehicleid ) ) ) return SendClientMessage( playerid, COLOR_RED, "[GRESKA]: Nepravilno vozilo!" );
	if( VehicleInfo[ vehicleid ][ vFuel ] >= 75 ) return SendClientMessage( playerid, COLOR_RED, "[GRESKA]: Vase vozilo moze voziti!");
	
	if( PlayerInfo[ playerid ][ pCanisterType ] == ENGINE_TYPE_PETROL ) 
	{
		if( VehicleInfo[ vehicleid ][ vEngineType ] == ENGINE_TYPE_DIESEL )
			VehicleInfo[ vehicleid ][ vEngineLife ] -= 25.0;
	}
	else if( PlayerInfo[ playerid ][ pCanisterType ] == ENGINE_TYPE_DIESEL ) 
	{
		if( VehicleInfo[ vehicleid ][ vEngineType ] == ENGINE_TYPE_PETROL )
			VehicleInfo[ vehicleid ][ vEngineLife ] -= 25.0;
	}
	VehicleInfo[ vehicleid ][ vFuel ] += PlayerInfo[ playerid ][ pCanisterLiters ];
	PlayerInfo[ playerid ][ pCanisterLiters ] 	= 0;
	PlayerInfo[ playerid ][ pCanisterType ] 	= -1;
	return 1;
}

CMD:get(playerid, params[])
{
	new
		param[6];
	if( sscanf( params, "s[6] ", param ) ) {
		SendClientMessage(playerid, COLOR_RED, "[ ? ]: /get [opcija]");
		SendClientMessage(playerid, COLOR_RED, "[ ! ] fuel");
	}
	if( !strcmp( param, "fuel", true ) )
	{
		new
			type, fuel, total;
			
		if( sscanf( params, "s[6]ii", param, type, fuel ) ) return SendClientMessage(playerid, COLOR_RED, "[ ? ]: /get fuel [0 - Benzin, 1 - Dizel][kolicina]");
		if( !IsPlayerNearGasStation( playerid ) ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste blizu benzinske stanice!");
		total = PlayerInfo[ playerid ][ pCanisterLiters ] + fuel;
		if (total > 25 ) return SendFormatMessage(playerid, MESSAGE_TYPE_ERROR, "Maksimalno 25 litara, treutno imate %d", PlayerInfo[ playerid ][ pCanisterLiters ]);
		if( type > 1 || type < 0 ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Tip mora biti izmedju 0 i 1!");
		if( 1 <= fuel <= 25 ) 
		{
			new
				moneys;
			switch( type ) 
			{
				case 0:  { // Benzin
					moneys = (fuel * 4);
					switch( PlayerInfo[playerid][pDonateRank] ) {
						case 1:
							moneys /= 4;
						case 2:
							moneys /= 2;
						case 3,4:
							moneys = 0;
					}
				}
				case 1:  {// Dizel
					moneys = (fuel * 3);
					switch( PlayerInfo[playerid][pDonateRank] ) {
						case 1:
							moneys /= 4;
						case 2:
							moneys /= 2;
						case 3,4:
							moneys = 0;
					}
				}
			}
			moneys = floatround(moneys);
			if( AC_GetPlayerMoney( playerid ) <  moneys) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Nemate toliko novca!");
			new bizid = GetNearestGasBiznis(playerid);
			if( bizid == INVALID_BIZNIS_ID ) return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Niste u blizini benzinske postaje!");
			
			PlayerToBusinessMoneyTAX(playerid, bizid, moneys);
			new
				gasTillQuery[ 100 ];
				
			format( gasTillQuery, sizeof(gasTillQuery), "UPDATE `bizzes` SET  `till` = '%d' WHERE `id` = '%d'", 
				BizzInfo[ bizid ][ bTill ],
				BizzInfo[ bizid ][bSQLID]
			);
			mysql_tquery( g_SQL, gasTillQuery, "", "");
			
			PlayerInfo[ playerid ][ pCanisterLiters ] 	+= fuel;
			PlayerInfo[ playerid ][ pCanisterType ] 	= type;
			va_SendClientMessage( playerid, COLOR_RED, "[ ! ] Uspjesno ste napunili kanister s %d litara. Mozete koristiti /fillcar unutar zeljena vozila!", fuel);
		} 
		else return SendMessage(playerid, MESSAGE_TYPE_ERROR, "Unos mora biti izmedju 1 i 25 litara!");
	}
	return 1;
}