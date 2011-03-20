//
//  SettingsViewController.m
//  RitEvents
//
//  Created by Andrew Church on 13/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "FeedCategory.h"


@implementation SettingsViewController
@synthesize availableFeeds;
@synthesize context;


- (void)viewDidLoad {

	[self loadEventCategories];
	self.title = @"Settings";
    [super viewDidLoad];
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
}

- (void)didReceiveMemoryWarning {
	NSLog(@"MEMORY LEAK!!!");
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch(section){
		default:
			return [availableFeeds count];
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section){
		default:
			return @"Available Feed Categories";
			break;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSUInteger row = [indexPath row];
	FeedCategory *category = (FeedCategory *)[availableFeeds objectAtIndex:row];
	cell.textLabel.text = category.name;
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.accessoryView = [switches objectAtIndex:row];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Private Members

- (void)toggleFeedSelection:(id)sender
{
	NSLog(@"feedToggled");
	UISwitch *sendingSwitch = (UISwitch *)sender;
	NSString *eventName = [(UITableViewCell *)[(UISwitch *)sender superview] textLabel].text;
	FeedCategory *feedCategory = (FeedCategory *)[self getFeedCategory:eventName];
	NSLog(@"feedCategory: %@",feedCategory);
	if(sendingSwitch.on)
	{
		[feedCategory setIsSubscribedTo:[NSNumber numberWithBool:YES]];
		[feedCategory setUpdateTimestamp:nil];
	}
	else
	{
		[feedCategory setIsSubscribedTo:[NSNumber numberWithBool:NO]];
	}
	
	NSError *error;
	
	if(![context save:&error])
	{
		NSLog(@"An error occured saving the new feed subscription settings: %@",error);
	}
	else
	{
		NSLog(@"Successfully saved new feed subscription settings.");
	}
	
	[feedCategory release];
	[eventName release];
	// this was causing memory leaks and is unnecessary
	//[self loadEventCategories];
}

- (void)loadEventCategories
{
	NSLog(@"Loading Event Categories");
    [self setAvailableFeeds:[self getFeedCategories]];

	if([availableFeeds count] == 0)
	{
		NSLog(@"No feeds in CoreData store, loading defaults");
		[self loadDefaultEventCategories];
	}
	
	[self setAvailableFeeds:[self getFeedCategories]];
	switches = [[NSMutableArray alloc] init];
	
	for(FeedCategory *category in availableFeeds)
	{
		UISwitch *switchObj = [[UISwitch alloc] initWithFrame:CGRectMake(1.0, 1.0, 20.0, 20.0)];
		switchObj.on = NO;
		
		if([[category isSubscribedTo] boolValue])
		{
			switchObj.on = YES;
		}
		[switchObj addTarget:self action:@selector(toggleFeedSelection:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
		[switches addObject:switchObj];
		[switchObj release];
	}
	
	NSLog(@"Finished Loading Feed Categories");
}

- (NSMutableArray *)getFeedCategories
{
	NSError *error;	
    NSFetchRequest *req = [NSFetchRequest new];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"FeedCategory"
                                             inManagedObjectContext:context];
    [req setEntity:descr];
    
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" 
														 ascending:YES];
	[req setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];	
	[req autorelease];
	return [[context executeFetchRequest:req error:&error] mutableCopy];
}

- (void)loadDefaultEventCategories
{
	NSLog(@"Loading Default Feeds from plist");
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"feeds" ofType:@"plist"];
	NSMutableArray *plistFeeds = [[NSMutableArray alloc] initWithContentsOfFile:path];
	
	for(int i=0; i<[plistFeeds count]; i++)
	{
		// set up default data
		NSDictionary *dict = [plistFeeds objectAtIndex:i];
		FeedCategory *category;
		category = [NSEntityDescription 
					insertNewObjectForEntityForName:@"FeedCategory" 
					inManagedObjectContext:context];
		NSLog(@"Inserted new entity into core data");
		[category setName:[dict objectForKey:@"name"]];
		[category setUriOptionValue:[dict objectForKey:@"uriOptionValue"]];
		[category setIsSubscribedTo:[NSNumber numberWithBool:NO]];
		//category.FeedEvents = [[NSSet alloc] init];
		
		[dict release];			
	}
	
	NSLog(@"Exited for loop, going to save");
	if(![context save:&error])
	{
		NSLog(@"Error saving context: %@",error);
	}
	else
	{
		NSLog(@"Save Successful");
	}

}

- (FeedCategory *)getFeedCategory:(NSString *)categoryName
{
	NSLog(@"Getting Event Feed Category");
	[categoryName retain];

	NSError *error;	
    NSFetchRequest *req = [NSFetchRequest new];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"FeedCategory"
                                             inManagedObjectContext:context];
    [req setEntity:descr];
    
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" 
														 ascending:YES];
	[req setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
    [req setPredicate:[NSPredicate predicateWithFormat:@"name like[cd] %@",categoryName]];
	NSMutableArray *resultSet = [[context executeFetchRequest:req error:&error] mutableCopy];
	[req autorelease];
	if([resultSet count] > 1)
	{
		NSLog(@"More than one category found with the specific title");
	}
	return [resultSet objectAtIndex:0];
}

#pragma mark -



- (void)dealloc {
	NSLog(@"Deallocating");
	[switches removeAllObjects];
	[switches release];
	[availableFeeds removeAllObjects];
	[availableFeeds release];
    [super dealloc];
}


@end

