//
//  BLCComposeCommentView.m
//  Blocstagram
//
//  Created by Collin Adler on 11/12/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCComposeCommentView.h"

@interface BLCComposeCommentView () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation BLCComposeCommentView

//our initializer will create and configure the objects and add them to the view hierarchy
- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] init];
        self.textView.delegate = self;
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setAttributedTitle:[self commentAttributedString]
                               forState:UIControlStateNormal];
        [self.button addTarget:self
                        action:@selector(commentButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.textView];
        //note that self.button is a subview of self.textview, not self. this will be helpful when we want to wrap long comment text around a button
        [self.textView addSubview:self.button];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.textView.frame = self.bounds;
    
    if (self.isWritingComment) {
        self.textView.backgroundColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
        self.button.backgroundColor = [UIColor colorWithRed:0.345 green:0.318 blue:0.424 alpha:1];
        
        CGFloat buttonX = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.button.frame) - 20;
        self.button.frame = CGRectMake(buttonX, 10, 80, 20);
    } else {
        self.textView.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
        self.button.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
        
        self.button.frame = CGRectMake(10, 10, 80, 20);
    }
    
    //we make a CGRect that's a bit larger than the comment button. We convert this into a UIBezierPath, and add this to the text view's text container's exclusion paths. This means that the text view won't draw text that intersects with this path, causing it to wrap around the button
    CGSize buttonSize = self.button.frame.size;
    buttonSize.height += 20;
    buttonSize.width += 20;
    CGFloat blockX = CGRectGetWidth(self.textView.bounds) - buttonSize.width;
    CGRect areaToBlockText = CGRectMake(blockX, 0, buttonSize.width, buttonSize.height);
    UIBezierPath *buttonPath = [UIBezierPath bezierPathWithRect:areaToBlockText];
    
    self.textView.textContainer.exclusionPaths = @[buttonPath];
}

- (NSAttributedString *) commentAttributedString {
    NSString *baseString = NSLocalizedString(@"COMMENT", @"comment button text");
    NSRange range = [baseString rangeOfString:baseString];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:baseString];
    
    [commentString addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]
                          range:range];
    [commentString addAttribute:NSKernAttributeName
                          value:@1.3
                          range:range];
    [commentString addAttribute:NSForegroundColorAttributeName
                          value:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]
                          range:range];
    
    return commentString;
}

//if we're told to stop editing, dismiss the keyboard
- (void) stopComposingComment {
    [self.textView resignFirstResponder];
}

#pragma mark - Button Target

- (void) commentButtonPressed:(UIButton *)sender {
    if (self.isWritingComment ) {
        [self.textView resignFirstResponder];
        self.textView.userInteractionEnabled = NO;
        [self.delegate commentViewDidPressCommentButton:self];
    } else {
        [self setIsWritingComment:YES animated:YES];
        [self.textView becomeFirstResponder];
    }
}

#pragma mark - Setters & Getters

- (void) setIsWritingComment:(BOOL)isWritingComment {
    [self setIsWritingComment:isWritingComment animated:NO];
}

//we provide both an animated and immediate way to set the views. Setting isWritingComment directly calls setIsWritingComment:animated:, passing NO for the animated variable
- (void) setIsWritingComment:(BOOL)isWritingComment animated:(BOOL)animated {
    _isWritingComment = isWritingComment;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            //call layoutSubviews to update the view positioning
            [self layoutSubviews];
        }];
    } else {
        //call layoutSubviews to update the view positioning
        [self layoutSubviews];
    }
}

- (void) setText:(NSString *)text {
    _text = text;
    self.textView.text = text;
    self.textView.userInteractionEnabled = YES;
    self.isWritingComment = text.length > 0;
}

#pragma mark - UITextViewDelegate
//use the textview delegate protocol to inform the delegate of user actions, and to update isWritingComment appropriately

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self setIsWritingComment:YES animated:YES];
    [self.delegate commentViewWillStartEditing:self];
    return YES;
}

//this is called whenever the user types or deletes a character
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    //send the delegate (the BLCMediaTableviewCell
    [self.delegate commentView:self textDidChange:newText];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    BOOL hasComment = (textView.text.length > 0);
    [self setIsWritingComment:hasComment];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
