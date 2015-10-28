//
//  LWPFinishedViewController.m
//  Lewp
//
//  Created by Ethan Geller on 2/26/15.
//  Copyright (c) 2015 Ethan Geller. All rights reserved.
//

#import "LWPFinishedViewController.h"

@interface LWPFinishedViewController ()
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UITextField *lewpNameField;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;

@end

@implementation LWPFinishedViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (sender!= _helpButton) {
        [[LWPScheduler masterScheduler] stopRecentLewp];
        [[LWPScheduler masterScheduler] playTheme];
        [[LWPScheduler masterScheduler] playAirHorn];
    }
    if (sender != _trashButton) {
        NSManagedObjectContext* context = [LWPScheduler getContext];
        PriorRecordings* song = [NSEntityDescription insertNewObjectForEntityForName:@"PriorRecordings" inManagedObjectContext:context];
        //TODO: save metadata
        song.songName = _lewpNameField.text;
        song.djtag = [LWPScheduler masterScheduler].userName;
        song.filePath = [LWPScheduler masterScheduler].fileName;
        song.dateCreated = [NSDate date];
        song.tempo = [NSNumber numberWithFloat:[LWPScheduler masterScheduler].tempo];
        song.isChallenge = false;
        NSError *err;
        if (![context save:&err]) {
            NSLog(@"ERROR WHILE SAVING: %@",[err localizedDescription]);
        }
        else NSLog(@"Saved!");
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[[LWPScheduler masterScheduler] playAirHorn]; //still on the fence about this...
    [[LWPScheduler masterScheduler] playRecentLewp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginToSoundCloud
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentModalViewController:loginViewController animated:YES];
    }];
}

- (IBAction)uploadToSoundcloud:(id)sender
{
    NSURL *trackURL = [NSURL
                       fileURLWithPath:[LWPScheduler masterScheduler].mostRecentFilePath];
    
    SCShareViewController *shareViewController;
    SCSharingViewControllerCompletionHandler handler;
    
    handler = ^(NSDictionary *trackInfo, NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Uploaded track: %@", trackInfo);
        }
    };
    shareViewController = [SCShareViewController
                           shareViewControllerWithFileURL:trackURL
                           completionHandler:handler];
    [shareViewController setTitle:@"BANGER 101"];
    [shareViewController setPrivate:NO];
    [self presentModalViewController:shareViewController animated:YES];
}
- (IBAction)trashIt:(id)sender {
    [self removeFile:[LWPScheduler masterScheduler].mostRecentFilePath];
}

- (void)removeFile:(NSString *)filepath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filepath error:&error];
    
    if (success) {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"It's gone!" message:@"You're right, that was not very good." delegate:self cancelButtonTitle:@"Fuck you, dude" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation


@end
