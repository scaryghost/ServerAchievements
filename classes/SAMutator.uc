class SAMutator extends Mutator
    config(ServerAchievements);

var() config bool persistAchievements;
var() config int port;
var() config string hostname;
var() config float clientUpdatePeriod;
var() config array<string> achievementPackNames;

var array<class<AchievementPackBase> > loadedAchievementPacks;
var ServerTcpLink serverLink;

simulated function Tick(float DeltaTime) {
    local PlayerController localController;

    localController= Level.GetLocalPlayerController();
    if (localController != none) {
        localController.Player.InteractionMaster.AddInteraction("ServerAchievements.SAInteraction", localController.Player);
    }
    Disable('Tick');
}

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
    if (persistAchievements) {
        serverLink= spawn(class'ServerTcpLink');
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

function sendAchievements(SAReplicationInfo saRI) {
    local int j;
    local AchievementPackBase pack;
    local Serializable serial;

    for(j= 0; j < loadedAchievementPacks.Length; j++) {
        pack= Spawn(loadedAchievementPacks[j], saRI.Owner);
        serial= pack;
        serverLink.getAchievementData(saRI.steamid64, pack.packName, serial);
        saRI.addAchievementPack(pack);
    }
}

function NotifyLogout(Controller Exiting) {
    local SAReplicationInfo saRI;
    local array<AchievementPackBase> packs;
    local int i;

    saRI= class'SAReplicationInfo'.static.findSAri(Exiting.PlayerReplicationInfo);
    if (persistAchievements) {
        saRI.getAchievementPacks(packs);
        for(i= 0; i < packs.Length; i++) {
            serverLink.saveAchievementData(saRI.steamid64, packs[i].packName, packs[i]);
        }
    }
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("ServerAchievements", "clientUpdatePeriod", "Client Update Period", 0, 1, "Text");
    PlayInfo.AddSetting("ServerAchievements", "persistAchievements", "Persist Achievements", 0, 0, "Check");
    PlayInfo.AddSetting("ServerAchievements", "hostname", "Remote Server Address", 0, 0, "Text", "128");
    PlayInfo.AddSetting("ServerAchievements", "port", "Remote Server Port", 0, 0, "Text");
    
}


static event string GetDescriptionText(string property) {
    switch(property) {
        case "clientUpdatePeriod":
            return "Time (in seconds) between achievement progress updates sent to the client";
        case "persistAchievements":
            return "Store a persistant state of achievement progress for each player";
        case "hostname":
            return "Host name of the remote server";
        case "port":
            return "Port number of the remote server";
        default:
            return Super.GetDescriptionText(property);
    }
}

defaultproperties {
    GroupName="KFServerAchievements"
    FriendlyName="Server Achievements v1.0"
    Description="Loads custom achievements into the game"

    RemoteRole= ROLE_SimulatedProxy
    bAlwaysRelevant= true
    
    clientUpdatePeriod= 10.0
}
