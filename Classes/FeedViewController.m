//
//  FeedViewController.m
//  RitEvents
//
//  Created by Thomas Mahoney on 1/28/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCategory.h"
#import "FeedEvent.h"
#import "FeedDetailViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#define BASE_FEED_URI @"http://events.rit.edu/web_service/rss_feed.cfm?categories="
#define URI_ENCODED_CATEGORY_DELIMITER @"%2C"


@implementation FeedViewController

@synthesize context;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	NSLog(@"viewDidLoad");
	self.title = @"Event Feed";
	hasStartedItemList = NO;
	[self loadCache];
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" 
																			  style:UIBarButtonItemStylePlain 
																			 target:self 
																			 action:@selector(refreshButtonSelected)];
	if([cachedFeedCategories count] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Feed Subscriptions" 
														message:@"You have not subscribed to any RIT Event feeds." 
													   delegate:self cancelButtonTitle:@"Cancel" 
											  otherButtonTitles:@"Settings", nil];
		[alert show];
		[alert release];
	}
	else
	{
		viewDidLoadWorking = YES;
		[self threadedRefresh:NO];
	}
	[super viewDidLoad];
}

-(void)refreshButtonSelected
{
	[self threadedRefresh:NO];
}

- (BOOL)isFeedSourceAvailable{
	const char *hostname = "events.rit.edu";
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, hostname);
	SCNetworkReachabilityFlags flags;
	return SCNetworkReachabilityGetFlags(reachability, &flags);
}

-(void)threadedRefresh:(BOOL)usingTimestamps
{

	if([self isFeedSourceAvailable])
	{
		if(!usingTimestamps)
		{
			[NSThread detachNewThreadSelector:@selector(initThreadedLoad) toTarget:self withObject:nil];
		}
		else {
			[NSThread detachNewThreadSelector:@selector(initThreadedLoadByTimestamp) toTarget:self withObject:nil];
		}

	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Connection Issue" 
														message:@"events.rit.edu is unavailable." 
													   delegate:nil cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

}

- (void)initThreadedLoad
{
	NSLog(@"initThreadedLoad");
	[self performSelectorOnMainThread:@selector(loadNewFeedData) withObject:nil waitUntilDone:NO];
}

- (void)initThreadedLoadByTimestamp
{
	NSLog(@"initThreadedLoadByTimestamp");
	[self performSelectorOnMainThread:@selector(loadNewFeedDataByTimestamp) withObject:nil waitUntilDone:NO];
}
 
- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"View Did Appear");
	if(!viewDidLoadWorking)
	{
		cachedFeedCategories = [self getSubscribedFeedCategories];
		[self threadedRefresh:YES];
	}
    [super viewDidAppear:animated];
}

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
    return [cachedFeedCategories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [(FeedCategory *)[cachedFeedCategories objectAtIndex:section] name];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // NSLog(@"numberOfRowsInSection");
	FeedCategory *category = [cachedFeedCategories objectAtIndex:section];
	if([[cachedFeedEvents objectForKey:[category name]] count] == 0) return 1;
	return [[cachedFeedEvents objectForKey:[category name]] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	FeedCategory *category = [cachedFeedCategories objectAtIndex:[indexPath section]];
	NSMutableArray *events = [cachedFeedEvents objectForKey:[category name]];
	//NSLog(@"Category found: %@", category);
	
	if([events count] != 0)
	{
		FeedEvent *event = [events objectAtIndex:[indexPath row]];
		cell.textLabel.text = event.title;
		cell.detailTextLabel.text = [dateFormatter stringFromDate:event.eventDate];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		cell.textLabel.text = @"No upcoming events";
		cell.detailTextLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	FeedCategory *category = [cachedFeedCategories objectAtIndex:[indexPath section]];
	[feedTableView deselectRowAtIndexPath:indexPath animated:YES];
	if([[category FeedEvents] count] > 0)
	{
		FeedDetailViewController *feedDVC = [[FeedDetailViewController alloc] 
											 initWithNibName:@"FeedDetailViewController" 
											 bundle:nil];
		FeedCategory *category = [cachedFeedCategories objectAtIndex:[indexPath section]];
		NSMutableArray *events = [cachedFeedEvents objectForKey:[category name]];
		feedDVC.event = [events objectAtIndex:[indexPath row]];
		feedDVC.context = context;
		[self.navigationController pushViewController:feedDVC animated:YES];
		[feedDVC release];
	}
}


#pragma mark -
#pragma mark NSXmlParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	currentElement = [elementName copy];
	if([elementName isEqual:@"item"]) {
		hasStartedItemList = YES;
		pendingTitle = [[NSMutableString alloc] init];
		pendingDescription = [[NSMutableString alloc] init];
		pendingLink = [[NSMutableString alloc] init];
		pendingGuid = [[NSMutableString alloc] init];
		pendingDateString = [[NSMutableString alloc] init];
	}	
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	NSLog(@"foundCharacters: %@", string);
	if(hasStartedItemList) {
		if ([currentElement isEqualToString:@"title"]) {
			[pendingTitle appendString:string];
		} else if ([currentElement isEqualToString:@"link"]) {
			[pendingLink appendString:string];
		} else if ([currentElement isEqualToString:@"description"]) {
			[pendingDescription appendString:string];
		} else if ([currentElement isEqualToString:@"guid"]) {
			[pendingGuid appendString:string];
		} else if([currentElement isEqualToString:@"pubDate"]){
			[pendingDateString appendString:string];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"item"]) {
		NSLog(@"saving new event");
	
		FeedEvent *event;
		event = [NSEntityDescription 
		 insertNewObjectForEntityForName:@"FeedEvent" 
				 inManagedObjectContext:context];
		
		event.title = [self trim:pendingTitle];
		event.feedDescription = pendingDescription;
		event.feedDetailUri = pendingLink;
		NSLog(@"Link: %@", pendingLink);
		event.guid = pendingGuid;
		event.eventDate = [dateFormatter dateFromString:pendingDateString];
		NSMutableSet *eventsSet = [[categoriesToUpdate objectAtIndex:currentCategoryFetchingIndex] mutableSetValueForKey:@"FeedEvents"];
		[eventsSet addObject:event];
		event.FeedCategory = [categoriesToUpdate objectAtIndex:currentCategoryFetchingIndex];
		[[categoriesToUpdate objectAtIndex:currentCategoryFetchingIndex] setUpdateTimestamp:[NSDate date]];
	}
}



- (void)parserDidEndDocument:(NSXMLParser *)parser{
	//NSLog(@"parserDidEndDocument parser=%@",parser);
	NSLog(@"ended Document");
	hasStartedItemList = NO;
	if(isParsing && currentCategoryFetchingIndex < ([categoriesToUpdate count]-1))
	{
		currentCategoryFetchingIndex = currentCategoryFetchingIndex+1;
		[self loadNewFeedsForCategory:currentCategoryFetchingIndex];
	}
	else if(currentCategoryFetchingIndex == ([categoriesToUpdate count]-1))
	{
		isParsing = NO;
		NSError *error;
		if(![context save:&error])
		{
			NSLog(@"Error saving need feed data: %@",error);
		}
		else
		{
			NSLog(@"Successfully saved new feed data");
		}
		
		[self loadCache];
		[feedTableView reloadData];
		viewDidLoadWorking = NO;
	}
	
}
#pragma mark -

#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	// cast NSURLResponse to NSHTTPURLResponse
	//NSHTTPURLResponse * httpResponse =  (NSHTTPURLResponse *)response;
	// Log info about response
	// Hey, where's the data?
	//NSLog(@"didReceiveResponse response = %@",httpResponse);
	//NSLog(@"status code = %d",[httpResponse statusCode]  );
	//NSLog(@"headers = %@",[httpResponse allHeaderFields]  );
	//	[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSLog(@"connectionDidFinishLoading");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
	[self parseData]; 
	[connection release]; 
	//[responseData release];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];

	[connection release];
	NSLog(@"didFailWithError error= %@",error);
}

#pragma mark -

#pragma mark AlertViewDelgate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	switch(buttonIndex) {
		case 0:
			//cancel
			break;
		case 1:
			self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:3];
			break;
		default:
			break;
	}
}

#pragma mark -

#pragma mark FeedViewController Private Members


- (void)loadNewFeedData{
	NSLog(@"Load New Feeds");
	cachedFeedCategories = [self getSubscribedFeedCategories];
	categoriesToUpdate = cachedFeedCategories;
	if([categoriesToUpdate count] > 0)
	{
		isParsing = YES;
		currentCategoryFetchingIndex = 0;
		[self loadNewFeedsForCategory:0];
	}
	else
	{
		[feedTableView reloadData];
	}
	
}

- (void)loadNewFeedDataByTimestamp
{
	if(categoriesToUpdate != nil) {
		[categoriesToUpdate removeAllObjects];
	}
	for(FeedCategory *category in cachedFeedCategories)
	{
		NSLog(@"minutesSinceLastUpdate: %f)",[[NSDate date] timeIntervalSinceDate: [category updateTimestamp]]/60);
		if(nil == [category updateTimestamp] || ([[NSDate date] timeIntervalSinceDate: [category updateTimestamp]]/60) > 5)
		{
			[categoriesToUpdate addObject:category];
		}
	}
	if([categoriesToUpdate count] > 0)
	{
		isParsing = YES;
		currentCategoryFetchingIndex = 0;
		[self loadNewFeedsForCategory:0];
	}
	else {
		[feedTableView reloadData];
	}

}

- (void)loadNewFeedsForCategory:(int)categoryArrayIndex
{
	NSLog(@"loadNewFeedsForCategory:%d",categoryArrayIndex);
	currentParsingCategory = (FeedCategory *)[categoriesToUpdate objectAtIndex:categoryArrayIndex];
	//NSLog(@"loadNewFeedsForCategory: %@",currentParsingCategory);

		if([[currentParsingCategory FeedEvents] count] > 0)
		{
			[[currentParsingCategory mutableSetValueForKey:@"FeedEvents"] removeAllObjects];
		}
	
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_FEED_URI,[currentParsingCategory uriOptionValue]]];
		NSURLRequest *request = [NSURLRequest requestWithURL:url 
							 // respect server's cacheing policy
											 cachePolicy:NSURLRequestUseProtocolCachePolicy 
										 timeoutInterval:10.0];
	
		// make the connection and retrieve the data
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (connection){
			NSLog(@"Started Connection");
			responseData = [[NSMutableData data] retain];
			NSLog(@"Retained mutable data");
			// show network activity indicator
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];

		}

}

- (void)parseData{
	NSLog(@"Parsing...");
	if(xml != nil) {
		[xml release];
	}
	xml = [[NSXMLParser alloc] initWithData:responseData];
	[xml setDelegate:self];
	[xml setShouldResolveExternalEntities:NO];
	[xml setShouldProcessNamespaces:NO];
	[xml setShouldReportNamespacePrefixes:NO];
	if(![xml parse]){
		NSLog(@"error in parse. error=%@", [xml parserError] );
		if(xml)[xml release];
	}
	
}

- (NSMutableArray *)getSubscribedFeedCategories
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
	[req setPredicate:[NSPredicate predicateWithFormat:@"isSubscribedTo = %d",1]];
	[req autorelease];
	return [[context executeFetchRequest:req error:&error] mutableCopy];
}

- (NSMutableArray *)getEventsForCategory:(NSString *)categoryName
{
	NSString *category = [categoryName copy];
	NSError *error;	
    NSFetchRequest *req = [NSFetchRequest new];
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"FeedEvent"
                                             inManagedObjectContext:context];
    [req setEntity:descr];
    
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"eventDate" 
														 ascending:YES];
	[req setSortDescriptors:[NSArray arrayWithObject:sort]];
	[sort release];
	[req setPredicate:[NSPredicate predicateWithFormat:@"FeedCategory.name like[cd] %@",category]];
	[req autorelease];
	return [[context executeFetchRequest:req error:&error] mutableCopy];
}

- (void)loadCache
{
	NSLog(@"Loading Cache");
	if(! cachedFeedEvents) cachedFeedEvents = [[NSMutableDictionary alloc] init];
	[cachedFeedEvents removeAllObjects];
	cachedFeedCategories = [self getSubscribedFeedCategories];
	
	for(FeedCategory *category in cachedFeedCategories)
	{
		[cachedFeedEvents setObject:[self getEventsForCategory:[category name]] forKey:[category name]];
	}	
}

- (NSString *)trim:(NSString *)original {
	NSMutableString *copy = [original mutableCopy];
	return [NSString stringWithString:[copy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

#pragma mark -

- (void)dealloc {
	[urlString release];
	[responseData release];
	[xml release];
	[currentParsingCategory release];
	[pendingTitle release];
	[pendingLink release];
	[pendingDescription release];
	[pendingGuid release];
	[pendingDateString release];
	[currentElement release];
	[cachedFeedCategories release];
	[categoriesToUpdate release];
	[cachedFeedEvents release];
	[dateFormatter release];
	[feedTableView release];
    [super dealloc];
}


@end

