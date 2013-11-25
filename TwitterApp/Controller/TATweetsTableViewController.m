//
//  TATweetsTableViewController.m
//  TwitterApp
//
//  Created by Maciej Cupial on 19/11/13.
//  Copyright (c) 2013 Maciej Cupial. All rights reserved.
//

#import "TATweetsTableViewController.h"
#import "TATweetDetailViewController.h"
#import "APIManager.h"

@interface TATweetsTableViewController ()

// Table View data source
@property (atomic, strong) NSArray *tweets;

// Stream Manager
@property (nonatomic, strong) APIManager *streamManager;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TATweetsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Loading...";
    
    // Set Back button for detail view
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil action:nil];
    
    // Handling stream manager
    self.streamManager = [[APIManager alloc] init];
        [[NSOperationQueue currentQueue] addOperationWithBlock:^{
            
            if ([self.keyword isEqualToString:@""]) {
                self.tweets = [self.streamManager fetchAllTweets];
            } else {
                self.tweets = [self.streamManager fetchTweetsForKeyword:self.keyword];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Refresh control only for single keyword
                    self.refreshControl = [[UIRefreshControl alloc]  initWithFrame:CGRectMake(0, 0, 20, 20)];
                    self.refreshControl.tintColor = [UIColor grayColor];
                    [self.refreshControl addTarget:self action:@selector(downloadNewTweets) forControlEvents:UIControlEventValueChanged];
                    [self.tableView addSubview:self.refreshControl];
                }];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // Reaload table view
                [self.tableView reloadData];
                self.title = [NSString stringWithFormat:@"Tweets: %i", self.tweets.count];
                
                if (self.tweets.count == 0) {
                    self.title = @"Loading...";
                    [self downloadNewTweets];
                }
                
            }];
            
        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[self.tweets objectAtIndex:indexPath.row] objectForKey:TWEET_TEXT];
    
    return cell;
}

#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Initialize Detail View Controller
    TATweetDetailViewController *tweetDetailViewController = [[TATweetDetailViewController alloc]
                                                         initWithNibName:@"TATweetDetailViewController"
                                                         bundle:[NSBundle mainBundle]];
    
    // Prepare payload
    NSDictionary *payload = @{TWEET_TEXT : [[self.tweets objectAtIndex:indexPath.row] objectForKey:TWEET_TEXT],
                              TWEET_AUTHOR : [[self.tweets objectAtIndex:indexPath.row] objectForKey:TWEET_AUTHOR],
                              TWEET_DATE : [[self.tweets objectAtIndex:indexPath.row] objectForKey:TWEET_DATE],
                              TWEET_IMAGEPATH : [[self.tweets objectAtIndex:indexPath.row] objectForKey:TWEET_IMAGEPATH]};
    
    tweetDetailViewController.payload = payload;
    
    // Push View Controller
    [self.navigationController pushViewController:tweetDetailViewController animated:YES];
}


#pragma mark Private Methods
- (void)downloadNewTweets
{
    __weak TATweetsTableViewController *weakSelf = self;
    [self.streamManager downloadNewTweetsForKeyword:self.keyword andCompletionBlock:^(BOOL success) {
        if (success) {
            
            [[NSOperationQueue currentQueue] addOperationWithBlock:^{
                
                NSArray *tweets = [NSArray arrayWithArray:[weakSelf.streamManager
                                                           fetchTweetsForKeyword:weakSelf.keyword]];
                weakSelf.tweets = tweets;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [weakSelf.tableView reloadData];
                    [weakSelf.refreshControl endRefreshing];
                    weakSelf.title = [NSString stringWithFormat:@"Tweets: %i", self.tweets.count];
                }];
                
            }];
            
        } else {
            NSLog(@"error ...");
        }
    }];
}




@end