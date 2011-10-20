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
#import "UIScreen+Helpers.h"

#define MARGIN 20.0f

#define ROUND_VIEW_X 20.0f
#define ROUND_VIEW_Y 7.0f
#define ROUND_VIEW_WIDTH 280.0f
#define ROUND_VIEW_HEIGHT 400.0f

#define LABEL_HEIGHT 40.0f
#define TEXT_FIELD_HEIGHT 40.0f

#define KEYBOARD_TOOLBAR_HEIGHT 44.0f

#define TEXTVIEW_MAX_LENGTH  255

#define TEXTFIELD_MAX_LENGTH 22
#define TEXTFIELD_WIDTH 150.0f

@interface NotesController()

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation;

-(BOOL) validateString:(NSString *)text;
-(void) displayAlert:(NSString *) alertText;
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
    UISwipeGestureRecognizer *swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close:)] autorelease];
    
    
    [bgView addGestureRecognizer:swipeRight];
    [self setView:bgView];
    
    [bgView release];
    
    UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
	keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboardForTextView:)] autorelease];
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, nil] autorelease];
	[keyboardToolbar setItems:items];
    
	notes = [[[SSTextView alloc] initWithFrame:CGRectZero] autorelease];
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
    if (notesData && notesData != nil) {
        notes.text = notesData;
    }
    [self.view addSubview:notes];
    
    purchaseOrder = [[[ExtUITextField alloc] initWithFrame:CGRectZero] autorelease];
    notes.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	purchaseOrder.textColor = [UIColor blackColor];
    purchaseOrder.placeholder = @"PO";
    purchaseOrder.borderStyle = UITextBorderStyleRoundedRect;
	purchaseOrder.textAlignment = UITextAlignmentLeft;
    purchaseOrder.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	purchaseOrder.delegate = self;
    [super addDoneToolbarForTextField:purchaseOrder];
    if (purchaseOrderData && purchaseOrderData != nil)
    {
        purchaseOrder.text = purchaseOrderData;
    }

    [self.view addSubview:purchaseOrder];
 	
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if ([self.currentFirstResponder isKindOfClass:[UITextView class]])
    {
        CGRect frame = notes.frame;
        frame.size.height = (self.view.frame.size.height / 4) - 5;
        
        notes.frame = frame;
    }
    NSLog(@"Calling show keyboard");
    
    [super keyboardWillShow:notification];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    if ([self.currentFirstResponder isKindOfClass:[UITextView class]])
    {
        CGRect frame = CGRectMake(MARGIN, purchaseOrder.frame.size.height + MARGIN*2, self.view.bounds.size.width - MARGIN*2, self.view.bounds.size.height/2);
        notes.frame = frame;
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

- (void) viewWillAppear:(BOOL)animated {
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
    
    [super viewWillAppear:animated];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self.currentFirstResponder resignFirstResponder];
    [self layoutView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
    // Position the Purchase Order
    purchaseOrder.frame = CGRectMake(MARGIN, MARGIN, TEXTFIELD_WIDTH, TEXT_FIELD_HEIGHT);
    
    // Position the notes
    notes.frame = CGRectMake(MARGIN, purchaseOrder.frame.size.height + MARGIN*2, viewBounds.size.width - MARGIN*2, viewBounds.size.height/2);
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
