//
//  LWPEngineersViewController.m
//  Lewp
//
//  Created by Ethan Geller on 1/5/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import "LWPEngineersViewController.h"

@interface LWPEngineersViewController ()
@property (weak, nonatomic) IBOutlet UILabel *adviceLabel;
@end

@implementation LWPEngineersViewController

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
    if ([LWPConstants adviceList].count) {
        NSUInteger idx = arc4random_uniform([LWPConstants adviceList].count);
        [self.adviceLabel setText:[LWPConstants adviceList][idx]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
