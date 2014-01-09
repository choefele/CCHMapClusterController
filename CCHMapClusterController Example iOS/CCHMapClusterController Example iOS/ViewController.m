//
//  ViewController.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 27.11.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "ViewController.h"

#import "DataReader.h"
#import "DataReaderDelegate.h"
#import "ClusterAnnotationView.h"

#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHCenterOfMassMapClusterer.h"

@interface ViewController()<DataReaderDelegate, CCHMapClusterControllerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CCHMapClusterController *mapClusterController;
@property (strong, nonatomic) id<CCHMapClusterer> mapClusterer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Early out when running unit tests
    BOOL runningTests = NSClassFromString(@"XCTestCase") != nil;
    if (runningTests) {
        return;
    }
    
    // Set up map clustering
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    // Cell size and margin factor
//    self.mapClusterController.cellSize = 100;           // [points]
//    self.mapClusterController.marginFactor = 0;         // 0 = no additional margin
//    self.mapClusterController.debuggingEnabled = YES;   // display grid
    
    // Positioning cluster representations
//    self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
//    self.mapClusterController.clusterer = self.mapClusterer;        // change default clusterer
//    self.mapClusterController.reuseExistingClusterAnnotations = NO; // YES to avoid updating positions
    
    // Read annotations
    DataReader *dataReader = [[DataReader alloc] init];
    dataReader.delegate = self;

    // 5000+ items near Berlin in JSON format
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.516221, 13.377829);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 45000, 45000);
    [dataReader startReadingJSON];
    
    // 80000+ items in the US
//    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(39.833333, -98.583333);
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 7000000, 7000000);
//    [dataReader startReadingCSV];
    
    self.mapView.region = region;
    self.mapView.delegate = self;
}

- (void)dataReader:(DataReader *)dataReader addAnnotations:(NSArray *)annotations
{
//    [self.mapView addAnnotations:annotations];
    [self.mapClusterController addAnnotations:annotations withCompletionHandler:NULL];
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;
    NSString *unit = numAnnotations > 1 ? @"annotations" : @"annotation";
    return [NSString stringWithFormat:@"%tu %@", numAnnotations, unit];
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = MIN(mapClusterAnnotation.annotations.count, 5);
    NSArray *annotations = [mapClusterAnnotation.annotations.allObjects subarrayWithRange:NSMakeRange(0, numAnnotations)];
    NSArray *titles = [annotations valueForKey:@"title"];
    return [titles componentsJoinedByString:@", "];
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.mapClusterController.mapView viewForAnnotation:mapClusterAnnotation];
    clusterAnnotationView.count = mapClusterAnnotation.annotations.count;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        static NSString *identifier = @"clusterAnnotation";
        
        ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (clusterAnnotationView) {
            clusterAnnotationView.annotation = annotation;
        } else {
            clusterAnnotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            clusterAnnotationView.canShowCallout = YES;
        }
        
        CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotation;
        clusterAnnotationView.count = clusterAnnotation.annotations.count;
        annotationView = clusterAnnotationView;
    }
    
    return annotationView;
}

@end
