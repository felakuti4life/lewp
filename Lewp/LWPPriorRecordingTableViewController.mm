//
//  LWPPriorRecordingTableViewController.m
//  Lewp
//
//  Created by Ethan Geller on 2/5/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import "LWPPriorRecordingTableViewController.h"
#import "LWPScheduler.h"
#import "PriorRecordings.h"
@interface LWPPriorRecordingTableViewController ()



@property NSArray *songList;
@property bool noSongs;

@end

@implementation LWPPriorRecordingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (IBAction)unwindToTable:(UIStoryboardSegue *)unwindSegue{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSManagedObjectContext* context = [LWPScheduler getContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PriorRecordings" inManagedObjectContext:context]];
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO]]];
    
    NSError *err;
    _songList = [context executeFetchRequest:request error:&err];
    if (err) {
        NSLog(@"ERROR GETTING RESULTS: %@",[err localizedDescription]);
    }
    
    if (_songList.count < 1) {
        NSLog(@"There are no songs!!");
        _noSongs = YES;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    //TODO: create array of Songs
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //TODO: create array of Songs
    // Return the number of rows in the section.
    if (!_noSongs) return  self.songList.count;
    else return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"BILLBOARD TOP %lu", (unsigned long)_songList.count];
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
    PriorRecordings* rec = [_songList objectAtIndex:indexPath.row];
    NSLog(@"Path: %@", [rec getAbsoluteFilePath]);
    [LWPScheduler masterScheduler].mostRecentFilePath = [rec getAbsoluteFilePath];
    [LWPScheduler masterScheduler].fileName = rec.filePath;
    [self performSegueWithIdentifier:@"detail" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //FIXME: Fill record with default lewp if no lewps are made by the user
    PriorRecordings* rec = (PriorRecordings*) _songList[indexPath.row];
    static NSString *CellIdentifier = [rec getAbsoluteFilePath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Set the data for this cell:
    
    cell.textLabel.text = [rec.songName uppercaseString];
    cell.detailTextLabel.text = rec.djtag;
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:18];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Italic" size:14];
    //cell.imageView.image = [UIImage imageNamed:@"flower.png"];
    if(rec.isChallenge) cell.imageView.image = [UIImage imageNamed:@"clowd"];
    
    // set the accessory view:
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if([sender isKindOfClass:[UITableViewCell class]]){
//        UITableViewCell* cell = (UITableViewCell*) sender;
//        [LWPScheduler masterScheduler].mostRecentFilePath = cell.reuseIdentifier;
//    }
    
}


//get files at path
-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
