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

@property (strong, nonatomic) DataReader *dataReader;
@property (strong, nonatomic) Settings *settings;
@property (strong, nonatomic) CCHMapClusterController *mapClusterController;
@property (strong, nonatomic) id<CCHMapClusterer> mapClusterer;
@property (strong, nonatomic) id<CCHMapAnimator> mapAnimator;

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
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    // Read annotations
    self.dataReader = [[DataReader alloc] init];
    self.dataReader.delegate = self;

    // Settings
    [self resetSettings];
}

- (IBAction)resetSettings
{
    Settings *settings = [[Settings alloc] init];
    [self updateWithSettings:settings];
}

- (void)updateWithSettings:(Settings *)settings
{
    self.settings = settings;
    
    // Reset
    [self.dataReader stopReadingData];
    [self.mapClusterController removeAnnotations:self.mapClusterController.annotations.allObjects withCompletionHandler:NULL];
    for (id<MKOverlay> overlay in self.mapView.overlays) {
        [self.mapView removeOverlay:overlay];
    }
    
    // Map cluster controller settings
    self.mapClusterController.debuggingEnabled = settings.isDebuggingEnabled;
    self.mapClusterController.cellSize = settings.cellSize;
    self.mapClusterController.marginFactor = settings.marginFactor;
    
    if (settings.clusterer == SettingsClustererCenterOfMass) {
        self.mapClusterer = [[CCHCenterOfMassMapClusterer alloc] init];
    } else if (settings.clusterer == SettingsClustererNearCenter) {
        self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
    }
    self.mapClusterController.clusterer = self.mapClusterer;

    if (settings.animator == SettingsAnimatorFadeInOut) {
        self.mapAnimator = [[CCHFadeInOutMapAnimator alloc] init];
    }
    self.mapClusterController.animator = self.mapAnimator;

    // Region and data
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
}

- (void)dataReader:(DataReader *)dataReader addAnnotations:(NSArray *)annotations
{
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
