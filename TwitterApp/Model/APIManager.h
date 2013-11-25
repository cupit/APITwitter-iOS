//
//  APIManager.h
//  TwitterApp
//
//  Created by Maciej Cupial on 19/11/13.
//  Copyright (c) 2013 Maciej Cupial. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(BOOL success);

@interface APIManager : NSObject

// Fetch tweets only for one keyword
- (NSArray *)fetchTweetsForKeyword:(NSString *)keyword;

// Fetch all tweets
- (NSArray *)fetchAllTweets;

// Download the new tweets
- (void)downloadNewTweetsForKeyword:(NSString *)keyword andCompletionBlock:(CompletionBlock)completionBlock;

// Fetch streams from Core Data
- (NSArray *)fetchStreams;

// Add a new stream to Core Data
- (void)addStreamWithName:(NSString *)name;

- (void)removeStreamWithName:(NSString *)name;

@end
