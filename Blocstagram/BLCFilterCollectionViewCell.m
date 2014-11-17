//
//  BLCFilterCollectionViewCell.m
//  Blocstagram
//
//  Created by Collin Adler on 11/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCFilterCollectionViewCell.h"

@interface BLCFilterCollectionViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BLCFilterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat thumbNailEdgeSize = 84;
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbNailEdgeSize, thumbNailEdgeSize)];
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.thumbnailImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbNailEdgeSize, thumbNailEdgeSize, 20)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [self.contentView addSubview:self.titleLabel];
    
    }
    return self;
}

#pragma mark - Overrides

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)titleString {
    return self.titleLabel.text;
}


@end
