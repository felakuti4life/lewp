//
//  LWPInstrumentArrays.m
//  Lewp
//
//  Created by Ethan Geller on 2/18/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPInstrumentArrays.h"

@implementation LWPInstrumentArrays

+(NSArray*)drumGroup{
    return @[@"Bass Drum",
             @"Snare Drum",
             @"Hi Hats",
             @"Crash Cymbals",
             @"Tamborine",
             @"Cowbell",
             @"Auxilary Cowbell"];
}

+(NSArray*)stringGroup{
    return @[@"Electric Bass",
             @"Double Bass",
             @"Electric Guitar",
             @"Slide Guitar",
             @"Ukelele",
             @"Orchestral Strings",
             @"Cellos"
             ];
}

+(NSArray*)keyboardGroup{
    return @[@"Synths",
             @"Piano",
             @"Robot Voice",
             @"Siren FX",
             @"Electronic Sounds"
             ];
}

+(NSArray*)vocalsGroup{
    return @[@"Lead Female Vocals",
             @"Lead Male Vocals",
             @"Backup Female Vocals",
             @"Backup Male Vocals"
             ];
}

+(NSArray*)freestyleGroup{
    return @[@"Rap about your love interest!",
             @"Rap about your fans!",
             @"Rap about your dad!",
             @"Rap about your mom!",
             @"Rap about your friends!",
             @"Rap about your enemies!"
             ];
}

+(NSArray*)adjectivesGroup{
    return @[@"Beautiful",
             @"Sinister",
             @"Enormous",
             @"Majestic",
             @"Rollicking",
             @"Wondorous",
             @"Monstrous",
             @"Dubstep-esque",
             @"Trap-esque",
             @"Jazz-esque",
             @"Coffeehouse-esque",
             @"\"Hardcore\"",
             @"Futuristic",
             @"Culture-appropriating",
             @"Militaristic"
             ];
}

+(NSArray*)instrumentGroups{
    return @[[LWPInstrumentArrays drumGroup], [LWPInstrumentArrays stringGroup], [LWPInstrumentArrays keyboardGroup], [LWPInstrumentArrays vocalsGroup]];
}

@end
