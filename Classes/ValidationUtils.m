//
//  ValidationUtils.m
//  iPOS
//
//  Created by Steven McCoole on 6/25/13.
//
//

#import "ValidationUtils.h"

@interface ValidationUtils ()
@end

@implementation ValidationUtils

+ (BOOL)validateEmail:(NSString *)emailStr {
    if (emailStr != nil && emailStr.length > 0) {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        return [emailTest evaluateWithObject:emailStr];
    } else {
        return NO;
    }
}

@end
