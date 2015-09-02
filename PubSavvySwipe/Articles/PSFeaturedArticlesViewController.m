//
//  PSFeaturedArticlesViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSFeaturedArticlesViewController.h"
#import "PSArticleView.h"
#import "PSArticle.h"
#import "PSArticleViewController.h"
#import "PSWebViewController.h"


@interface PSFeaturedArticlesViewController ()
@property (copy, nonatomic) NSString *currentTerm;
@property (strong, nonatomic) NSMutableArray *randomTerms;
@property (strong, nonatomic) NSMutableArray *featuredArticles;
@property (strong, nonatomic) PSArticle *currentArticle;
@property (strong, nonatomic) PSArticleView *topView;
@property (nonatomic) CGRect baseFrame;
@property (nonatomic) CGFloat padding;
@property (nonatomic) int offset;
@end

#define kSetSize 10

@implementation PSFeaturedArticlesViewController
@synthesize currentArticle = _currentArticle;
@synthesize topView = _topView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.currentArticle = nil;
        self.currentTerm = nil;
        self.offset = 0;
        
    }
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    self.padding = 0.5f*(frame.size.width-[PSArticleView standardWidth]);
    
    UILabel *lblRandom = [[UILabel alloc] initWithFrame:CGRectMake(self.padding, 10.0f, [PSArticleView standardWidth], 28.0f)];
    lblRandom.center = CGPointMake(0.5f*frame.size.width, lblRandom.center.y);
    lblRandom.textColor = [UIColor whiteColor];
    lblRandom.textAlignment = NSTextAlignmentCenter;
    lblRandom.text = @"Random";
    lblRandom.font = [UIFont fontWithName:kBaseFontName size:18.0f];
    lblRandom.backgroundColor = kLightBlue;
    lblRandom.layer.cornerRadius = 6.0f;
    lblRandom.layer.masksToBounds = YES;
    [view addSubview:lblRandom];
    
    UIImageView *bgCards = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgCards.png"]];
    bgCards.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bgCards.center = CGPointMake(0.5f*frame.size.width, 0.5f*frame.size.height);
    [view addSubview:bgCards];
    
    CGFloat h = 44.0f;
    CGFloat w = 0.5f*(frame.size.width-3*self.padding);
    CGFloat y = frame.size.height-h-self.padding-20.0f;
    
    UIButton *btnDislike = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    NSArray *buttons = @[@{@"title":@"SKIP", @"color":kDarkBlue, @"button":btnDislike}, @{@"title":@"LIKE", @"color":kLightBlue, @"button":btnLike}];
    CGRect buttonFrame = CGRectMake(self.padding, y, w, h);
    UIColor *darkGray = [UIColor darkGrayColor];
    UIColor *white = [UIColor whiteColor];
    
    for (NSDictionary *btnInfo in buttons) {
        UIButton *btn = btnInfo[@"button"];
        btn.frame = buttonFrame;
        btn.backgroundColor = btnInfo[@"color"];
        btn.layer.shadowColor = [darkGray CGColor];
        btn.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        btn.layer.shadowOpacity = 2.0f;
        btn.layer.shadowPath = [UIBezierPath bezierPathWithRect:btnDislike.bounds].CGPath;
        btn.layer.cornerRadius = 4.0f;
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [btn setTitle:btnInfo[@"title"] forState:UIControlStateNormal];
        [btn setTitleColor:white forState:UIControlStateNormal];
        [view addSubview:btn];
        buttonFrame.origin.x = frame.size.width-w-self.padding;
    }
    
    [btnDislike addTarget:self action:@selector(dislikeArticle) forControlEvents:UIControlEventTouchUpInside];
    [btnLike addTarget:self action:@selector(likeArticle) forControlEvents:UIControlEventTouchUpInside];

    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    

    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] fetchRandomTerms:kAutoSearchId completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *response = (NSDictionary *)result;
        NSDictionary *autosearch = response[@"autosearch"];
        self.randomTerms = [NSMutableArray arrayWithArray:autosearch[@"terms"]];
        NSLog(@"%@", [self.randomTerms description]);
        
        if (self.randomTerms.count==0) // nothing there for some reason
            return;
        
        int i = abs(arc4random());
        i = i % self.randomTerms.count;
        self.currentTerm = self.randomTerms[i];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchArticles:self.currentTerm];
        });
        
    }];
}

- (void)setCurrentArticle:(PSArticle *)currentArticle
{
    _currentArticle = currentArticle;
    if (currentArticle==nil)
        return;
    
    NSLog(@"CURRENT ARTICLE: %@", currentArticle.title);
}

- (void)searchArticles:(NSString *)term
{
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchArticles:@{@"term":term, @"limit":@"10", @"offset":[NSString stringWithFormat:@"%d", self.offset]} completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *response = (NSDictionary *)result;
            
            self.featuredArticles = [NSMutableArray array];
            NSArray *results = response[@"results"];
            for (int i=0; i<results.count; i++) {
                PSArticle *article = [PSArticle articleWithInfo:results[i]];
                [self.featuredArticles addObject:article];
                self.offset++;
            }
            
            int max = (self.featuredArticles.count >= kSetSize) ? kSetSize : (int)self.featuredArticles.count;
            [self animateFeaturedArticles:max];
            [self findCurrentArticle];
        });
    }];
}


- (void)animateFeaturedArticles:(int)max
{
    CGRect frame = self.view.frame;
    
    for (int i=0; i<self.featuredArticles.count; i++) {
        int idx = (int)self.featuredArticles.count-i-1; // adjust index to show articles in correct sequence
        
        PSArticle *article = self.featuredArticles[idx];
        
        int index = i%max;
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(0, self.padding+kNavBarHeight-24.0f, [PSArticleView standardWidth], frame.size.height-180.0f)];
        articleView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
        
        articleView.tag = 1000+index;
        articleView.lblAbsratct.text = article.abstract;
        articleView.lblAuthors.text = article.authorsString;
        articleView.lblTitle.text = article.title;
        articleView.lblDate.text = article.date;
        articleView.lblJournal.text = article.journal[@"iso"];
        
        CGPoint center = articleView.center;
        center.x = 0.5f*self.view.frame.size.width;
        articleView.center = center;
        self.baseFrame = articleView.frame;

        [self.view addSubview:articleView];
        self.topView = articleView;
        [self.loadingIndicator stopLoading];
        
        
//        [UIView animateWithDuration:1.2f
//                              delay:0.1f*index
//             usingSpringWithDamping:0.5f
//              initialSpringVelocity:0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             articleView.frame = CGRectMake(articleView.frame.origin.x, kPadding+kNavBarHeight-index, [PSArticleView standardWidth], articleView.frame.size.height);
//                         }
//                         completion:^(BOOL finished){
//                             
//                         }];
        
    }
    
    self.topView.delegate = self;
}



- (void)findCurrentArticle
{
    NSLog(@"Find Current Article: %d", (int)self.featuredArticles.count);
    if (self.featuredArticles.count == 0)
        return;
    
    if (self.currentArticle){
        [self.featuredArticles removeObject:self.currentArticle];
        self.currentArticle = nil;
    }
    
    if (self.featuredArticles.count == 0){
//        NSLog(@"NO MORE ARTICLES!");
//        [self searchRandomArticles];
        [self searchArticles:self.currentTerm];
        return;
    }
    
    self.currentArticle = self.featuredArticles[0];
}

- (void)articleViewTapped:(NSInteger)tag
{
    NSLog(@"articleViewTapped: %@", self.currentArticle.title);
    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
    articleVc.article = self.currentArticle;
//    articleVc.url = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/m/pubmed/%@/", self.currentArticle.pmid];
    [self.navigationController pushViewController:articleVc animated:YES];
    
}

- (void)articleViewStoppedMoving
{
    CGPoint center = self.topView.center;
    CGFloat nuetral = 75.0f;
    
    CGFloat screenCenter = self.view.center.x;
    
    if (center.x > screenCenter+nuetral){
        [self likeArticle:NO];
        return;
    }
    
    if (center.x < screenCenter-nuetral){
        [self dislikeArticle:NO];
        return;
    }
    
    // neutral
    [UIView animateWithDuration:0.3f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.topView.frame= self.baseFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


- (void)queueNextArticle
{
//    NSLog(@"queueNextArticle: %d", (int)self.topView.tag);
    if (self.topView.tag == 1000){
        [self.topView removeFromSuperview];
        self.topView.delegate = nil;
        self.topView = nil;
        
        [self findCurrentArticle];
        [self animateFeaturedArticles:5]; // load next set of 5
        return;
    }
    
    int tag = (int)self.topView.tag;
    [self.topView removeFromSuperview];
    self.topView = (PSArticleView *)[self.view viewWithTag:tag-1];
    self.topView.delegate = self;
    
    // assign current article
    [self findCurrentArticle];
}


- (void)dislikeArticle
{
    [self dislikeArticle:YES];
}

- (void)dislikeArticle:(BOOL)rotate
{
    NSLog(@"DIS-LIKE Article");
    [UIView transitionWithView:self.topView
                      duration:0.6f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        CGRect frame = self.topView.frame;
                        frame.origin.x = -self.view.frame.size.width-30.0f;
                        self.topView.frame = frame;
                    }
                    completion:^(BOOL finished){
                        if (self.featuredArticles.count > 0){
                            [self queueNextArticle];
                        }
                        
                    }];
    
}

- (void)likeArticle:(BOOL)rotate
{
    NSLog(@"LIKE Article: %@", self.currentArticle.title);
    [self.device saveArticle:self.currentArticle];
    [UIView transitionWithView:self.topView
                      duration:0.6f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        CGRect frame = self.topView.frame;
                        frame.origin.x = self.view.frame.size.width+30.0f;
                        self.topView.frame = frame;
                    }
                    completion:^(BOOL finished){
                        if (self.featuredArticles.count > 0){
                            [self queueNextArticle];
                        }
                    }];

}

- (void)likeArticle
{
    [self likeArticle:YES];
}

@end
