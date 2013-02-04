class SAReplicationInfo extends ReplicationInfo;

var PlayerReplicationInfo ownerPRI;
var array<AchievementPackBase> achievementPacks;

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

