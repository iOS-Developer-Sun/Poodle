//
//  PDLClassListViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLClassListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDLClassViewController.h"
#import "PDLKeyboardNotificationObserver.h"

@interface PDLClassListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PDLKeyboardNotificationObserver>

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, copy) NSArray *classes;
@property (nonatomic, copy) NSArray *filteredClasses;

@end

@implementation PDLClassListViewController

- (instancetype)initWithImageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _imageName = [imageName copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Classes";

    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.delegate = self;
    searchBar.keyboardType = UIKeyboardTypeASCIICapable;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, searchBar.frame.origin.y + searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (searchBar.frame.origin.y + searchBar.frame.size.height)) style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    self.tableView = tableView;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    tapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.tapGestureRecognizer = tapGestureRecognizer;

    [self loadClasses];
    [self filterWithString:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[PDLKeyboardNotificationObserver observerForDelegate:self] startObserving];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[PDLKeyboardNotificationObserver observerForDelegate:self] stopObserving];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)keyboardShowAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height) - keyboardHeight);
}

- (void)keyboardHideAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height));
}

- (void)tap {
    [self.searchBar resignFirstResponder];
}

- (void)loadClasses {
    unsigned int outCount = 0;
    NSMutableArray *classArray = [NSMutableArray array];
    if (self.imageName) {
        const char **classNames = objc_copyClassNamesForImage(self.imageName.UTF8String, &outCount);
        for (unsigned int i = 0; i < outCount; i++) {
            const char *className = classNames[i];
            [classArray addObject:@(className)];
        }
        free(classNames);
    } else {
        Class *classList = objc_copyClassList(&outCount);
        for (unsigned int i = 0; i < outCount; i++) {
            Class aClass = classList[i];
            [classArray addObject:@(class_getName(aClass))];
        }
        free(classList);
    }
    self.classes = classArray;
    self.title = [@"Classes" stringByAppendingFormat:@"(%@)", @(self.classes.count)];
}

- (void)filterWithString:(NSString *)string {
    if (string.length == 0) {
        self.filteredClasses = self.classes;
        return;
    }

    NSMutableArray *filteredClasses = [NSMutableArray array];
    for (NSString *className in self.classes) {
        NSRange range = [className rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == className.length) {
            [filteredClasses insertObject:className atIndex:0];
        } else if (range.location != NSNotFound) {
            [filteredClasses addObject:className];
        }
    }
    self.filteredClasses = filteredClasses;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.filteredClasses.count;
    return numbers;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
    }
    NSString *imageName = self.filteredClasses[indexPath.row];
    cell.textLabel.text = imageName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];

    NSString *className = self.filteredClasses[indexPath.row];
    PDLClassViewController *viewController = [[PDLClassViewController alloc] initWithClassName:className];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UISearchviewControllerhBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.tapGestureRecognizer.enabled = YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.tapGestureRecognizer.enabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *text = searchBar.text;
    [self filterWithString:text];
    [self.tableView reloadData];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    ;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    ;
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    ;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    ;
}

@end
