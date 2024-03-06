local ADDON_PREFIX = "YippYapp"
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
YippYappGuildTools_ProfessionsDB = YippYappGuildTools_ProfessionsDB or {}
YippYappGuildTools_BlacklistDB = YippYappGuildTools_BlacklistDB or {}

SLASH_YYGT1 = "/YYGT"
SlashCmdList["YYGT"] = function(msg)
    YippYappHandler()
end

local function YippYappHandler()

    RequestLatestProfessionData() 
    InitializeProfessionsFeature(YippYappGuildTools_ProfessionsDB)

    
    YippYappGuildTools_BlacklistDB = {}
    --InitializeBlacklistFeature(YippYappGuildTools_BlacklistDB)
    AddToBlacklist("Lorrden", "Warrior", "podadadsadsd  dhasdha hhad hha ha ha hha hnmadn ")  
    AddToBlacklist("re", "Rogue", "dadagg   agagag agagagsasf   sdanmadn ")  
  

    --UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)

    --IsCharacterBlacklisted("Ryggsekken")
    
end

local function checkguild()
    local guildName = GetGuildInfo("player")
    if guildName and guildName == "YippYapp" then
        print("Character is in YippYapp, initializing addon.")
        return true
    else
        print("Character is not in YippYapp, addon will not be initialized.")
        return false
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    if event == "PLAYER_LOGIN" then
        C_Timer.After(2, function()  -- Delay to ensure guild info is available
            local result = checkguild()
            if result then
                CreateMinimapButton()
                YippYappHandler()
                
            end
        end)
    end
    -- if event == "ADDON_LOADED" and arg1 == "YippYappGuildTools" then
    --     -- Call the function to create and display the minimap button
    --     if CreateMinimapButton then
    --         CreateMinimapButton()
    --     end
    -- end
end)
