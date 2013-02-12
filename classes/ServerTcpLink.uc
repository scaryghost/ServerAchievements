class ServerTcpLink extends TcpLink;

var string separator;
var string header;
var string protocol;
var int version;

var IpAddr serverAddr;
var string hostname;

function PostBeginPlay() {
    LinkMode= MODE_Line;
    ReceiveMode= RMODE_Manual;
    Resolve(class'SAMutator'.default.hostname);
    header=  protocol $ "-" $ version $ "-request";
}

event Resolved(IpAddr addr) {
    serverAddr= addr;
    serverAddr.port= class'SAMutator'.default.port;

    if (!Open(serverAddr)) {
        log("Cannot reach remote host");
    }
}

event Opened() {
    local string request, response;
    local int i;
    local array<string> parts;

    request= header $ separator $ "connect" $ separator $ "password";
    SendText(request);
    do {
        i= ReadText(response);
    } until (i != 0);
    Split(response, separator, parts);
    if (int(parts[1]) != 0) {
        /** TODO: Handle non zero status */
        log("Invalid password!");
    }
}

function getAchievementData(string steamid64, string packName, out Serializable obj) {
    local int i;
    local string request, response;
    local array<string> parts;

    request= header $ separator $ "retrieve" $ separator $ steamid64 $ "," $ packName;
    SendText(request);
    do {
        i= ReadText(response);
    } until (i != 0);
    Split(response, separator, parts);

    /** TODO: check header and version */
    obj.deserializeUserData(parts[2]);
}

function saveAchievementData(string steamid64, string packName, Serializable obj) {
    local int i;
    local string request, response;
    local array<string> parts;

    request= header $ separator $ "save" $ separator $ steamid64 $ "," $ packName $ "," $ obj.serializeUserData();
    SendText(request);
    do {
        i= ReadText(response);
    } until (i != 0);
    Split(response, separator, parts);

    /** TODO: check header and version */
}


defaultproperties {
    separator= "|"
    protocol= "server-achievements"
    version= 1
}
