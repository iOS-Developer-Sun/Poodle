//
//  PDLScreenDebuggerWindow.h
//  Poodle
//
//  Created by Poodle on 15/10/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDLScreenDebuggerWindow : UIWindow

@property (nonatomic, weak, readonly) UIView *contentView;
@property (nonatomic, weak, readonly) UIView *componentsView;
@property (nonatomic, weak, readonly) UIView *arrow;
@property (nonatomic, readonly) CGPoint currentPoint;
@property (nonatomic, weak, readonly) UIWindow *previousKeyWindow;
@property (nonatomic, weak, readonly) UIView *detailView;
@property (nonatomic, weak, readonly) UIButton *closeButton;

- (void)debugPoint;

@end
