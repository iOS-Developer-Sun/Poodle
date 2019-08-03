//
//  PDLDirectoryViewController.m
//  Poodle
//
//  Created by Poodle on 09/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLDirectoryViewController.h"
#import "PDLDirectoryViewControllerResources.h"
#import <dlfcn.h>
#import <AVKit/AVKit.h>
#import "PDLTextViewController.h"
#import "PDLPropertyListViewController.h"
#import "PDLDatabaseViewController.h"
#import "PDLWebViewController.h"

static UIImage *PDLDirectoryViewController_AspectFitImageWithImageAndSize(UIImage *image, CGSize size) {
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

static UIImage *PDLDirectoryViewController_ImageWithColorAndSize(UIColor *color, CGSize size) {
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

static UIImage *DirectoryViewController_CheckboxImage() {
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

static UIImage *DirectoryViewController_CheckboxHighlightedImage() {
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

static NSString *DirectoryViewController_SizeStringOfBytes(uint64_t bytes) {
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

static uint64_t DirectoryViewController_FileSizeAtPath(NSString *filePath) {
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

typedef NS_ENUM(NSInteger, DirectoryContentType) {
    DirectoryContentTypeUnknown = -1,
    DirectoryContentTypeDirectory,
    DirectoryContentTypeText,
    DirectoryContentTypeImage,
    DirectoryContentTypeAudio,
    DirectoryContentTypeVideo,
    DirectoryContentTypeDatabase,
    DirectoryContentTypePropertyList,
    DirectoryContentTypeWebPage,
    DirectoryContentTypeDynamicLibrary,
    DirectoryContentTypeOther,

    DirectoryContentTypeCount,
};

@interface DirectoryContent : NSObject

@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) BOOL isDirectory;
@property (nonatomic, readonly) uint64_t size;
@property (nonatomic, readonly) BOOL hasFinishCalculatingSize;
@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readonly) NSString *extension;
@property (nonatomic, readonly) DirectoryContentType type;
@property (nonatomic, copy) void (^sizeCalculatingCompletion)(DirectoryContent *content);

- (instancetype)initWithFilePath:(NSString *)filePath;

@end

@interface DirectoryContent ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, assign) BOOL hasFinishCalculatingSize;

@property (readonly) NSString *contentDescription;

@end

@implementation DirectoryContent

+ (dispatch_queue_t)sizeCalculatingQueue {
    static dispatch_queue_t sizeCalculatingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizeCalculatingQueue =  dispatch_queue_create("DirectoryContentSizeCalculatingQueue", NULL);
    });
    return sizeCalculatingQueue;
}

+ (DirectoryContentType)contentTypeOfFilePath:(NSString *)filePath {
    DirectoryContentType type = DirectoryContentTypeUnknown;
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    NSString *extension = [filePath pathExtension];
    if (isDirectory) {
        type = DirectoryContentTypeDirectory;
    } else {
        NSDictionary *typeMap = @{@"txt" : @(DirectoryContentTypeText),
                                  @"log" : @(DirectoryContentTypeText),

                                  @"png" : @(DirectoryContentTypeImage),
                                  @"jpg" : @(DirectoryContentTypeImage),
                                  @"jpeg" : @(DirectoryContentTypeImage),

                                  @"mp3" : @(DirectoryContentTypeAudio),
                                  @"aac" : @(DirectoryContentTypeAudio),

                                  @"mp4" : @(DirectoryContentTypeVideo),
                                  @"mov" : @(DirectoryContentTypeVideo),
                                  @"m3u8" : @(DirectoryContentTypeVideo),

                                  @"db" : @(DirectoryContentTypeDatabase),
                                  @"sqlite" : @(DirectoryContentTypeDatabase),

                                  @"plist" : @(DirectoryContentTypePropertyList),
                                  @"json" : @(DirectoryContentTypePropertyList),

                                  @"htm" : @(DirectoryContentTypeWebPage),
                                  @"html" : @(DirectoryContentTypeWebPage),

                                  @"framework" : @(DirectoryContentTypeDynamicLibrary),
                                  @"tbd" : @(DirectoryContentTypeDynamicLibrary),
                                  @"dylib" : @(DirectoryContentTypeDynamicLibrary),
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

        _filePath = filePath.copy;
        _filename = filePath.lastPathComponent.copy;
        _isDirectory = isDirectory;
        if (isDirectory) {
            __weak __typeof(self) weakSelf = self;
            dispatch_async([self.class sizeCalculatingQueue], ^{
                weakSelf.size = DirectoryViewController_FileSizeAtPath(filePath);
                weakSelf.hasFinishCalculatingSize = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong __typeof(self) strongSelf = self;
                    if (strongSelf.sizeCalculatingCompletion) {
                        strongSelf.sizeCalculatingCompletion(strongSelf);
                    }
                });
            });
        } else {
            _size = DirectoryViewController_FileSizeAtPath(filePath);
            _hasFinishCalculatingSize = YES;
        }
        _extension = [filePath pathExtension];

        DirectoryContentType type = [self.class contentTypeOfFilePath:filePath];
        CGSize size = CGSizeMake(10, 20);
        CGSize imageSize = CGSizeMake(60, 40);
        UIImage *thumbnailImage = nil;
        switch (type) {
            case DirectoryContentTypeDirectory:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor yellowColor], size);
                break;
            case DirectoryContentTypeText:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor grayColor], size);
                break;
            case DirectoryContentTypeImage:
                thumbnailImage = PDLDirectoryViewController_AspectFitImageWithImageAndSize([UIImage imageWithContentsOfFile:filePath], imageSize);
                break;
            case DirectoryContentTypeAudio:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor blueColor], size);
                break;
            case DirectoryContentTypeVideo:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor redColor], size);
                break;
            case DirectoryContentTypeDatabase:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor greenColor], size);
                break;
            case DirectoryContentTypePropertyList:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor purpleColor], size);
                break;
            case DirectoryContentTypeWebPage:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor magentaColor], size);
                break;
            case DirectoryContentTypeDynamicLibrary:
                thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor cyanColor], size);
                break;
            case DirectoryContentTypeUnknown: {
                UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                if (image) {
                    thumbnailImage = PDLDirectoryViewController_AspectFitImageWithImageAndSize(image, imageSize);
                    type = DirectoryContentTypeImage;
                } else {
                    thumbnailImage = PDLDirectoryViewController_ImageWithColorAndSize([UIColor blackColor], size);
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

- (NSComparisonResult)compare:(DirectoryContent *)content {
    if (self.isDirectory != content.isDirectory) {
        return self.isDirectory ? NSOrderedAscending : NSOrderedDescending;
    }
    return [self.filename compare:content.filename];
}

- (NSString *)contentDescription {
    NSString *contentDescription = self.filePath;
    contentDescription = [contentDescription stringByAppendingFormat:@"\nfile size:%@ bytes", @(self.size)];
    switch (self.type) {
        case DirectoryContentTypeDirectory:
            break;
        case DirectoryContentTypeText:
            break;
        case DirectoryContentTypeImage: {
            UIImage *image = [UIImage imageWithContentsOfFile:self.filePath];
            contentDescription = [contentDescription stringByAppendingFormat:@"\nimage size:%@, image scale:%@", NSStringFromCGSize(image.size), @(image.scale)];
        } break;
        case DirectoryContentTypeAudio:
            break;
        case DirectoryContentTypeVideo:
            break;
        case DirectoryContentTypeDatabase:
            break;
        case DirectoryContentTypePropertyList:
            break;
        case DirectoryContentTypeWebPage:
            break;
        case DirectoryContentTypeDynamicLibrary:
            break;
        case DirectoryContentTypeUnknown:
            break;
        default:
            break;
    }
    return contentDescription;
}

@end

@interface DirectoryTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL cellSelected;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@interface DirectoryTableViewCell ()

@property (nonatomic, strong) UIImageView *selectionImageView;

@end

@implementation DirectoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *selectionImageView = [[UIImageView alloc] init];
        selectionImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        selectionImageView.contentMode = UIViewContentModeCenter;
        _selectionImageView = selectionImageView;
    }
    return self;
}

- (void)setCellSelected:(BOOL)cellSelected {
    _cellSelected = cellSelected;

    [self refreshSelected];
}

- (void)refreshSelected {
    self.selectionImageView.image = self.cellSelected ? DirectoryViewController_CheckboxHighlightedImage() : DirectoryViewController_CheckboxImage();
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];

    if ([NSStringFromClass(view.class) isEqualToString:@"UITableViewCellEditControl"]) {
        if (![self.selectionImageView isDescendantOfView:self]) {
            [view addSubview:self.selectionImageView];
            self.selectionImageView.frame = view.bounds;

            self.selectionImageView.backgroundColor = [UIColor whiteColor];
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
        _directory = directory.copy;
        _selected = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [self.directory lastPathComponent];

    self.view.backgroundColor = [UIColor whiteColor];

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
    if (@available(iOS 10.0, *)) {
        tableView.refreshControl = refreshControl;
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
    if (@available(iOS 11, *)) {
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    UIView *selectAllView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 49 + bottom)];
    selectAllView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    selectAllView.backgroundColor = [UIColor whiteColor];

    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectAllView.frame.size.width, 49)];
    actionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [selectAllView addSubview:actionView];

    UIButton *checkboxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, actionView.frame.size.height)];
    checkboxButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [checkboxButton setImage:DirectoryViewController_CheckboxImage() forState:UIControlStateNormal];
    [checkboxButton setImage:DirectoryViewController_CheckboxHighlightedImage() forState:UIControlStateSelected];
    [checkboxButton setTitle:@" Select All" forState:UIControlStateNormal];
    [checkboxButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    checkboxButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [actionView addSubview:checkboxButton];
    self.checkboxButton = checkboxButton;

    UIButton *actButton = [[UIButton alloc] initWithFrame:CGRectMake(actionView.frame.size.width - 80, 0, 80, actionView.frame.size.height)];
    actButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    actButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [actButton setTitle:@"Act" forState:UIControlStateNormal];
    [actButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *contents = [NSMutableArray array];
        NSError *error = nil;
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directory error:&error];
        for (NSString *filename in filenames) {
            NSString *filePath = [self.directory stringByAppendingPathComponent:filename];
            DirectoryContent *content = [[DirectoryContent alloc] initWithFilePath:filePath];
            if (!content) {
                continue;
            }
            [contents addObject:content];
            __weak __typeof(self) weakSelf = self;
            content.sizeCalculatingCompletion = ^(DirectoryContent *content) {
                NSInteger index = [weakSelf.contents indexOfObject:content];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                NSArray *indexPathsForVisibleRows = weakSelf.tableView.indexPathsForVisibleRows;
                if ([indexPathsForVisibleRows containsObject:indexPath]) {
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            };
        }
        [contents sortUsingSelector:@selector(compare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    ;
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }

            if (@available(iOS 10.0, *)) {
                [self.tableView.refreshControl endRefreshing];
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
        DirectoryTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            DirectoryContent *content = self.contents[indexPath.row];
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
    for (DirectoryContent *content in self.selected) {
        NSString *filePath = content.filePath;
        if (error) {
            isRemoved &= [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        } else {
            isRemoved &= [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        }
    }
    if (!isRemoved) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    self.isEditing = NO;
    [self reloadData];
}

- (void)doOtherForSelected {
    NSMutableArray *urls = [NSMutableArray array];
    for (DirectoryContent *content in self.selected) {
        NSURL *url = [NSURL fileURLWithPath:content.filePath];
        [urls addObject:url];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:urls applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        DirectoryTableViewCell *cell = (DirectoryTableViewCell *)longPressGestureRecognizer.view;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath == nil) {
            return;
        }

        DirectoryContent *content = self.contents[indexPath.row];
        __weak __typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a text file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeText];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as an image file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeImage];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as an audio file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeAudio];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a video file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeVideo];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a database file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeDatabase];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a property list file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypePropertyList];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a web page file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeWebPage];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Open as a dynamic library file" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeDynamicLibrary];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Other" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf openContent:content type:DirectoryContentTypeOther];
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

- (void)openContent:(DirectoryContent *)content {
    if (content.type <= DirectoryContentTypeUnknown || content.type >= DirectoryContentTypeCount) {
        return;
    }

    [self openContent:content type:content.type];
}

- (void)openContent:(DirectoryContent *)content type:(DirectoryContentType)type {
    switch (type) {
        case DirectoryContentTypeDirectory: {
            PDLDirectoryViewController *viewController = [[self.class alloc] initWithDirectory:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case DirectoryContentTypeText: {
            PDLTextViewController *viewController = [[PDLTextViewController alloc] initWithPath:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case DirectoryContentTypeImage: {
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
        case DirectoryContentTypeAudio: {
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc] init];
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:content.filePath]];
            viewController.player = player;
            [self.navigationController presentViewController:viewController animated:YES completion:nil];
        } break;
        case DirectoryContentTypeVideo: {
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc] init];
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:content.filePath]];
            viewController.player = player;
            [self.navigationController presentViewController:viewController animated:YES completion:nil];
        } break;
        case DirectoryContentTypeDatabase: {
            PDLDatabaseViewController *viewController = [[PDLDatabaseViewController alloc] initWithPath:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case DirectoryContentTypePropertyList: {
            PDLPropertyListViewController *viewController = [[PDLPropertyListViewController alloc] initWithPath:content.filePath];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case DirectoryContentTypeWebPage: {
            NSURL *url = [NSURL fileURLWithPath:content.filePath];
            PDLWebViewController *viewController = [[PDLWebViewController alloc] initWithUrlString:url.absoluteString];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case DirectoryContentTypeDynamicLibrary: {
#ifdef DEBUG
            void *ret = dlopen(content.filePath.UTF8String, RTLD_NOW);
            if (ret) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    ;
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
                dlclose(ret);
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    ;
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
#endif
        } break;
        case DirectoryContentTypeOther: {
            NSURL *url = [NSURL fileURLWithPath:content.filePath];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:nil];
        } break;
        case DirectoryContentTypeUnknown: {
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

    DirectoryTableViewCell *cell = (DirectoryTableViewCell *)gestureRecognizer.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) {
        return NO;
    }
    return YES;
}

- (void)applyContent:(DirectoryContent *)content forCell:(DirectoryTableViewCell *)cell {
    cell.imageView.image = content.thumbnailImage;
    cell.textLabel.text = content.filename;
    cell.detailTextLabel.text = content.hasFinishCalculatingSize ? DirectoryViewController_SizeStringOfBytes(content.size) : @"calculating size...";
    cell.accessoryType = content.isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
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
    DirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPressGestureRecognizer.delegate = self;
        [cell addGestureRecognizer:longPressGestureRecognizer];
        cell.longPressGestureRecognizer = longPressGestureRecognizer;
    }
    DirectoryContent *content = self.contents[indexPath.row];
    [self applyContent:content forCell:cell];
    cell.cellSelected = ([self.selected containsObject:content]);
    cell.longPressGestureRecognizer.enabled = !tableView.isEditing;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DirectoryContent *content = self.contents[indexPath.row];
    if (tableView.isEditing) {
        DirectoryTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
    DirectoryContent *content = self.contents[indexPath.row];
    NSString *filePath = content.filePath;
    NSError *error = nil;
    BOOL isRemoved = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (isRemoved) {
        NSMutableArray *contents = self.contents.mutableCopy;
        [contents removeObjectAtIndex:indexPath.row];
        self.contents = contents;
        self.infoLabel.text = [NSString stringWithFormat:@"%@ %@", @(self.contents.count), (self.contents.count > 1 ? @"items" : @"item")];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self) weakSelf = self;
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath * indexPath) {
        [weakSelf tableView:tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    }];
    UITableViewRowAction *infoAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"信息" handler:^(UITableViewRowAction *action, NSIndexPath * indexPath) {
        weakSelf.tableView.editing = NO;
        DirectoryContent *content = self.contents[indexPath.row];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info" message:content.contentDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    infoAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, infoAction];
}

@end
