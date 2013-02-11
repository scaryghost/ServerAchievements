class ServerTcpLink extends TcpLink;

var string separator;
var string header;
var string protocol;
var int version;

var IpAddr serverAddr;
var string hostname;
var int tcpPort;

function PostBeginPlay() {
    LinkMode= MODE_Line;
    tcpPort= class'SAMutator'.default.port;
    BindPort(tcpPort + 1, true);
    Resolve(class'SAMutator'.default.hostname);
    header=  protocol $ "-" $ version $ "-request";
}

event Resolved(IpAddr addr) {
    serverAddr= addr;
    serverAddr.port= tcpPort;

    if (!Open(Addr)) {
        log("Cannot reach remote host");
    }
}

event Opened() {
    local string request, response;
    local array<string> parts;

    request= header $ separator $ "connect" $ separator $ "password";
    SendText(request);
    ReadText(response);
    Split(response, separator, parts);
    if (int(parts[1]) != 0) {
        /** TODO: Handle non zero status */
        log("Invalid password!");
    }
}

function getAchievementData(string steamid64, string packName, out Serializable obj) {
    local string request, response;
    local array<string> parts;

    request= header $ separator $ "retrieve" $ separator $ steamid64 $ "," $ packName;
    SendText(request);
    ReadText(response);
    Split(response, separator, parts);

    /** TODO: check header and version */
    obj.deserializeUserData(parts[2]);
}

function saveAchievementData(string steamid64, string packName, Serializable obj) {
    local string request, response;
    local array<string> parts;

    request= header $ separator $ "save" $ separator $ steamid64 $ "," $ packName $ "," $ obj.serializeUserData();
    SendText(request);
    ReadText(response);
    Split(response, separator, parts);

    /** TODO: check header and version */
}


defaultproperties {
    separator= "|"
    protocol= "server-achievements"
    version= 1
}
