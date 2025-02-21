//
//  PDLTextViewController.m
//  Poodle
//
//  Created by Poodle on 10/07/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLTextViewController.h"

@interface PDLTextViewController ()

@property (nonatomic, copy) NSFileHandle *fileHandle;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, assign) BOOL isReadOnly;

@end

@implementation PDLTextViewController

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        if (fileHandle == nil) {
            _isReadOnly = YES;
            fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
            if (fileHandle == nil) {
                return nil;
            }
        }
        _fileHandle = fileHandle;
        self.title = path.lastPathComponent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (!self.isReadOnly) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    }

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(self.containerView.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont systemFontOfSize:10];
    textView.editable = !self.isReadOnly;
    [self.containerView addSubview:textView];
    self.textView = textView;

    [self loadString];
}

- (void)loadString {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *string = [weakSelf textFileString];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.textView.text = string;
        });
    });
}

- (NSString *)textFileString {
    @synchronized (self.fileHandle) {
        [self.fileHandle seekToFileOffset:0];
        NSData *data = [self.fileHandle readDataToEndOfFile];
        if (data == nil) {
            return nil;
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return string;
    }
}

- (void)save {
    [self.textView resignFirstResponder];

    @synchronized (self.fileHandle) {
        NSString *text = self.textView.text ?: @"";
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        [self.fileHandle truncateFileAtOffset:0];
        [self.fileHandle writeData:data];
        [self.fileHandle synchronizeFile];
    }
}

@end
