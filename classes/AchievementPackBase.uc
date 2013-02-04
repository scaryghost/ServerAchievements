class AchievementPackBase extends Actor
    abstract;

struct Achievement {
    var string title;
    var string description;
    var byte completed;
};

var array<Achievement> achievements;

function killedMonster(Pawn target, class<DamageType> damageType);
function damagedMonster(int damage, Pawn target, class<DamageType> damageType);
