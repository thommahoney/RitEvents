//
//  RitEventsAppDelegate.h
//  RitEvents
//
//  Created by student on 1/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface RitEventsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController *tabBarController;
	UINavigationController *feedsNavigationController;
	UINavigationController *myFeedsNagivationController;
	UINavigationController *mapNagivationController;
	UINavigationController *settingsNavigationController;
	NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    NSPersistentStoreCoordinator *psc;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) UINavigationController *feedsNavigationController;
@property (nonatomic, retain) UINavigationController *myFeedsNagivationController;
@property (nonatomic, retain) UINavigationController *mapNagivationController;
@property (nonatomic, retain) UINavigationController *settingsNavigationController;
@property (retain, nonatomic) NSManagedObjectContext * context;
@property (retain, nonatomic) NSPersistentStoreCoordinator * psc;
@property (retain, nonatomic) NSManagedObjectModel * model;

-(void)setupPersistentStore;
- (NSString *)applicationDocumentsDirectory;

@end

