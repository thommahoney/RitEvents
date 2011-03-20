//
//  RitEventsAppDelegate.m
//  RitEvents
//
//  Created by student on 1/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RitEventsAppDelegate.h"
#import "FeedViewController.h"
#import "MyEventsViewController.h"
#import "PlacesViewController.h"
#import "SettingsViewController.h"

@implementation RitEventsAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize feedsNavigationController;
@synthesize myFeedsNagivationController;
@synthesize mapNagivationController;
@synthesize settingsNavigationController;
@synthesize context;
@synthesize psc;
@synthesize model;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	//Setup Core Data Store
	[self setModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    [self setupPersistentStore];
    context = [NSManagedObjectContext new];
    [context setPersistentStoreCoordinator:psc];
	
   	//Create our tab bar and navigation controllers
	tabBarController = [[UITabBarController alloc] init];
	
	feedsNavigationController = [[UINavigationController alloc] init];
	FeedViewController *feedVC = [[FeedViewController alloc] initWithNibName:@"FeedViewController" bundle:nil];
	[feedVC setContext:context];
	[feedsNavigationController pushViewController:feedVC animated:NO];
	feedsNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	feedsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Feed" image:[UIImage imageNamed:@"57-download.png"] tag:0];
	
	myFeedsNagivationController = [[UINavigationController alloc] init];
	MyEventsViewController *myEventsVC = [[MyEventsViewController alloc] initWithNibName:@"MyEventsViewController" bundle:nil];
	[myEventsVC setContext:context];
	myEventsVC.sortStyle = MyEventsUpcomingSortStyle;
	[myFeedsNagivationController pushViewController:myEventsVC animated:NO];
	myFeedsNagivationController.navigationBar.barStyle = UIBarStyleBlack;
	myFeedsNagivationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Events" image:[UIImage imageNamed:@"83-calendar.png"] tag:1];
	
	mapNagivationController = [[UINavigationController alloc] init];
	PlacesViewController *placesVC = [[PlacesViewController alloc] initWithNibName:@"PlacesViewController" bundle:nil];
	[placesVC setContext:context];
	[mapNagivationController pushViewController:placesVC animated:NO];
	mapNagivationController.navigationBar.barStyle = UIBarStyleBlack;
	mapNagivationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Places" image:[UIImage imageNamed:@"71-compass.png"] tag:2];
	
	settingsNavigationController = [[UINavigationController alloc] init];
	SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[settingsVC setContext:context];
	[settingsNavigationController pushViewController:settingsVC animated:NO];
	settingsNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	settingsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"20-gear2.png"] tag:3];
	
	//add this list of view controllers to the tabBarController
	tabBarController.viewControllers = [NSArray arrayWithObjects:feedsNavigationController,myFeedsNagivationController,mapNagivationController,settingsNavigationController,nil];
	
	//The tab bar controller is now retaining the two view controllers, so we can release them
	[feedVC release];
	[myEventsVC release];
	[settingsVC release];
	[placesVC release];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	//add bars to window so that we can see it
	[window addSubview:tabBarController.view];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

-(void)setupPersistentStore
{
    NSString *docDir = [self applicationDocumentsDirectory];
    NSString *pathToDb = [docDir stringByAppendingPathComponent:
                          @"RitEvents.sqlite"];
    NSURL *urlForPath = [NSURL fileURLWithPath:pathToDb];
	NSLog(@"Setting up persistent store");
	NSError *error;
    psc = [[NSPersistentStoreCoordinator alloc] 
           initWithManagedObjectModel:[self model]];
    if (![psc addPersistentStoreWithType:NSSQLiteStoreType 
                           configuration:nil 
                                     URL:urlForPath 
                                 options:nil 
                                   error:&error]) 
    {
		NSLog(@"An error occurred while setting up the persistent store");
        NSLog(@"Error: %@",error);
    }    
}

- (NSString *)applicationDocumentsDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	
    NSError *error;
    if (context != nil) 
    {
        if ([context hasChanges] && ![context save:&error]) 
        {
			NSLog(@"Error saving pending changes: %@",error);
        } 
    }
	NSLog(@"Application Terminated");
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
