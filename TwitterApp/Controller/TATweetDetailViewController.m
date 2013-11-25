//
//  TATweetDetailViewController.m
//  TwitterApp
//
//  Created by Maciej Cupial on 19/11/13.
//  Copyright (c) 2013 Maciej Cupial. All rights reserved.
//

#import "TATweetDetailViewController.h"

@interface TATweetDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *tweetAuthor;
@property (weak, atomic) IBOutlet UIImageView *tweetImageView;
@property (weak, nonatomic) IBOutlet UILabel *tweetDate;

@property (nonatomic, strong) NSString *imagePath;
@property (atomic, strong) UIImage *image;

@end

@implementation TATweetDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.payload = [NSDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set Back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil action:nil];
    
    // Load twee image in background
    [self loadTweetImage];
    
    self.tweetText.text = self.payload[TWEET_TEXT];
    
    // Format date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *timeStamp = [dateFormatter stringFromDate:self.payload[TWEET_DATE]];
    
    self.tweetDate.text = [NSString stringWithFormat:@"Created: %@", timeStamp];
    self.tweetAuthor.text = self.payload[TWEET_AUTHOR];
    self.title = [NSString stringWithFormat:@"Author: %@", self.payload[TWEET_AUTHOR]];
    self.imagePath = self.payload[TWEET_IMAGEPATH];
}

#pragma mark Private Methods
- (void)loadTweetImage
{
    
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        
        // Download image
        NSURL *imageURL = [NSURL URLWithString:self.imagePath];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            // Show new image
            self.image = [UIImage imageWithData:imageData];
            self.tweetImageView.image = self.image;
        }];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
