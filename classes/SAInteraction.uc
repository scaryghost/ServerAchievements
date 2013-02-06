class SAInteraction extends Interaction;

var float NotificationWidth, NotificationHeight;
var texture NotificationBackground;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function PostRender(Canvas canvas) {
    local float DrawHeight;
    local float TempX, TempY;

    DrawHeight= NotificationHeight;
    // Initialize the Canvas
    canvas.Style = 1;
    canvas.Font = class'ROHUD'.Static.LoadMenuFontStatic(2);
    canvas.SetDrawColor(255, 255, 255, 255);

    // Calc Notification's Screen Offset
    TempX = (canvas.ClipX / 2.0) - (NotificationWidth / 2.0);
    TempY = canvas.ClipY - DrawHeight;

    // Draw the Background
    canvas.SetPos(TempX, TempY);
    canvas.DrawTileStretched(NotificationBackground, NotificationWidth, NotificationHeight);
}

defaultproperties {
    bActive= true
    bVisible= true

    NotificationWidth= 200.0
    NotificationHeight= 80
    NotificationBackground=Texture'InterfaceArt_tex.Menu.DownTickBlurry'
}
