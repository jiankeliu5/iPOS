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
@synthesize custNewButton;
@synthesize custEditButton;
@synthesize confirmButton;
@synthesize custDetailsOpen;

#pragma mark Constructors
- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) {
		return nil;
	}
	
	// Allocate and add all our components to the view
	[self setupComponents];
	
	custDetailsOpen = NO;
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (BOOL) custDetailsOpen {
	return custDetailsOpen;
}

- (void) setCustDetailsOpen:(BOOL)isOpen {
	custDetailsOpen = isOpen;
	[self setNeedsLayout];
}

#pragma mark -
#pragma mark Methods
- (void) layoutSubviews {
	self.backgroundColor = [UIColor	colorWithWhite:0.85f alpha:1.0f];
	
	CGFloat width = self.bounds.size.width;
	
	CGFloat cy = START_Y;
	custPhoneField.center = [self centerAt:cy];
	
	if (custDetailsOpen == NO) {
		cy += TEXT_FIELD_HEIGHT + SPACING;
		detailView.hidden = YES;
		custNewButton.hidden = YES;
		custEditButton.hidden = YES;
		custSearchButton.center = [self centerAt:cy];
	} else {
		cy += TEXT_FIELD_HEIGHT;
		detailView.frame = CGRectMake(DETAIL_VIEW_X, cy, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT);
		detailView.hidden = NO;
		cy += DETAIL_VIEW_HEIGHT + SPACING;
		CGFloat buttonSpace = floorf((width - BUTTON_WIDTH * 3.0f) / 4.0f);
		custEditButton.frame = CGRectMake(buttonSpace, cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		custEditButton.hidden = NO;
		custSearchButton.frame = CGRectMake(((buttonSpace * 2.0f) + BUTTON_WIDTH), cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		custNewButton.frame = CGRectMake((buttonSpace * 3.0f) + (BUTTON_WIDTH * 2.0f), cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		custNewButton.hidden = NO;
	}


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

	// Set up the detail view for showing customer summary information when fetched by the search.
	detailView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT)];
	
	CGFloat dy = LABEL_SPACING;
	firstLabel = [self createNormalLabel:@"First Name" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstLabel];
	[firstLabel release];
	firstName = [self createBoldLabel:@"Megan" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstName];
	[firstName release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	lastLabel = [self createNormalLabel:@"Last Name" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastLabel];
	[lastLabel release];
	lastName = [self createBoldLabel:@"Hoy" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastName];
	[lastName release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	emailLabel = [self createNormalLabel:@"Email Address" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:emailLabel];
	[emailLabel release];
	email = [self createBoldLabel:@"Mhoy@tileshop.com" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:email];
	[email release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	zipLabel = [self createNormalLabel:@"Zip Code" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zipLabel];
	[zipLabel release];
	zip = [self createBoldLabel:@"55441" withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zip];
	[zip release];
	
	detailView.hidden = YES;
	[self addSubview:detailView];
	[detailView release];
	
	custNewButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custNewButton setupAsSmallBlackButton];
	custNewButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custNewButton setTitle:@"Enter New" forState:UIControlStateNormal];
	custNewButton.hidden = YES;
	[self addSubview:custNewButton];
	[custNewButton release];
	
	custEditButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custEditButton setupAsSmallBlackButton];
	custEditButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custEditButton setTitle:@"Edit" forState:UIControlStateNormal];
	custEditButton.hidden = YES;
	[self addSubview:custEditButton];
	[custEditButton release];
	
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
