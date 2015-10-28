//
//  LWPOptionsPaneViewController.m
//  Lewp
//
//  Created by Ethan Geller on 1/4/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import "LWPOptionsPaneViewController.h"
#import "Options.h"
@interface LWPOptionsPaneViewController ()
@property (weak, nonatomic) IBOutlet UISlider *tempoSlider;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *tempoLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property NSString* name;
@property NSNumber* bpm;

@end

@implementation LWPOptionsPaneViewController
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender!= self.doneButton) return;
    else{
        [LWPScheduler masterScheduler].tempo = (NSUInteger) self.tempoSlider.value;
        if (self.userNameTextField.hasText)
        [LWPScheduler masterScheduler].userName = self.userNameTextField.text;
        
        //save to data
        NSManagedObjectContext* context = [LWPScheduler getContext];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Options" inManagedObjectContext:context]];
        
        NSError *err;
        NSArray *results = [context executeFetchRequest:request error:&err];
        if (err) {
            NSLog(@"ERROR GETTING RESULTS: %@",[err localizedDescription]);
        }
        if(results.count>0){
            Options* ops = [results objectAtIndex:0];
            ops.name = [LWPScheduler masterScheduler].userName;
            ops.tempo = [NSNumber numberWithFloat:[LWPScheduler masterScheduler].tempo];
            NSError* err;
            if(![context save:&err]){
                NSLog(@"WARNING: could not save record!\n%@", [err localizedDescription]);
            }
            else NSLog(@"Saved options to current record.");
        }
        else {
            Options* ops = [NSEntityDescription insertNewObjectForEntityForName:@"Options" inManagedObjectContext:context];
            ops.name = [LWPScheduler masterScheduler].userName;
            ops.tempo = [NSNumber numberWithFloat:[LWPScheduler masterScheduler].tempo];
            NSError* err;
            if(![context save:&err]){
                NSLog(@"WARNING: could not save record!\n%@", [err localizedDescription]);
            }
            else NSLog(@"Saved options to new record.");
        }
        if(results.count>1){
            NSLog(@"WARNING: more than one options file in existence. Worth looking into.");
        }
        
        NSLog(@"Options saved. Name: %@ Tempo: %lu", [LWPScheduler masterScheduler].userName, (unsigned long)[LWPScheduler masterScheduler].tempo);
        [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] letsGetIt]];
    }
}

-(void)tempoSliderChanged
{
    self.tempoLabel.text = [NSString stringWithFormat:@"%d", (int) self.tempoSlider.value];
    if ((int) self.tempoSlider.value < 90) {
        if ([LWPScheduler masterScheduler].voxPlaying) {
            [[LWPScheduler masterScheduler].audio removeChannels:@[[LWPScheduler masterScheduler].vox]];
        }
        [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] sludgeMetal]];
    }
    else if ((int) self.tempoSlider.value > 180) {
        if ([LWPScheduler masterScheduler].voxPlaying) {
            [[LWPScheduler masterScheduler].audio removeChannels:@[[LWPScheduler masterScheduler].vox]];
        }
        [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] kPop]];
    }
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
    NSManagedObjectContext* context = [LWPScheduler getContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Options" inManagedObjectContext:context]];
    
    NSError *err;
    NSArray *results = [context executeFetchRequest:request error:&err];
    if (err) {
        NSLog(@"ERROR GETTING RESULTS: %@",[err localizedDescription]);
    }
    if(results.count>0){
        Options* ops = [results objectAtIndex:0];
        _name = ops.name;
        _bpm = ops.tempo;
    }
    //load up the rest of the stuff
    if(_name){
        _userNameTextField.text = _name;
    }
    if(_bpm){
        _tempoSlider.value = _bpm.floatValue;
        _tempoLabel.text = [NSString stringWithFormat:@"%d", (int) _tempoSlider.value];
    }
    //rest of the setup
    self.tempoSlider.continuous = YES;
    [self.tempoSlider addTarget:self action:@selector(tempoSliderChanged) forControlEvents:UIControlEventValueChanged];
    if (arc4random_uniform(2))
        [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] whatsYourName]];
    
    else
        [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] whatsYourTempo]];
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
