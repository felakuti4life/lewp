//
//  LWPScheduler.h
//  Lewp
//
//  Created by Ethan Geller on 2/17/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CloudKit/CloudKit.h>
#import "LWPInstrumentArrays.h"
#import "LWPConstants.h"

#import "AEAudioController.h"
#import "AEAudioFilePlayer.h"
#import "AEUtilities.h"

#import "AEBlockAudioReceiver.h"

#define MAX_STACKS_PER_SONG 1
#define MAX_LEWPS_PER_STACK 8
#define NUMBER_OF_EIGTH_NOTES_PER_BUFFER 16
#define BEATS_PER_LEWP 8
#define MAXSAMPLES 4194304

@interface LWPMeasureBuilder : NSObject
@property NSNumber *measureLengthInMS;
@property NSArray* instrumentOrder;

-(LWPMeasureBuilder *)initWithInstrumentOrder:(NSArray*) instrumentOrder;
-(BOOL)startRecordingSession;
-(BOOL)combineLayers;
-(BOOL)recordAndMixdownLayer;

@end

@interface LWPScheduler : NSObject
@property NSManagedObjectContext *context;

@property float tempo;
@property NSString *userName;
@property NSString *userToken;
@property bool isUploading;
@property bool challengeMode;
@property AudioBufferList cloudBuffer;

//timing
@property float g_t;
@property int currentBeat;
@property int currentLewp;
@property int currentStack;
@property float tick;
@property bool isDone;
@property bool isWritingAudio;
@property bool fxPlaying;
@property bool voxPlaying;
@property int hornCount;

@property NSMutableArray* instrumentNames;
//audio stuff
@property (nonatomic, strong) AEAudioController *audio;

//the buffers

@property (nonatomic) AEBlockAudioReceiver *input;
@property AEBlockFilter *lewper;
@property (nonatomic) AEBlockChannel *user_output;


@property int numStacks;


//Here is a main theme!
@property AEAudioFilePlayer *theme;
@property AEAudioFilePlayer* playback;
@property AEAudioFilePlayer *vox;
@property AEAudioFilePlayer *fx;

//VERY IMPORTANT:
@property AEAudioFilePlayer *airhorn;

@property BOOL isRunning;
@property BOOL isRecording;
@property long bufferFrameCount;

@property bool userRecordGot;
@property NSString* userID;
@property CKRecord* mostRecentRecord;
@property NSString* mostRecentFilePath;
@property NSString* fileName;

//arrays:
@property NSArray* lewpYellArr, *itBangsArr, *thisIsDopeArr, *altArr, *promArr, *howBarArr, *ifItArr, *heartWarmArr, *PosArr, *banjoArr, *memeArr, *vapArr, *letsDoItArr, *sludgeArr, *kPopArr, *namesArr, *temposArr;

+(LWPScheduler*) masterScheduler;
+(NSManagedObjectContext*) getContext;
-(void)playTheme;
-(void)stopTheme;

-(void)yellLewp;
-(void)playAirHorn;
-(void)playFx: (NSString*) fx;
-(void)playVox: (NSString*) vox;
-(void)playFile: (NSString*) fpath;
-(void)stopFile;
-(void)playRecentLewp;
-(void)stopRecentLewp;
-(void)prepareToLewp;
-(void)stopLewping;
-(NSArray*)getInstrumentOrderFromGroup: (NSUInteger)groupIndex
    andThisManyAdjectives: (NSUInteger)adjectiveCount;

-(NSString*) lewpYell;
-(NSString*) itBangs;
-(NSString*) thisIsDope;
-(NSString*) alternative;
-(NSString*) promworthy;
-(NSString*) howBaroque;
-(NSString*) ifItAint;
-(NSString*) heartWarming;
-(NSString*) whatAPos;
-(NSString*) isThatABanjo;
-(NSString*) memeWorthy;
-(NSString*) vapid;
-(NSString*) letsDoIt;
-(NSString*) sludgeMetal;
-(NSString*) kPop;
-(NSString*) whatsYourName;
-(NSString*) whatsYourTempo;
-(NSString*) wearHeadphones;
-(NSString*) letsGetIt;

@end
