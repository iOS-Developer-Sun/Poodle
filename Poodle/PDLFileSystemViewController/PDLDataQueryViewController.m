//
//  PDLDataQueryViewController.m
//  Poodle
//
//  Created by Poodle on 15/4/28.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLDataQueryViewController.h"
#import "PDLDatabase.h"

@interface PDLDataQueryViewController () <UITextViewDelegate>

@property (nonatomic, weak) UITextView *inputView;
@property (nonatomic, weak) UITextView *outputView;
@property (nonatomic, copy) NSArray *keyWords;

@end

@implementation PDLDataQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Data Query";

    self.view.backgroundColor = [UIColor colorWithRed:0.937255 green:0.937255 blue:0.956863 alpha:1];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Execute" style:UIBarButtonItemStylePlain target:self action:@selector(executeQuery)];

    self.keyWords = @[@"select", @"from", @"insert", @"into", @"replace", @"update", @"set", @"where", @"delete", @"as", @"in", @"and", @"or", @"order by", @"count", @"desc", @"asc", @"like", @"limit"];
    self.keyWords = [self.keyWords sortedArrayUsingSelector:@selector(compare:)];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:headerView];

    CGFloat footerViewHeight = self.view.frame.size.height - headerView.frame.size.height;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - footerViewHeight, self.view.frame.size.width, footerViewHeight)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:footerView];

    UITextView *inputView = [[UITextView alloc] initWithFrame:CGRectInset(headerView.bounds, 5, 5)];
    inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    inputView.backgroundColor = [UIColor whiteColor];
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
    NSError *error = nil;
    NSArray *result = [self.database executeQuery:query error:&error];
    if (error) {
        self.outputView.text = [NSString stringWithFormat:@"(%@)%@", @(error.code), error.localizedDescription];
    } else {
        self.outputView.text = result.description;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    textView.returnKeyType = UIReturnKeyGo;
    [textView reloadInputViews];

    if ([text isEqualToString:@"\n"]) {
        NSRange selectedRange = textView.selectedRange;
        if (selectedRange.length != 0) {
            textView.selectedRange = NSMakeRange(selectedRange.location + selectedRange.length, 0);
        } else {
            [self executeQuery];
        }
        return NO;
    }

    if ([text isEqualToString:@""]) {
        return YES;
    }

    NSString *orignalText = textView.text;
    NSString *previewText = [[orignalText stringByReplacingCharactersInRange:range withString:text] lowercaseString];
    textView.text = previewText;
    textView.selectedRange = NSMakeRange(range.location + text.length, 0);

    NSString *headText = [previewText substringToIndex:textView.selectedRange.location];
    NSArray *components = [headText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (components.count == 0) {
        return NO;
    }

    NSString *lastWord = components.lastObject;
    if (lastWord.length == 0) {
        return NO;
    }

    for (NSString *keyWord in self.keyWords) {
        if ([keyWord hasPrefix:lastWord] && (keyWord.length > lastWord.length)) {
            NSRange selectedRange = textView.selectedRange;
            NSString *suffix = [keyWord substringWithRange:NSMakeRange(lastWord.length, keyWord.length - lastWord.length)];
            NSString *finalText = [previewText stringByReplacingCharactersInRange:selectedRange withString:suffix];
            textView.text = finalText;
            textView.selectedRange = NSMakeRange(selectedRange.location, suffix.length);
            textView.returnKeyType = UIReturnKeyDone;
            [textView reloadInputViews];
            break;
        }
    }

    return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
    textView.text = [textView.text lowercaseString];
}

@end
