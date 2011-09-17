//
//  NotesController.m
//  iPOS
//
//  Created by Dan C on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NotesController.h"
#import "SSTextView.h"

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
@end


@implementation NotesController

@synthesize notesDelegate, notesData, purchaseOrderData;

- (id)init
{
    self = [super init];
    if (self) {
        
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
    UIView *bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    bgView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    
    /*UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
     singleTap.numberOfTapsRequired = 1;
     [bgView addGestureRecognizer:singleTap];*/
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
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
    
    CGFloat cy = floorf(SPACING_HEIGHT / 2.0f);
	CGFloat width = floorf(self.view.bounds.size.width * 0.60f);
    
	notes = [[[SSTextView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - width) / 5), cy, floorf(self.view.bounds.size.width * 0.85f), 100.0f)] autorelease];
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
    
    cy += (LABEL_HEIGHT + SPACING_HEIGHT + 50);
    
    purchaseOrder = [[[ExtUITextField alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - width) / 2.0f), cy, width, LABEL_HEIGHT)] autorelease];
	purchaseOrder.textColor = [UIColor blackColor];
    purchaseOrder.placeholder = @"PO";
    purchaseOrder.borderStyle = UITextBorderStyleRoundedRect;
	purchaseOrder.textAlignment = UITextAlignmentCenter;
	purchaseOrder.delegate = self;
    [super addDoneToolbarForTextField:purchaseOrder];
    if (purchaseOrderData && purchaseOrderData != nil)
    {
        purchaseOrder.text = purchaseOrderData;
    }
    [self.view addSubview:purchaseOrder];
 	
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
	[self addKeyboardListeners];
    
    // [TL]Track the actual Y origin of the view.  This fixes defect when view does not adjust up with multiple text fields
    // and the previous Y origin messes up the anchor point for the loaded view when the keyboard is hidden.
    if (self.view) {
        actualOriginY = self.view.frame.origin.y;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || UIInterfaceOrientationIsLandscape(interfaceOrientation);
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

/*- (void)textViewDidBeginEditing:(UITextView *)textView
 {
 if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
 {
 [self adjustViewForKeyBoard: 25]; 
 }
 else if (self.interfaceOrientation == UIDeviceOrientationLandscapeRight)
 {
 [self adjustViewForKeyBoard: -25];
 }
 }
 
 - (void)textViewDidEndEditing:(UITextView *)textView
 {
 
 if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
 {
 [self adjustViewForKeyBoard: -25]; 
 }
 else if (self.interfaceOrientation == UIDeviceOrientationLandscapeRight)
 {
 [self adjustViewForKeyBoard: 25];
 }
 }*/

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {  
    BOOL shouldChangeText = YES;  
    
    if([text isEqualToString:@"\n"] || [textView.text length] < TEXTVIEW_MAX_LENGTH)
    {
        shouldChangeText = YES;
    }
    else{
        shouldChangeText = NO;
        [self displayAlert: @"Only 255 characters are allowed"];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
    CGRect viewRectAbsolute = [textField convertRect:textField.bounds toView:self.view];
    
    CGFloat height = textField.bounds.size.height;
    CGFloat absoluteHeight = CGRectGetHeight(viewRectAbsolute);
    NSInteger adjustValue = height + absoluteHeight;
    
    if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        [self adjustViewForKeyBoard: adjustValue]; 
    }
    else if (self.interfaceOrientation == UIDeviceOrientationLandscapeRight)
    {
        [self adjustViewForKeyBoard: -1 * adjustValue];
    }
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
    
    if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        NSInteger adjustment = [self calculateViewAdujustment:textField];
        [self adjustViewForKeyBoard: -1 * adjustment]; 
    }
    else if (self.interfaceOrientation == UIDeviceOrientationLandscapeRight)
    {
        [self adjustViewForKeyBoard: [self calculateViewAdujustment:textField]];
    }
}

#pragma mark - Misc methods


-(NSInteger) calculateViewAdujustment:(UITextField *)textField
{
    CGRect viewRectAbsolute = [textField convertRect:textField.bounds toView:self.view];
    
    CGFloat height = textField.bounds.size.height;
    CGFloat absoluteHeight = CGRectGetHeight(viewRectAbsolute);
    return height + absoluteHeight;
    
    
}

-(void) adjustViewForKeyBoard:(NSInteger)value
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    self.view.frame = CGRectMake((self.view.frame.origin.x + value), self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.currentFirstResponder resignFirstResponder];
}


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
