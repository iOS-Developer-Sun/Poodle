//
//  PDLClassViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLClassViewController.h"
#import <objc/runtime.h>
#import "NSObject+PDLDebug.h"

@interface PDLClassViewController ()

@property (nonatomic, copy) NSString *className;

@end

@implementation PDLClassViewController

- (instancetype)initWithClassName:(NSString *)className {
    self = [super init];
    if (self) {
        _className = [className copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    Class aClass = NSClassFromString(self.className);
    self.title = [NSString stringWithFormat:@"%@(%@)", self.className, @(class_getInstanceSize(aClass))];
}

- (void)loadData {
    [super loadData];

    Class aClass = NSClassFromString(self.className);
    if (aClass == Nil) {
        return;
    }

    Class superclass = class_getSuperclass(aClass);
    const char *superClassName = class_getName(superclass) ?: "";

    NSDictionary *superclassDictionary = @{@"title" : @"superclass", @"data" : @[@(superClassName)]};

    NSMutableArray *subclasses = [NSMutableArray array];
    for (NSString *subclass in pdl_class_directSubclasses(aClass)) {
        [subclasses addObject:subclass];
    }
    NSDictionary *subclassesDictionary = @{@"title" : @"subclasses", @"data" : subclasses};

    NSMutableArray *protocols = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_class_protocols(aClass)) {
        NSString *string = dictionary.description;
        [protocols addObject:string];
    }
    NSDictionary *protocolsDictionary = @{@"title" : @"protocols", @"data" : protocols};

    NSMutableArray *ivars = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_class_ivars(aClass)) {
        NSString *string = dictionary.description;
        [ivars addObject:string];
    }
    NSDictionary *ivarsDictionary = @{@"title" : @"ivars", @"data" : ivars};

    NSMutableArray *properties = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_class_properties(aClass)) {
        NSString *string = dictionary.description;
        [properties addObject:string];
    }
    NSDictionary *propertiesDictionary = @{@"title" : @"properties", @"data" : properties};

    NSMutableArray *classMethods = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_class_classMethods(aClass)) {
        NSString *string = dictionary.description;
        [classMethods addObject:string];
    }
    NSDictionary *classMethodsDictionary = @{@"title" : @"class methods", @"data" : classMethods};

    NSMutableArray *instanceMethods = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_class_instanceMethods(aClass)) {
        NSString *string = dictionary.description;
        [instanceMethods addObject:string];
    }
    NSDictionary *instanceMethodsDictionary = @{@"title" : @"instance methods", @"data" : instanceMethods};

    self.data = @[superclassDictionary, subclassesDictionary, protocolsDictionary, ivarsDictionary, propertiesDictionary, classMethodsDictionary, instanceMethodsDictionary];
}

- (void)filterWithString:(NSString *)string {
    [super filterWithString:string];

    if (string.length == 0) {
        self.filteredData = self.data;
        return;
    }

    NSMutableArray *filteredData = [NSMutableArray array];
    for (NSDictionary *dictionary in self.data) {
        NSMutableDictionary *result = [dictionary mutableCopy];
        NSMutableArray *items = [NSMutableArray array];
        for (id item in dictionary[@"data"]) {
            NSString *text = [item description];
            NSRange range = [text rangeOfString:string options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                [items addObject:item];
            }
        }
        result[@"data"] = items;
        [filteredData addObject:result];
    }
    self.filteredData = filteredData;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.filteredData[section][@"title"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numbers = self.filteredData.count;
    return numbers;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *data = self.filteredData[section][@"data"];
    NSInteger numbers = data.count;
    return numbers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
    }
    NSDictionary *dictionary = self.filteredData[indexPath.section][@"data"][indexPath.row];
    cell.textLabel.text = dictionary.description;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    if (indexPath.section == 0) {
        Class aClass = NSClassFromString(self.className);
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            PDLClassViewController *viewController = [[self.class alloc] initWithClassName:@(class_getName(superclass))];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == 1) {
        NSString *subclassString = self.filteredData[indexPath.section][@"data"][indexPath.row];
        PDLClassViewController *viewController = [[self.class alloc] initWithClassName:subclassString];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[
        @":",
        @"::",
        @"<>",
        @"_",
        @"@",
        @"+",
        @"-",
    ];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}


@end
