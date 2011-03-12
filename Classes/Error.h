//
//  Error.h
//  iPOS
//
//  Created by Torey Lomenda on 3/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Error : NSObject {
    
    NSNumber *errorId;
    NSString *message;
    
    id reference;
}

// TODO: Place to put ERROR Constants.  None defined yet.

@property (nonatomic, retain) NSNumber *errorId;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) id reference;

@end
