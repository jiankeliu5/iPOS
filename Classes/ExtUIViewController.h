//
//  ExtUIViewController.h
//
//  Created by Steven McCoole on 3/31/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ExtUITextField.h"

@class ExtUIViewController;

@protocol ExtUIViewControllerDelegate

- (void) extTextFieldFinishedEditing:(ExtUITextField *) textField;

@end

#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f

@interface ExtUIViewController : UIViewController <UITextFieldDelegate>
{
	id currentFirstResponder;
	BOOL keyboardCancelled;
	CGFloat previousViewOriginY;
	NSObject <ExtUIViewControllerDelegate>* delegate;
	
}

@property (nonatomic, retain) id currentFirstResponder;
@property (nonatomic, assign) NSObject <ExtUIViewControllerDelegate>* delegate;
@property                     BOOL keyboardCancelled;
@property                     CGFloat previousViewOriginY;

- (void) dismissKeyboard:(id)sender;
- (void) addKeyboardListeners;
- (void) removeKeyboardListeners;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) addDoneToolbarForTextField:(ExtUITextField *)textField;
- (void) resignFirstResponderIfPossible;
@end
