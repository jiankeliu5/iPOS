//
//  AbstractModel.h
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Error.h"

@interface AbstractModel : NSObject {
    NSMutableArray *errorList;
}

@property (nonatomic, retain) NSMutableArray *errorList;

-(void) addError: (Error *) error;
- (void) removeAllErrors;

@end
