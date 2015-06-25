//
//  PSDevice.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 6/16/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSDevice.h"
#import "PSWebServices.h"

@implementation PSDevice
@synthesize deviceToken;
@synthesize uniqueId;


- (id)init
{
    self = [super init];
    if (self){
        self.uniqueId = @"none";
        self.deviceToken = @"none";
        if ([self populateFromCache]==NO) // not stored, register new device on backend
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
    [[PSWebServices sharedInstance] registerDevice:@{@"deviceToken":self.deviceToken} completionBlock:^(id result, NSError *error) {
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
    [self cacheDevice];
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
