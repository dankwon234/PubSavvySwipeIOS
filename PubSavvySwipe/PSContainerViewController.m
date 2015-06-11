//
//  PSContainerViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSContainerViewController.h"
#import "PSFeaturedArticlesViewController.h"

@interface PSContainerViewController()
@property (strong, nonatomic) UITableView *sectionsTable;
@property (strong, nonatomic) NSArray *sections;
//@property (strong, nonatomic) PSWelcomeView *welcomeView;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) PSViewController *currentVc;
@property (strong, nonatomic) PSFeaturedArticlesViewController *featuredVc;
@end


@implementation PSContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        self.sections = @[@"Featured Articles", @"Saved", @"About"];
        
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
//    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-white.png"]];
//    logo.frame = CGRectMake(12.0f, 22.0f, 0.3f*logo.frame.size.width, 0.3f*logo.frame.size.height);
//    [header addSubview:logo];
    self.sectionsTable.tableHeaderView = header;
    
    
    [view addSubview:self.sectionsTable];
    
    
    self.featuredVc = [[PSFeaturedArticlesViewController alloc] init];
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





@end
