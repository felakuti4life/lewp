//
//  PriorRecordings.m
//  Lewp
//
//  Created by Ethan Geller on 3/4/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "PriorRecordings.h"
#import "LWPScheduler.h"

@implementation PriorRecordings

@dynamic dateCreated;
@dynamic filePath;
@dynamic songName;
@dynamic tempo;
@dynamic djtag;
@dynamic isChallenge;
@dynamic cloudID;

-(NSString*) getAbsoluteFilePath {
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"FILE PATH:\n%@", [documentsFolder stringByAppendingPathComponent:self.filePath]);
    return [documentsFolder stringByAppendingPathComponent:self.filePath];
}

@end
