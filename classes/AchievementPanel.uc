class AchievementPanel extends KFGui.KFTab_MidGameVoiceChat;

var automated GUISectionBackground i_BGStats;
var automated moComboBox packNames;
var automated AchievementListBox lb_StatSelect;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    packNames.OnChange= InternalOnChange;
    packNames.OnLoadINI= InternalOnLoadINI;

    super.InitComponent(MyController, MyOwner);
}

function InternalOnChange(GUIComponent sender) {
    local SAReplicationInfo ownerSAri;
    local array<AchievementPackBase> packs;

    ownerSAri= class'SAReplicationInfo'.static.findSAri(PlayerOwner().PlayerReplicationInfo);
    ownerSAri.getAchievementPacks(packs);
    lb_StatSelect.listObj.InitList(packs[packNames.GetIndex()]);
}

function InternalOnLoadINI(GUIComponent sender, string s) {
    local int i;
    local SAReplicationInfo ownerSAri;
    local array<AchievementPackBase> packs;

    ownerSAri= class'SAReplicationInfo'.static.findSAri(PlayerOwner().PlayerReplicationInfo);
    ownerSAri.getAchievementPacks(packs);
    packNames.ResetComponent();
    for(i= 0; i < ownerSAri.achievementPacks.Length; i++) {
        packNames.AddItem(packs[i].packName);
    }
    lb_StatSelect.listObj.InitList(packs[0]);
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
        WinTop= 0.0135
        WinLeft=0.25
    End Object
    packNames=moComboBox'ServerAchievements.AchievementPanel.packComboBox'

    Begin Object Class=GUISectionBackground Name=BGStats
        bFillClient=True
        Caption="Achievements"
        WinTop=0.054063
        WinLeft=0.012240
        WinWidth=0.981520
        WinHeight=0.798982
    End Object
    i_BGStats=GUISectionBackground'ServerAchievements.AchievementPanel.BGStats'

    Begin Object Class=AchievementListBox Name=listBox
        WinTop=0.090760
        WinLeft=0.019240
        WinWidth=0.97
        WinHeight=0.75
    End Object
    lb_StatSelect=AchievementListBox'ServerAchievements.AchievementPanel.listBox'
}
