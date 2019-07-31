//
//  CADisplayLink+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CADisplayLink (PDLExtension)

+ (CADisplayLink *)pdl_displayLinkWithAction:(void (^)(CADisplayLink *displayLink))action;

@end
