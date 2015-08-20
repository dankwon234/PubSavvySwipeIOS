//
//  PSSearchViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSSearchViewController.h"
#import "PSArticleViewController.h"
#import "PSArticle.h"
#import "PSArticleView.h"
#import "PSWebViewController.h"


@interface PSSearchViewController() <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *searchHistory;
@property (strong, nonatomic) UITableView *searchHistoryTable;
@property (strong, nonatomic) PSArticle *currentArticle;
@property (strong, nonatomic) PSArticleView *topView;
@property (nonatomic) CGRect baseFrame;
@property (nonatomic) CGFloat padding;
@property (nonatomic) int index;
@end

#define kPadding 12.0f
#define kSetSize 10


@implementation PSSearchViewController
@synthesize currentArticle = _currentArticle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        [self.numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [self.numberFormatter setGroupingSeparator:@","];

        
        self.currentArticle = nil;
        
        self.searchHistory = [NSMutableArray array];
        for (NSString *searchTerm in self.device.searchHistory.allKeys)
            [self.searchHistory addObject:searchTerm];
        
        [self.searchHistory sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
    }
    
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = kLightBlue;
    CGRect frame = view.frame;
    
    CGFloat h = 44.0f;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, h)];
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    [view addSubview:self.searchBar];
    
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
    
    self.searchHistoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, h, frame.size.width, frame.size.height-h-20.0f) style:UITableViewStylePlain];
    self.searchHistoryTable.dataSource = self;
    self.searchHistoryTable.delegate = self;
    self.searchHistoryTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.searchHistoryTable.contentInset = UIEdgeInsetsMake(0, 0, 250.0f, 0);
    self.searchHistoryTable.alpha = 0.0f;
    
    UIView *cancel = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 64.0f)];
    cancel.backgroundColor = [UIColor redColor];
    self.searchHistoryTable.tableFooterView = cancel;
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(20.0f, 10.0f, frame.size.width-40.0f, 44.0f);
    [btnCancel addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel addSubview:btnCancel];
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];

    
    
    [view addSubview:self.searchHistoryTable];
    

    
    
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
}

- (void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}

- (void)setCurrentArticle:(PSArticle *)currentArticle
{
    _currentArticle = currentArticle;
    if (currentArticle==nil)
        return;
    
    NSLog(@"CURRENT ARTICLE: %@", currentArticle.title);
}

- (void)cancelSearch:(UIButton *)btn
{
    [self dismissKeyboard];
    [self hideSearchTable];
    
    
}

- (void)searchArticles:(NSString *)searchTerm
{
    [self.loadingIndicator startLoading];
    

    NSString *offset = [NSString stringWithFormat:@"%d", self.index];
    
    [[PSWebServices sharedInstance] searchArticles:@{@"term":searchTerm, @"offset":offset, @"limit":@"10", @"device":self.device.uniqueId} completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *response = (NSDictionary *)result;
        NSLog(@"%@", [response description]);
        NSDictionary *deviceInfo = response[@"device"];
        if (deviceInfo)
            [self.device populate:deviceInfo];
        
        NSArray *results = response[@"results"];
        for (int i=0; i<results.count; i++) {
            PSArticle *article = [PSArticle articleWithInfo:results[i]];
            [self.searchResults addObject:article];
        }
        
        NSDictionary *searchQuery = response[@"query"]; // this object contains the number of results, frequency and timestamp
        self.device.searchHistory[searchTerm] = searchQuery;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.searchHistory containsObject:searchTerm]==NO){
                [self.searchHistory addObject:searchTerm];
                [self.searchHistory sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            }

            [self.searchHistoryTable reloadData];
            int max = (self.searchResults.count >= kSetSize) ? kSetSize : (int)self.searchResults.count;
            [self animateFeaturedArticles:max];
            [self findCurrentArticle];
        });
    }];
}



- (void)animateFeaturedArticles:(int)max
{
    CGRect frame = self.view.frame;
    
    for (int i=0; i<self.searchResults.count; i++) {
        int idx = (int)self.searchResults.count-i-1; // adjust index to show articles in correct sequence
        
        PSArticle *article = self.searchResults[idx];
        
        int index = i % max;
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
    NSLog(@"Find Current Article: %d", (int)self.searchResults.count);
    if (self.searchResults.count == 0)
        return;
    
    if (self.currentArticle){
        [self.searchResults removeObject:self.currentArticle];
        self.currentArticle = nil;
    }
    
    if (self.searchResults.count == 0){
        NSLog(@"NO MORE ARTICLES!");
        [self searchArticles:self.searchBar.text];
        return;
    }
    
    self.currentArticle = self.searchResults[0];
    self.index++;
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
                         if (self.searchResults.count > 0){
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
                         if (self.searchResults.count > 0){
                             [self queueNextArticle];
                         }
                         
                     }];
}


- (void)reset
{
    self.searchResults = [NSMutableArray array];
    self.currentArticle = nil;
    self.index = 0;
    self.topView.delegate = nil;
    self.topView = nil;
    for (UIView *view in self.view.subviews) {
        if (view.tag < 1000)
            continue;
        
        [view removeFromSuperview];
    }
}


#pragma mark - PSArticleViewDelegate

- (void)articleViewTapped:(NSInteger)tag
{
    NSLog(@"articleViewTapped: %@", self.currentArticle.title);
    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
    articleVc.article = self.currentArticle;
    [self.navigationController pushViewController:articleVc animated:YES];
}


- (void)articleViewStoppedMoving
{
    CGRect frame = self.topView.frame;
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
                         frame.origin.y = kPadding+self.searchBar.frame.size.height;
                         self.topView.frame = frame;
                         
                     }
                     completion:NULL];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
    }
    
    NSString *searchTerm = self.searchHistory[indexPath.row];
    NSDictionary *searchQuery = self.device.searchHistory[searchTerm];
    cell.textLabel.text = searchTerm;
    NSNumber *count = [NSNumber numberWithInteger:[searchQuery[@"count"] intValue]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ results", [self.numberFormatter stringFromNumber:count]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [self reset];

    NSString *searchTerm = self.searchHistory[indexPath.row];
    self.searchBar.text = searchTerm;
    [self searchArticles:searchTerm];
}


#pragma mark - SearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldBeginEditing: %@", [self.device.searchHistory description]);
    [self.view bringSubviewToFront:self.searchHistoryTable];
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.searchHistoryTable.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    return YES;
}

- (void)hideSearchTable
{
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.searchHistoryTable.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self hideSearchTable];

    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self reset];
    [self searchArticles:searchBar.text];
}







@end
