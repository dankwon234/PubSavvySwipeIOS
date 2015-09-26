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
@synthesize lblJournal;
@synthesize lblPmid;
@synthesize iconLock;


#define kCellHeight 124.0f

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0, frame.size.width-40.0f, 1.0f)];
        line.backgroundColor = [UIColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:1];
        [self.contentView addSubview:line];
        
        CGFloat y = 12.0f;
        CGFloat x = 20.0f;
        CGFloat width = frame.size.width-2*x;
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 22.0f)];
        self.lblTitle.numberOfLines = 2;
        self.lblTitle.textColor = kDarkBlue;
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self.contentView addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 14.0f)];
        self.lblAuthors.font = [UIFont systemFontOfSize:12.0f];
        self.lblAuthors.textColor = kDarkBlue;
        [self.contentView addSubview:self.lblAuthors];
        y += self.lblAuthors.frame.size.height;

        self.lblJournal = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 14.0f)];
        self.lblJournal.font = [UIFont systemFontOfSize:12.0f];
        self.lblJournal.textColor = kLightBlue;
        [self.contentView addSubview:self.lblJournal];
        y += self.lblJournal.frame.size.height;

        self.lblPmid = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 0.40f*width, 16.0f)];
        self.lblPmid.backgroundColor = kDarkBlue;
        self.lblPmid.font = self.lblAuthors.font;
        self.lblPmid.textAlignment = NSTextAlignmentCenter;
        self.lblPmid.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.lblPmid];
        
        CGFloat dimen = 20.0f;
        self.iconLock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lockClosed.png"]];
        self.iconLock.frame = CGRectMake(frame.size.width-dimen-20.0f, y, dimen, dimen);
        [self.contentView addSubview:self.iconLock];
        
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
        CGFloat y = frame.origin.y+frame.size.height+6.0f;
        
        frame = self.lblAuthors.frame;
        frame.origin.y = y;
        self.lblAuthors.frame = frame;
        y += frame.size.height;
        
        frame = self.lblJournal.frame;
        frame.origin.y = y;
        self.lblJournal.frame = frame;
        y += frame.size.height+4.0f;
        
        frame = self.lblPmid.frame;
        frame.origin.y = y;
        self.lblPmid.frame = frame;
        
        frame = self.iconLock.frame;
        frame.origin.y = y;
        self.iconLock.frame = frame;
    }
}

+ (CGFloat)standardCellHeight
{
    return kCellHeight;
    
}

@end
