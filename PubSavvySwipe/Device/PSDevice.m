//
//  PSDevice.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/16/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSDevice.h"

@implementation PSDevice
@synthesize deviceToken;


- (id)init
{
    self = [super init];
    if (self){
        self.deviceToken = @"none";
    }
    return self;
    
}

+ (PSDevice *)sharedProfile
{
    static PSDevice *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PSDevice alloc] init];
//        if ([shared populateFromCache])
//            [shared refreshProfileInfo];
        
    });
    
    return shared;
}

+ (PSDevice *)deviceWithInfo:(NSDictionary *)info
{
    PSDevice *device = [[PSDevice alloc] init];
//    profile.isPublic = YES;
//    [profile populate:info];
    return device;
}


@end
