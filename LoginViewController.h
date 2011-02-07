//
//  LoginViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/1/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LoginView;

@interface LoginViewController : UIViewController
{
	
	// I'm assuming at some point we will have a domain/model object for this?  For now
	// I just need somewhere to put this info that has accessors on it.  SMM
	NSString *empId;
	NSString *password;
	NSString *storeId;
	NSString *deviceId;

	UITableView *loginTableView;
	id currentFirstResponder;
	NSIndexPath *topRowBeforeKeyboardShown;
	
}

@property (nonatomic, retain) NSString *empId;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *storeId;
@property (nonatomic, retain) NSString *deviceId;

@property (nonatomic, retain) UITableView *loginTableView;
@property (nonatomic, retain) id currentFirstResponder;

@end
