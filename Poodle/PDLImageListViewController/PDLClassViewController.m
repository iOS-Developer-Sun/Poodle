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

@interface PDLClassViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *className;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSArray <NSDictionary *>*dataSource;

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

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    [self loadClass];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)loadClass {
    Class aClass = NSClassFromString(self.className);
    if (aClass == Nil) {
        return;
    }

    Class superclass = class_getSuperclass(aClass);
    const char *superClassName = class_getName(superclass) ?: "";

    NSDictionary *superclassDictionary = @{@"title" : @"superclass", @"data" : @[@(superClassName)]};

    NSMutableArray *subclasses = [NSMutableArray array];
    for (NSString *subclass in pdl_class_subclasses(aClass)) {
        [subclasses addObject:subclass];
    }
    NSDictionary *subclassesDictionary = @{@"title" : @"subclasses", @"data" : subclasses};

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

    NSMutableArray *protocols = [NSMutableArray array];
    for (NSDictionary *dictionary in pdl_class_protocols(aClass)) {
        NSString *string = dictionary.description;
        [protocols addObject:string];
    }
    NSDictionary *protocolsDictionary = @{@"title" : @"protocols", @"data" : protocols};

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

    self.dataSource = @[superclassDictionary, subclassesDictionary, ivarsDictionary, propertiesDictionary, protocolsDictionary, classMethodsDictionary, instanceMethodsDictionary];
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
    NSArray *data = self.dataSource[section][@"data"];
    NSInteger numbers = data.count;
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

    if (indexPath.section == 0) {
        Class aClass = NSClassFromString(self.className);
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            PDLClassViewController *viewController = [[self.class alloc] initWithClassName:@(class_getName(superclass))];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == 1) {
        NSString *subclassString = self.dataSource[indexPath.section][@"data"][indexPath.row];
        PDLClassViewController *viewController = [[self.class alloc] initWithClassName:subclassString];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
