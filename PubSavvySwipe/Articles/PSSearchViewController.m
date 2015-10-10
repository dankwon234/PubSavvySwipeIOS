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
#import "PCSearchTermCell.h"


@interface PSSearchViewController() <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *searchHistory;
@property (strong, nonatomic) UITableView *searchHistoryTable;
@property (strong, nonatomic) PSArticle *currentArticle;
@property (strong, nonatomic) PSArticleView *topView;
@property (strong, nonatomic) UIView *customKeyboard;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardAppearNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHideNotification:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    
    return self;
}



- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;
    
    self.padding = 0.5f*(frame.size.width-[PSArticleView standardWidth]);

    CGFloat h = 44.0f;
    UIView *bgSearchBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, h)];
    double rgb = 0.78f;
    bgSearchBar.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:204.0f/255.0f alpha:1.0f];
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(frame.size.width-80.0f, 0.0f, 80.0f, h);
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont fontWithName:kBaseFontName size:14.0f];
    [btnCancel addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    [bgSearchBar addSubview:btnCancel];
    [view addSubview:bgSearchBar];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width-72.0f, h)];
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    [view addSubview:self.searchBar];
    

    UIImageView *bgCards = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgCardsGray.png"]];
    bgCards.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    bgCards.center = CGPointMake(0.5f*frame.size.width, 0.49f*frame.size.height);
    [view addSubview:bgCards];

    CGFloat w = 0.5f*(frame.size.width-3*self.padding);
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
    
    self.searchHistoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, h, frame.size.width, frame.size.height-h-20.0f) style:UITableViewStylePlain];
    self.searchHistoryTable.dataSource = self;
    self.searchHistoryTable.delegate = self;
    self.searchHistoryTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.searchHistoryTable.contentInset = UIEdgeInsetsMake(0, 0, 260.0f, 0);
    self.searchHistoryTable.alpha = 0.0f;
    [view addSubview:self.searchHistoryTable];

    h = 44.0f;
    self.customKeyboard = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, h)];
    self.customKeyboard.backgroundColor = bgSearchBar.backgroundColor;
    self.customKeyboard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    NSArray *customCharacters = @[@" [", @"]", @" (", @")", @" AND ", @" OR ", @" NOT "];
    CGFloat x = 6.0f;
    CGFloat height = h-2*x;
    CGFloat width = (frame.size.width-8*x) / customCharacters.count;
    UIColor *gray = [UIColor grayColor];
    UIFont *font = [UIFont fontWithName:kBaseFontName size:14.0f];
    
    for (int i=0; i<customCharacters.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 3.0f;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 0.5f;
        btn.layer.borderColor = [gray CGColor];
        btn.backgroundColor = white;
        btn.titleLabel.font = font;
        [btn setTitleColor:darkGray forState:UIControlStateNormal];
        [btn setTitle:customCharacters[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(x, 6.0f, width, height);
        [btn addTarget:self action:@selector(addCustomCharacter:) forControlEvents:UIControlEventTouchUpInside];
        [self.customKeyboard addSubview:btn];
        x += width+6.0f;
    }
    
    [view addSubview:self.customKeyboard];
    
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
    
    CGPoint ctr = self.loadingIndicator.center;
    ctr.y = 0.65f*self.view.frame.size.height;
    self.loadingIndicator.center = ctr;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isFree"] == NO)
        return;
    
    PSArticle *article = (PSArticle *)object;
    if (article.isFree == NO)
        return;
    
    NSUInteger index = [self.searchResults indexOfObject:article];
    index = self.searchResults.count-index-1;
    
    PSArticleView *articleView = (PSArticleView *)[self.view viewWithTag:1000+index];
    if (articleView == nil)
        return;
    
    [articleView.iconLock setImage:[UIImage imageNamed:@"lockOpen.png"] forState:UIControlStateNormal];
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
    if (self.index % kMaxArticles != 0){
        [self showAlertWithTitle:@"End of Results" message:@"There are no more articles in the current search results."];
        return;
    }

    NSString *offset = [NSString stringWithFormat:@"%d", self.index];
//    NSLog(@"OFFSET: %@", offset);

    
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchArticles:@{@"term":searchTerm, @"offset":offset, @"limit":[NSString stringWithFormat:@"%d", kMaxArticles], @"device":self.device.uniqueId} completionBlock:^(id result, NSError *error){
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
        if (results.count == 0){
            [self showAlertWithTitle:@"End of Results" message:@"There are no more search resutls."];
            return;
        }
        
        for (int i=0; i<results.count; i++) {
            PSArticle *article = [PSArticle articleWithInfo:results[i]];
            [article addObserver:self forKeyPath:@"isFree" options:0 context:nil];
            [self.searchResults addObject:article];
        }
        
        NSDictionary *searchQuery = response[@"query"]; // this object contains the number of results, frequency and timestamp
        if (searchQuery)
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
        
        int index = i%max;
        PSArticleView *articleView = [PSArticleView articleViewWithFrame:CGRectMake(0, self.padding+kNavBarHeight-26.0f, [PSArticleView standardWidth], frame.size.height-180.0f)];
        articleView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin);
        
        articleView.tag = 1000+index;
        articleView.backgroundColor = kLightGray;
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
        
        if (i == self.searchResults.count-1){
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
    NSLog(@"Find Current Article: %d", (int)self.searchResults.count);
    if (self.searchResults.count == 0)
        return;
    
    if (self.currentArticle){
        [self.currentArticle removeObserver:self forKeyPath:@"isFree"];
        [self.searchResults removeObject:self.currentArticle];
        self.currentArticle = nil;
    }
    
    if (self.searchResults.count == 0){
        [self searchArticles:self.searchBar.text];
        [self.loadingIndicator stopLoading];
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
                        if (self.searchResults.count > 0){
                            [self queueNextArticle];
                        }
                        
                    }];
}

- (void)dislikeArticle
{
    [self dislikeArticle:YES];
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
                        if (self.searchResults.count > 0){
                            [self queueNextArticle];
                        }
                    }];
}

- (void)likeArticle
{
    [self likeArticle:YES];
}

- (void)reset
{
    for (PSArticle *article in self.searchResults)
        [article removeObserver:self forKeyPath:@"isFree"];
        
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


- (void)keyboardAppearNotification:(NSNotification *)note
{
//    NSLog(@"keyboardNotification: %@", [note.userInfo description]);
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = self.customKeyboard.frame;
    frame.origin.y = keyboardFrame.origin.y-frame.size.height-kNavBarHeight;
    self.customKeyboard.frame = frame;
}


- (void)keyboardHideNotification:(NSNotification *)note
{
//    NSLog(@"keyboardNotification: %@", [note.userInfo description]);
    CGRect frame = self.customKeyboard.frame;
    frame.origin.y = self.view.frame.size.height;
    self.customKeyboard.frame = frame;
}


- (void)addCustomCharacter:(UIButton *)btn
{
    self.searchBar.text = [self.searchBar.text stringByAppendingString:[NSString stringWithFormat:@"%@", btn.titleLabel.text]];
}

#pragma mark - PSArticleViewDelegate

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

//    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
//    articleVc.article = self.currentArticle;
//    [self.navigationController pushViewController:articleVc animated:YES];
    
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
        
        if (url != nil){
            NSArray *p = [url componentsSeparatedByString:@".pdf"];
            url = p[0];
            
            NSString *http = @"http";
            p = [url componentsSeparatedByString:http];
            url = p[p.count-1];
            url = [http stringByAppendingString:[NSString stringWithFormat:@"%@.pdf", url]];
            NSLog(@"PDF: %@", url);
        }
        
        if (url == nil)
            url = self.currentArticle.links[@"Url"];
        
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PCSearchTermCell *cell = (PCSearchTermCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[PCSearchTermCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        
    }
    
    NSString *searchTerm = self.searchHistory[indexPath.row];
    NSDictionary *searchQuery = self.device.searchHistory[searchTerm];
    cell.lblTerm.text = searchTerm;
    
    NSNumber *count = [NSNumber numberWithInteger:[searchQuery[@"count"] intValue]];
    cell.lblFrequency.text = [NSString stringWithFormat:@"%@ hits", [self.numberFormatter stringFromNumber:count]];
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
    [self.view bringSubviewToFront:self.customKeyboard];
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
