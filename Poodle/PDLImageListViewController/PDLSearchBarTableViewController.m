//
//  PDLSearchBarTableViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLSearchBarTableViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDLKeyboardNotificationObserver.h"

@interface PDLSearchBarTableViewController () <UISearchBarDelegate, UIGestureRecognizerDelegate, PDLKeyboardNotificationObserver>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation PDLSearchBarTableViewController

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _searchBar.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

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

    [self loadData];
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

- (void)keyboardShowAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height) - keyboardHeight);
}

- (void)keyboardHideAnimation:(PDLKeyboardNotificationObserver *)observer withKeyboardHeight:(CGFloat)keyboardHeight {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.frame.size.height - (self.searchBar.frame.origin.y + self.searchBar.frame.size.height));
}

- (void)tap {
    [self.searchBar resignFirstResponder];
}

- (void)loadData {
    ;
}

- (void)filterWithString:(NSString *)string {
    ;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.filteredData.count;
    return numbers;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate

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
