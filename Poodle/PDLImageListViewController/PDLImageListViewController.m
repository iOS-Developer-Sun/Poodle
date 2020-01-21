//
//  PDLImageListViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLImageListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDLClassListViewController.h"
#import "PDLProtocolListViewController.h"
#import "PDLSystemImage.h"
#import "PDLKeyboardNotificationObserver.h"

@interface PDLImageListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, PDLKeyboardNotificationObserver>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *filteredImages;

@end

@implementation PDLImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Images";

    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithTitle:@"Classes" style:UIBarButtonItemStylePlain target:self action:@selector(toClasses)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"Protocols" style:UIBarButtonItemStylePlain target:self action:@selector(toProtocols)]
                                                ];

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

    [self loadImages];
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

- (void)toClasses {
    PDLClassListViewController *viewController = [[PDLClassListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)toProtocols {
    PDLProtocolListViewController *viewController = [[PDLProtocolListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)tap {
    [self.searchBar resignFirstResponder];
}

- (void)loadImages {
    unsigned int outCount = 0;
    NSMutableArray *imageArray = [NSMutableArray array];
    const char **imageNames = objc_copyImageNames(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        const char *imageName = imageNames[i];
        [imageArray addObject:@(imageName)];
    }
    free(imageNames);
    self.images = imageArray;
    self.title = [@"Images" stringByAppendingFormat:@"(%@)", @(self.images.count)];
}

- (void)filterWithString:(NSString *)string {
    if (string.length == 0) {
        self.filteredImages = self.images;
        return;
    }

    NSMutableArray *filteredImages = [NSMutableArray array];
    for (NSString *image in self.images) {
        NSRange range = [image rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == image.length) {
            [filteredImages insertObject:image atIndex:0];
        } else if (range.location != NSNotFound) {
            [filteredImages addObject:image];
        }
    }
    self.filteredImages = filteredImages;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)longPressGestureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath == nil) {
            return;
        }

        NSString *imageName = self.filteredImages[indexPath.row];
        PDLSystemImage *systemImage = [PDLSystemImage systemImageWithPath:imageName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:imageName message:systemImage.description   preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        ;
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.filteredImages.count;
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
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPressGestureRecognizer.delegate = self;
        [cell addGestureRecognizer:longPressGestureRecognizer];
    }
    NSString *imageName = self.filteredImages[indexPath.row];
    cell.textLabel.text = imageName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar resignFirstResponder];

    NSString *imageName = self.filteredImages[indexPath.row];
    PDLClassListViewController *viewController = [[PDLClassListViewController alloc] initWithImageName:imageName];
    [self.navigationController pushViewController:viewController animated:YES];
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
