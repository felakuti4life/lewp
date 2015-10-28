//
//  LWPClowdTableViewController.h
//  Lewp
//
//  Created by Ethan Geller on 3/8/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@interface LWPClowdTableViewController : UITableViewController
@property bool showFriendsList, isLoading;

-(void) refreshTable;

@end