//
//  EventWebViewController.h
//  RitEvents
//
//  Created by Thomas Mahoney on 2/20/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EventWebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *eventWebView;
}

@property (nonatomic, retain) IBOutlet UIWebView *eventWebView;

@end
