//
//  PDLImageListViewController.m
//  Poodle
//
//  Created by Poodle on 01/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLImageListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDLClassListViewController.h"
#import "PDLProtocolListViewController.h"
#import "PDLSystemImage.h"
#import "PDLKeyboardNotificationObserver.h"

@interface PDLImageListViewController () <UIGestureRecognizerDelegate>

@end

@implementation PDLImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"Images";

    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"Classes" style:UIBarButtonItemStylePlain target:self action:@selector(toClasses)],
        [[UIBarButtonItem alloc] initWithTitle:@"Protocols" style:UIBarButtonItemStylePlain target:self action:@selector(toProtocols)],
    ];
}

- (void)toClasses {
    PDLClassListViewController *viewController = [[PDLClassListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)toProtocols {
    PDLProtocolListViewController *viewController = [[PDLProtocolListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)loadData {
    [super loadData];

    unsigned int outCount = 0;
    NSMutableArray *imageArray = [NSMutableArray array];
    const char **imageNames = objc_copyImageNames(&outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        const char *imageName = imageNames[i];
        [imageArray addObject:@(imageName)];
    }
    free(imageNames);
    self.data = imageArray;
    self.title = [@"Images" stringByAppendingFormat:@"(%@)", @(self.data.count)];
}

- (void)filterWithString:(NSString *)string {
    [super filterWithString:string];

    if (string.length == 0) {
        self.filteredData = self.data;
        return;
    }

    NSMutableArray *filteredImages = [NSMutableArray array];
    for (NSString *image in self.data) {
        NSRange range = [image rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.location == 0 && range.length == image.length) {
            [filteredImages insertObject:image atIndex:0];
        } else if (range.location != NSNotFound) {
            [filteredImages addObject:image];
        }
    }
    self.filteredData = filteredImages;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)longPressGestureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath == nil) {
            return;
        }

        NSString *imageName = self.filteredData[indexPath.row];
        PDLSystemImage *systemImage = [PDLSystemImage systemImageWithPath:imageName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:imageName message:systemImage.description   preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        ;
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPressGestureRecognizer.delegate = self;
        [cell addGestureRecognizer:longPressGestureRecognizer];
    }
    NSString *imageName = self.filteredData[indexPath.row];
    cell.textLabel.text = imageName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    NSString *imageName = self.filteredData[indexPath.row];
    PDLClassListViewController *viewController = [[PDLClassListViewController alloc] initWithImageName:imageName];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
