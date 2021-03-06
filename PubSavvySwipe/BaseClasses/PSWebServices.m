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

#define kErrorDomain          @"pubsavvy.com"
#define kPathSearch           @"/api/search/"
#define kPathRelated          @"/api/related/"
#define kPathUpload           @"/api/upload/"
#define kPathImages           @"/site/image/"
#define kPathProfile          @"/api/profile/"
#define kPathDevice           @"/api/device/"
#define kPathArticle          @"/api/article/"
#define kPathLogin            @"/api/login/"
#define kPathRandomTerms      @"/api/autosearch/"
#define kImageUrl             @"https://media-service.appspot.com/"

//https://pubsavvyswipe.herokuapp.com/api/autosearch/5591a7ed6092181100f9fe79

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

#pragma mark - Random Search
- (void)fetchRandomTerms:(NSString *)singletonId completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:[kPathRandomTerms stringByAppendingString:singletonId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *response = (NSDictionary *)responseObject;
             
             if ([response[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(responseObject, nil);
                 
                 return;
             }
             
             
             if (completionBlock)
                 completionBlock(response, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:response[@"message"]}]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}


#pragma mark - Device
- (void)registerDevice:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager POST:kPathDevice
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)fetchDevice:(NSString *)deviceId completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:[kPathDevice stringByAppendingString:deviceId]
      parameters:nil
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

#pragma mark - Profile

- (void)registerProfile:(PSProfile *)profile completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager POST:kPathProfile
       parameters:[profile parametersDictionary]
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

- (void)login:(NSDictionary *)credentials completion:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager POST:kPathLogin
       parameters:credentials
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *results = (NSDictionary *)responseObject;
              
              if ([results[@"confirmation"] isEqualToString:@"success"]==NO){
                  if (completionBlock){
                      completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:results[@"message"]}]);
                  }
                  return;
              }
              
              if (completionBlock)
                  completionBlock(results, nil);
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
              if (completionBlock)
                  completionBlock(nil, error);
          }];
}

- (void)fetchProfileInfo:(PSProfile *)profile completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager GET:[kPathProfile stringByAppendingString:profile.uniqueId]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             
             if ([responseDictionary[@"confirmation"] isEqualToString:@"success"]){ // profile successfully registered
                 if (completionBlock)
                     completionBlock(responseDictionary, nil);
                 return ;
             }
             
             if (completionBlock){
                 NSLog(@"fetchProfileInfo: UPDATE FAILED");
                 completionBlock(responseDictionary, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:responseDictionary[@"message"]}]);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)updateProfile:(PSProfile *)profile completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [self requestManagerForJSONSerializiation];
    [manager PUT:[kPathProfile stringByAppendingString:profile.uniqueId]
      parameters:[profile parametersDictionary]
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

- (void)searchRelatedArticles:(NSString *)pmids completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathRelated
      parameters:@{@"pmid":pmids, @"limit":@"10"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             
             if ([responseDictionary[@"confirmation"] isEqualToString:@"success"]){
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

- (void)fetchArticleLinks:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [manager GET:kPathArticle
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             
             if ([responseDictionary[@"confirmation"] isEqualToString:@"success"]){
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


#pragma mark - IMAGES
- (void)fetchImage:(NSString *)imageId parameters:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    //check cache first:
    NSString *filePath = [self createFilePath:imageId];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data){
        UIImage *image = [UIImage imageWithData:data];
        //        NSLog(@"CACHED IMAGE: %@, %d bytes", imageId, (int)data.length);
        if (!image)
            NSLog(@"CACHED IMAGE IS NIL:");
        
        if (completionBlock)
            completionBlock(image, nil);
        
        return;
    }
    
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kImageUrl]];
    AFImageResponseSerializer *serializer = [[AFImageResponseSerializer alloc] init];
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"image/jpeg", @"image/png"]];
    manager.responseSerializer = serializer;
    
    NSLog(@"FETCH IMAGE: %@", imageId);
    [manager GET:[@"/site/images/" stringByAppendingString:imageId]
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             //Save image to cache directory:
             UIImage *img = (UIImage *)responseObject;
             NSData *imgData = UIImageJPEGRepresentation(img, 1.0f);
             NSLog(@"IMAGE FETCHED: %lu", imgData.length);
             
             [self cacheImage:img toPath:filePath];
             img = [UIImage imageWithData:imgData];
             completionBlock(img, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
             if (completionBlock)
                 completionBlock(nil, error);
         }];
}

- (void)fetchUploadString:(PSWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kImageUrl]];
    
    [manager GET:kPathUpload
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *responseDictionary = (NSDictionary *)responseObject;
             
             if ([responseDictionary[@"confirmation"] isEqualToString:@"success"]){
                 if (completionBlock)
                     completionBlock(responseDictionary, nil);
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

- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(PSWebServiceRequestCompletionBlock)completionBlock
{

    NSData *imageData = image[@"data"];
    NSString *imageName = image[@"name"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:uploadUrl
       parameters:nil
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *responseDictionary = (NSDictionary *)responseObject;
              
              if ([responseDictionary[@"confirmation"] isEqualToString:@"success"]){
                  if (completionBlock)
                      completionBlock(responseDictionary, nil);
                  return;
              }
              
              if (completionBlock)
                  completionBlock(responseDictionary, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:responseDictionary[@"message"]}]);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              completionBlock(nil, error);
              
          }];
    
}


#pragma mark - FileSavingStuff:
- (void)cacheImage:(UIImage *)image toPath:(NSString *)filePath
{
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    [imgData writeToFile:filePath atomically:YES];
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
}



- (NSString *)createFilePath:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}





#pragma mark - MISC
- (void)fetchHtml:(NSString *)address completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock
{
    NSLog(@"FETCH HTML: %@", address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", string);
        if (completionBlock)
            completionBlock(string, nil);

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (completionBlock)
            completionBlock(nil, error);
        
    }];
    
    [op start];
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
