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
@property (strong, nonatomic) NSArray *authors;
@property (strong, nonatomic) NSDictionary *journal;
+ (PSArticle *)articleWithInfo:(NSDictionary *)info;
- (void)populate:(NSDictionary *)articleInfo;
- (NSString *)authorsString;
@end