//
//  PSLoadingIndicator.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 5/21/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.
//

#import "PSLoadingIndicator.h"

@implementation PSLoadingIndicator
@synthesize lblTitle;
@synthesize lblMessage;
@synthesize darkScreen;
@synthesize spinner;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.darkScreen = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.3f*frame.size.width, 0.3f*frame.size.width)];
        self.darkScreen.center = CGPointMake(0.5f*frame.size.width, 0.3f*frame.size.height);
        self.darkScreen.backgroundColor = [UIColor blackColor];
        self.darkScreen.alpha = 0.7f;
        self.darkScreen.layer.cornerRadius = 4.0f;
        [self addSubview:self.darkScreen];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.darkScreen.frame.origin.x, self.darkScreen.frame.origin.y+10.0f, self.darkScreen.frame.size.width, 30.0f)];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20.0f];
        self.lblTitle.textColor = [UIColor whiteColor];
        //self.lblTitle.text = @"Loading...";
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lblTitle];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.spinner.center = self.darkScreen.center;
        [self addSubview:self.spinner];
        
        CGFloat y = self.spinner.frame.origin.y+self.spinner.frame.size.height+15.0f;
        self.lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(self.lblTitle.frame.origin.x, y, self.lblTitle.frame.size.width, 30.0f)];
        self.lblMessage.textColor = [UIColor whiteColor];
        self.lblMessage.textAlignment = NSTextAlignmentCenter;
        self.lblMessage.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16.0f];
        //self.lblMessage.text = @"Authorizing...";
        self.lblMessage.numberOfLines = 0;
        self.lblMessage.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.lblMessage];
        
        
    }
    return self;
}

- (void)startLoading
{
    if (self.alpha > 0)
        return;
    
    [self.spinner startAnimating];
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:NULL];
    
}

- (void)stopLoading
{
    if (self.alpha < 1)
        return;
    
    [self.spinner stopAnimating];
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:NULL];
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
