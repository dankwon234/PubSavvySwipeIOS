//
//  PSViewController.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLoadingIndicator.h"
#import "PSWebServices.h"
#import "Config.h"

@interface PSViewController : UIViewController

@property (strong, nonatomic) PSLoadingIndicator *loadingIndicator;
- (UIView *)baseView;
- (UIView *)baseViewWithNavBar;
- (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)msg;
- (void)shiftUp:(CGFloat)distance;
- (void)shiftBack:(CGFloat)origin;
- (void)addNavigationTitleView;
- (void)addCustomBackButton;
- (void)viewMenu:(id)sender;
- (void)addMenuButton;
@end
