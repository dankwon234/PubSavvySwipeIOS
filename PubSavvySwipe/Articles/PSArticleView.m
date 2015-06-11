//
//  PSArticleView.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticleView.h"
#import "UIView+draggable.h"

@interface PSArticleView ()
@property (strong, nonatomic) UIView *line;
@end

@implementation PSArticleView
@synthesize delegate;
@synthesize lblJournal;
@synthesize lblDate;
@synthesize lblAuthors;
@synthesize lblTitle;
@synthesize iconAccess;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        
        CGFloat y = 6.0f;
        static CGFloat padding = 12.0f;
        CGFloat width = (frame.size.width/3.0f);
        CGFloat x = 0.0f;
        
        self.lblJournal = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12.0f)];
        self.lblJournal.textAlignment = NSTextAlignmentCenter;
        self.lblJournal.textColor = [UIColor lightGrayColor];
        self.lblJournal.font = [UIFont fontWithName:@"Heiti SC" size:10.0f];
        self.lblJournal.text = @"Rofo";
        [self addSubview:self.lblJournal];
        x += width;

        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12.0f)];
        self.lblDate.textAlignment = NSTextAlignmentCenter;
        self.lblDate.textColor = self.lblJournal.textColor;
        self.lblDate.font = self.lblJournal.font;
        self.lblDate.text = @"June 10, 2015";
        [self addSubview:self.lblDate];
        x += width;

        self.iconAccess = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconPadlock.png"]];
        
        

        y += self.lblJournal.frame.size.height+6.0f;
        width = frame.size.width-2*padding;
        
        self.line = [[UIView alloc] initWithFrame:CGRectMake(padding, y, width, 1.0f)];
        self.line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.line];
        y += self.line.frame.size.height+padding;
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 32.0f)];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.textColor = [UIColor darkGrayColor];
        self.lblTitle.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
        self.lblTitle.text = @"Article Title";
        self.lblTitle.numberOfLines = 0;
        self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        [self.lblTitle addObserver:self forKeyPath:@"text" options:0 context:nil];
        [self addSubview:self.lblTitle];
        y += self.lblTitle.frame.size.height;
        
        
        self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 18.0f)];
        self.lblAuthors.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
        self.lblAuthors.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblAuthors.textColor = [UIColor lightGrayColor];
        self.lblAuthors.backgroundColor = [UIColor clearColor];
        self.lblAuthors.numberOfLines = 0;
        [self addSubview:self.lblAuthors];
        
        
        [self enableDragging];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]==NO)
        return;
    
    CGRect frame = self.lblTitle.frame;
    CGRect bounds = [self.lblTitle.text boundingRectWithSize:CGSizeMake(frame.size.width, 100.0f)
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

    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesBegan:");
//    UITouch *touch = [touches anyObject];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesMoved:");
//    UITouch *touch = [touches anyObject];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesEnded: ");
//    UITouch *touch = [touches anyObject];
    
    [self.delegate articleViewStoppedMoving];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled:");
    
}



@end
