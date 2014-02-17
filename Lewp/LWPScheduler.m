//
//  LWPScheduler.m
//  Lewp
//
//  Created by Ethan Geller on 2/17/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPScheduler.h"

@implementation LWPMeasureBuilder
-(LWPMeasureBuilder*)initWithInstrumentOrder:(NSArray *)instrumentOrder{
    self.instrumentOrder = instrumentOrder;
    self.measureLengthInMS = [[NSNumber alloc] initWithDouble:((1/[LWPScheduler masterScheduler].tempo)/4)];
    
    return self;
}

-(void)recordAndMixdownLayer{
    
    
}
@end


@implementation LWPScheduler
@synthesize tempo;
@synthesize userName;

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

@end
