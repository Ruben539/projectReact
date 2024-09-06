//
//  ComboBoxTableViewCell.m
//  congreso-roemmers
//
//  Created by Mambo on 9/3/16.
//  Copyright © 2016 Mambo. All rights reserved.
//

#import "ComboBoxTableViewCell.h"

@implementation ComboBoxTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
