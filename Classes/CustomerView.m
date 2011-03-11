//
//  CustomerView.m
//  iPOS
//
//  Created by Steven McCoole on 3/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerView.h"
#import "UIView+ViewLayout.h"

#pragma mark -
#pragma mark Private Interface
@interface CustomerView ()
- (void) setupComponents;
- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect;
- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect;
@end

#pragma mark -
@implementation CustomerView

@synthesize custPhoneField;
@synthesize custSearchButton;
@synthesize enterNewButton;
@synthesize confirmButton;

#pragma mark Constructors
- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) {
		return nil;
	}
	
	// Allocate and add all our components to the view
	[self setupComponents];
	
	return self;
}

- (void) dealloc {
	[detailView release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors


#pragma mark -
#pragma mark Methods
- (void) layoutSubviews {
	self.backgroundColor = [UIColor	colorWithWhite:0.85f alpha:1.0f];
	
	CGFloat cy = START_Y;
	custPhoneField.center = [self centerAt:cy];

	cy += TEXT_FIELD_HEIGHT + SPACING;
	
	custSearchButton.center = [self centerAt:cy];

}

- (void) setupComponents {
	custPhoneField = [[ExtUITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT)];
	custPhoneField.textColor = [UIColor blackColor];
	custPhoneField.borderStyle = UITextBorderStyleRoundedRect;
	custPhoneField.textAlignment = UITextAlignmentCenter;
	custPhoneField.clearsOnBeginEditing = YES;
	custPhoneField.placeholder = @"Phone Number";
	custPhoneField.tagName = @"CustPhone";
	custPhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	custPhoneField.returnKeyType = UIReturnKeyGo;
	custPhoneField.keyboardType = UIKeyboardTypeNumberPad;
	[self addSubview:custPhoneField];
	[custPhoneField release];
	
	custSearchButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custSearchButton setupAsSmallBlackButton];
	custSearchButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custSearchButton setTitle:@"Search" forState:UIControlStateNormal];
	[self addSubview:custSearchButton];
	[custSearchButton release];
	
	detailView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT)];
	firstLabel = [self createNormalLabel:@"First Name" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstLabel];
	firstName = [self createBoldLabel:@"Megan" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstName];
	lastLabel = [self createNormalLabel:@"Last Name" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastLabel];
	lastName = [self createBoldLabel:@"Hoy" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastName];
	emailLabel = [self createNormalLabel:@"Email Address" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:emailLabel];
	email = [self createBoldLabel:@"Mhoy@tileshop.com" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:email];
	zipLabel = [self createNormalLabel:@"Zip Code" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zipLabel];
	zip = [self createBoldLabel:@"55441" withRect:CGRectMake(0.0f, 0.0f, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zip];
}

- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label;
	label = [[UILabel alloc] initWithFrame:rect];
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = UITextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label = [self createNormalLabel:text withRect:rect];
	label.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

@end
