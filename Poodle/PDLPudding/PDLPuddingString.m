//
//  PDLPuddingString.m
//  Poodle
//
//  Created by Poodle on 2021/7/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLPuddingString.h"

#ifdef DEBUG
#define PDLPuddingString_ASSERT(e) assert(e)
#else
#define PDLPuddingString_ASSERT(e)
#endif

__attribute__((visibility("hidden")))
char *PDLPuddingString_ORIGforwardInvocation(void) {
    static bool initialized = false;
    static char s[23];
    if (!initialized) {
        s[0] = 'O';
        s[1] = 'R';
        s[2] = 'I';
        s[3] = 'G';
        s[4] = 'f';
        s[5] = 'o';
        s[6] = 'r';
        s[7] = 'w';
        s[8] = 'a';
        s[9] = 'r';
        s[10] = 'd';
        s[11] = 'I';
        s[12] = 'n';
        s[13] = 'v';
        s[14] = 'o';
        s[15] = 'c';
        s[16] = 'a';
        s[17] = 't';
        s[18] = 'i';
        s[19] = 'o';
        s[20] = 'n';
        s[21] = ':';
        s[22] = '\0';
        initialized = true;
        PDLPuddingString_ASSERT(strcmp(s, "ORIGforwardInvocation:") == 0);
    }
    return s;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_regexStr(void) {
    static NSString *string = nil;
    char s[23];
    if (!string) {
        s[0] = '(';
        s[1] = '?';
        s[2] = '<';
        s[3] = '!';
        s[4] = '\\';
        s[5] = '\\';
        s[6] = ')';
        s[7] = '\\';
        s[8] = '.';
        s[9] = '\\';
        s[10] = 's';
        s[11] = '*';
        s[12] = '(';
        s[13] = '\\';
        s[14] = 'w';
        s[15] = '+';
        s[16] = ')';
        s[17] = '\\';
        s[18] = 's';
        s[19] = '*';
        s[20] = '\\';
        s[21] = '(';
        s[22] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"(?<!\\\\)\\.\\s*(\\w+)\\s*\\("]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_replaceStr(void) {
    static NSString *string = nil;
    char s[12];
    if (!string) {
        s[0] = '.';
        s[1] = '_';
        s[2] = '_';
        s[3] = 'c';
        s[4] = '(';
        s[5] = '\"';
        s[6] = '$';
        s[7] = '1';
        s[8] = '\"';
        s[9] = ')';
        s[10] = '(';
        s[11] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@".__c(\"$1\")("]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_defineClass(void) {
    static NSString *string = nil;
    char s[16];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'd';
        s[5] = 'e';
        s[6] = 'f';
        s[7] = 'i';
        s[8] = 'n';
        s[9] = 'e';
        s[10] = 'C';
        s[11] = 'l';
        s[12] = 'a';
        s[13] = 's';
        s[14] = 's';
        s[15] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_defineClass"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_defineProtocol(void) {
    static NSString *string = nil;
    char s[19];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'd';
        s[5] = 'e';
        s[6] = 'f';
        s[7] = 'i';
        s[8] = 'n';
        s[9] = 'e';
        s[10] = 'P';
        s[11] = 'r';
        s[12] = 'o';
        s[13] = 't';
        s[14] = 'o';
        s[15] = 'c';
        s[16] = 'o';
        s[17] = 'l';
        s[18] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_defineProtocol"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_callI(void) {
    static NSString *string = nil;
    char s[10];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'c';
        s[5] = 'a';
        s[6] = 'l';
        s[7] = 'l';
        s[8] = 'I';
        s[9] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_callI"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_callC(void) {
    static NSString *string = nil;
    char s[10];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'c';
        s[5] = 'a';
        s[6] = 'l';
        s[7] = 'l';
        s[8] = 'C';
        s[9] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_callC"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_formatJSToOC(void) {
    static NSString *string = nil;
    char s[17];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'f';
        s[5] = 'o';
        s[6] = 'r';
        s[7] = 'm';
        s[8] = 'a';
        s[9] = 't';
        s[10] = 'J';
        s[11] = 'S';
        s[12] = 'T';
        s[13] = 'o';
        s[14] = 'O';
        s[15] = 'C';
        s[16] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_formatJSToOC"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_formatOCToJS(void) {
    static NSString *string = nil;
    char s[17];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'f';
        s[5] = 'o';
        s[6] = 'r';
        s[7] = 'm';
        s[8] = 'a';
        s[9] = 't';
        s[10] = 'O';
        s[11] = 'C';
        s[12] = 'T';
        s[13] = 'o';
        s[14] = 'J';
        s[15] = 'S';
        s[16] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_formatOCToJS"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_getCustomProps(void) {
    static NSString *string = nil;
    char s[19];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'g';
        s[5] = 'e';
        s[6] = 't';
        s[7] = 'C';
        s[8] = 'u';
        s[9] = 's';
        s[10] = 't';
        s[11] = 'o';
        s[12] = 'm';
        s[13] = 'P';
        s[14] = 'r';
        s[15] = 'o';
        s[16] = 'p';
        s[17] = 's';
        s[18] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_getCustomProps"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_setCustomProps(void) {
    static NSString *string = nil;
    char s[19];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 's';
        s[5] = 'e';
        s[6] = 't';
        s[7] = 'C';
        s[8] = 'u';
        s[9] = 's';
        s[10] = 't';
        s[11] = 'o';
        s[12] = 'm';
        s[13] = 'P';
        s[14] = 'r';
        s[15] = 'o';
        s[16] = 'p';
        s[17] = 's';
        s[18] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_setCustomProps"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___weak(void) {
    static NSString *string = nil;
    char s[7];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'w';
        s[3] = 'e';
        s[4] = 'a';
        s[5] = 'k';
        s[6] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__weak"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___strong(void) {
    static NSString *string = nil;
    char s[9];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 's';
        s[3] = 't';
        s[4] = 'r';
        s[5] = 'o';
        s[6] = 'n';
        s[7] = 'g';
        s[8] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__strong"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__formatOCToJS(void) {
    static NSString *string = nil;
    char s[14];
    if (!string) {
        s[0] = '_';
        s[1] = 'f';
        s[2] = 'o';
        s[3] = 'r';
        s[4] = 'm';
        s[5] = 'a';
        s[6] = 't';
        s[7] = 'O';
        s[8] = 'C';
        s[9] = 'T';
        s[10] = 'o';
        s[11] = 'J';
        s[12] = 'S';
        s[13] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_formatOCToJS"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_superClsName(void) {
    static NSString *string = nil;
    char s[17];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 's';
        s[5] = 'u';
        s[6] = 'p';
        s[7] = 'e';
        s[8] = 'r';
        s[9] = 'C';
        s[10] = 'l';
        s[11] = 's';
        s[12] = 'N';
        s[13] = 'a';
        s[14] = 'm';
        s[15] = 'e';
        s[16] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_superClsName"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_autoConvertOCType(void) {
    static NSString *string = nil;
    char s[18];
    if (!string) {
        s[0] = 'a';
        s[1] = 'u';
        s[2] = 't';
        s[3] = 'o';
        s[4] = 'C';
        s[5] = 'o';
        s[6] = 'n';
        s[7] = 'v';
        s[8] = 'e';
        s[9] = 'r';
        s[10] = 't';
        s[11] = 'O';
        s[12] = 'C';
        s[13] = 'T';
        s[14] = 'y';
        s[15] = 'p';
        s[16] = 'e';
        s[17] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"autoConvertOCType"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_convertOCNumberToString(void) {
    static NSString *string = nil;
    char s[24];
    if (!string) {
        s[0] = 'c';
        s[1] = 'o';
        s[2] = 'n';
        s[3] = 'v';
        s[4] = 'e';
        s[5] = 'r';
        s[6] = 't';
        s[7] = 'O';
        s[8] = 'C';
        s[9] = 'N';
        s[10] = 'u';
        s[11] = 'm';
        s[12] = 'b';
        s[13] = 'e';
        s[14] = 'r';
        s[15] = 'T';
        s[16] = 'o';
        s[17] = 'S';
        s[18] = 't';
        s[19] = 'r';
        s[20] = 'i';
        s[21] = 'n';
        s[22] = 'g';
        s[23] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"convertOCNumberToString"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_include(void) {
    static NSString *string = nil;
    char s[8];
    if (!string) {
        s[0] = 'i';
        s[1] = 'n';
        s[2] = 'c';
        s[3] = 'l';
        s[4] = 'u';
        s[5] = 'd';
        s[6] = 'e';
        s[7] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"include"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_resourcePath(void) {
    static NSString *string = nil;
    char s[13];
    if (!string) {
        s[0] = 'r';
        s[1] = 'e';
        s[2] = 's';
        s[3] = 'o';
        s[4] = 'u';
        s[5] = 'r';
        s[6] = 'c';
        s[7] = 'e';
        s[8] = 'P';
        s[9] = 'a';
        s[10] = 't';
        s[11] = 'h';
        s[12] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"resourcePath"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_dispatch_after(void) {
    static NSString *string = nil;
    char s[15];
    if (!string) {
        s[0] = 'd';
        s[1] = 'i';
        s[2] = 's';
        s[3] = 'p';
        s[4] = 'a';
        s[5] = 't';
        s[6] = 'c';
        s[7] = 'h';
        s[8] = '_';
        s[9] = 'a';
        s[10] = 'f';
        s[11] = 't';
        s[12] = 'e';
        s[13] = 'r';
        s[14] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"dispatch_after"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_dispatch_async_main(void) {
    static NSString *string = nil;
    char s[20];
    if (!string) {
        s[0] = 'd';
        s[1] = 'i';
        s[2] = 's';
        s[3] = 'p';
        s[4] = 'a';
        s[5] = 't';
        s[6] = 'c';
        s[7] = 'h';
        s[8] = '_';
        s[9] = 'a';
        s[10] = 's';
        s[11] = 'y';
        s[12] = 'n';
        s[13] = 'c';
        s[14] = '_';
        s[15] = 'm';
        s[16] = 'a';
        s[17] = 'i';
        s[18] = 'n';
        s[19] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"dispatch_async_main"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_dispatch_sync_main(void) {
    static NSString *string = nil;
    char s[19];
    if (!string) {
        s[0] = 'd';
        s[1] = 'i';
        s[2] = 's';
        s[3] = 'p';
        s[4] = 'a';
        s[5] = 't';
        s[6] = 'c';
        s[7] = 'h';
        s[8] = '_';
        s[9] = 's';
        s[10] = 'y';
        s[11] = 'n';
        s[12] = 'c';
        s[13] = '_';
        s[14] = 'm';
        s[15] = 'a';
        s[16] = 'i';
        s[17] = 'n';
        s[18] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"dispatch_sync_main"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_dispatch_async_global_queue(void) {
    static NSString *string = nil;
    char s[28];
    if (!string) {
        s[0] = 'd';
        s[1] = 'i';
        s[2] = 's';
        s[3] = 'p';
        s[4] = 'a';
        s[5] = 't';
        s[6] = 'c';
        s[7] = 'h';
        s[8] = '_';
        s[9] = 'a';
        s[10] = 's';
        s[11] = 'y';
        s[12] = 'n';
        s[13] = 'c';
        s[14] = '_';
        s[15] = 'g';
        s[16] = 'l';
        s[17] = 'o';
        s[18] = 'b';
        s[19] = 'a';
        s[20] = 'l';
        s[21] = '_';
        s[22] = 'q';
        s[23] = 'u';
        s[24] = 'e';
        s[25] = 'u';
        s[26] = 'e';
        s[27] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"dispatch_async_global_queue"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_releaseTmpObj(void) {
    static NSString *string = nil;
    char s[14];
    if (!string) {
        s[0] = 'r';
        s[1] = 'e';
        s[2] = 'l';
        s[3] = 'e';
        s[4] = 'a';
        s[5] = 's';
        s[6] = 'e';
        s[7] = 'T';
        s[8] = 'm';
        s[9] = 'p';
        s[10] = 'O';
        s[11] = 'b';
        s[12] = 'j';
        s[13] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"releaseTmpObj"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_log(void) {
    static NSString *string = nil;
    char s[8];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'l';
        s[5] = 'o';
        s[6] = 'g';
        s[7] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_log"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_catch(void) {
    static NSString *string = nil;
    char s[10];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'c';
        s[5] = 'a';
        s[6] = 't';
        s[7] = 'c';
        s[8] = 'h';
        s[9] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_catch"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString__OC_null(void) {
    static NSString *string = nil;
    char s[9];
    if (!string) {
        s[0] = '_';
        s[1] = 'O';
        s[2] = 'C';
        s[3] = '_';
        s[4] = 'n';
        s[5] = 'u';
        s[6] = 'l';
        s[7] = 'l';
        s[8] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"_OC_null"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_main_js(void) {
    static NSString *string = nil;
    char s[8];
    if (!string) {
        s[0] = 'm';
        s[1] = 'a';
        s[2] = 'i';
        s[3] = 'n';
        s[4] = '.';
        s[5] = 'j';
        s[6] = 's';
        s[7] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"main.js"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___realClsName(void) {
    static NSString *string = nil;
    char s[14];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'r';
        s[3] = 'e';
        s[4] = 'a';
        s[5] = 'l';
        s[6] = 'C';
        s[7] = 'l';
        s[8] = 's';
        s[9] = 'N';
        s[10] = 'a';
        s[11] = 'm';
        s[12] = 'e';
        s[13] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__realClsName"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___obj(void) {
    static NSString *string = nil;
    char s[6];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'o';
        s[3] = 'b';
        s[4] = 'j';
        s[5] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__obj"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___isNil(void) {
    static NSString *string = nil;
    char s[8];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'i';
        s[3] = 's';
        s[4] = 'N';
        s[5] = 'i';
        s[6] = 'l';
        s[7] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__isNil"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___isBlock(void) {
    static NSString *string = nil;
    char s[10];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'i';
        s[3] = 's';
        s[4] = 'B';
        s[5] = 'l';
        s[6] = 'o';
        s[7] = 'c';
        s[8] = 'k';
        s[9] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__isBlock"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_blockObj(void) {
    static NSString *string = nil;
    char s[9];
    if (!string) {
        s[0] = 'b';
        s[1] = 'l';
        s[2] = 'o';
        s[3] = 'c';
        s[4] = 'k';
        s[5] = 'O';
        s[6] = 'b';
        s[7] = 'j';
        s[8] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"blockObj"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___clsName(void) {
    static NSString *string = nil;
    char s[10];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'c';
        s[3] = 'l';
        s[4] = 's';
        s[5] = 'N';
        s[6] = 'a';
        s[7] = 'm';
        s[8] = 'e';
        s[9] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__clsName"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_formatedScript(void) {
    static NSString *string = nil;
    char s[67];
    if (!string) {
        s[0] = ';';
        s[1] = '(';
        s[2] = 'f';
        s[3] = 'u';
        s[4] = 'n';
        s[5] = 'c';
        s[6] = 't';
        s[7] = 'i';
        s[8] = 'o';
        s[9] = 'n';
        s[10] = '(';
        s[11] = ')';
        s[12] = '{';
        s[13] = 't';
        s[14] = 'r';
        s[15] = 'y';
        s[16] = '{';
        s[17] = '\n';
        s[18] = '%';
        s[19] = '@';
        s[20] = '\n';
        s[21] = '}';
        s[22] = 'c';
        s[23] = 'a';
        s[24] = 't';
        s[25] = 'c';
        s[26] = 'h';
        s[27] = '(';
        s[28] = 'e';
        s[29] = ')';
        s[30] = '{';
        s[31] = '_';
        s[32] = 'O';
        s[33] = 'C';
        s[34] = '_';
        s[35] = 'c';
        s[36] = 'a';
        s[37] = 't';
        s[38] = 'c';
        s[39] = 'h';
        s[40] = '(';
        s[41] = 'e';
        s[42] = '.';
        s[43] = 'm';
        s[44] = 'e';
        s[45] = 's';
        s[46] = 's';
        s[47] = 'a';
        s[48] = 'g';
        s[49] = 'e';
        s[50] = ',';
        s[51] = ' ';
        s[52] = 'e';
        s[53] = '.';
        s[54] = 's';
        s[55] = 't';
        s[56] = 'a';
        s[57] = 'c';
        s[58] = 'k';
        s[59] = ')';
        s[60] = '}';
        s[61] = '}';
        s[62] = ')';
        s[63] = '(';
        s[64] = ')';
        s[65] = ';';
        s[66] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@";(function(){try{\n%@\n}catch(e){_OC_catch(e.message, e.stack)}})();"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_cls(void) {
    static NSString *string = nil;
    char s[4];
    if (!string) {
        s[0] = 'c';
        s[1] = 'l';
        s[2] = 's';
        s[3] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"cls"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_superCls(void) {
    static NSString *string = nil;
    char s[9];
    if (!string) {
        s[0] = 's';
        s[1] = 'u';
        s[2] = 'p';
        s[3] = 'e';
        s[4] = 'r';
        s[5] = 'C';
        s[6] = 'l';
        s[7] = 's';
        s[8] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"superCls"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_paramsType(void) {
    static NSString *string = nil;
    char s[11];
    if (!string) {
        s[0] = 'p';
        s[1] = 'a';
        s[2] = 'r';
        s[3] = 'a';
        s[4] = 'm';
        s[5] = 's';
        s[6] = 'T';
        s[7] = 'y';
        s[8] = 'p';
        s[9] = 'e';
        s[10] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"paramsType"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_returnType(void) {
    static NSString *string = nil;
    char s[11];
    if (!string) {
        s[0] = 'r';
        s[1] = 'e';
        s[2] = 't';
        s[3] = 'u';
        s[4] = 'r';
        s[5] = 'n';
        s[6] = 'T';
        s[7] = 'y';
        s[8] = 'p';
        s[9] = 'e';
        s[10] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"returnType"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_typeEncode(void) {
    static NSString *string = nil;
    char s[11];
    if (!string) {
        s[0] = 't';
        s[1] = 'y';
        s[2] = 'p';
        s[3] = 'e';
        s[4] = 'E';
        s[5] = 'n';
        s[6] = 'c';
        s[7] = 'o';
        s[8] = 'd';
        s[9] = 'e';
        s[10] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"typeEncode"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_void(void) {
    static NSString *string = nil;
    char s[5];
    if (!string) {
        s[0] = 'v';
        s[1] = 'o';
        s[2] = 'i';
        s[3] = 'd';
        s[4] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"void"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_block(void) {
    static NSString *string = nil;
    char s[6];
    if (!string) {
        s[0] = 'b';
        s[1] = 'l';
        s[2] = 'o';
        s[3] = 'c';
        s[4] = 'k';
        s[5] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"block"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString___isPerformInOC(void) {
    static NSString *string = nil;
    char s[16];
    if (!string) {
        s[0] = '_';
        s[1] = '_';
        s[2] = 'i';
        s[3] = 's';
        s[4] = 'P';
        s[5] = 'e';
        s[6] = 'r';
        s[7] = 'f';
        s[8] = 'o';
        s[9] = 'r';
        s[10] = 'm';
        s[11] = 'I';
        s[12] = 'n';
        s[13] = 'O';
        s[14] = 'C';
        s[15] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"__isPerformInOC"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_clsName(void) {
    static NSString *string = nil;
    char s[8];
    if (!string) {
        s[0] = 'c';
        s[1] = 'l';
        s[2] = 's';
        s[3] = 'N';
        s[4] = 'a';
        s[5] = 'm';
        s[6] = 'e';
        s[7] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"clsName"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_ORIGdealloc(void) {
    static NSString *string = nil;
    char s[12];
    if (!string) {
        s[0] = 'O';
        s[1] = 'R';
        s[2] = 'I';
        s[3] = 'G';
        s[4] = 'd';
        s[5] = 'e';
        s[6] = 'a';
        s[7] = 'l';
        s[8] = 'l';
        s[9] = 'o';
        s[10] = 'c';
        s[11] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"ORIGdealloc"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_ORIGAT(void) {
    static NSString *string = nil;
    char s[7];
    if (!string) {
        s[0] = 'O';
        s[1] = 'R';
        s[2] = 'I';
        s[3] = 'G';
        s[4] = '%';
        s[5] = '@';
        s[6] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"ORIG%@"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_toJS(void) {
    static NSString *string = nil;
    char s[5];
    if (!string) {
        s[0] = 't';
        s[1] = 'o';
        s[2] = 'J';
        s[3] = 'S';
        s[4] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"toJS"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_SUPER_AT(void) {
    static NSString *string = nil;
    char s[9];
    if (!string) {
        s[0] = 'S';
        s[1] = 'U';
        s[2] = 'P';
        s[3] = 'E';
        s[4] = 'R';
        s[5] = '_';
        s[6] = '%';
        s[7] = '@';
        s[8] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"SUPER_%@"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_SUPER_(void) {
    static NSString *string = nil;
    char s[7];
    if (!string) {
        s[0] = 'S';
        s[1] = 'U';
        s[2] = 'P';
        s[3] = 'E';
        s[4] = 'R';
        s[5] = '_';
        s[6] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"SUPER_"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_ORIG(void) {
    static NSString *string = nil;
    char s[5];
    if (!string) {
        s[0] = 'O';
        s[1] = 'R';
        s[2] = 'I';
        s[3] = 'G';
        s[4] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"ORIG"]);
    }
    return string;
}

__attribute__((visibility("hidden")))
NSString *PDLPuddingString_NSBlock(void) {
    static NSString *string = nil;
    char s[8];
    if (!string) {
        s[0] = 'N';
        s[1] = 'S';
        s[2] = 'B';
        s[3] = 'l';
        s[4] = 'o';
        s[5] = 'c';
        s[6] = 'k';
        s[7] = '\0';
        string = @(s);
        PDLPuddingString_ASSERT([string isEqualToString:@"NSBlock"]);
    }
    return string;
}



// JSPatch.js
__attribute__((visibility("hidden")))
NSString *const PDLPuddingStringCore = @"dmFyIGdsb2JhbCA9IHRoaXMKCjsoZnVuY3Rpb24oKSB7CgogIHZhciBfb2NDbHMgPSB7fTsKICB2YXIgX2pzQ2xzID0ge307CgogIHZhciBfZm9ybWF0T0NUb0pTID0gZnVuY3Rpb24ob2JqKSB7CiAgICBpZiAob2JqID09PSB1bmRlZmluZWQgfHwgb2JqID09PSBudWxsKSByZXR1cm4gZmFsc2UKICAgIGlmICh0eXBlb2Ygb2JqID09ICJvYmplY3QiKSB7CiAgICAgIGlmIChvYmouX19vYmopIHJldHVybiBvYmoKICAgICAgaWYgKG9iai5fX2lzTmlsKSByZXR1cm4gZmFsc2UKICAgIH0KICAgIGlmIChvYmogaW5zdGFuY2VvZiBBcnJheSkgewogICAgICB2YXIgcmV0ID0gW10KICAgICAgb2JqLmZvckVhY2goZnVuY3Rpb24obykgewogICAgICAgIHJldC5wdXNoKF9mb3JtYXRPQ1RvSlMobykpCiAgICAgIH0pCiAgICAgIHJldHVybiByZXQKICAgIH0KICAgIGlmIChvYmogaW5zdGFuY2VvZiBGdW5jdGlvbikgewogICAgICAgIHJldHVybiBmdW5jdGlvbigpIHsKICAgICAgICAgICAgdmFyIGFyZ3MgPSBBcnJheS5wcm90b3R5cGUuc2xpY2UuY2FsbChhcmd1bWVudHMpCiAgICAgICAgICAgIHZhciBmb3JtYXRlZEFyZ3MgPSBfT0NfZm9ybWF0SlNUb09DKGFyZ3MpCiAgICAgICAgICAgIGZvciAodmFyIGkgPSAwOyBpIDwgYXJncy5sZW5ndGg7IGkrKykgewogICAgICAgICAgICAgICAgaWYgKGFyZ3NbaV0gPT09IG51bGwgfHwgYXJnc1tpXSA9PT0gdW5kZWZpbmVkIHx8IGFyZ3NbaV0gPT09IGZhbHNlKSB7CiAgICAgICAgICAgICAgICBmb3JtYXRlZEFyZ3Muc3BsaWNlKGksIDEsIHVuZGVmaW5lZCkKICAgICAgICAgICAgfSBlbHNlIGlmIChhcmdzW2ldID09IG5zbnVsbCkgewogICAgICAgICAgICAgICAgZm9ybWF0ZWRBcmdzLnNwbGljZShpLCAxLCBudWxsKQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgICAgIHJldHVybiBfT0NfZm9ybWF0T0NUb0pTKG9iai5hcHBseShvYmosIGZvcm1hdGVkQXJncykpCiAgICAgIH0KICAgIH0KICAgIGlmIChvYmogaW5zdGFuY2VvZiBPYmplY3QpIHsKICAgICAgdmFyIHJldCA9IHt9CiAgICAgIGZvciAodmFyIGtleSBpbiBvYmopIHsKICAgICAgICByZXRba2V5XSA9IF9mb3JtYXRPQ1RvSlMob2JqW2tleV0pCiAgICAgIH0KICAgICAgcmV0dXJuIHJldAogICAgfQogICAgcmV0dXJuIG9iagogIH0KICAKICB2YXIgX21ldGhvZEZ1bmMgPSBmdW5jdGlvbihpbnN0YW5jZSwgY2xzTmFtZSwgbWV0aG9kTmFtZSwgYXJncywgaXNTdXBlciwgaXNQZXJmb3JtU2VsZWN0b3IpIHsKICAgIHZhciBzZWxlY3Rvck5hbWUgPSBtZXRob2ROYW1lCiAgICBpZiAoIWlzUGVyZm9ybVNlbGVjdG9yKSB7CiAgICAgIG1ldGhvZE5hbWUgPSBtZXRob2ROYW1lLnJlcGxhY2UoL19fL2csICItIikKICAgICAgc2VsZWN0b3JOYW1lID0gbWV0aG9kTmFtZS5yZXBsYWNlKC9fL2csICI6IikucmVwbGFjZSgvLS9nLCAiXyIpCiAgICAgIHZhciBtYXJjaEFyciA9IHNlbGVjdG9yTmFtZS5tYXRjaCgvOi9nKQogICAgICB2YXIgbnVtT2ZBcmdzID0gbWFyY2hBcnIgPyBtYXJjaEFyci5sZW5ndGggOiAwCiAgICAgIGlmIChhcmdzLmxlbmd0aCA+IG51bU9mQXJncykgewogICAgICAgIHNlbGVjdG9yTmFtZSArPSAiOiIKICAgICAgfQogICAgfQogICAgdmFyIHJldCA9IGluc3RhbmNlID8gX09DX2NhbGxJKGluc3RhbmNlLCBzZWxlY3Rvck5hbWUsIGFyZ3MsIGlzU3VwZXIpOgogICAgICAgICAgICAgICAgICAgICAgICAgX09DX2NhbGxDKGNsc05hbWUsIHNlbGVjdG9yTmFtZSwgYXJncykKICAgIHJldHVybiBfZm9ybWF0T0NUb0pTKHJldCkKICB9CgogIHZhciBfY3VzdG9tTWV0aG9kcyA9IHsKICAgIF9fYzogZnVuY3Rpb24obWV0aG9kTmFtZSkgewogICAgICB2YXIgc2xmID0gdGhpcwoKICAgICAgaWYgKHNsZiBpbnN0YW5jZW9mIEJvb2xlYW4pIHsKICAgICAgICByZXR1cm4gZnVuY3Rpb24oKSB7CiAgICAgICAgICByZXR1cm4gZmFsc2UKICAgICAgICB9CiAgICAgIH0KICAgICAgaWYgKHNsZlttZXRob2ROYW1lXSkgewogICAgICAgIHJldHVybiBzbGZbbWV0aG9kTmFtZV0uYmluZChzbGYpOwogICAgICB9CgogICAgICBpZiAoIXNsZi5fX29iaiAmJiAhc2xmLl9fY2xzTmFtZSkgewogICAgICAgIHRocm93IG5ldyBFcnJvcihzbGYgKyAnLicgKyBtZXRob2ROYW1lICsgJyBpcyB1bmRlZmluZWQnKQogICAgICB9CiAgICAgIGlmIChzbGYuX19pc1N1cGVyICYmIHNsZi5fX2Nsc05hbWUpIHsKICAgICAgICAgIHNsZi5fX2Nsc05hbWUgPSBfT0Nfc3VwZXJDbHNOYW1lKHNsZi5fX29iai5fX3JlYWxDbHNOYW1lID8gc2xmLl9fb2JqLl9fcmVhbENsc05hbWU6IHNsZi5fX2Nsc05hbWUpOwogICAgICB9CiAgICAgIHZhciBjbHNOYW1lID0gc2xmLl9fY2xzTmFtZQogICAgICBpZiAoY2xzTmFtZSAmJiBfb2NDbHNbY2xzTmFtZV0pIHsKICAgICAgICB2YXIgbWV0aG9kVHlwZSA9IHNsZi5fX29iaiA/ICdpbnN0TWV0aG9kcyc6ICdjbHNNZXRob2RzJwogICAgICAgIGlmIChfb2NDbHNbY2xzTmFtZV1bbWV0aG9kVHlwZV1bbWV0aG9kTmFtZV0pIHsKICAgICAgICAgIHNsZi5fX2lzU3VwZXIgPSAwOwogICAgICAgICAgcmV0dXJuIF9vY0Nsc1tjbHNOYW1lXVttZXRob2RUeXBlXVttZXRob2ROYW1lXS5iaW5kKHNsZikKICAgICAgICB9CiAgICAgIH0KCiAgICAgIHJldHVybiBmdW5jdGlvbigpewogICAgICAgIHZhciBhcmdzID0gQXJyYXkucHJvdG90eXBlLnNsaWNlLmNhbGwoYXJndW1lbnRzKQogICAgICAgIHJldHVybiBfbWV0aG9kRnVuYyhzbGYuX19vYmosIHNsZi5fX2Nsc05hbWUsIG1ldGhvZE5hbWUsIGFyZ3MsIHNsZi5fX2lzU3VwZXIpCiAgICAgIH0KICAgIH0sCgogICAgc3VwZXI6IGZ1bmN0aW9uKCkgewogICAgICB2YXIgc2xmID0gdGhpcwogICAgICBpZiAoc2xmLl9fb2JqKSB7CiAgICAgICAgc2xmLl9fb2JqLl9fcmVhbENsc05hbWUgPSBzbGYuX19yZWFsQ2xzTmFtZTsKICAgICAgfQogICAgICByZXR1cm4ge19fb2JqOiBzbGYuX19vYmosIF9fY2xzTmFtZTogc2xmLl9fY2xzTmFtZSwgX19pc1N1cGVyOiAxfQogICAgfSwKCiAgICBwZXJmb3JtU2VsZWN0b3JJbk9DOiBmdW5jdGlvbigpIHsKICAgICAgdmFyIHNsZiA9IHRoaXMKICAgICAgdmFyIGFyZ3MgPSBBcnJheS5wcm90b3R5cGUuc2xpY2UuY2FsbChhcmd1bWVudHMpCiAgICAgIHJldHVybiB7X19pc1BlcmZvcm1Jbk9DOjEsIG9iajpzbGYuX19vYmosIGNsc05hbWU6c2xmLl9fY2xzTmFtZSwgc2VsOiBhcmdzWzBdLCBhcmdzOiBhcmdzWzFdLCBjYjogYXJnc1syXX0KICAgIH0sCgogICAgcGVyZm9ybVNlbGVjdG9yOiBmdW5jdGlvbigpIHsKICAgICAgdmFyIHNsZiA9IHRoaXMKICAgICAgdmFyIGFyZ3MgPSBBcnJheS5wcm90b3R5cGUuc2xpY2UuY2FsbChhcmd1bWVudHMpCiAgICAgIHJldHVybiBfbWV0aG9kRnVuYyhzbGYuX19vYmosIHNsZi5fX2Nsc05hbWUsIGFyZ3NbMF0sIGFyZ3Muc3BsaWNlKDEpLCBzbGYuX19pc1N1cGVyLCB0cnVlKQogICAgfQogIH0KCiAgZm9yICh2YXIgbWV0aG9kIGluIF9jdXN0b21NZXRob2RzKSB7CiAgICBpZiAoX2N1c3RvbU1ldGhvZHMuaGFzT3duUHJvcGVydHkobWV0aG9kKSkgewogICAgICBPYmplY3QuZGVmaW5lUHJvcGVydHkoT2JqZWN0LnByb3RvdHlwZSwgbWV0aG9kLCB7dmFsdWU6IF9jdXN0b21NZXRob2RzW21ldGhvZF0sIGNvbmZpZ3VyYWJsZTpmYWxzZSwgZW51bWVyYWJsZTogZmFsc2V9KQogICAgfQogIH0KCiAgdmFyIF9yZXF1aXJlID0gZnVuY3Rpb24oY2xzTmFtZSkgewogICAgaWYgKCFnbG9iYWxbY2xzTmFtZV0pIHsKICAgICAgZ2xvYmFsW2Nsc05hbWVdID0gewogICAgICAgIF9fY2xzTmFtZTogY2xzTmFtZQogICAgICB9CiAgICB9IAogICAgcmV0dXJuIGdsb2JhbFtjbHNOYW1lXQogIH0KCiAgZ2xvYmFsLnJlcXVpcmUgPSBmdW5jdGlvbigpIHsKICAgIHZhciBsYXN0UmVxdWlyZQogICAgZm9yICh2YXIgaSA9IDA7IGkgPCBhcmd1bWVudHMubGVuZ3RoOyBpICsrKSB7CiAgICAgIGFyZ3VtZW50c1tpXS5zcGxpdCgnLCcpLmZvckVhY2goZnVuY3Rpb24oY2xzTmFtZSkgewogICAgICAgIGxhc3RSZXF1aXJlID0gX3JlcXVpcmUoY2xzTmFtZS50cmltKCkpCiAgICAgIH0pCiAgICB9CiAgICByZXR1cm4gbGFzdFJlcXVpcmUKICB9CgogIHZhciBfZm9ybWF0RGVmaW5lTWV0aG9kcyA9IGZ1bmN0aW9uKG1ldGhvZHMsIG5ld01ldGhvZHMsIHJlYWxDbHNOYW1lKSB7CiAgICBmb3IgKHZhciBtZXRob2ROYW1lIGluIG1ldGhvZHMpIHsKICAgICAgaWYgKCEobWV0aG9kc1ttZXRob2ROYW1lXSBpbnN0YW5jZW9mIEZ1bmN0aW9uKSkgcmV0dXJuOwogICAgICAoZnVuY3Rpb24oKXsKICAgICAgICB2YXIgb3JpZ2luTWV0aG9kID0gbWV0aG9kc1ttZXRob2ROYW1lXQogICAgICAgIG5ld01ldGhvZHNbbWV0aG9kTmFtZV0gPSBbb3JpZ2luTWV0aG9kLmxlbmd0aCwgZnVuY3Rpb24oKSB7CiAgICAgICAgICB0cnkgewogICAgICAgICAgICB2YXIgYXJncyA9IF9mb3JtYXRPQ1RvSlMoQXJyYXkucHJvdG90eXBlLnNsaWNlLmNhbGwoYXJndW1lbnRzKSkKICAgICAgICAgICAgdmFyIGxhc3RTZWxmID0gZ2xvYmFsLnNlbGYKICAgICAgICAgICAgZ2xvYmFsLnNlbGYgPSBhcmdzWzBdCiAgICAgICAgICAgIGlmIChnbG9iYWwuc2VsZikgZ2xvYmFsLnNlbGYuX19yZWFsQ2xzTmFtZSA9IHJlYWxDbHNOYW1lCiAgICAgICAgICAgIGFyZ3Muc3BsaWNlKDAsMSkKICAgICAgICAgICAgdmFyIHJldCA9IG9yaWdpbk1ldGhvZC5hcHBseShvcmlnaW5NZXRob2QsIGFyZ3MpCiAgICAgICAgICAgIGdsb2JhbC5zZWxmID0gbGFzdFNlbGYKICAgICAgICAgICAgcmV0dXJuIHJldAogICAgICAgICAgfSBjYXRjaChlKSB7CiAgICAgICAgICAgIF9PQ19jYXRjaChlLm1lc3NhZ2UsIGUuc3RhY2spCiAgICAgICAgICB9CiAgICAgICAgfV0KICAgICAgfSkoKQogICAgfQogIH0KCiAgdmFyIF93cmFwTG9jYWxNZXRob2QgPSBmdW5jdGlvbihtZXRob2ROYW1lLCBmdW5jLCByZWFsQ2xzTmFtZSkgewogICAgcmV0dXJuIGZ1bmN0aW9uKCkgewogICAgICB2YXIgbGFzdFNlbGYgPSBnbG9iYWwuc2VsZgogICAgICBnbG9iYWwuc2VsZiA9IHRoaXMKICAgICAgdGhpcy5fX3JlYWxDbHNOYW1lID0gcmVhbENsc05hbWUKICAgICAgdmFyIHJldCA9IGZ1bmMuYXBwbHkodGhpcywgYXJndW1lbnRzKQogICAgICBnbG9iYWwuc2VsZiA9IGxhc3RTZWxmCiAgICAgIHJldHVybiByZXQKICAgIH0KICB9CgogIHZhciBfc2V0dXBKU01ldGhvZCA9IGZ1bmN0aW9uKGNsYXNzTmFtZSwgbWV0aG9kcywgaXNJbnN0LCByZWFsQ2xzTmFtZSkgewogICAgZm9yICh2YXIgbmFtZSBpbiBtZXRob2RzKSB7CiAgICAgIHZhciBrZXkgPSBpc0luc3QgPyAnaW5zdE1ldGhvZHMnOiAnY2xzTWV0aG9kcycsCiAgICAgICAgICBmdW5jID0gbWV0aG9kc1tuYW1lXQogICAgICBfb2NDbHNbY2xhc3NOYW1lXVtrZXldW25hbWVdID0gX3dyYXBMb2NhbE1ldGhvZChuYW1lLCBmdW5jLCByZWFsQ2xzTmFtZSkKICAgIH0KICB9CgogIHZhciBfcHJvcGVydGllc0dldEZ1biA9IGZ1bmN0aW9uKG5hbWUpewogICAgcmV0dXJuIGZ1bmN0aW9uKCl7CiAgICAgIHZhciBzbGYgPSB0aGlzOwogICAgICBpZiAoIXNsZi5fX29jUHJvcHMpIHsKICAgICAgICB2YXIgcHJvcHMgPSBfT0NfZ2V0Q3VzdG9tUHJvcHMoc2xmLl9fb2JqKQogICAgICAgIGlmICghcHJvcHMpIHsKICAgICAgICAgIHByb3BzID0ge30KICAgICAgICAgIF9PQ19zZXRDdXN0b21Qcm9wcyhzbGYuX19vYmosIHByb3BzKQogICAgICAgIH0KICAgICAgICBzbGYuX19vY1Byb3BzID0gcHJvcHM7CiAgICAgIH0KICAgICAgcmV0dXJuIHNsZi5fX29jUHJvcHNbbmFtZV07CiAgICB9OwogIH0KCiAgdmFyIF9wcm9wZXJ0aWVzU2V0RnVuID0gZnVuY3Rpb24obmFtZSl7CiAgICByZXR1cm4gZnVuY3Rpb24oanZhbCl7CiAgICAgIHZhciBzbGYgPSB0aGlzOwogICAgICBpZiAoIXNsZi5fX29jUHJvcHMpIHsKICAgICAgICB2YXIgcHJvcHMgPSBfT0NfZ2V0Q3VzdG9tUHJvcHMoc2xmLl9fb2JqKQogICAgICAgIGlmICghcHJvcHMpIHsKICAgICAgICAgIHByb3BzID0ge30KICAgICAgICAgIF9PQ19zZXRDdXN0b21Qcm9wcyhzbGYuX19vYmosIHByb3BzKQogICAgICAgIH0KICAgICAgICBzbGYuX19vY1Byb3BzID0gcHJvcHM7CiAgICAgIH0KICAgICAgc2xmLl9fb2NQcm9wc1tuYW1lXSA9IGp2YWw7CiAgICB9OwogIH0KCiAgZ2xvYmFsLmRlZmluZUNsYXNzID0gZnVuY3Rpb24oZGVjbGFyYXRpb24sIHByb3BlcnRpZXMsIGluc3RNZXRob2RzLCBjbHNNZXRob2RzKSB7CiAgICB2YXIgbmV3SW5zdE1ldGhvZHMgPSB7fSwgbmV3Q2xzTWV0aG9kcyA9IHt9CiAgICBpZiAoIShwcm9wZXJ0aWVzIGluc3RhbmNlb2YgQXJyYXkpKSB7CiAgICAgIGNsc01ldGhvZHMgPSBpbnN0TWV0aG9kcwogICAgICBpbnN0TWV0aG9kcyA9IHByb3BlcnRpZXMKICAgICAgcHJvcGVydGllcyA9IG51bGwKICAgIH0KCiAgICBpZiAocHJvcGVydGllcykgewogICAgICBwcm9wZXJ0aWVzLmZvckVhY2goZnVuY3Rpb24obmFtZSl7CiAgICAgICAgaWYgKCFpbnN0TWV0aG9kc1tuYW1lXSkgewogICAgICAgICAgaW5zdE1ldGhvZHNbbmFtZV0gPSBfcHJvcGVydGllc0dldEZ1bihuYW1lKTsKICAgICAgICB9CiAgICAgICAgdmFyIG5hbWVPZlNldCA9ICJzZXQiKyBuYW1lLnN1YnN0cigwLDEpLnRvVXBwZXJDYXNlKCkgKyBuYW1lLnN1YnN0cigxKTsKICAgICAgICBpZiAoIWluc3RNZXRob2RzW25hbWVPZlNldF0pIHsKICAgICAgICAgIGluc3RNZXRob2RzW25hbWVPZlNldF0gPSBfcHJvcGVydGllc1NldEZ1bihuYW1lKTsKICAgICAgICB9CiAgICAgIH0pOwogICAgfQoKICAgIHZhciByZWFsQ2xzTmFtZSA9IGRlY2xhcmF0aW9uLnNwbGl0KCc6JylbMF0udHJpbSgpCgogICAgX2Zvcm1hdERlZmluZU1ldGhvZHMoaW5zdE1ldGhvZHMsIG5ld0luc3RNZXRob2RzLCByZWFsQ2xzTmFtZSkKICAgIF9mb3JtYXREZWZpbmVNZXRob2RzKGNsc01ldGhvZHMsIG5ld0Nsc01ldGhvZHMsIHJlYWxDbHNOYW1lKQoKICAgIHZhciByZXQgPSBfT0NfZGVmaW5lQ2xhc3MoZGVjbGFyYXRpb24sIG5ld0luc3RNZXRob2RzLCBuZXdDbHNNZXRob2RzKQogICAgdmFyIGNsYXNzTmFtZSA9IHJldFsnY2xzJ10KICAgIHZhciBzdXBlckNscyA9IHJldFsnc3VwZXJDbHMnXQoKICAgIF9vY0Nsc1tjbGFzc05hbWVdID0gewogICAgICBpbnN0TWV0aG9kczoge30sCiAgICAgIGNsc01ldGhvZHM6IHt9LAogICAgfQoKICAgIGlmIChzdXBlckNscy5sZW5ndGggJiYgX29jQ2xzW3N1cGVyQ2xzXSkgewogICAgICBmb3IgKHZhciBmdW5jTmFtZSBpbiBfb2NDbHNbc3VwZXJDbHNdWydpbnN0TWV0aG9kcyddKSB7CiAgICAgICAgX29jQ2xzW2NsYXNzTmFtZV1bJ2luc3RNZXRob2RzJ11bZnVuY05hbWVdID0gX29jQ2xzW3N1cGVyQ2xzXVsnaW5zdE1ldGhvZHMnXVtmdW5jTmFtZV0KICAgICAgfQogICAgICBmb3IgKHZhciBmdW5jTmFtZSBpbiBfb2NDbHNbc3VwZXJDbHNdWydjbHNNZXRob2RzJ10pIHsKICAgICAgICBfb2NDbHNbY2xhc3NOYW1lXVsnY2xzTWV0aG9kcyddW2Z1bmNOYW1lXSA9IF9vY0Nsc1tzdXBlckNsc11bJ2Nsc01ldGhvZHMnXVtmdW5jTmFtZV0KICAgICAgfQogICAgfQoKICAgIF9zZXR1cEpTTWV0aG9kKGNsYXNzTmFtZSwgaW5zdE1ldGhvZHMsIDEsIHJlYWxDbHNOYW1lKQogICAgX3NldHVwSlNNZXRob2QoY2xhc3NOYW1lLCBjbHNNZXRob2RzLCAwLCByZWFsQ2xzTmFtZSkKCiAgICByZXR1cm4gcmVxdWlyZShjbGFzc05hbWUpCiAgfQoKICBnbG9iYWwuZGVmaW5lUHJvdG9jb2wgPSBmdW5jdGlvbihkZWNsYXJhdGlvbiwgaW5zdFByb3RvcyAsIGNsc1Byb3RvcykgewogICAgICB2YXIgcmV0ID0gX09DX2RlZmluZVByb3RvY29sKGRlY2xhcmF0aW9uLCBpbnN0UHJvdG9zLGNsc1Byb3Rvcyk7CiAgICAgIHJldHVybiByZXQKICB9CgogIGdsb2JhbC5ibG9jayA9IGZ1bmN0aW9uKGFyZ3MsIGNiKSB7CiAgICB2YXIgdGhhdCA9IHRoaXMKICAgIHZhciBzbGYgPSBnbG9iYWwuc2VsZgogICAgaWYgKGFyZ3MgaW5zdGFuY2VvZiBGdW5jdGlvbikgewogICAgICBjYiA9IGFyZ3MKICAgICAgYXJncyA9ICcnCiAgICB9CiAgICB2YXIgY2FsbGJhY2sgPSBmdW5jdGlvbigpIHsKICAgICAgdmFyIGFyZ3MgPSBBcnJheS5wcm90b3R5cGUuc2xpY2UuY2FsbChhcmd1bWVudHMpCiAgICAgIGdsb2JhbC5zZWxmID0gc2xmCiAgICAgIHJldHVybiBjYi5hcHBseSh0aGF0LCBfZm9ybWF0T0NUb0pTKGFyZ3MpKQogICAgfQogICAgdmFyIHJldCA9IHthcmdzOiBhcmdzLCBjYjogY2FsbGJhY2ssIGFyZ0NvdW50OiBjYi5sZW5ndGgsIF9faXNCbG9jazogMX0KICAgIGlmIChnbG9iYWwuX19nZW5CbG9jaykgewogICAgICByZXRbJ2Jsb2NrT2JqJ10gPSBnbG9iYWwuX19nZW5CbG9jayhhcmdzLCBjYikKICAgIH0KICAgIHJldHVybiByZXQKICB9CiAgCiAgaWYgKGdsb2JhbC5jb25zb2xlKSB7CiAgICB2YXIganNMb2dnZXIgPSBjb25zb2xlLmxvZzsKICAgIGdsb2JhbC5jb25zb2xlLmxvZyA9IGZ1bmN0aW9uKCkgewogICAgICBnbG9iYWwuX09DX2xvZy5hcHBseShnbG9iYWwsIGFyZ3VtZW50cyk7CiAgICAgIGlmIChqc0xvZ2dlcikgewogICAgICAgIGpzTG9nZ2VyLmFwcGx5KGdsb2JhbC5jb25zb2xlLCBhcmd1bWVudHMpOwogICAgICB9CiAgICB9CiAgfSBlbHNlIHsKICAgIGdsb2JhbC5jb25zb2xlID0gewogICAgICBsb2c6IGdsb2JhbC5fT0NfbG9nCiAgICB9CiAgfQoKICBnbG9iYWwuZGVmaW5lSlNDbGFzcyA9IGZ1bmN0aW9uKGRlY2xhcmF0aW9uLCBpbnN0TWV0aG9kcywgY2xzTWV0aG9kcykgewogICAgdmFyIG8gPSBmdW5jdGlvbigpIHt9LAogICAgICAgIGEgPSBkZWNsYXJhdGlvbi5zcGxpdCgnOicpLAogICAgICAgIGNsc05hbWUgPSBhWzBdLnRyaW0oKSwKICAgICAgICBzdXBlckNsc05hbWUgPSBhWzFdID8gYVsxXS50cmltKCkgOiBudWxsCiAgICBvLnByb3RvdHlwZSA9IHsKICAgICAgaW5pdDogZnVuY3Rpb24oKSB7CiAgICAgICAgaWYgKHRoaXMuc3VwZXIoKSkgdGhpcy5zdXBlcigpLmluaXQoKQogICAgICAgIHJldHVybiB0aGlzOwogICAgICB9LAogICAgICBzdXBlcjogZnVuY3Rpb24oKSB7CiAgICAgICAgcmV0dXJuIHN1cGVyQ2xzTmFtZSA/IF9qc0Nsc1tzdXBlckNsc05hbWVdLnByb3RvdHlwZSA6IG51bGwKICAgICAgfQogICAgfQogICAgdmFyIGNscyA9IHsKICAgICAgYWxsb2M6IGZ1bmN0aW9uKCkgewogICAgICAgIHJldHVybiBuZXcgbzsKICAgICAgfQogICAgfQogICAgZm9yICh2YXIgbWV0aG9kTmFtZSBpbiBpbnN0TWV0aG9kcykgewogICAgICBvLnByb3RvdHlwZVttZXRob2ROYW1lXSA9IGluc3RNZXRob2RzW21ldGhvZE5hbWVdOwogICAgfQogICAgZm9yICh2YXIgbWV0aG9kTmFtZSBpbiBjbHNNZXRob2RzKSB7CiAgICAgIGNsc1ttZXRob2ROYW1lXSA9IGNsc01ldGhvZHNbbWV0aG9kTmFtZV07CiAgICB9CiAgICBnbG9iYWxbY2xzTmFtZV0gPSBjbHMKICAgIF9qc0Nsc1tjbHNOYW1lXSA9IG8KICB9CiAgCiAgZ2xvYmFsLllFUyA9IDEKICBnbG9iYWwuTk8gPSAwCiAgZ2xvYmFsLm5zbnVsbCA9IF9PQ19udWxsCiAgZ2xvYmFsLl9mb3JtYXRPQ1RvSlMgPSBfZm9ybWF0T0NUb0pTCiAgCn0pKCkK";

static NSString *PDLPuddingStringJPTag(void) {
    char s[3];
    s[0] = 'J';
    s[1] = 'P';
    s[2] = '\0';
    return @(s);
}

NSString *PDLPuddingStringBlockClassName(void) {
    NSString *string = [PDLPuddingStringJP() stringByAppendingString:@"Block"];
    PDLPuddingString_ASSERT([string isEqualToString:@"JPBlock"]);
    return string;
}

NSString *PDLPuddingStringJP(void) {
    NSString *string = [NSString stringWithFormat:@"_%@", PDLPuddingStringJPTag()];
    PDLPuddingString_ASSERT([string isEqualToString:@"_JP"]);
    return string;
}

NSString *PDLPuddingStringJPAT(void) {
    NSString *string = [PDLPuddingStringJP() stringByAppendingString:@"%@"];
    PDLPuddingString_ASSERT([string isEqualToString:@"_JP%@"]);
    return string;
}

NSString *PDLPuddingStringJPSuper(void) {
    NSString *string = [PDLPuddingStringJP() stringByAppendingString:@"SUPER_"];
    PDLPuddingString_ASSERT([string isEqualToString:@"_JPSUPER_"]);
    return string;
}
