//
//  PSArticleView.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticleView.h"
#import "UIView+draggable.h"
#import "Config.h"

@interface PSArticleView ()
@property (strong, nonatomic) UIScrollView *base;
@property (nonatomic) BOOL isMoving;
@property (strong, nonatomic) UIView *line;
@end

@implementation PSArticleView
@synthesize delegate = _delegate;
@synthesize lblJournal;
@synthesize lblDate;
@synthesize lblAuthors;
@synthesize lblTitle;
@synthesize iconLock;
@synthesize lblAbsratct;
@synthesize lblPmid;

#define kStandardWidth 250.0f

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.isMoving = NO;
        
        self.backgroundColor = kLightBlue;
        self.layer.cornerRadius = 6.0f;
        self.layer.masksToBounds = YES;
        
        CGFloat x = 12.0f;
        CGFloat padding = 12.0f;
        CGFloat y = padding;
        CGFloat width = frame.size.width-2*x;
        
        self.lblJournal = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12.0f)];
        self.lblJournal.textAlignment = NSTextAlignmentLeft;
        self.lblJournal.textColor = [UIColor whiteColor];
        self.lblJournal.font = [UIFont fontWithName:kBaseFontName size:10.0f];
        [self addSubview:self.lblJournal];

        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12.0f)];
        self.lblDate.textAlignment = NSTextAlignmentRight;
        self.lblDate.textColor = self.lblJournal.textColor;
        self.lblDate.font = self.lblJournal.font;
        [self addSubview:self.lblDate];

        
        self.base = [[UIScrollView alloc] initWithFrame:CGRectMake(x, 26.0f, frame.size.width-2*x, frame.size.height-42.0f)];
        self.base.backgroundColor = [UIColor whiteColor];
        self.base.showsVerticalScrollIndicator = NO;
        

        y = padding;
        width = self.base.frame.size.width-2*padding;
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 32.0f)];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.textColor = [UIColor darkGrayColor];
        self.lblTitle.font = [UIFont fontWithName:kBaseFontName size:18.0f];
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self.base addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        
        self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(36.0f, y, width-36.0f, 18.0f)];
        self.lblAuthors.font = [UIFont fontWithName:kBaseFontName size:12.0];
        self.lblAuthors.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblAuthors.textColor = [UIColor lightGrayColor];
        self.lblAuthors.backgroundColor = [UIColor clearColor];
        self.lblAuthors.numberOfLines = 0;
        [self.base addSubview:self.lblAuthors];
        y += self.lblAuthors.frame.size.height;
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(36.0f, y, width-36.0f, 1.0f)];
        self.line.backgroundColor = kLightBlue;
        [self.base addSubview:self.line];

        
        self.lblAbsratct = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, y, width-24.0f, 18.0f)];
        self.lblAbsratct.font = self.lblAuthors.font;
        self.lblAbsratct.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblAbsratct.textColor = [UIColor lightGrayColor];
        self.lblAbsratct.backgroundColor = [UIColor clearColor];
        self.lblAbsratct.numberOfLines = 0;
        [self.base addSubview:self.lblAbsratct];
        
        
        [self.base addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        [self addSubview:self.base];
        y = self.base.frame.origin.y+self.base.frame.size.height+2.0f;

        self.lblPmid = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12.0f)];
        self.lblPmid.textColor = [UIColor whiteColor];
        self.lblPmid.font = [UIFont fontWithName:kBaseFontName size:10.0f];
        [self addSubview:lblPmid];

        self.iconLock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lockClosed.png"]];
        CGRect iconFrame = self.iconLock.frame;
        iconFrame.origin = CGPointMake(self.frame.size.width-self.iconLock.frame.size.width, self.frame.size.height-self.iconLock.frame.size.height);
        self.iconLock.frame = iconFrame;
        
        
        [self addSubview:self.iconLock];

        
        [self enableDragging];
        
        // http://stackoverflow.com/questions/14556605/capturing-self-strongly-in-this-block-is-likely-to-lead-to-a-retain-cycle
        __weak typeof(self) weakSelf = self;
        self.draggingEndedBlock = ^{
            [weakSelf.delegate articleViewStoppedMoving];
        };
    }
    
    return self;
}


- (void)dealloc
{
    [self.lblTitle removeObserver:self forKeyPath:@"text"];
}


+ (PSArticleView *)articleViewWithFrame:(CGRect)frame
{
    PSArticleView *articleView = [[PSArticleView alloc] initWithFrame:frame];
    return articleView;
}

+ (CGFloat)standardWidth
{
    return kStandardWidth;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    CGRect frame = self.lblTitle.frame;
    CGRect bounds = [self.lblTitle.text boundingRectWithSize:CGSizeMake(frame.size.width, 460.0f)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                     context:nil];
    
    frame.size.height = bounds.size.height;
    self.lblTitle.frame = frame;
    
    CGFloat y = frame.origin.y + frame.size.height+12.0f;
    frame = self.lblAuthors.frame;
    frame.origin.y = y;

    bounds = [self.lblAuthors.text boundingRectWithSize:CGSizeMake(frame.size.width, 100.0f)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:self.lblAuthors.font}
                                                     context:nil];
    
    frame.size.height = bounds.size.height;
    frame.origin.y = y;
    self.lblAuthors.frame = frame;
    y += frame.size.height+12.0f;

    frame = self.line.frame;
    frame.origin.y = y;
    self.line.frame = frame;
    y += 12.0f;
    
    bounds = [self.lblAbsratct.text boundingRectWithSize:CGSizeMake(frame.size.width, 1000.0f)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:self.lblAbsratct.font}
                                                 context:nil];

    frame = self.lblAbsratct.frame;
    frame.origin.y = y;
    frame.size.height = bounds.size.height;
    self.lblAbsratct.frame = frame;
    
    
    self.base.contentSize = CGSizeMake(0, y+frame.size.height+12.0f);
    

}

- (void)tap:(UIGestureRecognizer *)tap
{
    [self.delegate articleViewTapped:self.tag];
}





@end
