//
//  PDLClassListViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLClassListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDLClassViewController.h"

@interface PDLClassListViewController ()

@property (nonatomic, copy) NSString *imageName;

@end

@implementation PDLClassListViewController

- (instancetype)initWithImageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _imageName = [imageName copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Classes";
}

- (void)loadData {
    [super loadData];

    unsigned int outCount = 0;
    NSMutableArray *classArray = [NSMutableArray array];
    if (self.imageName) {
        const char **classNames = objc_copyClassNamesForImage(self.imageName.UTF8String, &outCount);
        for (unsigned int i = 0; i < outCount; i++) {
            const char *className = classNames[i];
            [classArray addObject:@(className)];
        }
        free(classNames);
    } else {
        Class *classList = objc_copyClassList(&outCount);
        for (unsigned int i = 0; i < outCount; i++) {
            Class aClass = classList[i];
            [classArray addObject:@(class_getName(aClass))];
        }
        free(classList);
    }
    self.data = classArray;
    self.title = [@"Classes" stringByAppendingFormat:@"(%@)", @(self.data.count)];
}

- (void)filterWithString:(NSString *)string {
    [super filterWithString:string];

    if (string.length == 0) {
        self.filteredData = self.data;
        return;
    }

    NSMutableArray *filteredClasses = [NSMutableArray array];
    for (NSString *className in self.data) {
        NSRange range = [className rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == className.length) {
            [filteredClasses insertObject:className atIndex:0];
        } else if (range.location != NSNotFound) {
            [filteredClasses addObject:className];
        }
    }
    self.filteredData = filteredClasses;
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

    NSString *className = self.filteredData[indexPath.row];
    PDLClassViewController *viewController = [[PDLClassViewController alloc] initWithClassName:className];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
