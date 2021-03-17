//
//  PDLDirectoryViewController.m
//  Poodle
//
//  Created by Poodle on 09/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLDirectoryViewController.h"
#import <dlfcn.h>
#import <AVKit/AVKit.h>
#import "PDLDirectoryViewControllerResources.h"
#import "PDLTextViewController.h"
#import "PDLPropertyListViewController.h"
#import "PDLDatabaseViewController.h"
#import "PDLWebViewController.h"
#import "PDLCrashViewController.h"
#import "PDLColor.h"

static NSString *PDLDirectoryViewControllerSizeStringOfBytes(uint64_t bytes) {
    double gigaBytes = bytes / 1024.0 / 1024.0 / 1024.0;
    if (gigaBytes >= 1) {
        return [NSString stringWithFormat:@"%.2fG", gigaBytes];
    }

    double megaBytes = bytes / 1024.0 / 1024.0;
    if (megaBytes >= 1) {
        return [NSString stringWithFormat:@"%.2fM", megaBytes];
    }

    double kiloBytes = bytes / 1024.0;
    if (kiloBytes >= 1) {
        return [NSString stringWithFormat:@"%.2fK", kiloBytes];
    }

    return [NSString stringWithFormat:@"%@B", @(bytes)];
}

static uint64_t PDLDirectoryViewControllerFileSizeAtPath(NSString *filePath) {
    uint64_t totalFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    NSArray *subpaths = nil;
    @autoreleasepool {
        subpaths = [[NSFileManager defaultManager] subpathsAtPath:filePath];
    }
    for (NSString *subpath in subpaths) {
        NSString *subFilePath = [filePath stringByAppendingPathComponent:subpath];
        uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:subFilePath error:nil] fileSize];
        totalFileSize += fileSize;
    }

    return totalFileSize;
}

static UIImage *PDLDirectoryViewControllerAspectFitImageWithImageAndSize(UIImage *image, CGSize size) {
    if (image == nil) {
        return nil;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
    CGFloat ratio = MAX(scaledImage.size.width / size.width, scaledImage.size.height / size.height);
    CGSize newSize = CGSizeMake(scaledImage.size.width / ratio, scaledImage.size.height / ratio);

    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [scaledImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}

static UIImage *PDLDirectoryViewControllerImageWithColorAndSize(UIColor *color, CGSize size) {
    if (!color || size.width <= 0 || size.height <= 0) {
        return nil;
    }
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static UIImage *PDLDirectoryViewControllerCheckboxImage(void) {
    static __weak UIImage *_checkboxImage = nil;
    UIImage *image = _checkboxImage;
    if (image == nil) {
        NSData *data = [[NSData alloc] initWithBytes:PDLDirectoryViewControllerCheckboxImageData length:PDLDirectoryViewControllerCheckboxImageDataLength];
        image = [UIImage imageWithData:data];
        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
        _checkboxImage = image;
    }
    return image;
}

static UIImage *PDLDirectoryViewControllerCheckboxHighlightedImage(void) {
    static __weak UIImage *_checkboxHighlightedImage = nil;
    UIImage *image = _checkboxHighlightedImage;
    if (image == nil) {
        NSData *data = [[NSData alloc] initWithBytes:PDLDirectoryViewControllerCheckboxHighlightedImageData length:PDLDirectoryViewControllerCheckboxHighlightedImageDataLength];
        image = [UIImage imageWithData:data];
        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
        _checkboxHighlightedImage = image;
    }
    return image;
}

typedef NS_ENUM(NSInteger, PDLDirectoryContentType) {
    PDLDirectoryContentTypeUnknown = -1,
    PDLDirectoryContentTypeDirectory,
    PDLDirectoryContentTypeText,
    PDLDirectoryContentTypeImage,
    PDLDirectoryContentTypeAudio,
    PDLDirectoryContentTypeVideo,
    PDLDirectoryContentTypeDatabase,
    PDLDirectoryContentTypePropertyList,
    PDLDirectoryContentTypeWebPage,
    PDLDirectoryContentTypeDynamicLibrary,
    PDLDirectoryContentTypeCrash,
    PDLDirectoryContentTypeOther,

    PDLDirectoryContentTypeCount,
};

@interface PDLDirectoryContent : NSObject

@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) BOOL isDirectory;
@property (nonatomic, readonly) uint64_t size;
@property (nonatomic, readonly) BOOL hasFinishCalculatingSize;
@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readonly) NSString *extension;
@property (nonatomic, readonly) PDLDirectoryContentType type;
@property (nonatomic, copy) void (^sizeCalculatingCompletion)(PDLDirectoryContent *content);

- (instancetype)initWithFilePath:(NSString *)filePath;

@end

@interface PDLDirectoryContent ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) BOOL hasFinishCalculatingSize;

@property (readonly) NSString *contentDescription;

@end

@implementation PDLDirectoryContent

+ (dispatch_queue_t)sizeCalculatingQueue {
    static dispatch_queue_t sizeCalculatingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizeCalculatingQueue =  dispatch_queue_create("PDLDirectoryContentSizeCalculatingQueue", NULL);
    });
    return sizeCalculatingQueue;
}

+ (PDLDirectoryContentType)contentTypeOfFilePath:(NSString *)filePath {
    PDLDirectoryContentType type = PDLDirectoryContentTypeUnknown;
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    NSString *extension = [filePath pathExtension];
    if (isDirectory) {
        type = PDLDirectoryContentTypeDirectory;
    } else {
        NSDictionary *typeMap = @{
            @"txt" : @(PDLDirectoryContentTypeText),
            @"log" : @(PDLDirectoryContentTypeText),

            @"png" : @(PDLDirectoryContentTypeImage),
            @"jpg" : @(PDLDirectoryContentTypeImage),
            @"jpeg" : @(PDLDirectoryContentTypeImage),

            @"mp3" : @(PDLDirectoryContentTypeAudio),
            @"aac" : @(PDLDirectoryContentTypeAudio),

            @"mp4" : @(PDLDirectoryContentTypeVideo),
            @"mov" : @(PDLDirectoryContentTypeVideo),
            @"m3u8" : @(PDLDirectoryContentTypeVideo),

            @"db" : @(PDLDirectoryContentTypeDatabase),
            @"sqlite" : @(PDLDirectoryContentTypeDatabase),

            @"plist" : @(PDLDirectoryContentTypePropertyList),
            @"json" : @(PDLDirectoryContentTypePropertyList),

            @"htm" : @(PDLDirectoryContentTypeWebPage),
            @"html" : @(PDLDirectoryContentTypeWebPage),

            @"framework" : @(PDLDirectoryContentTypeDynamicLibrary),
            @"tbd" : @(PDLDirectoryContentTypeDynamicLibrary),
            @"dylib" : @(PDLDirectoryContentTypeDynamicLibrary),

            @"crash" : @(PDLDirectoryContentTypeCrash),
            @"ips" : @(PDLDirectoryContentTypeCrash),
            @"synced" : @(PDLDirectoryContentTypeCrash),
        };
        NSNumber *typeNumber = typeMap[extension];
        if (typeNumber) {
            type = typeNumber.integerValue;
        }
    }
    return type;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        if (!exists) {
            return nil;
        }

        _filePath = [filePath copy];
        _filename = [filePath.lastPathComponent copy];
        _isDirectory = isDirectory;
        if (isDirectory) {
            __weak __typeof(self) weakSelf = self;
            dispatch_async([self.class sizeCalculatingQueue], ^{
                weakSelf.size = PDLDirectoryViewControllerFileSizeAtPath(filePath);
                weakSelf.hasFinishCalculatingSize = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(self) strongSelf = self;
                    if (strongSelf.sizeCalculatingCompletion) {
                        strongSelf.sizeCalculatingCompletion(strongSelf);
                    }
                });
            });
        } else {
            _size = PDLDirectoryViewControllerFileSizeAtPath(filePath);
            _hasFinishCalculatingSize = YES;
        }
        _extension = [filePath pathExtension];

        PDLDirectoryContentType type = [self.class contentTypeOfFilePath:filePath];
        CGSize size = CGSizeMake(10, 20);
        CGSize imageSize = CGSizeMake(60, 40);
        UIImage *thumbnailImage = nil;
        switch (type) {
            case PDLDirectoryContentTypeDirectory:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor yellowColor], size);
                break;
            case PDLDirectoryContentTypeText:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor grayColor], size);
                break;
            case PDLDirectoryContentTypeImage:
                thumbnailImage = PDLDirectoryViewControllerAspectFitImageWithImageAndSize([UIImage imageWithContentsOfFile:filePath], imageSize);
                break;
            case PDLDirectoryContentTypeAudio:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor blueColor], size);
                break;
            case PDLDirectoryContentTypeVideo:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor redColor], size);
                break;
            case PDLDirectoryContentTypeDatabase:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor greenColor], size);
                break;
            case PDLDirectoryContentTypePropertyList:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor purpleColor], size);
                break;
            case PDLDirectoryContentTypeWebPage:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor magentaColor], size);
                break;
            case PDLDirectoryContentTypeDynamicLibrary:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor cyanColor], size);
                break;
            case PDLDirectoryContentTypeCrash:
                thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor brownColor], size);
                break;
            case PDLDirectoryContentTypeUnknown: {
                UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                if (image) {
                    thumbnailImage = PDLDirectoryViewControllerAspectFitImageWithImageAndSize(image, imageSize);
                    type = PDLDirectoryContentTypeImage;
                } else {
                    thumbnailImage = PDLDirectoryViewControllerImageWithColorAndSize([UIColor blackColor], size);
                }
            } break;
            default:
                break;
        }
        _thumbnailImage = thumbnailImage;
        _type = type;
    }
    return self;
}

- (NSComparisonResult)compare:(PDLDirectoryContent *)content {
    if (self.isDirectory != content.isDirectory) {
        return self.isDirectory ? NSOrderedAscending : NSOrderedDescending;
    }
    return [self.filename compare:content.filename];
}

- (NSString *)contentDescription {
    NSString *contentDescription = self.filePath;
    contentDescription = [contentDescription stringByAppendingFormat:@"\nfile size:%@ bytes", @(self.size)];
    switch (self.type) {
        case PDLDirectoryContentTypeDirectory:
            break;
        case PDLDirectoryContentTypeText:
            break;
        case PDLDirectoryContentTypeImage: {
            UIImage *image = [UIImage imageWithContentsOfFile:self.filePath];
            contentDescription = [contentDescription stringByAppendingFormat:@"\nimage size:%@, image scale:%@", NSStringFromCGSize(image.size), @(image.scale)];
        } break;
        case PDLDirectoryContentTypeAudio:
            break;
        case PDLDirectoryContentTypeVideo:
            break;
        case PDLDirectoryContentTypeDatabase:
            break;
        case PDLDirectoryContentTypePropertyList:
            break;
        case PDLDirectoryContentTypeWebPage:
            break;
        case PDLDirectoryContentTypeDynamicLibrary:
            break;
        case PDLDirectoryContentTypeCrash:
            break;
        case PDLDirectoryContentTypeUnknown:
            break;
        default:
            break;
    }
    return contentDescription;
}

@end

@interface PDLDirectoryTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL cellSelected;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@interface PDLDirectoryTableViewCell ()

@property (nonatomic, strong) UIImageView *selectionImageView;

@end

@implementation PDLDirectoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *selectionImageView = [[UIImageView alloc] init];
        selectionImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _selectionImageView = selectionImageView;
    }
    return self;
}

- (void)setCellSelected:(BOOL)cellSelected {
    _cellSelected = cellSelected;

    [self refreshSelected];
}

- (void)refreshSelected {
    self.selectionImageView.image = self.cellSelected ? PDLDirectoryViewControllerCheckboxHighlightedImage() : PDLDirectoryViewControllerCheckboxImage();
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];

    if ([NSStringFromClass(view.class) isEqualToString:@"UITableViewCellEditControl"]) {
        if (![self.selectionImageView isDescendantOfView:self]) {
            for (UIView *subview in view.subviews) {
                subview.hidden = YES;
            }
            [view addSubview:self.selectionImageView];
            self.selectionImageView.frame = view.bounds;
            self.selectionImageView.backgroundColor = [UIColor clearColor];
            self.selectionImageView.layer.zPosition = FLT_MAX;
        }
    }
}

@end

@interface PDLDirectoryViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, copy) NSArray *contents;
@property (nonatomic, weak) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, weak) UILabel *infoLabel;

@property (nonatomic, weak) UIView *selectAllView;
@property (nonatomic, weak) UIButton *checkboxButton;
@property (nonatomic, weak) UIButton *actButton;
@property (nonatomic, strong) NSMutableArray *selected;

@end

@implementation PDLDirectoryViewController

- (instancetype)initWithDirectory:(NSString *)directory {
    self = [super init];
    if (self) {
        _directory = [directory copy];
        _selected = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [self.directory lastPathComponent];

    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.rightBarButtonItem = rightBarButtonItem;

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

    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor darkGrayColor];
    infoLabel.font = [UIFont systemFontOfSize:10];
    tableView.tableHeaderView = infoLabel;
    self.infoLabel = infoLabel;

    CGFloat bottom = 0;
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
#pragma clang diagnostic pop
    }
    UIView *selectAllView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 49 + bottom)];
    selectAllView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    selectAllView.backgroundColor = PDLColorBackgroundColor();

    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectAllView.frame.size.width, 49)];
    actionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [selectAllView addSubview:actionView];

    UIButton *checkboxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, actionView.frame.size.height)];
    checkboxButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [checkboxButton setImage:PDLDirectoryViewControllerCheckboxImage() forState:UIControlStateNormal];
    [checkboxButton setImage:PDLDirectoryViewControllerCheckboxHighlightedImage() forState:UIControlStateSelected];
    [checkboxButton setTitle:@" Select All" forState:UIControlStateNormal];
    [checkboxButton setTitleColor:PDLColorTextColor() forState:UIControlStateNormal];
    checkboxButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [actionView addSubview:checkboxButton];
    self.checkboxButton = checkboxButton;

    UIButton *actButton = [[UIButton alloc] initWithFrame:CGRectMake(actionView.frame.size.width - 80, 0, 80, actionView.frame.size.height)];
    actButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    actButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [actButton setTitle:@"Act" forState:UIControlStateNormal];
    [actButton setTitleColor:PDLColorTextColor() forState:UIControlStateNormal];
    [actButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [actionView addSubview:actButton];
    self.actButton = actButton;

    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectAllView.frame.size.width, 1 / [UIScreen mainScreen].scale)];
    topLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    topLineView.backgroundColor = [UIColor grayColor];
    [selectAllView addSubview:topLineView];

    [checkboxButton addTarget:self action:@selector(checkboxButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [actButton addTarget:self action:@selector(actButtonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:selectAllView];
    self.selectAllView = selectAllView;

    [self reloadData];
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)reloadData {
    self.rightBarButtonItem.enabled = NO;
    self.infoLabel.text = @"Loading...";
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong __typeof(self) self = weakSelf;
        NSMutableArray *contents = [NSMutableArray array];
        NSError *error = nil;
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directory error:&error];
        for (NSString *filename in filenames) {
            NSString *filePath = [self.directory stringByAppendingPathComponent:filename];
            PDLDirectoryContent *content = [[PDLDirectoryContent alloc] initWithFilePath:filePath];
            if (!content) {
                continue;
            }
            [contents addObject:content];
            content.sizeCalculatingCompletion = ^(PDLDirectoryContent *content) {
                __strong __typeof(self) self = weakSelf;
                NSInteger index = [self.contents indexOfObject:content];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                NSArray *indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows;
                if ([indexPathsForVisibleRows containsObject:indexPath]) {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            };
        }
        [contents sortUsingSelector:@selector(compare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(self) self = weakSelf;
            if (error) {
                [self alertWithTitle:@"Error" message:error.localizedDescription];
            }

            if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 10) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
                [self.tableView.refreshControl endRefreshing];
#pragma clang diagnostic pop
            } else {
                // Fallback on earlier versions
            }
            self.rightBarButtonItem.enabled = YES;
            self.contents = contents;
            self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", @(self.contents.count), (self.contents.count > 1 ? @"items" : @"item")];
            [self.tableView reloadData];
        });
    });
}

- (void)edit {
    self.isEditing = !self.isEditing;
}

- (void)reloadDataSilently {
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        PDLDirectoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            PDLDirectoryContent *content = self.contents[indexPath.row];
            [self applyContent:content forCell:cell];
            cell.cellSelected = ([self.selected containsObject:content]);
        }
    }
}

- (void)refreshCheckbox {
    self.checkboxButton.selected = ((self.selected.count > 0) && (self.selected.count >= self.contents.count));
    self.actButton.enabled = (self.selected.count > 0);
}

- (void)refreshRightButton {
    if (self.contents.count == 0) {
        self.rightBarButtonItem.title = @"";
    } else {
        self.rightBarButtonItem.title = self.isEditing ? @"Done" : @"Edit";
    }
}
- (BOOL)isEditing {
    return self.tableView.isEditing;
}

- (void)setIsEditing:(BOOL)isEditing {
    if (self.tableView.isEditing == isEditing) {
        return;
    }

    [self.tableView setEditing:isEditing animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, (isEditing ? self.selectAllView.frame.size.height : 0), 0);
        self.selectAllView.frame = CGRectMake(self.selectAllView.frame.origin.x, (isEditing ? self.view.frame.size.height - self.selectAllView.frame.size.height : self.view.frame.size.height), self.selectAllView.frame.size.width, self.selectAllView.frame.size.height);
    } completion:^(BOOL finished) {
        if (isEditing == NO) {
            [self.selected removeAllObjects];
            [self refreshCheckbox];
            [self reloadDataSilently];
        }
    }];
    [self refreshRightButton];
}

- (void)checkboxButtonDidTouchUpInside:(UIButton *)checkboxButton {
    checkboxButton.selected = !checkboxButton.selected;
    [self.selected removeAllObjects];
    if (checkboxButton.selected) {
        [self.selected addObjectsFromArray:self.contents];
    }
    [self.tableView reloadData];
    [self refreshCheckbox];
}

- (void)actButtonDidTouchUpInside:(UIButton *)actButton {
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteSelected];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Other" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doOtherForSelected];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteSelected {
    BOOL isRemoved = YES;
    NSError *error = nil;
    for (PDLDirectoryContent *content in self.selected) {
        NSString *filePath = content.filePath;
        if (error) {
            isRemoved &= [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        } else {
            isRemoved &= [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
    }
    if (!isRemoved) {
        [self alertWithTitle:@"Error" message:error.localizedDescription];
    }
    self.isEditing = NO;
    [self reloadData];
}

- (void)doOtherForSelected {
    NSMutableArray *urls = [NSMutableArray array];
    for (PDLDirectoryContent *content in self.selected) {
        NSURL *url = [NSURL fileURLWithPath:content.filePath];
        [urls addObject:url];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:urls applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        PDLDirectoryTableViewCell *cell = (PDLDirectoryTableViewCell *)longPressGestureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath == nil) {
            return;
        }

        PDLDirectoryContent *content = self.contents[indexPath.row];
        __weak __typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a text file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeText];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as an image file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeImage];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as an audio file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeAudio];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a video file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeVideo];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a database file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeDatabase];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a property list file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypePropertyList];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a web page file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeWebPage];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a dynamic library file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeDynamicLibrary];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a crash file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeCrash];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Other" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:PDLDirectoryContentTypeOther];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
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

- (void)tapImageView:(UITapGestureRecognizer *)tapGestureRecognizer {
    [tapGestureRecognizer.view removeFromSuperview];
}

- (void)openContent:(PDLDirectoryContent *)content {
    if (content.type <= PDLDirectoryContentTypeUnknown || content.type >= PDLDirectoryContentTypeCount) {
        return;
    }

    [self openContent:content type:content.type];
}

- (void)openContent:(PDLDirectoryContent *)content type:(PDLDirectoryContentType)type {
    switch (type) {
        case PDLDirectoryContentTypeDirectory: {
            PDLDirectoryViewController *viewController = [[self.class alloc] initWithDirectory:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case PDLDirectoryContentTypeText: {
            PDLTextViewController *viewController = [[PDLTextViewController alloc] initWithPath:content.filePath];
            if (viewController) {
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                [self alertWithTitle:@"Error" message:nil];
            }
        } break;
        case PDLDirectoryContentTypeImage: {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.window.bounds];
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imageView.userInteractionEnabled = YES;
            imageView.backgroundColor = [UIColor blackColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
            [self.view.window addSubview:imageView];

            NSData *imageData = [NSData dataWithContentsOfFile:content.filePath];
            imageView.image = [UIImage imageWithData:imageData];
        } break;
        case PDLDirectoryContentTypeAudio: {
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc] init];
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:content.filePath]];
            viewController.player = player;
            [self.navigationController presentViewController:viewController animated:YES completion:nil];
        } break;
        case PDLDirectoryContentTypeVideo: {
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc] init];
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:content.filePath]];
            viewController.player = player;
            [self.navigationController presentViewController:viewController animated:YES completion:nil];
        } break;
        case PDLDirectoryContentTypeDatabase: {
            PDLDatabaseViewController *viewController = [[PDLDatabaseViewController alloc] initWithPath:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case PDLDirectoryContentTypePropertyList: {
            PDLPropertyListViewController *viewController = [[PDLPropertyListViewController alloc] initWithPath:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case PDLDirectoryContentTypeWebPage: {
            NSURL *url = [NSURL fileURLWithPath:content.filePath];
            PDLWebViewController *viewController = [[PDLWebViewController alloc] initWithUrlString:url.absoluteString];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case PDLDirectoryContentTypeDynamicLibrary: {
#ifdef DEBUG
            void *ret = dlopen(content.filePath.UTF8String, RTLD_NOW);
            if (ret) {
                [self alertWithTitle:@"Success" message:nil];
                dlclose(ret);
            } else {
                [self alertWithTitle:@"Failure" message:nil];
            }
#endif
        } break;
        case PDLDirectoryContentTypeCrash: {
            PDLCrashViewController *viewController = [[PDLCrashViewController alloc] initWithPath:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case PDLDirectoryContentTypeOther: {
            NSURL *url = [NSURL fileURLWithPath:content.filePath];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:nil];
        } break;
        case PDLDirectoryContentTypeUnknown: {
            ;
        } break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.tableView.isEditing) {
        return NO;
    }

    PDLDirectoryTableViewCell *cell = (PDLDirectoryTableViewCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) {
        return NO;
    }
    return YES;
}

- (void)applyContent:(PDLDirectoryContent *)content forCell:(PDLDirectoryTableViewCell *)cell {
    cell.imageView.image = content.thumbnailImage;
    cell.textLabel.text = content.filename;
    cell.detailTextLabel.text = content.hasFinishCalculatingSize ? PDLDirectoryViewControllerSizeStringOfBytes(content.size) : @"calculating size...";
    cell.accessoryType = content.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbers = self.contents.count;
    return numbers;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"";
    PDLDirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PDLDirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPressGestureRecognizer.delegate = self;
        [cell addGestureRecognizer:longPressGestureRecognizer];
        cell.longPressGestureRecognizer = longPressGestureRecognizer;
    }
    PDLDirectoryContent *content = self.contents[indexPath.row];
    [self applyContent:content forCell:cell];
    cell.cellSelected = ([self.selected containsObject:content]);
    cell.longPressGestureRecognizer.enabled = !tableView.isEditing;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    PDLDirectoryContent *content = self.contents[indexPath.row];
    if (tableView.isEditing) {
        PDLDirectoryTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([self.selected containsObject:content]) {
            [self.selected removeObject:content];
            [self refreshCheckbox];
            cell.cellSelected = NO;
        } else {
            [self.selected addObject:content];
            [self refreshCheckbox];
            cell.cellSelected = YES;
        }
    } else {
        [self openContent:content];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.isEditing ? (UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert) : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PDLDirectoryContent *content = self.contents[indexPath.row];
    NSString *filePath = content.filePath;
    NSError *error = nil;
    BOOL isRemoved = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (isRemoved) {
        NSMutableArray *contents = [self.contents mutableCopy];
        [contents removeObjectAtIndex:indexPath.row];
        self.contents = contents;
        self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", @(self.contents.count), (self.contents.count > 1 ? @"items" : @"item")];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self alertWithTitle:@"Error" message:error.localizedDescription];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self) weakSelf = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath * indexPath) {
        [weakSelf tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    UITableViewRowAction *infoAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"信息" handler:^(UITableViewRowAction *action, NSIndexPath * indexPath) {
        weakSelf.tableView.editing = NO;
        PDLDirectoryContent *content = weakSelf.contents[indexPath.row];
        [weakSelf alertWithTitle:@"Info" message:content.contentDescription];
    }];
    infoAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, infoAction];
}

@end
