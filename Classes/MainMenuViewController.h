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

@interface MainMenuViewController : ExtUIViewController <LineaDelegate, ExtUIViewControllerDelegate, AddItemViewDelegate> {
	iPOSFacade *facade;
	
    OrderCart *orderCart;
    
	UILabel *scanItemLabel;
	ExtUITextField *lookupItemNameField;
	ExtUITextField *lookupItemSkuField;
	MOGlassButton *customerButton;
	MOGlassButton *cartButton;
    
    Linea *linea;
	
}

@end
