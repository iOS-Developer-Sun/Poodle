//
//  PDLAddressQueryViewController.m
//  Poodle
//
//  Created by Poodle on 15/4/28.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLAddressQueryViewController.h"
#import <stdlib.h>
#import <dlfcn.h>

@interface PDLAddressQueryViewController () <UITextViewDelegate>

@property (nonatomic, weak) UITextView *inputView;
@property (nonatomic, weak) UITextView *outputView;

@end

@implementation PDLAddressQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Address Query";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Execute" style:UIBarButtonItemStylePlain target:self action:@selector(executeQuery)];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, 200)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addSubview:headerView];

    CGFloat footerViewHeight = self.containerView.frame.size.height - headerView.frame.size.height;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.containerView.frame.size.height - footerViewHeight, self.containerView.frame.size.width, footerViewHeight)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:footerView];

    UITextView *inputView = [[UITextView alloc] initWithFrame:CGRectInset(headerView.bounds, 5, 5)];
    inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    inputView.layer.borderWidth = 1;
    inputView.layer.borderColor = [UIColor grayColor].CGColor;
    inputView.keyboardType = UIKeyboardTypeASCIICapable;
    inputView.autocorrectionType = UITextAutocorrectionTypeNo;
    inputView.returnKeyType = UIReturnKeyGo;
    inputView.enablesReturnKeyAutomatically = YES;
    inputView.delegate = self;
    [headerView addSubview:inputView];
    self.inputView = inputView;

    UITextView *outputView = [[UITextView alloc] initWithFrame:CGRectInset(footerView.bounds, 5, 5)];
    outputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    outputView.backgroundColor = [UIColor clearColor];
    outputView.editable = NO;
    [footerView addSubview:outputView];
    self.outputView = outputView;
}

- (void)dealloc {
    _inputView.delegate = nil;
}

- (void)executeQuery {
    [self.inputView resignFirstResponder];
    NSString *query = self.inputView.text ?: @"";

    long addr = strtol(query.UTF8String, NULL, 0);

    Dl_info info = {0};
    int ret = dladdr((void *)addr, &info);
    NSMutableString *result = [NSMutableString stringWithFormat:@"input addr is %lu(0x%lx)\n\ndladdr returns %d\n", addr, addr, ret];
    if (ret) {
        const char *fname = info.dli_fname ?: "null";
        long fbase = (long)info.dli_fbase;
        const char *sname = info.dli_sname ?: "null";
        long saddr = (long)info.dli_saddr;
        long totalOffset = addr - fbase;
        long symbolOffset = saddr - fbase;
        long innerOffset = addr - saddr;
        [result appendFormat:@"\n"
                                @"\tfname: %s\n"
                                @"\tfbase: %lu(0x%lx)\n"
                                @"\tsname: %s\n"
                                @"\tsaddr: %lu(0x%lx)\n",
                                fname, fbase, fbase, sname, saddr, saddr];
        [result appendFormat:@"\n"
                                @"\ttotal offset: %lu(0x%lx)\n"
                                @"\tsymbol offset: %lu(0x%lx)\n"
                                @"\tinner offset: %lu(0x%lx)\n",
                                totalOffset, totalOffset, symbolOffset, symbolOffset, innerOffset, innerOffset];
    }
    self.outputView.text = result;
}

@end
