function GetCharacterInfo()
    local name = UnitName("player")
    local level = UnitLevel("player")
    local class = UnitClass("player")
    local lastUpdated = date("%Y-%m-%d")    

    return {
        name = name,
        level = level,
        class = class,
        lastUpdated = lastUpdated
    }
end