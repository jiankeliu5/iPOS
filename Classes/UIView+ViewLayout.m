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

@end
