//
//  PSWebServices.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <Foundation/Foundation.h>
#import "PSDevice.h"
#define kBaseUrl @"https://pubsavvyswipe.herokuapp.com/"

typedef void (^PSWebServiceRequestCompletionBlock)(id result, NSError *error);


@interface PSWebServices : NSObject



+ (PSWebServices *)sharedInstance;
- (BOOL)checkConnection;

// RANDOM SEARCH TERMS
- (void)fetchRandomTerms:(NSString *)singletonId completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;

// SEARCH
- (void)searchArticles:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;
- (void)searchRelatedArticles:(NSString *)pmid completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;

// DEVICE
- (void)fetchDevice:(NSString *)deviceId completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;
- (void)registerDevice:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;
- (void)updateDevice:(PSDevice *)device completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;
@end
