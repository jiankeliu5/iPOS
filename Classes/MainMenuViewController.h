//
//  MainMenuViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "AddItemView.h"
#import "SignatureViewController.h"
#import "MOGlassButton.h"

#import "OrderCart.h"
#import "LineaSDK.h"

#import "FPPopoverController.h"

@interface MainMenuViewController : ExtUIViewController <LineaDelegate, ExtUIViewControllerDelegate, AddItemViewDelegate, FPPopoverControllerDelegate> {
	iPOSFacade *facade;
	
    OrderCart *orderCart;
    
	UILabel *scanItemLabel;
	ExtUITextField *lookupItemNameField;
	ExtUITextField *lookupItemSkuField;
	MOGlassButton *customerButton;
	MOGlassButton *cartButton;
    UIBarButtonItem *orderLookupButton;
    
    AddItemView *addItemOverlay;
    
    Linea *linea;
    
    UILabel *VersionLabel;
    FPPopoverController *popover;
	
}

-(IBAction)goToTableView:(id)sender;
-(IBAction)navControllerPopover:(id)sender;

-(void)selectedTableRow:(NSUInteger)rowNum;


-(IBAction)noArrow:(id)sender;
-(IBAction)popover:(id)sender;

@end
