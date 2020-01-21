//
//  PDLOpenUrlViewController.h
//  Poodle
//
//  Created by Poodle on 15/7/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"

@interface PDLOpenUrlViewController : PDLViewController

@property (nonatomic, copy, class) void (^openUrlAction)(NSString *urlString);

+ (void)addConstantItemWithTitle:(NSString *)title urlString:(NSString *)urlString;

@end
