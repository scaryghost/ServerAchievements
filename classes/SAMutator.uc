class SAMutator extends Mutator;

function PostBeginPlay() {
    local GameRules grObj;

    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }

    grObj= Spawn(class'SAGameRules');
    grObj.NextGameRules= Level.Game.GameRulesModifiers;
    Level.Game.GameRulesModifiers= grObj;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local PlayerReplicationInfo pri;
    local SAReplicationInfo saRI;

    if (PlayerReplicationInfo(Other) != none && 
            PlayerReplicationInfo(Other).Owner != none) {
        pri= PlayerReplicationInfo(Other);
        saRI= spawn(class'SAReplicationInfo', pri.Owner);
        saRI.ownerPRI= pri;
    }

    return true;
}
