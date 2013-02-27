/**
 * Panel for displaying achievement progress
 * @author etsai (Scary Ghost)
 */
class AchievementPanel extends KFGui.KFTab_MidGameVoiceChat;

var automated GUISectionBackground panelBg;
var automated moComboBox packNames;
var automated AchievementListBox achvSelect;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    packNames.OnChange= InternalOnChange;
    packNames.OnLoadINI= InternalOnLoadINI;

    super.InitComponent(MyController, MyOwner);
}

function InternalOnChange(GUIComponent sender) {
    local SAReplicationInfo ownerSAri;
    local array<AchievementPack> packs;

    if (sender == packNames) {
        ownerSAri= class'SAReplicationInfo'.static.findSAri(PlayerOwner().PlayerReplicationInfo);
        ownerSAri.getAchievementPacks(packs);
        achvSelect.listObj.setAchievementPack(packs[packNames.GetIndex()]);
    }
}

function InternalOnLoadINI(GUIComponent sender, string s) {
    local int i;
    local SAReplicationInfo ownerSAri;
    local array<AchievementPack> packs;

    ownerSAri= class'SAReplicationInfo'.static.findSAri(PlayerOwner().PlayerReplicationInfo);
    ownerSAri.getAchievementPacks(packs);
    if (sender == packNames && packNames.ItemCount() == 0) {
        packNames.ResetComponent();
        for(i= 0; i < ownerSAri.achievementPacks.Length; i++) {
            packNames.AddItem(packs[i].getPackName());
        }
    } else if (sender == achvSelect) {
        achvSelect.listObj.setAchievementPack(packs[0]);
    }
}

function FillPlayerLists() {
}

defaultproperties {
    ch_NoVoiceChat= None
    ch_NoSpeech= None
    ch_NoText= None
    ch_Ban= None

    sb_Specs= None
    sb_Players= None
    sb_Options= None

    Begin Object Class=moComboBox Name=packComboBox
        bReadOnly=True
        bAlwaysNotify=True
        ComponentJustification=TXTA_Left
        Caption="Achievement Packs"
        IniOption="@Internal"
        Hint="View achievement list for selected achievement pack"
        TabOrder=3
        WinTop= 0.0535
        WinLeft=0.25
    End Object
    packNames=moComboBox'ServerAchievements.AchievementPanel.packComboBox'

    Begin Object Class=GUISectionBackground Name=BGStats
        bFillClient=True
        Caption="Achievements"
        WinTop=0.01
        WinLeft=0.012240
        WinWidth=0.981520
        WinHeight=0.85
    End Object
    panelBg=GUISectionBackground'ServerAchievements.AchievementPanel.BGStats'

    Begin Object Class=AchievementListBox Name=listBox
        WinTop=0.090760
        WinLeft=0.019240
        WinWidth=0.97
        WinHeight=0.75
    End Object
    achvSelect=AchievementListBox'ServerAchievements.AchievementPanel.listBox'
}
