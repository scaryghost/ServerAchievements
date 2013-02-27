/**
 * Mutator class for ServerAchievements
 * @author etsai (Scary Ghost)
 */
class SAMutator extends Mutator
    config(ServerAchievements);

var() config bool useRemoteDatabase;
var() config int tcpPort;
var() config string hostname;
var() config string localHostSteamID64;
var() config array<string> achievementPacks;

var array<class<AchievementPack> > loadedAchievementPacks;
var ServerTcpLink serverLink;
var SAGameRules grObj;

simulated function Tick(float DeltaTime) {
    local PlayerController localController;

    localController= Level.GetLocalPlayerController();
    if (localController != none) {
        localController.Player.InteractionMaster.AddInteraction("ServerAchievements.SAInteraction", localController.Player);
    }
    Disable('Tick');
}

function PostBeginPlay() {
    local int i;
    local class<AchievementPack> loadedPack;

    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }
    AddToPackageMap();

    grObj= Spawn(class'SAGameRules');
    grObj.NextGameRules= Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers= grObj;

    log("Attempting to load"@achievementPacks.Length@"achievement packs");
    for(i= 0; i < achievementPacks.Length; i++) {
        loadedPack= class<AchievementPack>(DynamicLoadObject(achievementPacks[i], class'Class'));
        if (loadedPack == none) {
            Warn("Failed to load achievement pack"@achievementPacks[i]);
        } else {
            log("Successfully loaded"@achievementPacks[i]);
            loadedAchievementPacks[loadedAchievementPacks.Length]= loadedPack;
            AddToPackageMap(string(loadedPack.Outer.name));
        }
    }
    log("Successfully loaded"@loadedAchievementPacks.Length@"achievement packs");
    if (useRemoteDatabase) {
        serverLink= spawn(class'ServerTcpLink');
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRI;

    if (PlayerReplicationInfo(Other) != none && Other.Owner != none) {
        pri= PlayerReplicationInfo(Other);
        saRI= Spawn(class'SAReplicationInfo', pri.Owner);
        saRI.ownerPRI= pri;
        saRI.mutRef= Self;
    } else if (KFMonster(Other) != none) {
        grObj.aliveMonsters.Length= grObj.aliveMonsters.Length + 1;
        grObj.aliveMonsters[grObj.aliveMonsters.Length - 1].monster= KFMonster(Other);
        grObj.aliveMonsters[grObj.aliveMonsters.Length - 1].prevHeadHealth= KFMonster(Other).default.HeadHealth * 
            KFMonster(Other).DifficultyHeadHealthModifer() * KFMonster(Other).NumPlayersHeadHealthModifer();
    }

    return true;
}

function sendAchievements(SAReplicationInfo saRI) {
    local int j;
    local AchievementPack pack;
    local AchievementDataObject dataObj;

    if (Controller(saRI.Owner) != none && Controller(saRI.Owner).bIsPlayer) {
        dataObj= new(None, saRI.steamid64) class'AchievementDataObject';
        for(j= 0; j < loadedAchievementPacks.Length; j++) {
            pack= Spawn(loadedAchievementPacks[j], saRI.Owner);
            if (useRemoteDatabase) {
                serverLink.getAchievementData(saRI.steamid64, pack.getPackName(), pack);
            } else {
                pack.deserializeUserData(dataObj.getSerializedData(pack.getPackName()));
            }
            saRI.addAchievementPack(pack);
        }
    }
}

function NotifyLogout(Controller Exiting) {
    local SAReplicationInfo saRI;
    local array<AchievementPack> packs;
    local AchievementDataObject dataObj;
    local int i;

    saRI= class'SAReplicationInfo'.static.findSAri(Exiting.PlayerReplicationInfo);
    saRI.getAchievementPacks(packs);
    dataObj= new(None, saRI.steamid64) class'AchievementDataObject';
    for(i= 0; i < packs.Length; i++) {
        if (useRemoteDatabase) {
            serverLink.saveAchievementData(saRI.steamid64, packs[i].getPackName(), packs[i]);
        } else {
            dataObj.updateSerializedData(packs[i].getPackName(), packs[i].serializeUserData());
        }
    }
    if (!useRemoteDatabase) {
        dataObj.SaveConfig();
    }
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("ServerAchievements", "useRemoteDatabase", "Use Remote Database", 0, 0, "Check",,,, true);
    PlayInfo.AddSetting("ServerAchievements", "hostname", "Remote Server Address", 0, 0, "Text", "128",,, true);
    PlayInfo.AddSetting("ServerAchievements", "tcpPort", "Remote Server Port", 0, 0, "Text",,,, true);
    PlayInfo.AddSetting("ServerAchievements", "localHostSteamID64", "Local Host SteamID64", 0, 0, "Text", "128");
    PlayInfo.AddSetting("ServerAchievements", "achievementPacks", "Achievement Packs", 1, 1, "Text", "42",,,);
}


static event string GetDescriptionText(string property) {
    switch(property) {
        case "achievementPacks":
            return "Achievement packs to load.  Must be in full package.classname format";
        case "localHostSteamID64":
            return "SteamID64 of the local host.  Only used for solo games or listen server host";
        case "useRemoteDatabase":
            return "Store achievement progress on a remote server";
        case "hostname":
            return "Host name of the remote server";
        case "tcpPort":
            return "TCP Port number of the remote server";
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
}
