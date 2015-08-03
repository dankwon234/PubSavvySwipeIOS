//
//  PSArticleViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticleViewController.h"

@interface PSArticleViewController()
@property (strong, nonatomic) UIScrollView *container;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblAuthors;
@property (strong, nonatomic) UILabel *lblDetails;
@property (strong, nonatomic) UILabel *lblAbstract;
@end

@implementation PSArticleViewController
@synthesize article;


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
    view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    CGRect frame = view.frame;
    
    self.container = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.container.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.container.showsVerticalScrollIndicator = NO;
    
    CGFloat padding = 12.0f;
    CGFloat width = frame.size.width-2*padding;
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    CGRect bounds = [self.article.title boundingRectWithSize:CGSizeMake(width, 250.0f)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    CGFloat y = padding;
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, width, bounds.size.height)];
    self.lblTitle.text = self.article.title;
    self.lblTitle.font = font;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [self.container addSubview:self.lblTitle];
    y += self.lblTitle.frame.size.height+12.0f;
    
    font = [UIFont fontWithName:@"Arial" size:14.0f];
    self.lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 24.0f)];
    self.lblDetails.text = [NSString stringWithFormat:@"%@ | %@", self.article.journal[@"iso"], self.article.date];
    self.lblDetails.font = font;
    [self.container addSubview:self.lblDetails];
    y += self.lblDetails.frame.size.height+6.0f;
    

    bounds = [self.article.authorsString boundingRectWithSize:CGSizeMake(width, 300.0f)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:font}
                                                      context:nil];

    self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, bounds.size.height)];
    self.lblAuthors.text = self.article.authorsString;
    self.lblAuthors.font = font;
    self.lblAuthors.numberOfLines = 0;
    self.lblAuthors.lineBreakMode = NSLineBreakByWordWrapping;
    [self.container addSubview:self.lblAuthors];
    y += self.lblAuthors.frame.size.height+6.0f;
    

    bounds = [self.article.abstract boundingRectWithSize:CGSizeMake(width, 2*frame.size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:font}
                                                 context:nil];

    
    self.lblAbstract = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, bounds.size.height)];
    self.lblAbstract.numberOfLines = 0;
    self.lblAbstract.font = font;
    self.lblAbstract.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAbstract.text = self.article.abstract;
    [self.container addSubview:self.lblAbstract];
    y += self.lblAbstract.frame.size.height+2*padding;
    
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    btnShare.frame = CGRectMake(20.0f, y, frame.size.width-40.0f, 44.0f);
    btnShare.backgroundColor = kGreen;
    [btnShare setTitle:@"Share" forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareArticle) forControlEvents:UIControlEventTouchUpInside];
    [self.container addSubview:btnShare];
    y += btnShare.frame.size.height;
    
    self.container.contentSize = CGSizeMake(0, y+4*padding);
    
    [view addSubview:self.container];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
}

- (void)shareArticle
{
    NSString *articleUrl = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/pubmed/%@", self.article.pmid];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[articleUrl] applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    
    controller.excludedActivityTypes = excludedActivities;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}



@end
