local plymeta = FindMetaTable("Player")

function plymeta:GetCrippleDmgSpeedMult()
    return self:GetNWFloat("crippledmg_mult", 1.0)
end

hook.Add("Move", "CrippleDmgSpeedMult", function(ply, mv)
    local mult = ply:GetCrippleDmgSpeedMult();
    -- According to the gmod docs, speed to 0.0 does nothing at all, so we'll set it to 0.01 instead
    mv:SetMaxSpeed(math.max(0.01, mv:GetMaxSpeed() * mult))
    mv:SetMaxClientSpeed(math.max(0.01, mv:GetMaxClientSpeed() * mult))
end)
