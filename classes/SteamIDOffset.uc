/**
 * Commandlet demoing the addOffset function
 * @author etsai (Scary Ghost)
 */
class SteamIDOffset extends Commandlet;
 
function int Main(string TextParameters) {
    local class<Utility> utilityRef;

    utilityRef= class<Utility>(DynamicLoadObject("ServerAchievements.Utility", class'Class'));
    log(TextParameters @ "+" @ class'SAReplicationInfo'.default.offset @ "=");
    utilityRef.static.addOffset(TextParameters, class'SAReplicationInfo'.default.offset);
    log(TextParameters);
    return 0;
}
