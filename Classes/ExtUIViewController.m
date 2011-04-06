//
//  ExtUIViewController.m
//  iPOS
//
//  Created by Steven McCoole on 3/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "ExtUIViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface ExtUIViewController ()
- (CGRect) swapRect:(CGRect)rect;
- (void) formatInput:(ExtUITextField*)aTextField string:(NSString*)aString range:(NSRange)aRange;
@end

#pragma mark -
@implementation ExtUIViewController

@synthesize currentFirstResponder, keyboardCancelled, previousViewOriginY;
@synthesize delegate;

#pragma mark Constructors
- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self setCurrentFirstResponder:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView {
	return (UIView *)[self view];
}

#pragma mark -
#pragma mark UIViewController overrides

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated {
	self.keyboardCancelled = NO;
	
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
	[self addKeyboardListeners];
}

- (void) viewWillDisappear:(BOOL)animated {
	[self removeKeyboardListeners];
	// Call super at the end
	[super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark UIKeyboard management
- (void) addDoneToolbarForTextField:(ExtUITextField *)textField {
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, nil] autorelease];
	[keyboardToolbar setItems:items];
	[textField setInputAccessoryView:keyboardToolbar];
}

- (void) dismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void)addKeyboardListeners {
	NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
	[noteCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[noteCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeKeyboardListeners {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[self resignFirstResponderIfPossible];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
		NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
		if (!keyboardFrameValue) {
			keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
		}
		
		// Find out how much of the keyboard overlaps the textfield and move the view up out of the way
		CGRect windowRect = [[UIApplication sharedApplication] keyWindow].bounds;
		if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
			windowRect = [self swapRect:windowRect];
		}
		
		UITextField *tf = (UITextField *)self.currentFirstResponder;
		
		CGRect viewRectAbsolute = [tf convertRect:tf.bounds toView:[[UIApplication sharedApplication] keyWindow]];
		if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation ||UIInterfaceOrientationLandscapeRight == self.interfaceOrientation ) {
			viewRectAbsolute = [self swapRect:viewRectAbsolute];
		}
		
		CGRect frame = self.view.frame;
		CGRect keyboardRect = [keyboardFrameValue CGRectValue];
		
		previousViewOriginY = frame.origin.y;
		CGFloat adjustUpBy = (windowRect.size.height - keyboardRect.size.height) - (CGRectGetMaxY(viewRectAbsolute) + 10.0f);
		
		if (adjustUpBy < 0) {
			frame.origin.y = adjustUpBy;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
			self.view.frame = frame;
			[UIView commitAnimations];
		}
		// iOS 3 sends hide and show notifications right after each other
		// when switching between textFields, so cancel -scrollToOldPosition requests
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.navigationController.topViewController == self) {
		NSDictionary* userInfo = [notification userInfo];
		
		CGRect frame = self.view.frame;
		if (frame.origin.y != previousViewOriginY) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
			[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
			frame.origin.y = previousViewOriginY;
			self.view.frame = frame;
			[UIView commitAnimations];
			previousViewOriginY = 0.0f;
		}
	}
}

#pragma mark -
#pragma mark UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textFieldDidEndEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = nil;
	if (self.keyboardCancelled == NO) {
		// Set the values and do the work here.  Need to call delegate.
		if (delegate != nil && [delegate respondsToSelector:@selector(extTextFieldFinishedEditing:)]) {
			[delegate extTextFieldFinishedEditing:textField];
		}
		
	} else {
		self.keyboardCancelled = NO;
	}
	
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)formatInput:(ExtUITextField*)aTextField string:(NSString*)aString range:(NSRange)aRange {
    //Copying the contents of UITextField to an variable to add new chars later
    NSString* value = aTextField.text;
	
    NSString* formattedValue = value;
	
    //Make sure to retrieve the newly entered char on UITextField
    aRange.length = 1;
	
    NSString* _mask = [aTextField.mask substringWithRange:aRange];
	
    //Checking if there's a char mask at current position of cursor
    if (_mask != nil) {
        NSString *regex = @"[0-9]*";
		
        NSPredicate *regextest = [NSPredicate
                                  predicateWithFormat:@"SELF MATCHES %@", regex];
        //Checking if the character at this position isn't a digit
        if (! [regextest evaluateWithObject:_mask]) {
            //If the character at current position is a special char this char must be appended to the user entered text
            formattedValue = [formattedValue stringByAppendingString:_mask];
        }
		
        if (aRange.location + 1 < [aTextField.mask length]) {
			_mask =  [aTextField.mask substringWithRange:NSMakeRange(aRange.location + 1, 1)];
			if([_mask isEqualToString:@" "])
                formattedValue = [formattedValue stringByAppendingString:_mask];
        }
    }
    //Adding the user entered character
    formattedValue = [formattedValue stringByAppendingString:aString];
	
    //Refreshing UITextField value      
    aTextField.text = formattedValue;
}

// Watch the phone field as typed and insert extra characters according to the mask.
- (BOOL)textField:(ExtUITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	// Mask processing overrides max length processing since the mask also limits length.
	if (aTextField.mask != nil) {
		//If the length of used entered text is equals to mask length the user input must be cancelled
		if ([aTextField.text length] == [aTextField.mask length]) {
			if(! [string isEqualToString:@""])
				return NO;
			else
				return YES;
		}
		//If the user has started typing text on UITextField the formatting method must be called
		else if ([aTextField.text length] || range.location == 0) {
			if (string) {
				if(! [string isEqualToString:@""]) {
					[self formatInput:aTextField string:string range:range];
					return NO;
				}
				return YES;
			}
			return YES;
		}
	} else if (aTextField.maxLength != nil) {
		NSUInteger maxLen = [[aTextField maxLength] unsignedIntValue];
		NSUInteger newLength = [aTextField.text length] + [string length] - range.length;
		return (newLength > maxLen) ? NO : YES;
	}
	
	// No special processing.
	return YES;
}



#pragma mark -
#pragma mark Utility methods
- (CGRect) swapRect:(CGRect)rect
{
	return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

- (void) resignFirstResponderIfPossible {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
}
@end
