//
//  PSViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSViewController.h"
//#import "PSRegistrationViewController.h"
#import "PSLoginViewController.h"


@implementation PSViewController
@synthesize loadingIndicator;
@synthesize device;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.device = [PSDevice sharedDevice];
        self.profile = [PSProfile sharedProfile];
        [self addNavigationTitleView];
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingIndicator = [[PSLoadingIndicator alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    self.loadingIndicator.alpha = 0.0f;
    [self.view addSubview:self.loadingIndicator];
}


- (UIView *)baseView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    
    return view;
}

- (UIView *)baseViewWithNavBar
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height-kNavBarHeight)];
    view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    
    return view;
}

- (void)addNavigationTitleView
{
    static CGFloat width = 200.0f;
    static CGFloat height = 46.0f;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    titleView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    titleView.backgroundColor = [UIColor clearColor];
    UIImage *imgLogo = [UIImage imageNamed:@"logo-white.png"];
    UIImageView *logo = [[UIImageView alloc] initWithImage:imgLogo];
    static double scale = 0.9f;
    CGRect frame = logo.frame;
    frame.size.width = scale*imgLogo.size.width;
    frame.size.height = scale*imgLogo.size.height;
    logo.frame = frame;
    logo.center = CGPointMake(0.50f*width, 24.0f);
    
    [titleView addSubview:logo];
    
    self.navigationItem.titleView = titleView;
    
}




- (void)shiftUp:(CGFloat)distance
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = -distance;
                         self.view.frame = frame;
                     }
                     completion:NULL];
}

- (void)shiftBack:(CGFloat)origin
{
    [UIView animateWithDuration:0.21f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = origin; // accounts for nav bar
                         self.view.frame = frame;
                     }
                     completion:NULL];
    
}


- (void)addCustomBackButton
{
    UIColor *white = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = white;
    
    NSDictionary *titleAttributes = @{NSFontAttributeName:[UIFont fontWithName:kBaseFontName size:18.0f], NSForegroundColorAttributeName : white};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];
    
    UIImage *imgExit = [UIImage imageNamed:@"backArrow.png"];
    UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExit.frame = CGRectMake(0.0f, 0.0f, 0.8f*imgExit.size.width, 0.8f*imgExit.size.height);
    [btnExit setBackgroundImage:imgExit forState:UIControlStateNormal];
    [btnExit addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnExit];
}

- (void)addMenuButton
{
    UIImage *imgHamburger = [UIImage imageNamed:@"iconHamburger.png"];
    UIButton *btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMenu.frame = CGRectMake(0.0f, 0.0f, 0.5f*imgHamburger.size.width, 0.5f*imgHamburger.size.height);
    [btnMenu setBackgroundImage:imgHamburger forState:UIControlStateNormal];
    [btnMenu addTarget:self action:@selector(viewMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMenu];
}



- (void)back:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)showLoginView:(BOOL)animated completion:(void (^)(void))completion
{
    PSLoginViewController *loginVc = [[PSLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVc];
    navController.navigationBar.barTintColor = kDarkBlue;

    [self presentViewController:navController animated:animated completion:^{
        if (completion)
            completion();
    }];

    
}



- (void)showAccountView:(void (^)(void))completion
{
    
}


- (UINavigationController *)clearNavigationControllerWithRoot:(UIViewController *)root
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:root];
    
    // makes nav bar clear:
    [navController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navController.view.backgroundColor = [UIColor clearColor];
    navController.navigationBar.shadowImage = [UIImage new];
    navController.navigationBar.translucent = YES;
    return navController;
}


/*
 - (void)showLoginView:(BOOL)animated
 {
 PCLoginViewController *loginVc = [[PCLoginViewController alloc] init];
 UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVc];
 navController.navigationBar.barTintColor = kLightBlue;
 [self presentViewController:navController animated:animated completion:^{
 
 }];
 }
 
 - (void)showAccountView
 {
 PCAccountViewController *accountVc = [[PCAccountViewController alloc] init];
 UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountVc];
 navController.navigationBar.barTintColor = kGreen;
 [self presentViewController:navController animated:YES completion:^{
 
 }];
 }
 */

- (void)viewMenu:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kViewMenuNotification object:nil]];
}



#pragma mark - Alert
- (UIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return alert;
}




@end
