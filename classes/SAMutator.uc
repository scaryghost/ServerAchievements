class SAMutator extends Mutator
    config(ServerAchievements);

var() config array<string> achievementPackNames;

var array<class<AchievementPackBase> > loadedAchievementPacks;

function PostBeginPlay() {
    local GameRules grObj;
    local int i;

    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }

    grObj= Spawn(class'SAGameRules');
    grObj.NextGameRules= Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers= grObj;

    for(i= 0; i < achievementPackNames.Length; i++) {
        loadedAchievementPacks[i]= class<AchievementPackBase>(DynamicLoadObject(achievementPAckNames[i], class'Class'));
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local int i;
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRI;

    if (PlayerReplicationInfo(Other) != none && 
            PlayerReplicationInfo(Other).Owner != none) {
        pri= PlayerReplicationInfo(Other);
        saRI= spawn(class'SAReplicationInfo', pri.Owner);
        saRI.ownerPRI= pri;

        for(i= 0; i < loadedAchievementPacks.Length; i++) {
            saRI.addAchievementPack(Spawn(loadedAchievementPacks[i], pri.Owner));
        }
    }

    return true;
}

defaultproperties {
    GroupName="KFServerAchievements"
    FriendlyName="Server Achievements v1.0"
    Description="Loads custom achievements into the game"
}
