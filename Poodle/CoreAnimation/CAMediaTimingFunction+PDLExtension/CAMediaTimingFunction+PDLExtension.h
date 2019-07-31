//
//  CAMediaTimingFunction+PDLExtension.h
//  Poodle
//
//  Created by Poodle on 2019/2/20.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAMediaTimingFunction (PDLExtension)

@property (readonly) NSArray *pdl_controlPoints;

- (float)pdl_solve:(float)input;
- (float)pdl_velocity:(float)input;

@end
