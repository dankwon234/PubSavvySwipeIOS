//
//  PSProfile.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/3/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSProfile.h"
#import "PSWebServices.h"
#import "Config.h"

@implementation PSProfile
@synthesize uniqueId;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize device;
@synthesize password;
@synthesize isPopulated;


- (id)init
{
    self = [super init];
    if (self){
        [self clear];
        
    }
    
    return self;
}

+ (PSProfile *)sharedProfile
{
    static PSProfile *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PSProfile alloc] init];
        if ([shared populateFromCache])
            [shared refreshProfileInfo];
        
    });
    
    return shared;
}

- (void)clear
{
    self.uniqueId = @"";
    self.firstName = @"";
    self.lastName = @"";
    self.email = @"";
    self.device = @"";
    self.password = @"";
    self.isPopulated = NO;
}



- (void)populate:(NSDictionary *)profileInfo
{
    self.uniqueId = profileInfo[@"id"];
    self.firstName = profileInfo[@"firstName"];
    self.lastName = profileInfo[@"lastName"];
    self.email = profileInfo[@"email"];
    self.device = profileInfo[@"device"];
    self.isPopulated = YES;
    [self cacheProfile];
}

- (void)updateProfile
{
    
}

- (void)fetchImage
{
    
}

- (void)refreshProfileInfo
{
    //    NSLog(@"REFRESH PROFILE INFO: %@", self.uniqueId);
    if ([self.uniqueId isEqualToString:@"none"])
        return;
    
    [[PSWebServices sharedInstance] fetchProfileInfo:self completionBlock:^(id result, NSError *error){
        if (error)
            return;
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"REFRESH PROFILE INFO: %@", [results description]);
        if ([results[@"confirmation"] isEqualToString:@"success"] == NO)
            return;
        
        [self populate:results[@"profile"]]; //update profile with most refreshed data
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLoggedInNotification object:nil]];
        
    }];
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId}];

    if (self.device)
        params[@"device"] = self.device;

    if (self.firstName)
        params[@"firstName"] = self.firstName;
    
    if (self.lastName)
        params[@"lastName"] = self.lastName;
    
    if (self.email)
        params[@"email"] = self.email;

    if (self.password)
        params[@"password"] = self.password;

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


- (void)cacheProfile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [self jsonRepresentation];
    [defaults setObject:jsonString forKey:@"user"];
    [defaults synchronize];
}

- (BOOL)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"user"];
    if (!json)
        return NO;
    
    NSError *error = nil;
    NSDictionary *profileInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"STORED PROFILE: %@", [profileInfo description]);
    
    if (error)
        return NO;
    
    [self populate:profileInfo];
    return YES;
}





@end
