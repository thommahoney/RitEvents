//
//  SettingsViewController.h
//  RitEvents
//
//  Created by Andrew Church on 13/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FeedCategory.h"


@interface SettingsViewController : UITableViewController {
	NSMutableArray *availableFeeds;
	NSManagedObjectContext *context;
	NSMutableArray *switches;

}

@property (nonatomic, retain) NSMutableArray *availableFeeds;
@property (retain, nonatomic) NSManagedObjectContext * context;

- (void)toggleFeedSelection:(id)sender;
- (void)loadEventCategories;
- (void)loadDefaultEventCategories;
- (NSMutableArray *)getFeedCategories;
- (FeedCategory *)getFeedCategory:(NSString *)categoryName;

@end
