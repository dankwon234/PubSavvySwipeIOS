//
//  PSArticlesViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 10/10/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticlesViewController.h"
#import "PSArticleView.h"
#import "PSArticle.h"
#import "PSArticleViewController.h"
#import "PSWebViewController.h"


@interface PSArticlesViewController ()

@end




@implementation PSArticlesViewController
@synthesize currentArticle = _currentArticle;
@synthesize topView = _topView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.currentArticle = nil;
        self.currentTerm = nil;
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    self.padding = 0.5f*(frame.size.width-[PSArticleView standardWidth]);
    
    self.lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(self.padding, 16.0f, [PSArticleView standardWidth], 28.0f)];
    self.lblHeader.center = CGPointMake(0.5f*frame.size.width, self.lblHeader.center.y);
    self.lblHeader.textColor = [UIColor whiteColor];
    self.lblHeader.textAlignment = NSTextAlignmentCenter;
    self.lblHeader.text = @"HEADER";
    self.lblHeader.font = [UIFont fontWithName:kBaseFontName size:18.0f];
    self.lblHeader.backgroundColor = kLightBlue;
    self.lblHeader.layer.cornerRadius = 6.0f;
    self.lblHeader.layer.masksToBounds = YES;
    [view addSubview:self.lblHeader];
    
    UIImageView *bgCards = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgCards.png"]];
    bgCards.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bgCards.center = CGPointMake(0.5f*frame.size.width, 0.49f*frame.size.height);
    [view addSubview:bgCards];
    
    CGFloat h = 44.0f;
    CGFloat w = 0.5f*(frame.size.width - 3*self.padding);
    CGFloat y = frame.size.height-h-self.padding;
    
    UIButton *btnDislike = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    NSArray *buttons = @[@{@"title":@"SKIP", @"color":kLightBlue, @"button":btnDislike}, @{@"title":@"KEEP", @"color":kDarkBlue, @"button":btnLike}];
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
    
    CGPoint ctr = self.loadingIndicator.center;
    ctr.y = 0.65f*self.view.frame.size.height;
    self.loadingIndicator.center = ctr;
    
}

- (void)setCurrentArticle:(PSArticle *)currentArticle
{
    _currentArticle = currentArticle;
    if (currentArticle==nil)
        return;
    
    NSLog(@"CURRENT ARTICLE: %@", currentArticle.title);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isFree"] == NO)
        return;
    
    PSArticle *article = (PSArticle *)object;
    if (article.isFree == NO)
        return;
    
    NSUInteger index = [self.articles indexOfObject:article];
    index = self.articles.count-index-1;
    
    PSArticleView *articleView = (PSArticleView *)[self.view viewWithTag:1000+index];
    if (articleView == nil)
        return;
    
    [articleView.iconLock setImage:[UIImage imageNamed:@"lockOpen.png"] forState:UIControlStateNormal];
    
}

// this has to be over-ridden by subclass view controller
- (void)searchArticles:(NSString *)term
{
    
}


- (void)animateArticleSet:(int)max
{
    CGRect frame = self.view.frame;
    
    for (int i=0; i<self.articles.count; i++) {
        int idx = (int)self.articles.count-i-1; // adjust index to show articles in correct sequence
        
        PSArticle *article = self.articles[idx];
        
        int index = i%max;
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(0, self.padding+kNavBarHeight-26.0f, [PSArticleView standardWidth], frame.size.height-180.0f)];
        articleView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
        
        articleView.tag = 1000+index;
        articleView.lblAbsratct.text = article.abstract;
        articleView.lblAuthors.text = article.authorsString;
        articleView.lblTitle.text = article.title;
        articleView.lblDate.text = article.date;
        articleView.lblPmid.text = [NSString stringWithFormat:@"PMID: %@", article.pmid];
        articleView.lblJournal.text = article.journal[@"iso"];
        
        CGPoint center = articleView.center;
        center.x = 0.5f*self.view.frame.size.width;
        articleView.center = center;
        self.baseFrame = articleView.frame;
        
        [self.view addSubview:articleView];
        self.topView = articleView;
        [self.loadingIndicator stopLoading];
        
        if (i == self.articles.count-1){
            articleView.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
            [UIView animateWithDuration:0.16f
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 articleView.transform = CGAffineTransformIdentity;
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
        
    }
    
    self.topView.delegate = self;
}



- (void)findCurrentArticle
{
    NSLog(@"Find Current Article: %d", (int)self.articles.count);
    if (self.articles.count == 0)
        return;
    
    if (self.currentArticle){
        [self.currentArticle removeObserver:self forKeyPath:@"isFree"];
        [self.articles removeObject:self.currentArticle];
        self.currentArticle = nil;
    }
    
    if (self.articles.count == 0){
        //        NSLog(@"NO MORE ARTICLES!");
        //        [self searchRandomArticles];
        [self searchArticles:self.currentTerm];
        return;
    }
    
    self.currentArticle = self.articles[0];
}

- (void)articleViewTapped:(NSInteger)tag
{
    NSLog(@"articleViewTapped: %@", self.currentArticle.title);
    if (self.currentArticle.isFree){
        PSWebViewController *webVc = [[PSWebViewController alloc] init];
        webVc.url = self.currentArticle.links[@"Url"];
        [self.navigationController pushViewController:webVc animated:YES];
        return;
    }
    
    PSWebViewController *webVc = [[PSWebViewController alloc] init];
    webVc.url = (self.currentArticle.doi) ? [NSString stringWithFormat:@"http://dx.doi.org/%@", self.currentArticle.doi] : [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/m/pubmed/%@/", self.currentArticle.pmid];
    [self.navigationController pushViewController:webVc animated:YES];
    
}

/*
 - (void)articleViewTapped:(NSInteger)tag
 {
 
 NSLog(@"articleViewTapped: %@", self.currentArticle.title);
 if (self.currentArticle.isFree == NO){
 PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
 articleVc.article = self.currentArticle;
 [self.navigationController pushViewController:articleVc animated:YES];
 return;
 }
 
 
 NSString *url = self.currentArticle.links[@"Url"];
 [self.loadingIndicator startLoading];
 [[PSWebServices sharedInstance] fetchHtml:url completionBlock:^(id result, NSError *error){
 if (error){
 dispatch_async(dispatch_get_main_queue(), ^{
 [self.loadingIndicator stopLoading];
 PSWebViewController *webVc = [[PSWebViewController alloc] init];
 webVc.url = url;
 [self.navigationController pushViewController:webVc animated:YES];
 });
 return;
 }
 
 [self.loadingIndicator stopLoading];
 // TODO: scrape html results for .pdf extension. if found, segue directly to that.
 NSString *html = (NSString *)result;
 NSArray *parts = [html componentsSeparatedByString:@" "];
 NSString *url = nil;
 for (NSString *text in parts) {
 if ([text rangeOfString:@".pdf"].location != NSNotFound){
 url = text;
 break;
 }
 }
 
 if (url == nil)
 url = self.currentArticle.links[@"Url"];
 else {
 NSArray *p = [url componentsSeparatedByString:@".pdf"];
 url = p[0];
 
 NSString *http = @"http";
 p = [url componentsSeparatedByString:http];
 url = p[p.count-1];
 url = [http stringByAppendingString:[NSString stringWithFormat:@"%@.pdf", url]];
 NSLog(@"PDF: %@", url);
 }
 
 
 dispatch_async(dispatch_get_main_queue(), ^{
 PSWebViewController *webVc = [[PSWebViewController alloc] init];
 webVc.url = url;
 [self.navigationController pushViewController:webVc animated:YES];
 });
 
 
 return;
 
 }];
 
 
 }
 */


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
        [self animateArticleSet:5]; // load next set of 5
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
                        if (self.articles.count > 0){
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
                        if (self.articles.count > 0){
                            [self queueNextArticle];
                        }
                    }];
    
}

- (void)likeArticle
{
    [self likeArticle:YES];
}

@end
