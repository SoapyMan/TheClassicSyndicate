local FreeRideVehicleSet = {
    CopVehicles = {
        default = {
            Patrol = {
                npc_mcd_defaultpolicecar_white   = { },
                --cop_k5      = { minFelony = 0.75 }
            },
            RoadBlock = {
                npc_mcd_defaultpolicecar_white   = { },
                --cop_k5      = { minFelony = 0.75 }
            },
        }
    },
    Traffic = {
        default = {
            npc_mcd_traffic01       = {},
            npc_mcd_traffic02		= {},
            npc_mcd_defaultpolicecar_white	= { interval = 20, traffic = false }, -- cops are spawn by the requests
        },
    }
}

local GameModeVehicleSets = {
    ["freeride"] = FreeRideVehicleSet,
    --["minigames/survival"] = SurvivalVehicleSet
}

local vehicleSet = GameModeVehicleSets[MissionManager:GetGameMode()]

-- always return freeride set if no corresponding gamemode set has been found
return vehicleSet or FreeRideVehicleSet