//
//  PSArticleCell.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/20/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <UIKit/UIKit.h>

@interface PSArticleCell : UITableViewCell

@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblAuthors;
@property (strong, nonatomic) UILabel *lblJournal;
@property (strong, nonatomic) UILabel *lblPmid;
+ (CGFloat)standardCellHeight;
@end
