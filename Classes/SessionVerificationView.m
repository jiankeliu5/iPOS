//
//  SessionVerificationView.m
//  iPOS
//
//  Created by Steven McCoole on 4/26/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "SessionVerificationView.h"
#import "UIView+ViewLayout.h"

#define LABEL_HEIGHT 40.0f
#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f

#pragma mark -
#pragma mark Private Interface
@interface SessionVerificationView ()
- (void) loadView;
- (void) dismissKeyboard:(id)sender;
- (void) dismissKeyboardWithCancel:(id)sender;
@end

#pragma mark -
@implementation SessionVerificationView

@synthesize delegate = _delegate;
@synthesize keyboardCancelled = _keyboardCancelled;
@synthesize currentFirstResponder = _currentFirstResponder;

#pragma mark Constructors
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    
    // Create all the components here.
	[self loadView];
    
    return self;
}

- (void) dealloc
{
	[self setCurrentFirstResponder:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Methods
- (void)layoutSubviews {
	self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    CGRect rect = self.bounds;
    
    CGRect frame = CGRectMake(floorf(rect.size.width * 0.05f), floorf(rect.size.height * 0.05f), floorf(rect.size.width * 0.90f), floorf(rect.size.height * 0.30f));
	_roundedView.frame = frame;
    [_roundedView applyDefaultRoundedStyle];
    [_roundedView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] 
                                                 endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    
    CGFloat spacing = floorf(_roundedView.bounds.size.height * 0.10);
	CGFloat cy = spacing;
	CGFloat width = floorf(_roundedView.bounds.size.width * 0.80f);
	_promptLabel.frame = CGRectMake(floorf((_roundedView.bounds.size.width - width) / 2.0f), cy, width, LABEL_HEIGHT);
	cy += (LABEL_HEIGHT + spacing);
	_passwordField.frame = CGRectMake(floorf((_roundedView.bounds.size.width - width) / 2.0f), cy, width, LABEL_HEIGHT);
	self.keyboardCancelled = NO;
}

- (void) loadView {
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    
	_roundedView = [[UIView alloc] initWithFrame:CGRectZero];
	
	_promptLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	_promptLabel.lineBreakMode = NSLineBreakByWordWrapping;
	_promptLabel.numberOfLines = 0;
	_promptLabel.backgroundColor = [UIColor clearColor];
	_promptLabel.textColor = [UIColor blackColor];
	_promptLabel.text = @"Enter password to validate session:";
	_promptLabel.textAlignment = NSTextAlignmentLeft;
	[_roundedView addSubview:_promptLabel];
	
	_passwordField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
	_passwordField.textColor = [UIColor blackColor];
	_passwordField.borderStyle = UITextBorderStyleRoundedRect;
	_passwordField.textAlignment = NSTextAlignmentLeft;
	_passwordField.clearsOnBeginEditing = YES;
	_passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passwordField.returnKeyType = UIReturnKeyGo;
	_passwordField.keyboardType = UIKeyboardTypeNumberPad;
    _passwordField.secureTextEntry = YES;
	_passwordField.delegate = self;
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissKeyboardWithCancel:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, cancelButton, nil] autorelease];
	[keyboardToolbar setItems:items];
	[_passwordField setInputAccessoryView:keyboardToolbar];
	[_roundedView addSubview:_passwordField];
	
	[self addSubview:_roundedView];
	[_roundedView release];
}

#pragma mark -
#pragma mark UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.currentFirstResponder = nil;
	if (self.keyboardCancelled == NO) {
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(verificationView:submitPassword:)]) {
			[self.delegate verificationView:self submitPassword:textField.text];
		}
	} else {
		self.keyboardCancelled = NO;
		if (self.delegate != nil && [self.delegate respondsToSelector:@selector(cancelVerificationView:)]) {
			[self.delegate cancelVerificationView:self];
		}
	}
	
}

- (void) dismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		self.keyboardCancelled = NO;
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void) dismissKeyboardWithCancel:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void) makePasswordFieldFirstResponder {
    if ([_passwordField canBecomeFirstResponder]) {
        [_passwordField becomeFirstResponder];
    }
}

@end
