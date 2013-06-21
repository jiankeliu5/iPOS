//
//  ExtUITextField.h
//  iPOS
//
//  Created by Steven McCoole on 2/13/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtUITextField : UITextField 
{
	NSString *tagName;
	NSString *mask;
	NSNumber *maxLength;
}

@property (nonatomic, retain) NSString *tagName;
@property (nonatomic, retain) NSString *mask;
@property (nonatomic, retain) NSNumber *maxLength;

@end
