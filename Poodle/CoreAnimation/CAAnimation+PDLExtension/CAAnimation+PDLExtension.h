//
//  CAAnimation+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (PDLExtension)

@property (copy) void (^pdl_beginning)(CAAnimation *animation);
@property (copy) void (^pdl_completion)(CAAnimation *animation, BOOL finished);

@end
