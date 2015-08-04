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
    
    NSMutableArray *saved = self.device.saved;
    if (saved.count==0) // no saved articles
        return;
    
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
        for (int i=0; i<results.count; i++) {
            PSArticle *article = [PSArticle articleWithInfo:results[i]];
            [self.relatedArticles addObject:article];
        }
        
        int max = (self.relatedArticles.count >= kSetSize) ? kSetSize : (int)self.relatedArticles.count;
        [self animateFeaturedArticles:max];
        [self findCurrentArticle];
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
    [[PSWebServices sharedInstance] searchArticles:@{@"term":term, @"limit":@"10"} completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *response = (NSDictionary *)result;
            //            NSLog(@"%@", [response description]);
            
            self.relatedArticles = [NSMutableArray array];
            NSArray *results = response[@"results"];
            for (int i=0; i<results.count; i++) {
                PSArticle *article = [PSArticle articleWithInfo:results[i]];
                [self.relatedArticles addObject:article];
            }
            
            int max = (self.relatedArticles.count >= kSetSize) ? kSetSize : (int)self.relatedArticles.count;
            [self animateFeaturedArticles:max];
            [self findCurrentArticle];
            
        });
    }];
}


- (void)animateFeaturedArticles:(int)max
{
    CGRect frame = self.view.frame;
    
    for (int i=0; i<self.relatedArticles.count; i++) {
        int idx = (int)self.relatedArticles.count-i-1; // adjust index to show articles in correct sequence
        
        PSArticle *article = self.relatedArticles[idx];
        
        CGFloat x = (i%2 == 0) ? -frame.size.width : frame.size.width;
        int index = i%max;
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(x, kPadding, frame.size.width-2*kPadding, frame.size.height-160.0f)];
        articleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        articleView.backgroundColor = [UIColor whiteColor];
        
        articleView.tag = 1000 + index;
        articleView.lblAbsratct.text = article.abstract;
        articleView.lblAuthors.text = article.authorsString;
        articleView.lblTitle.text = article.title;
        articleView.lblDate.text = article.date;
        articleView.lblJournal.text = article.journal[@"iso"];
        
        [self.view addSubview:articleView];
        self.topView = articleView;
        [self.loadingIndicator stopLoading];
        
        [UIView animateWithDuration:1.65f
                              delay:(index*0.18f)
             usingSpringWithDamping:0.5f
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = articleView.frame;
                             frame.origin.x = kPadding;
                             articleView.frame = frame;
                         }
                         completion:^(BOOL finished){
                             
                         }];
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
//        [self searchRandomArticles];
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
