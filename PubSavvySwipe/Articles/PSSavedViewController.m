//
//  PSSavedViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSSavedViewController.h"

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
        // TODO: register notification for when user saves articles
        
        NSString *filePath = [self createFilePath:kSavedArticlesFileName];
        NSData *articlesData = [NSData dataWithContentsOfFile:filePath];
        
        if (articlesData != nil){
            NSError *error = nil;
            NSDictionary *map = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:articlesData
                                                                                options:NSJSONReadingMutableContainers
                                                                                  error:&error];
            
            self.articlesMap = [NSMutableDictionary dictionaryWithDictionary:map];
            NSLog(@"SAVED: %@", [self.articlesMap description]);
        }
        
        self.saved = [NSMutableArray array];
        for (NSString *pmid in self.device.saved) {
            NSDictionary *articleInfo = self.articlesMap[pmid];
            if (articleInfo==nil)
                continue;
            
            PSArticle *article = [PSArticle articleWithInfo:articleInfo];
            [self.saved addObject:article];
        }

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

- (NSString *)createFilePath:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}




@end
