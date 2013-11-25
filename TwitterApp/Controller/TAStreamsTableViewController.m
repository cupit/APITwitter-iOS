//
//  TATableViewController.m
//  TwitterApp
//
//  Created by Maciej Cupial on 19/11/13.
//  Copyright (c) 2013 Maciej Cupial. All rights reserved.
//

#import "TAStreamsTableViewController.h"
#import "APIManager.h"
#import "TATweetsTableViewController.h"

@interface TAStreamsTableViewController () <UIAlertViewDelegate>

// Stream Manager
@property (nonatomic, strong) APIManager *streamManager;

// TableView data source
@property (nonatomic, strong) NSArray *streams;

// TextField for UIAlertView
@property (nonatomic, strong) UITextField *streamTextField;

@end

@implementation TAStreamsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Streams...";
    
    // Set Back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil action:nil];
    
    // Handling stream manager
    self.streamManager = [[APIManager alloc] init];
    self.streams = [NSArray arrayWithArray:[self.streamManager fetchStreams]];
    
    // Add button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addStream)];
    self.navigationItem.rightBarButtonItem = addButton;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.streams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"All streams...";
    } else {
        cell.textLabel.text = [self.streams objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Initialize Detail View Controller
    TATweetsTableViewController *tweetsViewController = [[TATweetsTableViewController alloc]
                                                         initWithNibName:@"TATweetsTableViewController"
                                                         bundle:[NSBundle mainBundle]];
    
    if (indexPath.section == 0) {
        tweetsViewController.keyword = @"";
    } else {
        tweetsViewController.keyword = [self.streams objectAtIndex:indexPath.row];
    }

    // Push View Controller
    [self.navigationController pushViewController:tweetsViewController animated:YES];
}

#pragma mark Private Methods
- (void)addStream
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add a new stream"
                                                    message:@"Please enter a keyword"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Add", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = ADD_NEW_STREAM_ALERT_VIEW;
    [alert show];
}

- (void)addNewStrewamWithName:(NSString *)name
{
    // Copy array and add a new stream object
    NSMutableArray *currentStreams = [NSMutableArray arrayWithArray:self.streams];
    [currentStreams addObject:name];
    
    // Save the new array to TableView data source.
    self.streams = currentStreams;
    
    // Reload data
    [self.tableView reloadData];
    
    // Add a new stream name to Core Data
    [self.streamManager addStreamWithName:name];
}


#pragma mark UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == ADD_NEW_STREAM_ALERT_VIEW &&
        buttonIndex == 1) {
        
        NSString *newStreamKeyword = [alertView textFieldAtIndex:0].text;
        
        if ([newStreamKeyword isEqualToString:@""]) {
            // TODO: if new stream keyword is empty
        } else if ([self.streams containsObject:newStreamKeyword]) {
            // TODO: if the keyword exist already
        } else {
            // Run the method and add item
            [self addNewStrewamWithName:newStreamKeyword];
        }
    }
}

@end
