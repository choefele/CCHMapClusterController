//
//  ViewController.m
//  CCHMapClustering Example iOS
//
//  Created by Claus on 25.11.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "MapViewController.h"

#import "DataReader.h"
#import "DataReaderDelegate.h"

@interface MapViewController ()<DataReaderDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show Berlin
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.516221, 13.377829);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 45000, 45000);
    self.mapView.region = region;
    
    // Add annotations
    DataReader *dataReader = [[DataReader alloc] init];
    dataReader.delegate = self;
    [dataReader startReading];
}

- (void)dataReader:(DataReader *)dataReader addAnnotations:(NSArray *)annotations
{
    [self.mapView addAnnotations:annotations];
}

@end
