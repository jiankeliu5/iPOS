//
//  DrawUtils.h
//  iPOS
//
//  Created by Steven McCoole on 2/2/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawUtils : NSObject 
{

}

+ (void) drawLinearGradient:(CGContextRef) context withRect:(CGRect) rect startColor:(CGColorRef) startColor 
				   endColor:(CGColorRef) endColor;

+ (CGRect) rectFor1PxStroke:(CGRect)rect;
+ (void) draw1PxStroke:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(CGColorRef) color;

@end
