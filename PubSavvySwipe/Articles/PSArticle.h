//
//  PSArticle.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/19/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSArticle : NSObject


@property (copy, nonatomic) NSString *pmid;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *abstract;
@property (copy, nonatomic) NSString *language;
@property (copy, nonatomic) NSString *authorsString;
@property (strong, nonatomic) NSArray *keywords;
@property (strong, nonatomic) NSArray *authors;
@property (strong, nonatomic) NSDictionary *journal;
@property (strong, nonatomic) NSMutableArray *related;
@property (strong, nonatomic) NSDictionary *links;
@property (nonatomic) BOOL isFree;
+ (PSArticle *)articleWithInfo:(NSDictionary *)info;
- (void)populate:(NSDictionary *)articleInfo;
- (NSDictionary *)parametersDictionary;
- (void)fetchArticleLinks;
@end
