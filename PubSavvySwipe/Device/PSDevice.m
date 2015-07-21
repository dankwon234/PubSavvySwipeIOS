//
//  PSDevice.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/16/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSDevice.h"
#import "PSWebServices.h"
#import "Config.h"

@implementation PSDevice
@synthesize deviceToken;
@synthesize uniqueId;
@synthesize saved;


- (id)init
{
    self = [super init];
    if (self){
        self.uniqueId = @"none";
        self.deviceToken = @"none";
        self.saved = [NSMutableArray array];
        self.searchHistory = [NSMutableDictionary dictionary];
        if ([self populateFromCache])
            [self refreshDevice];
        
        else // not stored, register new device on backend
            [self registerDevice];
    }
    
    return self;
    
}

+ (PSDevice *)sharedDevice
{
    static PSDevice *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PSDevice alloc] init];
        
    });
    
    return shared;
}

+ (PSDevice *)deviceWithInfo:(NSDictionary *)info
{
    PSDevice *device = [[PSDevice alloc] init];
    [device populate:info];
    return device;
}

- (void)saveArticle:(PSArticle *)article
{
    if ([self.saved containsObject:article.pmid])
        return;
    
    [self.saved addObject:article.pmid];
    [self updateDevice];
    
    NSString *filePath = [self createFilePath:kSavedArticlesFileName];
    NSData *articlesData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *articlesMap = nil;
    
    if (articlesData==nil){
        articlesMap = [NSMutableDictionary dictionaryWithDictionary:@{article.pmid:[article parametersDictionary]}];
    }
    else {
        NSError *error = nil;
        NSDictionary *map = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:articlesData options:NSJSONReadingMutableContainers error:&error];
        
        articlesMap = [NSMutableDictionary dictionaryWithDictionary:map];
        articlesMap[article.pmid] = [article parametersDictionary];
    }
    
    NSLog(@"SAVED: %@", [articlesMap description]);
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:articlesMap options:NSJSONWritingPrettyPrinted error:&error];
    [jsonData writeToFile:filePath atomically:YES];
    
}


- (void)refreshDevice
{
    if ([self.uniqueId isEqualToString:@"none"])
        return;
    
    [[PSWebServices sharedInstance] fetchDevice:self.uniqueId completionBlock:^(id result, NSError *error){
        if (error){
            return;
        }
        
        NSLog(@"%@", [result description]);
        NSDictionary *device = result[@"device"];
        [self populate:device];
    }];
}



- (void)updateDevice
{
    if ([self.uniqueId isEqualToString:@"none"])
        return;
 
    [[PSWebServices sharedInstance] updateDevice:self completionBlock:^(id result, NSError *error){
        if (error){
            return;
        }
        
        NSLog(@"%@", [result description]);
        NSDictionary *device = result[@"device"];
        [self populate:device];
    }];
}

- (void)registerDevice
{
    NSLog(@"REGISTER DEVICE!");
    [[PSWebServices sharedInstance] registerDevice:[self parametersDictionary] completionBlock:^(id result, NSError *error) {
        if (error)
            return;
        
        NSLog(@"%@", [result description]);
        NSDictionary *device = result[@"device"];
        [self populate:device];
        
    }];
}

- (void)cacheDevice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [self jsonRepresentation];
    [defaults setObject:jsonString forKey:@"device"];
    [defaults synchronize];
}


- (BOOL)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"device"];
    if (!json)
        return NO;
    
    NSError *error = nil;
    NSDictionary *profileInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"STORED DEVICE: %@", [profileInfo description]);
    
    if (error)
        return NO;
    
    [self populate:profileInfo];
    return YES;
}




- (void)populate:(NSDictionary *)profileInfo
{
    self.uniqueId = profileInfo[@"id"];
    self.deviceToken = profileInfo[@"deviceToken"];
    self.searchHistory = profileInfo[@"searchHistory"];
    
    if (profileInfo[@"saved"] != nil)
        self.saved = [NSMutableArray arrayWithArray:profileInfo[@"saved"]];
    
    [self cacheDevice];
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"deviceToken":self.deviceToken}];
    
    if (self.saved)
        params[@"saved"] = self.saved;

    if (self.searchHistory)
        params[@"searchHistory"] = self.searchHistory;

    return params;
}

- (NSString *)jsonRepresentation
{
    NSDictionary *info = [self parametersDictionary];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        return nil;
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (NSString *)createFilePath:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}



@end
