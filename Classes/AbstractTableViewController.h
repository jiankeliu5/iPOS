//
//  AbstractTableViewController.h
//  selSheet
//
//  Created by Josh Walker on 2/10/12.
//  Copyright 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ExtUITextField.h"
#import "iPOSFacade.h"
#import "SelectionSheet.h"

@interface AbstractTableViewController : UIViewController {
	iPOSFacade *facade;    
    
    SelectionSheet *selSheet;
    
	UILabel *custPhoneLabel;
	UILabel *custNameLabel;
	UILabel *custZipLabel;
    
    UILabel *contPhoneLabel;
	UILabel *contNameLabel;
	UILabel *contZipLabel;
    
	
    /*	UITableView *orderTable;
     
     UIToolbar *toolBar;
     
     UIBarButtonItem *searchButton;
     UIBarButtonItem *custButton;
     UIBarButtonItem *logoutButton;
     */
    UIBarButtonItem *cancelEditButton;
    
    UIButton *commitEditsButton;
	UILabel *markDeleteLabel;
	UILabel *markCloseLabel;
	UIView *editHeaderView;
	
	BOOL multiEditMode;
	NSInteger countMarkedDelete;
	NSInteger countMarkedClose;
	
}

@property (nonatomic, retain) iPOSFacade *facade;
@property (nonatomic, retain) SelectionSheet *selSheet;
@property (nonatomic, retain) UITableView *orderTable;
@property (nonatomic, retain) UIToolbar *toolBar;

@property (nonatomic, retain) UIBarButtonItem *searchButton;
@property (nonatomic, retain) UIBarButtonItem *custButton;
@property (nonatomic, retain) UIBarButtonItem *logoutButton;
@property (nonatomic, retain) UIBarButtonItem *emailButton;
//@property (nonatomic, retain) UIBarButtonItem *projNameButton;
//@property (nonatomic, retain) UIBarButtonItem *cancelEditButton;



- (void) layoutView: (UIInterfaceOrientation) orientation;

- (void) sendSheetAsEmail:(id)sender;
- (void) addOrEditCustomer:(id)sender;
- (void) addOrEditContractor:(id)sender;

- (void) cancelOrderAndLogout:(id) sender;

@end