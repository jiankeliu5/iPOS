//
//  ReceiptOptionsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderCart.h"

@interface ReceiptViewController : UIViewController {
    OrderCart *orderCart;
	iPOSFacade *facade;
}

@end
