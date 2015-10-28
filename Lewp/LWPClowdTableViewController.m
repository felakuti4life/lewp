//
//  LWPClowdTableViewController.m
//  Lewp
//
//  Created by Ethan Geller on 3/8/15.
//  Copyright (c) 2015 Ethan Geller and Kevin Choumane. All rights reserved.
//

#import "LWPClowdTableViewController.h"
#import "LWPScheduler.h"
@interface LWPClowdTableViewController ()
@property NSMutableArray* globalLewps;
@property NSDictionary* friendLewps;
@property CKQueryCursor* globalCursor;
@property CKQueryCursor* friendsCursor;
@property bool noFriends, outOfRecords;
@property int totalFriendRows;
@end

@implementation LWPClowdTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _globalLewps = [[NSMutableArray alloc] init];
    _friendLewps = [[NSDictionary alloc] init];
    
    NSLog(@"Loading...");
    [self fetchGlobalData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if(_isLoading) return 1;
    else if (_showFriendsList) {
        //TODO: add sections for
        if (_noFriends)
            return 1;
        
    }
    else {
        
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_isLoading) return 1;
    else if (_showFriendsList) {
        if(_noFriends) return 1;
    }
    else {
        if(_globalLewps.count > 0) return  _globalLewps.count;
        else return 1;
    }
    return 0;
}

-(void) refreshTable {
    
    if(_showFriendsList) {
        [self fetchFriendData];
    }
    else {
        [self fetchGlobalData];
    }
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(void) fetchFriendData {
    _isLoading = YES;
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* publicDB = [container publicCloudDatabase];
    
    NSLog(@"LOADING USER INFOS...");
    [container discoverAllContactUserInfosWithCompletionHandler:^(NSArray *userInfos, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", [error localizedDescription]);
        }
        else {
            if (userInfos.count == 0) {
                NSLog(@"WARNING! NO FRIENDS!");
            }
            
            for (int i = 0; i< userInfos.count; i++) {
                CKDiscoveredUserInfo* userInfo = [userInfos objectAtIndex:i];
                NSLog(@"%@", userInfo);
            }
        }
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
}

-(void) fetchGlobalData {
    _isLoading = YES;
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* publicDB = [container publicCloudDatabase];
    
    NSLog(@"LOADING GLOBAL INFOS...");
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    CKQuery* query = [[CKQuery alloc] initWithRecordType:@"Challenges" predicate:predicate];
    [query setSortDescriptors:@[sort]];
    CKQueryOperation* request;
    if(_globalCursor == nil) request = [[CKQueryOperation alloc] initWithQuery:query];
    else request = [[CKQueryOperation alloc] initWithCursor:_globalCursor];
    [request setResultsLimit:10];
    [request setRecordFetchedBlock:^(CKRecord *record) {
        [_globalLewps addObject:record];
        NSLog(@"HERE'S A RECORD:\n%@", record);
    }];
    [request setQueryCompletionBlock:^(CKQueryCursor *cursor, NSError *err) {
        if (err) {
            NSLog(@"ERROR: %@", [err localizedDescription]);
        }
        else {
            if (!cursor) {
                NSLog(@"Reached end of global table");
                _outOfRecords = YES;
            }
            else {
                NSLog(@"Global cursor: %@", cursor);
                _globalCursor = cursor;
            }
        }
        NSLog(@"Done!");
        _isLoading = NO;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    if (_globalCursor) {
        request.cursor = _globalCursor;
    }
    
    
    [publicDB addOperation:request];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseID = [NSString stringWithFormat:@"row %ld", (long)indexPath.row];
    CKRecord* rec;
    if (_showFriendsList) {
        if (_noFriends) {
            reuseID = @"nofriends";
        }
        else {
            
        rec = [_friendLewps objectForKey:@""];
            reuseID = rec.recordID.recordName;
        }
    }
    else if (!_isLoading) {
        rec = [_globalLewps objectAtIndex:indexPath.row];
        reuseID = rec.recordID.recordName;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }
    
    
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:18];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Italic" size:14];
    //cell.imageView.image = [UIImage imageNamed:@"flower.png"];
    
    // set the accessory view:
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    if (_isLoading) {
        cell.textLabel.text = @"LOADING...";
        cell.detailTextLabel.text = @"Please wait...";
        
    }
    else if (_showFriendsList) {
        if (_noFriends) {
            cell.textLabel.text = @"NO FRIENDS";
            cell.detailTextLabel.text = @"You don't have any friends that LEWP hard enough.";
        }
        else {
            NSString* title = (NSString*) [rec objectForKey:@"instrument"];
            cell.textLabel.text = [title uppercaseString];
            NSString* djtag = (NSString*) [rec objectForKey:@"djtag"];
            cell.detailTextLabel.text = djtag;
        }
    }
    else {
        NSString* title = (NSString*) [rec objectForKey:@"instrument"];
        cell.textLabel.text = [title uppercaseString];
        NSString* djtag = (NSString*) [rec objectForKey:@"djtag"];
        cell.detailTextLabel.text = djtag;
    }
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [LWPScheduler masterScheduler].userName;
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_showFriendsList); //[LWPScheduler masterScheduler].mostRecentRecord = [_friendLewps objectAtIndex:indexPath.row];
    else [LWPScheduler masterScheduler].mostRecentRecord = [_globalLewps objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"clowdSong" sender:self];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if(y > h + reload_distance) {
        NSLog(@"load more rows");
        if (!_showFriendsList) {
            if(_globalCursor && !_outOfRecords) {
                [self fetchGlobalData];
            }
        }
        else {
            if (_friendsCursor) {
                [self fetchFriendData];
            }
        }
    }
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
