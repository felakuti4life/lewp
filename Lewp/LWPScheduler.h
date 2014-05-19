//
//  LWPScheduler.h
//  Lewp
//
//  Created by Ethan Geller on 2/17/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LWPInstrumentArrays.h"

@interface LWPMeasureBuilder : NSObject
@property NSNumber *measureLengthInMS;
@property NSArray* instrumentOrder;

-(LWPMeasureBuilder *)initWithInstrumentOrder:(NSArray*) instrumentOrder;
-(BOOL)startRecordingSession;
-(BOOL)combineLayers;
-(BOOL)recordAndMixdownLayer;

@end

@interface LWPScheduler : NSObject <AVAudioRecorderDelegate>
@property NSUInteger tempo;
@property NSString *userName;

@property BOOL isRunning;
@property BOOL isRecording;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;



+(LWPScheduler*) masterScheduler;
-(void)startPlaying;
-(NSArray*)getInstrumentOrderFromGroup: (NSUInteger)groupIndex
    andThisManyAdjectives: (NSUInteger)adjectiveCount;
-(void)recordMeasures:(NSUInteger)measures;


@end
