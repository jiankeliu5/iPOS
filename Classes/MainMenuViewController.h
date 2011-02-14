//
//  MainMenuViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPOSFacade.h"

@interface MainMenuViewController : UIViewController {
	iPOSFacade *facade;
	
	UILabel *scanItemLabel;
	UITextField *lookupItemField;
	UIButton *lookupOrderButton;
	UIButton *customerButton;
	
	NSString *lookupItemSku;
	NSString *scannedItemSku;
	
}

@property (nonatomic, retain) UILabel *scanItemLabel;
@property (nonatomic, retain) UITextField *lookupItemField;
@property (nonatomic, retain) UIButton *lookupOrderButton;
@property (nonatomic, retain) UIButton *customerButton;

@property (nonatomic, copy) NSString *lookupItemSku;
@property (nonatomic, copy) NSString *scannedItemSku;

@end
