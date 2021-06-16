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

@interface PDLProtocolListViewController ()

@end

@implementation PDLProtocolListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Protocols";
}

- (void)loadData {
    [super loadData];

    unsigned int outCount = 0;
    NSMutableArray *protocolArray = [NSMutableArray array];
    Protocol * __unsafe_unretained *protocolList = objc_copyProtocolList(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Protocol *protocol = protocolList[i];
        [protocolArray addObject:@(protocol_getName(protocol))];
    }
    free(protocolList);
    self.data = protocolArray;
    self.title = [@"Protocols" stringByAppendingFormat:@"(%@)", @(self.data.count)];
}

- (void)filterWithString:(NSString *)string {
    [super filterWithString:string];

    if (string.length == 0) {
        self.filteredData = self.data;
        return;
    }

    NSMutableArray *filteredProtocols = [NSMutableArray array];
    for (NSString *protocolName in self.data) {
        NSRange range = [protocolName rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == protocolName.length) {
            [filteredProtocols insertObject:protocolName atIndex:0];
        } else if (range.location != NSNotFound) {
            [filteredProtocols addObject:protocolName];
        }
    }
    self.filteredData = filteredProtocols;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
    }
    NSString *imageName = self.filteredData[indexPath.row];
    cell.textLabel.text = imageName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    NSString *protocolName = self.filteredData[indexPath.row];
    PDLProtocolViewController *viewController = [[PDLProtocolViewController alloc] initWithProtocolName:protocolName];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
