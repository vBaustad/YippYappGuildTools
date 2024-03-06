local ADDON_PREFIX = "YYBlacklist"
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

local function SerializeBlacklistData()    
    local dataToSerialize = YippYappGuildTools_BlacklistDB
    local serializedString = AceSerializer:Serialize(dataToSerialize)
    return serializedString
end

local function SendBlacklistDataToGuild()
    local serializedData = SerializeBlacklistData()    
    if serializedData then
        AceComm:SendCommMessage(ADDON_PREFIX, serializedData, "GUILD")
    end
end

function RequestLatestBlacklistData()      
    AceComm:SendCommMessage(ADDON_PREFIX, "request", "GUILD")
end

function AddToBlacklist(characterName, characterClass, blacklistReason)

    -- Prevent duplicate entries    
    if not YippYappGuildTools_BlacklistDB[characterName] then
        local characterInfo = {name = characterName, class = characterClass, reason = blacklistReason}
        YippYappGuildTools_BlacklistDB[characterName] = characterInfo        
    else
        -- If the character is already in the blacklist, you might want to update or skip
        print(characterName .. " is already in the blacklist.")
    end
    
    SendBlacklistDataToGuild(characterName) 
end

local function RemoveFromBlacklist(characterName)
    YippYappGuildTools_BlacklistDB[characterName] = nil
end

function IsCharacterBlacklisted(characterName)
    if YippYappGuildTools_BlacklistDB[characterName] then
        print(characterName .. " is blacklisted as a " .. YippYappGuildTools_BlacklistDB[characterName].class)
        return true
    else
        print(characterName .. " is not in the blacklist.")
        return false
    end
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
        local success, receivedData  = AceSerializer:Deserialize(message)
        if success then
            for characterName, characterClass in pairs(receivedData) do
                YippYappGuildTools_BlacklistDB[characterName] = characterClass
            end
            UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
        else
            print("Failed to deserialize data from", sender)
        end
    end
end) 