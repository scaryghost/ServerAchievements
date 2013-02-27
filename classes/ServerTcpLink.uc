/**
 * Creates a TCP link with the remote database to store achievement data on another machine
 * @author etsai (Scary Ghost)
 */
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
    BindPort();
    Resolve(class'SAMutator'.default.hostname);
    header=  protocol $ "-" $ version $ "-request";
}

event Resolved(IpAddr addr) {
    serverAddr= addr;
    serverAddr.port= class'SAMutator'.default.tcpPort;

    if (!Open(serverAddr)) {
        log("Cannot reach remote host"@IpAddrToString(serverAddr));
    }
}

event Opened() {
    local string response;
    local int len;
    local array<string> parts;

    SendText(header $ separator $ "connect" $ separator $ "password");
    do {
        len= ReadText(response);
    } until (len != 0);
    Split(response, separator, parts);
    if (int(parts[1]) != 0) {
        /** TODO: Handle non zero status */
        log("Invalid password!");
    }
}

function getAchievementData(string steamid64, string packName, out AchievementPack obj) {
    local int len;
    local string response;
    local array<string> parts;

    if (IsConnected()) {
        SendText(header $ separator $ "retrieve" $ separator $ steamid64 $ "," $ packName);
        do {
            len= ReadText(response);
        } until (len != 0);
        Split(response, separator, parts);

        /** TODO: check header and version */
        obj.deserializeUserData(parts[2]);
    }
}

function saveAchievementData(string steamid64, string packName, AchievementPack obj) {
    local int len;
    local string response;
    local array<string> parts;

    if (IsConnected()) {
        SendText(header $ separator $ "save" $ separator $ steamid64 $ "," $ packName $ "," $ obj.serializeUserData());
        do {
            len= ReadText(response);
        } until (len != 0);
        Split(response, separator, parts);

        /** TODO: check header and version */
    }
}


defaultproperties {
    separator= "|"
    protocol= "server-achievements"
    version= 1
}
