//
//  LWPClowdViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/8/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPClowdViewController.h"
#import "LWPClowdTableViewController.h"

@interface LWPClowdViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *globalSwitch;
@property LWPClowdTableViewController* table;

@property bool loadCheck;

@end

@implementation LWPClowdViewController

- (IBAction)unwindToClowdTable:(UIStoryboardSegue *)unwindSegue{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _table = (LWPClowdTableViewController*) [self.childViewControllers objectAtIndex:0];
    // Do any additional setup after loading the view.
    _loadCheck = YES;
    //NSTimer* animationTimer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(redraw:) userInfo:nil repeats:YES];
    //[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)globalSwitchChanged:(id)sender {
    _table.showFriendsList =_globalSwitch.selectedSegmentIndex;
    [_table refreshTable];
    
}

- (void)redraw:(NSTimer*)theTimer {
    if (_loadCheck == YES && _table.isLoading == NO) {
        NSLog(@"Load check: %i IsLoading: %i", _loadCheck, _table.isLoading);
        [_table refreshTable];
        _loadCheck = NO;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
