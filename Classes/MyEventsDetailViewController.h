//
//  MyEventsDetailViewController.h
//  RitEvents
//
//  Created by Thomas Mahoney on 2/20/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import "FavoriteEvent.h"

@interface MyEventsDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
	NSManagedObjectContext *context;
	FavoriteEvent *event;
	NSDateFormatter *dateFormatter;
}

- (NSString *)trim:(NSString *)original;
- (void)sendEmail;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;

@property (retain, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, retain) FavoriteEvent *event;

@end
