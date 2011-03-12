//
//  NSString+Base64Encode.h
//  iPOS
//
//  Created by Torey Lomenda on 3/11/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Base64Encode) 

+(NSString *) encodeBase64WithData:(NSData *)objData;
+(NSData *) decodeBase64WithString:(NSString *)strBase64;

@end
