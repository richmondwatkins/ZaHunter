//
//  PizzaLocation.m
//  ZaHunter
//
//  Created by Richmond on 10/15/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PizzaLocation.h"

@implementation PizzaLocation

+(PizzaLocation *)createPizzeria:(MKMapItem *)mapitem distanceFromUserLocation:(CLLocation *)userLocation{
    PizzaLocation *location = [[PizzaLocation alloc]init];
    location.pizzaMapItem = mapitem;
    location.name = mapitem.name;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    MKPlacemark *placemark = mapitem.placemark;
    annotation.coordinate = placemark.location.coordinate;

    CLLocation *pizzaLocation = [[CLLocation alloc] initWithCoordinate: placemark.location.coordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    location.distanceFromUser = [userLocation distanceFromLocation:pizzaLocation];
    annotation.title = [NSString stringWithFormat:@"%.0f meters from your location", location.distanceFromUser ];

    location.pizzaAnnotation = annotation;

    return location;
}


@end
