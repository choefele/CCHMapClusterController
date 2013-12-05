//
//  CCHNearCenterMapClustererTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 05.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHNearCenterMapClusterer.h"

@interface CCHNearCenterMapClustererTests : XCTestCase

@property (nonatomic, strong) CCHNearCenterMapClusterer *mapClusterer;

@end

@implementation CCHNearCenterMapClustererTests

- (void)setUp
{
    [super setUp];

    self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
}

- (void)testFindClosestAnnotationNil
{
    CLLocationCoordinate2D coordinate = [self.mapClusterer coordinateForAnnotations:nil inMapRect:MKMapRectNull];
    XCTAssertEqual(coordinate.latitude, 0.0, @"Wrong coordinate");
    XCTAssertEqual(coordinate.longitude, 0.0, @"Wrong coordinate");
}

- (void)testFindClosestAnnotationEmpty
{
    NSMutableSet *annotations = [[NSMutableSet alloc] init];
    CLLocationCoordinate2D coordinate = [self.mapClusterer coordinateForAnnotations:annotations inMapRect:MKMapRectNull];
    XCTAssertEqual(coordinate.latitude, 0.0, @"Wrong coordinate");
    XCTAssertEqual(coordinate.longitude, 0.0, @"Wrong coordinate");
}

- (void)testFindClosestAnnotation
{
    MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(45, 45));
    MKMapRect mapRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0, 0);
    mapRect = MKMapRectInset(mapRect, -10000, -10000);

    NSMutableSet *annotations = [[NSMutableSet alloc] initWithCapacity:5];
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(40, 40);
    [annotations addObject:annotation0];
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(47, 47);
    [annotations addObject:annotation1];
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(45.1, 44.9);
    [annotations addObject:annotation2];
    MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
    annotation3.coordinate = CLLocationCoordinate2DMake(42.1, 43.7);
    [annotations addObject:annotation3];

    CLLocationCoordinate2D coordinate = [self.mapClusterer coordinateForAnnotations:annotations inMapRect:mapRect];
    XCTAssertEqual(annotation2.coordinate.latitude, coordinate.latitude, @"Wrong coordinate");
    XCTAssertEqual(annotation2.coordinate.longitude, coordinate.longitude, @"Wrong coordinate");
}

@end
