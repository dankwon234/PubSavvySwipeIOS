//
//  PSViewController.h
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import <UIKit/UIKit.h>
#import "PSLoadingIndicator.h"
#import "PSWebServices.h"
#import "Config.h"
#import "PSDevice.h"


@interface PSViewController : UIViewController

@property (strong, nonatomic) PSDevice *device;
@property (strong, nonatomic) PSProfile *profile;
@property (strong, nonatomic) PSLoadingIndicator *loadingIndicator;
- (UIView *)baseView;
- (UIView *)baseViewWithNavBar;
- (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)msg;
- (void)shiftUp:(CGFloat)distance;
- (void)shiftBack:(CGFloat)origin;
- (void)back;
- (void)addNavigationTitleView;
- (void)addCustomBackButton;
- (void)viewMenu:(id)sender;
- (void)addMenuButton;
- (void)showLoginView:(BOOL)animated completion:(void (^)(void))completion;
- (void)showAccountView:(void (^)(void))completion;
@end
