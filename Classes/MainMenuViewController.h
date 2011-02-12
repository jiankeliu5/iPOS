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
	UIButton *lookupItemButton;
	UIButton *lookupOrderButton;
	UIButton *customerButton;
}

@property (nonatomic, retain) UILabel *scanItemLabel;
@property (nonatomic, retain) UIButton *lookupItemButton;
@property (nonatomic, retain) UIButton *lookupOrderButton;
@property (nonatomic, retain) UIButton *customerButton;

@end
