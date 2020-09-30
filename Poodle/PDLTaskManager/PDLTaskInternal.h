//
//  PDLTaskInternal.h
//  Poodle
//
//  Created by Poodle on 2020/9/29.
//  Copyright © 2020 Poodle. All rights reserved.
//

@interface PDLTask ()

@property (nonatomic, assign) PDLTaskState state;
@property (nonatomic, weak) PDLTaskManager *manager;

- (void)start;
- (void)succeed;
- (void)fail;
- (void)cancel;

@end
