/**
 * Creates a TCP link with the remote database to store achievement data on another machine
 * @author etsai (Scary Ghost)
 */
class ServerTcpLink extends TcpLink;

var string separator, bodySeparator;
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
    header=  protocol $ "," $ version $ ",request";
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

    SendText(header $ separator $ "connect" $ separator $ class'SAMutator'.default.serverPassword);
    do {
        len= ReadText(response);
    } until (len != 0);
    log("Response:"@response);
    Split(response, separator, parts);
    if (int(parts[1]) != 0) {
        /** TODO: Handle non zero status */
        log("Invalid password!");
    }
}

event Closed() {
    super.Closed();
    log("Connection to remote database closed");
}

function string getAchievementData(string steamid64, string packName) {
    local int len;
    local string response;
    local array<string> parts;

    if (IsConnected()) {
        SendText(header $ separator $ "retrieve" $ separator $ steamid64 $ bodySeparator $ packName);
        do {
            len= ReadText(response);
        } until (len != 0);
        Split(response, separator, parts);

        /** TODO: check header and version */
        return parts[2];
    }
    return "";
}

function saveAchievementData(string steamid64, string packName, string data) {
    local int len;
    local string response;
    local array<string> parts;

    if (IsConnected()) {
        SendText(header $ separator $ "save" $ separator $ steamid64 $ bodySeparator $ packName $ bodySeparator $ data);
        do {
            len= ReadText(response);
        } until (len != 0);
        Split(response, separator, parts);

        /** TODO: check header and version */
    }
}


defaultproperties {
    separator= "|"
    bodySeparator= "."
    protocol= "server-achievements"
    version= 1
}
