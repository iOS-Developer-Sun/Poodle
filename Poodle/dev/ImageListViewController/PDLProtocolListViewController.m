//
//  PDLProtocolListViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLProtocolListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDLProtocolViewController.h"
#import "PDLKeyboardNotificationObserver.h"

@interface PDLProtocolListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PDLKeyboardNotificationObserver>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, copy) NSArray *protocols;
@property (nonatomic, copy) NSArray *filteredProtocols;

@end

@implementation PDLProtocolListViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        ;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Protocols";

    self.view.backgroundColor = [UIColor whiteColor];

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

    [self loadProtocols];
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

- (void)loadProtocols {
    unsigned int outCount = 0;
    NSMutableArray *protocolArray = [NSMutableArray array];
    Protocol * __unsafe_unretained *protocolList = objc_copyProtocolList(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Protocol *protocol = protocolList[i];
        [protocolArray addObject:@(protocol_getName(protocol))];
    }
    free(protocolList);
    self.protocols = protocolArray;
    self.title = [@"Protocols" stringByAppendingFormat:@"(%@)", @(self.protocols.count)];
}

- (void)filterWithString:(NSString *)string {
    if (string.length == 0) {
        self.filteredProtocols = self.protocols;
        return;
    }

    NSMutableArray *filteredProtocols = [NSMutableArray array];
    for (NSString *protocolName in self.protocols) {
        NSRange range = [protocolName rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == protocolName.length) {
            [filteredProtocols insertObject:protocolName atIndex:0];
        } else if (range.location != NSNotFound) {
            [filteredProtocols addObject:protocolName];
        }
    }
    self.filteredProtocols = filteredProtocols;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.filteredProtocols.count;
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
    NSString *imageName = self.filteredProtocols[indexPath.row];
    cell.textLabel.text = imageName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];

    NSString *protocolName = self.filteredProtocols[indexPath.row];
    PDLProtocolViewController *viewController = [[PDLProtocolViewController alloc] initWithProtocolName:protocolName];
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
