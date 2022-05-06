//
//  PDLKeyboardNotificationObserver.h
//  Poodle
//
//  Created by Poodle on 25/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PDLKeyboardNotificationObserver;

@interface PDLKeyboardNotificationObserver : NSObject

@property (nonatomic, assign, readonly, class) CGFloat keyboardHeight;

@property (nonatomic, assign, readonly) BOOL isObserving;
@property (nonatomic, weak) id <PDLKeyboardNotificationObserver>delegate;
@property (nonatomic, copy, readonly) NSDictionary *currentInfo;

+ (void)enable;

+ (instancetype)observerForDelegate:(id <PDLKeyboardNotificationObserver>)delegate;

- (void)startObserving;
- (void)stopObserving;

@end

@protocol PDLKeyboardNotificationObserver <NSObject>

@optional

- (void)keyboardWillShow:(PDLKeyboardNotificationObserver *)observer;
- (void)keyboardWillHide:(PDLKeyboardNotificationObserver *)observer;
- (void)keyboardDidShow:(PDLKeyboardNotificationObserver *)observer;
- (void)keyboardDidHide:(PDLKeyboardNotificationObserver *)observer;

- (void)keyboardShowAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight;
- (void)keyboardHideAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight;

@end
