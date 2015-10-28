//
//  LWPClowdDetailViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/9/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPClowdDetailViewController.h"
#import "LWPScheduler.h"
#import "AEAudioFileLoaderOperation.h"
@interface LWPClowdDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *djtagLabel;
@property (weak, nonatomic) IBOutlet UITextView *instrumentLabel;
@property (weak, nonatomic) IBOutlet UITextView *songNameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *loadingBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property CKReference* audioRef;
@property CKAsset* audioAsset;
@property bool isLoadingAudio;

@end

@implementation LWPClowdDetailViewController

- (IBAction)unwindToClowdDetatil:(UIStoryboardSegue *)unwindSegue{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CKRecord* rec = [LWPScheduler masterScheduler].mostRecentRecord;
    _djtagLabel.text = (NSString*) [rec objectForKey:@"djtag"];
    _instrumentLabel.text = (NSString*) [rec objectForKey:@"instrument"];
    _songNameLabel.text = (NSString*) [rec objectForKey:@"name"];
    _djtagLabel.font = _instrumentLabel.font = _songNameLabel.font = [UIFont fontWithName:@"Helvetica Neue Bold" size:19.0];
    _djtagLabel.textColor = _instrumentLabel.textColor = _songNameLabel.textColor = [UIColor whiteColor];
    
    
    _audioRef = (CKReference*) [rec objectForKey:@"audio"];
    [self fetchAudio];
}

-(void) fetchAudio {
    _isLoadingAudio = YES;
    [_recordButton setEnabled:NO];
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* publicDB = [container publicCloudDatabase];
    CKFetchRecordsOperation* request = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[_audioRef.recordID]];
    
    [request setPerRecordProgressBlock:^(CKRecordID * audio, double prog) {
        NSLog(@"Progress: %f", prog);
        [self.loadingBar performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithDouble:prog] waitUntilDone:YES];
        //_loadingBar.progress = prog;
    }];
    [request setPerRecordCompletionBlock:^(CKRecord * rec, CKRecordID * recID, NSError *err) {
        if(err) {
            NSLog(@"ERROR: Couldn't get audio: %@", [err localizedDescription]);
        }
        else {
            _audioAsset = (CKAsset*) [rec objectForKey:@"file"];
            NSLog(@"Audio file downloaded to: %@", [_audioAsset fileURL].path);
            [LWPScheduler masterScheduler].mostRecentFilePath = [_audioAsset fileURL].path;
            [[LWPScheduler masterScheduler] stopTheme];
            [[LWPScheduler masterScheduler] playRecentLewp];
        }
    }];
    [request setCompletionBlock:^{
        _isLoadingAudio = NO;
        [self performSelectorOnMainThread:@selector(setLoadingBar:) withObject:[NSNumber numberWithDouble:1.0] waitUntilDone:YES];
        //_loadingBar.progress = 1.0;
        //[_recordButton setTitle:@"RECORD IT" forState:UIControlStateNormal];
        [self performSelectorOnMainThread:@selector(setButtonTitle:) withObject:@"RECORD IT" waitUntilDone:YES];
        
    }];
    [publicDB addOperation:request];
}

-(void) setButtonTitle: (NSString*) title {
    [_recordButton setTitle:title forState:UIControlStateNormal];
    [_recordButton setEnabled:YES];
}

-(void) setLoadProgress: (NSNumber*) prog {
    float x = prog.floatValue;
    [_loadingBar setProgress:x];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [[LWPScheduler masterScheduler] stopRecentLewp];
    if(sender == _recordButton) {
        [self recordToBufferList];
    }
    else
        [[LWPScheduler masterScheduler] playTheme];
}

-(void) recordToBufferList{
    AudioStreamBasicDescription description = streamDesc_floatNonInterleaved(2);
    AEAudioFileLoaderOperation* loader = [[AEAudioFileLoaderOperation alloc] initWithFileURL:[_audioAsset fileURL] targetAudioDescription:description];
    [loader start];
    if (loader.error) {
        NSLog(@"ERROR LOADING AUDIO: %@", [loader.error localizedDescription]);
    }
    else {
        [LWPScheduler masterScheduler].cloudBuffer = *(loader.bufferList);
    }
    
}

AudioStreamBasicDescription streamDesc_floatNonInterleaved( uint32_t channels )
{
    const int sampRate = 44100;
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    
    // other members init'd to 0
    AudioStreamBasicDescription dataFormat = (AudioStreamBasicDescription)
    {
        .mSampleRate = sampRate,
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
        .mBytesPerPacket = four_bytes_per_float,
        .mFramesPerPacket = 1,
        .mBytesPerFrame = four_bytes_per_float,
        .mChannelsPerFrame = channels,
        .mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte
    };
    
    return dataFormat;
}

@end
