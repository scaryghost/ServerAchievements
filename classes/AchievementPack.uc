class AchievementPack extends Actor
    abstract;

var string packName;

event matchEnd(string mapname, float difficulty, int length, byte result);
event waveStart(int waveNum);
event waveEnd(int waveNum);
event playerDied(Controller killer, class<DamageType> damageType);
event killedMonster(Pawn target, class<DamageType> damageType);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);

function string serializeUserData();
function deserializeUserData(string data);

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
