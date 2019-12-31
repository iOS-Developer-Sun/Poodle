//
//  PDLPropertyListViewController.m
//  Poodle
//
//  Created by Poodle on 10/07/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLPropertyListViewController.h"

@interface PDLPropertyListViewController ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSObject <NSCopying> *plistObject;
@property (nonatomic, weak) UITextView *textView;

@end

@implementation PDLPropertyListViewController

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.title = path;

        _filePath = path.copy;
        NSArray *classes = @[[NSArray class], [NSDictionary class], [NSString class]];
        for (Class aClass in classes) {
            NSObject <NSCopying> *plistObject = [[aClass alloc] initWithContentsOfFile:path];
            if (plistObject) {
                _plistObject = plistObject;
                break;
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont systemFontOfSize:10];
    textView.editable = NO;
    [self.view addSubview:textView];
    self.textView = textView;

    self.textView.text = self.plistObject.description;
}

@end
