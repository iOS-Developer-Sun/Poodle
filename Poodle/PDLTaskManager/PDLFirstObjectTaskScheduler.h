//
//  PDLFirstObjectTaskScheduler.h
//  PoodleApplication
//
//  Created by Poodle on 2020/9/30.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLTaskScheduler.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLFirstObjectTaskScheduler : PDLTaskScheduler

@property (nonatomic, weak) PDLTask *result;

@end

NS_ASSUME_NONNULL_END
