//
//  PropertyDebuggerView.h
//  Sunzj
//
//  Created by sunzj on 5/11/2016.
//  Copyright © 2016 sunzj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PropertyDebuggerView;

@protocol PropertyDebugger <NSObject>

@property (nonatomic, weak) id object;

- (NSString *)keyPath;
- (UIView *)mainViewWithFrame:(CGRect)frame;

@optional

- (NSString *)valueDescription:(id)value;

@end


@protocol PropertyDebuggerViewDelegate <NSObject>

- (void)closeButtonDidTouchUpInside:(PropertyDebuggerView *)propertyDebuggerView;

@end

@interface PropertyDebuggerView : UIControl

@property (nonatomic, weak) id <PropertyDebuggerViewDelegate> delegate;
@property (nonatomic, copy) NSArray *propertyDebuggers;
@property (nonatomic, weak) id object;

@end




@interface PropertyRecord : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;

- (void)undo;
- (void)redo;

@end
