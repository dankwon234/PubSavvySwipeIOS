//
//  PSArticleView.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSArticleViewDelegate
- (void)articleViewStoppedMoving;
@end

@interface PSArticleView : UIView

@property (assign) id delegate;
@property (strong, nonatomic) UILabel *lblJournal;
@property (strong, nonatomic) UILabel *lblDate;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblAuthors;
@property (strong, nonatomic) UIImageView *iconAccess;
+ (PSArticleView *)articleViewWithFrame:(CGRect)frame;
@end
