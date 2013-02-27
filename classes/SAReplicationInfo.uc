class SAReplicationInfo extends ReplicationInfo;

var string steamid64, offset;
var SAMutator mutRef;
var PlayerReplicationInfo ownerPRI;
var array<AchievementPack> achievementPacks;

replication {
    reliable if (Role == ROLE_Authority)
        ownerPRI;
}

simulated function Tick(float DeltaTime) {
    local AchievementPack pack;

    super.Tick(DeltaTime);

    if (PlayerController(Owner) != Level.GetLocalPlayerController()) {
        steamid64= PlayerController(Owner).GetPlayerIDHash();
    } else {
        steamid64= class'SAMutator'.default.localHostSteamID64;
    }
    if (!PlatformIsWindows()) {
        log("Server not on Window OS.  Adding steamid64 offset (" $ steamid64 @ "+" @ offset $ ")");
        class'Utility'.static.addOffset(steamid64, offset);
        log("New steamid64:"@steamid64);
    }
    
    if (Role == ROLE_Authority) {
        mutRef.sendAchievements(self);
    }
    foreach DynamicActors(class'AchievementPack', pack) {
        if (pack.Owner == Owner) {
            addAchievementPack(pack);
        }
    }
    Disable('Tick');
}

simulated function addAchievementPack(AchievementPack pack) {
    local int i;
    
    for(i= 0; i < achievementPacks.Length; i++) {
        if (achievementPacks[i] == pack)
            return;
    }
    achievementPacks[achievementPacks.Length]= pack;
}

simulated function removeAchievementPack(AchievementPack pack) {
    local int i;

    for(i= 0; i < achievementPacks.Length; i++) {
        if (achievementPacks[i] == pack) {
            achievementPacks.Remove(i, 1);
            return;
        }
    }
}

simulated function getAchievementPacks(out array<AchievementPack> packs) {
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

    offset= "76561197960265728"
}
