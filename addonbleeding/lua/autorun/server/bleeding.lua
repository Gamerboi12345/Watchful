
--[[]

hook.Add("PlayerHurt", "Playerishurt", function(plyr, attackr)
    if attackr:IsPlayer() or attackr:IsNPC() then
        print("that hurt")
        table.insert(bleedingperson, plyr)
        timer.Start("bleeder")
        print("well guess your bleeding, heal or something, stupid.")
    end
end)

bleedingperson = {}

hook.Add("DoPlayerDeath", "bleedremover", function(player, attacker)
    for k,v in pairs(bleedingperson) do
        if player == v then
            print("player removed from bleeding queue :",v)
            bleedingperson[k] = nil
        end
    end
end)


timer.Create("bleeder",1,0,function()
    table.ClearKeys(bleedingperson, false)
    for k,v in pairs(bleedingperson) do
        v:TakeDamage(2)
    end
    print("complete")
end )

]]--













