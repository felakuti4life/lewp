//
//  LWPPriorRecordingsItemViewController.m
//  Lewp
//
//  Created by Ethan Geller on 2/8/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPPriorRecordingsItemViewController.h"

@interface LWPPriorRecordingsItemViewController ()


@end

@implementation LWPPriorRecordingsItemViewController

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
    if([[SoundManager sharedManager] isPlayingMusic]) [[SoundManager sharedManager] stopMusic];
    [[SoundManager sharedManager] playMusic:[LWPConstants mainTheme] looping:YES]; //PLACEHOLDER: create dynamic sound pointer
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
