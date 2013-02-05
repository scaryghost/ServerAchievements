class SAGameRules extends GameRules;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, 
        vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    local int newDamage, i;
    local SAReplicationInfo instigatorSAri;
    local array<AchievementPackBase> achievementPacks;

    newDamage= super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    instigatorSAri= class'SAReplicationInfo'.static.findSAri(instigatedBy.PlayerReplicationInfo);
    if (instigatorSAri != none) {
        instigatorSAri.getAchievementPacks(achievementPacks);
        for(i= 0; i < achievementPacks.Length; i++) {
            achievementPacks[i].damagedMonster(newDamage, injured, DamageType);
        }
    }
    
    return newDamage;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local int i;
    local SAReplicationInfo killerSAri;
    local array<AchievementPackBase> achievementPacks;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        killerSAri= class'SAReplicationInfo'.static.findSAri(Killer.PlayerReplicationInfo);
        if (killerSAri != none) {
            killerSAri.getAchievementPacks(achievementPacks);
            for(i= 0; i < achievementPacks.Length; i++) {
                achievementPacks[i].killedMonster(Killed, DamageType);
            }
        }
        return false;
    }
    return true;
}

