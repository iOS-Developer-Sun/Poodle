//
//  PDLProtocolViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLProtocolViewController.h"
#import <objc/runtime.h>
#import "NSObject+PDLDebug.h"

@interface PDLProtocolViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *protocolName;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSArray <NSDictionary *>*dataSource;

@end

@implementation PDLProtocolViewController

- (instancetype)initWithProtocolName:(NSString *)protocolName {
    self = [super init];
    if (self) {
        _protocolName = [protocolName copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = [NSString stringWithFormat:@"%@", self.protocolName];

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    [self loadProtocol];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)loadProtocol {
    Protocol *protocol = NSProtocolFromString(self.protocolName);
    if (protocol == Nil) {
        return;
    }

    NSMutableArray *adoptingProtocols = [NSMutableArray array];
    for (NSString *adoptingProtocol in pdl_protocol_adoptingProtocols(protocol)) {
        [adoptingProtocols addObject:adoptingProtocol];
    }
    NSDictionary *adoptingProtocolsDictionary = @{@"title" : @"adopting protocols", @"data" : adoptingProtocols};

    NSMutableArray *adoptedProtocols = [NSMutableArray array];
    for (NSString *adoptedProtocol in pdl_protocol_adoptedProtocols(protocol)) {
        [adoptedProtocols addObject:adoptedProtocol];
    }
    NSDictionary *adoptedProtocolsDictionary = @{@"title" : @"adopted protocols", @"data" : adoptedProtocols};

    NSMutableArray *properties = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_protocol_properties(protocol)) {
        NSString *string = dictionary.description;
        [properties addObject:string];
    }
    NSDictionary *propertiesDictionary = @{@"title" : @"properties", @"data" : properties};

    NSMutableArray *methods = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_protocol_methods(protocol)) {
        NSString *string = dictionary.description;
        [methods addObject:string];
    }
    NSDictionary *methodsDictionary = @{@"title" : @"methods", @"data" : methods};

    self.dataSource = @[adoptingProtocolsDictionary, adoptedProtocolsDictionary, propertiesDictionary, methodsDictionary];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataSource[section][@"title"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numbers = self.dataSource.count;
    return numbers;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = [self.dataSource[section][@"data"] count];
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
    NSDictionary *dictionary = self.dataSource[indexPath.section][@"data"][indexPath.row];
    cell.textLabel.text = dictionary.description;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0 || indexPath.section == 1) {
        NSString *protocolString = self.dataSource[indexPath.section][@"data"][indexPath.row];
        Protocol *protocol = NSProtocolFromString(protocolString);
        if (protocol) {
            PDLProtocolViewController *viewController = [[self.class alloc] initWithProtocolName:@(protocol_getName(protocol))];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

@end
