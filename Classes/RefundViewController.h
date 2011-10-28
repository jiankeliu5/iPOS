//
//  RefundViewController.h
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPOSFacade.h"
#import "OrderCart.h"

#import "RefundView.h"

@interface RefundViewController : UIViewController<RefundViewDelegate> {
    iPOSFacade *facade;
    OrderCart *orderCart;
}

@property (nonatomic, assign) iPOSFacade *facade;
@property (nonatomic, assign) OrderCart *orderCart;

@end
