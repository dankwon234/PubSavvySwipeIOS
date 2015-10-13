//
//  PSFeaturedArticlesViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSFeaturedArticlesViewController.h"


@interface PSFeaturedArticlesViewController ()

@end


@implementation PSFeaturedArticlesViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.colorTheme = kLightBlue;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lblHeader.text = @"Random";
    
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
        
        int i = arc4random() % self.randomTerms.count;
        self.currentTerm = self.randomTerms[i];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchArticles:self.currentTerm];
        });
        
    }];
}

// this HAS to be overriden by subclass:
- (void)searchArticles:(NSString *)term
{
    if (self.offset % kMaxArticles != 0){
        [self showAlertWithTitle:@"End of Results" message:@"There are no more articles in the current search results."];
        return;
    }

    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchArticles:@{@"term":term, @"limit":[NSString stringWithFormat:@"%d", kMaxArticles], @"offset":[NSString stringWithFormat:@"%d", self.offset]} completionBlock:^(id result, NSError *error){
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *response = (NSDictionary *)result;
            NSLog(@"searchArticles: %@", [response description]);
            NSArray *results = response[@"results"];
            if (results.count == 0){ // no more results, move on to next search term
                [self.randomTerms removeObject:self.currentTerm];
                
                int i = arc4random() % self.randomTerms.count;
                self.currentTerm = self.randomTerms[i];
                [self searchArticles:self.currentTerm];
                return;
            }

            self.articles = [NSMutableArray array];
            for (int i=0; i<results.count; i++) {
                PSArticle *article = [PSArticle articleWithInfo:results[i]];
                [article addObserver:self forKeyPath:@"isFree" options:0 context:nil];
                [self.articles addObject:article];
                self.offset++;
            }
            
            int max = (self.articles.count >= kSetSize) ? kSetSize : (int)self.articles.count;
            [self animateArticleSet:max];
            [self findCurrentArticle];
        });
    }];
}



@end
