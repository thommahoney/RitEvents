//
//  PlacesViewController.h
//  RitEvents
//
//  Created by Thomas Mahoney on 1/28/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface PlacesViewController : UITableViewController {
	NSManagedObjectContext *context;
	NSMutableArray *locations;
}

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSMutableArray *locations;

@end
