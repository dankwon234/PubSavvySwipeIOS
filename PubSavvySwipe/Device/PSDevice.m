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
@synthesize uniqueId;


- (id)init
{
    self = [super init];
    if (self){
        self.uniqueId = @"none";
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
        
    });
    
    return shared;
}

+ (PSDevice *)deviceWithInfo:(NSDictionary *)info
{
    PSDevice *device = [[PSDevice alloc] init];
    [device populate:info];
    return device;
}

- (void)populate:(NSDictionary *)profileInfo
{
    self.uniqueId = profileInfo[@"id"];
    self.deviceToken = profileInfo[@"deviceToken"];
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"deviceToken":self.deviceToken}];
    
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



@end
