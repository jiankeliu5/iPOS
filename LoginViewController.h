//
//  LoginViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/1/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iPOSFacade.h"
#import "OrderCart.h"
#import "LineaSDK.h"

@interface LoginViewController : UIViewController <LineaDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
	
	// I'm assuming at some point we will have a domain/model object for this?  For now
	// I just need somewhere to put this info that has accessors on it.  SMM
	NSString *empId;
	NSString *password;
	NSString *storeId;
	NSString *deviceId;

	UITableView *loginTableView;
	id currentFirstResponder;
	BOOL keyboardCancelled;
	NSIndexPath *topRowBeforeKeyboardShown;
	
   	iPOSFacade *facade;
    OrderCart *orderCart;
    
    Linea *linea;
}

@property (nonatomic, copy) NSString *empId;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, copy) NSString *deviceId;

@property (nonatomic, retain) id currentFirstResponder;
@property (nonatomic, assign) BOOL keyboardCancelled;

@end
