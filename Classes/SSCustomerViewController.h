//
//  CustomerViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "iPOSFacade.h"


@interface SSCustomerViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
	
	iPOSFacade *facade;    
    // SelectionSheet *selSheet;
    
	ExtUITextField *custPhoneField;
    ExtUITextField *custNameField;
    
	
}

// @property (nonatomic, retain) Customer *customer;
@property (nonatomic, assign) BOOL contractor;

@end
