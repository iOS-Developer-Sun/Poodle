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

@end

@implementation PDLTextViewController

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
        if (fileHandle == nil) {
            return nil;
        }
        _fileHandle = fileHandle;
        self.title = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(save)];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:textView];
    self.textView = textView;

    self.textView.text = @"iOS UITextView bug";
    self.textView.text = @"";

    [self load];
}

- (void)load {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *string = [self textFileString];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = string;
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
