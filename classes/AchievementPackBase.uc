class AchievementPackBase extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var Texture image;

    var bool completed;
    var int progress;
    var int maxProgress;
    var int notifyProgress;
    var byte timesNotified;
    var byte canEarn;
};

var float flushPeriod, flushTimer;
var PlayerController PCOwner;
var array<Achievement> achievements;
var bool broadcastedWaveEnd;
var string packName;

replication {
    unreliable if (Role == ROLE_AUTHORITY) 
        achievementCompleted, notifyProgress, flushToClient;
}

function matchEnd(string mapname, float difficulty, int length, byte result);
function waveStart(int waveNum);
function waveEnd(int waveNum);
function playerDied(Controller killer, class<DamageType> damageType);
function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType);

event PostBeginPlay() {
    SetTimer(1.0, true);
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
            if (achievements[i].notifyProgress != 0) {
                flushToClient(i, achievements[i].progress);
            }
        }
        flushTimer= 0;
    }
}

simulated event PostNetBeginPlay() {
    if ( Level.NetMode != NM_DedicatedServer) {
        PCOwner= Level.GetLocalPlayerController();
        PCOwner.Player.InteractionMaster.AddInteraction("ServerAchievements.SAInteraction", PCOwner.Player);
    }
}

simulated event flushToClient(int index, int progress) {
    achievements[index].progress= progress;
}

simulated event notifyProgress(int index, int progress, int maxProgress) {
    local int i;

    for(i= 0; i < PCOwner.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(PCOwner.Player.LocalInteractions[i]) != none) {
            SAInteraction(PCOwner.Player.LocalInteractions[i]).addMessage("Achivement In Progress", 
                achievements[index].title@";("$ progress $ "/" $ maxProgress $ ")", achievements[index].image);
            break;
        }
    }
}

simulated event achievementCompleted(int index) {
    local int i;

    if (!achievements[index].completed) {
        achievements[index].completed= true;
        for(i= 0; i < PCOwner.Player.LocalInteractions.Length; i++) {
            if (SAInteraction(PCOwner.Player.LocalInteractions[i]) != none) {
                SAInteraction(PCOwner.Player.LocalInteractions[i]).addMessage("Achivement Unlocked!", 
                    achievements[index].title, achievements[index].image);
                break;
            }
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

