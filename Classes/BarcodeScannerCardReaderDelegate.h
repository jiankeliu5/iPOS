//
//  BarcodeScannerCardReaderDelegate.h
//  iPOS
//
//  Created by Torey Lomenda on 2/8/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LineaSDK.h"


@interface BarcodeScannerCardReaderDelegate : NSObject <LineaDelegate> {
    Linea *linea;
    
    // TODO:  Referencing the navigationController may be sufficient.
    UINavigationController *navigationController;
}

@property (nonatomic, retain) UINavigationController *navigationController;

-(void) connectToDevice;
- (void) disconnectFromDevice;

-(void) showAlertWithOk: (NSString *) msg;

@end
