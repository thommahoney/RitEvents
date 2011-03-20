//
//  FeedDetailViewController.h
//  RitEvents
//
//  Created by Andrew Church on 14/02/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import "FeedEvent.h"
#import "FavoriteEvent.h"

@interface FeedDetailViewController : UIViewController <MFMailComposeViewControllerDelegate> {
	NSManagedObjectContext *context;
	FeedEvent *event;
	NSDateFormatter *dateFormatter;
}

@property (nonatomic,retain) NSManagedObjectContext *context;
@property (nonatomic,retain) FeedEvent *event;

- (void)addToMyEvents;
- (void)sendEmail;
- (void)displayComposerSheet;
- (void)launchMailAppOnDevice;
- (NSString *)trim:(NSString *)original;


@end
