//
//  PSWebServices.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <Foundation/Foundation.h>
#define kBaseUrl @"https://pubsavvyswipe.herokuapp.com/"

typedef void (^PSWebServiceRequestCompletionBlock)(id result, NSError *error);


@interface PSWebServices : NSObject



+ (PSWebServices *)sharedInstance;
- (BOOL)checkConnection;

// SEARCH
- (void)searchArticles:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;

// DEVICE
- (void)registerDevice:(NSDictionary *)params completionBlock:(PSWebServiceRequestCompletionBlock)completionBlock;

@end
