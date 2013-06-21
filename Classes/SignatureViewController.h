//
//  SignatureViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignaturePad.h"

#import "iPOSFacade.h"

@interface SignatureViewController : UIViewController {
	iPOSFacade *facade;
    
    id delegate;
    
    SignaturePad *signaturePad;
    UILabel *signingLabel;
    UILabel *payAmountLabel;
}

@property(nonatomic, assign) id delegate;

@property (nonatomic, retain) SignaturePad *signaturePad;
@property (nonatomic, retain) UILabel *signingLabel;
@property (nonatomic, retain) UILabel *payAmountLabel;

@end

@protocol SignatureDelegate <NSObject>

-(void) signatureController: (SignatureViewController *) signatureController signatureAsImage: (UIImage *) signature savePressed: (id) sender;
-(void) signatureController: (SignatureViewController *) signatureController signatureAsBase64: (NSString *) signature savePressed: (id) sender;

@end