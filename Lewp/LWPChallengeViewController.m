//
//  LWPChallengeViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/2/15.
//  Copyright (c) 2015 Ethan Geller. All rights reserved.
//
#import "LWPScheduler.h"
#import <CloudKit/CloudKit.h>
#import "PriorRecordings.h"
#import "LWPChallengeViewController.h"

@interface LWPChallengeViewController ()
@property NSString* name;
@property NSString* instrument;

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *instrumentField;

@end

@implementation LWPChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _name = [LWPScheduler masterScheduler].userName;
    _userNameField.text = _name;
    _instrumentField.text = [[LWPScheduler masterScheduler].instrumentNames objectAtIndex:arc4random_uniform([LWPScheduler masterScheduler].instrumentNames.count)];
    _instrument = _instrumentField.text;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nameChanged:(id)sender {
    _name = _userNameField.text;
}

- (IBAction)instrumentChanged:(id)sender {
    _instrument = _instrumentField.text;
}


- (IBAction)sendPressed:(id)sender {
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* publicDB = [container publicCloudDatabase];
    CKRecord* challenge = [[CKRecord alloc] initWithRecordType:@"Challenges"];
    CKRecord* audioRec = [[CKRecord alloc] initWithRecordType:@"audio"];
    NSString* fpath = [LWPScheduler masterScheduler].mostRecentFilePath;
    NSString* fname = [LWPScheduler masterScheduler].fileName;
    
    //get file
    NSManagedObjectContext* context = [LWPScheduler getContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PriorRecordings" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filePath == %@", fname];
    [request setPredicate:predicate];
    
    NSError *err;
    NSArray *results = [context executeFetchRequest:request error:&err];
    if (err) {
        NSLog(@"ERROR GETTING RESULTS: %@",[err localizedDescription]);
    }
    else if (results.count == 0) {
        NSLog(@"ERROR: NO RESULTS RECEIVED FOR FETCH REQUEST");
    }
    else {
        PriorRecordings* song = [results objectAtIndex:0];
        [challenge setValue:song.songName forKey:@"name"];
    }
    
    CKAsset* audio = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:fpath]];
    [challenge setValue:_name forKey:@"djtag"];
    [challenge setValue:_instrument forKey:@"instrument"];
    
    [challenge setValue:[NSNumber numberWithFloat:[LWPScheduler masterScheduler].tempo] forKey:@"tempo"];
    if([LWPScheduler masterScheduler].userRecordGot){
        [challenge setValue:[LWPScheduler masterScheduler].userID forKey:@"user"];
    }
    [audioRec setObject:audio forKey:@"file"];
    CKReference* audioRef = [[CKReference alloc] initWithRecord:audioRec action:CKReferenceActionDeleteSelf];
    [challenge setObject:audioRef forKey:@"audio"];
    [LWPScheduler masterScheduler].isUploading = YES;
    [publicDB saveRecord:challenge completionHandler:^(CKRecord *record, NSError *error) {
        if(error){
            NSLog(@"Failed:(:(:(:(");
            NSLog([error localizedDescription]);
            UIAlertView *uploadFailFulAlert=[[UIAlertView alloc]initWithTitle:@"Upload failed!" message:@"You can try again by basking in your prior successes." delegate:self cancelButtonTitle:@"Great!" otherButtonTitles:nil];
            [uploadFailFulAlert show];
        }
        else {
            [publicDB saveRecord:audioRec completionHandler:^(CKRecord *record, NSError *error) {
                if(error){
                    NSLog(@"Failed:(:(:(:(");
                    NSLog([error localizedDescription]);
                    UIAlertView *uploadFailFulAlert=[[UIAlertView alloc]initWithTitle:@"Upload failed!" message:@"You can try again by basking in your prior successes." delegate:self cancelButtonTitle:@"Great!" otherButtonTitles:nil];
                    [uploadFailFulAlert show];
                }
                else {
                    NSLog(@"Song uploaded!");
                    [LWPScheduler masterScheduler].isUploading = NO;
                    }
            }];
            //update the record down here with the cloud record
            NSManagedObjectContext* context = [LWPScheduler getContext];
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"PriorRecordings" inManagedObjectContext:context]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filePath == %@", fname];
            [request setPredicate:predicate];
            
            NSError *err;
            NSArray *results = [context executeFetchRequest:request error:&err];
            if (err) {
                NSLog(@"ERROR GETTING RESULTS: %@",[err localizedDescription]);
            }
            else if (results.count == 0) {
                NSLog(@"ERROR: NO RESULTS RECEIVED FOR FETCH REQUEST");
            }
            else {
                PriorRecordings* song = [results objectAtIndex:0];
                song.isChallenge = [NSNumber numberWithInt:1];
                song.cloudID = challenge.recordID.recordName;
                if(![context save:&err]){
                    NSLog(@"ERROR SAVING RECORD: %@",[err localizedDescription]);
                }
                else {
                    NSLog(@"Saved!\nCloudID:\t%@", song.cloudID);
                }
                
            }
        }
        
    }];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[LWPScheduler masterScheduler] stopRecentLewp];
    [[LWPScheduler masterScheduler] playTheme];
    [[LWPScheduler masterScheduler] playAirHorn];
}


@end
