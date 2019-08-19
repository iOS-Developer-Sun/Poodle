//
//  PDLOpenUrlViewController.h
//  Poodle
//
//  Created by Poodle on 15/7/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDLOpenUrlViewController : UIViewController

@property (nonatomic, copy, class) void (^openUrlAction)(NSString *urlString);

+ (void)addConstantItemWithTitle:(NSString *)title urlString:(NSString *)urlString;

@end
