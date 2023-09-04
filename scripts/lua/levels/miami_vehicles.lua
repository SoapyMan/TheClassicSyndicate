local FreeRideVehicleSet = {
    CopVehicles = {
        default = {
            Patrol = {
                NPC_mcd_defaultpolicecar_black   = { },
                --cop_k5      = { minFelony = 0.75 }
            },
            RoadBlock = {
                NPC_mcd_defaultpolicecar_black   = { },
                --cop_k5      = { minFelony = 0.75 }
            },
        }
    },
    Traffic = {
        default = {
            npc_mcd_traffic01       = {},
            npc_mcd_traffic02		= {},
            NPC_mcd_defaultpolicecar_black	= { interval = 20, traffic = false }, -- cops are spawn by the requests
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