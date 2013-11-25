//
//  APIManager.m
//  TwitterApp
//
//  Created by Maciej Cupial on 19/11/13.
//  Copyright (c) 2013 Maciej Cupial. All rights reserved.
//

#import "APIManager.h"
#import "TAAppDelegate.h"
#import "STTwitterAPI.h"
#import "Tweet.h"
#import "Stream.h"

@interface APIManager ()

// Twitter API
@property (nonatomic, strong) STTwitterAPI *twitter;

// Completion block
@property (nonatomic, strong) CompletionBlock completionBlock;

@end

@implementation APIManager

#pragma mark Initialization
- (id)init
{
    if (self = [super init]) {
        [self setUpTweeterAPI];
    }
    return self;
}

#pragma mark Private Methods
- (void)setUpTweeterAPI
{
    self.twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:CONSUMER_KEY
                                                   consumerSecret:CONSUMER_SECRET];
}

- (void)downloadNewTweetsForKeyword:(NSString *)keyword andCompletionBlock:(CompletionBlock)completionBlock
{
    self.completionBlock = completionBlock;
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        [self.twitter getSearchTweetsWithQuery:keyword
                                       geocode:NULL
                                          lang:NULL
                                        locale:TWEETS_LOCALE
                                    resultType:NULL
                                         count:TWEETS_COUNT
                                         until:NULL
                                       sinceID:NULL
                                         maxID:NULL
                               includeEntities:NULL
                                      callback:NULL
                                  successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
                                      
                                      // Create array with tweets
                                      int i = 0;
                                      for (NSString *tweetText in statuses) {
                                          
                                          // Contex
                                          TAAppDelegate *appDelegate = ESAPP_DELEGATE;
                                          NSManagedObjectContext *context = [appDelegate managedObjectContext];
                                          
                                          NSString *tweetId = [NSString stringWithFormat:@"%@", [[statuses objectAtIndex:i] objectForKey:@"id"]];
                                          
                                          // Check id tweet if exists
                                          NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                                          NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet"
                                                                                    inManagedObjectContext:context];
                                          [fetchRequest setEntity:entity];
                                          
                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                                                    @"tweetId == [c] %@", tweetId];
                                          [fetchRequest setPredicate:predicate];
                                          
                                          NSError *error;
                                          NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                                          
                                          if (fetchedObjects.count == 0) {
                                              // NSDate from string
                                              NSDateFormatter *df = [[NSDateFormatter alloc] init];
                                              [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
                                              NSDate *date = [df dateFromString:[[statuses objectAtIndex:i] objectForKey:@"created_at"]];
                                              [df setDateFormat:@"eee MMM dd yyyy"];
                                              
                                              // Save to Core Data
                                              Tweet *tweet = [NSEntityDescription
                                                              insertNewObjectForEntityForName:@"Tweet"
                                                              inManagedObjectContext:context];
                                              
                                              
                                              tweet.text = [[statuses objectAtIndex:i] objectForKey:@"text"];
                                              tweet.author = [[[statuses objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"];
                                              tweet.date = date;
                                              tweet.imagePath = [[[statuses objectAtIndex:i]
                                                                  objectForKey:@"user"] objectForKey:@"profile_image_url"];
                                              tweet.stream = keyword;
                                              tweet.tweetId = [[statuses objectAtIndex:i] objectForKey:@"id"];
                                              
                                              if (![context save:&error]) {
                                                  // TODO: handling errors
                                                  NSLog(@"couldn't save: %@", [error localizedDescription]);
                                              }
                                              
                                              NSLog(@"saved: %@", [[statuses objectAtIndex:i] objectForKey:@"id"]);
                                              
                                          }
                                          ++i;
                                      }
                                      
                                      // Send success
                                      self.completionBlock(YES);
                                      
                                  } errorBlock:^(NSError *error) {
                                      // TODO: handling errors
                                      self.completionBlock(NO);
                                      NSLog(@"%@", error);
                                  }];
    } errorBlock:^(NSError *error) {
        // TODO: handling errors
        self.completionBlock(NO);
        NSLog(@"%@", error);
    }];
}

- (NSArray *)fetchTweetsForKeyword:(NSString *)keyword
{
    // Fetch current tweets from Core Data
    TAAppDelegate *appDelegate = ESAPP_DELEGATE;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"stream == [c] %@", keyword];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Tweet *info in fetchedObjects) {
        
        [result addObject:@{TWEET_TEXT : info.text,
                            TWEET_AUTHOR : info.author,
                            TWEET_DATE : info.date,
                            TWEET_IMAGEPATH : info.imagePath}];
    }
    
    return [NSArray arrayWithArray:result];

}

- (NSArray *)fetchAllTweets
{
    // Fetch current tweets from Core Data
    TAAppDelegate *appDelegate = ESAPP_DELEGATE;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Tweet *info in fetchedObjects) {
        
        [result addObject:@{TWEET_TEXT : info.text,
                            TWEET_AUTHOR : info.author,
                            TWEET_DATE : info.date,
                            TWEET_IMAGEPATH : info.imagePath}];
    }
    
    return [NSArray arrayWithArray:result];
    
}


- (NSArray *)fetchStreams
{
    // Fetch streams from Core Data
    TAAppDelegate *appDelegate = ESAPP_DELEGATE;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stream"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Stream *info in fetchedObjects) {
        
        [result addObject:info.name];
    }
    
    return [NSArray arrayWithArray:result];

}

- (void)addStreamWithName:(NSString *)name
{
    // Add a new stream name to Core Data, check if exist!
    TAAppDelegate *appDelegate = ESAPP_DELEGATE;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // Check id tweet if exists
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stream"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"name == [c] %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects.count == 0) {
        
        // Save to Core Data
        Stream *stream = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Stream"
                          inManagedObjectContext:context];
        
        
        stream.name = name;
        
        if (![context save:&error]) {
            // TODO: handling errors
            NSLog(@"couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (void)removeStreamWithName:(NSString *)name
{
    // Fetch current tweets from Core Data
    TAAppDelegate *appDelegate = ESAPP_DELEGATE;
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stream"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"name == [c] %@", name];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (Stream *info in fetchedObjects) {
        [context deleteObject:info];
    }
    
    [context save:&error];
}

@end
