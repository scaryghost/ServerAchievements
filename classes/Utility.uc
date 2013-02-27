/**
 * Provides auxiliary functions for the package
 * @author etsai (Scary Ghost)
 */
class Utility extends Object;

static function addOffset(out string num, string offset) {
    local string sum;
    local int left, right, carry, i, maxLen, partial;

    maxLen= max(len(offset), len(num));
    pad(offset, maxLen);
    pad(num, maxLen);
    for(i= maxLen - 1; i>= 0; i--) {
        left= getIntValue(offset, i);
        right= getIntValue(num, i);
        partial= carry + left + right;
        carry= partial / 10;
        sum= int(partial % 10) $ sum;
    }
    if (carry != 0) {
        sum= carry $ sum;
    }
    num= sum;
}

static function pad(out string num, int size) {
    local int i, padOffset;

    padOffset= size - Len(num);
    for(i= 0; i < padOffset; i++) {
        num= "0" $ num;
    }
}

static function int getIntValue(string num, int index) {
    if (index >= Len(num)) {
        return 0;
    }
    return int(Mid(num, index, 1));
}
