//
//  CCHNearCenterMapClustererTests.m
//  CCHMapClusterController
//
//  Copyright (C) 2013 Claus Höfele
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCHNearCenterMapClusterer.h"

#import <XCTest/XCTest.h>

@interface CCHNearCenterMapClustererTests : XCTestCase

@property (nonatomic) CCHNearCenterMapClusterer *mapClusterer;

@end

@implementation CCHNearCenterMapClustererTests

- (void)setUp
{
    [super setUp];

    self.mapClusterer = [[CCHNearCenterMapClusterer alloc] init];
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
    MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(45, 45));
    MKMapRect mapRect = MKMapRectMake(mapPoint.x, mapPoint.y, 0, 0);
    mapRect = MKMapRectInset(mapRect, -10000, -10000);

    NSMutableSet *annotations = [[NSMutableSet alloc] initWithCapacity:4];
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

    CLLocationCoordinate2D coordinate = [self.mapClusterer mapClusterController:nil coordinateForAnnotations:annotations inMapRect:mapRect];
    XCTAssertEqualWithAccuracy(annotation2.coordinate.latitude, coordinate.latitude, __FLT_EPSILON__);
    XCTAssertEqualWithAccuracy(annotation2.coordinate.longitude, coordinate.longitude, __FLT_EPSILON__);
}

@end
