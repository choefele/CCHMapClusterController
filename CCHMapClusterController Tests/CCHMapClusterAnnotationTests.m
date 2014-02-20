//
//  CCHMapClusterAnnotationTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus on 20.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "CCHMapClusterAnnotation.h"

#import <XCTest/XCTest.h>

@interface CCHMapClusterAnnotationTests : XCTestCase

@property (nonatomic, strong) CCHMapClusterAnnotation *clusterAnnotation;

@end

@implementation CCHMapClusterAnnotationTests

- (void)setUp
{
    [super setUp];
    
    self.clusterAnnotation = [[CCHMapClusterAnnotation alloc] init];
}

- (void)testIsCluster
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    XCTAssertTrue(self.clusterAnnotation.isCluster);
}

- (void)testIsNotCluster
{
    XCTAssertFalse(self.clusterAnnotation.isCluster);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation]];
    XCTAssertFalse(self.clusterAnnotation.isCluster);
}

- (void)testIsOneLocation
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation0.coordinate;
    
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0]];
    XCTAssertTrue(self.clusterAnnotation.isOneLocation);

    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    XCTAssertTrue(self.clusterAnnotation.isOneLocation);
}

- (void)testIsNotOneLocation
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(50.1, 12.0);
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    XCTAssertFalse(self.clusterAnnotation.isOneLocation);
}

- (void)testMapRectIncludesClusterCoordinate
{
    self.clusterAnnotation.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    MKMapRect mapRect = self.clusterAnnotation.mapRect;
    XCTAssertTrue(MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(self.clusterAnnotation.coordinate)));
}

- (void)testMapRectSingle
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0]];
    MKMapRect mapRect = self.clusterAnnotation.mapRect;
    XCTAssertTrue(MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(annotation0.coordinate)));
}

- (void)testMapRectMultiple
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(10.5, 78.0);
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    MKMapRect mapRect = self.clusterAnnotation.mapRect;
    XCTAssertTrue(MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(annotation0.coordinate)));
    XCTAssertTrue(MKMapRectContainsPoint(mapRect, MKMapPointForCoordinate(annotation1.coordinate)));
}


@end
