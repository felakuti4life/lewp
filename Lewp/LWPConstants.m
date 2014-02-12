//
//  LWPConstants.m
//  Lewp
//
//  Created by Ethan Geller on 2/11/14.
//  Copyright (c) 2014 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPConstants.h"

@implementation LWPConstants

+(NSArray*) adviceList{
    return @[
             @"All this song needs is an awards show controversy.",
             @"Are you sure about all of these hi hats?",
             @"Maybe your most recent divorce can inspire this beat.",
             @"You're going to take the singer songwriter genre by storm.",
             @"Are you ever going to finish that solo album you were working on?",
             @"I cannot for the life of me figure out how record labels actually make a profit.",
             @"Nobody asked for a guitar solo at the end of this song.",
             @"I don't know why you called this guy in, he is a terrible rapper.",
             @"This is not a concept album. There is no concept tying this album together. Stop calling it that."
             ];
}

+(Sound*) mainTheme{
    return [Sound soundWithContentsOfFile:@"Lewp/mainTheme.caf"];
}

@end
