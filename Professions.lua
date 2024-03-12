local ADDON_PREFIX = "YYProfessions"
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

local function SerializeProfessionData()
    if YippYappGuildTools_ProfessionsDB then
        local serializedString = AceSerializer:Serialize(YippYappGuildTools_ProfessionsDB)
        return serializedString
    else
        print(string.format(localeTable.failedToSerialize))
        return nil
    end
end

local function SendProfessionDataToGuild()    
    local serializedData = SerializeProfessionData()    
    if serializedData then
        AceComm:SendCommMessage(ADDON_PREFIX, serializedData, "GUILD")
    end
end

function RequestLatestProfessionData()    
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
        YippYappGuildTools_ProfessionsDB[characterName].lastUpdated = characterInfo.lastUpdated
        YippYappGuildTools_ProfessionsDB[characterName].level = characterInfo.level
    else
        -- Add new character data
        YippYappGuildTools_ProfessionsDB[characterName] = {
            name = characterName,
            level = characterInfo.level,
            class = characterInfo.class,            
            lastUpdated = characterInfo.lastUpdated,
            professions = professionInfo,
        }
    end

    UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)
    SendProfessionDataToGuild() 
end

-- Helper function to compare tables (simplified and specific for your use case)
    function AreTablesEqual(table1, table2)
        if #table1 ~= #table2 then return false end
        for i, v in ipairs(table1) do
            if table2[i] ~= v then return false end
        end
        return true
    end

-- Registering the addon communication channel
AceComm:RegisterComm(ADDON_PREFIX, function(prefix, message, distribution, sender)    
    local playerName = UnitName("player")
    if sender == playerName then
        return -- Avoid processing messages from self
    end
    
    if message == "request" then
        -- Handle the request for profession data       
        SendProfessionDataToGuild()
    else
        local success, incomingData = AceSerializer:Deserialize(message)
        if success then
            for characterName, professionInfo in pairs(incomingData) do
                -- If the character does not exist in the local DB, or the incoming data is more recent, update it
                if not YippYappGuildTools_ProfessionsDB[characterName] or (YippYappGuildTools_ProfessionsDB[characterName].lastUpdated < professionInfo.lastUpdated) then
                    YippYappGuildTools_ProfessionsDB[characterName] = professionInfo
                end
            end
            -- UpdateProfessionsContent
            UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)
        else
            print(string.format(localeTable.failedToDeserialize, sender))
        end
    end
end) 


