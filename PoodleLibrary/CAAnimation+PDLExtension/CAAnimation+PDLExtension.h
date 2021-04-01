//
//  CAAnimation+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (PDLExtension)

@property (copy, setter=pdl_setDidStartAction:) void (^pdl_didStartAction)(CAAnimation *animation);
@property (copy, setter=pdl_setDidStopAction:) void (^pdl_didStopAction)(CAAnimation *animation, BOOL finished);

@end
