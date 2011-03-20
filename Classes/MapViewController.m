//
//  MapViewController.m
//  RitEvents
//
//  Created by Thomas Mahoney on 2/14/10.
//  Copyright 2010 Home Use. All rights reserved.
//

#import "MapViewController.h"
#import "LocationAnnotation.h"

@implementation MapViewController

@synthesize locationMapView;
@synthesize latitude;
@synthesize longitude;

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
	locationMapView.delegate = self;
	
	// Move the map to the right location and zoom in
	MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
	region.center.latitude = 43.084187;
	region.center.longitude = -77.675476;
	region.span.longitudeDelta = 0.019569;
	region.span.latitudeDelta = 0.014669;
	[locationMapView setRegion:region animated:YES];
	
	// add the annotation for the location selected
	LocationAnnotation *annot = [[LocationAnnotation alloc] init];
	annot.title = self.title;
	CLLocationCoordinate2D coord = { [self.latitude doubleValue], [self.longitude doubleValue]};
	annot.coordinate = coord;
	[locationMapView addAnnotation:annot];
	[annot release];
	
    [super viewDidLoad];
}

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

#pragma mark MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	NSLog(@"viewForAnnotation");
	MKPinAnnotationView *pinView = nil;
	if(annotation != mapView.userLocation) {
		static NSString *defaultPinID = @"RitEventsPin";
		pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil ) {
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
		}
		pinView.pinColor = MKPinAnnotationColorGreen;
		pinView.canShowCallout = YES;
		pinView.animatesDrop = YES;
	} else {
		NSLog(@"setting user location title to \"You are here\"");
        [mapView.userLocation setTitle:@"You are here"];
	}
    return pinView;
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	NSLog(@"didAddAnnotationViews");
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	NSLog(@"regionDidChangeAnimated");
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
	NSLog(@"mapViewDidFailLoadingMap");
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	NSLog(@"mapViewDidFinishLoadingMap");
}
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	NSLog(@"mapViewWillStartLoadingMap");
}
#pragma mark -

- (void)dealloc {
	[locationMapView release];
	[latitude release];
	[longitude release];
    [super dealloc];
}


@end
