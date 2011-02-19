//
//  MainMenuViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUITextField.h"

#import "iPOSFacade.h"
#import "LineaSDK.h"

@interface MainMenuViewController : UIViewController <LineaDelegate> {
	iPOSFacade *facade;
	
	UILabel *scanItemLabel;
	ExtUITextField *lookupItemField;
	ExtUITextField *lookupOrderField;
	UIButton *customerButton;
	
	id currentFirstResponder;
	CGFloat previousViewOriginY;
	
	NSString *lookupItemSku;
	NSString *scannedItemSku;
	NSString *lookupOrderNum;
    
    Linea *linea;
	
}

@property (nonatomic, retain) UILabel *scanItemLabel;
@property (nonatomic, retain) ExtUITextField *lookupItemField;
@property (nonatomic, retain) ExtUITextField *lookupOrderField;
@property (nonatomic, retain) UIButton *customerButton;

@property (nonatomic, retain) id currentFirstResponder;

@property (nonatomic, copy) NSString *lookupItemSku;
@property (nonatomic, copy) NSString *scannedItemSku;
@property (nonatomic, copy) NSString *lookupOrderNum;

@end
