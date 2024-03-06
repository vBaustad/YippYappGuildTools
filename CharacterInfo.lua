function GetCharacterInfo()
    local name = UnitName("player")
    local level = UnitLevel("player")
    local characterClass, classFileName = UnitClass("player")
    local lastUpdated = date("%Y-%m-%d")    

    return {
        name = name,
        level = level,
        class = characterClass,
        lastUpdated = lastUpdated
    }
end