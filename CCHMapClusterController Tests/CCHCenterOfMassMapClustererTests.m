//
//  CCHCenterOfMassMapClustererTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 05.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHCenterOfMassMapClusterer.h"

@interface CCHCenterOfMassMapClustererTests : XCTestCase

@property (nonatomic, strong) CCHCenterOfMassMapClusterer *mapClusterer;

@end

@implementation CCHCenterOfMassMapClustererTests

- (void)setUp
{
    [super setUp];
    
    self.mapClusterer = [[CCHCenterOfMassMapClusterer alloc] init];
}

- (void)testCoordinateForAnnotationsNil
{
    CLLocationCoordinate2D coordinate = [self.mapClusterer mapClusterController:nil coordinateForAnnotations:nil inMapRect:MKMapRectNull];
    XCTAssertEqual(coordinate.latitude, 0.0);
    XCTAssertEqual(coordinate.longitude, 0.0);
}

- (void)testCoordinateForAnnotationsEmpty
{
    NSMutableSet *annotations = [[NSMutableSet alloc] init];
    CLLocationCoordinate2D coordinate = [self.mapClusterer mapClusterController:nil coordinateForAnnotations:annotations inMapRect:MKMapRectNull];
    XCTAssertEqual(coordinate.latitude, 0.0);
    XCTAssertEqual(coordinate.longitude, 0.0);
}

- (void)testCoordinateForAnnotations
{
    NSMutableSet *annotations = [[NSMutableSet alloc] initWithCapacity:4];
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(10, 0);
    [annotations addObject:annotation0];
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(10, 10);
    [annotations addObject:annotation1];
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(10, 20);
    [annotations addObject:annotation2];
    MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
    annotation3.coordinate = CLLocationCoordinate2DMake(10, 30);
    [annotations addObject:annotation3];
    
    CLLocationCoordinate2D averageCoordinate = CLLocationCoordinate2DMake(40 / 4, 60 / 4);
    CLLocationCoordinate2D coordinate = [self.mapClusterer mapClusterController:nil coordinateForAnnotations:annotations inMapRect:MKMapRectNull];
    XCTAssertEqualWithAccuracy(averageCoordinate.latitude, coordinate.latitude, __FLT_EPSILON__);
    XCTAssertEqualWithAccuracy(averageCoordinate.longitude, coordinate.longitude, __FLT_EPSILON__);
}

@end
