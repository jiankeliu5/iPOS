//
//  SignaturePad.h
//  iPOS
//
//  Created by Torey Lomenda on 3/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CONSTANTS:
#define BRUSH_OPACITY		(3.0 / 3.0)
#define BRUSH_PIXELSTEP		1
#define BRUSH_WIDTH			4

extern NSString * const SIGNATURE_AS_PNG;
extern NSString * const SIGNATURE_AS_JPG;

@interface SignaturePad : UIView {
    EAGLContext *context;
    
    // The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;

    // OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
    GLuint	brushTexture;
    
    Boolean	firstTouch;
    Boolean needsErase;
    
    CGPoint	location;
	CGPoint	previousLocation;
    
    NSString *signatureImageFormat;
}

@property(nonatomic, readwrite) CGPoint location;
@property(nonatomic, readwrite) CGPoint previousLocation;
@property(nonatomic, retain) NSString *signatureImageFormat;

- (void)erase;
- (void)initBrushColor;
- (UIImage *) getSignatureAsImage;
- (NSString *) getSignatureAsBase64;

@end
