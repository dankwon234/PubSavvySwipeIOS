//
//  PSAboutViewController.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 9/10/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PSAboutViewController.h"

@implementation PSAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        
    }
    
    return self;
}


- (void)loadView
{
    UIView *view = [self baseView];
    view.backgroundColor = [UIColor whiteColor];
    CGRect frame = view.frame;

    
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addMenuButton];
    

    
}

@end
