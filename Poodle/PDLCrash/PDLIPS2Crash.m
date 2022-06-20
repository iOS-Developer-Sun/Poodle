//
//  PDLIPS2Crash.m
//  Poodle
//
//  Created by Poodle on 2021/2/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import "PDLIPS2Crash.h"
#import "ips2crash/Model/IPSReport.h"
#import "ips2crash/tool_ips2crash/ips2crash/IPSReport+CrashRepresentation.h"

@implementation PDLIPS2Crash

+ (NSString *)crashString:(NSString *)ips {
    NSError *error = nil;
    IPSReport *report = [[IPSReport alloc] initWithString:ips error:&error];
    if (error) {
        return nil;
    }

    NSString *crashString = [report crashTextualRepresentation];
    return crashString;
}

@end
