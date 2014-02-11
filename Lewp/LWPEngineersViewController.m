//
//  LWPEngineersViewController.m
//  Lewp
//
//  Created by Ethan Geller on 1/5/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPEngineersViewController.h"

@interface LWPEngineersViewController ()
@property (weak, nonatomic) IBOutlet UILabel *adviceLabel;
@end

@implementation LWPEngineersViewController
@synthesize adviceList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.adviceList.count) {
        NSUInteger idx = arc4random_uniform(self.adviceList.count);
        [self.adviceLabel setText:adviceList[idx]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
