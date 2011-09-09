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


@class NotesController;

@protocol NotesControllerDelegate

-(void) close:(NotesController *)notesView;

@end

@interface NotesController : ExtUIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    id<NotesControllerDelegate> notesDelegate;
    UITextView *notes;
    ExtUITextField *purchaseOrder;
    UILabel *notesHeader;
    UILabel *purchaseOrderHeader;
    NSString *notesData;
    NSString *purchaseOrderData;
}

@property(nonatomic, assign) id notesDelegate;
@property(nonatomic, retain) NSString *notesData;
@property(nonatomic, retain) NSString *purchaseOrderData;
@end
