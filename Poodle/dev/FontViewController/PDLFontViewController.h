//
//  PDLFontViewController.h
//  Poodle
//
//  Created by Poodle on 15/7/21.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDLFontViewController : UIViewController

@property (nonatomic, copy) NSString *exampleText;
@property (nonatomic, copy) void(^fontSelectAction)(PDLFontViewController *fontViewController, NSString *familyName, NSString *fontName);

@end
