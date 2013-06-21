//
//  SSCheckoutCustomerEditViewController.h
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "IBAFormViewController.h"
#import "SSOrderCart.h"
#import "Items.h"
#import "ItemSet.h"

@interface SSCheckoutCustomerEditViewController : IBAFormViewController {
	SSOrderCart *orderCart;
    iPOSFacade *facade;
    
	NSMutableDictionary *lastSavedCustomer;
	
}

@property (nonatomic, retain) NSMutableDictionary *lastSavedCustomer;
@property (nonatomic, retain) NSMutableArray *itemDescription;
@property (nonatomic, retain) NSMutableArray *itemSku;
@property (nonatomic, retain) NSMutableArray *itemQty;
@property (nonatomic, retain) NSMutableArray *itemUOM;

@end

