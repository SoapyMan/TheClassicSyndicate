-- load the base file
module("mcd_flat.lua")

MISSION.MessageList = {
	mcd01 = {
		script = "message.bankjob",
		length = 15.0,
		delay = 2.0,
		environment = "day_clear"
	},
	mcd02 = {
		script = "message.hidetheevidence",
		length = 25.0,
		delay = 2.0,
		environment = "day_clear"
	},
	mcd03 = {
		script = "message.ticcosride",
		length = 13.0,
		delay = 2.0,
		environment = "night_clear"
	},
	mcd04a = {
		script = "message.cleanup",
		length = 25.5,
		delay = 2.0,
		environment = "day_clear"
	},
	mcd05a = {
		script = "message.caseforakey",
		length = 11.0,
		delay = 2.0,
		environment = "night_clear"
	},
	mcd06 = {
		script = "message.meetrufus",
		length = 16.0,
		delay = 2.0,
		environment = "day_clear"
	},
	mcd08 = {
		script = "message.payback",
		length = 12.0,
		delay = 2.0,
		environment = "day_clear"
	},
	mcd09 = {
		script = "message.shipmentcomingin",
		length = 13.0,
		delay = 2.0,
		environment = "night_stormy_norain"
	},
	mcd10 = {
		script = "message.superflydrive",
		length = 39.0,
		delay = 2.0,
		environment = "night_clear"
	},
	mcd11 = {
		script = "message.diangio",
		length = 16.5,
		delay = 2.0,
		environment = "night_clear"
	},
	mcd12 = {
		script = "message.baitforatrap",
		length = 14.5,
		delay = 2.0,
		environment = "day_clear"
	},
}