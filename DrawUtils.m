//
//  DrawUtils.m
//  iPOS
//
//  Created by Steven McCoole on 2/2/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "DrawUtils.h"

#pragma mark -
#pragma mark Private Interface
@interface DrawUtils ()
@end

#pragma mark -
@implementation DrawUtils

+ (void) drawLinearGradient:(CGContextRef) context withRect:(CGRect) rect startColor:(CGColorRef) startColor 
				   endColor:(CGColorRef) endColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
	
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, 
														(CFArrayRef) colors, locations);
	
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

+ (CGRect) rectFor1PxStroke:(CGRect)rect
{
	return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, 
					  rect.size.width - 1, rect.size.height - 1);
	
}

+ (void) draw1PxStroke:(CGContextRef) context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(CGColorRef) color {
	CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);  
}

@end
