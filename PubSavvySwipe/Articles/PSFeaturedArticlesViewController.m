//
//  PSFeaturedArticlesViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSFeaturedArticlesViewController.h"
#import "PSArticleView.h"


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
    
    for (int i=0; i<5; i++) {
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(kPadding, kPadding, frame.size.width-2*kPadding, frame.size.height-160.0f)];
        articleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        articleView.backgroundColor = [UIColor whiteColor];
        articleView.tag = 1000+i;
        articleView.lblAuthors.text = @"Author 1, Author 2, Author 3, Author 4, Author 5, Author 6, Author 7";
//        articleView.lblTitle.text = @"A Really long ARTICLE TITLE name with a lot of text that no one understands.";
        articleView.lblTitle.text = @"ARTICLE TITLE";
        
        [view addSubview:articleView];
        self.topView = articleView;
    }
    
    self.topView.delegate = self;
    
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
    
    /*
    [[PSWebServices sharedInstance] searchArticles:@{@"term":@"cancer"} completionBlock:^(id result, NSError *error){
        if (error){
            
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSDictionary *pubmedArticleSet = results[@"PubmedArticleSet"];
        NSArray *articles = pubmedArticleSet[@"PubmedArticle"];
        
        for (NSDictionary *article in articles) {
            NSArray *medLineCitation = article[@"MedlineCitation"];
//            NSLog(@"%@", [medLineCitation description]);
            
            NSDictionary *summary = (NSDictionary *)medLineCitation[0];
            NSDictionary *article = summary[@"Article"][0];
//            NSLog(@"%@", [article description]);
            
            // ABSTRACT:
            NSDictionary *abstract = article[@"Abstract"][0];
            NSDictionary *abstractText = abstract[@"AbstractText"][0];
//            NSLog(@"%@", abstractText[@"_"]);
            
            
            // TITLE:
            NSString *title = article[@"ArticleTitle"][0];
//            NSLog(@"%@", title);

            
            // AUTHORS:
            NSDictionary *authorList = article[@"AuthorList"][0];
            NSArray *author = authorList[@"Author"];
            NSMutableArray *authors = [NSMutableArray array];
            for (int i=0; i<author.count; i++) {
                NSDictionary *authorInfo = author[i];
                NSString *authorName = [NSString stringWithFormat:@"%@ %@", authorInfo[@"ForeName"][0], authorInfo[@"LastName"][0]];
                [authors addObject:authorName];
            }
            
            NSLog(@"%@", [authors description]);

            NSLog(@"- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ");
        }
    }];
     */
    
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
