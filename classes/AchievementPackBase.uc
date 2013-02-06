class AchievementPackBase extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var Texture image;

    var bool completed;
    var int progress;
    var int maxProgress;
    var int notifyProgress;
    var byte timesNotified;
};

var PlayerController PCOwner;
var array<Achievement> achievements;

replication {
    unreliable if (Role == ROLE_AUTHORITY) 
        achievementCompleted, notifyProgress;
}

function playerDied(Controller killer, class<DamageType> damageType);
function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType);

event PostBeginPlay();

simulated event PostNetBeginPlay() {
    if ( Level.NetMode != NM_DedicatedServer) {
        PCOwner= Level.GetLocalPlayerController();
        PCOwner.Player.InteractionMaster.AddInteraction("ServerAchievements.SAInteraction", PCOwner.Player);
    }
}

simulated event notifyProgress(int index, int progress, int maxProgress) {
    PCOwner.myHUD.ShowPopupNotification(5.0, 2, achievements[index].title@"-"@progress $ "/" $ maxProgress, achievements[index].image);
}

simulated event achievementCompleted(int index) {
    if (!achievements[index].completed) {
        achievements[index].completed= true;
        PCOwner.myHUD.ShowPopupNotification(5.0, 2, achievements[index].title, achievements[index].image);
    }
}

defaultproperties {
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    bOnlyDirtyReplication=true
    bSkipActorPropertyReplication=true

    bStatic=false
    bNoDelete=false
    bHidden=true
}

