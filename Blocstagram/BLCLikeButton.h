//
//  BLCLikeButton.h
//  Blocstagram
//
//  Created by Collin Adler on 11/11/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BLCLikeState) {
    BLCLikeStateNotLiked =  0,
    BLCLikeStateLiking =    1,
    BLCLikeStateLiked =     2,
    BLCLikeStateUnliking =  3
};

@interface BLCLikeButton : UIButton

//the current state of the like button
@property (nonatomic, assign) BLCLikeState likeButtonState;

@end
