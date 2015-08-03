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


@interface PSContainerViewController()
@property (strong, nonatomic) UITableView *sectionsTable;
@property (strong, nonatomic) NSArray *sections;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) PSViewController *currentVc;
@property (strong, nonatomic) PSFeaturedArticlesViewController *featuredVc;
@property (strong, nonatomic) PSRelatedViewController *relatedVc;
@property (strong, nonatomic) PSSearchViewController *searchVc;
@property (strong, nonatomic) PSSavedViewController *savedVc;
@end


@implementation PSContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.sections = @[@"Random", @"Related", @"Search", @"Saved", @"About"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(toggleMenu)
                                                     name:kViewMenuNotification
                                                   object:nil];

//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(showWelcomeView)
//                                                     name:kExitBoardNotification
//                                                   object:nil];
        
    }
    return self;
}





- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor darkGrayColor];
    CGRect frame = view.frame;

    
    CGFloat width = frame.size.width;
    self.sectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, frame.size.height) style:UITableViewStylePlain];
    self.sectionsTable.backgroundColor = [UIColor clearColor];
    self.sectionsTable.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.sectionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.sectionsTable.dataSource = self;
    self.sectionsTable.delegate = self;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, kNavBarHeight)];
    header.backgroundColor = kLightBlue;
    self.sectionsTable.tableHeaderView = header;
    
    
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
    
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.navController.view addGestureRecognizer:swipeLeft];
//    
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.navController.view addGestureRecognizer:swipeRight];
    
//    [self.welcomeView introAnimation];
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
        line.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:line];
        
    }
    
    cell.textLabel.text = self.sections[indexPath.row];
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
    
    if ([section isEqual:@"about"]){ // ignore for now
        [self toggleMenu];
        return;
    }

    
    if ([section isEqual:@"random"]){
        if ([self.currentVc isEqual:self.featuredVc]){
            [self toggleMenu];
            return;
        }
        
        self.currentVc = self.featuredVc;
    }
    
    if ([section isEqual:@"related"]){
        if ([self.currentVc isEqual:self.relatedVc]){
            [self toggleMenu];
            return;
        }
        
        if (self.relatedVc==nil)
            self.relatedVc = [[PSRelatedViewController alloc] init];
        
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
