//
//  BarcodeScannerCardReaderDelegate.m
//  iPOS
//
//  Created by Torey Lomenda on 2/8/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "BarcodeScannerCardReaderDelegate.h"


@implementation BarcodeScannerCardReaderDelegate

@synthesize navigationController;

#pragma mark Initializer and Memory mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Initialize reference to linea    
    linea = [Linea sharedDevice];
    [linea addDelegate: self];
    
    return self;
}

-(void) dealloc {
    [navigationController release];
    
    [self disconnectFromDevice];
    [linea removeDelegate:self];
    [linea release];
    
    [super dealloc];
}

#pragma mark Linea Delegate
-(void)connectionState:(int)state {
    switch (state) {
		case CONN_DISCONNECTED:		
            [self showAlertWithOk: @"Linea-Pro Device is disconnected!!"];
            break;
        case CONN_CONNECTING:
            break; 
		case CONN_CONNECTED:
            [self showAlertWithOk: @"Linea-Pro Device is connected!!"];
            break;
	}
    
}

-(void)barcodeData:(NSString *)barcode type:(int)type {
    NSMutableString *status = [[[NSMutableString alloc] init] autorelease];
    [status setString:@""];
	[status appendFormat:@"Type: %d\n",type];
	[status appendFormat:@"Type text: %@\n",[linea barcodeType2Text:type]];
	[status appendFormat:@"Barcode: %@",barcode];
    
    [self showAlertWithOk: status];
}

-(void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
}

#pragma mark Interface implementation
-(void) connectToDevice {
    [linea connect];
}

-(void) disconnectFromDevice {
    [linea disconnect];
}

#pragma mark Temporary Alert Messages
-(void) showAlertWithOk: (NSString *) msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Linea Device" message: msg
                                                            delegate:self cancelButtonTitle: nil otherButtonTitles:@"Ok", nil];
    [alert show];
    [alert release];    
}

@end
