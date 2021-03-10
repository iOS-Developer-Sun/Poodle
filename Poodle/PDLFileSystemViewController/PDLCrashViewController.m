//
//  PDLCrashViewController.m
//  Poodle
//
//  Created by Poodle on 10/07/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLCrashViewController.h"
#import "PDLCrash.h"

@interface PDLCrashViewController ()

@property (nonatomic, copy) NSFileHandle *fileHandle;
@property (nonatomic, weak) UITextView *textView;

@end

@implementation PDLCrashViewController

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = [path copy];
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        if (fileHandle == nil) {
            return nil;
        }
        _fileHandle = fileHandle;
        self.title = path.lastPathComponent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Symbolicate" style:UIBarButtonItemStylePlain target:self action:@selector(symbolicate)];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectInset(self.view.bounds, 5, 5)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.font = [UIFont systemFontOfSize:10];
    textView.editable = NO;
    [self.view addSubview:textView];
    self.textView = textView;

    self.textView.text = @"iOS UITextView bug";
    self.textView.text = @"";

    [self loadString];
}

- (void)loadString {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *string = [weakSelf textFileString];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.textView.text = string;
        });
    });
}

- (NSString *)textFileString {
    @synchronized (self.fileHandle) {
        [self.fileHandle seekToFileOffset:0];
        NSData *data = [self.fileHandle readDataToEndOfFile];
        if (data == nil) {
            return nil;
        }
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return string;
    }
}

- (void)export {
    NSString *info = [@".symbolicated-" stringByAppendingFormat:@"%@", [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]];
    NSString *lastPathComponent = self.path.lastPathComponent;
    NSString *basename = [lastPathComponent stringByDeletingPathExtension];
    NSString *pathExtension = lastPathComponent.pathExtension;
    NSString *file = [[basename stringByAppendingString:info] stringByAppendingPathExtension:pathExtension];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
    NSError *error = nil;
    BOOL exported = [self.textView.text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSString *title = nil;
    NSString *message = nil;
    if (exported) {
        title = @"Exported";
        message = path;
    } else {
        title = @"Failed";
        message = error.localizedDescription;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)finishSymbolication:(PDLCrash *)crash {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSString *title = nil;
    NSString *message = nil;
    if (crash.symbolicatedCount > 0) {
        title = @"Symbolicated";
        if (crash.UUIDMismatched) {
            title = [title stringByAppendingString:@"(UUID mismatched)"];
        }
        message = @(crash.symbolicatedCount).stringValue;
        NSString *symbolicatedString = crash.symbolicatedString;
        UIColor *highlightedColor = [UIColor redColor];
        UIColor *color = self.textView.textColor;
        UIFont *font = self.textView.font;
        NSMutableAttributedString *symbolicatedAttributedString = [[NSMutableAttributedString alloc] initWithString:symbolicatedString];
        [symbolicatedAttributedString setAttributes:@{
            NSForegroundColorAttributeName : color,
            NSFontAttributeName : font,
        } range:NSMakeRange(0, symbolicatedString.length)];
        for (NSValue *range in crash.symbolicatedLocations) {
            [symbolicatedAttributedString setAttributes:@{
                NSForegroundColorAttributeName : highlightedColor,
                NSFontAttributeName : font,
            } range:range.rangeValue];
        }
        self.textView.text = symbolicatedString;
        self.textView.attributedText = symbolicatedAttributedString;

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(export)];
    } else {
        title = @"Failed";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)symbolicate {
    self.navigationItem.rightBarButtonItem.enabled = NO;

    __weak __typeof(self) weakSelf = self;
    [self symbolicate:NO completion:^(PDLCrash *crash) {
        __strong __typeof(self) self = weakSelf;
        if (!self) {
            return;
        }

        if (crash.symbolicatedCount > 0) {
            [self finishSymbolication:crash];
        } else {
            [self symbolicate:YES completion:^(PDLCrash *crash) {
                __strong __typeof(self) self = weakSelf;
                if (!self) {
                    return;
                }

                [self finishSymbolication:crash];
            }];
        }
    }];
}

- (void)symbolicate:(BOOL)allowsUUIDMismatched completion:(void (^)(PDLCrash *crash))completion {
    __weak __typeof(self) weakSelf = self;
    NSString *string = self.textView.text;
    PDLCrash *crash = [[PDLCrash alloc] initWithString:string];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong __typeof(self) self = weakSelf;
        if (!self) {
            return;
        }

        crash.allowsUUIDMismatched = allowsUUIDMismatched;
        [crash symbolicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(self) self = weakSelf;
            if (!self) {
                return;
            }

            if (completion) {
                completion(crash);
            }
        });
    });
}

@end
