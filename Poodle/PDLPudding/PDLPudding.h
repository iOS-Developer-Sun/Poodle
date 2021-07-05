//
//  PDLPudding.h
//  Poodle
//
//  Created by sunzj on 2021/7/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLPudding : NSObject

+ (JSValue *)evaluateScript:(NSString *)script;

@end

NS_ASSUME_NONNULL_END
