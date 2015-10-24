//
//  VEKenBurns.m
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEKenBurns.h"

@implementation VEKenBurns

-(NSInteger) getNumberOfInputFrames
{
    return 1;
}

-(double)randomNumber
{
    return ((double)arc4random_uniform(10)) / 10;
}

-(void) setupMovement
{
    CGSize destinationSize = self.finalSize;
    CGSize originalSize = [self.frameProvider getOriginalSize];
    
    double yScale = destinationSize.height / originalSize.height;
    double xScale = destinationSize.width / originalSize.width;
    
    double minScale = MAX(xScale, yScale);
    double maxScale = 1.1 * minScale;
    
    if (yScale < 1 && xScale < 1) {
        minScale = MAX(xScale, yScale);
        maxScale = 1;
    }
    
    self.startScale = minScale + ((maxScale - minScale) * [self randomNumber]);
    self.endScale = minScale + ((maxScale - minScale) * [self randomNumber]);
    
    double startMaxX = originalSize.width * self.startScale - destinationSize.width;
    double startMaxY = originalSize.height * self.startScale - destinationSize.height;
    
    self.startX = -1  * (startMaxX * [self randomNumber]);
    self.startY = -1 * (startMaxY * [self randomNumber]);
    
    double endMaxX = originalSize.width * self.endScale - destinationSize.width;
    double endMaxY = originalSize.height * self.endScale - destinationSize.height;
    
    self.endX = -1 * (endMaxX * [self randomNumber]);
    self.endY = -1 * (endMaxY * [self randomNumber]);
    
    [self setupMovementForMovementPercent:0];
}

-(void) setupMovementForMovementPercent: (double) percent
{
    double k = percent;
    if (k > 1) {
        k = 1;
    }
    if (k < 0) {
        k = 0;
    }
    
    self.currentScale = self.startScale + (self.endScale - self.startScale) * k;
    
    self.currentX = self.startX + (self.endX - self.startX) * k;
    self.currentY = self.startY + (self.endY - self.startY) * k;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    double totalDuration = [self.frameProvider getDuration];
    double movementPercent = request.time / totalDuration;
    [self setupMovementForMovementPercent:movementPercent];
    
    CIImage* image = [self.frameProvider getFrameForRequest:request];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.currentScale, self.currentScale);
    image = [image imageByApplyingTransform:scaleTransform];
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(self.currentX, self.currentY);
    image = [image imageByApplyingTransform:translationTransform];
    
    image = [image imageByCroppingToRect:CGRectMake(0, 0, self.finalSize.width, self.finalSize.height)];
    
    return image;
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    [super reqisterIntoVideoComposition:videoComposition withInstruction:instruction withFinalSize:finalSize];
    
    [self setupMovement];
}

@end