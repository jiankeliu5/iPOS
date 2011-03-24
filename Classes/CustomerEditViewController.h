//
//  CustomerEditViewController.h
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "IBAFormViewController.h"
#import "iPOSFacade.h"

@interface CustomerEditViewController : IBAFormViewController {

	iPOSFacade *facade;
	NSMutableDictionary *lastSavedCustomer;
	
}

@property (nonatomic, retain) NSMutableDictionary *lastSavedCustomer;

@end
