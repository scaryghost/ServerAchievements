/**
 * Manages the list of achievements to display in the panel
 * @author etsai (Scary Ghost)
 */
class AchievementList extends KFGui.KFAchievementsList;

var AchievementPack selectedPack;

function setAchievementPack(AchievementPack pack) {
    SetIndex(0);
    selectedPack= pack;
    ItemCount= selectedPack.numAchievements();

    if (bNotify) {
        CheckLinkedObjects(Self);
    }

    if (MyScrollBar != none) {
        MyScrollBar.AlignThumb();
    }
}

function DrawAchievement(Canvas Canvas, int Index, float X, float Y, float Width, float Height, bool bSelected, bool bPending) {
    local float TempX, TempY;
    local float IconSize;
    local string ProgressString, title, description;
    local Texture image;
    local int maxProgress, progress;
    local byte completed;

    selectedPack.fillAchievementInfo(Index, title, description, image, maxProgress, progress, completed);
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
    if (completed == 1) {
        Canvas.DrawTile(image, IconSize, IconSize, 0, 0, 64, 64);
    }
    else {
        Canvas.DrawTile(Texture'KillingFloorHUD.Achievements.KF_Achievement_Lock', IconSize, IconSize, 0, 0, 64, 64);
    }

    TempX += IconSize + IconToNameSpacing * Width;
    TempY += TextTopOffset * Height;

    //Draw the Display Name
    SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX, TempY, Width - TempX, TextHeight * Height, TXTA_Left, title, FNS_Medium);

    //Draw the Description
    SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX, TempY + (TextHeight * Height) + (NameToDescriptionSpacing * Height), Width - TempX, TextHeight * Height, TXTA_Left, description, FNS_Small);

    if (maxProgress != 0) {
        TempX = X + Width - (OuterBorder * Width) - (ItemBorder * Height * 2.0) - (ProgressBarWidth * Width);
        TempY = Y + (Height / 2.0) - (ProgressBarHeight * Height / 2.0);

        // Draw Progress Bar
        Canvas.SetPos(TempX, TempY);
        Canvas.DrawTileStretched(ProgressBarBackground, ProgressBarWidth * Width, ProgressBarHeight * Height);
        Canvas.SetPos(TempX + 3.0, TempY + 3.0);
        if (progress < maxProgress) {
            Canvas.DrawTileStretched(ProgressBarForeground, ((ProgressBarWidth * Width) - 6.0) * (float(progress) / float(maxProgress)), ProgressBarHeight * Height - 6.0);
            ProgressString = progress$"/"$maxProgress;
        }
        else {
            Canvas.DrawTileStretched(ProgressBarForeground, ProgressBarWidth * Width - 6.0, ProgressBarHeight * Height - 6.0);
            ProgressString = maxProgress$"/"$maxProgress;
        }

        // Draw Progress Text
        SectionStyle.DrawText(Canvas, MSAT_Blurry, TempX - 150 - (ProgressTextSpacing * Width), TempY, 150, (TextHeight * Height), TXTA_Right, ProgressString, FNS_Medium);
    }
}

function float AchievementHeight(Canvas c) {
    return (MenuOwner.ActualHeight() / 8.0) - 1.0;
}

defaultproperties {
    TextHeight=0.275
    FontScale=FNS_Small

    GetItemHeight=AchievementList.AchievementHeight
    OnDrawItem=AchievementList.DrawAchievement
}
