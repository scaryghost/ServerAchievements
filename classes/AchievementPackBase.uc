class AchievementPackBase extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var bool completed;
};

var PlayerController PCOwner;
var array<Achievement> achievements;

replication {
    unreliable if (Role == ROLE_AUTHORITY) 
        achievementCompleted;
}

function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType);

event PostBeginPlay();

// Overridden to Grab the Stats and Achievements from Steam on the Client
simulated event PostNetBeginPlay() {
    if ( Level.NetMode != NM_DedicatedServer) {
        PCOwner= Level.GetLocalPlayerController();
    }
}

simulated event achievementCompleted(int index) {
    if (!achievements[index].completed) {
        achievements[index].completed= true;
        PCOwner.myHUD.ShowPopupNotification(5.0, 3, Achievements[index].Title);
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

