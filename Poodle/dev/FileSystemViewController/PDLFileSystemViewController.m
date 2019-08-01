//
//  PDLFileSystemViewController.m
//  Poodle
//
//  Created by Poodle on 16/10/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLFileSystemViewController.h"
#import "PDLDirectoryViewController.h"

@interface PDLFileSystemViewController () <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UITextView *inputView;
@property (nonatomic, copy) NSArray *directories;

@end

@implementation PDLFileSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"File System";

    self.view.backgroundColor = [UIColor whiteColor];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
    self.tableView = tableView;

    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)];
    tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tableView.tableHeaderView = tableHeaderView;

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(tableHeaderView.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.text = @"/";
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [tableHeaderView addSubview:textView];
    self.inputView = textView;
    
    self.directories = @[@{@"name" : @"App", @"path" : [[NSBundle mainBundle] bundlePath]},
                         @{@"name" : @"Sandbox", @"path" : NSHomeDirectory()}
                         ];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStylePlain target:self action:@selector(gotoCustomPath)];
}

- (void)gotoCustomPath {
    NSString *path = self.inputView.text;
    if (path.length > 0) {
        PDLDirectoryViewController *viewController = [[PDLDirectoryViewController alloc] initWithDirectory:path];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.directories.count;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.detailTextLabel.numberOfLines = 0;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *directory = self.directories[indexPath.row];
    cell.textLabel.text = directory[@"name"];
    cell.detailTextLabel.text = directory[@"path"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *directory = self.directories[indexPath.row];
    PDLDirectoryViewController *viewController = [[PDLDirectoryViewController alloc] initWithDirectory:directory[@"path"]];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
