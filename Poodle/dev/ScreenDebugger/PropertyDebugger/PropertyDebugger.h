//
//  PropertyDebugger.h
//  Sunzj
//
//  Created by sunzj on 6/11/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import "PropertyDebuggerView.h"

@interface PropertyDebugger : NSObject <PropertyDebugger>

@property (nonatomic, weak) id object;
@property (nonatomic, copy) NSString *keyPath;
@property id value;
@property (nonatomic, copy) id(^getter)(PropertyDebugger *propertyDebugger);
@property (nonatomic, copy) void(^setter)(PropertyDebugger *propertyDebugger, id value);

@property (nonatomic, readonly) UIView *mainView;
@property (nonatomic, readonly) UIView *controlPanel;

- (void)mainViewDidLayoutSubviews;
- (void)mainViewDidLoad;
- (void)setControlPanelFloatingEnabled:(BOOL)isEnabled;
- (UIView *)mainViewWithFrame:(CGRect)frame;

@end
