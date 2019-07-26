//
//  CADisplayLink+PDLExtension.h
//  Sun
//
//  Created by Sun on 2019/2/20.
//
//

#import <QuartzCore/QuartzCore.h>

@interface CADisplayLink (PDLExtension)

+ (CADisplayLink *)pdl_displayLinkWithAction:(void (^)(CADisplayLink *displayLink))action;

@end
