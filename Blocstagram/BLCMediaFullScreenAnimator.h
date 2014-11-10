//
//  BLCMediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Collin Adler on 11/9/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BLCMediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;
//references the image view from the media table view cell (the image view the user taps on)
@property (nonatomic, weak) UIImageView *cellImageView;

@end
