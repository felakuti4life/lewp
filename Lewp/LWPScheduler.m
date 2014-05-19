//
//  LWPScheduler.m
//  Lewp
//
//  Created by Ethan Geller on 2/17/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//
//  The LWPScheduler MasterScheduler is used to line up four LWPMeasureBuilders, each of which contain four instrument layers
//  each of which is continuously recorded and then layer said recording onto the looped buffer played in the background.
//  each of these four 


#import "LWPScheduler.h"


/*************************
    LWPMeasureBuilder
 ***************************/
@implementation LWPMeasureBuilder



-(LWPMeasureBuilder*)initWithInstrumentOrder:(NSArray *)instrumentOrder{
    self = [super init];
    if(self){
        self.instrumentOrder = instrumentOrder;
        self.measureLengthInMS = [[NSNumber alloc] initWithDouble:((1/[LWPScheduler masterScheduler].tempo)*4000)];
    }
    return self;
}

-(BOOL)startRecordingSession{
    //TODO: Implement
    return YES;
}

-(BOOL)combineLayers{
    //TODO:Implement
    return YES;
}

-(BOOL)recordAndMixdownLayer{
    //TODO: Impelement
    return YES;
}
@end


/*************************
        LWPScheduler
***************************/
@implementation LWPScheduler
@synthesize tempo;
@synthesize userName;

//Number of measures before crazy adjectives start getting thrown in the adjective names:
int adjectiveThreshold = 2;

+(LWPScheduler *)masterScheduler{
    static LWPScheduler *masterScheduler = nil;
    if (masterScheduler == nil)
    {
        masterScheduler = [[self alloc] init];
    }

    return masterScheduler;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.tempo = 120;
        self.userName = @"Tim Burland";
    }
    return self;
}

-(void)prepareToRecord{
    //recording init
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"recordingBuffer.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    //audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //recorder settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
}

-(void)startPlaying{
    //TODO: Implement
    
}

-(NSArray*) getInstrumentOrderFromGroup:(NSUInteger)groupIndex andThisManyAdjectives:(NSUInteger)adjectiveCount {
    
    NSArray* thisInstrumentArray = [NSArray array];
    NSMutableArray* orderedInstrumentArray = [NSMutableArray array];
    
    switch (groupIndex) {
        case 0:
            thisInstrumentArray = [LWPInstrumentArrays drumGroup];
            break;
            
        case 1:
            thisInstrumentArray = [LWPInstrumentArrays stringGroup];
            
        case 2:
            thisInstrumentArray = [LWPInstrumentArrays keyboardGroup];
            
        case 3:
            thisInstrumentArray = [LWPInstrumentArrays vocalsGroup];
                                   
        default:
            NSLog(@"Not an appropriate index. The indices are as follows:\n0\tdrumGroup\n1\tstringGroup\n2\tkeyboardGroup\n3\tvocalsGroup");
            break;
    }
    
    //GET A SCRAMBLED ORDER OF FOUR INSTRUMENTS:
    
    //first, get an element
    NSUInteger idxOne = arc4random_uniform(thisInstrumentArray.count);
    [orderedInstrumentArray arrayByAddingObject:[thisInstrumentArray objectAtIndex:idxOne]];
    
    NSUInteger idxTwo = idxOne;
    //keep pulling random number you get a new one
    while (idxTwo == idxOne)
        idxTwo = arc4random_uniform(thisInstrumentArray.count);
    
    [orderedInstrumentArray arrayByAddingObject:[thisInstrumentArray objectAtIndex:idxTwo]];
    
    NSUInteger idxThree = idxOne;
    
    while (idxThree == idxTwo || idxThree == idxOne)
        idxThree = arc4random_uniform(thisInstrumentArray.count);
    
    [orderedInstrumentArray arrayByAddingObject:[thisInstrumentArray objectAtIndex:idxThree]];
    
    NSUInteger idxFour = idxOne;
    
    while (idxFour == idxThree || idxFour == idxTwo || idxFour == idxOne)
        idxFour = arc4random_uniform(thisInstrumentArray.count);
    
    [orderedInstrumentArray arrayByAddingObject:[thisInstrumentArray objectAtIndex:idxFour]];
    
    //ADD ADJECTIVES:
    for (int adjectives = adjectiveCount; adjectives >  0; adjectives--) {
        for (int i = 0; i < orderedInstrumentArray.count; i++)
            [orderedInstrumentArray setObject:[[[LWPInstrumentArrays adjectivesGroup]
                                                 objectAtIndex:arc4random_uniform([LWPInstrumentArrays adjectivesGroup].count)]
                                                stringByAppendingString:[orderedInstrumentArray objectAtIndex:i]]
                                                atIndexedSubscript:i];
        
    }
    return orderedInstrumentArray;
}

-(void)recordMeasures:(NSUInteger)numberOfMeasures{
    //TODO: Implement
    NSMutableArray* measures = [NSArray array];
    for(int i = numberOfMeasures; i > 0; i--){
        if (i<adjectiveThreshold)
            [measures addObject:[[LWPScheduler masterScheduler] getInstrumentOrderFromGroup:i%3 andThisManyAdjectives:0]];
        else
            [measures addObject:[[LWPScheduler masterScheduler] getInstrumentOrderFromGroup:i%3 andThisManyAdjectives:i-adjectiveThreshold]];
    }
    
    [[LWPScheduler masterScheduler] prepareToRecord];
}

@end
