//
//  PSSavedViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSSavedViewController.h"
#import "PSArticleViewController.h"


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
    
    self.articlesTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-20.0f) style:UITableViewStylePlain];
    self.articlesTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.articlesTable.dataSource = self;
    self.articlesTable.delegate = self;
    [view addSubview:self.articlesTable];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    PSArticle *article = self.saved[indexPath.row];
    
    cell.textLabel.text = article.title;
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
    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
    articleVc.article = article;
    [self.navigationController pushViewController:articleVc animated:YES];
    
}



@end
