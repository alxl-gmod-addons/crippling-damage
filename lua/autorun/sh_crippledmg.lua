local plymeta = FindMetaTable("Player")

function plymeta:GetCrippleDmgSpeedMult()
    return self:GetNWFloat("crippledmg_mult", 1.0)
end

hook.Add("Move", "CrippleDmgSpeedMult", function(ply, mv)
    local speed = mv:GetMaxSpeed() * ply:GetCrippleDmgSpeedMult()
    mv:SetMaxSpeed(speed)
    mv:SetMaxClientSpeed(speed)
end)
