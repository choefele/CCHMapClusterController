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

#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHCenterOfMassMapClusterer.h"

@interface ViewController()<DataReaderDelegate, CCHMapClusterControllerDelegate>

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
    
    // Show Berlin
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.516221, 13.377829);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 45000, 45000);
    self.mapView.region = region;
    
    // Set up map clustering
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    // Cell size and margin factor
//    self.mapClusterController.cellSize = 100;           // [points]
//    self.mapClusterController.marginFactor = 0;         // 0 = no additional margin
//    self.mapClusterController.debuggingEnabled = YES;   // display grid
    
    // Positioning cluster representations
//    self.mapClusterer = [[CCHCenterOfMassMapClusterer alloc] init];
//    self.mapClusterController.clusterer = self.mapClusterer;        // change default clusterer
//    self.mapClusterController.reuseExistingClusterAnnotations = NO; // YES to avoid updating positions
    
    // Read annotations
    DataReader *dataReader = [[DataReader alloc] init];
    dataReader.delegate = self;
    [dataReader startReading];
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
    NSArray *annotations = [mapClusterAnnotation.annotations subarrayWithRange:NSMakeRange(0, numAnnotations)];
    NSArray *titles = [annotations valueForKey:@"title"];
    return [titles componentsJoinedByString:@", "];
}

@end
