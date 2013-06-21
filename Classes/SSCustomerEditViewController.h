//
//  CustomerEditViewController.h
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "IBAFormViewController.h"
#import "iPOSFacade.h"
#import "SelectionSheet.h"
#import "SSOrderCart.h"

@interface SSCustomerEditViewController : IBAFormViewController {
	iPOSFacade *facade;    
    SelectionSheet *selSheet;
    SSOrderCart *orderCart;
    
	NSMutableDictionary *lastSavedCustomer;
	
}

@property (nonatomic, retain) NSMutableDictionary *lastSavedCustomer;
@property (nonatomic, assign) BOOL contractor;


@end
