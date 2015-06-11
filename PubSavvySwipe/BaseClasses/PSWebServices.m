//
//  PSWebServices.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSWebServices.h"
#import "Reachability.h"
#import "AFNetworking.h"
#include <sys/xattr.h>

#define kErrorDomain    @"pubsavvy.com"
#define kPathSearch     @"/api/search/"
#define kPathUpload     @"/api/upload/"
#define kPathImages     @"/site/image/"
#define kPathProfiles   @"/api/profile/"
#define kPathDevices    @"/api/device/"
#define kPathLogin      @"/api/login/"


@implementation PSWebServices


+ (PSWebServices *)sharedInstance
{
    static PSWebServices *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PSWebServices alloc] init];
    });
    
    return shared;
}

- (BOOL)checkConnection;
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}



#pragma mark - Search
- (void)searchArticles:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathSearch
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             NSString *confirmation = responseDictionary[@"confirmation"];
             
             if ([confirmation isEqualToString:@"success"]){
                 NSDictionary *results = responseDictionary[@"results"];
                 if (completionBlock)
                     completionBlock(results, nil);
                 
                 return;
             }
             
             
             if (completionBlock)
                 completionBlock(responseDictionary, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:responseDictionary[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}





@end
