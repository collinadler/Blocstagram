//
//  BLCCropImageViewController.h
//  Blocstagram
//
//  Created by Collin Adler on 11/13/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCMediaFullScreenViewController.h"

@class BLCCropImageViewController;

@protocol BLCCropImageViewControllerDelegate <NSObject>

- (void) cropControlFinishedWithImage:(UIImage *)croppedImage;

@end


//another controller with paass in a source image and set itself as the crop controller's delegate. the user will crop and size the image, and the controller will pass a new, cropped image back to the delegate
@interface BLCCropImageViewController : BLCMediaFullScreenViewController

- (instancetype) initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak) NSObject <BLCCropImageViewControllerDelegate> *delegate;

@end
