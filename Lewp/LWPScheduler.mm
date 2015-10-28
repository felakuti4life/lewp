//
//  LWPScheduler.m
//  Lewp
//
//  Created by Ethan Geller on 2/17/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//
//  The LWPScheduler MasterScheduler is used to line up four LWPMeasureBuilders, each of which contain four instrument layers
//  each of which is continuously recorded and then layer said recording onto the looped buffer played in the background.
//  each of these four 


#import "LWPScheduler.h"
#define ADDITIONAL_LATENCY 876
#define MAX_HORN_BLASTS 12


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
@synthesize context = _context;

@synthesize tempo = _tempo;
@synthesize userName = _userName;

@synthesize audio = _audio;
@synthesize theme = _theme;

float summingBuffer[MAXSAMPLES] = {0};
float outputBuffer[MAXSAMPLES] = {0};
float playbackBuffers[MAX_STACKS_PER_SONG][MAXSAMPLES] = { {0} };

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

+(NSManagedObjectContext*) getContext {
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

- (id)init
{
    self = [super init];
    if (self) {
        _userRecordGot = NO;
        //MARK: ARRAYS of AUDIO NAMES
        _lewpYellArr = @[@"/lewp1.caf", @"/lewp2.caf", @"/lewp3.caf", @"/lewp4.caf", @"/lewp5.caf"];
        _itBangsArr = @[@"/itBangs1.caf", @"/itBangs2.caf", @"/itBangs3.caf", @"/itBangs4.caf"];
        _thisIsDopeArr = @[@"/thisIsDope1.caf", @"/thisIsDope2.caf", @"/thisIsDope3.caf", @"/thisIsDope4.caf"];
        _altArr = @[@"/alternative1.caf", @"/alternative2.caf", @"/alternative3.caf", @"/alternative4.caf"];
        _promArr = @[@"/promworthy1.caf", @"/promworthy2.caf", @"/promworthy3.caf", @"/promworthy4.caf", @"/promworthy5.caf"];
        _howBarArr = @[@"/howBaroque1.caf", @"/howBaroque2.caf", @"/howBaroque3.caf", @"/howBaroque4.caf", @"/howBaroque5.caf"];
        _ifItArr = @[@"/ifItAint1.caf", @"/ifItAint2.caf", @"/ifItAint3.caf", @"/ifItAint4.caf"];
        _heartWarmArr = @[@"/heartWarming1.caf", @"/heartWarming2.caf", @"/heartWarming3.caf", @"/heartWarming4.caf", @"/heartWarming5.caf"];
        _PosArr = @[@"/whatAPositive1.caf", @"/whatAPositive2.caf", @"/whatAPositive3.caf", @"/whatAPositive4.caf", @"/whatAPositive5.caf", @"/whatAPositive6.caf", @"/whatAPositive7.caf", @"/whatAPositive8.caf"];
        _banjoArr = @[@"/banjo1.caf", @"/banjo2.caf", @"/banjo3.caf", @"/banjo4.caf"];
        _memeArr = @[@"/meme1.caf", @"/meme2.caf", @"/meme3.caf", @"/meme4.caf", @"/meme5.caf"];
        _vapArr = @[@"/vapid1.caf", @"/vapid2.caf", @"/vapid3.caf", @"/vapid4.caf", @"/vapid5.caf", @"/vapid6.caf"];
        _letsDoItArr = @[@"/letsdoit1.caf", @"/letsdoit2.caf", @"/letsdoit3.caf", @"/letsdoit4.caf", @"/letsdoit5.caf", @"/letsdoit6.caf", @"/letsdoit7.caf", @"/letsdoit8.caf", @"/letsdoit9.caf"];
        _sludgeArr = @[@"/sludgeMetal1.caf", @"/sludgeMetal2.caf"];
        _kPopArr = @[@"/kpop1.caf", @"/kpop2.caf"];
        _namesArr = @[@"/whatsYourName.caf", @"/name2.caf"];
        _temposArr = @[@"/tempos1.caf", @"/tempos2.caf"];
        
        //MARK: REST OF INIT
        self.tempo = 120;
        self.userName = @"Tim Burland";
        _instrumentNames = [[NSMutableArray alloc] init];
        for (int i = 0; i< MAX_LEWPS_PER_STACK*MAX_STACKS_PER_SONG/3+3; i++) {
            int x = arc4random_uniform(4);
            int adj = arc4random_uniform(2);
            NSArray* arr = [self getInstrumentOrderFromGroup:x andThisManyAdjectives:adj];
            for(int k = 0; k< 3; k++){
                [_instrumentNames addObject:[arr objectAtIndex:k]];
            }
        }
        NSLog(@"instruments:%@", _instrumentNames);
        self.audio = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleavedFloatStereoAudioDescription] inputEnabled:YES];
        [self prepareAudio];
    }
    return self;
}

-(void)prepareAudio{
    NSError *error = NULL;
    _audio.preferredBufferDuration = AEConvertFramesToSeconds(_audio, 128);
    BOOL result = [_audio start:&error];
    if ( !result ) {
        NSLog(@"This audio engine sucks!");
    }
    
}
-(void)playTheme{
    NSURL *file = [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/mainTheme.caf"]];
    self.theme = [AEAudioFilePlayer audioFilePlayerWithURL:file
                                          audioController:_audio
                                                    error:NULL];
    self.theme.loop = YES;
    self.theme.volume= 0.3;
    [self.audio addChannels:@[self.theme]];
    
}

-(void)stopTheme{
    [self.audio removeChannels:@[self.theme]];
    self.theme = NULL;
}

-(void)playFx:(NSString *)fx{

    __weak typeof(self) wSelf = self;
    NSURL *file = [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:fx]];
    self.fx = [AEAudioFilePlayer audioFilePlayerWithURL:file audioController:_audio error:NULL];
    _fxPlaying = true;
    _fx.completionBlock=^{_fxPlaying = false;};
    [self.audio addChannels:@[self.fx]];
    
}

-(void)playVox:(NSString *)vox{

    __weak typeof(self) wSelf = self;
    NSURL *file = [NSURL URLWithString:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:vox]];
    self.vox = [AEAudioFilePlayer audioFilePlayerWithURL:file audioController:_audio error:NULL];
    _voxPlaying = true;
    _vox.completionBlock=^{_voxPlaying = false;};
    [self.audio addChannels:@[self.vox]];
}

-(void)playAirHorn{
    [self playFx:@"/airhorn.wav"];
    NSTimer* hornTimer = [NSTimer timerWithTimeInterval:(0.2f) target:self selector:@selector(runItBack:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:hornTimer forMode:NSDefaultRunLoopMode];
}

-(void)playFile: (NSString*) fpath {
    NSString* escapedPath = [fpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * file = [NSURL URLWithString:escapedPath];
    self.playback = [AEAudioFilePlayer audioFilePlayerWithURL:file audioController:_audio error:nil];
    self.playback.loop = true;
    [self.audio addChannels:@[self.playback]];
    
}
-(void) stopFile {
    [self.audio removeChannels:@[self.playback]];
    self.playback = NULL;
}

-(void)playRecentLewp {
    [self playFile:_mostRecentFilePath];
}

-(void)stopRecentLewp {
    [self stopFile];
}

-(void)runItBack:(NSTimer*)theTimer{
    if(arc4random_uniform(4)>1 && _hornCount<=MAX_HORN_BLASTS) {
        _fx.currentTime = 0;
        _hornCount++;
    }
    
}

-(void)prepareToLewp{
    //__weak typeof(self) wSelf = self;
    //set up timing
    _bufferFrameCount = AEConvertSecondsToFrames(_audio, (1/(self.tempo/60))*BEATS_PER_LEWP);
    __block int n = 0;
    __block int k = 0;
    __block int samplesPerBeat = AEConvertSecondsToFrames(_audio, (1/(self.tempo/60)));
    
    __block int latency = _audio.inputLatency + _audio.outputLatency + ADDITIONAL_LATENCY;
    
    //clear everything
    _currentBeat = 0;
    _currentStack = 0;
    _currentLewp = 0;
    _isDone = NO;
    memset(summingBuffer, 0, MAXSAMPLES);
    memset(outputBuffer, 0, MAXSAMPLES);
    if(_challengeMode) {
        float* clowdAudio =(float*)(_cloudBuffer.mBuffers[0].mData);
        memcpy(summingBuffer, clowdAudio, samplesPerBeat*BEATS_PER_LEWP*sizeof(float));
        memcpy(playbackBuffers[0], clowdAudio, samplesPerBeat*BEATS_PER_LEWP*sizeof(float));
        memcpy(outputBuffer, clowdAudio, samplesPerBeat*BEATS_PER_LEWP*sizeof(float));
    }
    NSLog(@"Buffer frame count: %ld", _bufferFrameCount);
    NSLog(@"%ld", _bufferFrameCount/(samplesPerBeat*BEATS_PER_LEWP));
    _input = [AEBlockAudioReceiver audioReceiverWithBlock:^(void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        for (int i = 0; i < frames; i++) {
            //timing stuff
            if(n % samplesPerBeat==0){
                _currentBeat++;
                outputBuffer[n] = 0.5;
            }
            
            if(_currentBeat == BEATS_PER_LEWP){
                memcpy(outputBuffer, summingBuffer, _bufferFrameCount*sizeof(float));
                outputBuffer[n] = 0.9;
                n=0;
                _currentBeat=0;
                _currentLewp++;
            }
            
            if(_currentLewp == MAX_LEWPS_PER_STACK){
                //throw it in the playbackBuffers
                memcpy(playbackBuffers[_currentStack],summingBuffer, _bufferFrameCount*sizeof(float));
                
                //zero out summing buffer
                memset(summingBuffer, 0, _bufferFrameCount*sizeof(float));
                memset(outputBuffer, 0, _bufferFrameCount*sizeof(float));
                _currentStack++;
                _currentLewp = 0;
            }
            
            if(_currentStack == MAX_STACKS_PER_SONG){
                _isDone = true;
                
            }
            
            summingBuffer[n] = summingBuffer[n] + ((float*) audio->mBuffers[0].mData)[i];
            _g_t++;
            n++;
            //_tick = ((float)(n % samplesPerBeat)) / samplesPerBeat;
        }
    }];
    
    _user_output = [AEBlockChannel channelWithBlock:^(const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
        for (int i = 0; i < frames; i++) {
            if(k==_bufferFrameCount) k=0;
            int lat_k = k - latency;
            if (lat_k>=0) {
                ((float*)audio->mBuffers[0].mData)[i] = outputBuffer[lat_k];
                ((float*)audio->mBuffers[1].mData)[i] = outputBuffer[lat_k];
            }
            else{
                ((float*)audio->mBuffers[0].mData)[i] = 0;
                ((float*)audio->mBuffers[1].mData)[i] = 0;
            }
            k++;
        }
    }];
    
    //MARK: routing
    [_audio addInputReceiver:_input];
    [_audio addChannels:@[_user_output]];
}

//method that cleans up if the panic button was pressed
-(void) lewpPanicked {
    
}

-(void) stopLewping {
    [_audio removeChannels:@[_user_output]];
    [_audio removeInputReceiver:_input];
    //write out the audio!
    _isWritingAudio = true;
    
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _fileName = [NSString stringWithFormat:@"%@-%@.m4a", _userName, [NSDate date]];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:_fileName];
    
    NSError* err = nil;
    AEAudioFileWriter* writer = [[AEAudioFileWriter alloc] initWithAudioDescription:_audio.audioDescription];
    [writer beginWritingToFileAtPath:filePath fileType:kAudioFileM4AType error:&err];
    if(err) {
        NSLog(@"ALERT: Failed to write %@", filePath);
    }
    
    UInt32 lengthInFrames = _bufferFrameCount*MAX_STACKS_PER_SONG;
    AudioBufferList *bufferList = AEAllocateAndInitAudioBufferList( streamDesc_floatNonInterleaved(2), lengthInFrames);
    float *bufL = (float*)bufferList->mBuffers[0].mData;
    float *bufR = (float*)bufferList->mBuffers[1].mData;
    int i = 0;
    for (int k = 0; k < MAX_STACKS_PER_SONG; k++) {
        for (int l = 0; l < _bufferFrameCount; l++) {
            bufL[i]=playbackBuffers[k][l];
            bufR[i]=playbackBuffers[k][l];
            i++;
        }
    }
    OSStatus stat = AEAudioFileWriterAddAudioSynchronously(writer, bufferList, lengthInFrames);
    NSLog(@"Closing up the file!");
    [writer finishWriting];
    _isWritingAudio = NO;
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:stat userInfo:nil];
    NSLog(@"File written at %@\nRESULT:\n%@", filePath, [error localizedDescription]);
    _mostRecentFilePath = filePath;
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

-(NSArray*) getInstrumentOrderFromGroup:(int) groupIndex andThisManyAdjectives:(int) adjectiveCount {
    
    NSArray* thisInstrumentArray = [NSArray array];
    NSMutableArray* orderedInstrumentArray = [NSMutableArray array];
    switch (groupIndex) {
        case 0:
            thisInstrumentArray = [LWPInstrumentArrays drumGroup];
            break;
            
        case 1:
            thisInstrumentArray = [LWPInstrumentArrays stringGroup];
            break;
            
        case 2:
            thisInstrumentArray = [LWPInstrumentArrays keyboardGroup];
            break;
            
        case 3:
            thisInstrumentArray = [LWPInstrumentArrays vocalsGroup];
            break;
                                   
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
    
    [orderedInstrumentArray addObject:[thisInstrumentArray objectAtIndex:idxTwo]];

    NSUInteger idxThree = idxOne;

    while (idxThree == idxTwo || idxThree == idxOne)
        idxThree = arc4random_uniform(thisInstrumentArray.count);
    
    [orderedInstrumentArray addObject:[thisInstrumentArray objectAtIndex:idxThree]];
    
    NSUInteger idxFour = idxOne;

    while (idxFour == idxThree || idxFour == idxTwo || idxFour == idxOne)
        idxFour = arc4random_uniform(thisInstrumentArray.count);
    
    [orderedInstrumentArray addObject:[thisInstrumentArray objectAtIndex:idxFour]];
    
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

-(NSString*) lewpYell {
    return [_lewpYellArr objectAtIndex:arc4random_uniform(_lewpYellArr.count)];
}

-(NSString*) itBangs {
    return [_itBangsArr objectAtIndex:arc4random_uniform(_itBangsArr.count)];
}

-(NSString*) thisIsDope {
    return [_thisIsDopeArr objectAtIndex:arc4random_uniform(_thisIsDopeArr.count)];
}

-(NSString*) alternative {
    return [_altArr objectAtIndex:arc4random_uniform(_altArr.count)];
}

-(NSString*) promworthy {
    return [_promArr objectAtIndex:arc4random_uniform(_promArr.count)];
}

-(NSString*) howBaroque {
    return [_howBarArr objectAtIndex:arc4random_uniform(_howBarArr.count)];
}

-(NSString*) ifItAint {
    return [_ifItArr objectAtIndex:arc4random_uniform(_ifItArr.count)];
}

-(NSString*) heartWarming {
    return [_heartWarmArr objectAtIndex:arc4random_uniform(_heartWarmArr.count)];
}

-(NSString*) whatAPos {
    return [_PosArr objectAtIndex:arc4random_uniform(_PosArr.count)];
}

-(NSString*) isThatABanjo {
    return [_banjoArr objectAtIndex:arc4random_uniform(_banjoArr.count)];
}

-(NSString*) memeWorthy {
    return [_memeArr objectAtIndex:arc4random_uniform(_memeArr.count)];
}

-(NSString*) vapid {
    return [_vapArr objectAtIndex:arc4random_uniform(_vapArr.count)];
}

-(NSString*) letsDoIt {
    return [_letsDoItArr objectAtIndex:arc4random_uniform(_letsDoItArr.count)];
}

-(NSString*) sludgeMetal {
    return [_sludgeArr objectAtIndex:arc4random_uniform(_sludgeArr.count)];
}

-(NSString*) kPop {
    return [_kPopArr objectAtIndex:arc4random_uniform(_kPopArr.count)];
}

-(NSString*) whatsYourName {
    return [_namesArr objectAtIndex:arc4random_uniform(_namesArr.count)];
}

-(NSString*) whatsYourTempo {
    return [_temposArr objectAtIndex:arc4random_uniform(_temposArr.count)];
}

-(NSString*) wearHeadphones {
    return @"/headphones.caf";
}

-(NSString*) letsGetIt {
    return @"/getit.caf";
}
@end
