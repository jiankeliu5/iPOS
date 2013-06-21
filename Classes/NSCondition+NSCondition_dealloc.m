//
//  NSCondition+NSCondition_dealloc.m
//  iPOS
//
//  Created by Enning Tang on 12/3/12.
//
//
#import <objc/runtime.h>

#import "NSCondition+NSCondition_dealloc.h"

@implementation NSCondition (NSCondition_dealloc)

- (void) safeDealloc
{
    NSLog(@"NSCONDITION DEALLOC CALLED");
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
    {
        [self safeDealloc];
    }
}

+ (void)load {
    //method_exchangeImplementations(class_getInstanceMethod(self, @selector(dealloc)), class_getInstanceMethod(self, @selector(safeDealloc)));
}


@end