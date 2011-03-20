//
//  FavoriteEvent.h
//  RitEvents
//
//  Created by Thomas Mahoney on 2/17/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <CoreData/CoreData.h>

@class FeedCategory;

@interface FavoriteEvent :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * feedDetailUri;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * feedDescription;
@property (nonatomic, retain) FeedCategory * FeedCategory;

@end



