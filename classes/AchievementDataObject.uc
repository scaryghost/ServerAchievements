/**
 * Data object representation of an achievement pack.  Stores achievement 
 * progress locally for each player
 * @author etsai (Scary Ghost)
 */
class AchievementDataObject extends Object
    PerObjectConfig
    config(ServerAchievementsProgress);

struct Data {
    var config string packName;
    var config string serializedData;
};

var() config array<Data> achievementData;

function string getSerializedData(string packName) {
    local int i;
    
    for(i= 0; i < achievementData.Length; i++) {
        if (achievementData[i].packName == packName) {
            return achievementData[i].serializedData;
        }
    }
    return "";
}

function updateSerializedData(string packName, string data) {
    local int i;

    for(i= 0; i < achievementData.Length; i++) {
        if (achievementData[i].packName == packName) {
            achievementData[i].serializedData= data;
            return;
        }
    }
    achievementData.Length= achievementData.Length + 1;
    achievementData[achievementData.Length - 1].packName= packName;
    achievementData[achievementData.Length - 1].serializedData= data;
}
