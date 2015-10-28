//
//  LWPChildrenTableViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/8/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPChildrenTableViewController.h"
#import "LWPScheduler.h"
@interface LWPChildrenTableViewController ()
@property NSMutableArray* childrenRecords;
@property bool isLoading, noChildren;
@end

@implementation LWPChildrenTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"loading children...");
    _childrenRecords = [[NSMutableArray alloc] init];
    [self loadChildren];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)loadChildren {
    _isLoading = true;
    NSLog(@"hit");
    CKRecord* parentRec = [LWPScheduler masterScheduler].mostRecentRecord;
    NSArray* childRefs = [parentRec objectForKey:@"children"];
    if (childRefs.count == 0) {
        _noChildren = true;
        _isLoading = false;
        return;
    }
    NSArray* childRecordIDs = [[NSArray alloc] init];
    for(int i = 0; i<childRefs.count; i++) {
        CKReference* ref = [childRefs objectAtIndex:i];
        childRecordIDs = [childRecordIDs arrayByAddingObject:ref.recordID];
    }
    CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    CKFetchRecordsOperation* request = [[CKFetchRecordsOperation alloc] initWithRecordIDs:childRecordIDs];
    [request setPerRecordCompletionBlock:^(CKRecord * rec, CKRecordID * recID, NSError *err) {
        if (err) {
            NSLog(@"ERROR! %@", [err localizedDescription]);
        }
        else
            [_childrenRecords addObject:rec];
    }];
    [request setCompletionBlock:^{
        _isLoading = false;
        NSLog(@"Done loading children ids...\n\n%@", _childrenRecords);
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
    [publicDB addOperation:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    if(_isLoading) return 0;
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if(_isLoading) return 0;
    else return _childrenRecords.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseID = [NSString stringWithFormat:@"Cell %li", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }
    
    
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:18];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Italic" size:14];
    
    // Configure the cell...
    CKRecord* rec = [_childrenRecords objectAtIndex:indexPath.row];
    NSString* dj = [rec objectForKey:@"djtag"];
    NSDate* creationDate = [rec objectForKey:@"creationDate"];
    NSTimeInterval interval = [creationDate timeIntervalSinceNow];

    cell.textLabel.text = dj;
    cell.detailTextLabel.text = [self stringFromTimeInterval:interval];
    return cell;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = -(NSInteger)interval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld hours and %02ld minutes ago", (long)hours, (long)minutes];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CKRecord* parentRec = [_childrenRecords objectAtIndex:indexPath.row];
    CKReference* audioRef = [parentRec objectForKey:@"audio"];
    CKDatabase* publicDB = [[CKContainer defaultContainer] publicCloudDatabase];
    [publicDB fetchRecordWithID:audioRef.recordID completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", [error localizedDescription]);
        }
        [LWPScheduler masterScheduler].mostRecentRecord = record;
        CKAsset* audioFile = [record objectForKey:@"file"];
        [[LWPScheduler masterScheduler] stopRecentLewp];
        [LWPScheduler masterScheduler].mostRecentFilePath = [audioFile fileURL].path;
        [[LWPScheduler masterScheduler] playRecentLewp];
        _refreshData = YES;
    }];
}

-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 40, 450, 80);
    myLabel.font = [UIFont fontWithName:@"Zapfino" size:36];
    myLabel.textColor = [UIColor grayColor];
    myLabel.text = [self tableView:tableView titleForFooterInSection:section];
    
    UIView *footerView = [[UIView alloc] init];
    [footerView addSubview:myLabel];
    
    UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lewpRightBodyCheer"]];
    imgView.frame = CGRectMake(self.view.frame.size.width - 100, 100, 100, 100);
    [footerView addSubview:imgView];
    
    return footerView;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
