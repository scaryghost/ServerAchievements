class AchievementPackBase extends Serializable
    abstract;

struct Achievement {
/** Static values that will always be the same for each player */
    var string title;
    var string description;
    var Texture image;
    var int maxProgress;

/** Player data that is saved and restored */
    var byte completed;
    var int progress;

/** Transient states that do not need to be saved */
    var byte timesNotified;
    var byte canEarn;
};

var float flushPeriod, flushTimer;
var PlayerController localController;
var array<Achievement> achievements;
var bool broadcastedWaveEnd;
var string packName;

replication {
    reliable if (Role == ROLE_AUTHORITY) 
        localAchievementCompleted, notifyProgress, flushToClient;
}

function matchEnd(string mapname, float difficulty, int length, byte result);
function waveStart(int waveNum);
function waveEnd(int waveNum);
function playerDied(Controller killer, class<DamageType> damageType);
function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);

event PostBeginPlay() {
    SetTimer(1.0, true);
}

function string serializeUserData() {
    local int i;
    local string data;

    for(i= 0; i < achievements.Length; i++) {
        if (i != 0) {
            data$= ";";
        }
        data$= i $ "," $ achievements[i].completed $ "," $ achievements[i].progress;
    }
    return data;
}

function deserializeUserData(string data) {
    local array<string> parts, achvData;
    local int i, j;
    
    Split(data, ";", parts);
    for(i= 0; i < parts.Length; i++) {
        Split(parts[i], ",", achvData);
        j= int(achvData[0]);
        achievements[j].completed= byte(achvData[1]);
        achievements[j].progress= int(achvData[2]);
        flushToClient(j, achievements[j].progress, achievements[j].completed);
    }
}

function Timer() {
    local int i;

    if (!broadcastedWaveEnd && KFGameType(Level.Game) != none && !KFGameType(Level.Game).bWaveInProgress) {
        waveEnd(KFGameType(Level.Game).WaveNum);
        broadcastedWaveEnd= true;
    } else if (broadcastedWaveEnd && KFGameType(Level.Game) != none && KFGameType(Level.Game).bWaveInProgress) {
        waveStart(KFGameType(Level.Game).WaveNum + 1);
        broadcastedWaveEnd= false;
    }
    if (KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType != 0) {
        matchEnd(class'KFGameType'.static.GetCurrentMapName(Level), Level.Game.GameDifficulty, 
            KFGameType(Level.Game).KFGameLength, KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType);
        SetTimer(0, false);
    }
    flushTimer+= 1.0;
    if (flushTimer > flushPeriod) {
        for(i= 0; i < achievements.Length; i++) {
            if (achievements[i].progress < achievements[i].maxProgress) {
                flushToClient(i, achievements[i].progress, achievements[i].completed);
            }
        }
        flushTimer-= flushPeriod;
    }
}

simulated event PostNetBeginPlay() {
    if (Level.NetMode != NM_DedicatedServer) {
        localController= Level.GetLocalPlayerController();
    }
}

simulated function flushToClient(int index, int progress, byte completed) {
    achievements[index].progress= progress;
    achievements[index].completed= completed;
}

simulated function notifyProgress(int index, int progress, int maxProgress) {
    local int i;

    for(i= 0; i < localController.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(localController.Player.LocalInteractions[i]) != none) {
            SAInteraction(localController.Player.LocalInteractions[i]).addMessage("Achivement In Progress", 
                achievements[index].title@";("$ progress $ "/" $ maxProgress $ ")", achievements[index].image);
            break;
        }
    }
}

function achievementCompleted(int index) {
    if (achievements[index].completed == 0) {
        achievements[index].completed= 1;
        localAchievementCompleted(index);
    }
}

simulated function localAchievementCompleted(int index) {
    local int i;

    achievements[index].completed= 1;
    for(i= 0; i < localController.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(localController.Player.LocalInteractions[i]) != none) {
            SAInteraction(localController.Player.LocalInteractions[i]).addMessage("Achivement Unlocked!", 
                achievements[index].title, achievements[index].image);
            break;
        }
    }
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true

    broadcastedWaveEnd= true
    flushPeriod= 10.0
}

