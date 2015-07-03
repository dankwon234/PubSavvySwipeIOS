//
//  PSArticleCell.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticleCell.h"

@implementation PSArticleCell
@synthesize lblAuthors;
@synthesize lblTitle;
@synthesize lblDetail;

#define kStandardCellHeight 64.0f
#define kTitleFont [UIFont fontWithName:@"Helvetica" size:16.0f]

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:line];
        
        static CGFloat padding = 10.0f;
        CGFloat y = 10.0f;
        CGFloat width = frame.size.width-2*padding;
        
        self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 16.0f)];
        self.lblAuthors.textColor = [UIColor grayColor];
        self.lblAuthors.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:self.lblAuthors];
        y += self.lblAuthors.frame.size.height+4.0f;
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 32.0f)];
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblTitle.font = kTitleFont;
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self.contentView addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 16.0f)];
        self.lblDetail.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.lblDetail];
        
        
    }
    
    return self;
}

- (void)dealloc
{
    [self.lblTitle removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    CGRect frame = self.lblTitle.frame;
    CGRect boundingRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake(frame.size.width, 350.0f)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                           context:nil];
    
    frame.size.height = boundingRect.size.height;
    self.lblTitle.frame = frame;
    
    CGFloat y = frame.origin.y+frame.size.height+24.0f;
    
    frame = self.lblDetail.frame;
    frame.origin.y = y;
    self.lblDetail.frame = frame;
    
//    boundingRect.size.height
    
    
}

+ (UIFont *)titleFont
{
    return kTitleFont;
}

+ (CGFloat)standardCellHeight
{
    return kStandardCellHeight;
}





@end
