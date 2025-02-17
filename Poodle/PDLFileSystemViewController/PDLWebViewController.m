//
//  PDLWebViewController.m
//  Poodle
//
//  Created by Poodle on 10/07/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLWebViewController.h"
#import <WebKit/WebKit.h>

@interface PDLWebViewController () <WKNavigationDelegate, UITextFieldDelegate>

@property (nonatomic, weak) UIView *addressView;
@property (nonatomic, weak) UITextField *addressTextField;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, copy) NSString *urlString;

@end

@implementation PDLWebViewController

static void *WebViewControllerObservingTitleContext = NULL;
static void *WebViewControllerObservingEstimatedProgressContext = NULL;

- (instancetype)initWithUrlString:(NSString *)urlString {
    self = [super init];
    if (self) {
        _urlString = [urlString copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];

    UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, 44)];
    addressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    addressView.backgroundColor = [UIColor grayColor];
    [self.containerView addSubview:addressView];
    self.addressView = addressView;

    UITextField *addressTextField = [[UITextField alloc] initWithFrame:CGRectInset(addressView.bounds, 10, 5)];
    addressTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    addressTextField.font = [UIFont systemFontOfSize:13];
    addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    addressTextField.keyboardType = UIKeyboardTypeURL;
    addressTextField.delegate = self;
    [addressView addSubview:addressTextField];
    self.addressTextField = addressTextField;
    addressTextField.text = self.urlString;

    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, addressView.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height - 44)];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.navigationDelegate = self;
    [self.containerView addSubview:webView];
    self.webView = webView;

    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionOld context:&WebViewControllerObservingTitleContext];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld context:&WebViewControllerObservingEstimatedProgressContext];

    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.frame = CGRectMake(0, 0, self.view.frame.size.width, 2);
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    progressView.trackTintColor = [UIColor clearColor];
    progressView.progressTintColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    progressView.clipsToBounds = YES;
    [self.containerView addSubview:progressView];
    self.progressView = progressView;

    [self setProgress:0];
    [self loadRequest];
}

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"title" context:&WebViewControllerObservingTitleContext];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress" context:&WebViewControllerObservingEstimatedProgressContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == &WebViewControllerObservingTitleContext) {
        self.title = self.webView.title;
    } else if (context == &WebViewControllerObservingEstimatedProgressContext) {
        if (self.webView.isLoading) {
            [self setProgress:self.webView.estimatedProgress];
        } else {
            [self setProgress:0];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setProgress:(double)progress {
    if (progress < self.progressView.progress) {
        self.progressView.progress = 0;
    }

    if (progress <= 0) {
        self.progressView.alpha = 0;
    } else {
        self.progressView.alpha = 1;
    }

    [self.progressView setProgress:progress animated:YES];
    if (progress >= 1) {
        [UIView animateWithDuration:0.3 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^{
            self.progressView.alpha = 0;
        } completion:^(BOOL finished) {
            ;
        }];
    }
}

- (void)loadRequest {
    if (self.webView.URL) {
        [self.webView reload];
    } else {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
        [self.webView loadRequest:request];
    }
}

- (void)copyLinkUrl {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.webView.URL.absoluteString;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"已复制到剪切板" message:self.webView.URL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openWithSafari {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webView.URL.absoluteString]];
}

- (void)clearCache {
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 9) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        __weak __typeof(self) weakSelf = self;
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"WKWebView Clear Cache Done" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                ;
            }]];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)showMenu {
    [self.view endEditing:YES];

    __weak __typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Actions" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([weakSelf.webView canGoBack]) {
            [weakSelf.webView goBack];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Forward" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([weakSelf.webView canGoForward]) {
            [weakSelf.webView goForward];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Reload" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf loadRequest];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel loading" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([weakSelf.webView isLoading]) {
            [weakSelf.webView stopLoading];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Copy url" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf copyLinkUrl];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Open with Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf openWithSafari];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear Cache" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf clearCache];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSURL *url = [NSURL URLWithString:textField.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (request) {
        [self.webView loadRequest:request];
        self.addressTextField.text = request.URL.absoluteString;
    }

    [textField resignFirstResponder];

    return NO;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            ;
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
