//
//  PDLDatabaseTableViewController.m
//  Poodle
//
//  Created by Poodle on 09/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLDatabaseTableViewController.h"
#import "PDLFormView.h"

@interface PDLDatabaseTableViewController () <PDLFormViewDelegate>

@property (nonatomic, weak) PDLFormView *formView;

@property (nonatomic, copy) NSArray *fields;
@property (nonatomic, copy) NSArray *rows;

@end

@implementation PDLDatabaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.tableName;

    PDLFormView *formView = [[PDLFormView alloc] initWithFrame:self.view.bounds];
    formView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    formView.delegate = self;
    formView.columnWidth = formView.frame.size.width / 2;
    [self.view addSubview:formView];
    self.formView = formView;

    [self loadData];
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *fields = [self.database fieldsFromTable:self.tableName];
        NSArray *all = [self.database findAll:@"*" fromTable:self.tableName];
        NSMutableArray *rows = [NSMutableArray array];
        for (NSDictionary *row in all) {
            NSMutableArray *values = [NSMutableArray array];
            for (NSString *field in fields) {
                NSString *value = [row[field] description];
                [values addObject:value ?: @""];
            }
            [rows addObject:values.copy];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fields = fields;
            self.rows = rows;
            [self.formView reloadData];
        });
    });
}

- (NSInteger)numberOfColumnsInFormView:(PDLFormView *)formView {
    return self.fields.count;
}

- (NSInteger)numberOfRowsInFormView:(PDLFormView *)formView {
    return self.rows.count + 1;
}

- (CGSize)formView:(PDLFormView *)formView sizeForColumn:(NSInteger)column row:(NSInteger)row {
    NSString *text = nil;
    CGFloat fontSize = [UIFont systemFontSize];
    if (row == 0) {
        fontSize = 14;
        text = self.fields[column];
    } else {
        fontSize = 12;
        text = self.rows[row - 1][column];
    }
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    CGSize size = rect.size;
    if (size.width > formView.frame.size.width / 2) {
        CGFloat widthMax = sqrt(size.width * size.height * 2);
        rect = [text boundingRectWithSize:CGSizeMake(widthMax, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
        size = rect.size;
    }
    if (size.height < 33) {
        size.height = 33;
    }
    return CGSizeMake(ceil(size.width) + 11, ceil(size.height) + 11);
}

- (UIView *)formView:(PDLFormView *)formView viewForColumn:(NSInteger)column row:(NSInteger)row {
    CGFloat fontSize = 12;
    if (row == 0) {
        fontSize = 14;
        NSString *reuseIdentifier = @"field";
        UIView *view = [formView dequeueReusableViewWithIdentifier:reuseIdentifier];
        if (view == nil) {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
            [formView setReuseIdentifier:reuseIdentifier forView:view];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 5, 5)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:fontSize];
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 0;
            label.tag = 1;
            [view addSubview:label];
        }
        UILabel *label = [view viewWithTag:1];
        label.text = self.fields[column];
        view.backgroundColor = column % 2 ? [UIColor blueColor] : [UIColor cyanColor];
        return view;
    }

    NSString *reuseIdentifier = @"view";
    UIView *view = [formView dequeueReusableViewWithIdentifier:reuseIdentifier];
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [formView setReuseIdentifier:reuseIdentifier forView:view];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 5, 5)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.tag = 1;
        [view addSubview:label];
    }
    UILabel *label = [view viewWithTag:1];
    label.text = self.rows[row - 1][column];
    return view;
}

@end
