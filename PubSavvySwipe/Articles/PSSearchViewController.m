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
@property (strong, nonatomic) NSMutableArray *searchHistory;
@property (strong, nonatomic) UITableView *searchHistoryTable;
@property (strong, nonatomic) UIView *customKeyboard;

@end

#define kPadding 12.0f


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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
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
    [self.view addSubview:bgSearchBar];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width-72.0f, h)];
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
    [self.view addSubview:self.searchBar];
    
    
    self.searchHistoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, h, frame.size.width, frame.size.height-h-20.0f) style:UITableViewStylePlain];
    self.searchHistoryTable.dataSource = self;
    self.searchHistoryTable.delegate = self;
    self.searchHistoryTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.searchHistoryTable.contentInset = UIEdgeInsetsMake(0, 0, 260.0f, 0);
    self.searchHistoryTable.alpha = 0.0f;
    [self.view addSubview:self.searchHistoryTable];

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
    
    UIColor *darkGray = [UIColor darkGrayColor];
    UIColor *white = [UIColor whiteColor];
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
    
    [self.view addSubview:self.customKeyboard];
    
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
    NSLog(@"searchArticles: %@", searchTerm);
    if (self.offset % kMaxArticles != 0){
        [self showAlertWithTitle:@"End of Results" message:@"There are no more articles in the current search results."];
        return;
    }
    
    if (searchTerm == nil)
        searchTerm = self.searchBar.text;
    
    if (searchTerm.length == 0){
        [self showAlertWithTitle:@"No Term" message:@"Please enter a search term first."];
        return;
    }

    [self.loadingIndicator startLoading];
    NSDictionary *params = @{@"term":searchTerm, @"offset":[NSString stringWithFormat:@"%d", self.offset], @"limit":[NSString stringWithFormat:@"%d", kMaxArticles], @"device":self.device.uniqueId};
    
    [[PSWebServices sharedInstance] searchArticles:params completionBlock:^(id result, NSError *error){
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
            self.offset++;
            [self.articles addObject:article];
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
            int max = (self.articles.count >= kSetSize) ? kSetSize : (int)self.articles.count;
            [self animateArticleSet:max];
            [self findCurrentArticle];
        });
    }];
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


- (void)keyboardAppearNotification:(NSNotification *)note
{
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.customKeyboard.frame;
    frame.origin.y = keyboardFrame.origin.y-frame.size.height-kNavBarHeight;
    self.customKeyboard.frame = frame;
}


- (void)keyboardHideNotification:(NSNotification *)note
{
    CGRect frame = self.customKeyboard.frame;
    frame.origin.y = self.view.frame.size.height;
    self.customKeyboard.frame = frame;
}


- (void)addCustomCharacter:(UIButton *)btn
{
    self.searchBar.text = [self.searchBar.text stringByAppendingString:[NSString stringWithFormat:@"%@", btn.titleLabel.text]];
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
