//
//  PSSavedViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSSavedViewController.h"
#import "PSArticleViewController.h"
#import "PSArticleCell.h"
#import "PSWebViewController.h"


@interface PSSavedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *articlesTable;
@property (strong, nonatomic) NSMutableDictionary *articlesMap;
@property (strong, nonatomic) NSMutableArray *saved;
@end

@implementation PSSavedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        // register notification for when user saves articles
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(articleSaved:)
                                                     name:kArticleSavedNotification
                                                   object:nil];

        
        [self setupArticlesSource:^{
            
        }];
    }
    
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor yellowColor];
    CGRect frame = view.frame;
    
    CGFloat padding = 20.0f;
    self.articlesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-padding) style:UITableViewStylePlain];
    self.articlesTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.articlesTable.dataSource = self;
    self.articlesTable.delegate = self;
    self.articlesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 64.0f)];
    header.backgroundColor = [UIColor clearColor];
    
    UILabel *lblRelated = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-2*padding, 28.0f)];
    lblRelated.center = CGPointMake(0.5f*frame.size.width, lblRelated.center.y);
    lblRelated.textColor = [UIColor whiteColor];
    lblRelated.textAlignment = NSTextAlignmentCenter;
    lblRelated.text = @"Saved Articles";
    lblRelated.font = [UIFont fontWithName:kBaseFontName size:18.0f];
    lblRelated.backgroundColor = kDarkBlue;
    lblRelated.layer.cornerRadius = 6.0f;
    lblRelated.layer.masksToBounds = YES;
    [header addSubview:lblRelated];
    self.articlesTable.tableHeaderView = header;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 5.0f)];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(padding, 0, frame.size.width-2*padding, 1.0f)];
    line.backgroundColor = [UIColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:1];
    [footer addSubview:line];
    self.articlesTable.tableFooterView = footer;
    
    
    
    [view addSubview:self.articlesTable];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.articlesTable deselectRowAtIndexPath:[self.articlesTable indexPathForSelectedRow] animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isFree"]==NO)
        return;
    
    [object removeObserver:self forKeyPath:@"isFree"];
    [self.articlesTable reloadData];
    
}

- (void)articleSaved:(NSNotification *)notification
{
    [self setupArticlesSource:^{
        [self.articlesTable reloadData];
    }];
}

- (void)setupArticlesSource:(void (^)(void))completion
{
    
    NSString *filePath = [self createFilePath:kSavedArticlesFileName];
    NSData *articlesData = [NSData dataWithContentsOfFile:filePath];
    
    if (articlesData == nil){
        NSLog(@"CANNOT FIND ARTICLES DATA!");

    }
    else{
        NSError *error = nil;
        NSDictionary *map = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:articlesData
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:&error];
        
        self.articlesMap = [NSMutableDictionary dictionaryWithDictionary:map];
    }
    
    
    self.saved = [NSMutableArray array];
    for (NSString *pmid in self.device.saved) {
        NSDictionary *articleInfo = self.articlesMap[pmid];
        if (articleInfo==nil)
            continue;
        
        PSArticle *article = [PSArticle articleWithInfo:articleInfo];
        [article addObserver:self forKeyPath:@"isFree" options:0 context:nil];
        [self.saved addObject:article];
    }
    
    if (completion)
        completion();
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.saved.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    PSArticleCell *cell = (PSArticleCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[PSArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    PSArticle *article = (PSArticle *)self.saved[indexPath.row];
    cell.lblTitle.text = article.title;
    cell.lblAuthors.text = article.authorsString;
    cell.lblPmid.text = [NSString stringWithFormat:@"PMID: %@", article.pmid];
    cell.lblJournal.text = [NSString stringWithFormat:@"%@ | %@", article.journal[@"iso"], article.date];
    
    NSString *lockImage = (article.isFree) ? @"lockOpen.png" : @"lockClosed.png";
    cell.iconLock.image = [UIImage imageNamed:lockImage];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
        return;
    
    
    PSArticle *article = self.saved[indexPath.row];
    NSLog(@"REMOVE ARTICLE: %@", article.pmid);
    [self.saved removeObject:article];
    [self.articlesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    if ([self.device.saved containsObject:article.pmid]==NO)
        return;
    
    [self.device.saved removeObject:article.pmid];
    [self.device updateDevice];
}

- (NSString *)createFilePath:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSArticle *article = self.saved[indexPath.row];
    
    if (article.isFree){
        PSWebViewController *webVc = [[PSWebViewController alloc] init];
        webVc.url = article.links[@"Url"];
        [self.navigationController pushViewController:webVc animated:YES];
        return;
    }

    PSWebViewController *webVc = [[PSWebViewController alloc] init];
    webVc.url = [NSString stringWithFormat:@"http://dx.doi.org/%@", article.doi];
    [self.navigationController pushViewController:webVc animated:YES];
    
//    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
//    articleVc.article = article;
//    [self.navigationController pushViewController:articleVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [PSArticleCell standardCellHeight];
    
}



@end
