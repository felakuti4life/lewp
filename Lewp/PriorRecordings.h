//
//  PriorRecordings.h
//  Lewp
//
//  Created by Ethan Geller on 3/4/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PriorRecordings : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * songName;
@property (nonatomic, retain) NSNumber * tempo;
@property (nonatomic, retain) NSString * djtag;
@property (nonatomic, retain) NSNumber * isChallenge;
@property (nonatomic, retain) NSString * cloudID;

-(NSString*) getAbsoluteFilePath;

@end
