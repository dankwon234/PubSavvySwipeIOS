//
//  PSWebViewController.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/8/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSViewController.h"

@interface PSWebViewController : PSViewController <UIWebViewDelegate, UIActionSheetDelegate>


@property (copy, nonatomic) NSString *url;
@end
