//
//  AlertUtils.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertUtils : NSObject 
{

}

+ (void) showModalAlertMessage:(NSString*)message;

+ (UIAlertView *) showProgressAlertMessage:(NSString*)message;

+ (void) dismissAlertMessage:(UIAlertView *) alert;

@end
