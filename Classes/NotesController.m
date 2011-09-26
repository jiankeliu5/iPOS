//
//  NotesController.m
//  iPOS
//
//  Created by Dan C on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotesController.h"
#import "SSTextView.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"

#define ROUND_VIEW_X 20.0f
#define ROUND_VIEW_Y 7.0f
#define ROUND_VIEW_WIDTH 280.0f
#define ROUND_VIEW_HEIGHT 400.0f
#define LABEL_HEIGHT 40.0f
#define TEXT_FIELD_HEIGHT 40.0f
#define SPACING_HEIGHT 20.0f
#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f
#define TEXTVIEW_MAX_LENGTH  255
#define TEXTFIELD_MAX_LENGTH 22

@interface NotesController()
-(BOOL) validateString:(NSString *)text;
-(void) displayAlert:(NSString *) alertText;
-(void) adjustViewForKeyBoard:(NSInteger)value;
-(NSInteger) calculateViewAdujustment:(UITextField *)textField;
-(void) close:(id)sender;
@end


@implementation NotesController

@synthesize notesDelegate, notesData, purchaseOrderData;

- (id)init
{
    self = [super init];
    if (self) {
        [[self navigationItem] setTitle:@"Notes"];
        isKeyboardPresent = NO;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect rectForView = [self rectForNavAndStatus];
  
    UIView *bgView = [[UIView alloc] initWithFrame:rectForView];
    bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    //[bgView setAllAutoresizingMask: YES];
    
    [bgView addGestureRecognizer:swipeRight];
    [self setView:bgView];
    
    [bgView release];
    
    UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardForTextView:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, nil] autorelease];
	[keyboardToolbar setItems:items];
    
    CGFloat cy = floorf(LABEL_HEIGHT + SPACING_HEIGHT + SPACING_HEIGHT);
	CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
    
	notes = [[[SSTextView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - width) / 15), cy, floorf(self.view.bounds.size.width * 0.95f), (rectForView.size.height /2))] autorelease];
    notes.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    notes.layer.cornerRadius = 10.0f;
	notes.textColor = [UIColor blackColor];
    notes.autocorrectionType = UITextAutocorrectionTypeNo;
    notes.autocapitalizationType = UITextAutocapitalizationTypeNone;
	notes.returnKeyType = UIReturnKeyDefault;
    notes.placeholder = @"Notes";
    notes.font = [UIFont fontWithName:@"Helvetica" size:17.0];
	notes.delegate = self;
    [notes setInputAccessoryView:keyboardToolbar];
    if (notesData && notesData != nil)
    {
        notes.text = notesData;
    }
    [self.view addSubview:notes];
    
    cy += (SPACING_HEIGHT + notes.frame.size.height);
    
    purchaseOrder = [[[ExtUITextField alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - width) / 10.0f), cy, width, LABEL_HEIGHT)] autorelease];
    notes.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	purchaseOrder.textColor = [UIColor blackColor];
    purchaseOrder.placeholder = @"PO";
    purchaseOrder.borderStyle = UITextBorderStyleRoundedRect;
	purchaseOrder.textAlignment = UITextAlignmentCenter;
    purchaseOrder.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	purchaseOrder.delegate = self;
    [super addDoneToolbarForTextField:purchaseOrder];
    if (purchaseOrderData && purchaseOrderData != nil)
    {
        purchaseOrder.text = purchaseOrderData;
    }

    [self.view addSubview:purchaseOrder];
 	
}

-(CGRect) buildNotesLayoutForPortrait{
    CGFloat cy = floorf(LABEL_HEIGHT + SPACING_HEIGHT + SPACING_HEIGHT);
	CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
    
    return CGRectMake(floorf((self.view.bounds.size.width - width) / 15), cy, floorf(self.view.bounds.size.width * 0.95f), (self.view.frame.size.height /2)); 
}

-(CGRect) buildPurchaseOrderLayOutForPortrait{
    
    CGFloat cy = floorf(LABEL_HEIGHT + SPACING_HEIGHT + SPACING_HEIGHT);
    cy += (SPACING_HEIGHT + notes.frame.size.height);
	CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
    
    return CGRectMake(floorf((self.view.bounds.size.width - width) / 10.0f), cy, width, LABEL_HEIGHT);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.currentFirstResponder isKindOfClass:[UITextView class]])
    {
        CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
        notes.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 15), notes.frame.origin.y, floor(self.view.frame.size.width * .95f), ((self.view.frame.size.height / 4) - 5));
    }
    NSLog(@"Calling show keyboard");
    
    [super keyboardWillShow:notification];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if ([self.currentFirstResponder isKindOfClass:[UITextView class]])
    {
        CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
        notes.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 15), notes.frame.origin.y, floor(self.view.frame.size.width * .95f), (self.view.frame.size.height / 2));
    }
    
    [super keyboardWillHide:notification];
    
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
     if (self.navigationController != nil) {
         [self.navigationController setNavigationBarHidden:NO];
     }
 }


- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
	//[self addKeyboardListeners];
    
    }

- (void)viewDidUnload
{
    [super viewDidUnload];
    [notes release];
    [purchaseOrder release];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self close:self];
    
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.currentFirstResponder resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat cy = floorf(SPACING_HEIGHT / 2.0f);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    if (UIDeviceOrientationIsLandscape(fromInterfaceOrientation))
    {
        notes.frame = [self buildNotesLayoutForPortrait];
        purchaseOrder.frame = [self buildPurchaseOrderLayOutForPortrait];
        
    }
    else if (UIDeviceOrientationIsPortrait(fromInterfaceOrientation))
    {
        CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
        notes.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 15), cy, floor(self.view.frame.size.width * .95f), (self.view.frame.size.height / 2));
        cy += (SPACING_HEIGHT + notes.frame.size.height);
        purchaseOrder.frame = CGRectMake(floorf((self.view.bounds.size.width - width) / 10.0f), cy, width, LABEL_HEIGHT);
        
    }
    [self.currentFirstResponder becomeFirstResponder];
    [UIView commitAnimations];
    
    
}

#pragma mark - Text View Delegate methods
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    self.currentFirstResponder = textView;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *) view {
    [self.currentFirstResponder resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {  
    BOOL shouldChangeText = YES;  
    
    if(range.length > text.length){
        shouldChangeText =  YES;
    }else if([[textView text] length] + text.length > TEXTVIEW_MAX_LENGTH){
        [self displayAlert: @"Only 255 characters are allowed"];
        shouldChangeText =  NO;
    }
    
    return shouldChangeText;
} 

#pragma mark - TextField Delegate methods

//Call the super classes method, then our own for added validation
- (BOOL)textField:(UITextField *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text {  
    BOOL shouldChangeText = YES;  
    
    [super textField:textView shouldChangeCharactersInRange:range replacementString:text];
    if([textView.text length] < TEXTFIELD_MAX_LENGTH && [self validateString:text])
    {
        shouldChangeText = YES;
    }
    else{
        shouldChangeText = NO;
    } 
    
    return shouldChangeText;  
} 

#pragma mark - Misc methods

-(void)dismissKeyboardForTextView:(id)sender
{
    [self.currentFirstResponder resignFirstResponder];
}

-(void)close:(id)sender {
    self.notesData = notes.text;
    self.purchaseOrderData = purchaseOrder.text;    
    [self.notesDelegate close:self];
}


-(BOOL) validateString:(NSString *)text
{    
    BOOL shouldAllow = NO;
    NSError *error = NULL;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSUInteger numOfMatches = [expression numberOfMatchesInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if (numOfMatches > 0) {
        
        shouldAllow = YES;
    }
    else{
        shouldAllow = NO;
        [self displayAlert: @"Only Letters and Digits are allowed."];
    }
    
    return shouldAllow;
}

- (void) displayAlert:(NSString *) alertText
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
    [alertView release];
}
@end
