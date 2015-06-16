//
//  PSDevice.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/16/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <Foundation/Foundation.h>

@interface PSDevice : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *deviceToken;
+ (PSDevice *)sharedDevice;
+ (PSDevice *)deviceWithInfo:(NSDictionary *)info;
- (void)populate:(NSDictionary *)profileInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)updateDevice;
- (void)registerDevice;
@end
