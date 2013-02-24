class AchievementPack extends Actor
    abstract;

/** TODO: Hook in trader events */
/** TODO: Hook in weapon usage */
event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum);
event waveStart(int waveNum);
event waveEnd(int waveNum);
event playerDied(Controller killer, class<DamageType> damageType, int waveNum);
event killedMonster(Pawn target, class<DamageType> damageType, bool headshot);
event damagedMonster(int damage, Pawn target, class<DamageType> damageType, bool headshot);

function string serializeUserData();
function deserializeUserData(string data);
simulated function fillAchievementInfo(int index, out string title, out string description, out Texture image, 
    out int maxProgress, out int progress, out byte completed);
simulated function int numAchievements();
simulated function string getPackName();

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
