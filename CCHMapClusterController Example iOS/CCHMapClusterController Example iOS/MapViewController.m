//
//  ViewController.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 27.11.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "MapViewController.h"

#import "DataReader.h"
#import "DataReaderDelegate.h"
#import "ClusterAnnotationView.h"
#import "SettingsViewController.h"
#import "Settings.h"

#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHCenterOfMassMapClusterer.h"
#import "CCHNearCenterMapClusterer.h"
#import "CCHFadeInOutMapAnimator.h"

@interface MapViewController()<DataReaderDelegate, CCHMapClusterControllerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) DataReader *dataReader;
@property (nonatomic) Settings *settings;
@property (nonatomic) CCHMapClusterController *mapClusterControllerRed;
@property (nonatomic) CCHMapClusterController *mapClusterControllerBlue;
@property (nonatomic) NSUInteger count;
@property (nonatomic) id<CCHMapClusterer> mapClusterer;
@property (nonatomic) id<CCHMapAnimator> mapAnimator;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Early out when running unit tests
    BOOL runningTests = NSClassFromString(@"XCTestCase") != nil;
    if (runningTests) {
        return;
    }
    
    // Set up map clustering
    self.mapClusterControllerRed = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterControllerRed.delegate = self;
    
    // Read annotations
    self.dataReader = [[DataReader alloc] init];
    self.dataReader.delegate = self;

    // Settings
    [self resetSettings];
}

- (IBAction)resetSettings
{
    self.count = 0;
    Settings *settings = [[Settings alloc] init];
    [self updateWithSettings:settings];
}

- (void)updateWithSettings:(Settings *)settings
{
    self.settings = settings;
    
    // Map cluster controller settings
    self.mapClusterControllerRed.debuggingEnabled = settings.isDebuggingEnabled;
    self.mapClusterControllerRed.cellSize = settings.cellSize;
    self.mapClusterControllerRed.marginFactor = settings.marginFactor;
    
    if (settings.clusterer == SettingsClustererCenterOfMass) {
        self.mapClusterer = [[CCHCenterOfMassMapClusterer alloc] init];
    } else if (settings.clusterer == SettingsClustererNearCenter) {
        self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
    }
    self.mapClusterControllerRed.clusterer = self.mapClusterer;
    self.mapClusterControllerRed.maxZoomLevelForClustering = settings.maxZoomLevelForClustering;
    self.mapClusterControllerRed.minUniqueLocationsForClustering = settings.minUniqueLocationsForClustering;

    if (settings.animator == SettingsAnimatorFadeInOut) {
        self.mapAnimator = [[CCHFadeInOutMapAnimator alloc] init];
    }
    self.mapClusterControllerRed.animator = self.mapAnimator;
    
    // Similar settings for second cluster controller
    if (settings.isGroupingEnabled) {
        if (self.mapClusterControllerBlue == nil) {
            self.mapClusterControllerBlue = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
            self.mapClusterControllerBlue.delegate = self;
        }
        
        self.mapClusterControllerBlue.debuggingEnabled = settings.isDebuggingEnabled;
        self.mapClusterControllerBlue.cellSize = settings.cellSize + 20;
        self.mapClusterControllerBlue.marginFactor = settings.marginFactor;
        self.mapClusterControllerBlue.clusterer = self.mapClusterer;
        self.mapClusterControllerBlue.maxZoomLevelForClustering = settings.maxZoomLevelForClustering;
        self.mapClusterControllerBlue.minUniqueLocationsForClustering = settings.minUniqueLocationsForClustering;
        self.mapClusterControllerBlue.animator = self.mapAnimator;
    } else {
        self.mapClusterControllerBlue = nil;
    }
    
    // Restart data reader
    self.count = 0;
    [self.dataReader stopReadingData];

    MKCoordinateRegion region;
    if (self.settings.dataSet == SettingsDataSetBerlin) {
        // 5000+ items near Berlin
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.516221, 13.377829);
        region = MKCoordinateRegionMakeWithDistance(location, 45000, 45000);
        [self.dataReader startReadingBerlinData];
    } else {
        // 80000+ items in the US
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(39.833333, -98.583333);
        region = MKCoordinateRegionMakeWithDistance(location, 7000000, 7000000);
        [self.dataReader startReadingUSData];
    }
    self.mapView.region = region;
    
    // Remove all current items form the map
    [self.mapClusterControllerRed removeAnnotations:self.mapClusterControllerRed.annotations.allObjects withCompletionHandler:NULL];
    [self.mapClusterControllerBlue removeAnnotations:self.mapClusterControllerBlue.annotations.allObjects withCompletionHandler:NULL];
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        [self.mapView removeOverlay:overlay];
    }
}

- (void)dataReader:(DataReader *)dataReader addAnnotations:(NSArray *)annotations
{
    if (self.settings.isGroupingEnabled) {
        if (self.count++ % 2 == 0) {
            [self.mapClusterControllerRed addAnnotations:annotations withCompletionHandler:NULL];
        } else {
            [self.mapClusterControllerBlue addAnnotations:annotations withCompletionHandler:NULL];
        }
    } else {
        [self.mapClusterControllerRed addAnnotations:annotations withCompletionHandler:NULL];        
    }
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
    ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.mapView viewForAnnotation:mapClusterAnnotation];
    clusterAnnotationView.count = mapClusterAnnotation.annotations.count;
    clusterAnnotationView.uniqueLocation = mapClusterAnnotation.isUniqueLocation;
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
        clusterAnnotationView.blue = (clusterAnnotation.mapClusterController == self.mapClusterControllerBlue);
        clusterAnnotationView.uniqueLocation = clusterAnnotation.isUniqueLocation;
        annotationView = clusterAnnotationView;
    }
    
    return annotationView;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapToSettings"]) {
        UINavigationController *navigationViewController = (UINavigationController *)segue.destinationViewController;
        SettingsViewController *settingsViewController = (SettingsViewController *)navigationViewController.topViewController;
        settingsViewController.settings = self.settings;
        settingsViewController.completionBlock = ^(Settings *settings) {
            [self updateWithSettings:settings];
        };
    }
}

@end
