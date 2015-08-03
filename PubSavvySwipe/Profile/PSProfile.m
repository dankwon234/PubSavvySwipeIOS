//
//  PSProfile.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/3/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSProfile.h"

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
        self.uniqueId = @"";
        self.firstName = @"";
        self.lastName = @"";
        self.email = @"";
        self.device = @"";
        self.password = @"";
        self.isPopulated = NO;
        
    }
    
    return self;
}

+ (PSProfile *)sharedProfile
{
    static PSProfile *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PSProfile alloc] init];
        
    });
    
    return shared;
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
