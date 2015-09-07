//
//  PCSearchTermCell.m
//  PubSavvySwipe
//
//  Created by Dan Kwon on 9/7/15.
//  Copyright (c) 2015 FrameResearch. All rights reserved.


#import "PCSearchTermCell.h"

@implementation PCSearchTermCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    return self;
}

@end
