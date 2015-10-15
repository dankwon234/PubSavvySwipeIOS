//
//  PSProfile.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/3/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <Foundation/Foundation.h>

@interface PSProfile : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *device;
@property (nonatomic)BOOL isPopulated;
+ (PSProfile *)sharedProfile;
- (void)populate:(NSDictionary *)profileInfo;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)updateProfile;
- (void)fetchImage;
- (void)cacheProfile;
- (void)clear;
@end
