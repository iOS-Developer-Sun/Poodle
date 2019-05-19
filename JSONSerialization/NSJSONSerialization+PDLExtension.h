//
//  NSJSONSerialization+PDLExtension.h
//  Sun
//
//  Created by Sun on 16/6/1.
//  Copyright © 2016 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PDLJSONSerialization)

@property (readonly) id pdl_JSONObject;

@end

@interface NSData (PDLJSONSerialization)

@property (readonly) id pdl_JSONObject;

@end

@interface NSArray (PDLJSONSerialization)

@property (readonly) NSData *pdl_JSONData;
@property (readonly) NSString *pdl_JSONString;

@end

@interface NSDictionary (PDLJSONSerialization)

@property (readonly) NSData *pdl_JSONData;
@property (readonly) NSString *pdl_JSONString;

@end
