/**
 * Commandlet demoing the addOffset function
 * @author etsai (Scary Ghost)
 */
class SteamIDOffset extends Commandlet;
 
function int Main(string TextParameters) {
    local class<Utility> utilityRef;
    local string test, offset;
    local array<string> parts;

    offset= "76561197960265728";
    utilityRef= class<Utility>(DynamicLoadObject("ServerAchievements.Utility", class'Class'));
    log(TextParameters @ "+" @ offset @ "=");
    utilityRef.static.addOffset(TextParameters, offset);
    log(TextParameters);

    test="1,2,";
    Split(test, ",", parts);
    log(parts.Length);
    log(len(parts[0]));
    log(len(parts[1]));
    log(len(parts[2]));
    return 0;
}
