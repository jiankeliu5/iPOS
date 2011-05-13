//
//  PaymentServiceImpl.h
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaymentService.h"

@interface PaymentServiceImpl : NSObject<PaymentService> {
    NSString *baseUrl;
    NSString *posPaymentMgmtUri;
}

@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic, retain) NSString *posPaymentMgmtUri;

-(void) setToDemoMode;
-(void) setToReleaseMode;

@end
