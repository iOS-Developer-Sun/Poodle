//
//  PDLPuddingString.h
//  Poodle
//
//  Created by Poodle on 2021/7/5.
//  Copyright © 2021 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define PDLPuddingCString(string) PDLPuddingString_##string()
#define PDLPuddingCFString(string) PDLPuddingString_##string()

extern char *PDLPuddingString_ORIGforwardInvocation(void);

extern NSString *PDLPuddingString_regexStr(void);
extern NSString *PDLPuddingString_replaceStr(void);
extern NSString *PDLPuddingString__OC_defineClass(void);
extern NSString *PDLPuddingString__OC_defineProtocol(void);
extern NSString *PDLPuddingString__OC_callI(void);
extern NSString *PDLPuddingString__OC_callC(void);
extern NSString *PDLPuddingString__OC_formatJSToOC(void);
extern NSString *PDLPuddingString__OC_formatOCToJS(void);
extern NSString *PDLPuddingString__OC_getCustomProps(void);
extern NSString *PDLPuddingString__OC_setCustomProps(void);
extern NSString *PDLPuddingString___weak(void);
extern NSString *PDLPuddingString___strong(void);
extern NSString *PDLPuddingString__formatOCToJS(void);
extern NSString *PDLPuddingString__OC_superClsName(void);
extern NSString *PDLPuddingString_autoConvertOCType(void);
extern NSString *PDLPuddingString_convertOCNumberToString(void);
extern NSString *PDLPuddingString_include(void);
extern NSString *PDLPuddingString_resourcePath(void);
extern NSString *PDLPuddingString_dispatch_after(void);
extern NSString *PDLPuddingString_dispatch_async_main(void);
extern NSString *PDLPuddingString_dispatch_sync_main(void);
extern NSString *PDLPuddingString_dispatch_async_global_queue(void);
extern NSString *PDLPuddingString_releaseTmpObj(void);
extern NSString *PDLPuddingString__OC_log(void);
extern NSString *PDLPuddingString__OC_catch(void);
extern NSString *PDLPuddingString__OC_null(void);
extern NSString *PDLPuddingString_main_js(void);
extern NSString *PDLPuddingString___realClsName(void);
extern NSString *PDLPuddingString___obj(void);
extern NSString *PDLPuddingString___isNil(void);
extern NSString *PDLPuddingString___isBlock(void);
extern NSString *PDLPuddingString_blockObj(void);
extern NSString *PDLPuddingString___clsName(void);
extern NSString *PDLPuddingString_formatedScript(void);
extern NSString *PDLPuddingString_cls(void);
extern NSString *PDLPuddingString_superCls(void);
extern NSString *PDLPuddingString_paramsType(void);
extern NSString *PDLPuddingString_returnType(void);
extern NSString *PDLPuddingString_typeEncode(void);
extern NSString *PDLPuddingString_void(void);
extern NSString *PDLPuddingString_block(void);
extern NSString *PDLPuddingString___isPerformInOC(void);
extern NSString *PDLPuddingString_clsName(void);
extern NSString *PDLPuddingString_ORIGdealloc(void);
extern NSString *PDLPuddingString_ORIGAT(void);
extern NSString *PDLPuddingString_toJS(void);
extern NSString *PDLPuddingString_SUPER_AT(void);
extern NSString *PDLPuddingString_SUPER_(void);
extern NSString *PDLPuddingString_ORIG(void);
extern NSString *PDLPuddingString_NSBlock(void);

extern NSString *const PDLPuddingStringCore;
extern NSString *PDLPuddingStringBlockClassName(void);

extern NSString *PDLPuddingStringJP(void);
extern NSString *PDLPuddingStringJPAT(void);
extern NSString *PDLPuddingStringJPSuper(void);


NS_ASSUME_NONNULL_END
