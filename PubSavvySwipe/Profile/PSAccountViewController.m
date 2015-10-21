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
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UIImageView *profileIcon;
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
    
    UIImageView *imgOwl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgOwl.png"]];
    imgOwl.frame = CGRectMake(0, 0, frame.size.width, frame.size.height+20);
    [view addSubview:imgOwl];
    
    CGFloat dimen = 84.0f;
    self.profileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 72.0f, dimen, dimen)];
    self.profileIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.profileIcon.backgroundColor = [UIColor blueColor];
    self.profileIcon.center = CGPointMake(0.5f*frame.size.width, self.profileIcon.center.y);
    self.profileIcon.userInteractionEnabled = YES;
    [self.profileIcon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)]];
    self.profileIcon.layer.cornerRadius = 0.5f*dimen;
    self.profileIcon.layer.masksToBounds = YES;
    [view addSubview:self.profileIcon];
    
    
    CGFloat y = self.profileIcon.frame.origin.y+self.profileIcon.frame.size.height+48.0f;
    CGFloat x = 32.0f;
    CGFloat h = 44.0f;
    CGFloat width = frame.size.width;
    
    self.firstNameField = [[UITextField alloc] init];
    self.lastNameField = [[UITextField alloc] init];
    self.passwordField = [[UITextField alloc] init];

    NSArray *fields = @[self.firstNameField, self.lastNameField, self.passwordField];
    NSArray *placeholders = @[@"First Name", @"Last Name", @"Password"];
    UIColor *white = [UIColor whiteColor];
    UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
    
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
    
    self.firstNameField.text = [self.profile.firstName capitalizedString];
    self.lastNameField.text = [self.profile.lastName capitalizedString];
    
    y = frame.size.height - 64.0f;
    UIButton *btnUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpdate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    btnUpdate.frame = CGRectMake(20.0f, y, width-40.0f, 44.0f);
    btnUpdate.backgroundColor = kDarkBlue;
    [btnUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnUpdate setTitle:@"Update Profile" forState:UIControlStateNormal];
    [btnUpdate addTarget:self action:@selector(updateProfile:) forControlEvents:UIControlEventTouchUpInside];
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
    
    if (self.profile.image.length == 0)
        return;
    
    
    [[PSWebServices sharedInstance] fetchImage:self.profile.image parameters:@{@"crop":@"260"} completionBlock:^(id result, NSError *error){
        if (error){ // fail silently
            NSLog(@"ERROR: %@", [error localizedDescription]);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"TEST 4");
            UIImage *image = (UIImage *)result;
            self.profileIcon.image = image;
            
        });
        
    }];
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

- (void)updateProfile:(UIButton *)btn
{
    NSLog(@"updateProfile: ");
    
    [self.loadingIndicator startLoading];
    if (self.profile.imageData){
        [[PSWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
            if (error){
                [self.loadingIndicator stopLoading];
                [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
                return;
            }
            
            NSDictionary *results = (NSDictionary *)result;
            NSLog(@"%@", [results description]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadImage:results[@"upload"]];
            });
        }];
        return;
    }
    
    
    NSCharacterSet *trim = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.profile.firstName = [self.firstNameField.text stringByTrimmingCharactersInSet:trim];
    self.profile.lastName = [self.lastNameField.text stringByTrimmingCharactersInSet:trim];
    
    [[PSWebServices sharedInstance] updateProfile:self.profile completionBlock:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
        NSLog(@"%@", [results description]);
        [self showAlertWithTitle:@"Profile Updated" message:nil];
        
    }];
}

- (void)selectImage:(UIGestureRecognizer *)tap
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
    actionsheet.frame = CGRectMake(0, 150.0f, self.view.frame.size.width, 100.0f);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)uploadImage:(NSString *)uploadUrl
{
    NSDictionary *pkg = @{@"data":UIImageJPEGRepresentation(self.profile.imageData, 0.5f), @"name":@"image.jpg"};
    [[PSWebServices sharedInstance] uploadImage:pkg toUrl:uploadUrl completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            [self.loadingIndicator stopLoading];
            [self showAlertWithTitle:@"Error" message:[error localizedDescription]];
            return;
        }
        
        NSDictionary *results = (NSDictionary *)result;
//        NSLog(@"%@", [results description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *imageInfo = results[@"image"];
            self.profile.image = imageInfo[@"id"];
            self.profile.imageData = nil;
            
            [self updateProfile:nil];
        });
    }];
}



#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    if (buttonIndex==0){
        [self launchImageSelector:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if (buttonIndex==1){
        [self launchImageSelector:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: didFinishPickingMediaWithInfo: %@", [info description]);
    UIImage *image = info[UIImagePickerControllerEditedImage];
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (w != h){
        CGFloat dimen = (w < h) ? w : h;
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0.5*(image.size.width-dimen), 0.5*(image.size.height-dimen), dimen, dimen));
        image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.5f)];
        CGImageRelease(imageRef);
    }
    
    self.profile.imageData = image;
    self.profileIcon.image = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}




- (void)launchImageSelector:(UIImagePickerControllerSourceType)sourceType
{
    [self.loadingIndicator startLoading];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.loadingIndicator stopLoading];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
