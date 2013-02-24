class SAGameRules extends GameRules;

struct HeadHealthState {
    var KFMonster monster;
    var float prevHeadHealth;
    var bool prevHeadShot;
};

var array<HeadHealthState> aliveMonsters;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, 
        vector HitLocation, out vector Momentum, class<DamageType> DamageType) {
    local int newDamage, i;
    local bool headShot;
    local SAReplicationInfo instigatorSAri;
    local array<AchievementPack> achievementPacks;

    for(i= 0; i < aliveMonsters.Length; i++) {
        if (aliveMonsters[i].monster == injured) {
            if (aliveMonsters[i].prevHeadHealth > KFMonster(injured).HeadHealth) {
                aliveMonsters[i].prevHeadHealth= KFMonster(injured).HeadHealth;
                aliveMonsters[i].prevHeadShot= true;
                headShot= true;
            } else {
                aliveMonsters[i].prevHeadShot= false;
            }
            break;
        }
    }
    newDamage= super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    instigatorSAri= class'SAReplicationInfo'.static.findSAri(instigatedBy.PlayerReplicationInfo);
    if (instigatorSAri != none && KFMonster(injured) != none) {
        instigatorSAri.getAchievementPacks(achievementPacks);
        for(i= 0; i < achievementPacks.Length; i++) {
            achievementPacks[i].damagedMonster(newDamage, injured, DamageType, KFMonster(injured).bDecapitated || headShot);
        }
    }
    
    return newDamage;
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation) {
    local int i;
    local SAReplicationInfo playerSAri;
    local array<AchievementPack> achievementPacks;
    local bool headShot;

    if (!super.PreventDeath(Killed, Killer, damageType, HitLocation)) {
        if(KFHumanPawn(Killed) != none) {
            playerSAri= class'SAReplicationInfo'.static.findSAri(Killed.PlayerReplicationInfo);
            if (playerSAri != none) {
                playerSAri.getAchievementPacks(achievementPacks);
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].playerDied(Killer, DamageType, KFGameType(Level.Game).WaveNum + 1);
                }
            }
        } else if (KFMonster(Killed) != none) {
            for(i= 0; i < aliveMonsters.Length; i++) {
                if (aliveMonsters[i].monster == Killed) {
                    headShot= aliveMonsters[i].monster.bDecapitated || aliveMonsters[i].prevHeadShot;
                    aliveMonsters.remove(i, 1);
                    break;
                }
            }
            if (KFPlayerController(Killer) != none) {
                playerSAri= class'SAReplicationInfo'.static.findSAri(Killer.PlayerReplicationInfo);
            
                if (playerSAri != none) {
                    playerSAri.getAchievementPacks(achievementPacks);
                    for(i= 0; i < achievementPacks.Length; i++) {
                        achievementPacks[i].killedMonster(Killed, DamageType, headShot);
                    }
                }
            }

        } 
        return false;
    }
    return true;
}
