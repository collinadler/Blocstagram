//
//  BLCCameraViewController.h
//  Blocstagram
//
//  Created by Collin Adler on 11/12/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLCCameraViewController;

@protocol BLCCameraViewControllerDelegate <NSObject>

//inform the presenting view controller when the camera view controller is done
- (void) cameraViewController:(BLCCameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end

@interface BLCCameraViewController : UIViewController

@property (nonatomic, weak) NSObject <BLCCameraViewControllerDelegate> *delegate;

@end
