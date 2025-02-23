//
//  PDLFileObserver.m
//  Poodle
//
//  Created by Poodle on 23/2/25.
//  Copyright © 2025 Poodle. All rights reserved.
//

#import "PDLFileObserver.h"

@interface PDLFileObserver ()

@property (nonatomic, assign) int fileDescriptor;
@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation PDLFileObserver

- (instancetype)initWithFilePath:(NSString *)filePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }

    self = [super init];
    if (self) {
        _filePath = [filePath copy];
    }
    return self;
}

- (void)dealloc {
    [self stopObserving];
}

- (BOOL)isObserving {
    return self.source != nil;
}

- (BOOL)startObserving:(void(^)(uintptr_t))action {
    if (!action) {
        return NO;
    }

    int fileDescriptor = open([self.filePath fileSystemRepresentation], O_EVTONLY);
    if (fileDescriptor < 0) {
        return NO;
    }

    self.fileDescriptor = fileDescriptor;

    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor, DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_DELETE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE | DISPATCH_VNODE_WRITE, queue);
    if (!source) {
        close(self.fileDescriptor);
        return NO;
    }

    self.source = source;
    dispatch_source_set_event_handler(source, ^{
        uintptr_t flags = dispatch_source_get_data(source);
        action(flags);
    });

    dispatch_source_set_cancel_handler(source, ^{
        close(fileDescriptor);
    });

    dispatch_resume(source);
    return YES;
}

- (void)stopObserving {
    if (self.source) {
        dispatch_source_cancel(self.source);
    }
    self.source = nil;
    self.fileDescriptor = -1;
}

@end
