class AchievementPackBase extends Info
    abstract;

struct Achievement {
    var string title;
    var string description;
    var bool completed;
};

var PlayerController pcOwner;
var array<Achievement> achievements;

function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType);

function achievementCompleted(int index) {
    if (!achievements[index].completed) {
        achievements[index].completed= true;
        pcOwner.myHUD.ShowPopupNotification(5.0, 3, Achievements[Index].Title);
    }
}
