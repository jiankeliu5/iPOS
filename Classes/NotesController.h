//
//  NotesController.h
//  iPOS
//
//  Created by Dan C on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "SSTextView.h"


@class NotesController;

@protocol NotesControllerDelegate

-(void) close:(NotesController *)notesView;

@end

@interface NotesController : ExtUIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    id<NotesControllerDelegate> notesDelegate;
    SSTextView *notes;
    ExtUITextField *purchaseOrder;
    NSString *notesData;
    NSString *purchaseOrderData;
}

@property(nonatomic, assign) id notesDelegate;
@property(nonatomic, retain) NSString *notesData;
@property(nonatomic, retain) NSString *purchaseOrderData;
@end
