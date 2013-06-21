//
//  HHTabListViewController.m
//  iPOS
//
//  Created by Enning Tang on 2/8/13.
//
//

#import "HHTabListContainerView.h"

#import <QuartzCore/QuartzCore.h>


@implementation HHTabListContainerView

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self) {
		self.clipsToBounds = NO;
		self.backgroundColor = [UIColor whiteColor];
		self.opaque = YES;
    }
    return self;
}


#pragma mark -
#pragma mark Instance methods

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CALayer *layer = self.layer;
	
	layer.shadowOffset = CGSizeZero;
	layer.shadowOpacity = 0.75f;
	layer.shadowRadius = 10.0f;
	layer.shadowColor = [UIColor blackColor].CGColor;
	layer.shadowPath = [UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
}

@end
