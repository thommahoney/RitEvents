//
//  FeedCategory.h
//  RitEvents
//
//  Created by Thomas Mahoney on 2/21/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <CoreData/CoreData.h>

@class FavoriteEvent;
@class FeedEvent;

@interface FeedCategory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * uriOptionValue;
@property (nonatomic, retain) NSDate * updateTimestamp;
@property (nonatomic, retain) NSNumber * isSubscribedTo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* FavoriteEvents;
@property (nonatomic, retain) NSSet* FeedEvents;

@end


@interface FeedCategory (CoreDataGeneratedAccessors)
- (void)addFavoriteEventsObject:(FavoriteEvent *)value;
- (void)removeFavoriteEventsObject:(FavoriteEvent *)value;
- (void)addFavoriteEvents:(NSSet *)value;
- (void)removeFavoriteEvents:(NSSet *)value;

- (void)addFeedEventsObject:(FeedEvent *)value;
- (void)removeFeedEventsObject:(FeedEvent *)value;
- (void)addFeedEvents:(NSSet *)value;
- (void)removeFeedEvents:(NSSet *)value;

@end

