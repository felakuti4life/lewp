//
//  LWPClowdRecorderViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/10/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPClowdRecorderViewController.h"
#import "LWPScheduler.h"

@interface LWPClowdRecorderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *beatLabel;
@property (weak, nonatomic) IBOutlet UILabel *stackLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *instrumentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *circle;
@property (weak, nonatomic) IBOutlet UIButton *panicButton;



@end

@implementation LWPClowdRecorderViewController
@synthesize panicButton = _panicButton;

- (void)viewDidLoad {
    [LWPScheduler masterScheduler].challengeMode = YES;
    [super viewDidLoad];
    self.segueString = @"clowdFinish";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) redraw:(NSTimer *)theTimer {
    [super redraw:theTimer];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender == _panicButton) {
        [[LWPScheduler masterScheduler] playTheme];
        [[LWPScheduler masterScheduler] playAirHorn];
    }
}


@end
