//
//  UIScreen+Helpers.h
//  iPOS
//
//  Created by Torey Lomenda on 10/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (Helpers)

+ (CGRect) rectForScreenView: (UIInterfaceOrientation) orientation;
+ (CGRect) rectForScreenView: (UIInterfaceOrientation) orientation isNavBarVisible: (BOOL) isNavBarVisible;

@end
