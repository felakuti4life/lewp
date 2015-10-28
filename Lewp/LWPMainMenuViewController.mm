//
//  LWPMainMenuViewController.m
//  Lewp
//
//  Created by Ethan Geller on 1/4/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "LWPMainMenuViewController.h"
#import "Options.h"


@interface LWPMainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headphoneImg;
@property (weak, nonatomic) IBOutlet UIImageView *clowdImg;

@property bool headphoneSkitPlaying, letsDoItPlaying;
@end

@implementation LWPMainMenuViewController

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue
{
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
    [[LWPScheduler masterScheduler] playTheme];
    [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] lewpYell]];
    _letsDoItPlaying = true;
    if ([LWPScheduler masterScheduler].audio.playingThroughDeviceSpeaker) {
        _letsDoItPlaying = false;
        [_headphoneImg setHidden:false];
        [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] wearHeadphones]];
        _headphoneSkitPlaying = true;
    }
    NSTimer* animationTimer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(redraw:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
    //load up options
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
        [LWPScheduler masterScheduler].userName = ops.name;
        [LWPScheduler masterScheduler].tempo = ops.tempo.floatValue;
    }
    
    if(![LWPScheduler masterScheduler].userRecordGot) {
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase* publicDB = [container publicCloudDatabase];
        
        //container.handle = [[NSUserDefaults standardUserDefaults] valueForKey:SenderKey];
        
        [container requestApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus status, NSError *error){
            
            
            if(status == CKApplicationPermissionStatusGranted)
                [container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
                    if (error) {
                        NSLog(@"ERROR: Couldn't get the user's ID!");
                    }
                    else {
                        //MARK: May not be neccesary?
                        [LWPScheduler masterScheduler].userID = recordID.recordName;
                        [LWPScheduler masterScheduler].userRecordGot = YES;
                        NSLog(@"USER RECORD ID: %@", recordID.recordName);
                    }
                }];
            
            if(error) {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
    
    
}

- (void)redraw:(NSTimer*)theTimer {
    if ([LWPScheduler masterScheduler].audio.playingThroughDeviceSpeaker) {
        [_headphoneImg setHidden:false];
        if(_letsDoItPlaying) {
            [[LWPScheduler masterScheduler].audio removeChannels:@[[LWPScheduler masterScheduler].vox]];
            _letsDoItPlaying = false;
        }
        if (!_headphoneSkitPlaying) {
            [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] wearHeadphones]];
            _headphoneSkitPlaying = true;
        }
    }
    else if (![LWPScheduler masterScheduler].audio.playingThroughDeviceSpeaker) {
        [_headphoneImg setHidden:true];
        if(_headphoneSkitPlaying) {
            [[LWPScheduler masterScheduler].audio removeChannels:@[[LWPScheduler masterScheduler].vox]];
            _headphoneSkitPlaying = false;
        }
        if (!_letsDoItPlaying) {
            [[LWPScheduler masterScheduler] playVox:[[LWPScheduler masterScheduler] letsDoIt]];
            _letsDoItPlaying = true;
        }
        
        
    }
    
    //clowd img
    if((![LWPScheduler masterScheduler].isUploading) ^ _clowdImg.hidden){
        _clowdImg.hidden = ![LWPScheduler masterScheduler].isUploading;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
