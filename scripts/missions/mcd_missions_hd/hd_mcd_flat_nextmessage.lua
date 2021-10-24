-- load the base file
module("hd_mcd_flat.lua")

MISSION.MessageList = {
	hd_mcd01 = {
		script = "message.bankjob",
		length = 15.0,
		delay = 2.0,
		environment = "day_clear"
	},
	hd_mcd02 = {
		script = "message.hidetheevidence",
		length = 25.0,
		delay = 2.0,
		environment = "day_clear"
	},
	hd_mcd03 = {
		script = "message.ticcosride",
		length = 13.0,
		delay = 2.0,
		environment = "night_clear"
	},
	hd_mcd04a = {
		script = "message.cleanup",
		length = 25.5,
		delay = 2.0,
		environment = "day_clear"
	},
	hd_mcd05a = {
		script = "message.caseforakey",
		length = 11.0,
		delay = 2.0,
		environment = "night_clear"
	},
	hd_mcd06 = {
		script = "message.meetrufus",
		length = 16.0,
		delay = 2.0,
		environment = "day_clear"
	},
	hd_mcd08 = {
		script = "message.payback",
		length = 12.0,
		delay = 2.0,
		environment = "day_clear"
	},
	hd_mcd09 = {
		script = "message.shipmentcomingin",
		length = 13.0,
		delay = 2.0,
		environment = "night_stormy_norain"
	},
	hd_mcd10 = {
		script = "message.superflydrive",
		length = 39.0,
		delay = 2.0,
		environment = "night_clear"
	},
	hd_mcd11 = {
		script = "message.diangio",
		length = 16.5,
		delay = 2.0,
		environment = "night_clear"
	},
	hd_mcd12 = {
		script = "message.baitforatrap",
		length = 14.5,
		delay = 2.0,
		environment = "day_clear"
	},
}