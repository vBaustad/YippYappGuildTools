local function CreateMinimapButton()
    local LibDBIcon = LibStub("LibDBIcon-1.0")
    local LDB = LibStub("LibDataBroker-1.1")

    local addonName = "YippYappGuildTools"
    local minimapButtonDB = {
        profile = {
            minimapButton = {
                hide = false,
                -- Define your icon settings here
                oldIcon = false,
            }
        }
    }

    local function GetIcon()
        -- Return the icon based on your condition
        local iconPath = "Interface\\AddOns\\YippYappGuildTools\\Media\\YippYappIcon.tga"  -- Ensure this path is correct

        return iconPath
    end

    local function UpdateIcon(minimapButton)
        minimapButton.icon = GetIcon()
    end

    local function RefreshMinimapButtonConfig(minimapButton)
        if minimapButton then
            UpdateIcon(minimapButton)
            LibDBIcon:Refresh(addonName, minimapButtonDB.profile.minimapButton)
        end
    end

    local minimapButton = LDB:NewDataObject(addonName, {
        type = "data source",
        text = "YippYapp Guild Tools",
        icon = GetIcon(),
        OnClick = function(clickedFrame, button)
            if button == "RightButton" then
                ShowHideFrame(2)
            elseif button == "LeftButton" then
                ShowHideFrame(1)
            if IsControlKeyDown() then
                
              else
                
              end
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("YippYapp Guild Tools")
            tooltip:AddLine(" ")
            tooltip:AddLine(GRAY_FONT_COLOR_CODE .. "Left Click:|r Toggle YippYapp Professions")
            tooltip:AddLine(GRAY_FONT_COLOR_CODE .. "Right Click:|r Toggle YippYapp Blacklist")
            tooltip:AddLine(GRAY_FONT_COLOR_CODE .. "Ctrl + Left Click:|r NOTHING YET")
        end,
    })

    LibDBIcon:Register(addonName, minimapButton, minimapButtonDB.profile.minimapButton)
    return minimapButton
end

-- Make the CreateMinimapButton function accessible globally
_G.CreateMinimapButton = CreateMinimapButton

