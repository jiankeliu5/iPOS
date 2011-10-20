//
//  UIScreen+Helpers.m
//  iPOS
//
//  Created by Torey Lomenda on 10/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "UIScreen+Helpers.h"

#define STATUSBAR_HEIGHT 20.0f
#define NAVBAR_HEIGHT_PORTRAIT 44.0f
#define NAVBAR_HEIGHT_LANDSCAPE 32.0f

@implementation UIScreen (Helpers)

+ (CGRect) rectForScreenView:(UIInterfaceOrientation)orientation {
    return [UIScreen rectForScreenView:orientation isNavBarVisible:NO];
}

+ (CGRect) rectForScreenView:(UIInterfaceOrientation)orientation isNavBarVisible:(BOOL)isNavBarVisible {
    CGRect viewFrame;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat statusBarHeight = STATUSBAR_HEIGHT;
    CGFloat navBarHeight = 0.0f;
    
    if (isNavBarVisible) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            navBarHeight = NAVBAR_HEIGHT_PORTRAIT;
        } else {
            navBarHeight = NAVBAR_HEIGHT_LANDSCAPE;
        }
    }
    
    if ([UIApplication sharedApplication].statusBarHidden) {
        statusBarHeight = 0.0f;
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        viewFrame = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height - statusBarHeight - navBarHeight);
    } else {
        viewFrame = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width - statusBarHeight - navBarHeight);
    }
    
    return viewFrame;
}


@end
