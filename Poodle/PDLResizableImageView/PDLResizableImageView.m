//
//  PDLResizableImageView.m
//  Poodle
//
//  Created by Poodle on 2019/1/17.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLResizableImageView.h"

@interface PDLResizableImageView ()

@end

@implementation PDLResizableImageView

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
        _image = image;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setCapInsets:(UIEdgeInsets)capInsets {
    UIEdgeInsets formedCapInsets = capInsets;
    if (formedCapInsets.top < 0) {
        formedCapInsets.top = 0;
    }
    if (formedCapInsets.left < 0) {
        formedCapInsets.left = 0;
    }
    if (formedCapInsets.bottom < 0) {
        formedCapInsets.bottom = 0;
    }
    if (formedCapInsets.right < 0) {
        formedCapInsets.right = 0;
    }
    _capInsets = formedCapInsets;
    [self setNeedsLayout];
}

- (void)setCentralSize:(CGSize)centralSize {
    CGSize formedCentralSize = centralSize;
    if (formedCentralSize.width < 0) {
        formedCentralSize.width = 0;
    }
    if (formedCentralSize.height < 0) {
        formedCentralSize.height = 0;
    }
    _centralSize = formedCentralSize;
    [self setNeedsLayout];
}

- (void)calculateBlocksWithRect:(CGRect)rect
                    imageXArray:(CGFloat *)imageXArray
                    imageYArray:(CGFloat *)imageYArray
                         xArray:(CGFloat *)xArray
                         yArray:(CGFloat *)yArray
                    xArrayCount:(NSInteger *)xArrayCount
                    yArrayCount:(NSInteger *)yArrayCount {
    *xArrayCount = 0;
    *yArrayCount = 0;

    UIImage *image = self.image;
    if (image == nil) {
        return;
    }

    CGImageRef imageRef = self.image.CGImage;
    CGFloat scale = self.image.scale;

    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    if (width <= 0 || height <= 0) {
        return;
    }

    CGFloat imageWidth = CGImageGetWidth(imageRef);
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    if (imageWidth <= 0 || imageHeight <= 0) {
        return;
    }

    UIEdgeInsets capInsets = self.capInsets;
    CGFloat capInsetsTop = capInsets.top;
    CGFloat capInsetsBottom = capInsets.bottom;
    CGFloat capInsetsLeft = capInsets.left;
    CGFloat capInsetsRight = capInsets.right;

    CGFloat imageCapInsetsTop = capInsetsTop * scale;
    CGFloat imageCapInsetsBottom = capInsetsBottom * scale;
    CGFloat imageCapInsetsLeft = capInsetsLeft * scale;
    CGFloat imageCapInsetsRight = capInsetsRight * scale;

    CGFloat centralWidth = self.centralSize.width;
    CGFloat centralHeight = self.centralSize.height;

    CGFloat imageCentralWidth = centralWidth * scale;
    CGFloat imageCentralHeight = centralHeight * scale;

    *xArrayCount = 2;
    *yArrayCount = 2;
    imageXArray[0] = 0;
    imageXArray[1] = imageWidth;
    imageYArray[0] = 0;
    imageYArray[1] = imageHeight;
    xArray[0] = 0;
    xArray[1] = width;
    yArray[0] = height;
    yArray[1] = 0;

    NSInteger count = 6;

    if (imageCapInsetsLeft + imageCapInsetsRight + imageCentralWidth <= imageWidth && capInsetsLeft + capInsetsRight + centralWidth <= width) {
        NSInteger currentIndex = 1;
        CGFloat totalImageXArray[] = {0, imageCapInsetsLeft, (imageWidth - imageCentralWidth) / 2, (imageWidth + imageCentralWidth) / 2, imageWidth - imageCapInsetsRight, imageWidth};
        CGFloat totalXArray[] = {0, capInsetsLeft, (width - centralWidth) / 2, (width + centralWidth) / 2, width - capInsetsRight, width};
        for (NSInteger i = 1; i < count; i++) {
            CGFloat x1 = totalXArray[i - 1];
            CGFloat x2 = totalXArray[i];
            if (x2 > x1) {
                xArray[currentIndex] = x2;
                imageXArray[currentIndex] = totalImageXArray[i];
                currentIndex++;
            }
        }
        *xArrayCount = currentIndex;
    }

    if (imageCapInsetsTop + imageCapInsetsBottom + imageCentralHeight <= imageHeight && capInsetsTop + capInsetsBottom + centralHeight <= height) {
        NSInteger currentIndex = 1;
        CGFloat totalImageYArray[] = {0, imageCapInsetsTop, (imageHeight - imageCentralHeight) / 2, (imageHeight + imageCentralHeight) / 2, imageHeight - imageCapInsetsBottom, imageHeight};
        CGFloat totalYArray[] = {height - 0, height - capInsetsTop, height - (height - centralHeight) / 2, height - (height + centralHeight) / 2, height - (height - capInsetsBottom), height - height};
        for (NSInteger i = 1; i < count; i++) {
            CGFloat y1 = totalYArray[i - 1];
            CGFloat y2 = totalYArray[i];
            if (y2 < y1) {
                yArray[currentIndex] = y2;
                imageYArray[currentIndex] = totalImageYArray[i];
                currentIndex++;
            }
        }
        *yArrayCount = currentIndex;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    UIColor *backgroundColor = self.backgroundColor ?: [UIColor clearColor];
    [backgroundColor setFill];
    UIRectFill(rect);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1, -1);

    CGFloat imageXArray[6], imageYArray[6], xArray[6], yArray[6];
    NSInteger xArrayCount, yArrayCount;
    [self calculateBlocksWithRect:rect
                      imageXArray:imageXArray
                      imageYArray:imageYArray
                           xArray:xArray
                           yArray:yArray
                      xArrayCount:&xArrayCount
                      yArrayCount:&yArrayCount];

    for (NSInteger j = 1; j < yArrayCount; j++) {
        for (NSInteger i = 1; i < xArrayCount; i++) {
            CGFloat imageX1 = imageXArray[i - 1];
            CGFloat imageX2 = imageXArray[i];
            CGFloat imageY1 = imageYArray[j - 1];
            CGFloat imageY2 = imageYArray[j];
            CGFloat blockImageWidth = imageX2 - imageX1;
            CGFloat blockImageHeight = imageY2 - imageY1;

            CGFloat x1 = xArray[i - 1];
            CGFloat x2 = xArray[i];
            CGFloat y1 = yArray[j];
            CGFloat y2 = yArray[j - 1];
            CGFloat blockWidth = x2 - x1;
            CGFloat blockHeight = y2 - y1;
            if (blockImageWidth < 1) {
                blockImageWidth = 1;
            }
            if (blockImageHeight < 1) {
                blockImageHeight = 1;
            }

            x1 = floor(x1);
            y1 = floor(y1);
            blockWidth = ceil(blockWidth);
            blockHeight = ceil(blockHeight);

            CGImageRef imageBlock = CGImageCreateWithImageInRect(self.image.CGImage, CGRectMake(imageX1, imageY1, blockImageWidth, blockImageHeight));
            CGContextDrawImage(context, CGRectMake(x1, y1, blockWidth, blockHeight), imageBlock);
            CGImageRelease(imageBlock);
        }
    }
    UIGraphicsEndImageContext();
}

@end
