//
//  PSRelatedViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/3/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSRelatedViewController.h"


@interface PSRelatedViewController ()
@property (nonatomic) BOOL shouldRefresh;
@end


@implementation PSRelatedViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.colorTheme = kLightGray;
        self.shouldRefresh = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshRelatedArticles:)
                                                     name:kArticleSavedNotification
                                                   object:nil];
        

        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblHeader.text = @"Related";

    if (self.device.saved.count == 0) { // no saved articles
        [self showAlertWithTitle:@"No Saved Articles" message:@"This page shows related articles based on your list of saved articles. To get started, save a few articles first!"];
        return;
    }
    
    [self searchRelatedArticles:self.device.saved];
}

- (void)refreshRelatedArticles:(NSNotification *)note
{
    NSLog(@"refreshRelatedArticles: ");
    self.shouldRefresh = YES;
}

- (void)checkRefresh
{
    if (self.shouldRefresh == NO)
        return;
    
    [self reset];
    [self searchRelatedArticles:self.device.saved];
}

- (void)reset
{
    for (PSArticle *article in self.articles)
        [article removeObserver:self forKeyPath:@"isFree"];
    
    self.articles = [NSMutableArray array];
    self.currentArticle = nil;
    self.offset = 0;
    self.topView.delegate = nil;
    self.topView = nil;
    for (UIView *view in self.view.subviews) {
        if (view.tag < 1000)
            continue;
        
        [view removeFromSuperview];
    }
}



- (void)searchRelatedArticles:(NSArray *)saved
{
    NSMutableString *pmids = [NSMutableString stringWithString:@""];
    int max = (saved.count < 3) ? (int)saved.count : 3;
    for (int i=0; i<max; i++){
        [pmids appendString:saved[i]];
        if (i != max-1)
            [pmids appendString:@","];
    }
    
    NSLog(@"PMIDS: %@", pmids);
    self.currentTerm = pmids;
    [self searchArticles:pmids];
}


- (void)searchArticles:(NSString *)term
{
    if (self.offset % kMaxArticles != 0){
        [self showAlertWithTitle:@"End of Results" message:@"There are no more articles in the current search results."];
        return;
    }

    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchRelatedArticles:term completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        self.shouldRefresh = NO;
        NSDictionary *response = (NSDictionary *)result;
        NSLog(@"%@", [response description]);
        
        
        self.articles = [NSMutableArray array];
        NSArray *results = response[@"results"];
        if (results.count == 0){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"No Articles Found" message:@"There are no related articles."];
            return;
        }
        
        for (int i=0; i<results.count; i++) {
            PSArticle *article = [PSArticle articleWithInfo:results[i]];
            [article addObserver:self forKeyPath:@"isFree" options:0 context:nil];
            [self.articles addObject:article];
            self.offset++;
        }
        
        int max = (self.articles.count >= kSetSize) ? kSetSize : (int)self.articles.count;
        [self animateArticleSet:max];
        [self findCurrentArticle];
    }];
}




@end
