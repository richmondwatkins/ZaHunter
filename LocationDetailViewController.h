//
//  LocationDetailViewController.h
//  ZaHunter
//
//  Created by Richmond on 10/15/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PizzaLocation.h"
@interface LocationDetailViewController : UIViewController
@property PizzaLocation *pizzeria;
@property CLLocationCoordinate2D userLocation;
@end
