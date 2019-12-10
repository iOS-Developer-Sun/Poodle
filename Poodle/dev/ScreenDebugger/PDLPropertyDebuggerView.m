//
//  PDLPropertyDebuggerView.m
//  Poodle
//
//  Created by Poodle on 5/11/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLPropertyDebuggerView.h"

@interface PDLPropertyDebuggerView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIButton *currentButton;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) id <PDLPropertyDebugger> currentPropertyDebugger;

@end

@implementation PDLPropertyDebuggerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat top = 0;
        CGFloat bottom = 0;
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
            top = safeAreaInsets.top;
            bottom = safeAreaInsets.bottom;
        }

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, top, frame.size.width, 44)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        [self addSubview:headerView];
        _headerView = headerView;

        UIButton *currentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [currentButton setTitle:@"List" forState:UIControlStateNormal];
        [currentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [currentButton addTarget:self action:@selector(currentButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

        currentButton.hidden = YES;
        [headerView addSubview:currentButton];
        _currentButton = currentButton;

        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 60, 0, 60, 44)];
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:closeButton];

        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, top + 44, frame.size.width, frame.size.height - top - 44 - bottom)];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        containerView.backgroundColor = [UIColor clearColor];
        [self addSubview:containerView];
        _containerView = containerView;

        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top + 44, frame.size.width, frame.size.height - top - 44 - bottom) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:tableView];
        _tableView = tableView;
    }
    return self;
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];

    if (hidden) {
        [self stop];
    }
}

- (void)setPropertyDebuggers:(NSArray *)propertyDebuggers {
    _propertyDebuggers = propertyDebuggers.copy;
    [self.tableView reloadData];
}

- (void)currentButtonDidTouchUpInside:(UIButton *)button {
    [self stop];
}

- (void)start {
    self.tableView.hidden = YES;
    self.currentButton.hidden = NO;
    UIView *mainView = [self.currentPropertyDebugger mainViewWithFrame:self.containerView.bounds];
    if (mainView) {
        [self.containerView addSubview:mainView];
    }
    self.currentPropertyDebugger.object = self.object;
}

- (void)stop {
    if (self.currentPropertyDebugger) {
        self.currentPropertyDebugger = nil;
        self.tableView.hidden = NO;
        for (UIView *view in self.containerView.subviews) {
            [view removeFromSuperview];
        }
        self.currentButton.hidden = YES;
    }
}

- (void)closeButtonDidTouchUpInside:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(closeButtonDidTouchUpInside:)]) {
        [self.delegate closeButtonDidTouchUpInside:self];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedIdentifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    id <PDLPropertyDebugger> PDLPropertyDebugger = self.propertyDebuggers[indexPath.row];
    id value = [self.object valueForKeyPath:PDLPropertyDebugger.keyPath];
    NSString *description = nil;
    if ([PDLPropertyDebugger respondsToSelector:@selector(valueDescription:)]) {
        description = [PDLPropertyDebugger valueDescription:value];
    } else {
        description = [NSString stringWithFormat:@"%@", value];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", PDLPropertyDebugger.keyPath, description];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.propertyDebuggers.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currentPropertyDebugger = self.propertyDebuggers[indexPath.row];
    [self start];
}

@end
