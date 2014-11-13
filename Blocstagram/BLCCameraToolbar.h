//
//  BLCCameraToolbar.h
//  Blocstagram
//
//  Created by Collin Adler on 11/12/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLCCameraToolbar;

@protocol BLCCameraToolbarDelegate <NSObject>

//This view will know nearly nothing about what the function of these buttons is. Instead, we'll use the trusted delegate pattern to inform the view when the buttons are pressed.
- (void) leftButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;
- (void) rightButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;
- (void) cameraButtonPressedOnToolbar:(BLCCameraToolbar *)toolbar;

@end

@interface BLCCameraToolbar : UIView

- (instancetype) initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak) NSObject <BLCCameraToolbarDelegate> *delegate;

@end
