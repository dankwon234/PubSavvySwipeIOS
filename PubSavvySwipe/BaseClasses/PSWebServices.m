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
#define kPathProfile   @"/api/profile/"
#define kPathDevice    @"/api/device/"
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


#pragma mark - Device
- (void)registerDevice:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];

    [manager POST:kPathDevice
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSLog(@"JSON: %@", responseObject);
              NSDictionary *response = (NSDictionary *)responseObject;
              
              if ([response[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      NSLog(@"REGISTRATION FAILED");
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:response[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(response, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];

    
}

- (void)updateDevice:(PSDevice *)device completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    
    [manager PUT:[kPathDevice stringByAppendingString:device.uniqueId]
      parameters:[device parametersDictionary]
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *response = (NSDictionary *)responseObject;
              
              if ([response[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:response[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(response, nil);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (completionBlock)
                  completionBlock(nil, error);
          }];
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
                 if (completionBlock)
                     completionBlock(responseObject, nil);
                 
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



- (AFHTTPRequestOperationManager *)requestManagerForJSONSerializiation
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
    policy.allowInvalidCertificates = YES;
    manager.securityPolicy = policy;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}




@end
