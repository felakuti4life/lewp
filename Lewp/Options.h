//
//  Options.h
//  Lewp
//
//  Created by Ethan Geller on 3/4/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Options : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * tempo;

@end
