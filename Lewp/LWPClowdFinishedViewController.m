//
//  LWPClowdFinishedViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/15/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPClowdFinishedViewController.h"
#import "LWPScheduler.h"
#import "Options.h"
#import <CloudKit/CloudKit.h>

@interface LWPClowdFinishedViewController ()
@property (weak, nonatomic) IBOutlet UIButton *postItButton;
@property (weak, nonatomic) IBOutlet UIButton *trashItButton;
@property (weak, nonatomic) IBOutlet UITextField *djTagInput;
@property (weak, nonatomic) IBOutlet UITextField *instrumentInput;

@end

@implementation LWPClowdFinishedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[LWPScheduler masterScheduler] playRecentLewp];
    [_djTagInput setText:[LWPScheduler masterScheduler].userName];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) saveTheChild {
    NSString* fpath = [LWPScheduler masterScheduler].mostRecentFilePath;
    NSLog(@"FPATH: %@", fpath);
    NSURL* furl = [[NSURL alloc] initFileURLWithPath:fpath];
    NSLog(@"furl: %@", furl.path);
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* publicDB = [container publicCloudDatabase];
    
    CKRecord* parent = [LWPScheduler masterScheduler].mostRecentRecord;
    CKRecord* child = [[CKRecord alloc] initWithRecordType:@"Challenges"];
    CKRecord* childAudio = [[CKRecord alloc] initWithRecordType:@"audio"];
    NSLog(@"Hit");
    CKAsset* childAudioAsset = [[CKAsset alloc] initWithFileURL:furl];
    NSLog(@"Hit");
    [childAudio setObject:childAudioAsset forKey:@"file"];
    CKReference* childAudioRef = [[CKReference alloc] initWithRecord:childAudio action:CKReferenceActionDeleteSelf];
    NSString* childName = [parent objectForKey:@"name"];
    //set child record info
    [child setValue:[_djTagInput text] forKey:@"djtag"];
    [child setValue:_instrumentInput.text forKey:@"instrument"];
    [child setValue:[LWPScheduler masterScheduler].userID forKey:@"user"];
    [child setValue:childName forKey:@"name"];
    [child setValue:[NSNumber numberWithFloat:[LWPScheduler masterScheduler].tempo] forKey:@"tempo"];
    [child setObject:childAudioRef forKey:@"audio"];
    
    //save pointer to child in parent record
    CKReference* childRef = [[CKReference alloc] initWithRecord:child action:CKReferenceActionNone];
    NSArray* parentRefs = [parent objectForKey:@"children"];
    if(parentRefs == nil) parentRefs = [[NSArray alloc] init];
    
    parentRefs = [parentRefs arrayByAddingObject:childRef];
    NSLog(@"PARENT REFRENCES:\n%@", parentRefs);
    [parent setValue:parentRefs forKey:@"children"];
    
    [publicDB saveRecord:childAudio completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"ERROR saving CHILDAUDIO! %@", [error localizedDescription]);
        }
        else {
            [publicDB saveRecord:child completionHandler:^(CKRecord *record, NSError *error) {
                if (error) {
                    NSLog(@"ERROR saving CHILD INFO! %@", [error localizedDescription]);
                }
                else {
                    [publicDB saveRecord:parent completionHandler:^(CKRecord *record, NSError *error) {
                        if (error) {
                            NSLog(@"ERROR updaing PARENT! %@", [error localizedDescription]);
                        }
                        else {
                            NSLog(@"EVERYTHING SAVED!");
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
                                [LWPScheduler masterScheduler].tempo = ops.tempo.floatValue;
                            }
                        }
                    }];
                }
            }];
        }
    }];
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

-(void) trashIt {
    [self removeFile:[LWPScheduler masterScheduler].mostRecentFilePath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if (sender==_trashItButton) {
        [self trashIt];
    }
    else if (sender == _postItButton) {
        [self saveTheChild];
    }
    [[LWPScheduler masterScheduler] stopRecentLewp];
    [[LWPScheduler masterScheduler] playAirHorn];
    [[LWPScheduler masterScheduler] playTheme];
}


@end
