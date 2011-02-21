//
//  GradientView.h
//  iPOS
//
//  Created by Steven McCoole on 2/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradientView : UIView 
{
	UIColor *startColor;
	UIColor *endColor;
}

@property (nonatomic, retain) UIColor *startColor;
@property (nonatomic, retain) UIColor *endColor;

- (void) setStart:(UIColor *)sColor andEndColor:(UIColor *)eColor;

@end
