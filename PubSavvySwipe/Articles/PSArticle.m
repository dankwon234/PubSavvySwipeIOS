//
//  PSArticle.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/19/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticle.h"

@interface PSArticle ()
@property (strong, nonatomic) NSArray *keys;
@end

@implementation PSArticle
@synthesize pmid;
@synthesize title;
@synthesize abstract;
@synthesize language;
@synthesize authors;
@synthesize journal;
@synthesize date;
@synthesize keywords;
@synthesize authorsString;
@synthesize related;

- (id)init
{
    self = [super init];
    if (self){
        self.keys = @[@"pmid", @"title", @"abstract", @"language", @"journal", @"authors", @"date", @"keywords"];
        self.related = [NSMutableArray array];
    }
    
    return self;
}

+ (PSArticle *)articleWithInfo:(NSDictionary *)info
{
    PSArticle *article = [[PSArticle alloc] init];
    [article populate:info];
    return article;
}

- (void)populate:(NSDictionary *)articleInfo
{
    for (NSString *key in articleInfo.allKeys){
        if ([self.keys containsObject:key]==NO)
            continue;
        
        [self setValue:articleInfo[key] forKeyPath:key];
    }
    
    if (self.authors.count == 0)
        return;
    
    self.authorsString = @"";
    for (int i=0; i<self.authors.count; i++) {
        NSString *fullName = @"";
        NSDictionary *author = self.authors[i];
        if (author[@"firstName"]!=nil)
            fullName = author[@"firstName"];
        
        if (author[@"lastName"] != nil)
            fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", author[@"lastName"]]];
        
        self.authorsString = [self.authorsString stringByAppendingString:fullName];
        if (i != self.authors.count-1)
            self.authorsString = [self.authorsString stringByAppendingString:@", "];
    }
    
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"pmid":self.pmid, @"title":self.title}];
    
    if (self.date)
        params[@"date"] = self.date;
    
    if (self.abstract)
        params[@"abstract"] = self.abstract;

    if (self.language)
        params[@"language"] = self.language;
    
    if (self.authors)
        params[@"authors"] = self.authors;

    if (self.keywords)
        params[@"keywords"] = self.keywords;

    if (self.journal)
        params[@"journal"] = self.journal;
    
    return params;
}





@end
