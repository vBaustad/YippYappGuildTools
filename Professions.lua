local ADDON_PREFIX = "YTProfessions"
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

local function getProfessionsAndSkill()
    local validName = {
        ["Engineering"] = true,
        ["Enchanting"] = true,
        ["Alchemy"] = true,
        ["Blacksmithing"] = true,
        ["Find Herbs"] = true,
        ["Leatherworking"] = true,
        ["Find Minerals"] = true,
        ["Skinning"] = true,
        ["Tailoring"] = true,
        -- ["Fishing"] = true,
        -- ["First Aid"] = true,
        -- ["Cooking"] = true,
    }
    
    -- Mapping table for name replacements
    local nameReplacement = {
        ["Find Herbs"] = "Herbalism",
        ["Find Minerals"] = "Mining",
    }

    local professions = {}
    
    -- Get all professions learned on character
    for i = 1, GetNumSpellTabs() do
        local offset, numSlots = select(3, GetSpellTabInfo(i))
        for j = offset+1, offset+numSlots do
            local spellName, spellSubName, spellID = GetSpellBookItemName(j, BOOKTYPE_SPELL)
            if validName[spellName] then  
                local displayName = nameReplacement[spellName] or spellName              
                table.insert(professions, {displayName, spellSubName, spellID})               
            end
        end
    end    
    return professions
end

local function SerializeProfessionData(characterName)
    if YippYappGuildTools_ProfessionsDB[characterName] then
        local dataToSerialize = YippYappGuildTools_ProfessionsDB[characterName]
        local serializedString = AceSerializer:Serialize(dataToSerialize)
        return serializedString
    else
        print("Character data for serialization not found.")
        return nil
    end
end

local function SendProfessionDataToGuild(characterName)    
    local serializedData = SerializeProfessionData(characterName)    
    if serializedData then
        AceComm:SendCommMessage(ADDON_PREFIX, serializedData, "GUILD")
    end
end

function RequestLatestProfessionData() 
    print("SendCommMessage") 
    AceComm:SendCommMessage(ADDON_PREFIX, "request", "GUILD")
end

function InitializeProfessionsFeature(YippYappGuildTools_ProfessionsDB)
    
    local characterInfo = GetCharacterInfo()    
    local professionInfo = getProfessionsAndSkill()    

    -- Character name acts as a unique key
    local characterName = characterInfo.name
        
    -- Check if the character already exists in YippYappGuildTools_ProfessionsDB
    if YippYappGuildTools_ProfessionsDB[characterName] then
        -- Update existing character data
        YippYappGuildTools_ProfessionsDB[characterName].professions = professionInfo
        YippYappGuildTools_ProfessionsDB[characterName].character = characterInfo
    else
        -- Add new character data
        YippYappGuildTools_ProfessionsDB[characterName] = {
            name = characterName,  -- Assuming characterName is a string variable with the character's name
            level = characterInfo.level,
            class = characterInfo.class,
            professions = professionInfo,
            lastUpdated = characterInfo.lastUpdated  -- Assuming this timestamp is generated when updating
        }
    end

    --UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)
    SendProfessionDataToGuild(characterName) 
end

-- Registering the addon communication channel
AceComm:RegisterComm(ADDON_PREFIX, function(prefix, message, distribution, sender)    
    local playerName = UnitName("player")
    if sender == playerName then
        return -- Avoid processing messages from self
    end
    
    if message == "request" then
        -- Handle the request for profession data
        local characterName = UnitName("player")
        local serializedData = SerializeProfessionData(characterName)
        if serializedData then
            AceComm:SendCommMessage(ADDON_PREFIX, serializedData, "GUILD")
        end
    else
        local success, characterData = AceSerializer:Deserialize(message)
        if success then
            if not AreTablesEqual(YippYappGuildTools_ProfessionsDB[characterData.name], characterData) then
                YippYappGuildTools_ProfessionsDB[characterData.name] = characterData
                --UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)
            end
        else
            print("Failed to deserialize data from", sender)
        end
    end
end) 


-- Helper function to compare tables (simplified and specific for your use case)
function AreTablesEqual(table1, table2)
    if #table1 ~= #table2 then return false end
    for i, v in ipairs(table1) do
        if table2[i] ~= v then return false end
    end
    return true
end