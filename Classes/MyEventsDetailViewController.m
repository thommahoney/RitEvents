//
//  MyEventsDetailViewController.m
//  RitEvents
//
//  Created by Thomas Mahoney on 2/20/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import "MyEventsDetailViewController.h"
#import "EventWebViewController.h"

@implementation MyEventsDetailViewController

@synthesize event;
@synthesize context;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = event.title;
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
    [super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 6;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		default:
			return 1;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Event Title";
			break;
		case 1:
			return @"Date";
			break;
		case 2:
			return @"Description";
			break;
		case 3:
			return @"Share";
			break;
		case 4:
			return @"Link";
			break;
		default:
			return @"";
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"heightForRowAtIndexPath");
	NSString *cellText;
	switch ([indexPath section]) {
		case 0:
			cellText = event.title;
			break;
		case 1:
			cellText = [dateFormatter stringFromDate:event.eventDate];
			break;
		case 2:
			cellText = event.feedDescription;
			break;
		default:
			return 44;
			break;
	}
	UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
	CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
	CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
	return labelSize.height + 15;	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"cellForRowAtIndexPath called");
	
	// intentionally not dequeuing
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	cell.textLabel.textAlignment = UITextAlignmentLeft;
	cell.textLabel.textColor = [UIColor blackColor];
	cell.backgroundColor = [UIColor whiteColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	// as many lines as it needs
	cell.textLabel.numberOfLines = 0;
	
	switch ([indexPath section]) {
		case 0:
			cell.textLabel.text = event.title;
			break;
		case 1:
			cell.textLabel.text = [dateFormatter stringFromDate:event.eventDate];
			break;
		case 2:
			cell.textLabel.text = [NSString	stringWithFormat:@"\n%@", event.feedDescription];
			break;
		case 3:
			cell.textLabel.text = @"Email";
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.numberOfLines = 1;
			break;
		case 4:
			cell.textLabel.text = event.guid;
			cell.textLabel.numberOfLines = 1;
			cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			break;
		case 5:
			cell.textLabel.text = @"Remove Event";
			cell.textLabel.numberOfLines = 1;
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.textColor = [UIColor whiteColor];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
			cell.textLabel.backgroundColor = [UIColor clearColor];
			cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedButton.jpg"]];
			cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DarkRedButton.jpg"]];
			cell.textLabel.shadowColor = [UIColor darkGrayColor];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			break;
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([indexPath section] == 3) {
		[self sendEmail];
	} else if([indexPath section] == 4) {
		EventWebViewController *eventWebViewController = [[EventWebViewController alloc] initWithNibName:@"EventWebViewController" bundle:nil];
		[self.navigationController pushViewController:eventWebViewController animated:YES];
		eventWebViewController.title = event.title;
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&show_small_window=T", [self trim:event.feedDetailUri]]];
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
		[eventWebViewController.eventWebView loadRequest:request];
		[eventWebViewController release];
	} else if([indexPath section] == 5) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Removal" 
														message:[NSString stringWithFormat:@"Are you sure you want to remove %@", event.title]
													   delegate:self cancelButtonTitle:@"Cancel" 
											  otherButtonTitles:@"Yes", nil];
		[alert show];
		[alert release];
	}
}

#pragma mark -

#pragma mark AlertViewDelgate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	switch(buttonIndex) {
		case 0:
			//cancel
			break;
		case 1:
			[context deleteObject:event];
			[self.navigationController popViewControllerAnimated:YES];
			break;
		default:
			break;
	}
}
#pragma mark -

#pragma mark Compose Mail
/*
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 This code has been modified from its original source (above) to fit the needs of the RIT Events application
 */
-(void)sendEmail
{
	// This sample can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:event.title];
	
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"<br /><br /><b>Event Title:</b> %@<br /><br /><b>Date:</b> %@<br /><br /><b>Description:</b> %@<br /><br /><b>URL:</b> <a href=\"%@\">%@</a>", event.title, [dateFormatter stringFromDate:event.eventDate], event.feedDescription, event.feedDetailUri, event.feedDetailUri];
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *body = [NSString stringWithFormat:@"<br /><br /><b>Event Title:</b> %@<br /><br /><b>Date:</b> %@<br /><br /><b>Description:</b> %@<br /><br /><b>URL:</b> <a href=\"%@\">%@</a>", event.title, [dateFormatter stringFromDate:event.eventDate], event.feedDescription, event.feedDetailUri, event.feedDetailUri];
	
	NSString *email = [NSString stringWithFormat:@"%@%@", nil, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark -


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (NSString *)trim:(NSString *)original {
	NSMutableString *copy = [original mutableCopy];
	return [NSString stringWithString:[copy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)dealloc {
	[context release];
	[event release];
	[dateFormatter release];
    [super dealloc];
}


@end
