//
//  ComboBoxButton.h
//  congreso-roemmers
//
//  Created by Mambo on 9/3/16.
//  Copyright © 2016 Mambo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComboBoxButton : UIButton <UITableViewDataSource, UITableViewDelegate>
// views
@property (strong, nonatomic) UITableView *myOptionsTable;


// properties
@property BOOL active;
@property NSArray *data;
@property float tableHeight;


// methods
-(instancetype)initWithData:(NSArray *)data andTableHeight:(float)tableHeight andFrame:(CGRect)frame;
-(void)addOptionsTable;
@end
