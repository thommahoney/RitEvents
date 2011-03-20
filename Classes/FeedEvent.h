//
//  FeedEvent.h
//  RitEvents
//
//  Created by Andrew Church on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class FeedCategory;

@interface FeedEvent :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * feedDetailUri;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * feedDescription;
@property (nonatomic, retain) FeedCategory * FeedCategory;

@end



