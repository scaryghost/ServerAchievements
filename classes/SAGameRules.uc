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

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason) {
    local int i, j;
    local SAReplicationInfo playerSAri;
    local array<AchievementPackBase> achievementPacks;

    if (super.CheckEndGame(Winner, Reason)) {
        for(i= 0; i < Level.GRI.PRIArray.Length; i++) {
            playerSAri= class'SAReplicationInfo'.static.findSAri(Level.GRI.PRIArray[i]);
            playerSAri.getAchievementPacks(achievementPacks);
            for(j= 0; j < achievementPacks.Length; j++) {
                achievementPacks[i].matchEnd(class'KFGameType'.static.GetCurrentMapName(Level), Level.Game.GameDifficulty, 
                        KFGameType(Level.Game).KFGameLength);
            }
        }
        return true;
    }
    return false;
}
