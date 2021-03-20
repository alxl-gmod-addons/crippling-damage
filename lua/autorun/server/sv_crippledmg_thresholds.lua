CrippleDmg = CrippleDmg or {}
CrippleDmg.Thresholds = CrippleDmg.Thresholds or {}

CreateConVar("crippledmg_file", "crippledmg_thresholds.txt", nil,
    "The location of the file for thresholds when saved/loaded")
CreateConVar("crippledmg_as_percentage", "1", FCVAR_ARCHIVE, "0=raw hp, 1=hp percentage", 0, 1)

concommand.Add("crippledmg_thresholds_list", function(ply, cmd, args)
    print("hp\tmult")
    for i, v in ipairs(CrippleDmg.Thresholds) do
        print(v.h .. "\t" .. v.m)
    end
end)

concommand.Add("crippledmg_thresholds_set", function(ply, cmd, args)
    local h = tonumber(args[1])
    local m = tonumber(args[2])
    if h ~= nil and m ~= nil then
        CrippleDmg.SetThreshold(h, m)
        CrippleDmg.SortThresholds()
        CrippleDmg.SaveThresholds()
    else
        print("crippledmg_thresholds_set <HP> <SpeedMult>")
        print("Adds or sets a damage threshold")
        print("HP and SpeedMult must both be numbers")
    end
end)

concommand.Add("crippledmg_thresholds_remove", function(ply, cmd, args)
    local h = tonumber(args[1])
    if h ~= nil then
        CrippleDmg.DeleteThreshold(h)
        CrippleDmg.SaveThresholds()
    else
        print("crippledmg_thresholds_remove <HP>")
        print("Removes a damage threshold")
        print("HP must be a number")
    end
end)

concommand.Add("crippledmg_thresholds_reload", function(ply, cmd, args)
    CrippleDmg.LoadThresholds()
end)

-- The performance of manipulating the thresholds doesn't really matter
-- but it's important to make searching for a threshold fast

CrippleDmg.SetThreshold = function(hp, speedMult)
    CrippleDmg.DeleteThreshold(hp)
    table.insert(CrippleDmg.Thresholds, {
        h = hp,
        m = speedMult
    })
end

CrippleDmg.DeleteThreshold = function(hp)
    for i, v in ipairs(CrippleDmg.Thresholds) do
        if v.h == hp then
            table.remove(CrippleDmg.Thresholds, i)
            return
        end
    end
end

CrippleDmg.ClearThresholds = function()
    local ct = #CrippleDmg.Thresholds
    for i=ct, 1, -1 do
        table.remove(CrippleDmg.Thresholds, i)
    end
end

CrippleDmg.SortThresholds = function()
    table.sort(CrippleDmg.Thresholds, function(a, b)
        return a.h < b.h
    end)
end

CrippleDmg.GetThresholdForPly = function(ply)
    local comparison
    if GetConVar("crippledmg_file"):GetBool() then
        comparison = 100 * ply:Health() / ply:GetMaxHealth()
    else
        comparison = ply:Health()
    end

    for i, v in ipairs(CrippleDmg.Thresholds) do
        if comparison <= v.h then
            return v.m
        end
    end
    return 1.0
end

-- Save/Load stuff

CrippleDmg.LoadThresholds = function()
    local floc = GetConVar("crippledmg_file"):GetString()

    CrippleDmg.ClearThresholds();
    if file.Exists(floc, "DATA") then
        local fileLines = string.Explode("\n", file.Read(floc, "DATA"))
        for i, l in pairs(fileLines) do
            local data = string.Explode(":", string.gsub(l, "%s+", ""))
            local validLine = true

            if #data == 2 then
                local hp = tonumber(data[1])
                local mult = tonumber(data[2])
                if hp ~= nil and mult ~= nil then
                    CrippleDmg.SetThreshold(hp, mult)
                else
                    validLine = false
                end
            else
                validLine = false
            end

            if not validLine then
                print("CRIPPLING DAMAGE: error loading threshold file " .. floc .. " on line " .. i)
            end
        end
    else
        print("CRIPPLING DAMAGE: file " .. floc .. " not found, using default threshold values")
        CrippleDmg.SetThreshold(15, 0.33)
        CrippleDmg.SetThreshold(40, 0.66)
        CrippleDmg.SaveThresholds()
    end
    CrippleDmg.SortThresholds()
end

CrippleDmg.SaveThresholds = function()
    local data = ""
    for i, v in ipairs(CrippleDmg.Thresholds) do
        if i > 1 then
            data = data .. "\n"
        end
        data = data .. v.h .. ":" .. v.m
    end
    file.Write(GetConVar("crippledmg_file"):GetString(), data)
end

CrippleDmg.LoadThresholds() -- Load immediately
