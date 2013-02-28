/**
 * Partial implementation of the AchievementPack interface.  Provides member 
 * variables for storing the achievements, handles replication, and serializes 
 * achievement data
 * @author etsai (Scary Ghost)
 */
class AchievementPackPartImpl extends AchievementPack
    abstract;

struct Achievement {
    var string title;
    var string description;
    var Texture image;
    var int maxProgress;
    var float notifyIncrement;

    var int progress;
    var byte completed;

    var byte timesNotified;
};

var PlayerController localController;
var array<Achievement> achievements;
var bool dataModified;
var string packName;
var Texture defaultAchievementImage;

replication {
    reliable if (Role == ROLE_AUTHORITY) 
        localAchievementCompleted, notifyProgress, flushToClient;
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
    
    if (data != "") {
        Split(data, ";", parts);
        for(i= 0; i < parts.Length; i++) {
            Split(parts[i], ",", achvData);
            if (achvData.Length == 3) {
                j= int(achvData[0]);
                achievements[j].completed= byte(achvData[1]);
                achievements[j].progress= int(achvData[2]);
                flushToClient(j, achievements[j].progress, achievements[j].completed);
                if (achievements[j].completed == 0 && achievements[j].maxProgress != 0) {
                    achievements[j].timesNotified= int((achievements[j].progress/achievements[j].maxProgress)/achievements[j].notifyIncrement);
                }
            }
        }
    }
}

simulated function fillAchievementInfo(int index, out string title, out string description, out Texture image, 
    out int maxProgress, out int progress, out byte completed) {
    title= achievements[index].title;
    description= achievements[index].description;
    if (achievements[index].image == none) {
        image= defaultAchievementImage;
    } else {
        image= achievements[index].image;
    }
    maxProgress= achievements[index].maxProgress;
    progress= achievements[index].progress;
    completed= achievements[index].completed;
}

simulated function int numAchievements() {
    return achievements.Length;
}

simulated function string getPackName() {
    return packName;
}

simulated event PostNetBeginPlay() {
    if (ScriptedController(Owner) == none) {
        localController= Level.GetLocalPlayerController();
    }
}

simulated function flushToClient(int index, int progress, byte completed) {
    achievements[index].progress= progress;
    achievements[index].completed= completed;
}

simulated function notifyProgress(int index) {
    local int i;
    local Texture usedImage;

    for(i= 0; localController != none && i < localController.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(localController.Player.LocalInteractions[i]) != none) {
            if (achievements[index].image == none) {
                usedImage= defaultAchievementImage;
            } else {
                usedImage= achievements[index].image;
            }
            SAInteraction(localController.Player.LocalInteractions[i]).addMessage("Achievement In Progress", 
                achievements[index].title@";("$ achievements[index].progress $ "/" $ achievements[index].maxProgress $ ")", usedImage);
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
    local Texture usedImage;

    for(i= 0; localController != none && i < localController.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(localController.Player.LocalInteractions[i]) != none) {
            if (achievements[index].image == none) {
                usedImage= defaultAchievementImage;
            } else {
                usedImage= achievements[index].image;
            }
            SAInteraction(localController.Player.LocalInteractions[i]).addMessage("Achievement Unlocked!", 
                packName $ ";" $ achievements[index].title, usedImage);
            break;
        }
    }
}

defaultproperties {
    defaultAchievementImage= Texture'ServerAchievements.HUD.DefaultIcon'
}

