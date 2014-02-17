//
//  LWPScheduler.h
//  Lewp
//
//  Created by Ethan Geller on 2/17/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LWPMeasureBuilder : NSObject
@property NSNumber *measureLengthInMS;
@property NSArray* instrumentOrder;
@property AVAudioRecorder *layerRecorder;

-(LWPMeasureBuilder *)initWithInstrumentOrder:(NSArray*) instrumentOrder;
-(void)startRecordingSession;
-(void)mixdownLayers;
-(void)recordAndMixdownLayer;


@end

@interface LWPScheduler : NSObject
@property NSUInteger tempo;
@property NSString *userName;

@property BOOL isRunning;
@property BOOL isRecording;

+(LWPScheduler*) masterScheduler;
-(void)startPlaying;
-(NSArray*)getInstrumentOrderWithThisManyAdjectives:(NSUInteger)adjectiveCount;
-(void)recordMeasures:(NSUInteger)measures;


@end
