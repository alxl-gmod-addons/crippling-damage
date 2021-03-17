CrippleDmg = CrippleDmg or {}

local function ResetAllPlayers()
    for _, ply in ipairs(player.GetAll()) do
        ply:ResetCrippleDmgSpeedMult()
    end
end

CreateConVar("crippledmg_enable", 1, FCVAR_NOTIFY,
    "When 1, players slow down at specified health thresholds. Turn off with 0.", 0, 1)
local enabled = GetConVar("crippledmg_enable"):GetBool()
cvars.AddChangeCallback("crippledmg_enable", function()
    enabled = GetConVar("crippledmg_enable"):GetBool()

    if not enabled then
        ResetAllPlayers()
    end
end)

hook.Add("PostPlayerDeath", "CrippleDmgDeathReset", function(ply)
    if enabled then
        ply:ResetCrippleDmgSpeedMult()
    end
end)

local tick_time = 0.05
cvars.AddChangeCallback("crippledmg_tick_time", function()
    tick_time = GetConVar("crippledmg_tick_time"):GetFloat()
end)

local lastTick = 0.0
hook.Add("Tick", "CrippleDmgMult", function()
    if enabled then
        local delta = CurTime() - lastTick

        if delta >= tick_time then
            lastTick = CurTime()

            for _, ply in ipairs(player.GetAll()) do
                if ply:Alive() then
                    ply:SetCrippleDmgSpeedMult(CrippleDmg.GetThresholdForPly(ply))
                end
            end
        end
    end
end)

concommand.Add("crippledmg_reset_all_players", function(ply, cmd, args)
    ResetAllPlayers()
end)
