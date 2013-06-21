//
//  SpecialItem.m
//  iPOS
//
//  Created by Enning Tang on 6/5/13.
//
//

#import "SpecialItem.h"
#import "NSString+StringFormatters.h"
#import "UIView+ViewLayout.h"
#import "AlertUtils.h"

#import "UIViewController+ViewControllerLayout.h"
#import "UIScreen+Helpers.h"

#import "ManagerInfo.h"

#define OVERLAY_VIEW_X 20.0f
#define OVERLAY_VIEW_Y 10.0f
#define OVERLAY_VIEW_WIDTH 280.0f
#define OVERLAY_VIEW_HEIGHT 300.0f

#define LABEL_SMALL_FONT_SIZE 12.0f
#define LABEL_FONT_SIZE 16.0f
#define LABEL_LARGE_FONT_SIZE 20.0f
#define LABEL_HEIGHT 18.0f
#define LABEL_WIDTH 120.0f

#define BUTTON_HEIGHT 30.0f
#define BUTTON_WIDTH 100.0f

// Margins
#define MARGIN_TOP 10.0f
#define MARGIN_LEFT 20.0f
#define MARGIN_RIGHT 20.0f
#define MARGIN_BOTTOM 10.0f

#define STRIP_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define STRIP_HEIGHT 60.0f
#define AMOUNT_LABEL_WIDTH 20.0f
#define AMOUNT_LABEL_HEIGHT 40.0f
#define AMOUNT_TEXT_FIELD_HEIGHT 40.0f
#define AMOUNT_TEXT_FIELD_WIDTH 180.0f
#define CHARGE_AMOUNT_VIEW_HEIGHT 142.0f
#define ENTER_CHARGE_AMT_WIDTH 240.0f
#define ENTER_CHARGE_AMT_HEIGHT 60.0f

#define SWIPE_MSG_VIEW_HEIGHT 142.0f

#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f

@interface SpecialItem ()

@end

@implementation SpecialItem

@synthesize itemToAdd;
@synthesize currentFirstResponder;
@synthesize keyboardCancelled;
@synthesize viewDelegate;
@synthesize originalCenter;

#pragma mark -

- (void) layoutSubviews {
    facade = [iPOSFacade sharedInstance];
	orderCart = [OrderCart sharedInstance];
    
    self.originalCenter = self.viewForBaselineLayout.center;
    
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    CGFloat width = self.bounds.size.width;
    
    // Add the rounded view
    CGRect roundedViewRect = CGRectMake((width-OVERLAY_VIEW_WIDTH)/2, OVERLAY_VIEW_Y, OVERLAY_VIEW_WIDTH, OVERLAY_VIEW_HEIGHT);
    if (!mainRoundedView) {
        mainRoundedView = [[UIView alloc] initWithFrame:roundedViewRect];
        [self addSubview:mainRoundedView];
        [mainRoundedView release];
    } else {
        mainRoundedView.frame = roundedViewRect;
    }
    
    [mainRoundedView applyRoundedStyle:[UIColor blackColor] withShadow:YES];
	[mainRoundedView applyGradientToBackgroundWithStartColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                                                    endColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    
    // Add description label
    descriptionLbl = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH + 130.0f, LABEL_HEIGHT)] autorelease];
    descriptionLbl.textAlignment = NSTextAlignmentLeft;
    descriptionLbl.textColor = [UIColor blackColor];
    descriptionLbl.text = @"Special Item: New Description (Required)";
    descriptionLbl.font = [UIFont boldSystemFontOfSize:LABEL_SMALL_FONT_SIZE];
    [mainRoundedView addSubview:descriptionLbl];
    
    description = [[[ExtUITextField alloc]
                              initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + LABEL_HEIGHT, AMOUNT_TEXT_FIELD_WIDTH + 60.0f, AMOUNT_TEXT_FIELD_HEIGHT)]
                             autorelease];
    description.tag = 0;
    description.textColor = [UIColor blackColor];
    description.borderStyle = UITextBorderStyleRoundedRect;
    description.textAlignment = NSTextAlignmentLeft;
    description.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [description setKeyboardType:UIKeyboardTypeDefault];
    description.returnKeyType = UIReturnKeyDone;
    description.delegate = self;
    [self addDoneAndCancelToolbarForTextField:description];
    [mainRoundedView addSubview:description];
    
    amountLbl = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
    amountLbl.textAlignment = NSTextAlignmentLeft;
    amountLbl.textColor = [UIColor blackColor];
    amountLbl.text = @"Amount (Required)";
    amountLbl.font = [UIFont boldSystemFontOfSize:LABEL_SMALL_FONT_SIZE];
    [mainRoundedView addSubview:amountLbl];
    
    amount = [[[ExtUITextField alloc]
                    initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT, AMOUNT_TEXT_FIELD_WIDTH - 50.0f, AMOUNT_TEXT_FIELD_HEIGHT)]
                   autorelease];
    amount.tag = 1;
    amount.textColor = [UIColor blackColor];
    amount.borderStyle = UITextBorderStyleRoundedRect;
    amount.textAlignment = NSTextAlignmentLeft;
    amount.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [amount setKeyboardType:UIKeyboardTypeDecimalPad];
    amount.returnKeyType = UIReturnKeyDone;
    amount.delegate = self;
    [self addDoneAndCancelToolbarForTextField:amount];
    [mainRoundedView addSubview:amount];
    
    managerIdPassLbl = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f, LABEL_WIDTH + 70.0f, LABEL_HEIGHT)] autorelease];
    managerIdPassLbl.textAlignment = NSTextAlignmentLeft;
    managerIdPassLbl.textColor = [UIColor blackColor];
    managerIdPassLbl.text = @"Authorization Code (Required)";
    managerIdPassLbl.font = [UIFont boldSystemFontOfSize:LABEL_SMALL_FONT_SIZE];
    [mainRoundedView addSubview:managerIdPassLbl];
    
    managerId = [[[ExtUITextField alloc]
               initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT, AMOUNT_TEXT_FIELD_WIDTH - 70.0f, AMOUNT_TEXT_FIELD_HEIGHT)]
              autorelease];
    managerId.tag = 2;
    managerId.textColor = [UIColor blackColor];
    managerId.borderStyle = UITextBorderStyleRoundedRect;
    managerId.textAlignment = NSTextAlignmentLeft;
    managerId.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [managerId setKeyboardType:UIKeyboardTypeNumberPad];
    managerId.returnKeyType = UIReturnKeyDone;
    managerId.delegate = self;
    [self addDoneAndCancelToolbarForTextField:managerId];
    [mainRoundedView addSubview:managerId];
    
    managerPass = [[[ExtUITextField alloc]
                  initWithFrame:CGRectMake(MARGIN_LEFT + AMOUNT_LABEL_WIDTH + 100.0f, MARGIN_TOP + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT, AMOUNT_TEXT_FIELD_WIDTH - 50.0f, AMOUNT_TEXT_FIELD_HEIGHT)]
                 autorelease];
    managerPass.tag = 3;
    managerPass.textColor = [UIColor blackColor];
    managerPass.borderStyle = UITextBorderStyleRoundedRect;
    managerPass.textAlignment = NSTextAlignmentLeft;
    managerPass.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [managerPass setKeyboardType:UIKeyboardTypeNumberPad];
    managerPass.returnKeyType = UIReturnKeyDone;
    managerPass.delegate = self;
    managerPass.secureTextEntry = YES;
    [self addDoneAndCancelToolbarForTextField:managerPass];
    [mainRoundedView addSubview:managerPass];
    
    infoLbl = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f + LABEL_HEIGHT + LABEL_HEIGHT + 30.0f, LABEL_WIDTH + 130.0f, LABEL_HEIGHT + LABEL_HEIGHT)] autorelease];
    infoLbl.textAlignment = NSTextAlignmentLeft;
    infoLbl.numberOfLines = 0;
    infoLbl.lineBreakMode = NSLineBreakByWordWrapping;
    infoLbl.textColor = [UIColor blackColor];
    infoLbl.text = @"Special items cannot be returned using standard POS processes.";
    infoLbl.font = [UIFont boldSystemFontOfSize:LABEL_SMALL_FONT_SIZE];
    [mainRoundedView addSubview:infoLbl];
    
    // Add a confirm button
    acceptItemButton = [[[MOGlassButton alloc]
                      initWithFrame:CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f),
                                               mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)]
                     autorelease];
    [acceptItemButton setupAsSmallRedButton];
    [mainRoundedView addSubview:acceptItemButton];
    acceptItemButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [acceptItemButton setTitle:@"Accept" forState:UIControlStateNormal];
    [acceptItemButton addTarget:self action:@selector(handleConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    acceptItemButton.frame = CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f - 70.0f),
                                     mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    //Add cancel button
    cancelItemButton = [[[MOGlassButton alloc]
                      initWithFrame:CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f),
                                               mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT)]
                     autorelease];
    [cancelItemButton setupAsGrayButton];
    [mainRoundedView addSubview:cancelItemButton];
    cancelItemButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [cancelItemButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelItemButton addTarget:self action:@selector(handleCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    cancelItemButton.frame = CGRectMake(floorf((mainRoundedView.bounds.size.width - BUTTON_WIDTH) / 2.0f + 70.0f),
                                     mainRoundedView.bounds.size.height - BUTTON_HEIGHT - MARGIN_BOTTOM, BUTTON_WIDTH, BUTTON_HEIGHT);
	
}

#pragma mark -
#pragma mark Private Interface
- (void) layoutBalanceDueLabels: (UIView *) parentView {
    /*if (!balanceDueTitle) {
        balanceDueTitle = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
        balanceDueLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT)] autorelease];
        
        balanceDueTitle.textAlignment = NSTextAlignmentLeft;
        balanceDueTitle.text = @"Balance Due";
        balanceDueTitle.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        balanceDueLabel.textAlignment = NSTextAlignmentRight;
        balanceDueLabel.textColor = [UIColor blueColor];
        balanceDueLabel.text = self.balanceDue.stringValue;
        balanceDueLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        [parentView addSubview:balanceDueTitle];
        [parentView addSubview:balanceDueLabel];
    }
    
    balanceDueTitle.frame = CGRectMake(MARGIN_LEFT, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
    balanceDueLabel.frame = CGRectMake(MARGIN_LEFT+LABEL_WIDTH, MARGIN_TOP, LABEL_WIDTH, LABEL_HEIGHT);
     */
}

- (void) addDoneAndCancelToolbarForTextField:(UITextField *)textField {
	UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAndDismissKeyboard:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, cancelButton, nil] autorelease];
    
    [keyboardToolbar setItems:items];
	[textField setInputAccessoryView:keyboardToolbar];
}

- (void) dismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// The toolbar done button calls this.  Allows the delegate to be called.
		self.keyboardCancelled = NO;
		[self.currentFirstResponder resignFirstResponder];
        self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
	}
}

- (void) cancelAndDismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
		[self.currentFirstResponder resignFirstResponder];
        self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
	}
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag > 1)
    {
        //self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
        self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 60.0f);
    }
    else
    {
        
    }
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.currentFirstResponder = textField;
	/*if ([loginTableView indexPathsForVisibleRows].count) {
     [self setTopRowBeforeKeyboardShown:(NSIndexPath *) [[loginTableView indexPathsForVisibleRows] objectAtIndex:0]];
     } else {
     [self setTopRowBeforeKeyboardShown:[NSIndexPath indexPathForRow:0 inSection:0]];
     [textField resignFirstResponder];
     }*/
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.currentFirstResponder = nil;
    
    self.keyboardCancelled = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void) handleConfirmButton: (id) sender{
    NSLog(@"SpecialItem Confirm button hit");
    
    //[self removeFromSuperview];
    itemToAdd.description = description.text;
    NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:amount.text];
    NSLog(@"Item to Add description: %@", itemToAdd.description);
    NSLog(@"Item to Add Qty: %@", quantity.stringValue);
    ManagerInfo *mgr = [[ManagerInfo alloc] init];
    
    if (([description.text length] > 0) && [amount.text length] > 0)
    {
        if ([managerId.text length] > 0) {
            if ([managerPass.text length] == 0) {
                [AlertUtils showModalAlertMessage:@"Password must be entered with Id." withTitle:@"iPOS"];
                return;
            } else {
                mgr.managerUserName = [NSString stringWithString:managerId.text];
                mgr.managerPassword = [NSString stringWithString:managerPass.text];
            }
        }
        if (![facade login:mgr.managerUserName password:mgr.managerPassword]) {
            NSLog(@"after");
            [AlertUtils showModalAlertMessage:@"Invalid credentials." withTitle:@"iPOS"];
            self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
        } else {
            [viewDelegate addSpecialItem:itemToAdd orderQuantity:quantity ofUnits:itemToAdd.primaryUnitOfMeasure];
            [self removeFromSuperview];
        }
    }
    else
    {
        [AlertUtils showModalAlertMessage:@"Item description and amount are required." withTitle:@"iPOS"];
        self.viewForBaselineLayout.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
    }
}

- (void) handleCancelButton: (id) sender{
    NSLog(@"SpecialItem Cancel button hit");
    [self removeFromSuperview];
}


@end
