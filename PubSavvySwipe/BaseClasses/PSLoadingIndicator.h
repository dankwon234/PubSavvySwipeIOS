//
//  PSLoadingIndicator.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSLoadingIndicator : UIView

@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UIView *darkScreen;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
- (void)stopLoading;
- (void)startLoading;
@end
