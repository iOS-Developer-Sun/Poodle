//
//  PDLCrashViewController.h
//  Poodle
//
//  Created by Poodle on 10/07/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"

@interface PDLCrashViewController : PDLViewController

@property (nonatomic, copy, readonly) NSString *path;

- (instancetype)initWithPath:(NSString *)path;

@end
