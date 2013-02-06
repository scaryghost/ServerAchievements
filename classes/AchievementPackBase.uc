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
    local int i;

    for(i= 0; i < PCOwner.Player.LocalInteractions.Length; i++) {
        if (SAInteraction(PCOwner.Player.LocalInteractions[i]) != none) {
            SAInteraction(PCOwner.Player.LocalInteractions[i]).addMessage("Achivement In Progress", 
                achievements[index].title@"("$ progress $ "/" $ maxProgress $ ")", achievements[index].image);
            break;
        }
    }
}

simulated event achievementCompleted(int index) {
    local int i;

    if (!achievements[index].completed) {
        achievements[index].completed= true;
        for(i= 0; i < PCOwner.Player.LocalInteractions.Length; i++) {
            if (SAInteraction(PCOwner.Player.LocalInteractions[i]) != none) {
                SAInteraction(PCOwner.Player.LocalInteractions[i]).addMessage("Achivement Unlocked!", 
                    achievements[index].title, achievements[index].image);
                break;
            }
        }
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

