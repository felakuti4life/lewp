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
@property NSArray *adviceList;
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
    self.adviceList = [NSArray arrayWithObjects:
                       @"All this song needs is an awards show controversy.",
                       @"Are you sure about all of these hi hats?",
                       @"Maybe your most recent divorce can inspire this beat.",
                       @"You're going to take the singer songwriter genre by storm.",
                       @"Are you ever going to finish that solo album you were working on?",
                       @"I cannot for the life of me figure out how record labels actually make a profit.",
                       @"Nobody asked for a guitar solo at the end of this song.",
                       @"I don't know why you called this guy in, he is a terrible rapper.",
                       @"This is not a concept album. There is no concept tying this album together. Stop calling it that.",
                       nil];
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
