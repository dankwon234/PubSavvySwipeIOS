//
//  PSAboutViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 9/10/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSAboutViewController.h"

@implementation PSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        
    }
    
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgAbout.png"]];
    CGRect frame = view.frame;

    CGFloat y = 0.58f*frame.size.height;
    UILabel *lblCreatedBy = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 28.0f)];
    lblCreatedBy.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblCreatedBy.textColor = [UIColor whiteColor];
    lblCreatedBy.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblCreatedBy.textAlignment = NSTextAlignmentCenter;
    lblCreatedBy.text = @"Created By";
    [view addSubview:lblCreatedBy];
    y += lblCreatedBy.frame.size.height;
    
    UILabel *lblFrameResearch = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 28.0f)];
    lblFrameResearch.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblFrameResearch.textColor = [UIColor grayColor];
    lblFrameResearch.font = lblCreatedBy.font;
    lblFrameResearch.textAlignment = NSTextAlignmentCenter;
    lblFrameResearch.text = @"Frame Research, LLC";
    [view addSubview:lblFrameResearch];
    y += lblFrameResearch.frame.size.height+32.0f;
    
    
    UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, 36.0f)];
    lblComment.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lblComment.backgroundColor = kDarkBlue;
    lblComment.textColor = [UIColor whiteColor];
    lblComment.textAlignment = NSTextAlignmentCenter;
    lblComment.font = lblFrameResearch.font;
    lblComment.text = @"Have a Comment?";
    [view addSubview:lblComment];
    
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    

    
}

@end
