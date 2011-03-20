//
//  CustomerViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iPOSFacade.h"
#import "ExtUITextField.h"
#import "MOGlassButton.h"

#import "Customer.h"

#define START_Y 40.0f
#define SPACING 20.0f
#define TEXT_FIELD_HEIGHT 30.0f
#define TEXT_FIELD_WIDTH 200.0f
#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 100.0f
#define LABEL_FONT_SIZE 12.0f
#define LABEL_HEIGHT 12.0f
#define LABEL_SPACING 7.0f
#define DETAIL_VIEW_X 10.0f
#define DETAIL_VIEW_WIDTH 300.0f
#define DETAIL_VIEW_HEIGHT 77.0f
#define DETAIL_LABEL_X 0.0f
#define DETAIL_LABEL_WIDTH 40.0f
#define DETAIL_DATA_X 40.0f
#define DETAIL_DATA_WIDTH 260.0f
#define CONFIRM_BUTTON_X 180.0f

@interface CustomerViewController : UIViewController <UITextFieldDelegate> {
	
	iPOSFacade *facade;

	ExtUITextField *custPhoneField;
	NSString *phoneMask;
	MOGlassButton *custSearchButton;
	MOGlassButton *confirmButton;
	UIImage *numberPadDoneImageNormal;
    UIImage *numberPadDoneImageHighlighted;
    UIButton *numberPadDoneButton;
	
	UIView *detailView;
	UILabel *firstLabel;
	UILabel *firstName;
	UILabel *lastLabel;
	UILabel *lastName;
	UILabel *emailLabel;
	UILabel *email;
	UILabel *zipLabel;
	UILabel *zip;
	
	BOOL custDetailsOpen;
	id currentFirstResponder;
	
	Customer *customer;
	
}

@property (nonatomic, retain) NSString *phoneMask;
@property (nonatomic, retain) UIImage *numberPadDoneImageNormal;
@property (nonatomic, retain) UIImage *numberPadDoneImageHighlighted;
@property (nonatomic, retain) UIButton *numberPadDoneButton;
@property (nonatomic, retain) id currentFirstResponder;

- (void)numberPadDoneButton:(id)sender;

@end
