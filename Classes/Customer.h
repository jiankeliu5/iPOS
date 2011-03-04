//
//  Customer.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Address.h"

@interface Customer : NSObject {
    NSNumber *customerId;
    NSString *firstName;
    NSString *lastName;
    NSString *phoneNumber;
    NSString *emailAddress;
    
    Address *address; 
    
    NSArray *errorList;
}

@property (nonatomic, retain) NSNumber *customerId;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *emailAddress;

@property (nonatomic, retain) Address *address;

@property (nonatomic, retain) NSArray *errorList;

@end
