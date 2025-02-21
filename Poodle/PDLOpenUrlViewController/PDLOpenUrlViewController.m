//
//  PDLOpenUrlViewController.m
//  Poodle
//
//  Created by Poodle on 15/7/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLOpenUrlViewController.h"
#import "PDLGeometry.h"

@interface PDLOpenUrlViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIView *footerView;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong, class, readonly) NSMutableArray *constantTitles;
@property (nonatomic, strong, class, readonly) NSMutableArray *constantUrlStrings;

@end

@implementation PDLOpenUrlViewController

static void (^PDLOpenUrlViewControllerOpenUrlAction)(NSString *urlString) = nil;

+ (void (^)(NSString *))openUrlAction {
    return PDLOpenUrlViewControllerOpenUrlAction;
}

+ (void)setOpenUrlAction:(void (^)(NSString *))openUrlAction {
    PDLOpenUrlViewControllerOpenUrlAction = [openUrlAction copy];
}

+ (NSMutableArray *)constantTitles {
    static NSMutableArray *constantTitles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constantTitles = [NSMutableArray array];
    });
    return constantTitles;
}

+ (NSMutableArray *)constantUrlStrings {
    static NSMutableArray *constantUrlStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        constantUrlStrings = [NSMutableArray array];
    });
    return constantUrlStrings;
}

+ (void)addConstantItemWithTitle:(NSString *)title urlString:(NSString *)urlString {
    if (title && urlString) {
        [self.constantTitles addObject:title];
        [self.constantUrlStrings addObject:urlString];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Open URL";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(openUrl)];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, 200)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addSubview:headerView];
    self.headerView = headerView;

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(headerView.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textView];
    self.textView = textView;

    CGFloat footerViewHeight = self.containerView.frame.size.height - headerView.frame.size.height;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.containerView.frame.size.height - footerViewHeight, self.containerView.frame.size.width, footerViewHeight)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:footerView];
    self.footerView = footerView;

    UITableView *tableView = [[UITableView alloc] initWithFrame:footerView.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [footerView addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.containerView addGestureRecognizer:tap];
}

- (void)layoutContainerView {
    [super layoutContainerView];

    self.headerView.pdl_height = self.containerView.pdl_height * 0.4;
    self.footerView.pdl_height = self.containerView.pdl_height * 0.6;
    self.footerView.pdl_top = self.headerView.pdl_bottom;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL ret = ![touch.view isKindOfClass:[UITextView class]];
    return ret;
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    [self.textView resignFirstResponder];
}

- (void)showUrlString:(NSString *)urlString {
    self.textView.text = urlString;
}

- (void)openUrl {
    [self.containerView endEditing:YES];

    NSString *urlString = self.textView.text;
    if (urlString.length == 0) {
        return;
    }

    if (self.class.openUrlAction) {
        self.class.openUrlAction(urlString);
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.class.constantTitles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *urlString = self.class.constantUrlStrings[indexPath.row];
    [self showUrlString:urlString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *constantCell = @"constantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:constantCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:constantCell];
    }
    cell.textLabel.text = self.class.constantTitles[indexPath.row];
    cell.tag = indexPath.row;
    return cell;
}

@end
