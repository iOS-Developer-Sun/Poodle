//
//  PDLMemoryQueryViewController.m
//  Poodle
//
//  Created by Poodle on 15/7/16.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLMemoryQueryViewController.h"
#import <stdlib.h>
#import "pdl_malloc.h"
#import "PDLGeometry.h"

typedef NS_ENUM(NSUInteger, PDLMemoryQueryArgumentType) {
    PDLMemoryQueryArgumentTypeClass,
    PDLMemoryQueryArgumentTypeSelector,
    PDLMemoryQueryArgumentTypeNSObject,
    PDLMemoryQueryArgumentTypeNSString,
    PDLMemoryQueryArgumentTypeNSArray,
    PDLMemoryQueryArgumentTypeNSDictionary,
    PDLMemoryQueryArgumentTypeNSIntegerNumber,
    PDLMemoryQueryArgumentTypeDoubleNumber,
    PDLMemoryQueryArgumentTypeBoolNumber,
    PDLMemoryQueryArgumentTypeNSInteger,
    PDLMemoryQueryArgumentTypeDouble,
    PDLMemoryQueryArgumentTypeBool,
    PDLMemoryQueryArgumentTypeCount
};

typedef NS_ENUM(NSUInteger, PDLMemoryQueryArgumentParseError) {
    PDLMemoryQueryArgumentParseErrorNone,
    PDLMemoryQueryArgumentParseErrorInvalidClass,
    PDLMemoryQueryArgumentParseErrorInvalidSelector,
    PDLMemoryQueryArgumentParseErrorInvalidAddress,
    PDLMemoryQueryArgumentParseErrorInvalidArray,
    PDLMemoryQueryArgumentParseErrorInvalidDictionary,
    PDLMemoryQueryArgumentParseErrorCount
};

@interface PDLMemoryQueryArgument : NSObject

@property (nonatomic, assign) PDLMemoryQueryArgumentType type;
@property (nonatomic, copy) NSString *string;

@end

@implementation PDLMemoryQueryArgument

+ (NSArray *)typeStrings {
    NSArray *strings = @[@"Class", @"Selector", @"id(address)", @"NSString", @"NSArray", @"NSDictionary", @"NSNumber(integer)", @"NSNumber(double)", @"NSNumber(bool)", @"NSInteger", @"Double", @"Bool"];
    return strings;
}

+ (NSString *)stringOfArgumentType:(PDLMemoryQueryArgumentType)type {
    return [self typeStrings][type];
}

@end

@implementation PDLMemoryQueryResult

- (NSString *)resultDescription {
    NSString *resultDescription;
    switch (self.type) {
        case PDLMemoryQueryResultTypeUnknown:
            resultDescription = [NSString stringWithFormat:@"Result Type Unknown: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeVoid:
            resultDescription = [NSString stringWithFormat:@"Result Type Void"];
            break;
        case PDLMemoryQueryResultTypeClass:
            resultDescription = [NSString stringWithFormat:@"Result Type Class: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeSelector:
            resultDescription = [NSString stringWithFormat:@"Result Type Selector: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeNSObject:
            resultDescription = [NSString stringWithFormat:@"Result Type NSObject(<%@: %p>): %@", NSStringFromClass([self.result class]), self.result, self.result];
            break;
        case PDLMemoryQueryResultTypeChar:
            resultDescription = [NSString stringWithFormat:@"Result Type Char: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeShort:
            resultDescription = [NSString stringWithFormat:@"Result Type Short: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeInt:
            resultDescription = [NSString stringWithFormat:@"Result Type Int: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeLong:
            resultDescription = [NSString stringWithFormat:@"Result Type Long: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeLongLong:
            resultDescription = [NSString stringWithFormat:@"Result Type Long Long: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeUnsignedChar:
            resultDescription = [NSString stringWithFormat:@"Result Type Unsigned Char: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeUnsignedShort:
            resultDescription = [NSString stringWithFormat:@"Result Type Unsigned Short: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeUnsignedInt:
            resultDescription = [NSString stringWithFormat:@"Result Type Unsigned Int: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeUnsignedLong:
            resultDescription = [NSString stringWithFormat:@"Result Type Unsigned Long: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeUnsignedLongLong:
            resultDescription = [NSString stringWithFormat:@"Result Type Unsigned Long Long: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeFloat:
            resultDescription = [NSString stringWithFormat:@"Result Type Float: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeDouble:
            resultDescription = [NSString stringWithFormat:@"Result Type Double: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeBool:
            resultDescription = [NSString stringWithFormat:@"Result Type Bool: %@", self.result];
            break;
        case PDLMemoryQueryResultTypePointer: {
            NSNumber *result = self.result;
            void *pointer = (void *)result.longValue;
            resultDescription = [NSString stringWithFormat:@"Result Type Pointer: %p", pointer];
        } break;
        case PDLMemoryQueryResultTypeFunctionPointer: {
            NSNumber *result = self.result;
            void *pointer = (void *)result.longValue;
            resultDescription = [NSString stringWithFormat:@"Result Type FunctionPointer: %p", pointer];
        } break;
        case PDLMemoryQueryResultTypeCString: {
            NSNumber *result = self.result;
            char *cstring = (char *)result.longValue;
            resultDescription = [NSString stringWithFormat:@"Result Type CString: %p, %@", cstring, @(cstring)];
        } break;
        case PDLMemoryQueryResultTypeBlock:
            resultDescription = [NSString stringWithFormat:@"Result Type Block(<%@: %p>): %@", NSStringFromClass([self.result class]), self.result, self.result];
            break;
        case PDLMemoryQueryResultTypeCGPoint:
            resultDescription = [NSString stringWithFormat:@"Result Type CGPoint: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeCGSize:
            resultDescription = [NSString stringWithFormat:@"Result Type CGSize: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeCGRect:
            resultDescription = [NSString stringWithFormat:@"Result Type CGRect: %@", self.result];
            break;
        case PDLMemoryQueryResultTypeError:
            resultDescription = [NSString stringWithFormat:@"Result Type Error: %@", self.result];
            break;

        default:
            break;
    }

    return resultDescription;
}

@end


@class PDLMemoryQueryArgumentCell;

@protocol PDLMemoryQueryArgumentCellDelegate <NSObject>

@optional

- (void)memoryQueryArgumentCellTypeButtonDidTouchUpInside:(PDLMemoryQueryArgumentCell *)memoryQueryArgumentCell;
- (void)memoryQueryArgumentCell:(PDLMemoryQueryArgumentCell*)PDLMemoryQueryArgumentCell textViewDidBeginEditing:(UITextView *)textView;
- (void)memoryQueryArgumentCell:(PDLMemoryQueryArgumentCell*)PDLMemoryQueryArgumentCell textViewDidChanged:(UITextView *)textView;

@end

@interface PDLMemoryQueryArgumentCell : UITableViewCell <UIActionSheetDelegate, UITextViewDelegate>

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UIButton *detailButton;
@property (nonatomic, weak) UIButton *clearButton;
@property (nonatomic, weak) id <PDLMemoryQueryArgumentCellDelegate> delegate;
@end

@implementation PDLMemoryQueryArgumentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        CGFloat margin = 5;
        CGFloat buttonWidth = 130;
        CGFloat height = self.contentView.frame.size.height - margin * 2;

        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(margin, margin, self.contentView.frame.size.width - buttonWidth - self.contentView.frame.size.height - margin * 3, height)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.delegate = self;
        textView.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:textView];
        _textView = textView;

        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - buttonWidth - margin * 2 - self.contentView.frame.size.height, margin, self.contentView.frame.size.height, self.contentView.frame.size.height)];
        clearButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        clearButton.alpha = 0.5;
        clearButton.exclusiveTouch = YES;
        [clearButton setTitle:@"❌" forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:clearButton];
        _clearButton = clearButton;
        clearButton.hidden = YES;

        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - buttonWidth - margin, margin, buttonWidth, height)];
        detailButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [detailButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        detailButton.exclusiveTouch = YES;
        [detailButton addTarget:self action:@selector(detailButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [detailButton setTitle:@"None" forState:UIControlStateNormal];
        detailButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        detailButton.layer.borderColor = [UIColor purpleColor].CGColor;
        detailButton.layer.borderWidth = 1;
        detailButton.layer.cornerRadius = 3;
        [self.contentView addSubview:detailButton];
        _detailButton = detailButton;
    }
    return self;
}

- (void)dealloc {
    _textView.delegate = nil;
}

- (void)refreshClearButton {
    self.clearButton.hidden = (self.textView.text.length == 0);
}

- (void)clearText {
    self.textView.text = @"";
    [self refreshClearButton];
    if ([self.delegate respondsToSelector:@selector(memoryQueryArgumentCell:textViewDidChanged:)]) {
        [self.delegate memoryQueryArgumentCell:self textViewDidChanged:self.textView];
    }
}

- (void)detailButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(memoryQueryArgumentCellTypeButtonDidTouchUpInside:)]) {
        [self.delegate memoryQueryArgumentCellTypeButtonDidTouchUpInside:self];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(memoryQueryArgumentCell:textViewDidBeginEditing:)]) {
        [self.delegate memoryQueryArgumentCell:self textViewDidBeginEditing:self.textView];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self refreshClearButton];
    if ([self.delegate respondsToSelector:@selector(memoryQueryArgumentCell:textViewDidChanged:)]) {
        [self.delegate memoryQueryArgumentCell:self textViewDidChanged:self.textView];
    }
}

@end

@interface PDLMemoryQueryResultCell : UITableViewCell

@property (nonatomic, weak) UILabel *indexLabel;
@property (nonatomic, weak) UILabel *contentLabel;

@end

@implementation PDLMemoryQueryResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.contentView.bounds, 10, 0)];
        indexLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        indexLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:indexLabel];
        _indexLabel = indexLabel;

        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.contentView.frame.size.width - 50, self.contentView.frame.size.height)];
        contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:contentLabel];
        _contentLabel = contentLabel;
    }
    return self;
}

@end

@interface PDLMemoryQueryViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, PDLMemoryQueryArgumentCellDelegate>

@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIView *footerView;
@property (nonatomic, weak) UITextView *currentTextView;
@property (nonatomic, weak) UITextView *outputView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) NSMutableArray *arguments;

@property (nonatomic, strong) NSMutableArray *constantTitles;
@property (nonatomic, strong) NSMutableArray *constantActions;

@end

@implementation PDLMemoryQueryViewController

- (NSMutableArray *)constantTitles {
    if (!_constantTitles) {
        _constantTitles = [NSMutableArray array];
    }
    return _constantTitles;
}

- (NSMutableArray *)constantActions {
    if (!_constantActions) {
        _constantActions = [NSMutableArray array];
    }
    return _constantActions;
}

- (void)addConstantQueryWithTitle:(NSString *)title action:(void (^)(PDLMemoryQueryResult *))action {
    if (title && action) {
        [self.constantTitles addObject:title];
        [self.constantActions addObject:action];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Memory Query";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Execute" style:UIBarButtonItemStylePlain target:self action:@selector(executeQuery)];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, 200)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.containerView addSubview:headerView];
    self.headerView = headerView;

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(headerView.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [headerView addSubview:textView];
    self.outputView = textView;
    self.outputView.backgroundColor = [UIColor clearColor];
    self.outputView.editable = NO;

    CGFloat footerViewHeight = self.containerView.frame.size.height - headerView.frame.size.height;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.containerView.frame.size.height - footerViewHeight, self.containerView.frame.size.width, footerViewHeight)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView addSubview:footerView];
    self.footerView = footerView;

    UITableView *tableView = [[UITableView alloc] initWithFrame:footerView.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [footerView addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    [self.containerView addGestureRecognizer:tap];

    self.results = [NSMutableArray array];
    self.arguments = [NSMutableArray array];
    PDLMemoryQueryArgument *targetArgument = [[PDLMemoryQueryArgument alloc] init];
    [self.arguments addObject:targetArgument];
    PDLMemoryQueryArgument *selectorArgument = [[PDLMemoryQueryArgument alloc] init];
    selectorArgument.type = PDLMemoryQueryArgumentTypeSelector;
    [self.arguments addObject:selectorArgument];
}

- (void)layoutContainerView {
    [super layoutContainerView];

    self.headerView.pdl_height = self.containerView.pdl_height * 0.4;
    self.footerView.pdl_height = self.containerView.pdl_height * 0.6;
    self.footerView.pdl_top = self.headerView.pdl_bottom;
}

- (PDLMemoryQueryResult *)constantResult:(NSInteger)index {
    void (^action)(PDLMemoryQueryResult *result) = self.constantActions[index];
    PDLMemoryQueryResult *result = [[PDLMemoryQueryResult alloc] init];
    action(result);
    return result;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL ret = touch.view != self.outputView;
    return ret;
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    [self.currentTextView resignFirstResponder];
}

- (void)showString:(NSString *)string {
    self.outputView.text = string;
}

- (void)showResult:(PDLMemoryQueryResult *)result {
    NSString *resultString = [NSString stringWithFormat:@"%@", [result resultDescription]];
    [self showString:resultString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIButton *button = [[UIButton alloc] initWithFrame:view.bounds];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (section == 0) {
        [button setTitle:@"Arguments" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addArgument) forControlEvents:UIControlEventTouchUpInside];
    } else if (section == 1) {
        [button setTitle:@"Results" forState:UIControlStateNormal];
    } else {
        [button setTitle:@"Constants" forState:UIControlStateNormal];
    }
    [view addSubview:button];
    return view;
}

- (void)addArgument {
    [self hideKeyboard];
    PDLMemoryQueryArgument *argument = [[PDLMemoryQueryArgument alloc] init];
    [self.arguments addObject:argument];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.arguments.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.arguments.count;
    } else if (section == 1) {
        return self.results.count;
    } else {
        return self.constantTitles.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        PDLMemoryQueryResult *result = self.results[indexPath.row];
        [self showResult:result];
    } else if (indexPath.section == 2) {
        PDLMemoryQueryResult *result = [self constantResult:indexPath.row];
        [self showResult:result];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *argumentCell = @"argumentCell";
    static NSString *resultCell = @"resultCell";
    static NSString *constantCell = @"constantCell";
    if (indexPath.section == 0) {
       PDLMemoryQueryArgumentCell *cell = [tableView dequeueReusableCellWithIdentifier:argumentCell];
        if (cell == nil) {
            cell = [[PDLMemoryQueryArgumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:argumentCell];
            cell.delegate = self;
        }
        PDLMemoryQueryArgument *argument = self.arguments[indexPath.row];
        [cell.detailButton setTitle:[PDLMemoryQueryArgument stringOfArgumentType:argument.type] forState:UIControlStateNormal];
        cell.textView.text = argument.string;
        cell.tag = indexPath.row;
        cell.detailButton.userInteractionEnabled = YES;
        return cell;
    } else if (indexPath.section == 1) {
       PDLMemoryQueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:resultCell];
        if (cell == nil) {
            cell = [[PDLMemoryQueryResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resultCell];
        }
        PDLMemoryQueryResult *result = self.results[indexPath.row];
        cell.indexLabel.text = @(indexPath.row).stringValue;
        cell.contentLabel.text = [result resultDescription];
        cell.tag = indexPath.row;
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:constantCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:constantCell];
        }
        cell.textLabel.text = self.constantTitles[indexPath.row];
        cell.tag = indexPath.row;
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    if (indexPath.section == 0 && indexPath.row >= 2) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            [self.arguments removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else if (indexPath.section == 1) {
            [self.results removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSInteger i = 0; i < self.results.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
            [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PDLMemoryQueryArgumentCell *cell = (PDLMemoryQueryArgumentCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.detailButton.userInteractionEnabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PDLMemoryQueryArgumentCell *cell = (PDLMemoryQueryArgumentCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.detailButton.userInteractionEnabled = YES;
    }
}

#pragma mark - PDLMemoryQueryArgumentCellDelegate
- (void)memoryQueryArgumentCell:(PDLMemoryQueryArgumentCell *)memoryQueryArgumentCell textViewDidBeginEditing:(UITextView *)textView {
    self.currentTextView = textView;
}

- (void)memoryQueryArgumentCell:(PDLMemoryQueryArgumentCell *)memoryQueryArgumentCell textViewDidChanged:(UITextView *)textView {
    PDLMemoryQueryArgument *argument = self.arguments[memoryQueryArgumentCell.tag];
    argument.string = textView.text;
}

- (void)memoryQueryArgumentCellTypeButtonDidTouchUpInside:(PDLMemoryQueryArgumentCell *)memoryQueryArgumentCell {
    [self hideKeyboard];

    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *typeStrings = [PDLMemoryQueryArgument typeStrings];
    for (NSString *typeString in typeStrings) {
        [alertController addAction:[UIAlertAction actionWithTitle:typeString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger index = [typeStrings indexOfObject:action.title];
            PDLMemoryQueryArgument *argument = weakSelf.arguments[memoryQueryArgumentCell.tag];
            argument.type = index;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:memoryQueryArgumentCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)executeQuery {
    [self.view endEditing:YES];

    @try {
        PDLMemoryQueryResult *result = [self.class execute:[self.arguments copy]];
        [self showResult:result];
        if (result) {
            [self.results addObject:result];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.results.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    @catch (NSException *exception) {
        [self showString:exception.description];
    }
    @finally {
        ;
    }
}

+ (NSString *)parseErrorStringWithError:(PDLMemoryQueryArgumentParseError)error {
    NSDictionary *errorStrings = @{
                                   @(PDLMemoryQueryArgumentParseErrorNone) : @"success",
                                   @(PDLMemoryQueryArgumentParseErrorInvalidClass) : @"invalid class",
                                   @(PDLMemoryQueryArgumentParseErrorInvalidSelector) : @"invalid selector",
                                   @(PDLMemoryQueryArgumentParseErrorInvalidAddress) : @"invalid address",
                                   @(PDLMemoryQueryArgumentParseErrorInvalidArray) : @"invalid array",
                                   @(PDLMemoryQueryArgumentParseErrorInvalidDictionary) : @"invalid dictionary",
                                   };
    return errorStrings[@(error)];
}

+ (BOOL)isObjectAddressValid:(void *)objectAddress {
    if (objectAddress == NULL) {
        return YES;
    }

    void *header = NULL;
    size_t size = 0;
    if (!pdl_malloc_find(objectAddress, &size, &header)) {
        return NO;
    }

    if (size == 0) {
        return NO;
    }

    return YES;
}

+ (id)parseObjectByArgument:(PDLMemoryQueryArgument *)argument error:(PDLMemoryQueryArgumentParseError *)error {
    id object = nil;
    PDLMemoryQueryArgumentParseError parseError = PDLMemoryQueryArgumentParseErrorNone;
    do {
        NSString *objectString = argument.string;
        if (objectString.length == 0) {
            break;
        }

        switch (argument.type) {
            case PDLMemoryQueryArgumentTypeClass: {
                object = NSClassFromString(objectString);
                if (object == nil) {
                    parseError = PDLMemoryQueryArgumentParseErrorInvalidClass;
                }
            } break;
            case PDLMemoryQueryArgumentTypeSelector: {
                SEL selector = NSSelectorFromString(objectString);
                object = NSStringFromSelector(selector);
                if (object == nil) {
                    parseError = PDLMemoryQueryArgumentParseErrorInvalidSelector;
                }
            } break;
            case PDLMemoryQueryArgumentTypeNSObject: {
                NSInteger addressInteger = strtol(objectString.UTF8String, NULL, 16);
                void *addressVoidPointer = (void *)addressInteger;
                if ([self isObjectAddressValid:addressVoidPointer]) {
                    object = (__bridge id)(addressVoidPointer);
                } else {
                    parseError = PDLMemoryQueryArgumentParseErrorInvalidAddress;
                }
            } break;
            case PDLMemoryQueryArgumentTypeNSString: {
                object = objectString;
            } break;
            case PDLMemoryQueryArgumentTypeNSArray: {
                NSData *data = [objectString dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                if ([array isKindOfClass:[NSArray class]]) {
                    object = [NSArray arrayWithArray:array];
                } else {
                    parseError = PDLMemoryQueryArgumentParseErrorInvalidArray;
                }
            } break;
            case PDLMemoryQueryArgumentTypeNSDictionary: {
                NSData *data = [objectString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                if ([dictionary isKindOfClass:[NSDictionary class]]) {
                    object = [NSDictionary dictionaryWithDictionary:dictionary];
                } else {
                    parseError = PDLMemoryQueryArgumentParseErrorInvalidDictionary;
                }
            } break;
            case PDLMemoryQueryArgumentTypeNSInteger:
            case PDLMemoryQueryArgumentTypeNSIntegerNumber: {
                long long number = strtoll(objectString.UTF8String, NULL, 0);
                object = @(number);
            } break;
            case PDLMemoryQueryArgumentTypeDouble:
            case PDLMemoryQueryArgumentTypeDoubleNumber: {
                double number = strtod(objectString.UTF8String, NULL);
                object = @(number);
            } break;
            case PDLMemoryQueryArgumentTypeBool:
            case PDLMemoryQueryArgumentTypeBoolNumber: {
                object = @(objectString.boolValue);
            } break;
            default:
                break;
        }
    } while (NO);

    if (error) {
        *error = parseError;
    }

    return object;
}

+ (PDLMemoryQueryResultType)resultTypeByConvertingArgumentType:(PDLMemoryQueryArgumentType)argumentType {
    PDLMemoryQueryResultType resultType;
    switch (argumentType) {
        case PDLMemoryQueryArgumentTypeClass:
            resultType = PDLMemoryQueryResultTypeClass;
            break;
        case PDLMemoryQueryArgumentTypeSelector:
            resultType = PDLMemoryQueryResultTypeSelector;
            break;
        case PDLMemoryQueryArgumentTypeNSObject:
        case PDLMemoryQueryArgumentTypeNSString:
        case PDLMemoryQueryArgumentTypeNSArray:
        case PDLMemoryQueryArgumentTypeNSDictionary:
        case PDLMemoryQueryArgumentTypeNSIntegerNumber:
        case PDLMemoryQueryArgumentTypeDoubleNumber:
        case PDLMemoryQueryArgumentTypeBoolNumber:
            resultType = PDLMemoryQueryResultTypeNSObject;
            break;
        case PDLMemoryQueryArgumentTypeNSInteger:
            resultType = PDLMemoryQueryResultTypeLongLong;
            break;
        case PDLMemoryQueryArgumentTypeDouble:
            resultType = PDLMemoryQueryResultTypeDouble;
            break;
        case PDLMemoryQueryArgumentTypeBool:
            resultType = PDLMemoryQueryResultTypeBool;
            break;
        default:
            resultType = PDLMemoryQueryResultTypeNSObject;
            break;
    }
    return resultType;
}

+ (PDLMemoryQueryResult *)execute:(NSArray *)arguments {
    PDLMemoryQueryArgument *targetArgument = arguments[0];
    PDLMemoryQueryArgument *selectorArgument = arguments[1];

    PDLMemoryQueryResult *result = [[PDLMemoryQueryResult alloc] init];
    if (selectorArgument.type != PDLMemoryQueryArgumentTypeSelector) {
        result.type = PDLMemoryQueryResultTypeError;
        result.result = @"argument 2 must be \"Selector\"";
        return result;
    }

    PDLMemoryQueryArgumentParseError parseError = PDLMemoryQueryArgumentParseErrorNone;
    id target = [self parseObjectByArgument:targetArgument error:&parseError];
    if (parseError != PDLMemoryQueryArgumentParseErrorNone) {
        result.type = PDLMemoryQueryResultTypeError;
        NSString *parseErrorString = [self parseErrorStringWithError:parseError];
        result.result = [NSString stringWithFormat:@"parse target error: %@", parseErrorString];
        return result;
    }

    NSString *selectorString = selectorArgument.string;
    if (selectorString.length == 0) {
        result.type = [self resultTypeByConvertingArgumentType:targetArgument.type];
        result.result = target;
        return result;
    }

    SEL selector = NSSelectorFromString(selectorString);
    if (selector == nil) {
        result.type = PDLMemoryQueryResultTypeError;
        result.result = @"selector is NULL";
        return result;
    }

    if (![target respondsToSelector:selector]) {
        result.type = PDLMemoryQueryResultTypeError;
        result.result = @"target does not respond to selector";
        return result;
    }

    NSInteger argumentsCount = arguments.count - 2;
    void **args = NULL;
    if (argumentsCount > 0) {
        args = malloc(sizeof(void *) * argumentsCount);
    }
    NSMutableArray *memoryArray = [NSMutableArray array];

    NSString *argumentsErrorString = nil;
    for (NSInteger i = 0; i < argumentsCount; i++) {
        PDLMemoryQueryArgument *argument = arguments[i + 2];
        id argumentObject = [self parseObjectByArgument:argument error:&parseError];
        if (parseError != PDLMemoryQueryArgumentParseErrorNone) {
            NSString *parseErrorString = [self parseErrorStringWithError:parseError];
            argumentsErrorString = [NSString stringWithFormat:@"parse argument %@ error: %@", @(i + 1), parseErrorString];
            break;
        }

        void **parg = NULL;
        switch (argument.type) {
            case PDLMemoryQueryArgumentTypeClass: {
                void *arg = (__bridge void *)argumentObject;
                if (argumentObject) {
                    [memoryArray addObject:argumentObject];
                }
                parg = (void **)malloc(sizeof(arg));
                *parg = arg;
            } break;
            case PDLMemoryQueryArgumentTypeSelector: {
                SEL selector = NSSelectorFromString(argumentObject);
                void *arg = selector;
                parg = (void **)malloc(sizeof(arg));
                *parg = arg;
            } break;
            case PDLMemoryQueryArgumentTypeNSObject:
            case PDLMemoryQueryArgumentTypeNSString:
            case PDLMemoryQueryArgumentTypeNSArray:
            case PDLMemoryQueryArgumentTypeNSDictionary:
            case PDLMemoryQueryArgumentTypeNSIntegerNumber:
            case PDLMemoryQueryArgumentTypeDoubleNumber:
            case PDLMemoryQueryArgumentTypeBoolNumber: {
                void *arg = (__bridge void *)argumentObject;
                if (argumentObject) {
                    [memoryArray addObject:argumentObject];
                }
                parg = (void **)malloc(sizeof(arg));
                *parg = arg;
            } break;
            case PDLMemoryQueryArgumentTypeNSInteger: {
                NSInteger number = [argumentObject integerValue];
                NSInteger arg = number;
                parg = (void **)malloc(sizeof(arg));
                *(NSInteger *)parg = arg;
            } break;
            case PDLMemoryQueryArgumentTypeDouble: {
                double number = [argumentObject doubleValue];
                double arg = number;
                parg = (void **)malloc(sizeof(arg));
                *(double *)parg = arg;
            } break;
            case PDLMemoryQueryArgumentTypeBool: {
                BOOL number = [argumentObject boolValue];
                BOOL arg = number;
                parg = (void **)malloc(sizeof(arg));
                *(BOOL *)parg = arg;
            } break;
            default:
                break;
        }
        args[i] = parg;
    }

    if (argumentsErrorString) {
        free(args);
        result.type = PDLMemoryQueryResultTypeError;
        result.result = argumentsErrorString;
        return result;
    }

    const char *returnType = NULL;
    void **returnValue = NULL;
    NSUInteger returnLength = 0;

    BOOL ret = [self invokeWithTarget:target selector:selector arguments:args argumentCount:argumentsCount returnType:&returnType returnValue:&returnValue returnLength:&returnLength];
    if (ret == NO) {
        free(args);
        result.type = PDLMemoryQueryResultTypeError;
        result.result = @"invokeWithTarget returns NO";
        return result;
    }

    for (NSInteger i = 0; i < argumentsCount; i++) {
        void *arg = args[i];
        free(arg);
    }
    free(args);

    NSString *onewayVoidTypeEncoding = @"Vv";
    NSString *pointerTypeEncoding = @"^"; // NSObjCPointerType

    if (returnType) {
        NSString *returnTypeString = @(returnType);
        if ([returnTypeString hasPrefix:@(@encode(id))]) {
            if ([returnTypeString isEqualToString:@(@encode(dispatch_block_t))]) {
                result.type = PDLMemoryQueryResultTypeBlock;
            } else {
                result.type = PDLMemoryQueryResultTypeNSObject;
            }
            result.result = (__bridge id)(*returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(Class))]) {
            result.type = PDLMemoryQueryResultTypeClass;
            result.result = (__bridge id)(*returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(SEL))]) {
            result.type = PDLMemoryQueryResultTypeSelector;
            result.result = NSStringFromSelector(*(SEL *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(void))] || [returnTypeString isEqualToString:onewayVoidTypeEncoding]) {
            result.type = PDLMemoryQueryResultTypeVoid;
            result.result = nil;
        } else if ([returnTypeString isEqualToString:@(@encode(char))]) {
            result.type = PDLMemoryQueryResultTypeChar;
            result.result = @(*(char *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(short))]) {
            result.type = PDLMemoryQueryResultTypeShort;
            result.result = @(*(short *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(int))]) {
            result.type = PDLMemoryQueryResultTypeInt;
            result.result = @(*(int *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(long))]) {
            result.type = PDLMemoryQueryResultTypeLong;
            result.result = @(*(long *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(long long))]) {
            result.type = PDLMemoryQueryResultTypeLongLong;
            result.result = @(*(long long *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(unsigned char))]) {
            result.type = PDLMemoryQueryResultTypeUnsignedChar;
            result.result = @(*(unsigned char *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(unsigned short))]) {
            result.type = PDLMemoryQueryResultTypeUnsignedShort;
            result.result = @(*(unsigned short *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(unsigned int))]) {
            result.type = PDLMemoryQueryResultTypeUnsignedInt;
            result.result = @(*(unsigned int *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(unsigned long))]) {
            result.type = PDLMemoryQueryResultTypeUnsignedLong;
            result.result = @(*(unsigned long *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(unsigned long long))]) {
            result.type = PDLMemoryQueryResultTypeUnsignedLongLong;
            result.result = @(*(unsigned long long *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(float))]) {
            result.type = PDLMemoryQueryResultTypeFloat;
            result.result = @(*(float *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(double))]) {
            result.type = PDLMemoryQueryResultTypeDouble;
            result.result = @(*(double *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(BOOL))]) {
            result.type = PDLMemoryQueryResultTypeBool;
            result.result = @(*(BOOL *)returnValue);
        } else if ([returnTypeString hasPrefix:pointerTypeEncoding]) {
            if ([returnTypeString isEqualToString:@(@encode(IMP))]) {
                result.type = PDLMemoryQueryResultTypeFunctionPointer;
            } else {
                result.type = PDLMemoryQueryResultTypePointer;
            }
            void *pointer = *(void **)returnValue;
            result.result = @((long)pointer);
        } else if ([returnTypeString isEqualToString:@(@encode(char *))]) {
            result.type = PDLMemoryQueryResultTypeCString;
            char *cstring = *(char **)returnValue;
            result.result = @((long)cstring);
        } else if ([returnTypeString isEqualToString:@(@encode(CGPoint))]) {
            result.type = PDLMemoryQueryResultTypeCGPoint;
            result.result = @(*(CGPoint *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(CGSize))]) {
            result.type = PDLMemoryQueryResultTypeCGSize;
            result.result = @(*(CGSize *)returnValue);
        } else if ([returnTypeString isEqualToString:@(@encode(CGRect))]) {
            result.type = PDLMemoryQueryResultTypeCGRect;
            result.result = @(*(CGRect *)returnValue);
        } else {
            result.type = PDLMemoryQueryResultTypeUnknown;
            if (returnLength > 0) {
                NSData *data = [NSData dataWithBytes:returnValue length:returnLength];
                result.result = [NSString stringWithFormat:@"Unknown type: %@, length: %@, data: %@ ", returnTypeString, @(returnLength), data.description];
            } else {
                result.result = returnTypeString;
            }
        }
    }

    free(returnValue);

    return result;
}

+ (BOOL)invokeWithTarget:(id)target selector:(SEL)selector arguments:(void *[])arguments argumentCount:(NSInteger)argumentCount returnType:(const char **)returnType returnValue:(void ***)returnValue returnLength:(NSUInteger *)returnLength {
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
    if (methodSignature == nil) {
        return NO;
    }
    NSUInteger numberOfArguments = [methodSignature numberOfArguments];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    if (numberOfArguments != argumentCount + 2) {
        return NO;
    }

    for (NSInteger i = 0; i < argumentCount; i++) {
        void *argument = arguments[i];
        [invocation setArgument:argument atIndex:i + 2];
    }

    [invocation retainArguments];
    [invocation invoke];

    NSUInteger length = [[invocation methodSignature] methodReturnLength];
    const char *invocationReturnType = [[invocation methodSignature] methodReturnType];
    if (returnType) {
        *returnType = invocationReturnType;
    }
    if (returnLength) {
        *returnLength = length;
    }

    if (length > 0) {
        void **invocationReturnValue = NULL;
        if (returnValue) {
            invocationReturnValue = malloc(length);
            [invocation getReturnValue:invocationReturnValue];
            *returnValue = invocationReturnValue;
        }
    }
    return YES;
}

@end
