//
//  PDLBlock.h
//  Poodle
//
//  Created by Poodle on 2021/2/3.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSUInteger PDLBlockCheckEnable(BOOL(*descriptorFilter)(NSString *symbol));
extern BOOL PDLBlockCheck(Class aClass, void (^callback)(void *block, void *object));

extern void PDLBlockCheckIgnoreBegin(id object);
extern void PDLBlockCheckIgnoreEnd(id object);
extern void PDLBlockCheckIgnoreAllBegin(void);
extern void PDLBlockCheckIgnoreAllEnd(void);
