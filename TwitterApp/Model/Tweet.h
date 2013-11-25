//
//  Tweet.h
//  TwitterApp
//
//  Created by Maciej Cupial on 25/11/13.
//  Copyright (c) 2013 Maciej Cupial. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * stream;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * tweetId;

@end
