//
//  PDLMemoryTracer.h
//  Poodle
//
//  Created by Poodle on 2019/4/4.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <objc/objc.h>

extern void PDLMemoryTracerPrepareTracingClass(Class aClass);
extern void PDLMemoryTracerStartTracingClass(Class aClass);
extern void PDLMemoryTracerStopTracingClass(Class aClass);
extern void PDLMemoryTracerStartTracingClassObject(id object);
extern void PDLMemoryTracerStopTracingClassObject(id object);
extern void PDLMemoryTracerStartTracingObject(id object);
extern void PDLMemoryTracerStopTracingObject(id object);

extern BOOL PDLMemoryTracerLogEnabledForClass(Class aClass);
extern void PDLMemoryTracerSetLogEnabledForClass(Class aClass, BOOL logEnabled);
extern BOOL PDLMemoryTracerLogEnabledForObject(id object);
extern void PDLMemoryTracerSetLogEnabledForObject(id object, BOOL logEnabled);
