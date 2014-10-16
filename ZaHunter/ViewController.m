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
#import "LocationDetailViewController.h"
@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITabBarDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManger;
@property NSMutableArray *pizzaMapItemArray;
@property NSMutableArray *pizzaArray;
@property NSMutableDictionary *pizzaDictionary;
@property PizzaLocation *foundPizzeria;
@property float transportTime;
@property CLLocationCoordinate2D userLocation;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *travelTimeLabel;
@property NSIndexPath *swipedCell;
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
            self.userLocation = location.coordinate;
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
        self.pizzaDictionary = [[NSMutableDictionary alloc] init];
        for(MKMapItem *mapItem in response.mapItems){
            PizzaLocation *pizzeria = [PizzaLocation createPizzeria:mapItem distanceFromUserLocation:location];
            [self.pizzaArray addObject:pizzeria];
            [self.pizzaDictionary setObject:pizzeria forKey:pizzeria.pizzaAnnotation.title];
            [self.pizzaMapItemArray addObject:pizzeria.pizzaMapItem];
        }

        [self addAnnotationsToMap];
        [self.tableView reloadData];
    }];
}

-(void)addAnnotationsToMap{
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"distanceFromUser" ascending:YES];
    [self.pizzaArray sortUsingDescriptors:[NSArray arrayWithObject:sorter]];

    for (int i = 0; i <=3; i++) {
        PizzaLocation *pizzeria = self.pizzaArray[i];
        [self.mapView addAnnotation:pizzeria.pizzaAnnotation];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self showTotalTravelTime:(MKDirectionsTransportType)MKDirectionsTransportTypeWalking];
}

-(void)showTotalTravelTime:(MKDirectionsTransportType)transportType{
    [self.pizzaMapItemArray addObject:[MKMapItem mapItemForCurrentLocation]];
    for(int i = 0; i <= self.pizzaMapItemArray.count; i++){
        if (i < self.pizzaMapItemArray.count-1) {
            MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
            [directionRequest setSource:self.pizzaMapItemArray[i]];

            [directionRequest setDestination:self.pizzaMapItemArray[i+1]];
            directionRequest.transportType = transportType;
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                MKRoute *route = response.routes.firstObject;
                self.transportTime += ((route.expectedTravelTime / 60) +50) / 60;
                self.travelTimeLabel.text = [NSString stringWithFormat:@"%.0f hours", self.transportTime];
            }];

        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];

    PizzaLocation *pizzeria = [self.pizzaArray objectAtIndex:indexPath.row];
    cell.textLabel.text = pizzeria.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", pizzeria.distanceFromUser ];

    return cell;
}

- (IBAction)swipedTableCell:(UIPanGestureRecognizer *)swipe {
    self.swipedCell = [self.tableView indexPathForRowAtPoint:[swipe locationInView:self.tableView]];
    [self.tableView setEditing:YES animated:YES];
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.pizzaArray removeObjectAtIndex:indexPath.row];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView setEditing:NO animated:YES];
    [self.tableView reloadData];
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
    self.foundPizzeria = [self.pizzaDictionary objectForKey:view.annotation.title];
    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DetailSegue"]) {
        LocationDetailViewController *locationCtrl = [segue destinationViewController];
        locationCtrl.pizzeria = self.foundPizzeria;
        locationCtrl.userLocation  = self.userLocation;
    }
}
- (IBAction)walkOrDriveSegmentControl:(UISegmentedControl *)sender {
    self.transportTime = 0;
    if (sender.selectedSegmentIndex) {
        [self showTotalTravelTime:(MKDirectionsTransportType)MKDirectionsTransportTypeAutomobile];
    }else{
        [self showTotalTravelTime:(MKDirectionsTransportType)MKDirectionsTransportTypeWalking];
    }
}

@end
