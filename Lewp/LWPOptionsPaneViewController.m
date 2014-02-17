//
//  LWPOptionsPaneViewController.m
//  Lewp
//
//  Created by Ethan Geller on 1/4/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPOptionsPaneViewController.h"

@interface LWPOptionsPaneViewController ()
@property (weak, nonatomic) IBOutlet UISlider *tempoSlider;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *tempoLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@end

@implementation LWPOptionsPaneViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender!= self.doneButton) return;
    else{
        [LWPScheduler masterScheduler].tempo = (NSUInteger) self.tempoSlider.value;
        [LWPScheduler masterScheduler].userName = self.userNameTextField.text;
    }
}

-(void)tempoSliderChanged
{
    self.tempoLabel.text = [NSString stringWithFormat:@"%d", (int) self.tempoSlider.value];
}


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
    self.tempoSlider.continuous = YES;
    [self.tempoSlider addTarget:self action:@selector(tempoSliderChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
