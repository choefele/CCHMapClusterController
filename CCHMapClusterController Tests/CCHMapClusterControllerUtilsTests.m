//
//  CCHMapClusterControllerUtilsTests.m
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

#import <XCTest/XCTest.h>

#import "CCHMapClusterControllerUtils.h"
#import "CCHMapClusterAnnotation.h"

@interface CCHMapClusterControllerUtilsTests : XCTestCase

@end

@implementation CCHMapClusterControllerUtilsTests

- (void)testAlignToCellSize
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 15, 20);
    MKMapRect adjustedMapRect = CCHMapClusterControllerAlignToCellSize(mapRect, 5);
    XCTAssertEqual(adjustedMapRect.origin.x, 0.0, @"Wrong origin x");
    XCTAssertEqual(adjustedMapRect.origin.y, 0.0, @"Wrong origin y");
    XCTAssertEqual(adjustedMapRect.size.width, 15.0, @"Wrong size width");
    XCTAssertEqual(adjustedMapRect.size.height, 20.0, @"Wrong size height");

    mapRect = MKMapRectMake(8, 8, 15, 20);
    adjustedMapRect = CCHMapClusterControllerAlignToCellSize(mapRect, 6);
    XCTAssertEqual(adjustedMapRect.origin.x, 6.0, @"Wrong origin x");
    XCTAssertEqual(adjustedMapRect.origin.y, 6.0, @"Wrong origin y");
    XCTAssertEqual(adjustedMapRect.size.width, 18.0, @"Wrong size width");
    XCTAssertEqual(adjustedMapRect.size.height, 24.0, @"Wrong size height");
}

- (void)testFindVisibleAnnotation
{
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    NSSet *annotations = [NSSet setWithObjects:[[MKPointAnnotation alloc] init], [[MKPointAnnotation alloc] init], pointAnnotation, nil];
    NSMutableSet *visibleAnnotations = [NSMutableSet set];
    
    // Empty cluster
    CCHMapClusterAnnotation *clusterAnnotationEmpty = [[CCHMapClusterAnnotation alloc] init];
    [visibleAnnotations addObject:clusterAnnotationEmpty];
    CCHMapClusterAnnotation *visibleAnnotation = CCHMapClusterControllerFindVisibleAnnotation(annotations, visibleAnnotations);
    XCTAssertNil(visibleAnnotation, @"Wrong visible annotation");
    
    // Cluster does not contain annotation
    CCHMapClusterAnnotation *clusterAnnotationDoesNotContain = [[CCHMapClusterAnnotation alloc] init];
    [visibleAnnotations addObject:clusterAnnotationDoesNotContain];
    visibleAnnotation = CCHMapClusterControllerFindVisibleAnnotation(annotations, visibleAnnotations);
    XCTAssertNil(visibleAnnotation, @"Wrong visible annotation");
    
    // Cluster does contain annotation
    CCHMapClusterAnnotation *clusterAnnotationContains = [[CCHMapClusterAnnotation alloc] init];
    clusterAnnotationContains.annotations = @[[[MKPointAnnotation alloc] init], pointAnnotation, [[MKPointAnnotation alloc] init], [[MKPointAnnotation alloc] init]];
    [visibleAnnotations addObject:clusterAnnotationContains];
    visibleAnnotation = CCHMapClusterControllerFindVisibleAnnotation(annotations, visibleAnnotations);
    XCTAssertEqualObjects(clusterAnnotationContains, visibleAnnotation, @"Wrong visible annotation");
}

- (void)testCoordinateEqualToCoordinate
{
    // Same struct
    CLLocationCoordinate2D coordinate0 = CLLocationCoordinate2DMake(5.12, -0.72);
    XCTAssertTrue(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate0, coordinate0), @"Wrong coordinate");
    
    // Equal struct
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(5.12, -0.72);
    XCTAssertTrue(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate0, coordinate1), @"Wrong coordinate");

    // Longitude different
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(5.12, -0.73);
    XCTAssertFalse(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate1, coordinate2), @"Wrong coordinate");

    // Latitude different
    CLLocationCoordinate2D coordinate3 = CLLocationCoordinate2DMake(5.11, -0.72);
    XCTAssertFalse(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate1, coordinate3), @"Wrong coordinate");
}

- (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion
{
    CLLocationCoordinate2D topLeftCoordinate =
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                               + (coordinateRegion.span.latitudeDelta/2.0),
                               coordinateRegion.center.longitude
                               - (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate =
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                               - (coordinateRegion.span.latitudeDelta/2.0),
                               coordinateRegion.center.longitude
                               + (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x,
                                      topLeftMapPoint.y,
                                      fabs(bottomRightMapPoint.x-topLeftMapPoint.x),
                                      fabs(bottomRightMapPoint.y-topLeftMapPoint.y));
    
    return mapRect;
}

- (void)testClusterAnnotationForAnnotation
{
    MKMapRect mapRect = MKMapRectMake(10000000, 10000000, 20000000, 20000000);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionForMapRect(mapRect);

    CCHMapClusterAnnotation *mapClusterAnnotation = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation.coordinate = coordinateRegion.center;
    MKMapView *mapView = [[MKMapView alloc] init];
    [mapView addAnnotation:mapClusterAnnotation];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    // Cluster annotation doesn't contain annotation
    CCHMapClusterAnnotation *mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertNil(mapClusterAnnotationFound, @"Wrong cluster annotation");
    
    // Cluster annotation contains annotation
    mapClusterAnnotation.annotations = @[annotation];
    mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertEqualObjects(mapClusterAnnotation, mapClusterAnnotationFound, @"Wrong cluster annotation");

    // Cluster annotation outside map rect
    mapClusterAnnotation.coordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + 1.2 * coordinateRegion.span.latitudeDelta, coordinateRegion.center.longitude);
    mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertNil(mapClusterAnnotationFound, @"Wrong cluster annotation");
}

- (void)testClusterAnnotationForAnnotationMultiple
{
    MKMapRect mapRect = MKMapRectMake(10000000, 10000000, 20000000, 20000000);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionForMapRect(mapRect);
    
    MKMapView *mapView = [[MKMapView alloc] init];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    CCHMapClusterAnnotation *mapClusterAnnotation0 = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation0.coordinate = coordinateRegion.center;
    mapClusterAnnotation0.annotations = @[[[MKPointAnnotation alloc] init], annotation, [[MKPointAnnotation alloc] init]];
    [mapView addAnnotation:mapClusterAnnotation0];

    CCHMapClusterAnnotation *mapClusterAnnotation1 = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation1.coordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + 0.5, coordinateRegion.center.longitude + 0.5);
    mapClusterAnnotation1.annotations = @[[[MKPointAnnotation alloc] init], [[MKPointAnnotation alloc] init]];
    [mapView addAnnotation:mapClusterAnnotation1];

    CCHMapClusterAnnotation *mapClusterAnnotation2 = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation2.coordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - 0.5, coordinateRegion.center.longitude - 0.5);
    mapClusterAnnotation2.annotations = @[[[MKPointAnnotation alloc] init]];
    [mapView addAnnotation:mapClusterAnnotation2];
    
    CCHMapClusterAnnotation *mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertEqualObjects(mapClusterAnnotation0, mapClusterAnnotationFound, @"Wrong cluster annotation");
}

- (void)testEnumerateCells
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 100, 100);
    __block NSUInteger numCalls = 0;
    CCHMapClusterControllerEnumerateCells(mapRect, 10, ^(MKMapRect cellRect) {
        numCalls++;
        
        XCTAssertEqualWithAccuracy(cellRect.size.height, 10, __FLT_EPSILON__, @"Wrong size");
        XCTAssertEqualWithAccuracy(cellRect.size.width, 10, __FLT_EPSILON__, @"Wrong size");
    });
    XCTAssertEqual(numCalls, 100u, @"Wrong number of calls");
}

- (void)testEnumerateCellsAlign
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 95, 95);
    __block NSUInteger numCalls = 0;
    CCHMapClusterControllerEnumerateCells(mapRect, 10, ^(MKMapRect cellRect) {
        numCalls++;
        
        XCTAssertEqualWithAccuracy(cellRect.size.height, 10, __FLT_EPSILON__, @"Wrong size");
        XCTAssertEqualWithAccuracy(cellRect.size.width, 10, __FLT_EPSILON__, @"Wrong size");
    });
    XCTAssertEqual(numCalls, 100u, @"Wrong number of calls");
}

@end
