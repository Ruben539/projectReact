//
//  ComboBoxButton.m
//  congreso-roemmers
//
//  Created by Mambo on 9/3/16.
//  Copyright © 2016 Mambo. All rights reserved.
//

#import "ComboBoxButton.h"
#import "ComboBoxTableViewCell.h"
#import "ViewController.h"

@implementation ComboBoxButton
@synthesize data, tableHeight;

-(instancetype)initWithData:(NSArray *)dataArray andTableHeight:(float)height andFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
//    self = [super init];
    if (!self) {
        self = [self initWithFrame:frame];
//        [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    self.tableHeight = height;
    self.data = dataArray;
    [self addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self setTitle:@"Cambiado al crear" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont fontWithName:@"BigNoodleTitling" size:24.0f]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -36, 0, 0)];
    [self setImage:[UIImage imageNamed:@"down-arrow"] forState:UIControlStateNormal];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, 250, 0, -3)];
    
    _myOptionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, 400, 0) style:UITableViewStylePlain];
    _myOptionsTable.delegate = self;
    _myOptionsTable.dataSource = self;
    _myOptionsTable.scrollEnabled = YES;
    _myOptionsTable.userInteractionEnabled = YES;
    [self addSubview:_myOptionsTable];
    _active = NO;
    
//    [self.superview addSubview:_myOptionsTable];
    
    return self;
}

-(void)addOptionsTable {
    _myOptionsTable = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.size.height + self.frame.origin.y, 400, 0) style:UITableViewStylePlain];
    [_myOptionsTable setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:52/255.0 alpha:1.0f]];
    _myOptionsTable.delegate = self;
    _myOptionsTable.dataSource = self;
    _myOptionsTable.scrollEnabled = YES;
    _myOptionsTable.userInteractionEnabled = YES;
    
//    NSLog(@"superview: %@", self.superview);
    
    _active = NO;
    [self.superview addSubview:_myOptionsTable];
}

-(IBAction)toggle:(id)sender {
    NSLog(@"Toggling...");
    
    if (_active) {
        _active = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.imageView.transform = CGAffineTransformIdentity; //CGAffineTransformMakeRotation(M_PI/-1.5);
            _myOptionsTable.frame = CGRectMake(_myOptionsTable.frame.origin.x, _myOptionsTable.frame.origin.y, _myOptionsTable.frame.size.width, 0);
        }];
    } else {
        _active = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.imageView.transform = CGAffineTransformMakeRotation(M_PI/1.0001);
            _myOptionsTable.frame = CGRectMake(_myOptionsTable.frame.origin.x, _myOptionsTable.frame.origin.y, _myOptionsTable.frame.size.width, self.tableHeight);
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesBegan");
    [self toggle:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count];
}

-(ComboBoxTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellIdentifier";
    ComboBoxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"ComboBoxTableViewCell" owner:self options:nil];
        cell = [nibArray objectAtIndex:0];
    }
    
    
    [cell.title setText:[[data objectAtIndex:indexPath.row] objectForKey:@"nombre"]];
    [cell.title setTextColor:[UIColor whiteColor]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *selected = [data objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customButtonPressed" object: selected];
    [self toggle:nil];
}

@end
