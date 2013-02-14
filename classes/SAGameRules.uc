class SAGameRules extends GameRules;

var array<KFMonster> dmgMonsters;
var array<float> prevHeadHealth;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, 
        vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    local int newDamage, i;
    local bool headshot;
    local SAReplicationInfo instigatorSAri;
    local array<AchievementPackBase> achievementPacks;

    for(i= 0; i < dmgMonsters.Length; i++) {
        if (dmgMonsters[i] == injured) {
            if(prevHeadHealth[i] > KFMonster(injured).HeadHealth) {
                prevHeadHealth[i]= KFMonster(injured).HeadHealth;
                headshot= true;
            }
            break;
        }
    }
    if (i == dmgMonsters.Length && KFMonster(injured).HeadHealth < KFMonster(injured).default.HeadHealth * 
            KFMonster(injured).DifficultyHeadHealthModifer() * KFMonster(injured).NumPlayersHeadHealthModifer()) {
        dmgMonsters[dmgMonsters.Length]= KFMonster(injured);
        prevHeadHealth[prevHeadHealth.Length]= KFMonster(injured).HeadHealth;
        headshot= true;
    }
    newDamage= super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    instigatorSAri= class'SAReplicationInfo'.static.findSAri(instigatedBy.PlayerReplicationInfo);
    if (instigatorSAri != none) {
        instigatorSAri.getAchievementPacks(achievementPacks);
        for(i= 0; i < achievementPacks.Length; i++) {
            achievementPacks[i].damagedMonster(newDamage, injured, DamageType, headshot);
        }
    }
    
    return newDamage;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local int i;
    local SAReplicationInfo playerSAri;
    local array<AchievementPackBase> achievementPacks;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if (KFPlayerController(Killer) != none) {
            playerSAri= class'SAReplicationInfo'.static.findSAri(Killer.PlayerReplicationInfo);
            if (playerSAri != none) {
                playerSAri.getAchievementPacks(achievementPacks);
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].killedMonster(Killed, DamageType);
                }
            }
            for(i= 0; i < dmgMonsters.Length; i++) {
                if (dmgMonsters[i] == Killed) {
                    dmgMonsters.remove(i, 1);
                    prevHeadHealth.remove(i, 1);
                    break;
                }
            }
        } else if(KFHumanPawn(Killed) != none) {
            playerSAri= class'SAReplicationInfo'.static.findSAri(Killed.PlayerReplicationInfo);
            if (playerSAri != none) {
                playerSAri.getAchievementPacks(achievementPacks);
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].playerDied(Killer, DamageType);
                }
            }
        }
        return false;
    }
    return true;
}
