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
@property NSString *test;
+(PizzaLocation *)createPizzeria:(MKMapItem *)mapitem distanceFromUserLocation:(CLLocation *)userLocation;

@end
