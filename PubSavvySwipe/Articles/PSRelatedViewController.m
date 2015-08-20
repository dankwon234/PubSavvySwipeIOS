//
//  PSRelatedViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/3/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSRelatedViewController.h"
#import "PSArticleView.h"
#import "PSArticle.h"
#import "PSArticleViewController.h"
#import "PSWebViewController.h"

@interface PSRelatedViewController ()
@property (strong, nonatomic) NSMutableArray *relatedArticles;
@property (strong, nonatomic) PSArticle *currentArticle;
@property (strong, nonatomic) PSArticleView *topView;
@property (nonatomic) CGRect baseFrame;
@property (nonatomic) CGFloat padding;
@end

#define kPadding 12.0f
#define kSetSize 10


@implementation PSRelatedViewController
@synthesize currentArticle = _currentArticle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.currentArticle = nil;
        
    }
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    CGRect frame = view.frame;

    self.padding = 0.5f*(frame.size.width-[PSArticleView standardWidth]);

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
    
    if (self.device.saved.count==0) // no saved articles
        return;
    
    [self searchRelatedArticles:self.device.saved];
}

- (void)setCurrentArticle:(PSArticle *)currentArticle
{
    _currentArticle = currentArticle;
    if (currentArticle==nil)
        return;
    
    NSLog(@"CURRENT ARTICLE: %@", currentArticle.title);
}



- (void)searchRelatedArticles:(NSArray *)saved
{
    NSMutableString *pmids = [NSMutableString stringWithString:@""];
    for (int i=0; i<saved.count; i++) {
        NSString *savedPmid = saved[i];
        [pmids appendString:savedPmid];
        if (i != saved.count-1)
            [pmids appendString:@","];
    }
    
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchRelatedArticles:pmids completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *response = (NSDictionary *)result;
        NSLog(@"%@", [response description]);
        
        self.relatedArticles = [NSMutableArray array];
        NSArray *results = response[@"results"];
        if (results.count == 0){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"No Articles Found" message:@"There are no related articles."];
            return;
        }
        
        for (int i=0; i<results.count; i++) {
            PSArticle *article = [PSArticle articleWithInfo:results[i]];
            [self.relatedArticles addObject:article];
        }
        
        int max = (self.relatedArticles.count >= kSetSize) ? kSetSize : (int)self.relatedArticles.count;
        [self animateFeaturedArticles:max];
        [self findCurrentArticle];
    }];
}

- (void)animateFeaturedArticles:(int)max
{
    CGRect frame = self.view.frame;
    
    for (int i=0; i<self.relatedArticles.count; i++) {
        int idx = (int)self.relatedArticles.count-i-1; // adjust index to show articles in correct sequence
        
        PSArticle *article = self.relatedArticles[idx];
        
        int index = i%max;
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(0, self.padding+kNavBarHeight-index, [PSArticleView standardWidth], frame.size.height-180.0f)];
        articleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
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
        
//        [UIView animateWithDuration:1.65f
//                              delay:(index*0.18f)
//             usingSpringWithDamping:0.5f
//              initialSpringVelocity:0
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             CGRect frame = articleView.frame;
//                             frame.origin.x = kPadding;
//                             articleView.frame = frame;
//                         }
//                         completion:^(BOOL finished){
//                             
//                         }];
    }
    
    self.topView.delegate = self;
}



- (void)findCurrentArticle
{
    NSLog(@"Find Current Article: %d", (int)self.relatedArticles.count);
    if (self.relatedArticles.count == 0)
        return;
    
    if (self.currentArticle){
        [self.relatedArticles removeObject:self.currentArticle];
        self.currentArticle = nil;
    }
    
    if (self.relatedArticles.count == 0){
        NSLog(@"NO MORE ARTICLES!");
        [self searchRelatedArticles:self.device.saved];
        return;
    }
    
    self.currentArticle = self.relatedArticles[0];
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
    CGRect frame = self.topView.frame;
    //    NSLog(@"articleViewStoppedMoving: %.2f, %.2f", frame.origin.x, frame.origin.y);
    
    CGFloat nuetral = 90.0f;
    
    if (frame.origin.x > kPadding+nuetral){
        [self likeArticle];
        return;
    }
    
    if (frame.origin.x < kPadding-nuetral){
        [self dislikeArticle];
        return;
    }
    
    // neutral
    [UIView animateWithDuration:0.3f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.topView.frame;
                         frame.origin.x = kPadding;
                         frame.origin.y = kPadding;
                         self.topView.frame = frame;
                         
                     }
                     completion:NULL];
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
    //    NSLog(@"DIS-LIKE Article");
    [UIView animateWithDuration:0.20f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.topView.frame;
                         frame.origin.x = -self.view.frame.size.width-30.0f;
                         self.topView.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         if (self.relatedArticles.count > 0){
                             [self queueNextArticle];
                         }
                     }];
}


- (void)likeArticle
{
    NSLog(@"LIKE Article: %@", self.currentArticle.title);
    [self.device saveArticle:self.currentArticle];
    
    [UIView animateWithDuration:0.20f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.topView.frame;
                         frame.origin.x = self.view.frame.size.width+30.0f;
                         self.topView.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         if (self.relatedArticles.count > 0){
                             [self queueNextArticle];
                         }
                         
                     }];
}


@end
