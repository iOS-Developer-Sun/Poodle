//
//  PDLPropertyDebugger.h
//  Poodle
//
//  Created by Poodle on 6/11/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLPropertyDebuggerView.h"

@interface PDLPropertyDebugger : NSObject <PDLPropertyDebugger>

@property (nonatomic, weak) id object;
@property (nonatomic, copy) NSString *keyPath;
@property id value;
@property (nonatomic, copy) id(^getter)(PDLPropertyDebugger *PDLPropertyDebugger);
@property (nonatomic, copy) void(^setter)(PDLPropertyDebugger *PDLPropertyDebugger, id value);

@property (nonatomic, readonly) UIView *mainView;
@property (nonatomic, readonly) UIView *controlPanel;

- (void)mainViewDidLayoutSubviews;
- (void)mainViewDidLoad;
- (void)setControlPanelFloatingEnabled:(BOOL)isEnabled;
- (UIView *)mainViewWithFrame:(CGRect)frame;

@end
