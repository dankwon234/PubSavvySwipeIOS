//
//  PSSearchViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSSearchViewController.h"
#import "PSArticleViewController.h"
#import "PSArticle.h"
#import "PSArticleCell.h"

@interface PSSearchViewController() <UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) UITableView *articlesTable;
@end

@implementation PSSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.searchResults = [NSMutableArray array];
        
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
    
    self.articlesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, h, frame.size.width, frame.size.height-h-20.0f) style:UITableViewStylePlain];
    self.articlesTable.dataSource = self;
    self.articlesTable.delegate = self;
    self.articlesTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.articlesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [view addSubview:self.articlesTable];
    
    
    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.articlesTable deselectRowAtIndexPath:[self.articlesTable indexPathForSelectedRow] animated:YES];
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


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PSArticleCell *cell = (PSArticleCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[PSArticleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    PSArticle *article = self.searchResults[indexPath.row];
    cell.lblTitle.text = article.title;
    cell.lblAuthors.text = article.authorsString;
    cell.lblDetail.text = @"details";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView didSelectRowAtIndexPath:");
    
    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
    articleVc.article = self.searchResults[indexPath.row];
    [self.navigationController pushViewController:articleVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSArticle *article = self.searchResults[indexPath.row];
    CGRect boundingRect = [article.title boundingRectWithSize:CGSizeMake(tableView.frame.size.width, 350.0f)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:[PSArticleCell titleFont]}
                                                      context:nil];

    
    return [PSArticleCell standardCellHeight]+boundingRect.size.height+46.0f;
}


#pragma mark - SearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldBeginEditing:");
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    [searchBar resignFirstResponder];
    
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] searchArticles:@{@"term":searchBar.text, @"limit":@"50", @"device":self.device.uniqueId} completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *response = (NSDictionary *)result;
        NSArray *results = response[@"results"];
        for (int i=0; i<results.count; i++) {
            PSArticle *article = [PSArticle articleWithInfo:results[i]];
            [self.searchResults addObject:article];
        }
        
        [self.device populate:response[@"device"]];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.articlesTable reloadData];
        });
        
        
        
    }];
    
}

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;                     // called when text starts editing
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes
//


@end
