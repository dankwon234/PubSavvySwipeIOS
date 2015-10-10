//
//  PSArticlesViewController.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 10/10/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSViewController.h"
#import "PSArticleView.h"


@interface PSArticlesViewController : PSViewController

@property (copy, nonatomic) NSString *currentTerm;
@property (strong, nonatomic) NSMutableArray *randomTerms;
@property (strong, nonatomic) NSMutableArray *articles;
@property (strong, nonatomic) PSArticle *currentArticle;
@property (strong, nonatomic) PSArticleView *topView;
@property (strong, nonatomic) UILabel *lblHeader;
@property (strong, nonatomic) UIColor *colorTheme;
@property (nonatomic) CGRect baseFrame;
@property (nonatomic) CGFloat padding;
- (void)searchArticles:(NSString *)term;
- (void)animateArticleSet:(int)max;
- (void)findCurrentArticle;

@end
