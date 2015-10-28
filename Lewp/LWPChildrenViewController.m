//
//  LWPChildrenViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/7/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPChildrenViewController.h"
#import "LWPChildrenTableViewController.h"
#import "LWPScheduler.h"

@interface LWPChildrenViewController ()
@property (weak, nonatomic) IBOutlet UILabel *instrumentLabel;
@property (weak, nonatomic) IBOutlet UILabel *djTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property LWPChildrenTableViewController* table;
@property NSTimer* animationTimer;
@end

@implementation LWPChildrenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLabels];
    _table = (LWPChildrenTableViewController*) self.childViewControllers.lastObject;
    _animationTimer = [NSTimer timerWithTimeInterval:(0.5f) target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
}

-(void) refresh {
    if (_table.refreshData) {
        [self setLabels];
        _table.refreshData = NO;
    }
}

-(void)setLabels {
    NSLog(@"Setting labels...");
    CKRecord* rec = [LWPScheduler masterScheduler].mostRecentRecord;
    NSString* instrumentName = [rec objectForKey:@"instrument"];
    [_instrumentLabel setText:instrumentName];
    NSString* djTagName = [rec objectForKey:@"djtag"];
    [_djTagLabel setText:djTagName];
    NSDate* date = [rec objectForKey:@"creationDate"];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    NSString* dateText = [format stringFromDate:date];
    [_dateLabel setText:dateText];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
