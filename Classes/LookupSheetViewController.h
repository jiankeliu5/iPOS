//
//  LookupSelectionsViewController.h
//  iPOS
//
//  Created by Enning Tang on 7/24/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "MOGlassButton.h"
#import "iPOSFacade.h"
#import "SelectionSheet.h"


@interface LookupSheetViewController : ExtUIViewController <ExtUIViewControllerDelegate>
{
    iPOSFacade *facade;
    SelectionSheet *selSheet;
}

@property (nonatomic, retain) UIBarButtonItem *closeBarButton;
@property (nonatomic, retain) ExtUITextField *lookupCustomerField;
@property (nonatomic, retain) ExtUITextField *lookupContractorField;
@property (nonatomic, retain) ExtUITextField *lookupProjectField;

@property (nonatomic, retain) UISwitch *archivedSwitch;
@property (nonatomic, retain) UILabel *archiveLabel;

@property (nonatomic, retain) MOGlassButton *searchButton;

@end
