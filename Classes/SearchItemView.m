//
//  SearchItemView.m
//  iPOS
//
//  Created by Steven McCoole on 4/2/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "SearchItemView.h"
#import <QuartzCore/QuartzCore.h>

#define ROUND_VIEW_X 20.0f
#define ROUND_VIEW_Y 7.0f
#define ROUND_VIEW_WIDTH 280.0f
#define ROUND_VIEW_HEIGHT 140.0f
#define LABEL_HEIGHT 40.0f
#define TEXT_FIELD_HEIGHT 40.0f
#define SPACING_HEIGHT 20.0f
#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f

#pragma mark -
#pragma mark Private Interface
@interface SearchItemView ()
- (void) loadView;
- (void) dismissKeyboard:(id)sender;
@end

#pragma mark -
@implementation SearchItemView

@synthesize delegate;
@synthesize keyboardCancelled;
@synthesize currentFirstResponder;

#pragma mark Constructors
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
	
	// Create all the components here.
	[self loadView];
	
    return self;
}

- (void) dealloc
{
	[self setDelegate:nil];
	[self setCurrentFirstResponder:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Methods
- (void)layoutSubviews {
	self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
	roundedView.frame = CGRectMake(ROUND_VIEW_X, ROUND_VIEW_Y, ROUND_VIEW_WIDTH, ROUND_VIEW_HEIGHT);
	CGFloat cy = floorf(SPACING_HEIGHT / 2.0f);
	CGFloat width = floorf(roundedView.bounds.size.width * 0.60f);
	lookupSkuLabel.frame = CGRectMake(floorf((roundedView.bounds.size.width - width) / 2.0f), cy, width, LABEL_HEIGHT);
	cy += (LABEL_HEIGHT + SPACING_HEIGHT);
	lookupSkuField.frame = CGRectMake(floorf((roundedView.bounds.size.width - width) / 2.0f), cy, width, LABEL_HEIGHT);
	self.keyboardCancelled = NO;
}

- (void) loadView {
	roundedView = [[GradientView alloc] initWithFrame:CGRectZero];
	[roundedView.layer setCornerRadius:5.0f];
	[roundedView.layer setMasksToBounds:YES];
	[roundedView.layer setBorderWidth:1.0f];
	[roundedView.layer setBorderColor:[[UIColor blackColor] CGColor]];
	[roundedView setStart:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] andEndColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
	
	lookupSkuLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	lookupSkuLabel.backgroundColor = [UIColor clearColor];
	lookupSkuLabel.textColor = [UIColor blackColor];
	lookupSkuLabel.text = @"Manual SKU Lookup";
	lookupSkuLabel.textAlignment = UITextAlignmentCenter;
	[roundedView addSubview:lookupSkuLabel];
	
	lookupSkuField = [[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease];
	lookupSkuField.textColor = [UIColor blackColor];
	lookupSkuField.borderStyle = UITextBorderStyleRoundedRect;
	lookupSkuField.textAlignment = UITextAlignmentCenter;
	lookupSkuField.clearsOnBeginEditing = YES;
	lookupSkuField.placeholder = @"Look Up Item";
	lookupSkuField.tagName = @"LookupItem";
	lookupSkuField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	lookupSkuField.returnKeyType = UIReturnKeyGo;
	lookupSkuField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	lookupSkuField.delegate = self;
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, nil] autorelease];
	[keyboardToolbar setItems:items];
	[lookupSkuField setInputAccessoryView:keyboardToolbar];
	[roundedView addSubview:lookupSkuField];
	
	[self addSubview:roundedView];
	[roundedView release];
}

#pragma mark -
#pragma mark ExtUITextField delegates
- (BOOL)textFieldShouldBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textFieldDidEndEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = nil;
	if (self.keyboardCancelled == NO && textField.text != nil) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(searchItem:withSku:)]) {
			[self.delegate searchItem:self withSku:[NSString stringWithString:textField.text]];
		}
	} else {
		self.keyboardCancelled = NO;
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(cancelSearchItem:)]) {
			[self.delegate cancelSearchItem:self];
		}
	}
	
}

- (void) dismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
		[self.currentFirstResponder resignFirstResponder];
	}
}

@end
