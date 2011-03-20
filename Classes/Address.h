//
//  Address.h
//  iPOS
//
//  Created by Torey Lomenda on 2/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Address : NSObject {
    NSString *line1;
    NSString *line2;
    NSString *line3;
    
    NSString *city;
    NSString *stateProv;
    NSString *zipPostalCode;
    NSString *country;
}

@property (nonatomic, retain) NSString *line1;
@property (nonatomic, retain) NSString *line2;
@property (nonatomic, retain) NSString *line3;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *stateProv;
@property (nonatomic, retain) NSString *zipPostalCode;
@property (nonatomic, retain) NSString *country;

+ (NSArray *)usStateCodes;

@end
