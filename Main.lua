local ADDON_PREFIX = "YippYapp"
local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
YippYappGuildTools_ProfessionsDB = YippYappGuildTools_ProfessionsDB or {}
YippYappGuildTools_BlacklistDB = YippYappGuildTools_BlacklistDB or {}

SLASH_YYGT1 = "/YYGT"
SlashCmdList["YYGT"] = function(msg)
    ShowHideFrame(1)
end

function YippYappHandler()
    
    RequestLatestProfessionData() 
    RequestLatestBlacklistData()

    InitializeProfessionsFeature(YippYappGuildTools_ProfessionsDB)
    
end

local function checkguild()
    local guildName = GetGuildInfo("player")
    if guildName and guildName == "YippYapp" then        
        return true
    else        
        return false
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...
    if event == "PLAYER_LOGIN" then
        C_Timer.After(2, function()  -- Delay to ensure guild info is available
            local result = checkguild()
            if result then
                --CreateMinimapButton()
                YippYappHandler()

            end
        end)
    end
    if event == "GROUP_ROSTER_UPDATE" then                
        checkPartyMembersAgainstBlacklist()
    end
    if event == "ADDON_LOADED" and arg1 == "YippYappGuildTools" then
        -- Call the function to create and display the minimap button
        if CreateMinimapButton then
            CreateMinimapButton()
        end
    end
end)
