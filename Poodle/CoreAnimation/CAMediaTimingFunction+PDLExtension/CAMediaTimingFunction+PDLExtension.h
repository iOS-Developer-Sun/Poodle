//
//  CAMediaTimingFunction+PDLExtension.h
//  Sun
//
//  Created by Sun on 2019/2/20.
//
//

#import <UIKit/UIKit.h>

@interface CAMediaTimingFunction (PDLExtension)

@property (readonly) NSArray *pdl_controlPoints;

- (float)pdl_solve:(float)input;
- (float)pdl_velocity:(float)input;

@end
