//
//  PSSearchViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 7/2/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSSearchViewController.h"

@interface PSSearchViewController ()
@property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation PSSearchViewController

- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor redColor];
    
    self.view = view;
}

@end
