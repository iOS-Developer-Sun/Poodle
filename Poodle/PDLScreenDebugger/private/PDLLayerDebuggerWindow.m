//
//  PDLLayerDebuggerWindow.m
//  Poodle
//
//  Created by Poodle on 15/10/2016.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import "PDLLayerDebuggerWindow.h"
#import "PDLScreenDebugger.h"
#import "PDLRectPropertyDebugger.h"
#import "PDLFloatPropertyDebugger.h"
#import "PDLColorPropertyDebugger.h"
#import "PDLBoolPropertyDebugger.h"

@interface PDLLayerDebuggerLayerDetail : NSObject

@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, assign) NSInteger indentationLevel;

@end

@implementation PDLLayerDebuggerLayerDetail

@end

@interface PDLLayerDebuggerWindow () <UITableViewDataSource, UITableViewDelegate, PropertyDebuggerViewDelegate>

@property (nonatomic, weak) UIControl *selectedIndicatorView;
@property (nonatomic, weak) UIView *framesView;

@property (nonatomic, weak) UITableView *detailTableView;
@property (nonatomic, weak) UILabel *detailPointLabel;

@property (nonatomic, weak) CALayer *currentLayer;
@property (nonatomic, copy) NSArray *currentAscendants;
@property (nonatomic, copy) NSArray *layersContainsPoint;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, weak) PDLPropertyDebuggerView *propertyDebuggerView;

@end

@implementation PDLLayerDebuggerWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.arrow.backgroundColor = [UIColor blueColor];

        UIControl *selectedIndicatorView = [[UIControl alloc] init];
        selectedIndicatorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3];
        selectedIndicatorView.hidden = YES;
        selectedIndicatorView.userInteractionEnabled = NO;
        [selectedIndicatorView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectedIndicator:)]];
        [self.contentView addSubview:selectedIndicatorView];
        _selectedIndicatorView = selectedIndicatorView;

        UIView *framesView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        framesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        framesView.backgroundColor = [UIColor clearColor];
        framesView.userInteractionEnabled = NO;
        [self.contentView addSubview:framesView];
        _framesView = framesView;

        UITableView *detailTableView = [[UITableView alloc] initWithFrame:self.detailView.bounds style:UITableViewStyleGrouped];
        detailTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        detailTableView.backgroundColor = [UIColor clearColor];
        detailTableView.dataSource = self;
        detailTableView.delegate = self;
        [self.detailView addSubview:detailTableView];
        _detailTableView = detailTableView;

        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, detailTableView.bounds.size.width, 30)];
        UILabel *detailPointLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 20, 0)];
        detailPointLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        detailPointLabel.textColor = [UIColor whiteColor];
        detailPointLabel.font = [UIFont systemFontOfSize:17];
        [headerView addSubview:detailPointLabel];
        detailTableView.tableHeaderView = headerView;
        _detailPointLabel = detailPointLabel;

        [self.contentView bringSubviewToFront:self.detailView];

        UIView *view = self.rootViewController.view;
        PDLPropertyDebuggerView *propertyDebuggerView = [[PDLPropertyDebuggerView alloc] initWithFrame:view.bounds];
        propertyDebuggerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        propertyDebuggerView.hidden = YES;
        propertyDebuggerView.delegate = self;
        [view addSubview:propertyDebuggerView];
        _propertyDebuggerView = propertyDebuggerView;

        PDLRectPropertyDebugger *framePropertyDebugger = [[PDLRectPropertyDebugger alloc] init];
        framePropertyDebugger.keyPath = @"frame";

        PDLFloatPropertyDebugger *alphaPropertyDebugger = [[PDLFloatPropertyDebugger alloc] init];
        alphaPropertyDebugger.keyPath = @"opacity";
        alphaPropertyDebugger.minimumValue = 0;
        alphaPropertyDebugger.maximumValue = 1;

        PDLColorPropertyDebugger *backgroundColorPropertyDebugger = [[PDLColorPropertyDebugger alloc] init];
        backgroundColorPropertyDebugger.keyPath = @"backgroundColor";
        backgroundColorPropertyDebugger.getter = ^id(PDLPropertyDebugger *PDLPropertyDebugger) {
            CALayer *layer = PDLPropertyDebugger.object;
            UIColor *color = [UIColor colorWithCGColor:layer.backgroundColor];
            return color;
        };
        backgroundColorPropertyDebugger.setter = ^(PDLPropertyDebugger *PDLPropertyDebugger, id value) {
            CALayer *layer = PDLPropertyDebugger.object;
            UIColor *color = value;
            layer.backgroundColor = color.CGColor;
        };

        PDLBoolPropertyDebugger *hiddenPropertyDebugger = [[PDLBoolPropertyDebugger alloc] init];
        hiddenPropertyDebugger.keyPath = @"hidden";

        propertyDebuggerView.propertyDebuggers = @[framePropertyDebugger, alphaPropertyDebugger, backgroundColorPropertyDebugger, hiddenPropertyDebugger];

    }
    return self;
}

- (void)dealloc {
    _detailTableView.dataSource = nil;
    _detailTableView.delegate = nil;
}

- (void)setDebuggingLayer:(CALayer *)debuggingLayer {
    _debuggingLayer = debuggingLayer;
    CALayer *layer = debuggingLayer;
    UIView *view = nil;
    while (layer.superlayer) {
        if ([layer.delegate isKindOfClass:[UIView class]]) {
            view = (typeof(view))layer.delegate;
            break;
        }
        layer = layer.superlayer;
    }
    UIWindow *window = view.window;
    if ([view isKindOfClass:[UIWindow class]]) {
        window = (typeof(window))view;
    }
    self.windowLevel = window.windowLevel + 1;
}

- (void)setCurrentLayer:(CALayer *)currentLayer {
    _currentLayer = currentLayer;

    NSMutableArray *layerDetails = [NSMutableArray array];
    CALayer *layer = currentLayer;
    while (layer) {
        PDLLayerDebuggerLayerDetail *layerDetail = [[PDLLayerDebuggerLayerDetail alloc] init];
        layerDetail.layer = layer;
        [layerDetails addObject:layerDetail];
        layer = layer.superlayer;
    }
    for (NSInteger i = 0; i < layerDetails.count; i++) {
        PDLLayerDebuggerLayerDetail *layerDetail = layerDetails[i];
        layerDetail.indentationLevel = layerDetails.count - 1 - i;
    }
    self.currentAscendants = layerDetails;
}

- (void)tapSelectedIndicator:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.contentView.hidden = YES;
    self.componentsView.hidden = YES;
    self.propertyDebuggerView.hidden = NO;
}

- (void)updatePointLabel:(CGPoint)point {
    self.detailPointLabel.text = [NSString stringWithFormat:@"Point: %.3f, %.3f", point.x, point.y];
}

+ (CGPoint)convertPoint:(CGPoint)point fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer {
    CALayer *fromSuper = fromLayer;
    while (fromSuper) {
        CALayer *layer = fromSuper.superlayer;
        if (layer) {
            fromSuper = layer;
        } else {
            break;
        }
    }
    CALayer *toSuper = toLayer;
    while (toSuper) {
        CALayer *layer = toSuper.superlayer;
        if (layer) {
            toSuper = layer;
        } else {
            break;
        }
    }

    CALayer *fromWindow = (CALayer *)fromSuper;
    CALayer *toWindow = (CALayer *)toSuper;

    if (fromWindow == nil && toWindow == nil) {
        return point;
    }

    if (fromWindow == toWindow) {
        CGPoint convertedPoint = [toLayer convertPoint:point fromLayer:fromLayer];
        return convertedPoint;
    }

    CGPoint fromWindowPoint = point;
    if (fromWindow != nil) {
        fromWindowPoint = [fromWindow convertPoint:point fromLayer:fromLayer];
    }

    CGPoint toWindowPoint = fromWindowPoint;
    if (toWindow != nil) {
        toWindowPoint = [toWindow convertPoint:fromWindowPoint fromLayer:fromWindow];
    } else {
        if (fromWindow != nil) {
            toWindowPoint = [fromWindow convertPoint:fromWindowPoint toLayer:toWindow];
        }
    }

    CGPoint toViewPoint = toWindowPoint;
    if (toWindow != nil) {
        toViewPoint = [toWindow convertPoint:toWindowPoint toLayer:toLayer];
    }

    return toViewPoint;
}

+ (CGRect)convertRect:(CGRect)rect fromLayer:(CALayer *)fromLayer toLayer:(CALayer *)toLayer {
    CALayer *fromSuper = fromLayer;
    while (fromSuper) {
        CALayer *layer = fromSuper.superlayer;
        if (layer) {
            fromSuper = layer;
        } else {
            break;
        }
    }
    CALayer *toSuper = toLayer;
    while (toSuper) {
        CALayer *layer = toSuper.superlayer;
        if (layer) {
            toSuper = layer;
        } else {
            break;
        }
    }

    CALayer *fromWindow = (CALayer *)fromSuper;
    CALayer *toWindow = (CALayer *)toSuper;

    if (fromWindow == nil && toWindow == nil) {
        return rect;
    }

    if (fromWindow == toWindow) {
        CGRect convertedRect = [toLayer convertRect:rect fromLayer:fromLayer];
        return convertedRect;
    }

    CGRect fromWindowRect = rect;
    if (fromWindow != nil) {
        fromWindowRect = [fromWindow convertRect:rect fromLayer:fromLayer];
    }

    CGRect toWindowRect = fromWindowRect;
    if (toWindow != nil) {
        toWindowRect = [toWindow convertRect:fromWindowRect fromLayer:fromWindow];
    } else {
        if (fromWindow != nil) {
            toWindowRect = [fromWindow convertRect:fromWindowRect toLayer:toWindow];
        }
    }

    CGRect toViewRect = toWindowRect;
    if (toWindow != nil) {
        toViewRect = [toWindow convertRect:toWindowRect toLayer:toLayer];
    }

    return toViewRect;
}

- (void)updateLayersContainsPoint:(CGPoint)point {
    NSMutableArray *stack = [NSMutableArray array];
    CALayer *layer = self.debuggingLayer;
    if (layer) {
        CGPoint pointInLayer = [self.class convertPoint:point fromLayer:self.arrow.superview.layer toLayer:layer];
        if (CGRectContainsPoint(layer.bounds, pointInLayer)) {
            PDLLayerDebuggerLayerDetail *layerDetail = [[PDLLayerDebuggerLayerDetail alloc] init];
            layerDetail.layer = layer;
            layerDetail.indentationLevel = 0;
            [stack addObject:layerDetail];
        }
    }

    NSMutableArray *layerDetails = [NSMutableArray array];
    while (stack.count > 0) {
        PDLLayerDebuggerLayerDetail *layerDetail = stack.lastObject;
        [stack removeLastObject];
        [layerDetails addObject:layerDetail];

        NSInteger count = layerDetail.layer.sublayers.count;
        for (NSInteger i = 0; i < count; i++) {
            CALayer *sublayer = layerDetail.layer.sublayers[count - 1 - i];
            CGPoint pointInLayer = [self.class convertPoint:point fromLayer:self.arrow.superview.layer toLayer:sublayer];
            if ([sublayer.delegate isKindOfClass:NSClassFromString(@"UITableViewWrapperView")] || CGRectContainsPoint(sublayer.bounds, pointInLayer)) {
                PDLLayerDebuggerLayerDetail *sublayerDetail = [[PDLLayerDebuggerLayerDetail alloc] init];
                sublayerDetail.layer = sublayer;
                sublayerDetail.indentationLevel = layerDetail.indentationLevel + 1;
                [stack addObject:sublayerDetail];
            }
        }
    }

    NSMutableArray *inverseLayerDetails = [NSMutableArray array];
    for (PDLLayerDebuggerLayerDetail *layerDetail in layerDetails) {
        [inverseLayerDetails insertObject:layerDetail atIndex:0];
    }

    self.layersContainsPoint = inverseLayerDetails;

    [self updateFramesView];
}

- (void)updateFramesView {
    for (UIView *view in self.framesView.subviews) {
        [view removeFromSuperview];
    }

    for (PDLLayerDebuggerLayerDetail *layerDetail in self.layersContainsPoint) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor clearColor];
        v.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        v.layer.borderColor = [UIColor blackColor].CGColor;
        [self.framesView addSubview:v];
        CALayer *layer = layerDetail.layer;
        CGRect frame = [self.class convertRect:layer.bounds fromLayer:layer toLayer:v.superview.layer];
        v.frame = frame;
        v.layer.cornerRadius = (v.frame.size.width < v.frame.size.height ? v.frame.size.width : v.frame.size.height) / 16;
    }
}

- (void)updateSelected {
    CALayer *selectedLayer = nil;
    if (self.selectedIndexPath) {
        selectedLayer = [self layerDetailAtIndexPath:self.selectedIndexPath].layer;
        self.framesView.hidden = YES;
        self.arrow.hidden = YES;
        self.selectedIndicatorView.userInteractionEnabled = YES;
    } else {
        selectedLayer = self.currentLayer;
        self.framesView.hidden = NO;
        self.arrow.hidden = NO;
        self.selectedIndicatorView.userInteractionEnabled = NO;
    }
    self.propertyDebuggerView.object = selectedLayer;
    CGRect frame = [self.class convertRect:selectedLayer.bounds fromLayer:selectedLayer toLayer:self.selectedIndicatorView.superview.layer];
    self.selectedIndicatorView.frame = frame;
    self.selectedIndicatorView.hidden = NO;
}

- (void)debugPoint {
    [super debugPoint];

    CGPoint point = self.currentPoint;
    CGPoint debuggingLayerPoint = [self.class convertPoint:point fromLayer:self.arrow.superview.layer toLayer:self.debuggingLayer];
    CALayer *layer = [self.debuggingLayer hitTest:debuggingLayerPoint];
    self.currentLayer = layer;

    self.selectedIndexPath = nil;

    [self updatePointLabel:point];
    [self updateLayersContainsPoint:point];
    [self updateSelected];
    [self.detailTableView reloadData];

    self.detailView.hidden = NO;
    self.contentView.hidden = NO;
    self.componentsView.hidden = NO;
    self.propertyDebuggerView.hidden = YES;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = (UITableViewCell *)longPressGestureRecognizer.view;
        NSIndexPath *indexPath = [self.detailTableView indexPathForCell:cell];
        if (indexPath == nil) {
            return;
        }

        CALayer *layer = [self layerDetailAtIndexPath:indexPath].layer;
        __weak __typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Copy object address" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf copyToPasteboard:[NSString stringWithFormat:@"%p", layer]];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Copy description" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf copyToPasteboard:cell.textLabel.text];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self.rootViewController presentViewController:alertController animated:YES completion:nil];
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        ;
    } else if(longPressGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        ;
    }
}

- (void)copyToPasteboard:(NSString *)string {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = string;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Copied" message:string preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)layerDescription:(CALayer *)layer {
    NSString *description = nil;
    if ([layer respondsToSelector:@selector(pdl_screenDebuggerDescription)]) {
        description = [(id <PDLScreenDebuggerDescription>)layer pdl_screenDebuggerDescription];
        return description;
    }

    description = layer.description;
    if ([description hasSuffix:@">"]) {
        return [NSString stringWithFormat:@"%@; delegate = %@%@", [description substringToIndex:description.length - 1], layer.delegate, [description substringFromIndex:description.length - 1]];
    }

    return [description stringByAppendingFormat:@" delegate: %@", layer.delegate];
}

- (PDLLayerDebuggerLayerDetail *)layerDetailAtIndexPath:(NSIndexPath *)indexPath {
    PDLLayerDebuggerLayerDetail *layerDetail = nil;
    if (indexPath.section == 0) {
        layerDetail = self.currentAscendants[indexPath.row];
    } else {
        layerDetail = self.layersContainsPoint[indexPath.row];
    }
    return layerDetail;
}

- (void)closeButtonDidTouchUpInside:(PDLPropertyDebuggerView *)propertyDebuggerView {
    self.contentView.hidden = NO;
    self.componentsView.hidden = NO;
    self.propertyDebuggerView.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = UITableViewAutomaticDimension;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 50;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *reusedIdentifier = @"";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reusedIdentifier];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:reusedIdentifier];
        UILabel *label = [[UILabel alloc] initWithFrame:header.contentView.bounds];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:17];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [header.contentView addSubview:label];
        label.tag = 1;
    }
    UILabel *label = [header.contentView viewWithTag:1];
    if (section == 0) {
        label.text = @"Hit test layer and superlayers:";
    } else {
        label.text = @"Layers of point:";
    }
    return header;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    UILabel *label = [header.contentView viewWithTag:1];
    label.frame = CGRectInset(header.contentView.bounds, 20, 0);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self layerDetailAtIndexPath:indexPath].indentationLevel;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedIdentifier = @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;
        cell.backgroundColor = [UIColor clearColor];
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [cell addGestureRecognizer:longPressGestureRecognizer];
    }
    CALayer *layer = [self layerDetailAtIndexPath:indexPath].layer;
    cell.textLabel.text = [self layerDescription:layer];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.currentAscendants.count;
    } else {
        return self.layersContainsPoint.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath == nil || self.selectedIndexPath.section != indexPath.section || self.selectedIndexPath.row != indexPath.row) {
        self.selectedIndexPath = indexPath;
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.selectedIndexPath = nil;
    }
    [self updateSelected];
}

@end
