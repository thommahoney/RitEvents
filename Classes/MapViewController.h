//
//  MapViewController.h
//  RitEvents
//
//  Created by Thomas Mahoney on 2/14/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController <MKMapViewDelegate> {
	IBOutlet MKMapView *locationMapView;
	NSNumber *latitude;
	NSNumber *longitude;
}

@property (nonatomic, retain) IBOutlet MKMapView *locationMapView;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

@end
