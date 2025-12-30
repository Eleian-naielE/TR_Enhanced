--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              Corey
--*   @Date:                2017-12-18T14:01:09+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            GCZsinjCampaign.lua
--*   @Last modified by:
--*   @Last modified time:  2018-02-05T07:33:34-05:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("PGBase")
require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")
require("eawx-util/ChangeOwnerUtilities")
require("eawx-util/PopulatePlanetUtilities")
StoryUtil = require("eawx-util/StoryUtil")
require("deepcore/crossplot/crossplot")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    StoryModeEvents = {
        Determine_Faction_LUA = Find_Faction,
        Zsinj_Death = On_Zsinj_Death,
        Spawn_Leia = Leia_Spawn,
        Spawn_Leia_Again = Leia_Respawn,
        Spawn_Hapans = Get_Hapes,
        Zsinj_Centares = Centares_Zsinj,
		Delayed_Initialize = Initialize,
		No_Iblis_for_sure = No_Iblis
    }
end

function Find_Faction(message)
    if message == OnEnter then
        p_newrep = Find_Player("Rebel")
        p_empire = Find_Player("Empire")
        p_eoth = Find_Player("EmpireoftheHand")
        p_eriadu = Find_Player("Eriadu_Authority")
        p_pentastar = Find_Player("Pentastar")
        p_zsinj = Find_Player("Zsinj_Empire")
        p_maldrood = Find_Player("Greater_Maldrood")
        p_csa = Find_Player("Corporate_Sector")

        if p_newrep.Is_Human() then
            Story_Event("ENABLE_BRANCH_NEWREP_FLAG")
        elseif p_empire.Is_Human() then
            Story_Event("ENABLE_BRANCH_EMPIRE_FLAG")
        elseif p_eoth.Is_Human() then
            Story_Event("ENABLE_BRANCH_EOTH_FLAG")
        elseif p_eriadu.Is_Human() then
            Story_Event("ENABLE_BRANCH_ERIADU_FLAG")
        elseif p_pentastar.Is_Human() then
            Story_Event("ENABLE_BRANCH_PENTASTAR_FLAG")
        elseif p_zsinj.Is_Human() then
            Story_Event("ENABLE_BRANCH_ZSINJ_FLAG")
        elseif p_maldrood.Is_Human() then
            Story_Event("ENABLE_BRANCH_TERADOC_FLAG")
        elseif p_csa.Is_Human() then
            Story_Event("ENABLE_BRANCH_CSA_FLAG")
        end
    end
end

function Initialize(message)
    if message == OnEnter then
		
		crossplot:galactic()
		crossplot:publish("INITIALIZE_AI", "empty")
		crossplot:publish("NR_ADMIRAL_DECREMENT", 2, 1)
		crossplot:publish("NR_ADMIRAL_LOCKIN", {"Han_Solo_Mon_Remonda"}, 1)
		crossplot:publish("NR_ADMIRAL_EXIT", {"Iblis"}, 1)
	else
		crossplot:update()
    end
end

function No_Iblis(message)
    if message == OnEnter then
		crossplot:publish("NR_ADMIRAL_EXIT", {"Iblis"}, 1)
	else
		crossplot:update()
    end
end

function On_Zsinj_Death(message)
    if message == OnEnter then
        local p_empire = Find_Player("Empire")
        local p_rebel = Find_Player("Rebel")
        local p_maldrood = Find_Player("Greater_Maldrood")
        local p_corporate = Find_Player("Corporate_Sector")
        local p_zsinj = Find_Player("Zsinj_Empire")

        --Post-Zsinj, Kosh merges with Treutan
        local start_planet = FindPlanet("Centares")
        if TestValid(start_planet) then
            if start_planet.Get_Owner() == p_maldrood then
                spawn_list_kosh = {"Kosh_Lancet"}
                KoshSpawn = SpawnList(spawn_list_kosh, start_planet, p_maldrood, true, false)
            end
        end

        --Corporate Sector Spawns

        start_planet = FindPlanet("Etti")
        if TestValid(start_planet) then
            if start_planet.Get_Owner() == p_zsinj then
               
                ChangePlanetOwnerAndPopulate(start_planet, p_corporate, 7500)
            end
        end

        start_planet = FindPlanet("Ession")
        if TestValid(start_planet) then
            if start_planet.Get_Owner() == p_zsinj then

                ChangePlanetOwnerAndPopulate(start_planet, p_corporate, 7500)
            end
        end

        start_planet = FindPlanet("Bonadan")
        if TestValid(start_planet) then
            if start_planet.Get_Owner() == p_zsinj then
                ChangePlanetOwnerAndPopulate(start_planet, p_corporate, 7500)
            end
        end
    elseif message == OnUpdate then
    end
end

function Leia_Spawn(message)
    if message == OnEnter then
        p_rebel = Find_Player("Rebel")
        start_planet = FindPlanet("Coruscant")
        if TestValid(start_planet) then
            if not StoryUtil.CheckFriendlyPlanet(start_planet,p_rebel) then
				start_planet = StoryUtil.FindFriendlyPlanet(p_rebel)
			end

            spawn_list_requiem = {"Princess_Leia_Team"}
            LeiaSpawn = SpawnList(spawn_list_requiem, start_planet, p_rebel, true, false)
        end
    end
end

function Leia_Respawn(message)
    if message == OnEnter then
        p_rebel = Find_Player("Rebel")
        start_planet = FindPlanet("Coruscant")
        if TestValid(start_planet) then
            if not StoryUtil.CheckFriendlyPlanet(start_planet,p_rebel) then
				start_planet = StoryUtil.FindFriendlyPlanet(p_rebel)
			end

            spawn_list_requiem = {"Princess_Leia_Team"}
            LeiaSpawn = SpawnList(spawn_list_requiem, start_planet, p_rebel, true, false)
        end
    end
end

function Get_Hapes(message)
    if message == OnEnter then
        p_rebel = Find_Player("Rebel")
        p_hapans = Find_Player("Hapes_Consortium")
        start_planet = FindPlanet("Hapes")

        ChangePlanetOwnerAndPopulate(start_planet, p_rebel, 10000, p_hapans)

        spawn_list_hapan = {"Isolder_Song_of_War"}
        HapesSpawn = SpawnList(spawn_list_hapan, start_planet, p_rebel, true, false)

        start_planet = FindPlanet("Charubah")
        ChangePlanetOwnerAndPopulate(start_planet, p_rebel, 500, p_hapans)

        start_planet = FindPlanet("Terephon")
        ChangePlanetOwnerAndPopulate(start_planet, p_rebel, 500, p_hapans)

        start_planet = FindPlanet("Transitory_Mists_I")
        ChangePlanetOwnerAndPopulate(start_planet, p_rebel, 500, p_hapans)

        start_planet = FindPlanet("Transitory_Mists_II")
        ChangePlanetOwnerAndPopulate(start_planet, p_rebel, 500, p_hapans)
        
        start_planet = FindPlanet("Transitory_Mists_III")
        ChangePlanetOwnerAndPopulate(start_planet, p_rebel, 500, p_hapans)
        
    end
end

function Centares_Zsinj(message)
    if message == OnEnter then
        p_zsinj = Find_Player("Zsinj_Empire")
        start_planet = FindPlanet("Centares")

        if start_planet.Get_Owner() == Find_Player("Zsinj_Empire") then
            if p_zsinj.Is_Human() then
                Story_Event("SELIT_JOINS_SPEECH")
            end
            spawn_list_selit = {"Selit_Team"}
            SpawnList(spawn_list_selit, start_planet, p_zsinj, true, false)
        --end
        end
    end
end

function Exit_Iblis(message)
  if message == OnEnter then
	Story_Event("NR_ADMIRAL_IBLIS_EXIT")
  end
end
