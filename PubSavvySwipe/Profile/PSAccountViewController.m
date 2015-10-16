//
//  PSAccountViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 10/15/15.
//  Copyright © 2015 FrameResearch. All rights reserved.


#import "PSAccountViewController.h"

@interface PSAccountViewController ()
@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@end

@implementation PSAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.edgesForExtendedLayout = UIRectEdgeAll;
        
    }
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor lightGrayColor];
    CGRect frame = view.frame;
    
    UIImageView *profileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 72, 64, 64)];
    profileIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    profileIcon.backgroundColor = [UIColor blueColor];
    profileIcon.center = CGPointMake(0.5f*frame.size.width, profileIcon.center.y);
    [view addSubview:profileIcon];
    
    
    CGFloat y = profileIcon.frame.origin.y+profileIcon.frame.size.height+48.0f;
    CGFloat x = 20.0f;
    CGFloat h = 32.0f;
    CGFloat width = frame.size.width;
    
    self.firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width-2*x, h)];
    self.firstNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12.0f, h)];
    self.firstNameField.leftViewMode = UITextFieldViewModeAlways;
    self.firstNameField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.firstNameField.backgroundColor = [UIColor redColor];
    self.firstNameField.text = self.profile.firstName;
    self.firstNameField.placeholder = @"First Name";
    [view addSubview:self.firstNameField];
    y += self.firstNameField.frame.size.height+16.0f;

    self.lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, width-2*x, h)];
    self.lastNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12.0f, h)];
    self.lastNameField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lastNameField.backgroundColor = [UIColor redColor];
    self.lastNameField.text = self.profile.lastName;
    self.lastNameField.placeholder = @"Last Name";
    [view addSubview:self.lastNameField];
    
    y = frame.size.height - 64.0f;
    UIButton *btnUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpdate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnUpdate.frame = CGRectMake(20, y, width-40, 44);
    btnUpdate.backgroundColor = [UIColor redColor];
    [view addSubview:btnUpdate];

    
    

    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self addCustomBackButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(logout:)];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)logout:(id)sender
{
    NSLog(@"logout:");
    [self.profile clear:YES];
    [self back:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
    [defaults synchronize];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
