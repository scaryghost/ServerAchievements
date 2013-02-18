class SAGameRules extends GameRules;

struct HeadHealthState {
    var KFMonster monster;
    var float prevHeadHealth;
};

var array<HeadHealthState> aliveMonsters;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, 
        vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    local int newDamage, i;
    local bool headshot;
    local SAReplicationInfo instigatorSAri;
    local array<AchievementPack> achievementPacks;

    for(i= 0; i < aliveMonsters.Length; i++) {
        if (aliveMonsters[i].monster == injured) {
            if (aliveMonsters[i].prevHeadHealth > KFMonster(injured).HeadHealth) {
                aliveMonsters[i].prevHeadHealth= KFMonster(injured).HeadHealth;
                headshot= true;
            }
            break;
        }
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
    local array<AchievementPack> achievementPacks;
    local bool headshot;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if (KFPlayerController(Killer) != none) {
            playerSAri= class'SAReplicationInfo'.static.findSAri(Killer.PlayerReplicationInfo);
            for(i= 0; i < aliveMonsters.Length; i++) {
                if (aliveMonsters[i].monster == Killed) {
                    if (aliveMonsters[i].prevHeadHealth > KFMonster(Killed).HeadHealth) {
                        headshot= true;
                    }
                    aliveMonsters.remove(i, 1);
                    break;
                }
            }
            if (playerSAri != none) {
                playerSAri.getAchievementPacks(achievementPacks);
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].killedMonster(Killed, DamageType, headshot);
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
