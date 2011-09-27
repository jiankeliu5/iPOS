//
//  ProfitMarginViewController.m
//  iPOS
//
//  Created by Dan C on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfitMarginViewController.h"

@implementation ProfitMarginViewController

@synthesize delegate, order;

-(id)initWithOrder:(Order *) currentOrder {
    
    self.order = currentOrder;
    
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
   
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)] autorelease];
    singleTap.numberOfTapsRequired = 1;
    [bgView addGestureRecognizer:singleTap];
    
	bgView.backgroundColor = [UIColor whiteColor];
	[self setView:bgView];
	[bgView release];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, 106.0f, 16.0f)];    
    label.text = @"PM";
    
    [self.view addSubview:label];
    [label release];
    
    //If there was no result, or if there was an error what should we display?
    UILabel *totalProfitLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 50, 106.0f, 16.0f)];    
    totalProfitLabel.text = [NSString stringWithFormat:@" %@", [order calculateProfitMargin]];
    
    [self.view addSubview:totalProfitLabel];
    [totalProfitLabel release];
}

- (void)close:(id)sender{
    [self.delegate exit:sender];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
 [doneButton addTarget:self action:@selector(foo:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewDidUnload
{
    [doneButton release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
