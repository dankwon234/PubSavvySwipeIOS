//
//  PSDevice.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/16/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <Foundation/Foundation.h>

@interface PSDevice : NSObject


@property (copy, nonatomic) NSString *deviceToken;
+ (PSDevice *)sharedProfile;
+ (PSDevice *)deviceWithInfo:(NSDictionary *)info;
@end
