local plymeta = FindMetaTable("Player")

function plymeta:SetCrippleDmgSpeedMult(mult)
    self:SetNWFloat("crippledmg_mult", mult)
end

function plymeta:ResetCrippleDmgSpeedMult()
    self:SetCrippleDmgSpeedMult(1.0)
end
