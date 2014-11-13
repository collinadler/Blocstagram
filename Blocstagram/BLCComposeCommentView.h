//
//  BLCComposeCommentView.h
//  Blocstagram
//
//  Created by Collin Adler on 11/12/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCComposeCommentView;

//the delegate protocol will inform its delegate (the BLCMediaTableViewCell) when when the user starts editing, updates the text, and presses the comment button
@protocol BLCComposeCommentViewDelegate <NSObject>

- (void) commentViewDidPressCommentButton:(BLCComposeCommentView *)sender;
- (void) commentView:(BLCComposeCommentView *)sender textDidChange:(NSString *)text;
- (void) commentViewWillStartEditing:(BLCComposeCommentView *)sender;

@end

@interface BLCComposeCommentView : UIView

@property (nonatomic, weak) NSObject <BLCComposeCommentViewDelegate> *delegate;

@property (nonatomic, assign) BOOL isWritingComment;

//text contains the text of the comment, and will allow an external controller to set text
@property (nonatomic, strong) NSString *text;

//a controller can send this view this method if some external event means that the compose workflow should end and the keyboard should be dismissed
- (void) stopComposingComment;

@end
