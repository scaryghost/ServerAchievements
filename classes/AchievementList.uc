class AchievementList extends GUIVertList;

var AchievementPackBase currentPack;

// Settings
var()   float   OuterBorder;
var()   float   ItemBorder;
var()   float   TextTopOffset;
var()   float   ItemSpacing;
var()   float   IconToNameSpacing;
var()   float   NameToDescriptionSpacing;
var()   float   ProgressBarWidth;
var()   float   ProgressBarHeight;
var()   float   ProgressTextSpacing;
var()   float   TextHeight;

// Display
var texture ItemBackground;
var texture ProgressBarBackground;
var texture ProgressBarForeground;

function InitList(AchievementPackBase pack) {
    SetIndex(0);
    currentPack= pack;
    ItemCount= currentPack.achievements.Length;

    if ( bNotify ) {
        CheckLinkedObjects(Self);
    }

    if ( MyScrollBar != none ) {
        MyScrollBar.AlignThumb();
    }
}

function DrawAchievement(Canvas Canvas, int Index, float X, float Y, float Width, float Height, bool bSelected, bool bPending) {
    local float TempX, TempY;
    local float IconSize;
    local string ProgressString;

    // Offset for the Background
    TempX = X + OuterBorder * Width;
    TempY = Y + ItemSpacing / 2.0;

    // Initialize the Canvas
    Canvas.Style = 1;
    Canvas.SetDrawColor(255, 255, 255, 192);

    // Draw Item Background
    Canvas.SetPos(TempX, TempY);
    Canvas.DrawTileStretched(ItemBackground, Width - (OuterBorder * Width * 2.0), Height - ItemSpacing);
    Canvas.SetDrawColor(255, 255, 255, 255);

    // Offset and Calculate Icon's Size
    TempX += ItemBorder * Height;
    TempY += ItemBorder * Height;
    IconSize = Height - ItemSpacing - (ItemBorder * Height * 2.0);

    // Draw Icon
    Canvas.SetPos(TempX, TempY);
    if ( currentPack.achievements[Index].completed) {
        Canvas.DrawTile(currentPack.achievements[Index].image, IconSize, IconSize, 0, 0, 64, 64);
    }
/*
    else {
        Canvas.DrawTile(KFStatsAndAchievements.achievements[Index].LockedIcon, IconSize, IconSize, 0, 0, 64, 64);
    }
*/

    TempX += IconSize + IconToNameSpacing * Width;
    TempY += TextTopOffset * Height;

    //Draw the Display Name
    SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX, TempY, Width - TempX, TextHeight * Height, TXTA_Left, currentPack.achievements[Index].title, FNS_Medium);

    //Draw the Description
    SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX, TempY + (TextHeight * Height) + (NameToDescriptionSpacing * Height), Width - TempX, TextHeight * Height, TXTA_Left, currentPack.achievements[Index].description, FNS_Small);

    if ( currentPack.achievements[Index].notifyProgress != 0) {
        TempX = X + Width - (OuterBorder * Width) - (ItemBorder * Height * 2.0) - (ProgressBarWidth * Width);
        TempY = Y + (Height / 2.0) - (ProgressBarHeight * Height / 2.0);

        // Draw Progress Bar
        Canvas.SetPos(TempX, TempY);
        Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth * Width, ProgressBarHeight * Height);
        Canvas.SetPos(TempX + 3.0, TempY + 3.0);
        if (currentPack.achievements[Index].progress < currentPack.achievements[Index].maxProgress) {
            Canvas.DrawTileStretched(ProgressBarForeground, ((ProgressBarWidth * Width) - 6.0) * (float(currentPack.achievements[Index].progress) / float(currentPack.achievements[Index].maxProgress)), ProgressBarHeight * Height - 6.0);
        }
        else
        {
            Canvas.DrawTileStretched(ProgressBarForeground, ProgressBarWidth * Width - 6.0, ProgressBarHeight * Height - 6.0);
        }

        // Draw Progress Text
        ProgressString = currentPack.achievements[Index].progress$"/"$currentPack.achievements[Index].maxProgress;
        SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX - 150 - (ProgressTextSpacing * Width), TempY, 150, (TextHeight * Height), TXTA_Right, ProgressString, FNS_Medium);
    }
}

function float AchievementHeight(Canvas c) {
    return (MenuOwner.ActualHeight() / 4.0) - 1.0;
}

defaultproperties {
    OuterBorder=0.015
    ItemBorder=0.05
    TextTopOffset=0.082
    ItemSpacing=5.0
    IconToNameSpacing=0.018
    ProgressBarWidth=0.227
    ProgressBarHeight=0.225
    NameToDescriptionSpacing=0.125
    ProgressTextSpacing=0.009
    TextHeight=0.225

    ItemBackground=Texture'KF_InterfaceArt_tex.Menu.Thin_border_SlightTransparent'
    ProgressBarBackground=Texture'KF_InterfaceArt_tex.Menu.Innerborder'
    ProgressBarForeground=Texture'InterfaceArt_tex.Menu.progress_bar'

    FontScale=FNS_Medium
    GetItemHeight=AchievementList.AchievementHeight
    OnDrawItem=AchievementList.DrawAchievement
}