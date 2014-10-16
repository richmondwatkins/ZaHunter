//
//  ViewController.m
//  ZaHunter
//
//  Created by Richmond on 10/15/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "PizzaLocation.h"
@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITabBarDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManger;
@property NSMutableArray *pizzaMapItemArray;
@property NSMutableArray *pizzaArray;
@property float walkingTime;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManger = [[CLLocationManager alloc] init];
    [self.locationManger requestWhenInUseAuthorization];
    self.locationManger.delegate = self;
    [self.locationManger startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for(CLLocation *location in locations){
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            [self findPizzaLocations:location];
            [self.locationManger stopUpdatingLocation];
            break;
        }
    }
}



-(void)findPizzaLocations:(CLLocation *)location{
    MKLocalSearchRequest *localSearchRequest = [[MKLocalSearchRequest alloc] init];
    localSearchRequest.naturalLanguageQuery = @"pizzeria";
    localSearchRequest.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));

    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        self.pizzaMapItemArray = [[NSMutableArray alloc] init];
        self.pizzaArray = [[NSMutableArray alloc] init];
        for(MKMapItem *mapItem in response.mapItems){
            PizzaLocation *pizzeria = [PizzaLocation createPizzeria:mapItem distanceFromUserLocation:location];
            if (pizzeria.distanceFromUser < 10000) {
                [self.pizzaArray addObject:pizzeria];
                [self.pizzaMapItemArray addObject:pizzeria.pizzaMapItem];
                [self.mapView addAnnotation:pizzeria.pizzaAnnotation];
            }
        }

        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
        [self showTotalWalkingTime];
        [self.tableView reloadData];
    }];
}

-(void)showTotalWalkingTime{
    [self.pizzaMapItemArray addObject:[MKMapItem mapItemForCurrentLocation]];
    for(int i = 0; i <= self.pizzaMapItemArray.count; i++){
        if (i < self.pizzaMapItemArray.count-1) {
            MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
            [directionRequest setSource:self.pizzaMapItemArray[i]];

            [directionRequest setDestination:self.pizzaMapItemArray[(i+1)]];
            directionRequest.transportType = MKDirectionsTransportTypeWalking;
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                MKRoute *route = response.routes.firstObject;
                self.walkingTime += (route.expectedTravelTime / 60) +50;
                self.title = [NSString stringWithFormat:@"%.0f", self.walkingTime];
            }];

        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.pizzaArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];

    PizzaLocation *pizzeria = [self.pizzaArray objectAtIndex:indexPath.row];
    NSLog(@"%@", pizzeria);
    cell.textLabel.text = pizzeria.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", pizzeria.distanceFromUser ];

    return cell;
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

- (IBAction)segmentControlChange:(UISegmentedControl *)sender {

    if (sender.selectedSegmentIndex) {
        self.tableView.hidden = YES;

    }else{
        self.tableView.hidden = NO;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}

@end
