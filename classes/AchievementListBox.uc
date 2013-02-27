/**
 * Container for the achievement list
 * @author etsai (Scary Ghost)
 */
class AchievementListBox extends GUIListBoxBase;

var AchievementList listObj;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    Super.InitComponent(MyController,MyOwner);
    listObj = AchievementList(AddComponent(DefaultListClass));
    if (listObj == None) {
        Warn(Class$".InitComponent - Could not create default list ["$DefaultListClass$"]");
        return;
    }
    InitBaseList(listObj);
}

function int GetIndex() {
    return listObj.Index;
}

defaultproperties {
    DefaultListClass="ServerAchievements.AchievementList"
}
