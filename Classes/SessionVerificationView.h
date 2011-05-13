//
//  SessionVerificationView.h
//  iPOS
//
//  Created by Steven McCoole on 4/26/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SessionVerificationView;

@protocol SessionVerificationViewDelegate

- (void) verificationView:(SessionVerificationView *)aVerificationView submitPassword:(NSString *)password;
- (void) cancelVerificationView:(SessionVerificationView *)aVerificationView;

@end

@interface SessionVerificationView : UIView <UITextFieldDelegate> 
{
	NSObject <SessionVerificationViewDelegate>* _delegate;
    UIView *_roundedView;
    UILabel *_promptLabel;
    UITextField *_passwordField;
    
    id _currentFirstResponder;
    BOOL _keyboardCancelled;

}

@property (nonatomic, assign) NSObject<SessionVerificationViewDelegate>* delegate;
@property (nonatomic, retain) id currentFirstResponder;
@property (nonatomic, assign) BOOL keyboardCancelled;

- (void) makePasswordFieldFirstResponder;

@end
