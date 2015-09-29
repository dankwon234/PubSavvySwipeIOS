//
//  PSLoginViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 8/3/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSLoginViewController.h"
#import "PSRegistrationViewController.h"
#import "PSWebServices.h"


@interface PSLoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *passwordField;
@end

@implementation PSLoginViewController

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
    view.backgroundColor = [UIColor blackColor];
    CGRect frame = view.frame;
    
    CGFloat y = 100.0f;
    CGFloat width = frame.size.width;
    
    CGFloat x = 36.0f;
    UILabel *lblLogin = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 64.0f)];
    lblLogin.textColor = [UIColor whiteColor];
    lblLogin.textAlignment = NSTextAlignmentCenter;
    lblLogin.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblLogin.numberOfLines = 0;
    lblLogin.lineBreakMode = NSLineBreakByWordWrapping;
    lblLogin.text = @"Create a free account to access your search history and saved articles on the web";
    [view addSubview:lblLogin];
    y += lblLogin.frame.size.height+24.0f;
    
    x = 48.0f;
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(x, y, 0.5f*frame.size.width-x, 32.0f);
    btnRegister.backgroundColor = [UIColor darkGrayColor];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRegister setTitle:@"Register" forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(btnRegisterAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnRegister];

    UIButton *btnSignin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSignin.frame = CGRectMake(0.5f*frame.size.width, y, 0.5f*frame.size.width-x, 32.0f);
    btnSignin.backgroundColor = [UIColor grayColor];
    [btnSignin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSignin setTitle:@"Sign In" forState:UIControlStateNormal];
    [btnSignin addTarget:self action:@selector(btnSigninAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSignin];
    y += btnRegister.frame.size.height+16.0f;
    
    self.emailField = [[UITextField alloc] init];
    self.passwordField = [[UITextField alloc] init];
    
    NSArray *fields = @[self.emailField, self.passwordField];
    NSArray *placeholders = @[@"Email", @"Password"];
    UIFont *font = [UIFont fontWithName:kBaseFontName size:14.0];
    UIColor *white = [UIColor whiteColor];
    CGFloat h = 44.0f;
    x = 32.0f;
    for (int i=0; i<fields.count; i++) {
        UITextField *field = fields[i];
        field.frame = CGRectMake(0.0f, y, width, 44.0f);
        field.delegate = self;
        field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, h)];
        field.leftViewMode = UITextFieldViewModeAlways;
        field.backgroundColor = [UIColor clearColor];
        field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholders[i] attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
        field.alpha = 0.8f;
        field.textColor = [UIColor darkGrayColor];
        field.placeholder = placeholders[i];
        field.returnKeyType = UIReturnKeyNext;
        field.font = font;
        field.textColor = white;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, h-6.0f, width-2*x, 1.0f)];
        line.backgroundColor = white;
        [field addSubview:line];
        
        [view addSubview:field];
        y += field.frame.size.height+4.0f;
    }
    
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    y += 24.0f;
    
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLogin.frame = CGRectMake(x, y, width-2*x, 24.0f);
    btnLogin.backgroundColor = [UIColor clearColor];
    [btnLogin addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [btnLogin setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    [view addSubview:btnLogin];
    
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
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


- (void)dismissKeyboard
{
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)signUp:(UIButton *)btn
{
    NSLog(@"signUp: ");
    PSRegistrationViewController *registerVc = [[PSRegistrationViewController alloc] init];
    [self.navigationController pushViewController:registerVc animated:YES];
}

- (void)login
{
    if (self.emailField.text.length==0){
        [self showAlertWithTitle:@"Missing Email" message:@"Please enter your email."];
        return;
    }
    
    if (self.passwordField.text.length==0){
        [self showAlertWithTitle:@"Missing Password" message:@"Please enter your password."];
        return;
    }
    
    [self dismissKeyboard];

    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] login:@{@"email":self.emailField.text, @"password":self.passwordField.text} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        [self.profile populate:results[@"profile"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLoggedInNotification object:nil]];
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        });
        
    }];
}

- (void)btnRegisterAction:(UIButton *)btn
{
    NSLog(@"btnRegisterAction: ");

    
}

- (void)btnSigninAction:(UIButton *)btn
{
    NSLog(@"btnSigninAction: ");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailField]){
        [self.passwordField becomeFirstResponder];
        return YES;
    }
    
    [self login];
    return YES;
}

@end
