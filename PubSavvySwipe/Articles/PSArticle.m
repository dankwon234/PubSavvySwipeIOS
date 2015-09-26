//
//  PSArticle.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/19/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSArticle.h"
#import "PSWebServices.h"

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
@synthesize links;
@synthesize doi;
@synthesize isFree;


- (id)init
{
    self = [super init];
    if (self){
        self.isFree = NO;
        self.keys = @[@"pmid", @"title", @"abstract", @"language", @"journal", @"authors", @"date", @"keywords", @"doi"];
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

        if (author[@"lastName"] != nil)
            fullName = author[@"lastName"];

        if (author[@"firstName"] != nil){
            NSString *firstName = author[@"firstName"];
            NSString *initials = [firstName substringToIndex:1]; // first and middle initial
            NSArray *parts = [firstName componentsSeparatedByString:@" "];
            if (parts.count > 1)
                initials = [initials stringByAppendingString:[NSString stringWithFormat:@" %@", [parts[1] substringToIndex:1]]];
            
            fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", initials]];
        }
        
        

        self.authorsString = [self.authorsString stringByAppendingString:fullName];
        if (i != self.authors.count-1)
            self.authorsString = [self.authorsString stringByAppendingString:@", "];
    }
    
    [self fetchArticleLinks];
}

- (void)fetchArticleLinks
{
    [[PSWebServices sharedInstance] fetchArticleLinks:@{@"meta":@"links", @"pmid":self.pmid} completionBlock:^(id result, NSError *error){
        if (error){
            return;
        }
        
        NSDictionary *results = result;
//        NSLog(@"FETCH ARTICLE LINKS: %@", [results description]);
        self.links = results[@"links"];
        
        if (self.links[@"Attribute"] == nil)
            return;
        
        self.isFree = ([self.links[@"Attribute"] isEqualToString:@"free resource"]);
        if (self.isFree)
            NSLog(@"FREE ARTICLE: %@", self.title);
    }];
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
    
    if (self.doi)
        params[@"doi"] = self.doi;

    if (self.links)
        params[@"links"] = self.links;

    
    return params;
}





@end
