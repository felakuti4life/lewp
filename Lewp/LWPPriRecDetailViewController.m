//
//  LWPPriRecDetailViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/5/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPPriRecDetailViewController.h"
#import "PriorRecordings.h"
#import "LWPScheduler.h"
@interface LWPPriRecDetailViewController ()
@property NSManagedObjectContext* context;
@property PriorRecordings* song;

@property (weak, nonatomic) IBOutlet UITextView *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *helpDetail;


@property bool isChallenge;

@end

@implementation LWPPriRecDetailViewController

- (IBAction)unwindToDetail:(UIStoryboardSegue *)unwindSegue{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //get file
    NSString* fpath = [LWPScheduler masterScheduler].fileName;
    _context = [LWPScheduler getContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PriorRecordings" inManagedObjectContext:_context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filePath == %@", fpath];
    [request setPredicate:predicate];
    
    NSError *err;
    NSArray *results = [_context executeFetchRequest:request error:&err];
    if (err) {
        NSLog(@"ERROR GETTING RESULTS: %@",[err localizedDescription]);
    }
    _song = [results objectAtIndex:0];
    _titleLabel.text = _song.songName;
    _nameLabel.text = _song.djtag;
    
    //change help button to a show children button if it is a challenge
    if(_song.isChallenge) {
        [_helpButton setTitle:@"CHECK CLOWD PROGRESS" forState:UIControlStateNormal];
        _helpDetail.text = @"Check if anyone has recorded your challenge";
        [_helpDetail setTextColor:[UIColor whiteColor]];

        _isChallenge = YES;
    }
    
    //play song
    [[LWPScheduler masterScheduler] stopTheme];
    [[LWPScheduler masterScheduler] playRecentLewp];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leakPressed:(id)sender {
}

- (IBAction)trashPressed:(id)sender {
}


- (IBAction)helpPressed:(id)sender {
    if(!_isChallenge){
        [self performSegueWithIdentifier:@"challenge" sender:self];
    }
    else {
        //TODO: View Children view
        [_helpButton setTitle:@"Loading..." forState:UIControlStateNormal];
        CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
        [publicDB fetchRecordWithID:[[CKRecordID alloc] initWithRecordName:_song.cloudID] completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"Error loading record!");
            }
            else {
                [_helpButton setTitle:@"CHECK CLOWD PROGRESS" forState:UIControlStateNormal];
                [LWPScheduler masterScheduler].mostRecentRecord = record;
                [self performSegueWithIdentifier:@"children" sender:self];
            }
        }];
        
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if(sender == _doneButton){
        [[LWPScheduler masterScheduler] stopRecentLewp];
        [[LWPScheduler masterScheduler] playTheme];
    }
    
}


@end
