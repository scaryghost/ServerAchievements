/**
 * Creates a TCP link with the remote database to store achievement data on another machine
 * @author etsai (Scary Ghost)
 */
class ServerTcpLink extends TcpLink;

var string separator, bodySeparator, header, protocol, hostname;
var int version, reqId;
var IpAddr serverAddr;
var bool isOpenned;

enum StatusCode {
    OK,
    INVALID_PASSWORD,
    ERROR_SAVING,
    ERROR_RETRIEVING
};

struct PendingResponse {
    var int reqId;
    var string request;
    var AchievementPack achvObj;
};
var array<PendingResponse> pendingResponses;

function sendRequest(string request, string body) {
    if (!isOpenned) {
        BindPort();
        Open(serverAddr);
    }
    pendingResponses.Length= pendingResponses.Length + 1;
    pendingResponses[pendingResponses.Length - 1].reqId= reqId;
    pendingResponses[pendingResponses.Length - 1].request= request;
    
    SendText(header $ separator $ reqId $ separator $ request $ separator $ body);
    reqId++;
}

function PostBeginPlay() {
    LinkMode= MODE_Line;
    ReceiveMode= RMODE_Event;
    BindPort();
    Resolve(class'SAMutator'.default.hostname);
    header= protocol $ "," $ version $ ",request";
}

event Resolved(IpAddr addr) {
    serverAddr= addr;
    serverAddr.port= class'SAMutator'.default.tcpPort;

    if (!Open(serverAddr)) {
        log("Cannot reach remote host"@IpAddrToString(serverAddr));
    }
}

event Opened() {
    isOpenned= true;
    sendRequest("connect", class'SAMutator'.default.serverPassword);
}

event Closed() {
    super.Closed();
    isOpenned= false;
    log("Connection to remote database closed");
}

event ReceivedLine(string Line) {
    local array<string> parts, respHeader;
    local int i, respId;

    log("Response:"@Line);
    Split(Line, separator, parts);
    Split(parts[0], ",", respHeader);

    if (respHeader.Length >= 3 && respHeader[0] == protocol && int(respHeader[1]) == version) {
        if (respHeader[2] == "response") {
            respId= int(parts[1]);
            for(i= 0; i < pendingResponses.Length && pendingResponses[i].reqId != respId; i++) {
            }

            if (i < pendingResponses.Length) {
                switch (int(parts[2])) {
                    case StatusCode.OK:
                        if (pendingResponses[i].request == "retrieve") {
                            pendingResponses[i].achvObj.deserializeUserData(parts[3]);
                        }
                        break;
                    case StatusCode.INVALID_PASSWORD:
                        log("Invalid password!");
                        break;
                    case StatusCode.ERROR_SAVING:
                        log("Error saving achievement data");
                        break;
                    case StatusCode.ERROR_RETRIEVING:
                        log("Error retrieving achievement data");
                        break;
                    default:
                        log("Unrecognized status code="@parts[2]);
                }
            }
            pendingResponses.remove(i, 1);
        }
    }
}

function getAchievementData(string steamid64, AchievementPack achvObj) {
    sendRequest("retrieve", steamid64 $ bodySeparator $ achvObj.getPackName());
    pendingResponses[pendingResponses.Length - 1].achvObj= achvObj;
}

function saveAchievementData(string steamid64, string packName, string data) {
    sendRequest("save", steamid64 $ bodySeparator $ packName $ bodySeparator $ data);
}


defaultproperties {
    separator= "|"
    bodySeparator= "."
    protocol= "server-achievements"
    version= 1
}
