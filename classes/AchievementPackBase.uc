class AchievementPackBase extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var bool completed;
};

var array<Achievement> achievements;

function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType);

simulated function achievementCompleted(int index) {
    if (!achievements[index].completed) {
        achievements[index].completed= true;
        PlayerController(Owner).myHUD.ShowPopupNotification(5.0, 3, Achievements[Index].Title);
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

