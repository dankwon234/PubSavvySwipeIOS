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
    y += lblComment.frame.size.height+12.0f;
    
    CGFloat h = 32.0f;
    UIButton *btnSendFeedback = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSendFeedback.frame = CGRectMake(20.0f, y, frame.size.width-40.0f, h);
    btnSendFeedback.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [btnSendFeedback setTitle:@"Send Feedback" forState:UIControlStateNormal];
    [btnSendFeedback setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnSendFeedback addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSendFeedback];
    y += btnSendFeedback.frame.size.height;

    UIButton *btnReview = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReview.frame = CGRectMake(20.0f, y, frame.size.width-40.0f, h);
    btnReview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [btnReview setTitle:@"Review in App Store" forState:UIControlStateNormal];
    [btnReview setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnReview addTarget:self action:@selector(reviewInAppstore:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnReview];

    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    
}

- (void)sendFeedback:(UIButton *)btn
{
    NSLog(@"sendFeedback: ");
    if([MFMailComposeViewController canSendMail]==NO)
        return;

    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setMailComposeDelegate:self];
    [mailController setSubject:@"PubSavvy Swipe"];
    [mailController setToRecipients:[NSArray arrayWithObject:@"info@frameresearch.com"]];
    [self presentViewController:mailController animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    NSLog(@"controller didFinishWithResult:");
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reviewInAppstore:(UIButton *)btn
{
    NSLog(@"reviewInAppstore: ");
}

@end
