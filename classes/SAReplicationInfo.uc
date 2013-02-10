class SAReplicationInfo extends ReplicationInfo;

var SAMutator mutRef;
var PlayerReplicationInfo ownerPRI;
var array<AchievementPackBase> achievementPacks;
var int numPacks;

replication {
    reliable if (Role == ROLE_Authority)
        ownerPRI, numPacks;
}

simulated function Tick(float DeltaTime) {
    local AchievementPackBase pack;

    super.Tick(DeltaTime);

    if (Role == ROLE_Authority) {
        mutRef.sendAch(self);
    }
        foreach DynamicActors(class'AchievementPackBase', pack) {
            if (pack.Owner == Owner) {
                addAchievementPack(pack);
            }
        }
    log("I have"@achievementPacks.Length@"I should have"@numPacks);
    Disable('Tick');
}

simulated function addAchievementPack(AchievementPackBase pack) {
    achievementPacks[achievementPacks.Length]= pack;
}

simulated function removeAchievementPack(AchievementPackBase pack) {
    local int i;

    for(i= 0; i < achievementPacks.Length; i++) {
        if (achievementPacks[i] == pack) {
            achievementPacks.Remove(i, 1);
            return;
        }
    }
}

simulated function getAchievementPacks(out array<AchievementPackBase> packs) {
    local int i;
    for(i= 0; i < achievementPacks.Length; i++) {
        packs[i]= achievementPacks[i];
    }
}

static function SAReplicationInfo findSAri(PlayerReplicationInfo pri) {
    local SAReplicationInfo repInfo;

    if (pri == none)
        return none;

    foreach pri.DynamicActors(Class'SAReplicationInfo', repInfo)
        if (repInfo.ownerPRI == pri)
            return repInfo;
 
    return none;
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True
}
