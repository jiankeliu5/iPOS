//
//  AlertUtils.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "AlertUtils.h"

#pragma mark -
#pragma mark Private Interface
@interface AlertUtils ()
@end

#pragma mark -
@implementation AlertUtils

+ (void) showModalAlertMessage:(NSString*)message {
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"iPOS" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];	
	[alert show];
	[alert release];
}

+ (UIAlertView *) showProgressAlertMessage:(NSString*)message {
	UIAlertView *alert=[[UIAlertView alloc] initWithTitle:message message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];	
	UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[indicator startAnimating];
	[indicator setFrame:CGRectMake(125, 60, 37, 37)];
	[alert addSubview:indicator];
	[alert show];
	return alert;
}


+ (void) dismissAlertMessage:(UIAlertView *) alert {
	
	if (nil != alert) {
		[alert dismissWithClickedButtonIndex:0 animated:YES];
		[alert release]; 
		alert=nil;
	}
}

@end
