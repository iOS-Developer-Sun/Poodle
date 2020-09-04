//
//  PDLViewControllerListViewController.m
//  Poodle
//
//  Created by Poodle on 20/4/21.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "PDLViewControllerListViewController.h"

typedef NS_ENUM(NSInteger, PDLViewControllerRelationship) {
    PDLViewControllerRelationshipNone,
    PDLViewControllerRelationshipRoot,
    PDLViewControllerRelationshipChild,
    PDLViewControllerRelationshipNavigationChild,
    PDLViewControllerRelationshipTabBarChild,
    PDLViewControllerRelationshipPresented,
};

@interface PDLViewControllerListViewControllerViewControllerItem : NSObject

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) PDLViewControllerRelationship relationship;
@property (nonatomic, assign) NSInteger indentationLevel;

@end

@implementation PDLViewControllerListViewControllerViewControllerItem

@end

@interface PDLViewControllerListViewControllerRootItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray <PDLViewControllerListViewControllerViewControllerItem *> *items;

@end

@implementation PDLViewControllerListViewControllerRootItem

@end

@interface PDLViewControllerListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSArray <PDLViewControllerListViewControllerRootItem *>*data;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation PDLViewControllerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"ViewController List";

    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 10) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        tableView.refreshControl = refreshControl;
#pragma clang diagnostic pop
    } else {
        // Fallback on earlier versions
    }

    [self loadData];
}

- (void)loadData {
    NSArray *viewControllersLoaded = @[];
    if (self.allViewControllersLoader) {
        viewControllersLoaded = self.allViewControllersLoader(self);
    }
    NSMutableArray *allViewControllers = viewControllersLoaded.mutableCopy;

    // window rootViewControllers
    NSArray *windows = [UIApplication sharedApplication].windows.copy;
    NSMutableArray *data = [NSMutableArray array];
    for (UIWindow *window in windows) {
        UIViewController *viewController = window.rootViewController;
        NSArray *items = [self itemsForViewController:viewController indentationLevel:0 action:^(UIViewController *eachViewController) {
            [allViewControllers removeObject:eachViewController];
        }];
        PDLViewControllerListViewControllerRootItem *item = [[PDLViewControllerListViewControllerRootItem alloc] init];
        item.title = [NSString stringWithFormat:@"%@ %p, level:%@", window.class, window, @(window.windowLevel)];
        item.items = items;
        [data addObject:item];
    }

    // non window rootViewControllers
    NSMutableArray *rootViewControllers = [NSMutableArray array];
    for (UIViewController *viewController in allViewControllers) {
        if (viewController.navigationController || viewController.tabBarController || viewController.parentViewController || viewController.presentingViewController) {
            continue;
        }
        [rootViewControllers addObject:viewController];
    }
    for (UIViewController *rootViewController in rootViewControllers) {
        NSArray *items = [self itemsForViewController:rootViewController indentationLevel:0 action:^(UIViewController *eachViewController) {
            [allViewControllers removeObject:eachViewController];
        }];
        PDLViewControllerListViewControllerRootItem *item = [[PDLViewControllerListViewControllerRootItem alloc] init];
        item.title = nil;
        item.items = items;
        [data addObject:item];
    }

    // not caught viewControllers
    NSArray *notCaughtViewControllers = allViewControllers.copy;
    if (allViewControllers.count > 0) {
        NSMutableArray *items = [NSMutableArray array];
        for (UIViewController *notCaughtViewController in notCaughtViewControllers) {
            PDLViewControllerListViewControllerViewControllerItem *item = [[PDLViewControllerListViewControllerViewControllerItem alloc] init];
            item.viewController = notCaughtViewController;
            item.relationship = PDLViewControllerRelationshipNone;
            item.indentationLevel = 0;
            [items addObject:item];
        }
        PDLViewControllerListViewControllerRootItem *item = [[PDLViewControllerListViewControllerRootItem alloc] init];
        item.title = @"!";
        item.items = items;
        [data addObject:item];
    }

    // count
    NSUInteger count = 0;
    for (PDLViewControllerListViewControllerRootItem *item in data) {
        count += item.items.count;
    }
    if (viewControllersLoaded.count == 0) {
        self.title = [NSString stringWithFormat:@"ViewController List (%@)", @(count)];
    } else {
        self.title = [NSString stringWithFormat:@"ViewController List (%@/%@)", @(count), @(viewControllersLoaded.count)];
    }

    self.data = data;
}

- (void)reloadData {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 10) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        [self.tableView.refreshControl endRefreshing];
#pragma clang diagnostic pop
    } else {
        // Fallback on earlier versions
    }

    [self loadData];
    [self.tableView reloadData];
}

- (NSArray *)itemsForViewController:(UIViewController *)rootViewController indentationLevel:(NSInteger)indentationLevel action:(void(^)(UIViewController *viewController))action {
    NSMutableArray *stack = [NSMutableArray array];
    if (rootViewController) {
        PDLViewControllerListViewControllerViewControllerItem *item = [[PDLViewControllerListViewControllerViewControllerItem alloc] init];
        item.viewController = rootViewController;
        item.relationship = PDLViewControllerRelationshipRoot;
        item.indentationLevel = 0;
        [stack addObject:item];
    }

    NSMutableArray *items = [NSMutableArray array];
    while (stack.count > 0) {
        PDLViewControllerListViewControllerViewControllerItem *item = stack.lastObject;
        UIViewController *viewController = item.viewController;
        [stack removeLastObject];
        [items addObject:item];
        if (action) {
            action(viewController);
        }

        UIViewController *presentedViewController = viewController.presentedViewController;
        if (presentedViewController && presentedViewController.presentingViewController == viewController) {
            PDLViewControllerListViewControllerViewControllerItem *presentedItem = [[PDLViewControllerListViewControllerViewControllerItem alloc] init];
            presentedItem.viewController = presentedViewController;
            presentedItem.relationship = PDLViewControllerRelationshipPresented;
            presentedItem.indentationLevel = item.indentationLevel + 1;
            [stack addObject:presentedItem];
        }

        NSInteger count = viewController.childViewControllers.count;
        PDLViewControllerRelationship relationship = PDLViewControllerRelationshipChild;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            relationship = PDLViewControllerRelationshipNavigationChild;
        } else if ([viewController isKindOfClass:[UITabBarController class]]) {
            relationship = PDLViewControllerRelationshipTabBarChild;
        }
        for (NSInteger i = 0; i < count; i++) {
            UIViewController *childViewController = viewController.childViewControllers[count - 1 - i];
            PDLViewControllerListViewControllerViewControllerItem *childItem = [[PDLViewControllerListViewControllerViewControllerItem alloc] init];
            childItem.viewController = childViewController;
            childItem.relationship = relationship;
            childItem.indentationLevel = item.indentationLevel + 1;
            [stack addObject:childItem];
        }
    }
    return items.copy;
}

- (NSString *)stringOfRelationship:(PDLViewControllerRelationship)relationship {
    NSString *string = nil;
    switch (relationship) {
        case PDLViewControllerRelationshipRoot:
            string = @"R";
            break;
        case PDLViewControllerRelationshipChild:
            string = @"C";
            break;
        case PDLViewControllerRelationshipNavigationChild:
            string = @"N";
            break;
        case PDLViewControllerRelationshipTabBarChild:
            string = @"T";
            break;
        case PDLViewControllerRelationshipPresented:
            string = @"P";
            break;
        default:
            string = @"";
            break;
    }
    return string;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.data[section].items.count;
    return number;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    PDLViewControllerListViewControllerViewControllerItem *item = self.data[indexPath.section].items[indexPath.row];
    NSInteger indentationLevel = item.indentationLevel;
    return indentationLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedIdentifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor whiteColor];
    }
    PDLViewControllerListViewControllerViewControllerItem *item = self.data[indexPath.section].items[indexPath.row];
    UIViewController *viewController = item.viewController;
    NSString *relationshipString = [self stringOfRelationship:item.relationship];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %p [%@]", viewController.class, viewController, relationshipString];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = UITableViewAutomaticDimension;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    NSString *title = self.data[section].title;
    if (title.length > 0) {
        height = 44;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *reusedIdentifier = @"";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reusedIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reusedIdentifier];
        UILabel *label = [[UILabel alloc] initWithFrame:header.contentView.bounds];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [header.contentView addSubview:label];
        label.tag = 1;
    }
    UILabel *label = [header.contentView viewWithTag:1];
    NSString *title = self.data[section].title;
    label.text = title;
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    UILabel *label = [header.contentView viewWithTag:1];
    label.frame = CGRectInset(header.contentView.bounds, 20, 0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
