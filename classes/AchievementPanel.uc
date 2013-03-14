/**
 * Panel for displaying achievement progress
 * @author etsai (Scary Ghost)
 */
class AchievementPanel extends KFGui.KFTab_MidGameVoiceChat;

var automated GUISectionBackground panelBg;
var automated GUIProgressBar progressBar;
var automated moComboBox packNames;
var automated AchievementListBox achvSelect;

function updateProgressBar() {
    progressBar.Value= achvSelect.listObj.selectedPack.getNumCompleted();
    progressBar.High= achvSelect.listObj.selectedPack.numAchievements();
    progressBar.Caption= int(progressBar.Value) $ "/" $ int(progressBar.High);
    progressBar.CaptionWidth= Len(ProgressBar.Caption) * 20;
}

function ShowPanel(bool bShow){
    if (bShow) {
        updateProgressBar();
    }

    super.ShowPanel(bShow);
}

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
        updateProgressBar();
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
        WinTop=0.130760
        WinLeft=0.019240
        WinWidth=0.97
        WinHeight=0.725
    End Object
    achvSelect=AchievementListBox'ServerAchievements.AchievementPanel.listBox'

    Begin Object class=GUIProgressBar Name=AchievementProgressBar
        BarColor=(R=255,G=255,B=255,A=255)
        Value=0.0
        WinWidth=0.655610
        WinHeight=0.030000
        WinLeft=0.180867
        WinTop=0.090000
        RenderWeight=1.2
        BarBack=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
        BarTop=Texture'InterfaceArt_tex.Menu.progress_bar'
        CaptionWidth=0
        bShowValue=false
        BorderSize=3.0
    End Object
    progressBar=AchievementProgressBar
}
