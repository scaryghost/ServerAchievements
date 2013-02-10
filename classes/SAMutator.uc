class SAMutator extends Mutator
    config(ServerAchievements);

var() config float clientUpdatePeriod;
var() config array<string> achievementPackNames;

var array<class<AchievementPackBase> > loadedAchievementPacks;

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
        saRI.mutRef= Self;
    } else if (AchievementPackBase(Other) != none) {
        AchievementPackBase(Other).flushPeriod= clientUpdatePeriod;
    }

    return true;
}

function sendAch(SAReplicationInfo saRI) {
    local int j;
        for(j= 0; j < loadedAchievementPacks.Length; j++) {
            saRI.addAchievementPack(Spawn(loadedAchievementPacks[j], saRI.Owner));
        }
        saRI.numPacks= loadedAchievementPacks.Length;
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("ServerAchievements", "clientUpdatePeriod", "Client Update Period", 0, 1, "Text");
}


static event string GetDescriptionText(string property) {
    switch(property) {
        case "clientUpdatePeriod":
            return "Time (in seconds) between achievement progress updates sent to the client";
        default:
            return Super.GetDescriptionText(property);
    }
}

defaultproperties {
    GroupName="KFServerAchievements"
    FriendlyName="Server Achievements v1.0"
    Description="Loads custom achievements into the game"

    clientUpdatePeriod= 10.0
}
