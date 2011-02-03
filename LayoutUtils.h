//
//  LayoutUtils.h
//  iPOS
//
//  Created by Steven McCoole on 2/3/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayoutUtils : NSObject 
{

}

+ (CGRect) rectPercent:(CGRect)rect startX:(float)sx startY:(float)sy percentWidth:(float)pw percentHeight:(float)ph;

@end
