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
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    self.container = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.container.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.container.showsVerticalScrollIndicator = NO;
    
    CGFloat padding = 12.0f;
    CGFloat width = frame.size.width-2*padding;
    
    UILabel *lblArticle = [[UILabel alloc] initWithFrame:CGRectMake(padding, 16.0f, width, 28.0f)];
    lblArticle.center = CGPointMake(0.5f*frame.size.width, lblArticle.center.y);
    lblArticle.textColor = [UIColor whiteColor];
    lblArticle.textAlignment = NSTextAlignmentCenter;
    lblArticle.text = @"Article";
    lblArticle.font = [UIFont fontWithName:kBaseFontName size:18.0f];
    lblArticle.backgroundColor = kDarkBlue;
    lblArticle.layer.cornerRadius = 6.0f;
    lblArticle.layer.masksToBounds = YES;
    [self.container addSubview:lblArticle];
    CGFloat y = lblArticle.frame.origin.y+lblArticle.frame.size.height+20.0f;

    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(padding, y, width, 600)];
    base.backgroundColor = kDarkBlue;
    base.layer.cornerRadius = 6.0f;
    base.layer.masksToBounds = YES;
    [self.container addSubview:base];
    
    width = base.frame.size.width-2*padding;
    y = padding;
    
    UILabel *lblJournal = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 16.0f)];
    lblJournal.textColor = [UIColor whiteColor];
    lblJournal.font = [UIFont fontWithName:kBaseFontName size:10.0f];
    lblJournal.text = [NSString stringWithFormat:@"%@", self.article.journal[@"iso"]];
    [base addSubview:lblJournal];
    
    UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 16.0f)];
    lblDate.textColor = [UIColor whiteColor];
    lblDate.font = lblJournal.font;
    lblDate.text = self.article.date;
    lblDate.textAlignment = NSTextAlignmentRight;
    [base addSubview:lblDate];
    y += lblDate.frame.size.height;
    
    width = base.frame.size.width-2*padding;
    UIView *bgWhite = [[UIView alloc] initWithFrame:CGRectMake(padding, y, width, base.frame.size.height)];
    bgWhite.backgroundColor = [UIColor whiteColor];
    [base addSubview:bgWhite];

    UIFont *font = [UIFont fontWithName:kBaseFontName size:18.0f];
    CGRect bounds = [self.article.title boundingRectWithSize:CGSizeMake(width, 250.0f)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    y = padding;
    width = bgWhite.frame.size.width-2*padding;
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, bounds.size.height)];
    self.lblTitle.text = self.article.title;
    self.lblTitle.font = font;
    self.lblTitle.textColor = [UIColor darkGrayColor];
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [bgWhite addSubview:self.lblTitle];
    y += self.lblTitle.frame.size.height+padding;
    

    font = [UIFont fontWithName:kBaseFontName size:12.0];
    bounds = [self.article.authorsString boundingRectWithSize:CGSizeMake(width-36.0f, 450.0f)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:font}
                                                      context:nil];
    
    self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(padding+18.0f, y, width-36.0f, bounds.size.height)];
    self.lblAuthors.text = self.article.authorsString;
    self.lblAuthors.font = font;
    self.lblAuthors.numberOfLines = 0;
    self.lblAuthors.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAuthors.textAlignment = NSTextAlignmentCenter;
    self.lblAuthors.textColor = [UIColor lightGrayColor];
    [bgWhite addSubview:self.lblAuthors];
    y += self.lblAuthors.frame.size.height+12.0f;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.lblAuthors.frame.origin.x, y, self.lblAuthors.frame.size.width, 0.5f)];
    line.backgroundColor = kDarkBlue;
    [bgWhite addSubview:line];
    y += 12.0f;
    
    
    bounds = [self.article.abstract boundingRectWithSize:CGSizeMake(width, 2*frame.size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:font}
                                                 context:nil];

    self.lblAbstract = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, bounds.size.height)];
    self.lblAbstract.numberOfLines = 0;
    self.lblAbstract.font = font;
    self.lblAbstract.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAbstract.text = self.article.abstract;
    self.lblAbstract.textColor = self.lblAuthors.textColor;
    [bgWhite addSubview:self.lblAbstract];
    y += self.lblAbstract.frame.size.height+2*padding;
    
    frame = bgWhite.frame;
    frame.size.height = y;
    bgWhite.frame = frame;

    frame = base.frame;
    frame.size.height = y+padding+bgWhite.frame.origin.y;
    base.frame = frame;

    self.container.contentSize = CGSizeMake(0, base.frame.origin.y+base.frame.size.height+3*padding);
    
    NSString *imgLock = (self.article.isFree) ? @"lockOpen.png" : @"lockClosed.png";
    UIImageView *iconLock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgLock]];
    CGRect iconFrame = iconLock.frame;
    iconFrame.origin = CGPointMake(self.container.frame.size.width-iconLock.frame.size.width-16.0f, self.container.contentSize.height-iconLock.frame.size.height-42.0f);
    iconLock.frame = iconFrame;
    [self.container addSubview:iconLock];

    [view addSubview:self.container];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeRight];
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(shareArticle)];
    
    
    
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
