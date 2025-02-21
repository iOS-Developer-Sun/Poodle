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
@property (nonatomic, strong) UITableViewCell *tableViewCell;

@end

@implementation PDLFontViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _exampleText = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n1234567890\n简体中文\n繁體中文\n日本語あいうえお\n~`!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fontFamilyNames = [[UIFont familyNames] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = (NSString *)obj1;
        NSString *name2 = (NSString *)obj2;
        return [name1 compare:name2];
    }];
    NSString *systemFamilyName = [UIFont systemFontOfSize:[UIFont systemFontSize]].familyName;
    if (systemFamilyName) {
        self.fontFamilyNames = [@[systemFamilyName] arrayByAddingObjectsFromArray:self.fontFamilyNames];
    }

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

    UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    tableViewCell.frame = CGRectMake(0, 0, tableView.frame.size.width, 44);
    [self setupCell:tableViewCell];
    self.tableViewCell = tableViewCell;
}

- (void)setExampleText:(NSString *)exampleText {
    _exampleText = [exampleText copy];
    [self.tableView reloadData];
}

- (void)setupCell:(UITableViewCell *)cell {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cell.contentView.frame.size.width - 30, 30)];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:textLabel];
    textLabel.tag = 1;

    UILabel *detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, cell.contentView.frame.size.width - 30, 120)];
    detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    detailTextLabel.backgroundColor = [UIColor clearColor];
    detailTextLabel.numberOfLines = 0;
    detailTextLabel.text = self.exampleText;
    detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [cell.contentView addSubview:detailTextLabel];
    detailTextLabel.tag = 2;

    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 150, cell.contentView.frame.size.width - 30, 30)];
    testLabel.backgroundColor = [UIColor lightGrayColor];
    testLabel.text = @"ABCxyz123890";
    [cell.contentView addSubview:testLabel];
    testLabel.tag = 3;
}

- (CGFloat)applyCell:(UITableViewCell *)cell fontName:(NSString *)fontName {
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:1];
    textLabel.text = fontName;

    UILabel *detailTextLabel = (UILabel *)[cell.contentView viewWithTag:2];
    detailTextLabel.font = [UIFont fontWithName:fontName size:12];
    detailTextLabel.frame = CGRectMake(15, 30, cell.contentView.frame.size.width - 30, 0);
    [detailTextLabel sizeToFit];

    UILabel *testLabel = (UILabel *)[cell.contentView viewWithTag:3];
    testLabel.font = [UIFont fontWithName:fontName size:12];
    testLabel.frame = CGRectMake(15, detailTextLabel.frame.origin.y + detailTextLabel.frame.size.height + 10, cell.contentView.frame.size.width - 30, 0);
    [testLabel sizeToFit];

    return testLabel.frame.origin.y + testLabel.frame.size.height + 5;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *familyName = self.fontFamilyNames[indexPath.section];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    NSString *fontName = fontNames[indexPath.row];

    UITableViewCell *cell = self.tableViewCell;
    CGFloat height = [self applyCell:cell fontName:fontName];
    return height;
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
    NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [self setupCell:cell];
    }

    NSString *familyName = self.fontFamilyNames[indexPath.section];
    NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
    NSString *fontName = fontNames[indexPath.row];

    [self applyCell:cell fontName:fontName];
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
