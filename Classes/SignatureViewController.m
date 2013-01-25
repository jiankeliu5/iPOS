//
//  SignatureViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "SignatureViewController.h"
#include "PlaceHolderView.h"
#include "AlertUtils.h"

@implementation SignatureViewController

@synthesize delegate, signaturePad, payAmountLabel;
@synthesize signingLabel;


#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Signature"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];
	
    return self;
}

- (void)dealloc {    
    [signaturePad release];
    signaturePad = nil;
    [signingLabel release];
    signingLabel = nil;
    [payAmountLabel release];
    payAmountLabel = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// [self setView:[[[PlaceHolderView alloc] initWithFrame:CGRectZero] autorelease]];
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 480, 320)] autorelease];
    
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.autoresizesSubviews = YES;
    bgView.clipsToBounds = YES;
    
    
    // Add a toolbar to the view
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(savePressed:)] autorelease];
    UIBarButtonItem *clearButton = [[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearPressed:)] autorelease];
    UIBarButtonItem *flex = [[[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                             target:nil action:nil] autorelease];
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 480, 44)] autorelease];
    
    toolbar.barStyle = UIBarStyleBlack;
    [toolbar setItems:[NSArray arrayWithObjects:flex,saveButton,clearButton,nil]];
    
    // Add the labels and signature pad
    signingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, 480, 20)];
    signingLabel.font = [UIFont systemFontOfSize:14.0f];
    signingLabel.textAlignment = UITextAlignmentCenter;
    signingLabel.text = @"By signing below, I agree to pay a total credit card charge of";
    
    payAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 74, 480, 20)];
    payAmountLabel.textAlignment = UITextAlignmentCenter;
    payAmountLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    payAmountLabel.text = @"0.00";
    
    signaturePad = [[SignaturePad alloc] initWithFrame:CGRectMake(10, 94, 460, 170) andTextureEnabled:YES];
    
    // Add the the bg view
    [bgView addSubview:toolbar]; 
    [bgView addSubview:signingLabel];
    [bgView addSubview:payAmountLabel];
    [bgView addSubview:signaturePad];
    
    [signaturePad initBrushColor];
    
    [self setView:bgView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
    // Rotate to landscape
    //self.view.transform = CGAffineTransformIdentity;
//    self.view.transform = CGAffineTransformMakeRotation((M_PI * (90) / 180.0)); 
    // self.view.bounds = CGRectMake(0.0, 0.0, 480, 320);    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Button Selectors
-(void) clearPressed: (id) sender {
    [signaturePad erase];
}

-(void) savePressed: (id) sender {
    // The delegate may accept the signature as an image or a base64 encoded string.  The base64 encoded signature 
    // is invoked if the delegate has implementations for both SignatureDelegate methods
    if (delegate && [delegate respondsToSelector:@selector(signatureController:signatureAsBase64:savePressed:)]) {
        NSString *signature = [signaturePad getSignatureAsBase64];
        [delegate signatureController:self signatureAsBase64:signature savePressed:sender];
    } else if (delegate && [delegate respondsToSelector:@selector(signatureController:signatureAsImage:savePressed:)]) {
        UIImage *signature = [signaturePad getSignatureAsImage];
        [delegate signatureController:self signatureAsImage:signature savePressed:sender];
    }
}




@end
