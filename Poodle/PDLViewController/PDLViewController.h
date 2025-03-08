//
//  PDLViewController.h
//  Poodle
//
//  Created by Poodle on 2014/12/31.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDLKeyboardNotificationObserver.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLViewController : UIViewController <PDLKeyboardNotificationObserverDelegate>

@property (nonatomic, weak, readonly) UIView *containerView;

// default YES.
@property (nonatomic, assign) BOOL adjustContainerViewSizeForKeyboardEventAutomatically;

- (void)layoutContainerView;

@end

NS_ASSUME_NONNULL_END
