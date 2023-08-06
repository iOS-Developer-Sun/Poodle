//
//  PDLDSym.h
//  Poodle
//
//  Created by Poodle on 2023/8/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLSystemImage.h"

@interface PDLDSym : NSObject

@property (nonatomic, readonly) PDLSystemImage *systemImage;

- (instancetype)initWithSystemImage:(PDLSystemImage *)systemImage;
- (void)addSymbol:(NSString *)symbol debugName:(NSString *)debugName offset:(ptrdiff_t)offset;
- (BOOL)dump:(NSString *)path;

@end
