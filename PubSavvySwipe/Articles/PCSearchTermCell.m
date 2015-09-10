//
//  PCSearchTermCell.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 9/7/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PCSearchTermCell.h"
#import "Config.h"

@implementation PCSearchTermCell
@synthesize lblTerm;
@synthesize lblFrequency;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        
        CGFloat padding = 10.0f;
        self.lblTerm = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-2*padding, 22.0f)];
        self.lblTerm.font = [UIFont fontWithName:kBaseFontName size:12.0f];
        [self.contentView addSubview:self.lblTerm];
        
        self.lblFrequency = [[UILabel alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-4*padding, 22.0f)];
        self.lblFrequency.textAlignment = NSTextAlignmentRight;
        self.lblFrequency.font = self.lblTerm.font;
        self.lblFrequency.textColor = kLightBlue;
        [self.contentView addSubview:self.lblFrequency];
        
    }
    
    return self;
}

@end
