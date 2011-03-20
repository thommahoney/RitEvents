//
//  MyEventsViewController.h
//  RitEvents
//
//  Created by Thomas Mahoney on 1/28/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef enum {
	MyEventsCategorySortStyle,
	MyEventsUpcomingSortStyle
} MyEventsSortStyle;

@interface MyEventsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSManagedObjectContext *context;
	NSMutableArray *favoriteEvents;
	NSMutableDictionary *favoriteEventCategories;
	IBOutlet UISegmentedControl *sortToggle;
	MyEventsSortStyle sortStyle;
	NSDateFormatter *dateFormatter;
	NSMutableArray *sortedCategoryKeys;
	IBOutlet UITableView *myEventsTableView;
}

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (nonatomic) MyEventsSortStyle sortStyle;

- (IBAction)toggleSortStyle:(id)sender;
- (void)loadFavorites;

@end
