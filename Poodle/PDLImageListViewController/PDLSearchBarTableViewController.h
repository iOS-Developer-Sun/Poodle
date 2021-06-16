//
//  PDLSearchBarTableViewController.h
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"

@interface PDLSearchBarTableViewController : PDLViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UISearchBar *searchBar;

@property (nonatomic, copy) NSArray *data;
@property (nonatomic, copy) NSArray *filteredData;

- (void)loadData;
- (void)filterWithString:(NSString *)string;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
