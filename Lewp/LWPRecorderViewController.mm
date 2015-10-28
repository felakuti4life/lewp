//
//  LWPRecorderViewController.m
//  Lewp
//
//  Created by Ethan Geller on 2/18/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import "LWPRecorderViewController.h"
#import <QuartzCore/QuartzCore.h>

#define C_WIDTH 120
#define C_HEIGHT 120

#define PERCENT_TO_TALK 15
#define PERCENT_TO_ANIMATE 50

@interface LWPRecorderViewController ()




@end

@implementation LWPRecorderViewController
float w,h;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (sender == _panicButton) {
        [[LWPScheduler masterScheduler] playTheme];
        [[LWPScheduler masterScheduler] playAirHorn];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        w = screenRect.size.width;
        h = screenRect.size.height;
        NSLog(@"Width: %f, Height: %f", w,h);
        _circleStartingBounds = CGRectMake(w, h/2, C_WIDTH, C_HEIGHT); //outside to the right
        _circleActiveBounds = CGRectMake(self.view.center.x, self.view.center.y, C_WIDTH, C_HEIGHT); //dead center
        _circleEndingBounds = CGRectMake(0, h/2, C_WIDTH, C_HEIGHT);
        _circleImage = [UIImage imageNamed:@"lewpCircle2.png"];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _segueString = @"finish";
	// Do any additional setup after loading the view.
    if([LWPScheduler masterScheduler].theme.channelIsPlaying)
        [[LWPScheduler masterScheduler] stopTheme];
    [[LWPScheduler masterScheduler] prepareToLewp];
    _circle.frame = _circleActiveBounds;
    _animateTime = 60.0f*1.0f/[LWPScheduler masterScheduler].tempo*(PERCENT_TO_ANIMATE /100);
    NSLog(@"Animation Time: %f seconds", _animateTime);
    NSTimer* animationTimer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(redraw:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
    
}

- (void)redraw:(NSTimer*)theTimer {
    int beats = [LWPScheduler masterScheduler].currentBeat;
    int lewps = [LWPScheduler masterScheduler].currentLewp;
    int stacks = [LWPScheduler masterScheduler].currentStack;
    float progress = ((float) beats + (lewps*BEATS_PER_LEWP) + (stacks*MAX_LEWPS_PER_STACK*BEATS_PER_LEWP)) / ((float) MAX_STACKS_PER_SONG * MAX_LEWPS_PER_STACK * BEATS_PER_LEWP);
    
    
    if(beats!=_lastBeat){
        //set instrument text
        [_instrumentLabel setText:[[[LWPScheduler masterScheduler] instrumentNames] objectAtIndex:lewps+stacks*MAX_LEWPS_PER_STACK]];
        NSString *b = [NSString stringWithFormat:@"%i", beats+1];
        [_beatLabel setText:b];
        _lastBeat = beats;
        [self rotationAnimation];
    }
    
    if(lewps!=_lastLewp){
        //switch up circles here
        [self SwitchLewpCircle];
        _lastLewp = lewps;
        if(arc4random_uniform(100)<=PERCENT_TO_TALK){
            int action = arc4random_uniform(11);
            switch (action) {
                case 0:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] itBangs]];
                    [self animateQuoteWithImage:@"itBangs"];
                    break;
                case 1:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] thisIsDope]];
                    [self animateQuoteWithImage:@"thisIsSoDope"];
                    break;
                case 2:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] alternative]];
                    [self animateQuoteWithImage:@"alternative"];
                    break;
                case 3:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] promworthy]];
                    if(arc4random_uniform(2)) [self animateQuoteWithImage:@"promWorthy1"];
                    else [self animateQuoteWithImage:@"promWorthy2"];
                    break;
                case 4:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] howBaroque]];
                    [self animateQuoteWithImage:@"howBaroque"];
                    break;
                case 5:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] ifItAint]];
                    [self animateQuoteWithImage:@"baroque2"];
                    break;
                case 6:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] heartWarming]];
                    [self animateQuoteWithImage:@"heartWarming"];
                    break;
                case 7:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] whatAPos]];
                    [self animateQuoteWithImage:@"positiveMessage"];
                    break;
                case 8:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] isThatABanjo]];
                    [self animateQuoteWithImage:@"banjo"];
                    break;
                case 9:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] memeWorthy]];
                    [self animateQuoteWithImage:@"memeReady"];
                    break;
                case 10:
                    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] vapid]];
                    [self animateQuoteWithImage:@"vapid"];
                    break;
                default:
                    break;
            }
        }
        if([LWPScheduler masterScheduler].isDone){
            [[LWPScheduler masterScheduler] stopLewping];
            [self performSegueWithIdentifier:_segueString sender:self];
        }
        
    }
    NSString *s = [NSString stringWithFormat:@"STACK %i", stacks+1];
    
    
    
    [_stackLabel setText:s];
    [_progressBar setProgress:progress];
    
    
    
    _lastStack = stacks;
}

-(void)animateQuoteWithImage: (NSString*)imageName {
    w= [UIScreen mainScreen].bounds.size.width;
    h= [UIScreen mainScreen].bounds.size.height;
    UIImageView* quote = [[UIImageView alloc] init];
    quote.image = [UIImage imageNamed:imageName];
    quote.frame = CGRectMake(w, h/2, w/1.4, h/2.5);
    quote.alpha = 0.0;
    quote.layer.zPosition = 3.0;
    [self.view addSubview:quote];
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        quote.alpha = 1.0;
        quote.frame = CGRectMake(w/4, h/4, w/1.5, h/1.5);
        
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:1.5f delay:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        quote.alpha = 0.0;
        quote.frame = CGRectMake(0, w/2, w/3.0, h/3.0);
        
    } completion:^(BOOL finished) {
        [quote removeFromSuperview];
    }];
    
}

-(void)SwitchLewpCircle {
    //add a new circle
    [UIView animateWithDuration:_animateTime animations:^{
        _circle.frame = _circleEndingBounds;
        _circle.hidden = true;
        _circle.frame = _circleStartingBounds;
        _circle.hidden = false;
        _circle.frame = _circleActiveBounds;
    }];
    
    
    
}

- (void)rotationAnimation
{
    [UIView animateWithDuration:0.1f animations:^{
        _circle.transform = CGAffineTransformMakeRotation(M_PI*2*_lastBeat/BEATS_PER_LEWP);
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
