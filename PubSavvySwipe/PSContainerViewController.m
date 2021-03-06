//
//  PSContainerViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSContainerViewController.h"
#import "PSFeaturedArticlesViewController.h"
#import "PSSearchViewController.h"
#import "PSSavedViewController.h"
#import "PSRelatedViewController.h"
#import "PSAboutViewController.h"


@interface PSContainerViewController()
@property (strong, nonatomic) UITableView *sectionsTable;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) PSViewController *currentVc;
@property (strong, nonatomic) PSFeaturedArticlesViewController *featuredVc;
@property (strong, nonatomic) PSRelatedViewController *relatedVc;
@property (strong, nonatomic) PSSearchViewController *searchVc;
@property (strong, nonatomic) PSAboutViewController *aboutVc;
@property (strong, nonatomic) PSSavedViewController *savedVc;
@end


@implementation PSContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.sections = @[@"Random", @"Related", @"Search", @"Saved", @"About", @"Account"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleMenu)
                                                     name:kViewMenuNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refresh)
                                                     name:kLoggedInNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refresh)
                                                     name:kLoggedOutNotification
                                                   object:nil];

    }
    return self;
}





- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = kLightBlue;
    CGRect frame = view.frame;

    
    CGFloat width = frame.size.width;
    self.sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, frame.size.height) style:UITableViewStylePlain];
    self.sectionsTable.backgroundColor = [UIColor clearColor];
    self.sectionsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.sectionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sectionsTable.dataSource = self;
    self.sectionsTable.delegate = self;
    self.sectionsTable.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner.png"]];
    [view addSubview:self.sectionsTable];
    
    
    
    self.featuredVc = [[PSFeaturedArticlesViewController alloc] init];
    self.currentVc = self.featuredVc;
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.featuredVc];
    self.navController.navigationBar.barTintColor = kDarkBlue;
    
    [self addChildViewController:self.navController];
    [self.navController willMoveToParentViewController:self];
    [view addSubview:self.navController.view];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.navController.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.navController.view addGestureRecognizer:swipeRight];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isPopulated"]==NO)
        return;
}

- (void)refresh
{
    NSLog(@"refresh");
    [self.sectionsTable reloadData];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)toggleMenu:(NSTimeInterval)duration
{
    CGRect frame = self.view.frame;
    CGFloat halfWidth = 0.50f*frame.size.width;
    
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGPoint center = self.navController.view.center;
                         center.x = (center.x==halfWidth) ? 1.15f*frame.size.width : halfWidth;
                         self.navController.view.center = center;
                     }
                     completion:^(BOOL finished){
                         CGPoint center = self.navController.view.center;
                         self.navController.topViewController.view.userInteractionEnabled = (center.x==halfWidth);
                         [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:YES];
                     }];
}


- (void)toggleMenu
{
    [self toggleMenu:0.85f];
}

- (void)hideMenu
{
    CGRect frame = self.view.frame;
    CGFloat halfWidth = 0.50f*frame.size.width;

    CGPoint center = self.navController.view.center;
    if (center.x == halfWidth)
        return;
    
    [self toggleMenu];
    
}

- (void)showMenu
{
    CGRect frame = self.view.frame;
    CGFloat halfWidth = 0.50f*frame.size.width;
    
    CGPoint center = self.navController.view.center;
    if (center.x != halfWidth)
        return;
    
    [self toggleMenu];
    
}


- (void)loginOrViewAccount
{
    if (self.profile.isPopulated){
        [self showAccountView:^{
            [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:NO];
        }];
        
        return;
    }
    
    [self showLoginView:YES completion:^{
        [self.sectionsTable deselectRowAtIndexPath:[self.sectionsTable indexPathForSelectedRow] animated:NO];
    }];
}




#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:kBaseFontName size:16.0f];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 53.0f, tableView.frame.size.width, 0.5f)];
        line.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:line];
        
    }
    
    // Account Row
    if (indexPath.row == self.sections.count-1){
        cell.imageView.image = [UIImage imageNamed:@"iconAccount.png"];
        if (self.profile.isPopulated){ // logged in
            cell.textLabel.text = self.profile.email;
            return cell;
        }
        
        cell.textLabel.text = @"Account";
        return cell;
    }
    
    NSString *section = self.sections[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon%@.png", section]];
    cell.textLabel.text = section;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = [self.sections[indexPath.row] lowercaseString];
//    NSLog(@"SECTION = %@", section);
    
    if ([section isEqual:@"account"]){
        [self loginOrViewAccount];
        return;
    }

    if ([section isEqual:@"random"]){
        if ([self.currentVc isEqual:self.featuredVc]){
            [self toggleMenu];
            return;
        }
        
        self.currentVc = self.featuredVc;
    }
    
    
    if ([section isEqual:@"about"]){
        if ([self.currentVc isEqual:self.aboutVc]){
            [self toggleMenu];
            return;
        }
        
        if (self.aboutVc == nil)
            self.aboutVc = [[PSAboutViewController alloc] init];
        
        self.currentVc = self.aboutVc;
    }
    
    

    
    if ([section isEqual:@"related"]){
        if ([self.currentVc isEqual:self.relatedVc]){
            [self toggleMenu];
            return;
        }
        
        if (self.relatedVc == nil)
            self.relatedVc = [[PSRelatedViewController alloc] init];
        else
            [self.relatedVc checkRefresh];
        
        self.currentVc = self.relatedVc;
    }

    
    if ([section isEqual:@"search"]){
        if ([self.currentVc isEqual:self.searchVc]){
            [self toggleMenu];
            return;
        }
        
        if (self.searchVc==nil)
            self.searchVc = [[PSSearchViewController alloc] init];
        
        self.currentVc = self.searchVc;
    }
    
    if ([section isEqual:@"saved"]){
        if ([self.currentVc isEqual:self.savedVc]){
            [self toggleMenu];
            return;
        }
        
        if (self.savedVc==nil)
            self.savedVc = [[PSSavedViewController alloc] init];
        
        self.currentVc = self.savedVc;
    }

    
    CGRect frame = self.view.frame;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect navFrame = self.navController.view.frame;
                         navFrame.origin.x = frame.size.width;
                         self.navController.view.frame = navFrame;
                     }
                     completion:^(BOOL finished){
                         [self.navController popToRootViewControllerAnimated:NO];
                         if (indexPath.row != 0)
                             [self.navController pushViewController:self.currentVc animated:NO];
                         
                         [self toggleMenu:0.85f];
                     }];
}




@end
