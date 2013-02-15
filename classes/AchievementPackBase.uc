class AchievementPackBase extends AchievementPack
    abstract;

struct Achievement {
/** Static values that will always be the same for each player */
    var string title;
    var string description;
    var Texture image;
    var int maxProgress;
    var float notifyIncrement;

/** Player data that is saved and restored */
    var byte completed;
    var int progress;

/** Transient states that do not need to be saved */
    var byte timesNotified;
    var byte canEarn;
};

var PlayerController localController;
var array<Achievement> achievements;
var bool broadcastedWaveEnd;
var bool dataModified;

replication {
    reliable if (Role == ROLE_AUTHORITY) 
        localAchievementCompleted, notifyProgress, flushToClient;
}

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

simulated function notifyProgress(int index) {
    local int i;

    for(i= 0; i < localController.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(localController.Player.LocalInteractions[i]) != none) {
            SAInteraction(localController.Player.LocalInteractions[i]).addMessage("Achivement In Progress", 
                achievements[index].title@";("$ achievements[index].progress $ "/" $ achievements[index].maxProgress $ ")", achievements[index].image);
            break;
        }
    }
}

function achievementCompleted(int index) {
    if (achievements[index].completed == 0) {
        achievements[index].completed= 1;
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        dataModified= true;
        localAchievementCompleted(index);
    }
}

function addProgress(int index, int offset) {
    achievements[index].progress+= offset;
    if (achievements[index].progress >= achievements[index].maxProgress) {
        achievementCompleted(index);
    } else {
        flushToClient(index, achievements[index].progress, achievements[index].completed);
        if (achievements[index].progress >= achievements[index].notifyIncrement * (achievements[index].timesNotified + 1) * achievements[index].maxProgress) {
            notifyProgress(index);
            achievements[index].timesNotified++;
        }
    }
    dataModified= true;
}

simulated function localAchievementCompleted(int index) {
    local int i;

    for(i= 0; i < localController.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(localController.Player.LocalInteractions[i]) != none) {
            SAInteraction(localController.Player.LocalInteractions[i]).addMessage("Achivement Unlocked!", 
                achievements[index].title, achievements[index].image);
            break;
        }
    }
}

defaultproperties {
    broadcastedWaveEnd= true
}

