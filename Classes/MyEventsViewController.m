//
//  MyEventsViewController.m
//  RitEvents
//
//  Created by Thomas Mahoney on 1/28/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import "MyEventsViewController.h"
#import "MyEventsDetailViewController.h"
#import "FavoriteEvent.h"
#import "FeedCategory.h"

@implementation MyEventsViewController

@synthesize context;
@synthesize sortStyle;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
	NSLog(@"MyEvents viewDidLoad");
	self.title = @"My Events";
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"MyEvents viewWillAppear");
	[self loadFavorites];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"MyEvents viewDidAppear");
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem.action = @selector(toggleEditing);
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
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
	NSLog(@"numberOfSectionsInTableView called");
    if(sortStyle == MyEventsCategorySortStyle) {
		return [sortedCategoryKeys count];
	} else if(sortStyle == MyEventsUpcomingSortStyle) {
		return 1;
	}
	return 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"numberOfRowsInSection called");
    if(sortStyle == MyEventsCategorySortStyle) {
		return [[favoriteEventCategories objectForKey:[sortedCategoryKeys objectAtIndex:section]] count];
	} else if(sortStyle == MyEventsUpcomingSortStyle) {
		return [favoriteEvents count];
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(sortStyle == MyEventsCategorySortStyle) {
		return [sortedCategoryKeys objectAtIndex:section];
	}
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"cellForRowAtIndexPath called");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
    if(sortStyle == MyEventsCategorySortStyle) {
		NSMutableArray *categoryArray = [favoriteEventCategories objectForKey:[sortedCategoryKeys objectAtIndex:[indexPath section]]];
		[sortedCategoryKeys retain];
		FavoriteEvent *event = [categoryArray objectAtIndex:[indexPath row]];
		cell.textLabel.text = [event title];
		cell.detailTextLabel.text = [dateFormatter stringFromDate:[event eventDate]];
	} else if(sortStyle == MyEventsUpcomingSortStyle) {
		cell.textLabel.text = [[favoriteEvents objectAtIndex:[indexPath row]] title];
		cell.detailTextLabel.text = [dateFormatter stringFromDate:[[favoriteEvents objectAtIndex:[indexPath row]] eventDate]];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	MyEventsDetailViewController *myEventsDetailViewController = [[MyEventsDetailViewController alloc] initWithNibName:@"MyEventsDetailViewController" bundle:nil];
	myEventsDetailViewController.context = self.context;
	if(sortStyle == MyEventsCategorySortStyle) {
		NSMutableArray *categoryArray = [favoriteEventCategories objectForKey:[sortedCategoryKeys objectAtIndex:[indexPath section]]];
		[sortedCategoryKeys retain];
		myEventsDetailViewController.event = [categoryArray objectAtIndex:[indexPath row]];
	} else if(sortStyle == MyEventsUpcomingSortStyle) {
		myEventsDetailViewController.event = [favoriteEvents objectAtIndex:[indexPath row]];
	}
	[self.navigationController pushViewController:myEventsDetailViewController animated:YES];
	[myEventsDetailViewController release];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		if(sortStyle == MyEventsCategorySortStyle) {
			[context deleteObject:[[favoriteEventCategories objectForKey:[sortedCategoryKeys objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]]];
		} else if(sortStyle == MyEventsUpcomingSortStyle) {
			[context deleteObject:[favoriteEvents objectAtIndex:[indexPath row]]];
		}
        [self loadFavorites];
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)toggleEditing {
	[UIView beginAnimations:@"animation1" context:nil];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if (myEventsTableView.editing) {
		myEventsTableView.editing = NO;
	} else {
		myEventsTableView.editing = YES;
	}
	[UIView commitAnimations];
}

- (IBAction)toggleSortStyle:(id)sender {
	NSLog(@"toggleSortStyle");
	if(sortStyle == MyEventsCategorySortStyle) {
		sortStyle = MyEventsUpcomingSortStyle;
		NSLog(@"toggleSortStyle - sortStyle was MyEventsCategorySortStyle, is now MyEventsUpcomingSortStyle");
	} else if(sortStyle == MyEventsUpcomingSortStyle) {
		sortStyle = MyEventsCategorySortStyle;
		NSLog(@"toggleSortStyle - sortStyle was MyEventsUpcomingSortStyle, is now MyEventsCategorySortStyle");
	}
	[myEventsTableView reloadData];
}

- (void)loadFavorites {
	if(favoriteEvents != nil) {
		[favoriteEvents removeAllObjects];
		[favoriteEvents release];
	}
	if(favoriteEventCategories != nil) {
		[favoriteEventCategories removeAllObjects];
		[favoriteEventCategories release];
	}
	if(sortedCategoryKeys != nil) {
		[sortedCategoryKeys removeAllObjects];
		[sortedCategoryKeys release];
	}
	NSError *error;	
    NSFetchRequest *req = [NSFetchRequest new];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"FavoriteEvent"
                                             inManagedObjectContext:context];
    [req setEntity:descr];
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"eventDate" 
														 ascending:YES];
	[req setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	favoriteEvents = [[NSMutableArray alloc] init];
	for(FavoriteEvent *event in [[context executeFetchRequest:req error:&error] mutableCopy]) {
		[favoriteEvents addObject:event];
		[event release];
	}
	[req release];
	favoriteEventCategories = [[NSMutableDictionary alloc] init];
	for(FavoriteEvent *event in favoriteEvents) {
		NSMutableArray *categoryEventsArray = [favoriteEventCategories objectForKey:event.FeedCategory.name];
		if(categoryEventsArray != nil) {
			[categoryEventsArray addObject:event];
		} else {
			categoryEventsArray = [[NSMutableArray alloc] init];
			[categoryEventsArray addObject:event];
			[favoriteEventCategories setObject:categoryEventsArray forKey:event.FeedCategory.name];
			[categoryEventsArray release];
		}
	}
	sortedCategoryKeys = [[NSMutableArray arrayWithArray:[[favoriteEventCategories allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]] retain];
	NSLog(@"reloadData called");
	[myEventsTableView reloadData];
}

- (void)dealloc {
	[context release];
	[favoriteEvents removeAllObjects];
	[favoriteEvents release];
	[favoriteEventCategories removeAllObjects];
	[favoriteEvents release];
	[sortToggle release];
	[dateFormatter release];
	[sortedCategoryKeys removeAllObjects];
	[sortedCategoryKeys release];
	[myEventsTableView release];
    [super dealloc];
}


@end

