//
//  PDLKeyboardNotificationObserver.m
//  Poodle
//
//  Created by Poodle on 25/09/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLKeyboardNotificationObserver.h"

@interface PDLKeyboardNotificationObserver ()

@property (nonatomic, assign, class) CGFloat keyboardHeight;
@property (nonatomic, class, readonly) NSMapTable *observers;
@property (nonatomic, assign) BOOL isObserving;

@property (nonatomic, copy) NSDictionary *currentInfo;

@end

@implementation PDLKeyboardNotificationObserver

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    });
}

static CGFloat PDLKeyboardNotificationObserverKeyboardHeight = 0;
+ (CGFloat)keyboardHeight {
    return PDLKeyboardNotificationObserverKeyboardHeight;
}

+ (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    PDLKeyboardNotificationObserverKeyboardHeight = keyboardHeight;
}

+ (void)handleKeyboardWillShowNotification:(NSNotification *)notification {
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.keyboardHeight = height;
}

+ (void)handleKeyboardWillHideNotification:(NSNotification *)notification {
    self.keyboardHeight = 0;
}

+ (NSMapTable *)observers {
    static NSMapTable *observers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        observers = [NSMapTable weakToStrongObjectsMapTable];
    });
    return observers;
}

+ (instancetype)observerForDelegate:(id <PDLKeyboardNotificationObserver>)delegate {
    NSMapTable *observers = self.observers;
    PDLKeyboardNotificationObserver *observer = [observers objectForKey:delegate];
    if (observer == nil) {
        observer = [[self alloc] init];
        observer.delegate = delegate;
        [observers setObject:observer forKey:delegate];
    }
    return observer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startObserving {
    if (self.isObserving) {
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    self.isObserving = YES;
}

- (void)stopObserving {
    if (self.isObserving == NO) {
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    self.isObserving = NO;
}


- (void)handleKeyboardWillShowNotification:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }

    self.currentInfo = notification.userInfo;

    if ([self.delegate respondsToSelector:@selector(keyboardWillShow:)]) {
        [self.delegate keyboardWillShow:self];
    }

    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView beginAnimations:NSStringFromSelector(@selector(handleKeyboardWillShowNotification:)) context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    if ([self.delegate respondsToSelector:@selector(keyboardShowAnimation:withKeyboardHeight:)]) {
        [self.delegate keyboardShowAnimation:self withKeyboardHeight:height];
    }
    [UIView commitAnimations];
}

- (void)handleKeyboardWillHideNotification:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }

    self.currentInfo = notification.userInfo;

    if ([self.delegate respondsToSelector:@selector(keyboardWillHide:)]) {
        [self.delegate keyboardWillHide:self];
    }

    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView beginAnimations:NSStringFromSelector(@selector(handleKeyboardWillHideNotification:)) context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    if ([self.delegate respondsToSelector:@selector(keyboardHideAnimation:withKeyboardHeight:)]) {
        [self.delegate keyboardHideAnimation:self withKeyboardHeight:height];
    }
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:NSStringFromSelector(@selector(handleKeyboardWillShowNotification:))]) {
        if ([self.delegate respondsToSelector:@selector(keyboardDidShow:)]) {
            [self.delegate keyboardDidShow:self];
        }
    } else if ([animationID isEqualToString:NSStringFromSelector(@selector(handleKeyboardWillHideNotification:))]) {
        if ([self.delegate respondsToSelector:@selector(keyboardDidHide:)]) {
            [self.delegate keyboardDidHide:self];
        }
    }
}

@end
