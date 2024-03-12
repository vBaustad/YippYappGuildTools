local ADDON_PREFIX = "YYBlacklist"
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

function RemoveFromBlacklist(characterName)
    YippYappGuildTools_BlacklistDB[characterName] = nil
end

local function SerializeBlacklistData()    
    local dataToSerialize = YippYappGuildTools_BlacklistDB
    local serializedString = AceSerializer:Serialize(dataToSerialize)
    return serializedString
end

function SendBlacklistDataToGuild()
    local serializedData = SerializeBlacklistData()    
    if serializedData then
        AceComm:SendCommMessage(ADDON_PREFIX, serializedData, "GUILD")
    else
        print(string.format(localeTable.failedToSerialize))
        return nil
    end
end

function RequestLatestBlacklistData()      
    AceComm:SendCommMessage(ADDON_PREFIX, "request", "GUILD")
end

function AddToBlacklist(characterData)
    --rename to UpdateOrAddCharacterlater 
    local existingEntry = YippYappGuildTools_BlacklistDB[characterName]
    if not existingEntry or existingEntry.lastUpdated < characterData.lastUpdated then
        
    end
    -- Prevent duplicate entries    
    if not YippYappGuildTools_BlacklistDB[characterName] then
        local characterInfo = {name = characterName, class = characterClass, reason = blacklistReason}
        YippYappGuildTools_BlacklistDB[characterName] = characterInfo        
    else
        -- If the character is already in the blacklist, you might want to update or skip
        print(string.format(localeTable["alreadyInBlacklist"], characterName))
    end
    
    SendBlacklistDataToGuild(characterName) 
end

function IsCharacterBlacklisted(characterName)
    if YippYappGuildTools_BlacklistDB[characterName] then
        print(string.format(localeTable["blacklistedAsClass"], characterName, YippYappGuildTools_BlacklistDB[characterName].class))        
        return true
    else
        print(string.format(localeTable["notInBlacklist"], characterName))
        return false
    end
end

function checkPartyMembersAgainstBlacklist()

    if not IsInGroup() then
        blacklistNotificationPlayed = false -- Reset flag when not in a group
        return
    end

    local numGroupMembers = GetNumGroupMembers()
    local blacklistMemberFound = false

    for i = 1, numGroupMembers do
        -- For party use 'partyN', for raid 'raidN'
        local unitId = IsInRaid() and "raid" .. i or "party" .. i
        local name = UnitName(unitId)
        local characterName = name

        if YippYappGuildTools_BlacklistDB[characterName] then
            blacklistMemberFound = true
            if not blacklistNotificationPlayed then
                PlaySound(8959) -- Play a notification sound, this ID is an example
                print(characterName .. " is in your blacklist!")
                blacklistNotificationPlayed = true
            end
            break-- Exit the loop after finding the first blacklisted member  
        end
    end
    if not blacklistMemberFound then
        blacklistNotificationPlayed = false -- Reset flag if no blacklisted members are found
    end
end

-- Registering the addon communication channel
AceComm:RegisterComm(ADDON_PREFIX, function(prefix, message, distribution, sender)    
    local playerName = UnitName("player")
    if sender == playerName then
        return -- Avoid processing messages from self
    end
    
    if message == "request" then 
        -- Handle the request for blacklist data
        SendBlacklistDataToGuild()
    else
        local success, receivedData  = AceSerializer:Deserialize(message)
        if success then
            for characterName, characterClass in pairs(receivedData) do
                YippYappGuildTools_BlacklistDB[characterName] = characterClass
            end
            UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
        else
            print(string.format(localeTable.failedToDeserialize, sender))
        end
    end
end) 