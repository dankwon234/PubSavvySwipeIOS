//
//  PSArticleCell.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/20/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticleCell.h"
#import "Config.h"

@implementation PSArticleCell
@synthesize lblTitle;
@synthesize lblAuthors;
@synthesize lblPmid;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        CGFloat y = 12.0f;
        CGFloat x = 20.0f;
        CGFloat width = frame.size.width-2*x;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 22.0f)];
        self.lblTitle.numberOfLines = 2;
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self.contentView addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 16.0f)];
        self.lblAuthors.font = [UIFont systemFontOfSize:12.0f];
        self.lblAuthors.textColor = kLightBlue;
        [self.contentView addSubview:self.lblAuthors];
        y += self.lblAuthors.frame.size.height;

        self.lblPmid = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 0.35f*width, 16.0f)];
        self.lblPmid.backgroundColor = kDarkBlue;
        self.lblPmid.font = self.lblAuthors.font;
        self.lblPmid.textColor = [UIColor whiteColor];
        self.lblPmid.text = @"PMID: 4235345";
        [self.contentView addSubview:self.lblPmid];
        
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

    if ([object isEqual:self.lblTitle]){
        CGRect frame = self.lblTitle.frame;
        CGRect bounds = [self.lblTitle.text boundingRectWithSize:CGSizeMake(frame.size.width, 44.0f)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                         context:nil];
        
        frame.size.height = bounds.size.height;
        self.lblTitle.frame = frame;
        CGFloat y = frame.origin.y+frame.size.height+4.0f;
        
        frame = self.lblAuthors.frame;
        frame.origin.y = y;
        self.lblAuthors.frame = frame;
        y += frame.size.height;
        
        frame = self.lblPmid.frame;
        frame.origin.y = y;
        self.lblPmid.frame = frame;
        
    }
    
    
    
}

@end
