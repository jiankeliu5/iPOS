//
//  ItemSet.h
//  iPOS
//
//  Created by Enning Tang on 8/2/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemSet : NSObject{
    NSMutableArray *_items;
}

@property (nonatomic, retain) NSMutableArray *items;

@end
