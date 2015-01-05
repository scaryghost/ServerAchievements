/**
 * Custom replication info class for ServerAchievements
 * @author etsai (Scary Ghost)
 */
class SAReplicationInfo extends LinkedReplicationInfo;

var bool broadcastedWaveEnd, initialized, signalReload, signalToss, signalFire, objectiveMode;
var string steamid64;
var SAMutator mutRef;
var PlayerReplicationInfo ownerPRI;
var array<AchievementPack> achievementPacks;
var KF_StoryObjective storedObjective;

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
    local KFPlayerReplicationInfo kfPRI;
    local AchievementPack pack;
    local HealingProjectile projectile;
    local int i;
    local PlayerController ownerPC;

    super.Tick(DeltaTime);

    if (!initialized) {
        ownerPC= PlayerController(Owner);
        if (ownerPC != None) {
            if (Level.NetMode != NM_DedicatedServer && ownerPC.Player != none && 
                    ownerPC.Player.GUIController != none) {
                steamid64= ownerPC.Player.GUIController.SteamGetUserID();
            } else {
                steamid64= ownerPC.GetPlayerIDHash();
            }
        }

        if (Role == ROLE_Authority) {
            mutRef.sendAchievements(self);
        }

        foreach DynamicActors(class'AchievementPack', pack) {
            if (pack.Owner == Owner) {
                addAchievementPack(pack);
            }
        }
        objectiveMode= KFStoryGameInfo(Level.Game) != none;
        SetTimer(1.0, true);
        initialized= true;
    }
    if (Role == ROLE_Authority && Owner != none && Controller(Owner).Pawn != none) {
        foreach Controller(Owner).Pawn.TouchingActors(class'HealingProjectile', projectile) {
            if (!hasProcessed(projectile)) {
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].touchedHealDart(projectile);
                }
                processedActors[processedActors.Length]= projectile;
            }
        }
        if (KFWeapon(Controller(Owner).Pawn.Weapon) != none) {
            if (!signalReload && KFWeapon(Controller(Owner).Pawn.Weapon).bIsReloading) {
                for(i= 0; i < achievementPacks.Length; i++) {
                    achievementPacks[i].reloadedWeapon(KFWeapon(Controller(Owner).Pawn.Weapon));
                }
                signalReload= true;
            } else if (signalReload && !KFWeapon(Controller(Owner).Pawn.Weapon).bIsReloading) {
                signalReload= false;
            }
        }
        if (!signalToss && KFPawn(Controller(Owner).Pawn).bThrowingNade) {
            kfPRI= KFPlayerReplicationInfo(Controller(Owner).PlayerReplicationInfo);
            for(i= 0; i < achievementPacks.Length; i++) {
                achievementPacks[i].tossedFrag(kfPRI.ClientVeteranSkill.Static.GetNadeType(kfPRI));
            }
            signalToss= true;
        } else if (signalToss && !KFPawn(Controller(Owner).Pawn).bThrowingNade) {
            signalToss= false;
        }
        if (!signalFire && Controller(Owner).Pawn.Weapon != none && Controller(Owner).Pawn.Weapon.IsFiring()) {
            for(i= 0; i < achievementPacks.Length; i++) {
                achievementPacks[i].firedWeapon(KFWeapon(Controller(Owner).Pawn.Weapon));
            }
            signalFire= true;
        } else if (signalFire && Controller(Owner).Pawn.Weapon != none && !Controller(Owner).Pawn.Weapon.IsFiring()) {
            signalFire= false;
        }
    }
}

function checkCurrentObjective() {
    local KF_StoryObjective currentObjective;
    local int i;

    currentObjective= KF_StoryGRI(Level.Game.GameReplicationInfo).GetCurrentObjective();
    if (storedObjective != currentObjective) {
        storedObjective= currentObjective;
        for(i= 0; i < achievementPacks.Length; i++) {
            achievementPacks[i].objectiveChanged(currentObjective);
        }
    }
}

function Timer() {
    local int realWaveNum;
    local int i;
    local bool eventTriggered, gameEnded;

    if (objectiveMode) {
        checkCurrentObjective();
    }
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
            gameEnded= true;
            SetTimer(0, false);
        }
    }
    if (eventTriggered) {
        broadcastedWaveEnd= !broadcastedWaveEnd;
    }
    if (gameEnded) {
        mutRef.saveAchievementData(self);
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
    local LinkedReplicationInfo lriIt;
    local SAReplicationInfo mspIt;

    if (pri == None) {
        return None;
    }
    for(lriIt= pri.CustomReplicationInfo; lriIt != None && lriIt.class != class'SAReplicationInfo';
            lriIt= lriIt.NextReplicationInfo) {
    }
    if (lriIt == None) {
        foreach pri.DynamicActors(class'SAReplicationInfo', mspIt)
            if (mspIt.ownerPRI == pri) 
                return mspIt;
        return None;
    }
    return SAReplicationInfo(lriIt);
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=True

    broadcastedWaveEnd= true
}
