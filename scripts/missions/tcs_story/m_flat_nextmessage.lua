-- load the base file
module("m_flat.lua")

MISSION.AnsweringMachines = {
	vec3(-60.0648, 0.959353, 39.1427),	-- Miami flat
}

MISSION.MessageList = {
	m_01 = {
		script = "message.bankjob",
		length = 16.0,
		delay = 2.0,
		environment = "day_clear"
	},
	m_02 = {
		script = "message.hidetheevidence",
		length = 25.0,
		delay = 2.0,
		environment = "day_clear"
	},
	m_03 = {
		script = "message.ticcosride",
		length = 13.0,
		delay = 2.0,
		environment = "night_clear"
	},
	m_04a = {
		script = "message.cleanup",
		length = 25.5,
		delay = 2.0,
		environment = "day_clear"
	},
	m_05a = {
		script = "message.caseforakey",
		length = 11.0,
		delay = 2.0,
		environment = "night_clear"
	},
	m_06 = {
		script = "message.meetrufus",
		length = 16.0,
		delay = 2.0,
		environment = "day_clear"
	},
	m_08 = {
		script = "message.payback",
		length = 12.0,
		delay = 2.0,
		environment = "day_clear"
	},
	m_09 = {
		script = "message.shipmentcomingin",
		length = 13.0,
		delay = 2.0,
		environment = "night_clear"
	},
	m_10 = {
		script = "message.superflydrive",
		length = 39.0,
		delay = 2.0,
		environment = "night_clear"
	},
	m_11 = {
		script = "message.diangio",
		length = 16.5,
		delay = 2.0,
		environment = "night_clear"
	},
	m_12 = {
		script = "message.baitforatrap",
		length = 14.5,
		delay = 2.0,
		environment = "day_clear"
	},
}