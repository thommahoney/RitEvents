//
//  FeedViewController.h
//  RitEvents
//
//  Created by Thomas Mahoney on 1/28/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FeedEvent.h"

@interface FeedViewController : UITableViewController <UIAlertViewDelegate, NSXMLParserDelegate> {
	NSManagedObjectContext *context;
	NSString *urlString;
	NSMutableData *responseData;
	NSXMLParser *xml;
	FeedCategory *currentParsingCategory;
	NSMutableString *pendingTitle;
	NSMutableString *pendingLink;
	NSMutableString *pendingDescription;
	NSMutableString *pendingGuid;
	NSMutableString *pendingDateString;
	NSString *currentElement;
	BOOL isParsing;
	int currentCategoryFetchingIndex;
	NSMutableArray *cachedFeedCategories;
	NSMutableArray *categoriesToUpdate;
	NSMutableDictionary *cachedFeedEvents;
	NSDateFormatter *dateFormatter;
	BOOL viewDidLoadWorking;
	IBOutlet UITableView *feedTableView;
	BOOL hasStartedItemList;
}

@property (retain, nonatomic) NSManagedObjectContext *context;

- (void)parseData;
- (void)loadNewFeedData;
- (NSMutableArray *)getSubscribedFeedCategories;
- (NSMutableArray *)getEventsForCategory:(NSString *)categoryName;
- (void)loadNewFeedsForCategory:(int)categoryArrayIndex;
- (void)loadCache;
- (NSString *)trim:(NSString *)original;
- (void)threadedRefresh:(BOOL)usingTimestamps;
- (void)initThreadedLoadByTimestamp;
- (void)loadNewFeedDataByTimestamp;
- (void)initThreadedLoad;
- (BOOL)isFeedSourceAvailable;
- (void)refreshButtonSelected;

@end