//
//  BLCLikeButton.m
//  Blocstagram
//
//  Created by Collin Adler on 11/11/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCLikeButton.h"
#import "BLCCircleSpinnerView.h"

#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface BLCLikeButton ()

@property (nonatomic, strong) BLCCircleSpinnerView *spinnerView;

@end

@implementation BLCLikeButton

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.spinnerView = [[BLCCircleSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        //this provides a buffer between the edge of the button and the content
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        //specified the alignment of the button's content. by default, its centered, but we want it at teh top so that the like button isn't misaligned on photos with longer captions
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = BLCLikeStateNotLiked;
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

//This setter updates the button's image and userInteractionEnabled property depending on the BLCLikeState passed in. It also shows or hides the spinner view as appropriate
- (void) setLikeButtonState:(BLCLikeState)likeButtonState {
    _likeButtonState = likeButtonState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case BLCLikeStateLiked:
        case BLCLikeStateUnliking:
            imageName = kLikedStateImage;
            break;
        
        case BLCLikeStateNotLiked:
        case BLCLikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
        case BLCLikeStateLiking:
        case BLCLikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case BLCLikeStateLiked:
        case BLCLikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
