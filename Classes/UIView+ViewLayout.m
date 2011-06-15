//
//  UIView+ViewLayout.m
//  iPOS
//
//  Created by Steven McCoole on 3/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "UIView+ViewLayout.h"


@implementation UIView (ViewLayout)

- (CGPoint)centerAt:(CGFloat) y {
	return CGPointMake(self.bounds.size.width / 2.0f, y);
}

- (void) setAllAutoresizingMask {
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void) applyDefaultRoundedStyle {
    [self applyRoundedStyle: [UIColor lightGrayColor] withShadow:YES];
}

- (void) applyRoundedStyle: (UIColor *)borderColor withShadow: (BOOL) doApplyShadow {
    self.clipsToBounds = NO;
    
    CALayer *round = [CALayer layer];
	round.name = @"rounded";
    round.frame = self.bounds;
    // Round the corners
    round.masksToBounds = YES;
    round.cornerRadius = 5.0f;
    // Set the borders
    round.borderWidth = 1.0f;
    round.borderColor = [borderColor CGColor];
    [self.layer insertSublayer:round atIndex:0];
    
    // Add the drop shadow
    if (doApplyShadow) {
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.layer.shadowOpacity = 0.80f;
        self.layer.shadowRadius = 5.0f;
    }
}


- (void) applyShineGradientToBackgroundWithColor:(UIColor *)color {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    // Get the RGB components for the color passed in.
    const CGFloat *cs = CGColorGetComponents(color.CGColor);
    
    // Create the colors for the gradient
    gradient.colors = [NSArray arrayWithObjects:
                    (id)[color CGColor],
                    (id)[[UIColor colorWithRed:0.98f*cs[0] green:0.98*cs[1] blue:0.98*cs[2] alpha:1.0f] CGColor],
                    (id)[[UIColor colorWithRed:0.95f*cs[0] green:0.95*cs[1] blue:0.95*cs[2] alpha:1.0f] CGColor],
                    (id)[[UIColor colorWithRed:0.93f*cs[0] green:0.93*cs[1] blue:0.93*cs[2] alpha:1.0f] CGColor],
                    nil];
    
    gradient.locations = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:0.0f],
                       [NSNumber numberWithFloat:0.49f],
                       [NSNumber numberWithFloat:0.51f],
                       [NSNumber numberWithFloat:1.0f],
                       nil];
    
    gradient.frame = self.bounds;
	
    CALayer *roundLayer = nil;
	for (CALayer *l in self.layer.sublayers) {
		if ([l.name isEqualToString:@"rounded"]) {
			roundLayer = l;
			break;
		}
	}
	if (roundLayer != nil) {
		[roundLayer addSublayer:gradient];
	} else {
		[self.layer insertSublayer:gradient atIndex:0];
	}
}

- (void) applyGradientToBackgroundWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    CAGradientLayer *gradient = [CAGradientLayer layer];
	
    // Create the colors for the gradient
    gradient.colors = [NSArray arrayWithObjects:
                    (id)[startColor CGColor],
                    (id)[endColor CGColor],
                    nil];
    
    gradient.locations = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:0.0f],
                       [NSNumber numberWithFloat:1.0f],
                       nil];
    
    gradient.frame = self.bounds;
	
	CALayer *roundLayer = nil;
	for (CALayer *l in self.layer.sublayers) {
		if ([l.name isEqualToString:@"rounded"]) {
			roundLayer = l;
			break;
		}
	}
	if (roundLayer != nil) {
		[roundLayer addSublayer:gradient];
	} else {
		[self.layer insertSublayer:gradient atIndex:0];
	}
}

#pragma mark -
#pragma mark Transformation Methods
- (void) rotateView:(NSInteger)degrees animated:(BOOL)isAnimated {
    
    if (isAnimated) {
        [UIView beginAnimations:nil context:NULL];
    }
    
    self.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180.0);
    
    if (isAnimated) {
        [UIView commitAnimations];
    }
}
@end
