/**
 * Custom replication info class for ServerAchievements
 * @author etsai (Scary Ghost)
 */
class SAReplicationInfo extends ReplicationInfo;

var bool broadcastedWaveEnd, initialized;
var string steamid64, offset;
var SAMutator mutRef;
var PlayerReplicationInfo ownerPRI;
var array<AchievementPack> achievementPacks;

var array<Actor> processedActors;

replication {
    reliable if (Role == ROLE_Authority)
        ownerPRI;
}

function bool hasProcessed(Actor key) {
    local int i, len;
    len= processedActors.Length;

    while(i < len) {
        if (processedActors[i] == none) {
            processedActors.remove(i, 1);
            len--;
        } else if (processedActors[i] == key) {
            return true;
        }
        i++;
    }
    return false;
}

simulated function Tick(float DeltaTime) {
    local AchievementPack pack;
    local MP7MHealinglProjectile projectile;
    local int i;

    super.Tick(DeltaTime);

    if (!initialized) {
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
        SetTimer(1.0, true);
        initialized= true;
    }
    if (Role == ROLE_Authority && Owner != none && Controller(Owner).Pawn != none) {
        foreach Controller(Owner).Pawn.TouchingActors(class'MP7MHealinglProjectile', projectile) {
            if (!hasProcessed(projectile)) {
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].touchedHealDart(projectile);
                }
                processedActors[processedActors.Length]= projectile;
            }
        }
    }
}

function Timer() {
    local int realWaveNum;
    local int i;
    local bool eventTriggered;

    for(i= 0; i < achievementPacks.Length && (eventTriggered || i == 0); i++) {
        if (!broadcastedWaveEnd && !KFGameType(Level.Game).bWaveInProgress) {
            achievementPacks[i].waveEnd(KFGameType(Level.Game).WaveNum);
            eventTriggered= true;
        } else if (broadcastedWaveEnd && KFGameType(Level.Game).bWaveInProgress) {
            achievementPacks[i].waveStart(KFGameType(Level.Game).WaveNum + 1);
            eventTriggered= true;
        }
        if (KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType != 0) {
            if (KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType == 1) {
                realWaveNum= KFGameType(Level.Game).WaveNum + 1;
                achievementPacks[i].waveEnd(realWaveNum);
            } else {
                realWaveNum= KFGameType(Level.Game).WaveNum;
            }
            achievementPacks[i].matchEnd(class'KFGameType'.static.GetCurrentMapName(Level), Level.Game.GameDifficulty, 
                KFGameType(Level.Game).KFGameLength, KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType, realWaveNum);
            eventTriggered= true;
            SetTimer(0, false);
        }
    }
    if (eventTriggered) {
        broadcastedWaveEnd= !broadcastedWaveEnd;
    }
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
    broadcastedWaveEnd= true
}
