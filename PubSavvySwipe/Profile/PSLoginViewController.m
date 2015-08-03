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
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundLights.png"]];
    CGRect frame = view.frame;
    
    CGFloat y = 110.0f;
    CGFloat width = frame.size.width;
    
    static CGFloat x = 20.0f;
    UILabel *lblLogin = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblLogin.textColor = [UIColor whiteColor];
    lblLogin.textAlignment = NSTextAlignmentCenter;
    lblLogin.font = [UIFont fontWithName:kBaseFontName size:24.0f];
    lblLogin.text = @"Log In";
    [view addSubview:lblLogin];
    y += lblLogin.frame.size.height+32.0f;
    
    self.emailField = [[UITextField alloc] init];
    self.passwordField = [[UITextField alloc] init];
    
    NSArray *fields = @[self.emailField, self.passwordField];
    NSArray *placeholders = @[@"Email", @"Password"];
    UIFont *font = [UIFont fontWithName:kBaseFontName size:14.0];
    UIColor *white = [UIColor whiteColor];
    CGFloat h = 44.0f;
    x = 36.0f;
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
    
    
    UILabel *lblOr = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width-2*x, 32.0f)];
    lblOr.textColor = [UIColor whiteColor];
    lblOr.textAlignment = NSTextAlignmentCenter;
    lblOr.font = [UIFont fontWithName:kBaseFontName size:16.0f];
    lblOr.text = @"Don't have an account?";
    [view addSubview:lblOr];
    y += lblOr.frame.size.height;
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(x, y, width-2*x, 24.0f);
    btnRegister.backgroundColor = [UIColor clearColor];
    [btnRegister addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    [btnRegister setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = lblOr.font;
    [view addSubview:btnRegister];
    
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addCustomBackButton];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailField]){
        [self.passwordField becomeFirstResponder];
        return YES;
    }
    
    // login
    if (self.emailField.text.length==0){
        [self showAlertWithTitle:@"Missing Email" message:@"Please enter your email."];
        return YES;
    }
    
    if (self.passwordField.text.length==0){
        [self showAlertWithTitle:@"Missing Password" message:@"Please enter your password."];
        return YES;
    }
    
    
    [textField resignFirstResponder];
    [self.loadingIndicator startLoading];
    [[PSWebServices sharedInstance] login:@{@"email":self.emailField.text, @"password":self.passwordField.text} completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        [self.profile populate:results[@"profile"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kLoggedInNotification object:nil]];
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        });
        
    }];
    
    return YES;
}

@end
