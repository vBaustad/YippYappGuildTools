function ClearDynamicContent(contentArea)
    if contentArea.dynamicContentList then
        for _, content in ipairs(contentArea.dynamicContentList) do
            content:Hide()
            content:SetParent(nil)
        end
        -- Clear the list after cleaning up
        contentArea.dynamicContentList = {}
    end
end

function ShowHideFrame(tabIndex)
    local frame = _G["YippYappDataDisplayFrame"]
    
    if not frame then -- Ensure the frame is created if it doesn't exist
        frame = CreateDisplayFrame()
        UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
        UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)         
        frame:Show() 
        Tab_OnClick(frame.tabs[tabIndex], frame)   

    elseif frame:IsShown() and frame.selectedTab == tabIndex then
        frame:Hide()
    else

        UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
        UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)  
        frame:Show() 

        -- Update 'frame.selectedTab' to reflect the newly selected tab
        frame.selectedTab = tabIndex
        PanelTemplates_SetTab(frame, tabIndex)
        Tab_OnClick(frame.tabs[tabIndex], frame)        
    end
end

function CreateTabs(frame)
    frame.tabs = {}
    local titles = {localeTable.professions, localeTable.blacklisted}

    for i, title in ipairs(titles) do
        local tab = CreateFrame("Button", "$parentTab"..i, frame, "CharacterFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(title)
        tab:GetFontString():SetWidth(0)

        tab:SetScript("OnClick", function() Tab_OnClick(tab, frame) end)
        
        -- Adjust tab width based on the text width
        local textWidth = tab:GetFontString():GetWidth()
        local padding = 20 -- Adjust padding as needed
        local tabWidth = textWidth + padding
        tab:SetWidth(tabWidth)
        
        PanelTemplates_TabResize(tab, padding, 100)

        if i == 1 then
            tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 4)
        else
            tab:SetPoint("LEFT", frame.tabs[i-1], "RIGHT", -16, 0)
        end

        frame.tabs[i] = tab
    end

    PanelTemplates_SetNumTabs(frame, #titles)
    PanelTemplates_UpdateTabs(frame)

    -- Automatically select and display the first tab's content upon creation
    PanelTemplates_SetTab(frame, 1)
    Tab_OnClick(frame.tabs[1], frame)      
end

local function Capitalize(str)
    return str:sub(1,1):upper() .. str:sub(2):lower()
end

local function GetTimeDifference(lastUpdated)
    local currentTime = GetServerTime()
    local difference = currentTime - lastUpdated

    local minutes = math.floor(difference / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)

    if days > 0 then
        return days .. (days == 1 and " day" or " days") .. " ago"
    elseif hours > 0 then
        return hours .. (hours == 1 and " hour" or " hours") .. " ago"
    else
        return minutes .. (minutes == 1 and " minute" or " minutes") .. " ago"
    end

end

local function ValidateInputs(name, class, reason)
    -- Define a list of valid classes
    local validClasses = {
        ["Warrior"] = true,
        ["Paladin"] = true,
        ["Hunter"] = true,
        ["Rogue"] = true,
        ["Priest"] = true,
        ["Shaman"] = true,
        ["Mage"] = true,
        ["Warlock"] = true,
        ["Druid"] = true,
    }
    
    class = Capitalize(class:lower())
    
    if name == "" or class == "" or reason == "" then
        return false, "All fields must be filled out."
    end
    if not validClasses[class] then
        return false, "Invalid class."
    end
    return true, ""
end

function CreateBlacklistInput(labelText, parent, labelPoint, inputPoint, relativeTo, offsetX, offsetY, labelWidth, inputWidth)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint(labelPoint, relativeTo, offsetX, offsetY)
    label:SetText(labelText)
    label:SetWidth(labelWidth)

    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    -- Adjust input position to be aligned with the frame, but shifted right to accommodate label
    input:SetPoint(inputPoint, label, "TOPRIGHT", -15, 5) -- Offset adjusted for visual alignment
    input:SetSize(inputWidth, 20)
    input:SetAutoFocus(false)  -- Avoid automatic focus
    input:SetFontObject("ChatFontNormal")
    input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    input:SetFrameLevel(parent:GetFrameLevel() + 1)  -- Ensure input is above the label in the frame stack

    return input
end

function CreateBlacklistInputFields(inputArea)       

    local labelWidth = 100
    local inputWidth = 150
    local nameInput = CreateBlacklistInput(localeTable.inputName, inputArea, "TOPLEFT", "TOPLEFT", inputArea, -15, -13, labelWidth, inputWidth)
    local classInput = CreateBlacklistInput(localeTable.inputClass, inputArea, "TOPLEFT", "TOPLEFT", inputArea, -15, -35, labelWidth, inputWidth)
    local reasonInput = CreateBlacklistInput(localeTable.inputReason, inputArea, "TOPLEFT", "TOPLEFT", inputArea, -15, -57, labelWidth, inputWidth)

    --Submit button
    local submitButton = CreateFrame("Button", nil, inputArea, "GameMenuButtonTemplate")
    submitButton:SetPoint("TOPLEFT", inputArea, "BOTTOMLEFT", 5, 35)
    submitButton:SetSize(120, 25)
    submitButton:SetText(localeTable.submitButton)
    submitButton:SetScript("OnClick", function()
        -- Grab inputs
        local name = nameInput:GetText()
        local class = classInput:GetText()
        local reason = reasonInput:GetText()

        -- Validate inputs
        local isValid, errorMessage = ValidateInputs(name, class, reason)
        if isValid then
            -- Add to blacklist (ensure your AddToBlacklist function handles this correctly)
            local characterData = {
                name = Capitalize(name),
                class = Capitalize(class),
                reason = reason
            }
                
            AddToBlacklist(characterData)
            
            -- Clear inputs after successful submission
            nameInput:SetText("")
            classInput:SetText("")
            reasonInput:SetText("")
            
            UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
            SendBlacklistDataToGuild() 
            ShowHideFrame(2)           
        else            
            UpdateStatusReport(errorMessage)
        end
    end)

    -- Remove Button
    local removeButton = CreateFrame("Button", nil, inputArea, "GameMenuButtonTemplate")
    removeButton:SetPoint("LEFT", submitButton, "RIGHT", 5, 0)
    removeButton:SetSize(120, 25)
    removeButton:SetText(localeTable.removeButton)
    removeButton:SetScript("OnClick", function()
        local name = nameInput:GetText()
        name = Capitalize(name) 
        if name ~= "" then            
            if YippYappGuildTools_BlacklistDB[name] then
                RemoveFromBlacklist(name)
                UpdateStatusReport(name.." removed from blacklist")
                -- Update the blacklist tab content with the new data
                UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)                
                ShowHideFrame(2) 
            else
                -- Display error message if name input is not in db
                UpdateStatusReport("Character does not exist in DB.")
            end
        else
            -- Display error message if name input is empty
            UpdateStatusReport("Please enter a name to remove.")
        end
    end)

    -- Status Report Area
    local statusReport = inputArea:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusReport:SetPoint("TOPLEFT", nameInput, "TOPRIGHT", 10, 0)
    statusReport:SetWidth(inputArea:GetWidth())
    statusReport:SetJustifyH("LEFT")

    function UpdateStatusReport(message)
        statusReport:SetText(message)
    end
end

function CreateInputArea(frame)
    
    local inputArea = CreateFrame("Frame", nil, frame, "BackdropTemplate") 
    inputArea:SetHeight(110)  -- Adjust height as needed
    inputArea:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 25)
    inputArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 14)
    inputArea:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    inputArea:SetFrameLevel(frame:GetFrameLevel() + 1)
    frame.inputArea = inputArea    
   
    CreateBlacklistInputFields(inputArea)
end

function CreateContentAreas(frame)

    -- Professions Content
    local professionsContent = CreateFrame("Frame", "$parentProfessionsContent", frame.content)
    professionsContent:SetSize(frame.content:GetWidth(), frame.content:GetHeight())
    professionsContent:SetPoint("TOPLEFT")
    professionsContent:Hide()  -- Start hidden

    -- Blacklist Content
    local blacklistContent = CreateFrame("Frame", "$parentBlacklistContent", frame.content)
    blacklistContent:SetSize(frame.content:GetWidth(), frame.content:GetHeight())
    blacklistContent:SetPoint("TOPLEFT")
    blacklistContent:Hide()  -- Start hidden

    -- Add title for Blacklist Content
    -- local blacklistTitle = blacklistContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    -- blacklistTitle:SetPoint("TOPLEFT", blacklistContent, "TOPLEFT", 10, 0)
    -- blacklistTitle:SetText("FOOKIN BLACKLISTED")    

    frame.professionsContent = professionsContent
    frame.blacklistContent = blacklistContent
    
end

function Tab_OnClick(tab, frame)
    local tabIndex = tab:GetID()
    PanelTemplates_SetTab(frame, tabIndex)
    frame.selectedTab = tabIndex
    
    frame.professionsContent:Hide()
    frame.blacklistContent:Hide()
    -- Assume inputArea is properly initialized and part of the 'frame'
    if frame.inputArea then
        if tabIndex == 1 then
            frame.professionsContent:Show()
            frame.inputArea:Hide()
        elseif tabIndex == 2 then
            frame.blacklistContent:Show()
            frame.inputArea:Show()
        end
    end
end

function CreateBottomFrame(frame)

    -- Credit Bar similar to the Title Bar at the bottom
    local bottomBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bottomBar:SetHeight(22)  -- Similar to the title bar
    bottomBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 5)
    bottomBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -25, 5)
    bottomBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Background texture
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- Border texture
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    

    local creditText = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    creditText:SetPoint("CENTER", bottomBar, "CENTER", 0, 0)
    creditText:SetText("Created by Ryggsekken-ChaosBolt")

end

function CreateDisplayFrame()
    if not _G["YippYappDataDisplayFrame"] then
        local frame = CreateFrame("Frame", "YippYappDataDisplayFrame", UIParent, "BasicFrameTemplateWithInset")
        -- Frame setup code...
        _G["YippYappDataDisplayFrame"] = frame
        frame:SetSize(500, 360)  -- Adjusted for wider content
        frame:SetPoint("CENTER")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
        frame.title:SetText("YippYapp Guild Tools")

        -- Insert frame into UISpecialFrames to close with Escape
        tinsert(UISpecialFrames, frame:GetName())

        -- Scroll Frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(scrollFrame:GetWidth(), scrollFrame:GetHeight()) -- Initial size
        scrollFrame:SetScrollChild(content)
        frame.content = content     

        -- Create content areas
        CreateContentAreas(frame)
        -- Create tabs
        CreateTabs(frame)
        CreateBottomFrame(frame)
        CreateInputArea(frame)
        Tab_OnClick(frame.tabs[1], frame)

        _G["YippYappDataDisplayFrame"] = frame
    end
    return _G["YippYappDataDisplayFrame"]
    
end

function createHeader(parent, text, xPosition, yPosition)    
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", xPosition, yPosition)
    header:SetText(text)
    return header
end

function createColumnText(parent, text, xPosition, yPosition, color)
    local textLine = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    textLine:SetPoint("TOPLEFT", parent, "TOPLEFT", xPosition, yPosition)
    if color then
        text = string.format("|cFF%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, text)
    end
    textLine:SetText(text)
    return textLine
end

function createHorizontalLine(parent, xStart, xEnd, yPosition)
    local line = parent:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(1, 1, 1, 0.5)  -- Set color and alpha of the line; adjust as needed
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", xStart, yPosition)
    line:SetPoint("TOPRIGHT", parent, "TOPLEFT", xEnd, yPosition)
    line:SetHeight(1)  -- Line thickness    
    return line
end

function UpdateProfessionsContent(guildMembersData)
    local frame = _G["YippYappDataDisplayFrame"]
    if not frame then
        frame = CreateDisplayFrame()
    end

    -- Determine the active content area. For this example, we'll update the professionsContent.
    local contentArea = frame.professionsContent

    ClearDynamicContent(contentArea)

    local spacing = 15
    local initialYOffset = -20  -- Initial Y offset from the top of the content area

    local nameColumnX = 10
    local professionColumnX = 90
    local lastUpdatedColumnX = 370

    -- Ensure dynamicContentList is initialized
    if not contentArea.dynamicContentList then
        contentArea.dynamicContentList = {}
    end
    -- Headers
    table.insert(contentArea.dynamicContentList, createHeader(contentArea, localeTable.name, nameColumnX, initialYOffset))
    table.insert(contentArea.dynamicContentList, createHeader(contentArea, localeTable.professions, professionColumnX, initialYOffset))
    table.insert(contentArea.dynamicContentList, createHeader(contentArea, localeTable.lastUpdated, lastUpdatedColumnX, initialYOffset))

    -- Horizontal line under headers
    table.insert(contentArea.dynamicContentList, createHorizontalLine(contentArea, 0, frame:GetWidth(), initialYOffset - 15))

    local contentHeight = initialYOffset - 5 - spacing  -- Start below the headers

    for _, data in pairs(guildMembersData) do
        if next(data.professions) ~= nil then
            local professionsStrs = {}
            for _, profession in ipairs(data.professions) do  
                if profession[2] and profession[2] ~= "" then  -- Check if spellSubName is not empty
                    professionStr = string.format("%s - %s", profession[1] or "N/A", profession[2])
                else
                    professionStr = profession[1] or "N/A"
                end
                table.insert(professionsStrs, professionStr)
            end
            
            local professionsLine = table.concat(professionsStrs, ", ")
            local classColor = RAID_CLASS_COLORS[string.upper(data.class)]
            --print("character: " .. data.name .. " " .. "last updated: " .. data.lastUpdated)
            table.insert(contentArea.dynamicContentList, createColumnText(contentArea, data.name, nameColumnX, contentHeight, classColor))
            table.insert(contentArea.dynamicContentList, createColumnText(contentArea, professionsLine, professionColumnX, contentHeight))
            table.insert(contentArea.dynamicContentList, createColumnText(contentArea, data.lastUpdated or "N/A", lastUpdatedColumnX, contentHeight))

            -- Draw a line after each entry and track it
            table.insert(contentArea.dynamicContentList, createHorizontalLine(contentArea, 0, frame:GetWidth(), contentHeight - 12))

            -- Increment contentHeight for the next entry
            contentHeight = contentHeight - spacing 
        end
    end
     
    contentArea:SetSize(frame:GetWidth(), initialYOffset) 
    frame:Hide()   
    
end

function UpdateBlacklistContent(blacklistData)
    local frame = _G["YippYappDataDisplayFrame"]
    if not frame then
        frame = CreateDisplayFrame()
    end
    
    -- Determine the active content area. For this example, we'll update the professionsContent.
    local contentArea = frame.blacklistContent 

    ClearDynamicContent(contentArea)

    local spacing = 15
    local initialYOffset = -20  -- Initial Y offset from the top of the content area

    local nameColumnX = 10
    local reasonColumnX = 90
    local lastUpdatedColumnX = 270
    local formattedTime = GetTimeDifference(YippYappGuildTools_BlacklistDB.lastUpdated)

    -- Ensure dynamicContentList is initialized
    if not contentArea.dynamicContentList then
        contentArea.dynamicContentList = {}
    end

    -- Headers
    table.insert(contentArea.dynamicContentList, createHeader(contentArea, localeTable.blacklisted, nameColumnX, initialYOffset))
    table.insert(contentArea.dynamicContentList, createHeader(contentArea, localeTable.reason, reasonColumnX, initialYOffset))
    table.insert(contentArea.dynamicContentList, createHeader(contentArea, localeTable.lastUpdated .. ": " .. formattedTime, lastUpdatedColumnX, initialYOffset))

    -- Horizontal line under headers
    table.insert(contentArea.dynamicContentList, createHorizontalLine(contentArea, 0, frame:GetWidth(), initialYOffset - 15))

    local contentHeight = initialYOffset - 5 - spacing  -- Start below the headers

    for characterName, characterData in pairs(blacklistData) do
        
        if characterName ~= "lastUpdated" then
            local classColor = RAID_CLASS_COLORS[string.upper(characterData.class)]   


            table.insert(contentArea.dynamicContentList, createColumnText(contentArea, characterName, nameColumnX, contentHeight, classColor))
            table.insert(contentArea.dynamicContentList, createColumnText(contentArea, characterData.reason, reasonColumnX, contentHeight))
            

            -- Creating a horizontal line
            table.insert(contentArea.dynamicContentList, createHorizontalLine(contentArea, 0, frame:GetWidth(), contentHeight - 12))

            contentHeight = contentHeight - spacing   -- Updated to include text height
        end
    end    
    contentArea:SetSize(frame:GetWidth(), initialYOffset)  
    frame:Hide()
end

