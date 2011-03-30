//
//  UIViewController+ViewControllerLayout.m
//  iPOS
//
//  Created by Steven McCoole on 3/7/11.
//  Copyright 2011 NA. All rights reserved.
//

// NOTE: [[UIScreen mainScreen] applicationFrame] ALWAYS returns portrait orientation!
// This would have to be updated if the application needs to support landscape as well.
// May need to use self.navigationController.view.frame but I am not sure.

#import "UIViewController+ViewControllerLayout.h"


@implementation UIViewController (ViewControllerLayout)

- (CGFloat)navBarHeight {
	CGFloat barHeight = 0.0f;
	if (self.navigationController != nil) {
		barHeight = self.navigationController.navigationBarHidden ? 0.0f : self.navigationController.navigationBar.frame.size.height;
	}
	return barHeight;
}

- (CGFloat)tabBarHeight {
	CGFloat barHeight = 0.0f;
	if (self.tabBarController != nil) {
		barHeight = self.tabBarController.tabBar.frame.size.height;
	}
	return barHeight;
}

- (CGRect)rectForNav {
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	rect.size.height -= [self navBarHeight];
	return rect;
}

- (CGRect)rectForTab {
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	rect.size.height -= [self tabBarHeight];
	return rect;
}

- (CGRect)rectForNavAndTab {
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	rect.size.height -= ([self navBarHeight] + [self tabBarHeight]);
	return rect;
}

- (CGPoint)centerAt:(CGFloat) y {
	return CGPointMake(self.view.bounds.size.width / 2.0f, y);
}

@end
