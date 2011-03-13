//
//  CustomerView.h
//  iPOS
//
//  Created by Steven McCoole on 3/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ExtUITextField.h"
#import "MOGlassButton.h"

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
#define DETAIL_LABEL_WIDTH 80.0f
#define DETAIL_DATA_X 90.0f
#define DETAIL_DATA_WIDTH 210.0f
#define CONFIRM_BUTTON_X 180.0f


@interface CustomerView : UIView {

	ExtUITextField *custPhoneField;
	MOGlassButton *custSearchButton;
	MOGlassButton *custNewButton;
	MOGlassButton *custEditButton;
	MOGlassButton *confirmButton;
	
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
	
}

@property (nonatomic, assign) ExtUITextField *custPhoneField;
@property (nonatomic, assign) MOGlassButton *custSearchButton;
@property (nonatomic, assign) MOGlassButton *custNewButton;
@property (nonatomic, assign) MOGlassButton *custEditButton;
@property (nonatomic, assign) MOGlassButton *confirmButton;
@property (nonatomic, assign) BOOL custDetailsOpen;

@end
