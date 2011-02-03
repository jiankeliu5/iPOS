//
//  LayoutUtils.m
//  iPOS
//
//  Created by Steven McCoole on 2/3/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "LayoutUtils.h"

#pragma mark -
#pragma mark Private Interface
@interface LayoutUtils ()
@end

#pragma mark -
@implementation LayoutUtils

+ (CGRect) rectPercent:(CGRect)rect startX:(float)sx startY:(float)sy percentWidth:(float)pw percentHeight:(float)ph 
{
	float newX = rect.origin.x + floorf(rect.size.width * (sx / 100.0f));
	float newY = rect.origin.y + floorf(rect.size.height * (sy / 100.0f));
	float newW = floorf(rect.size.width * (pw / 100.0f));
	float newH = floorf(rect.size.height * (ph / 100.0f));
	return CGRectMake(newX, newY, newW, newH);
}

@end
