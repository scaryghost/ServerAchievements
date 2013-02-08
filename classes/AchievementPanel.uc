class AchievementPanel extends MidGamePanel;

var automated GUISectionBackground i_BGStats;
var automated moComboBox packNames;
var automated AchievementListBox lb_StatSelect;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
    packNames.OnChange= InternalOnChange;
    packNames.OnLoadINI= InternalOnLoadINI;

    i_BGStats.ManageComponent(packNames);
    i_BGStats.ManageComponent(lb_StatSelect);
    super.InitComponent(MyController, MyOwner);
}

function InternalOnChange(GUIComponent sender) {
    local SAReplicationInfo ownerSAri;

    ownerSAri= class'SAReplicationInfo'.static.findSAri(PlayerOwner().PlayerReplicationInfo);
    lb_StatSelect.listObj.InitList(ownerSAri.achievementPacks[packNames.GetIndex()]);
}

function InternalOnLoadINI(GUIComponent sender, string s) {
    local int i;
    local SAReplicationInfo ownerSAri;

    ownerSAri= class'SAReplicationInfo'.static.findSAri(PlayerOwner().PlayerReplicationInfo);
    for(i= 0; i < ownerSAri.achievementPacks.Length; i++) {
        packNames.AddItem(ownerSAri.achievementPacks[i].packName);
    }
    lb_StatSelect.listObj.InitList(ownerSAri.achievementPacks[0]);
}

defaultproperties {
    Begin Object Class=moComboBox Name=packComboBox
        bReadOnly=True
        bAlwaysNotify=True
        ComponentJustification=TXTA_Left
        Caption="Player"
        IniOption="@Internal"
        Hint="View achievement list for selected achievement pack"
        TabOrder=3
        WinTop= 0.085
        WinLeft=0.25
    End Object
    packNames=moComboBox'ServerAchievements.AchievementPanel.packComboBox'

    Begin Object Class=GUISectionBackground Name=BGStats
        bFillClient=True
        Caption="Achievements"
        WinTop=0.058063
        WinLeft=0.019240
        WinWidth=0.961520
        WinHeight=0.896032
    End Object
    i_BGStats=GUISectionBackground'ServerAchievements.AchievementPanel.BGStats'

    Begin Object Class=AchievementListBox Name=listBox
        WinTop=0.097760
        WinLeft=0.029240
        WinWidth=0.941520
        WinHeight=0.892836
    End Object
    lb_StatSelect=AchievementListBox'ServerAchievements.AchievementPanel.listBox'
}
