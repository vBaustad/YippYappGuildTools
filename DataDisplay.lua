
function ShowHideFrame(tabIndex)
    local frame = _G["YippYappDataDisplayFrame"]
    if not frame then
        frame = CreateDisplayFrame()  -- Ensure the frame is created if it doesn't exist
    end

    if frame:IsShown() and frame.selectedTab == tabIndex then
        frame:Hide()
    else
        if not frame:IsShown() then
            frame:Show()

            
        end
        UpdateBlacklistContent(YippYappGuildTools_BlacklistDB)
        UpdateProfessionsContent(YippYappGuildTools_ProfessionsDB)
        -- Update 'frame.selectedTab' to reflect the newly selected tab
        frame.selectedTab = tabIndex
        PanelTemplates_SetTab(frame, tabIndex)
        Tab_OnClick(frame.tabs[tabIndex], frame)
        
    end
end

function CreateTabs(frame)
    frame.tabs = {}
    local titles = {"Professions", "Blacklist"}

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

function CreateBlacklistInputFields(inputArea)
        
    local nameInput = CreateBlacklistInput("Name  ", inputArea, "TOPLEFT", inputArea, "TOPLEFT", 10, -10)
    local classInput = CreateBlacklistInput("Class   ", inputArea, "TOPLEFT", inputArea, "TOPLEFT", 10, -34)
    local reasonInput = CreateBlacklistInput("Reason", inputArea, "TOPLEFT", inputArea, "TOPLEFT", 10, -56)

    local submitButton = CreateFrame("Button", nil, inputArea, "GameMenuButtonTemplate")
    submitButton:SetPoint("TOPLEFT", inputArea, "BOTTOMLEFT", 5, 35)
    submitButton:SetSize(120, 25)
    submitButton:SetText("Submit")
    submitButton:SetScript("OnClick", function()
        -- Clear inputs after submission
        nameInput:SetText("")
        classInput:SetText("")
        reasonInput:SetText("")
    end)

end

function CreateBlacklistInput(labelText, parent, point, relativeTo, relativePoint, offsetX, offsetY)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
    label:SetText(labelText)

    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetPoint("LEFT", label, "RIGHT", 10, 0)
    input:SetSize(150, 20)
    input:SetAutoFocus(false)  -- Avoid automatic focus
    input:SetFontObject("ChatFontNormal")
    input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    input:SetFrameLevel(input:GetFrameLevel() + 1)  -- Make sure it's above its parent   
    
    return input
end

function CreateInputArea(frame)
    
    local inputArea = CreateFrame("Frame", nil, frame, "BackdropTemplate")  -- Removed the "$parentBlacklistContent" name to avoid naming conflicts
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

    -- Placeholder for creating inputs, to be implemented next
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
end

function createColumnText(parent, text, xPosition, yPosition, color)
    local textLine = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    textLine:SetPoint("TOPLEFT", parent, "TOPLEFT", xPosition, yPosition)
    if color then
        text = string.format("|cFF%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, text)
    end
    textLine:SetText(text)
end

function createHorizontalLine(parent, xStart, xEnd, yPosition)
    local line = parent:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(1, 1, 1, 0.5)  -- Set color and alpha of the line; adjust as needed
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", xStart, yPosition)
    line:SetPoint("TOPRIGHT", parent, "TOPLEFT", xEnd, yPosition)
    line:SetHeight(1)  -- Line thickness
end

function UpdateProfessionsContent(guildMembersData)
    local frame = _G["YippYappDataDisplayFrame"]
    if not frame then
        frame = CreateDisplayFrame()
    end
    
    -- Determine the active content area. For this example, we'll update the professionsContent.
    local contentArea = frame.professionsContent 

    -- Clear previous content
    for _, child in ipairs({contentArea:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local spacing = 15
    local initialYOffset = -20  -- Initial Y offset from the top of the content area

    local nameColumnX = 10
    local professionColumnX = 90
    local lastUpdatedColumnX = 370

    -- Headers
    createHeader(contentArea, "Name", nameColumnX, initialYOffset)
    createHeader(contentArea, "Professions", professionColumnX, initialYOffset)
    createHeader(contentArea, "Last Updated", lastUpdatedColumnX, initialYOffset)

    -- Horizontal line under headers
    createHorizontalLine(contentArea, 0, frame:GetWidth(), initialYOffset - 15)

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
            
            createColumnText(contentArea, data.name, nameColumnX, contentHeight, classColor)
            createColumnText(contentArea, professionsLine, professionColumnX, contentHeight)
            createColumnText(contentArea, data.lastUpdated or "N/A", lastUpdatedColumnX, contentHeight)

            -- Optional: Draw a line after each entry
            createHorizontalLine(contentArea, 0, frame:GetWidth(), contentHeight - 12)

            -- Increment contentHeight for the next entry
            contentHeight = contentHeight - spacing 
        end
    end
     
    contentArea:SetSize(frame:GetWidth(), initialYOffset)
end

function UpdateBlacklistContent(blacklistData)
    local frame = _G["YippYappDataDisplayFrame"]
    if not frame then
        frame = CreateDisplayFrame()
    end
    
    -- Determine the active content area. For this example, we'll update the professionsContent.
    local contentArea = frame.blacklistContent 

    -- Clear previous content
    for _, child in ipairs({contentArea:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end

    local spacing = 15
    local initialYOffset = -20  -- Initial Y offset from the top of the content area

    local nameColumnX = 10
    local reasonColumnX = 90

    -- Headers
    createHeader(contentArea, "Name", nameColumnX, initialYOffset)
    createHeader(contentArea, "Reason", reasonColumnX, initialYOffset)

    -- Horizontal line under headers
    createHorizontalLine(contentArea, 0, frame:GetWidth(), initialYOffset - 15)

    local contentHeight = initialYOffset - 5 - spacing  -- Start below the headers

    for _, data in pairs(blacklistData) do
        if data.class then
            local classColor = RAID_CLASS_COLORS[string.upper(data.class)]   


            createColumnText(contentArea, data.name, nameColumnX, contentHeight, classColor)
            createColumnText(contentArea, data.reason, reasonColumnX, contentHeight)

            -- Creating a horizontal line
            createHorizontalLine(contentArea, 0, frame:GetWidth(), contentHeight - 12)

            contentHeight = contentHeight - spacing   -- Updated to include text height
        end
    end
    
    contentArea:SetSize(frame:GetWidth(), initialYOffset)
    
end

