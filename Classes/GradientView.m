//
//  GradientView.m
//  iPOS
//
//  Created by Steven McCoole on 2/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "GradientView.h"
#import "DrawUtils.h"

#pragma mark -
#pragma mark Private Interface
@interface GradientView ()
@end

#pragma mark -
@implementation GradientView

@synthesize startColor;
@synthesize endColor;

#pragma mark Constructors
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    return self;
}

- (void) dealloc
{
	[self setEndColor:nil];
	[self setStartColor:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIColor *)startColor {
	return startColor;
}

- (void) setStartColor:(UIColor *)color {
	if (startColor != color) {
		[startColor autorelease];
		startColor = [color	retain];
		[self setNeedsDisplay];
	}
}

- (UIColor *)endColor {
	return endColor;
}

- (void) setEndColor:(UIColor *)color {
	if (endColor != color) {
		[endColor autorelease];
		endColor = [color retain];
		[self setNeedsDisplay];
	}
}

- (void) setStart:(UIColor *)sColor andEndColor:(UIColor *)eColor {
	if (startColor != sColor) {
		[startColor autorelease];
		startColor = [sColor retain];
	}
	if (endColor != eColor) {
		[endColor autorelease];
		endColor = [eColor retain];
	}
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Methods

- (void)drawRect:(CGRect)rect {
	// Put anything here you need to draw on the view or set in the background.
	
	if (startColor != nil && endColor != nil) {
		
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect paperRect = self.bounds;
	
	[DrawUtils drawLinearGradient:context withRect:paperRect startColor:startColor.CGColor endColor:endColor.CGColor];

	/*	
	CGRect strokeRect = paperRect;
	strokeRect.size.height -= 1;
	strokeRect = [DrawUtils rectFor1PxStroke:strokeRect];
	
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetLineWidth(context, 1.0);
	CGContextStrokeRect(context, strokeRect);
	*/
		
	}
	
}


@end
