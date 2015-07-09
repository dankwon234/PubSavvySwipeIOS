//
//  PSArticleViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticleViewController.h"

@interface PSArticleViewController() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIScrollView *container;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblAuthors;
@property (strong, nonatomic) UILabel *lblDetails;
@property (strong, nonatomic) UILabel *lblAbstract;
@property (strong, nonatomic) UITableView *relatedTable;
@end

@implementation PSArticleViewController
@synthesize article;


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
    view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    CGRect frame = view.frame;
    
    self.container = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    self.container.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.container.showsVerticalScrollIndicator = NO;
    
    CGFloat padding = 12.0f;
    CGFloat width = frame.size.width-2*padding;
    
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    CGRect bounds = [self.article.title boundingRectWithSize:CGSizeMake(width, 250.0f)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
    
    CGFloat y = padding;
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, width, bounds.size.height)];
    self.lblTitle.text = self.article.title;
    self.lblTitle.font = font;
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.numberOfLines = 0;
    self.lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [self.container addSubview:self.lblTitle];
    y += self.lblTitle.frame.size.height+12.0f;
    
    font = [UIFont fontWithName:@"Arial" size:14.0f];
    self.lblDetails = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 24.0f)];
    self.lblDetails.text = [NSString stringWithFormat:@"%@ | %@", self.article.journal[@"iso"], self.article.date];
    self.lblDetails.font = font;
    [self.container addSubview:self.lblDetails];
    y += self.lblDetails.frame.size.height+6.0f;
    

    bounds = [self.article.authorsString boundingRectWithSize:CGSizeMake(width, 300.0f)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:font}
                                                      context:nil];

    self.lblAuthors = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, bounds.size.height)];
    self.lblAuthors.text = self.article.authorsString;
    self.lblAuthors.font = font;
    self.lblAuthors.numberOfLines = 0;
    self.lblAuthors.lineBreakMode = NSLineBreakByWordWrapping;
    [self.container addSubview:self.lblAuthors];
    y += self.lblAuthors.frame.size.height+6.0f;
    

    bounds = [self.article.abstract boundingRectWithSize:CGSizeMake(width, 2*frame.size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:font}
                                                 context:nil];

    
    self.lblAbstract = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, bounds.size.height)];
    self.lblAbstract.numberOfLines = 0;
    self.lblAbstract.font = font;
    self.lblAbstract.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblAbstract.text = self.article.abstract;
    [self.container addSubview:self.lblAbstract];
    y += self.lblAbstract.frame.size.height+2*padding;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(padding, y, width, 1.0f)];
    line.backgroundColor = [UIColor grayColor];
    [self.container addSubview:line];
    y += line.frame.size.height+2*padding;
    
    UILabel *lblRelated = [[UILabel alloc] initWithFrame:CGRectMake(padding, y, width, 22.0f)];
    lblRelated.font = [UIFont boldSystemFontOfSize:16.0f];
    lblRelated.textAlignment = NSTextAlignmentCenter;
    lblRelated.text = @"Related";
    [self.container addSubview:lblRelated];
    y += lblRelated.frame.size.height;
    
    self.relatedTable = [[UITableView alloc] initWithFrame:CGRectMake(padding, y, width, 250.0f) style:UITableViewStyleGrouped];
    self.relatedTable.delegate = self;
    self.relatedTable.dataSource = self;
    self.relatedTable.backgroundColor = [UIColor clearColor];
    self.relatedTable.scrollEnabled = NO;
    self.relatedTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.container addSubview:self.relatedTable];
    y += self.relatedTable.frame.size.height;
    
    self.container.contentSize = CGSizeMake(0, y+4*padding);
    
    [view addSubview:self.container];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
    
    if (self.article.related.count > 0)
        return;
    
    [[PSWebServices sharedInstance] searchRelatedArticles:self.article.pmid completionBlock:^(id result, NSError *error){
        if (error){
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        
        NSArray *list = results[@"results"];
        for (int i=0; i<list.count; i++) {
            if (i==0) // ignore first one, it's the same as the source article
                continue;
            
            PSArticle *relatedArticle = [PSArticle articleWithInfo:list[i]];
            [self.article.related addObject:relatedArticle];
            if (self.article.related.count==5)
                break;
        }
        
        [self.relatedTable reloadData];
        
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.article.related.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    PSArticle *relatedArticle = self.article.related[indexPath.row];
    cell.textLabel.text = relatedArticle.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSArticle *relatedArticle = self.article.related[indexPath.row];
    PSArticleViewController *articleVc = [[PSArticleViewController alloc] init];
    articleVc.article = relatedArticle;
    [self.navigationController pushViewController:articleVc animated:YES];
    
}



@end
