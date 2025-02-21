//
//  PDLDatabaseViewController.m
//  Poodle
//
//  Created by Poodle on 09/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLDatabaseViewController.h"
#import "PDLDatabase.h"
#import "PDLDatabaseTableViewController.h"
#import "PDLDataQueryViewController.h"

@interface PDLDatabaseViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PDLDatabase *database;
@property (nonatomic, copy) NSArray *tables;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PDLDatabaseViewController

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        PDLDatabase *database = [PDLDatabase databaseWithPath:path];
        if (!database) {
            return nil;
        }
        _database = database;
        self.title = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Execute" style:UIBarButtonItemStylePlain target:self action:@selector(executeQuery)];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    self.tables = self.database.customTables;
}

- (void)executeQuery {
    PDLDataQueryViewController *dataQueryViewController = [[PDLDataQueryViewController alloc] init];
    dataQueryViewController.database = self.database;
    [self.navigationController pushViewController:dataQueryViewController animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.tables.count;
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
    }
    cell.textLabel.text = self.tables[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PDLDatabaseTableViewController *viewController = [[PDLDatabaseTableViewController alloc] init];
    viewController.database = self.database;
    viewController.tableName = self.tables[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
