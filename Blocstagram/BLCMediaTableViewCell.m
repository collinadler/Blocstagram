//
//  BLCMediaTableViewCell.m
//  Blocstagram
//
//  Created by Collin Adler on 11/3/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCMediaTableViewCell.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCUser.h"
#import "BLCLikeButton.h"

@interface BLCMediaTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic, strong) BLCLikeButton *likeButton;
@property (nonatomic, strong) UILabel *likeCount;

@end

static UIFont *lightFont; //used for comments and captions
static UIFont *boldFont; //used for usernames
static UIColor *usernameLabelGray; //used as the background color for the username and caption label
static UIColor *commentLabelGray; //separate background color for the comment section
static UIColor *linkColor; //text color of every username in order to make it tapable
static NSParagraphStyle *paragraphStyle; //lets us set properties like line spacing, text alignment, indentation, paragraph spacing, etc.

@implementation BLCMediaTableViewCell

//since the variables we declared are all static, they will belong to every instance of BLCMediaTableViewCell, and we'll initialize them in (void)load (load is only called once per class, so it is used for static variables
+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0; //first line of the paragraph will be indented by 20
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5; //indicates how far each new paragraph should be from the previous
    
    paragraphStyle = mutableParagraphStyle;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.mediaImageView = [[UIImageView alloc] init];
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self.doubleTapGestureRecognizer requireGestureRecognizerToFail:self.tapGestureRecognizer];
        [self addGestureRecognizer:self.doubleTapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc] init];
        self.usernameAndCaptionLabel.numberOfLines = 0;
        self.usernameAndCaptionLabel.backgroundColor = usernameLabelGray;
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        self.likeButton = [[BLCLikeButton alloc] init];
        [self.likeButton addTarget:self
                            action:@selector(likePressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.likeCount = [[UILabel alloc] init];
        self.backgroundColor = usernameLabelGray;
        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeCount, self.likeButton]) {
            [self.contentView addSubview:view];
            //this converts the auto-resizing mask we learned into constraints automatically. we usually set to NO when working with auto-layout
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _likeCount);
        
        //"H:|[_mediaImageView]| -> means _mediaImageView should exactly match the width of its superview
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        //"H:|[_usernameAndCaption Label / commentLabel]| -> means both views should exactly match the width of the superview
        //set an explicit width of 38 for the like button
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeCount][_likeButton(==38)]|"
                                                                                 options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options:kNilOptions metrics:nil views:viewDictionary]];
        
        //"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel] -> means the three views should stack on top of eachother, with no space in between
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:100];
        
        self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        
        //all this is saying is "the height (i.e. NSLayoutAttributeHeight) of _commentLabel is equal (i.e. NSLayoutRelationEqual) to (nothing[nil] * 1[multiplier]) + 100[constant]."
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    //before layout, calculate the instrinsic size of the labels (the size they "want" to be), and add 20 to the height for some vertical padding
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    //overwrites the 100 we set earlier as the constant
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    
    //use our same scaling image calculation to determine the appropriate height of the image.
    if (_mediaItem.image) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint.constant = maxSize.width;
    }

    //hide the line between the cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

//override the mediaItem property setter method (used in the View Controller)
- (void)setMediaItem:(BLCMedia *)mediaItem {
    //when overriding a getter or setter method, always refer to the ivar (i.e. _ivar)
    _mediaItem = mediaItem;
    self.mediaImageView.image = _mediaItem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.likeCount.attributedText = [self likeCountString];
}

- (NSAttributedString *) likeCountString {
    CGFloat likeCountFontSize = 15;
    NSString *baseString = [NSString stringWithFormat:@"%ld", self.mediaItem.likeCount];
    
    NSMutableAttributedString *mutablelikeCountString = [[NSMutableAttributedString alloc] initWithString:baseString
                                                                                               attributes:@{NSFontAttributeName : [lightFont fontWithSize:likeCountFontSize],
                                                                                                            NSParagraphStyleAttributeName : paragraphStyle}];
    return mutablelikeCountString;
}

- (NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    //Make a string that says "[username] [caption text]"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    //make an attributed string, with the "username" bold
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];

    //override the attributes set in the dictionary above for the username and caption
    NSRange usernameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName
                                            value:[boldFont fontWithSize:usernameFontSize]
                                            range:usernameRange];
    
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName
                                            value:linkColor
                                            range:usernameRange];
    
    return mutableUsernameAndCaptionString;
}

- (NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    //use a for loop to iterate over each comment in the self.mediaItem.comments array
    for (BLCComment *comment in self.mediaItem.comments) {
        //make a string that says "[username] [comment text]" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        
        //make an attributed string, with the "username" bold
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString
                                                                                             attributes:@{NSFontAttributeName : lightFont,
                                                                                                                                NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName
                                 value:boldFont
                                 range:usernameRange];
        
        [oneCommentString addAttribute:NSForegroundColorAttributeName
                                 value:linkColor
                                 range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    return commentString;
}

//create a local copy of the cell which will mirror the one actually being used in the table view controller
+ (CGFloat) heightForMediaItem:(BLCMedia *)mediaItem width:(CGFloat)width {
    //make a cell
    BLCMediaTableViewCell *layoutCell = [[BLCMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:@"layoutCell"];
    
    layoutCell.mediaItem = mediaItem;
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    // get the actual height required for the cell
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Gesture Recognizers

//inform the delegate when a tap is fired
- (void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

- (void) likePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self];
}

//inform the delegate when a long press is fired
- (void) longPressFired:(UILongPressGestureRecognizer *)sender {
    //We make sure that state is UIGestureRecognizerStateBegan. We could alternatively check for UIGestureRecognizerStateRecognized, but then the method wouldn't get called until the user lifts their finger. (And if we don't check at all, the delegate method will get called twice: once when the recognizer begins, and again when the user lifts their finger.)
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

- (void) doubleTapFired:(UITapGestureRecognizer *)sender {
    if (!self.mediaItem.image) {
//insert checkpoint code here
    }
}

#pragma mark - UIGestureRecognizerDelegate

//make sure the gesture recognizer only fires when the cell isn't in editing mode
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return (self.isEditing == NO);
}

@end
