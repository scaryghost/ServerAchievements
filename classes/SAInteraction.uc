class SAInteraction extends Interaction;

struct PopupMessage {
    var string header;
    var string body;
    var Texture image;
};

var array<PopupMessage> messageQueue;
var float NotificationWidth, NotificationHeight, NotificationPhaseStartTime, NotificationIconSpacing, 
        NotificationShowTime, NotificationHideTime, NotificationHideDelay, NotificationBorderSize;
var int NotificationPhase;
var texture NotificationBackground;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function addMessage(string header, string body, Texture image) {
    messageQueue.Length= messageQueue.Length + 1;
    messageQueue[messageQueue.Length - 1].header= header;
    messageQueue[messageQueue.Length - 1].body= body;
    messageQueue[messageQueue.Length - 1].image= image;

    if (messageQueue.Length == 1) {
        NotificationPhaseStartTime= ViewportOwner.Actor.Level.TimeSeconds;
        NotificationPhase= 0;
        bVisible= true;
    }
}

function PostRender(Canvas canvas) {
    local float TimeElapsed;
    local float DrawHeight;
    local float IconSize, TempX, TempY, TempWidth, TempHeight;

    TimeElapsed= ViewportOwner.Actor.Level.TimeSeconds - NotificationPhaseStartTime;
    if (NotificationPhase == 0) { //Showing phase
        if (TimeElapsed < NotificationShowTime) {
            DrawHeight = (TimeElapsed / NotificationShowTime) * NotificationHeight;
        }
        else {
            NotificationPhase= 1; // Delaying Phase
            NotificationPhaseStartTime = ViewportOwner.Actor.Level.TimeSeconds - (TimeElapsed - NotificationShowTime);
            DrawHeight = NotificationHeight;
        }
    }
    else if (NotificationPhase == 1) {
        if ( TimeElapsed < NotificationHideDelay ) {
            DrawHeight = NotificationHeight;
        }
        else {
            NotificationPhase = 3; // Hiding Phase
            TimeElapsed -= NotificationHideDelay;
            NotificationPhaseStartTime = ViewportOwner.Actor.Level.TimeSeconds - TimeElapsed;
            DrawHeight = (TimeElapsed / NotificationHideTime) * NotificationHeight;
        }
    }
    else {
        if (TimeElapsed < NotificationHideTime) {
            DrawHeight = (1.0 - (TimeElapsed / NotificationHideTime)) * NotificationHeight;
        }
        else {
            // We're done
            messageQueue.remove(0, 1);
            if (messageQueue.Length != 0) {
                NotificationPhaseStartTime= ViewportOwner.Actor.Level.TimeSeconds;
            } else {
                bVisible= false;
            }
            return;
        }
    }

    // Initialize the Canvas
    canvas.Style = 1;
    canvas.Font = class'ROHUD'.Static.LoadMenuFontStatic(3);
    canvas.SetDrawColor(255, 255, 255, 255);

    // Calc Notification's Screen Offset
    TempX = (canvas.ClipX / 2.0) - (NotificationWidth / 2.0);
    TempY = canvas.ClipY - DrawHeight;

    // Draw the Background
    canvas.SetPos(TempX, TempY);
    canvas.DrawTileStretched(NotificationBackground, NotificationWidth, NotificationHeight);

    // Offset for Border and Calc Icon Size
    TempX += NotificationBorderSize;
    TempY += NotificationBorderSize;

    if (messageQueue[0].image != none) {
        IconSize = NotificationHeight - (NotificationBorderSize * 2.0);
        canvas.SetPos(TempX, TempY);
        canvas.DrawTile(messageQueue[0].image, IconSize, IconSize, 0, 0, messageQueue[0].image.USize, messageQueue[0].image.VSize);

        // Offset for desired Spacing between Icon and Text
        TempX += IconSize + NotificationIconSpacing;
    }

    canvas.SetPos(TempX, TempY);
    canvas.DrawText(messageQueue[0].header);
    // Set up next line
    canvas.StrLen(messageQueue[0].body, TempWidth, TempHeight);
    TempY += (TempHeight * 0.8);
    canvas.SetPos(TempX, TempY);
    canvas.DrawText(messageQueue[0].body);
}

defaultproperties {
    bActive= true

    NotificationWidth= 250.0
    NotificationHeight= 80
    NotificationShowTime= 0.3
    NotificationHideTime= 0.5
    NotificationHideDelay= 5.0
    NotificationBorderSize= 7.0
    NotificationIconSpacing= 10.0
    NotificationBackground=Texture'InterfaceArt_tex.Menu.DownTickBlurry'
}
