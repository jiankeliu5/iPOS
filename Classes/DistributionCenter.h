//
//  DistributionCenter.h
//  iPOS
//
//  Created by Torey Lomenda on 2/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DistributionCenter : NSObject {
    NSNumber *dcId;
    
    NSDecimalNumber *availability;
    NSDecimalNumber *onHand;

    NSString *etaDateAsString;
    BOOL isPrimary;
}

@property (nonatomic, retain) NSNumber *dcId;
@property (nonatomic, retain) NSDecimalNumber *availability;
@property (nonatomic, retain) NSDecimalNumber *onHand;
@property (nonatomic, retain) NSString *etaDateAsString;

@property                     BOOL isPrimary;



@end
