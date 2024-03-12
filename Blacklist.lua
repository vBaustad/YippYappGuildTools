local ADDON_PREFIX = "YYBlacklist"
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

-- Update timestamp function
local function UpdateTimestamp()
    YippYappGuildTools_BlacklistDB.lastUpdated = GetServerTime()
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
    if not YippYappGuildTools_BlacklistDB[characterData.name] then
        YippYappGuildTools_BlacklistDB[characterData.name] = {class = characterData.class, reason = characterData.reason}
        UpdateTimestamp() -- Update the global timestamp
        SendBlacklistDataToGuild()  -- Optionally trigger a sync after updating
    end    
end

function RemoveFromBlacklist(characterName)
    if YippYappGuildTools_BlacklistDB[characterName] then
        YippYappGuildTools_BlacklistDB[characterName] = nil
        UpdateTimestamp() -- Update the global timestamp
        SendBlacklistDataToGuild() -- Optionally trigger a sync after updating
    end
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

function CheckPartyMembersAgainstBlacklist()

    if not IsInGroup() then
        BlacklistNotificationPlayed = false -- Reset flag when not in a group
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
            if not BlacklistNotificationPlayed then
                PlaySound(8959) -- Play a notification sound, this ID is an example
                print(characterName .. " is in your blacklist!")
                BlacklistNotificationPlayed = true
            end
            break-- Exit the loop after finding the first blacklisted member  
        end
    end
    if not blacklistMemberFound then
        BlacklistNotificationPlayed = false -- Reset flag if no blacklisted members are found
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
            -- If the local DB is empty or the incoming DB is more recent, update it
            if not YippYappGuildTools_BlacklistDB.lastUpdated or YippYappGuildTools_BlacklistDB.lastUpdated == 0 or receivedData.lastUpdated > YippYappGuildTools_BlacklistDB.lastUpdated then
                YippYappGuildTools_BlacklistDB = receivedData
                -- Refresh your UI or other components
                UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
            end            
        else
            print(string.format(localeTable.failedToDeserialize, sender))
        end
    end
end) 