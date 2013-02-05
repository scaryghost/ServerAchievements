class SAMutator extends Mutator
    config(ServerAchievements);

var() config array<string> achievementPackNames;

var array<class<AchievementPackBase> > loadedAchievementPacks;
var array<SAReplicationInfo> saRIs;

function PostBeginPlay() {
    local GameRules grObj;
    local int i;

    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }
    AddToPackageMap();

    grObj= Spawn(class'SAGameRules');
    grObj.NextGameRules= Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers= grObj;

    for(i= 0; i < achievementPackNames.Length; i++) {
        loadedAchievementPacks[i]= class<AchievementPackBase>(DynamicLoadObject(achievementPAckNames[i], class'Class'));
        AddToPackageMap(string(loadedAchievementPacks[i].Outer.name));
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRI;

    if (PlayerReplicationInfo(Other) != none && 
            PlayerReplicationInfo(Other).Owner != none) {
        pri= PlayerReplicationInfo(Other);
        saRI= Spawn(class'SAReplicationInfo', pri.Owner);
        saRI.ownerPRI= pri;
        saRIs[saRIs.Length]= saRI;
        SetTimer(0.1, false);
    }

    return true;
}

function Timer() {
    local int i, j;

    for(i= 0; i < saRIs.Length; i++) {
        for(j= 0; j < loadedAchievementPacks.Length; j++) {
            saRIs[i].addAchievementPack(Spawn(loadedAchievementPacks[j], saRIs[i].Owner));
        }
    }
    saRIs.Length= 0;
}

defaultproperties {
    GroupName="KFServerAchievements"
    FriendlyName="Server Achievements v1.0"
    Description="Loads custom achievements into the game"
}
