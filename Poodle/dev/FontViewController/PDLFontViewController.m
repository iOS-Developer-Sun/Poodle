//
//  PDLFontViewController.m
//  Poodle
//
//  Created by Poodle on 15/7/21.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLFontViewController.h"

@interface PDLFontViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSArray *fontFamilyNames;
@property (nonatomic, copy) NSArray *fontFamilyNamesIndexesKeys;
@property (nonatomic, copy) NSDictionary *fontFamilyNamesIndexesDictionary;

@end

@implementation PDLFontViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.fontFamilyNames = [[UIFont familyNames] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = (NSString *)obj1;
        NSString *name2 = (NSString *)obj2;
        return [name1 compare:name2];
    }];

    self.title = [NSString stringWithFormat:@"Font(%@)", @(self.fontFamilyNames.count)];

    NSMutableArray *fontFamilyNamesIndexesKeys = [NSMutableArray array];
    NSMutableDictionary *fontFamilyNamesIndexesDictionary = [NSMutableDictionary dictionary];
    for (NSString *fontFamilyName in self.fontFamilyNames) {
        if (fontFamilyName.length == 0) {
            continue;
        }
        NSString *capital = [[fontFamilyName substringToIndex:1] lowercaseString];
        if (fontFamilyNamesIndexesDictionary[capital] == nil) {
            NSInteger index = [self.fontFamilyNames indexOfObject:fontFamilyName];
            fontFamilyNamesIndexesDictionary[capital] = @(index);
            [fontFamilyNamesIndexesKeys addObject:capital];
        }
    }
    self.fontFamilyNamesIndexesKeys = fontFamilyNamesIndexesKeys;
    self.fontFamilyNamesIndexesDictionary = fontFamilyNamesIndexesDictionary;

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundView = nil;
    self.tableView = tableView;

    [self.view addSubview:tableView];
}

- (void)setExampleText:(NSString *)exampleText {
    _exampleText = exampleText.copy;
    [self.tableView reloadData];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fontFamilyNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *familyName = self.fontFamilyNames[section];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    return fontNames.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *familyName = self.fontFamilyNames[section];
    return familyName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FontViewControllerTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cell.contentView.frame.size.width - 30, 30)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:textLabel];
        textLabel.tag = 1;

        UILabel *detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, cell.contentView.frame.size.width - 30, 120)];
        detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        detailTextLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:detailTextLabel];
        detailTextLabel.tag = 2;
        detailTextLabel.numberOfLines = 0;

        detailTextLabel.text = self.exampleText ?: @"abcdefghijklmnopqrstuvwxyz\n1234567890\n简体中文\n繁體中文\n日本語あいうえお\n~`!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?";
        detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }

    NSString *familyName = self.fontFamilyNames[indexPath.section];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    NSString *fontName = fontNames[indexPath.row];

    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *detailTextLabel = (UILabel *)[cell.contentView viewWithTag:2];

    textLabel.font = [UIFont fontWithName:fontName size:14];
    textLabel.text = fontName;
    detailTextLabel.font = [UIFont fontWithName:fontName size:12];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *familyName = self.fontFamilyNames[indexPath.section];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    NSString *fontName = fontNames[indexPath.row];
    if (self.fontSelectAction) {
        self.fontSelectAction(self, familyName, fontName);
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.fontFamilyNamesIndexesKeys;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fontFamilyNamesIndexesDictionary[title] integerValue];
}

@end
