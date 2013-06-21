//
//  ProfitMarginViewController.h
//  iPOS
//
//  Created by Dan C on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "MOGlassButton.h"
#import "Order.h"

@protocol ProfitMarginViewDelegate
-(void)exit:(id) sender;
@end



@interface ProfitMarginViewController : UIViewController
{
    Order *order;
    id<ProfitMarginViewDelegate> delegate;
    MOGlassButton *doneButton;
    
}
    
@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) Order *order;

@end
