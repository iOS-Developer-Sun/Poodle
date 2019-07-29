//
//  CAAnimation+PDLExtension.h
//  Sun
//
//  Created by Sun on 2019/2/20.
//
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (PDLExtension)

@property (copy) void (^pdl_beginning)(CAAnimation *animation);
@property (copy) void (^pdl_completion)(CAAnimation *animation, BOOL finished);

@end
