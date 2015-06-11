//
//  SignalCheck.h
//  FileStream
//
//  Created by Denny Kwon on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface SignalCheck : NSObject {
//	Reachability *hostReach, *internetReach, *wifiReach;
}

@property (assign) id delegate;
@property (strong, nonatomic) Reachability *hostReach;
@property (strong, nonatomic) Reachability *internetReach;
@property (strong, nonatomic) Reachability *wifiReach;

+ (SignalCheck *)signalWithDelegate:(id)del;
- (id)initWithDelegate:(id)del;
- (BOOL)checkSignal;
- (void)lostConnection;
- (void)reachabilityChanged:(NSNotification *)note;
- (void)statusChanged:(Reachability *)reach;
@end
