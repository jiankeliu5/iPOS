//
//  Error.h
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Error : NSObject {
    NSString *errorMsgString;
    
    id reference;
}

@property (nonatomic, retain) NSString *errorMsgString;
@property (nonatomic, assign) id reference;

@end
