//
//  PSFeaturedArticlesViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSFeaturedArticlesViewController.h"
#import "PSArticleView.h"
#import "PSArticle.h"


@interface PSFeaturedArticlesViewController ()
@property (strong, nonatomic) NSMutableArray *featuredArticles;
@property (strong, nonatomic) PSArticleView *topView;
@end

#define kPadding 12.0f

@implementation PSFeaturedArticlesViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.featuredArticles = [NSMutableArray array];
        
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
    
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchArticles:@{@"term":@"cancer"} completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *response = (NSDictionary *)result;
            NSLog(@"%@", [response description]);
            
            NSArray *results = response[@"results"];
            for (int i=0; i<results.count; i++) {
                PSArticle *article = [PSArticle articleWithInfo:results[i]];
                [self.featuredArticles addObject:article];
            }
            
            
            
            CGRect frame = self.view.frame;
            for (int i=0; i<5; i++) {
                PSArticle *article = self.featuredArticles[i];
                
                CGFloat x = (i %2 ==0) ? -frame.size.width : frame.size.width;
                PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(x, kPadding, frame.size.width-2*kPadding, frame.size.height-160.0f)];
                articleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                articleView.backgroundColor = [UIColor whiteColor];
                articleView.tag = 1000+i;
                articleView.lblTitle.text = article.title;
                articleView.lblDate.text = article.date;
                articleView.lblAuthors.text = [article authorsString];
                
                [self.view addSubview:articleView];
                self.topView = articleView;
                [self.loadingIndicator stopLoading];
                
                [UIView animateWithDuration:1.65f
                                      delay:(i*0.18f)
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
            
            
            
            
        });
        
        
        
     
    }];
    
}


- (void)articleViewStoppedMoving
{
    CGRect frame = self.topView.frame;
    NSLog(@"articleViewStoppedMoving: %.2f, %.2f", frame.origin.x, frame.origin.y);
    
    if (frame.origin.x > kPadding){
        [self likeArticle];
    }
    
    if (frame.origin.x < kPadding){
        [self dislikeArticle];
    }
}

- (void)queueNextArticle
{
    if (self.topView.tag == 1000){
        [self.topView removeFromSuperview];
        self.topView.delegate = nil;
        self.topView = nil;
        return;
    }
    
    int tag = (int)self.topView.tag;
    [self.topView removeFromSuperview];
    self.topView = (PSArticleView *)[self.view viewWithTag:tag-1];
    self.topView.delegate = self;
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
                         [self queueNextArticle];
                     }];
    
}

- (void)likeArticle
{
//    NSLog(@"LIKE Article");
    [UIView animateWithDuration:0.20f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.topView.frame;
                         frame.origin.x = self.view.frame.size.width+30.0f;
                         self.topView.frame = frame;

                     }
                     completion:^(BOOL finished){
                         [self queueNextArticle];
                     }];
}

@end
