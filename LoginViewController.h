//
//  LoginViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/1/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> 
{
	UIImageView *iPosLogo;
	UIImageView *tileShopLogo;
	
	UITableView *loginEntryView;
	UITextField *empIdField;
	UITextField *passwordField;
	
	UIView *containerView;

	// I'm assuming at some point we will have a domain/model object for this?  For now
	// I just need somewhere to put this info that has accessors on it.  SMM
	NSString *empId;
	NSString *password;
	NSString *storeId;
}

@property (nonatomic, retain) UIImageView *iPosLogo;
@property (nonatomic, retain) UIImageView *tileShopLogo;

@property (nonatomic, retain) UITableView *loginEntryView;
@property (nonatomic, retain) UITextField *empIdField;
@property (nonatomic, retain) UITextField *passwordField;

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, retain) NSString *empId;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *storeId;

@end
