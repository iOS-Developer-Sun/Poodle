//
//  PDLDirectoryViewController.h
//  Poodle
//
//  Created by Poodle on 09/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLSearchBarTableViewController.h"

@class PDLDirectoryViewController;

@protocol PDLDirectoryViewControllerDelegate <NSObject>

- (NSInteger)directoryViewController:(PDLDirectoryViewController *)directoryViewController numberOfCustomActions:(NSString *)filePath;
- (NSString *)directoryViewController:(PDLDirectoryViewController *)directoryViewController customActionTitle:(NSString *)filePath index:(NSInteger)index;
- (void)directoryViewController:(PDLDirectoryViewController *)directoryViewController customActionDidClick:(NSString *)filePath index:(NSInteger)index;

@end

@interface PDLDirectoryViewController : PDLSearchBarTableViewController

@property (nonatomic, weak, class) id <PDLDirectoryViewControllerDelegate> delegate;

- (instancetype)initWithDirectory:(NSString *)directory;

@end
