//
//  UIView+ViewLayout.h
//  iPOS
//
//  Created by Steven McCoole on 3/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (ViewLayout)

- (CGPoint) centerAt:(CGFloat) y;
- (void) setAllAutoresizingMask;
- (void) applyDefaultRoundedStyle;
- (void) applyRoundedStyle: (UIColor *)borderColor withShadow: (BOOL) doApplyShadow;

- (void) applyShineGradientToBackgroundWithColor:(UIColor *)color;
- (void) applyGradientToBackgroundWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

- (void) removeLayerNamed: (NSString *) layerName;

#pragma mark Transformation Functions
- (void) rotateView:(NSInteger) degrees animated:(BOOL) isAnimated;

@end
