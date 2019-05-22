//
//  CAAnimation+PDLExtension.h
//  Sun
//
//  Created by Sun on 2019/2/20.
//
//

#import "CADisplayLink+PDLExtension.h"

@interface PDLDisplayLinkTarget : NSObject

@property (nonatomic, copy) void (^action)(CADisplayLink *displayLink);

@end

@implementation PDLDisplayLinkTarget

- (void)displayLinkAction:(CADisplayLink *)displayLink {
    void (^action)(CADisplayLink *displayLink) = self.action;
    if (action) {
        action(displayLink);
    }
}

@end

@implementation CADisplayLink (PDLExtension)

+ (CADisplayLink *)pdl_displayLinkWithAction:(void (^)(CADisplayLink *displayLink))action {
    PDLDisplayLinkTarget *displayLinkTarget = [[PDLDisplayLinkTarget alloc] init];
    displayLinkTarget.action = action;
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:displayLinkTarget selector:@selector(displayLinkAction:)];
    return displayLink;
}

@end

