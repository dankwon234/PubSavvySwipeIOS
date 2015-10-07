//
//  PSWebViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/8/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSWebViewController.h"

@interface PSWebViewController ()
@property (strong, nonatomic) UIWebView *articleWebview;
@end

@implementation PSWebViewController
@synthesize url;


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
    view.backgroundColor = kLightBlue;
    CGRect frame = view.frame;
    
    self.articleWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f)];
    self.articleWebview.delegate = self;
    self.articleWebview.scalesPageToFit = YES;
    self.articleWebview.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    [view addSubview:self.articleWebview];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    [self.loadingIndicator startLoading];
//    NSString *url = [NSString stringWithFormat:@"http://www.ncbi.nlm.nih.gov/m/pubmed/%@/", self.article.pmid];
    [self.articleWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

#pragma mark - UIWebviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView shouldStartLoadWithRequest: %@", request.URL.absoluteString);
    [self.loadingIndicator startLoading];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingIndicator stopLoading];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError:");
    [self.loadingIndicator stopLoading];
}



@end
