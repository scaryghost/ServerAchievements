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

function achievementCompleted(int index) {
    achievements[index].completed= true;
    PlayerController(Owner).myHUD.ShowPopupNotification(5.0, 3, Achievements[Index].Title);
}
