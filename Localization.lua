local L = {}

-- English localization
L["enUS"] = {
    name = "Name",
    professions = "Professions",
    lastUpdated = "Last Updated",
    blacklisted = "Blacklisted",
    reason = "Reason",
    inputName = "Name   ",
    inputClass = "Class    ",
    inputReason = "Reason",
    submitButton = "Submit",
    removeButton = "Remove",
    welcomeMessage = "Welcome to YippYappGuildTools!",
    errorMessage = "An error has occurred.",
    alreadyInBlacklist = "%s is already in the blacklist.",
    notInBlacklist = "%s is not in the blacklist.",
    blacklistedAsClass = "%s is blacklisted as a %s.",
    failedToDeserialize = "Failed to deserialize data from %s",
    failedToSerialize = "Character data for serialization not found.",
    classNames = {
        Warrior = "Warrior",
        Mage = "Mage",
        Rogue = "Rogue",
        Shaman = "Shaman",
        Paladin = "Paladin",
        Warlock = "Warlock",
        Druid = "Druid",
        Hunter = "Hunter",
        Priest = "Priest",        
    },
}


-- Determine the current locale and select the appropriate localization table
local currentLocale = GetLocale()
localeTable = L[currentLocale] or L["enUS"] -- Fallback to English if the current locale is not supported
