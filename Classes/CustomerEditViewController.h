//
//  CustomerEditViewController.h
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "IBAFormViewController.h"
#import "OrderCart.h"

@interface CustomerEditViewController : IBAFormViewController {
	OrderCart *orderCart;
    iPOSFacade *facade;
    
	NSMutableDictionary *lastSavedCustomer;
	
}

@property (nonatomic, retain) NSMutableDictionary *lastSavedCustomer;

@end
