//
//  LocationDetailViewController.m
//  ZaHunter
//
//  Created by Richmond on 10/15/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "LocationDetailViewController.h"
#import <MapKit/MapKit.h>
@interface LocationDetailViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property  MKRoute *route;
@end

@implementation LocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.mapView addAnnotation:self.pizzeria.pizzaAnnotation];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = self.userLocation;
    NSArray *annotations = [[NSArray alloc] initWithObjects:annotation, self.pizzeria.pizzaAnnotation, nil];
    [self.mapView showAnnotations:annotations animated:YES];
    [self findRoute];
}


- (IBAction)findRoute{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:self.pizzeria.placemark];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
           self.route = response.routes.lastObject;
            [self.mapView addOverlay:self.route.polyline];
        }
    }];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.route.polyline];
    routeLineRenderer.strokeColor = [UIColor blueColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{

    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

@end
