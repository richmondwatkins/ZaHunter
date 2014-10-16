//
//  PizzaLocation.h
//  ZaHunter
//
//  Created by Richmond on 10/15/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PizzaLocation : NSObject

@property MKPointAnnotation *pizzaAnnotation;
@property CLLocationDistance distanceFromUser;
@property MKMapItem *pizzaMapItem;
@property NSString *name;
+(PizzaLocation *)createPizzeria:(MKMapItem *)mapitem distanceFromUserLocation:(CLLocation *)userLocation;

@end
