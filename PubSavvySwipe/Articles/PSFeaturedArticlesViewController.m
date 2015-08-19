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
@property (strong, nonatomic) NSMutableArray *randomTerms;
@property (strong, nonatomic) NSMutableArray *featuredArticles;
@property (strong, nonatomic) PSArticle *currentArticle;
@property (strong, nonatomic) PSArticleView *topView;
@property (nonatomic) CGRect  baseFrame;
@end

#define kPadding 12.0f
#define kSetSize 10

@implementation PSFeaturedArticlesViewController
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
    
    UILabel *lblRandom = [[UILabel alloc] initWithFrame:CGRectMake(kPadding, kPadding, [PSArticleView standardWidth], 44.0f)];
    lblRandom.center = CGPointMake(0.5f*frame.size.width, lblRandom.center.y);
    lblRandom.textColor = [UIColor whiteColor];
    lblRandom.textAlignment = NSTextAlignmentCenter;
    lblRandom.text = @"Random";
    lblRandom.font = [UIFont fontWithName:kBaseFontName size:18.0f];
    lblRandom.backgroundColor = kLightBlue;
    lblRandom.layer.cornerRadius = 6.0f;
    lblRandom.layer.masksToBounds = YES;
    [view addSubview:lblRandom];
    
    CGFloat h = 44.0f;
    CGFloat w = 0.5f*(frame.size.width-3*kPadding);
    CGFloat y = frame.size.height-h-kPadding-20.0f;
    
    UIButton *btnDislike = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDislike.frame = CGRectMake(kPadding, y, w, h);
    btnDislike.backgroundColor = [UIColor lightGrayColor];
    btnDislike.layer.borderColor = [[UIColor grayColor] CGColor];
    btnDislike.layer.borderWidth = 0.5f;
    btnDislike.layer.cornerRadius = 2.0f;
    btnDislike.layer.masksToBounds = YES;
    btnDislike.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [btnDislike addTarget:self action:@selector(dislikeArticle) forControlEvents:UIControlEventTouchUpInside];
    [btnDislike setTitle:@"SKIP" forState:UIControlStateNormal];
    [btnDislike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:btnDislike];

    
    UIButton *btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLike.frame = CGRectMake(frame.size.width-w-kPadding, y, w, h);
    btnLike.backgroundColor = kGreen;
    btnLike.layer.borderColor = [[UIColor grayColor] CGColor];
    btnLike.layer.borderWidth = 0.5f;
    btnLike.layer.cornerRadius = 2.0f;
    btnLike.layer.masksToBounds = YES;
    btnLike.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [btnLike addTarget:self action:@selector(likeArticle) forControlEvents:UIControlEventTouchUpInside];
    [btnLike setTitle:@"KEEP" forState:UIControlStateNormal];
    [btnLike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:btnLike];

    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchRandomArticles];
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

- (void)searchRandomArticles
{
    if (self.randomTerms.count==0){
//        NSLog(@"SEARCH RANDOM ARTICLES: Out of Terms");
        return;
    }
    
    NSLog(@"SEARCH RANDOM ARTICLES: %@", [self.randomTerms description]);
    
    int i = abs(arc4random());
    i = i % self.randomTerms.count;
    
    NSString *term = self.randomTerms[i];
    [self searchArticles:term];
    [self.randomTerms removeObject:term];
    
}

- (void)searchArticles:(NSString *)term
{
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchArticles:@{@"term":term, @"limit":@"10"} completionBlock:^(id result, NSError *error){
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
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(0, kPadding+kNavBarHeight, [PSArticleView standardWidth], frame.size.height-170.0f)];
        articleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        articleView.tag = 1000 + index;
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
        [self searchRandomArticles];
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
    if (rotate){
        [UIView animateWithDuration:0.18f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.topView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_4), CGAffineTransformMakeTranslation(-130, 0));
                             
                         }
                         completion:^(BOOL finished){
                             if (self.featuredArticles.count > 0){
                                 [self queueNextArticle];
                             }
                         }];
        return;
    }
    
    [UIView transitionWithView:self.topView
                      duration:0.4f
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
    
    if (rotate){
        [UIView animateWithDuration:0.18f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.topView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_4), CGAffineTransformMakeTranslation(130.0f, 0.0f));
                             
                         }
                         completion:^(BOOL finished){
                             if (self.featuredArticles.count > 0){
                                 [self queueNextArticle];
                             }
                         }];
        return;
    }

    [UIView transitionWithView:self.topView
                      duration:0.4f
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
