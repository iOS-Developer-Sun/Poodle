//
//  PDLViewControllerListViewController.h
//  Poodle
//
//  Created by Poodle on 20/4/21.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLViewControllerListViewController : PDLViewController

@property (nonatomic, copy) NSArray *(^allViewControllersLoader)(PDLViewControllerListViewController *viewController);

@end

NS_ASSUME_NONNULL_END
