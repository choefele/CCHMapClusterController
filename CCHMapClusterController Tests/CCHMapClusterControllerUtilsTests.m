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

#import "CCHMapClusterControllerUtils.h"
#import "CCHMapClusterAnnotation.h"

#import <XCTest/XCTest.h>

@interface CCHMapClusterControllerUtilsTests : XCTestCase

@end

@implementation CCHMapClusterControllerUtilsTests

- (void)testAlignToCellSize
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 15, 20);
    MKMapRect adjustedMapRect = CCHMapClusterControllerAlignMapRectToCellSize(mapRect, 5);
    XCTAssertEqual(adjustedMapRect.origin.x, 0.0);
    XCTAssertEqual(adjustedMapRect.origin.y, 0.0);
    XCTAssertEqual(adjustedMapRect.size.width, 15.0);
    XCTAssertEqual(adjustedMapRect.size.height, 20.0);

    mapRect = MKMapRectMake(8, 8, 15, 20);
    adjustedMapRect = CCHMapClusterControllerAlignMapRectToCellSize(mapRect, 6);
    XCTAssertEqual(adjustedMapRect.origin.x, 6.0);
    XCTAssertEqual(adjustedMapRect.origin.y, 6.0);
    XCTAssertEqual(adjustedMapRect.size.width, 18.0);
    XCTAssertEqual(adjustedMapRect.size.height, 24.0);
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
    XCTAssertNil(visibleAnnotation);
    
    // Cluster does not contain annotation
    CCHMapClusterAnnotation *clusterAnnotationDoesNotContain = [[CCHMapClusterAnnotation alloc] init];
    [visibleAnnotations addObject:clusterAnnotationDoesNotContain];
    visibleAnnotation = CCHMapClusterControllerFindVisibleAnnotation(annotations, visibleAnnotations);
    XCTAssertNil(visibleAnnotation);
    
    // Cluster does contain annotation
    CCHMapClusterAnnotation *clusterAnnotationContains = [[CCHMapClusterAnnotation alloc] init];
    clusterAnnotationContains.annotations = [NSSet setWithObjects:[[MKPointAnnotation alloc] init], pointAnnotation, [[MKPointAnnotation alloc] init], [[MKPointAnnotation alloc] init], nil];
    [visibleAnnotations addObject:clusterAnnotationContains];
    visibleAnnotation = CCHMapClusterControllerFindVisibleAnnotation(annotations, visibleAnnotations);
    XCTAssertEqualObjects(clusterAnnotationContains, visibleAnnotation);
}

- (void)testMapLengthForLength
{
    CGRect rect = CGRectMake(0, 0, 200, 200);
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:rect];
    mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    double length = 100;
    
    // Heading north
    double mapLengthNorth = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    MKMapRect visibleMapRect = mapView.visibleMapRect;
    XCTAssert(mapLengthNorth > 0);
    XCTAssertEqualWithAccuracy(mapLengthNorth, visibleMapRect.size.width / 2.0, __FLT_EPSILON__);
    
    // Heading east
    MKMapCamera *camera = mapView.camera;
    camera.heading = 90;
    mapView.camera = camera;
    double mapLengthEast = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    XCTAssertEqualWithAccuracy(mapLengthEast, mapLengthNorth, __FLT_EPSILON__);
    
    // Heading south
    camera.heading = 180;
    mapView.camera = camera;
    double mapLengthSouth = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    XCTAssertEqualWithAccuracy(mapLengthSouth, mapLengthNorth, __FLT_EPSILON__);
    
    // Heading west
    camera.heading = 270;
    mapView.camera = camera;
    double mapLengthWest = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    XCTAssertEqualWithAccuracy(mapLengthWest, mapLengthNorth, __FLT_EPSILON__);
}

- (void)testMapLengthForLength180thMeridian
{
    CGRect rect = CGRectMake(0, 0, 200, 200);
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:rect];
    mapView.centerCoordinate = CLLocationCoordinate2DMake(0, 180);
    double length = 100;
    
    // Heading north
    double mapLengthNorth = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    MKMapRect visibleMapRect = mapView.visibleMapRect;
    XCTAssert(mapLengthNorth > 0);
    XCTAssertEqualWithAccuracy(mapLengthNorth, visibleMapRect.size.width / 2.0, 2 * __FLT_EPSILON__);
    
    // Heading east
    MKMapCamera *camera = mapView.camera;
    camera.heading = 90;
    mapView.camera = camera;
    double mapLengthEast = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    XCTAssertEqualWithAccuracy(mapLengthEast, mapLengthNorth, 2 * __FLT_EPSILON__);
    
    // Heading south
    camera.heading = 180;
    mapView.camera = camera;
    double mapLengthSouth = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    XCTAssertEqualWithAccuracy(mapLengthSouth, mapLengthNorth, 2 * __FLT_EPSILON__);
    
    // Heading west
    camera.heading = 270;
    mapView.camera = camera;
    double mapLengthWest = CCHMapClusterControllerMapLengthForLength(mapView, nil, length);
    XCTAssertEqualWithAccuracy(mapLengthWest, mapLengthNorth, 2 * __FLT_EPSILON__);
}

- (void)testAlignMapLengthToWorldWidth
{
    double mapLength = 10000.1;
    double alignedMapLength = CCHMapClusterControllerAlignMapLengthToWorldWidth(mapLength);
    XCTAssertTrue(alignedMapLength > mapLength);
    double factor = MKMapSizeWorld.width / alignedMapLength;
    XCTAssertEqualWithAccuracy(factor, floor(factor), __FLT_EPSILON__);

    mapLength = 123456789.0123;
    alignedMapLength = CCHMapClusterControllerAlignMapLengthToWorldWidth(mapLength);
    XCTAssertTrue(alignedMapLength > mapLength, @"Wrong aligned map length");
    factor = MKMapSizeWorld.width / alignedMapLength;
    XCTAssertEqualWithAccuracy(factor, floor(factor), __FLT_EPSILON__);
}

- (void)testCoordinateEqualToCoordinate
{
    // Same struct
    CLLocationCoordinate2D coordinate0 = CLLocationCoordinate2DMake(5.12, -0.72);
    XCTAssertTrue(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate0, coordinate0));
    
    // Equal struct
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(5.12, -0.72);
    XCTAssertTrue(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate0, coordinate1));

    // Longitude different
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(5.12, -0.73);
    XCTAssertFalse(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate1, coordinate2));

    // Latitude different
    CLLocationCoordinate2D coordinate3 = CLLocationCoordinate2DMake(5.11, -0.72);
    XCTAssertFalse(CCHMapClusterControllerCoordinateEqualToCoordinate(coordinate1, coordinate3));
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
    XCTAssertNil(mapClusterAnnotationFound);
    
    // Cluster annotation contains annotation
    mapClusterAnnotation.annotations = [NSSet setWithObject:annotation];
    mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertEqualObjects(mapClusterAnnotation, mapClusterAnnotationFound);

    // Cluster annotation outside map rect
    mapClusterAnnotation.coordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + 1.2 * coordinateRegion.span.latitudeDelta, coordinateRegion.center.longitude);
    mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertNil(mapClusterAnnotationFound);
}

- (void)testClusterAnnotationForAnnotationMultiple
{
    MKMapRect mapRect = MKMapRectMake(10000000, 10000000, 20000000, 20000000);
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionForMapRect(mapRect);
    
    MKMapView *mapView = [[MKMapView alloc] init];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    
    CCHMapClusterAnnotation *mapClusterAnnotation0 = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation0.coordinate = coordinateRegion.center;
    mapClusterAnnotation0.annotations = [NSSet setWithObjects:[[MKPointAnnotation alloc] init], annotation, [[MKPointAnnotation alloc] init], nil];
    [mapView addAnnotation:mapClusterAnnotation0];

    CCHMapClusterAnnotation *mapClusterAnnotation1 = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation1.coordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + 0.5, coordinateRegion.center.longitude + 0.5);
    mapClusterAnnotation1.annotations = [NSSet setWithObjects:[[MKPointAnnotation alloc] init], [[MKPointAnnotation alloc] init], nil];
    [mapView addAnnotation:mapClusterAnnotation1];

    CCHMapClusterAnnotation *mapClusterAnnotation2 = [[CCHMapClusterAnnotation alloc] init];
    mapClusterAnnotation2.coordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - 0.5, coordinateRegion.center.longitude - 0.5);
    mapClusterAnnotation2.annotations = [NSSet setWithObject:[[MKPointAnnotation alloc] init]];
    [mapView addAnnotation:mapClusterAnnotation2];
    
    CCHMapClusterAnnotation *mapClusterAnnotationFound = CCHMapClusterControllerClusterAnnotationForAnnotation(mapView, annotation, mapRect);
    XCTAssertEqualObjects(mapClusterAnnotation0, mapClusterAnnotationFound);
}

- (void)testEnumerateCells
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 100, 100);
    __block NSUInteger numCalls = 0;
    CCHMapClusterControllerEnumerateCells(mapRect, 10, ^(MKMapRect cellRect) {
        numCalls++;
        
        XCTAssertEqualWithAccuracy(cellRect.size.height, 10, __FLT_EPSILON__);
        XCTAssertEqualWithAccuracy(cellRect.size.width, 10, __FLT_EPSILON__);
    });
    XCTAssertEqual(numCalls, 100);
}

- (void)testEnumerateCellsAlign
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 95, 95);
    __block NSUInteger numCalls = 0;
    CCHMapClusterControllerEnumerateCells(mapRect, 10, ^(MKMapRect cellRect) {
        numCalls++;
        
        XCTAssertEqualWithAccuracy(cellRect.size.height, 10, __FLT_EPSILON__);
        XCTAssertEqualWithAccuracy(cellRect.size.width, 10, __FLT_EPSILON__);
    });
    XCTAssertEqual(numCalls, 100);
}

- (void)testMapRectForCoordinateRegion
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(52, 13);
    MKCoordinateSpan span = MKCoordinateSpanMake(3, 4);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    MKCoordinateRegion regionConverted = MKCoordinateRegionForMapRect(mapRect);
    
    // Pretty inaccurate
    XCTAssertEqualWithAccuracy(regionConverted.center.latitude, region.center.latitude, 1000000 * __FLT_EPSILON__);
    XCTAssertEqualWithAccuracy(regionConverted.center.longitude, region.center.longitude, __FLT_EPSILON__);
    XCTAssertEqualWithAccuracy(regionConverted.span.latitudeDelta, region.span.latitudeDelta, __FLT_EPSILON__);
    XCTAssertEqualWithAccuracy(regionConverted.span.longitudeDelta, region.span.longitudeDelta, __FLT_EPSILON__);
}

- (void)testFilterAnnotationsNil
{
    NSSet *filteredAnnotations = CCHMapClusterControllerClusterAnnotationsForAnnotations(nil, nil);
    XCTAssertEqual(filteredAnnotations.count, 0);
}

- (void)testFilterAnnotations
{
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    CCHMapClusterAnnotation *clusterAnnotation = [[CCHMapClusterAnnotation alloc] init];
    NSArray *annotations = @[pointAnnotation, clusterAnnotation];
    NSSet *filteredAnnotations = CCHMapClusterControllerClusterAnnotationsForAnnotations(annotations, nil);
    XCTAssertEqual(filteredAnnotations.count, 1);
    XCTAssertEqualObjects(filteredAnnotations.anyObject, clusterAnnotation);
}

- (void)testZoomLevelForRegion
{
    double zoomLevel = CCHMapClusterControllerZoomLevelForRegion(0, 360, 256);
    XCTAssertEqualWithAccuracy(zoomLevel, 0, __FLT_EPSILON__);
    zoomLevel = CCHMapClusterControllerZoomLevelForRegion(0, 180, 256);
    XCTAssertEqualWithAccuracy(zoomLevel, 1, __FLT_EPSILON__);
    zoomLevel = CCHMapClusterControllerZoomLevelForRegion(180, 180, 256);
    XCTAssertEqualWithAccuracy(zoomLevel, 1, __FLT_EPSILON__);
}

- (void)testAnnotationsByUniqueLocations
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(51.0, 13.0);

    NSSet *annotations = [NSSet setWithArray:@[annotation0]];
    NSArray *uniqueAnnotations = CCHMapClusterControllerAnnotationSetsByUniqueLocations(annotations, NSUIntegerMax);
    
    XCTAssertEqual(uniqueAnnotations.count, 1);
    XCTAssertEqual([uniqueAnnotations[0] count], 1);
    XCTAssertEqualObjects([uniqueAnnotations[0] anyObject], annotation0);
}

- (void)testAnnotationsByUniqueLocationsSameLocation
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52.0, 13.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation0.coordinate;

    NSSet *annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    NSArray *uniqueAnnotations = CCHMapClusterControllerAnnotationSetsByUniqueLocations(annotations, NSUIntegerMax);
    
    XCTAssertEqual(uniqueAnnotations.count, 1);
    XCTAssertEqual([uniqueAnnotations[0] count], 2);
}

- (void)testAnnotationsByUniqueLocationsClose
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(53.0, 14.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(annotation0.coordinate.latitude + __FLT_EPSILON__, annotation0.coordinate.longitude + __FLT_EPSILON__);
    
    NSSet *annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    NSArray *uniqueAnnotations = CCHMapClusterControllerAnnotationSetsByUniqueLocations(annotations, NSUIntegerMax);
    
    XCTAssertEqual(uniqueAnnotations.count, 1);
    XCTAssertEqual([uniqueAnnotations[0] count], 2);
}

- (void)testAnnotationsByUniqueLocationsTwoLocations
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52.0, 13.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(52.1, 13.1);
    
    NSSet *annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    NSArray *uniqueAnnotations = CCHMapClusterControllerAnnotationSetsByUniqueLocations(annotations, NSUIntegerMax);
    
    XCTAssertEqual(uniqueAnnotations.count, 2);
}

- (void)testAnnotationsByUniqueLocationsMax
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52.0, 13.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(52.1, 13.1);
    
    NSSet *annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    NSArray *uniqueAnnotations = CCHMapClusterControllerAnnotationSetsByUniqueLocations(annotations, 1);
    
    XCTAssertNil(uniqueAnnotations);
}

- (void)testIsUniqueLocation
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52.0, 13.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation0.coordinate;
    
    NSSet *annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    BOOL isUniqueLocation = CCHMapClusterControllerIsUniqueLocation(annotations);
    
    XCTAssertTrue(isUniqueLocation);
}

- (void)testIsUniqueLocationNil
{
    BOOL isUniqueLocation = CCHMapClusterControllerIsUniqueLocation(nil);
    
    XCTAssertFalse(isUniqueLocation);
}

- (void)testIsUniqueLocationFalse
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52.0, 13.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(52.0, 13.1);
    
    NSSet *annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    BOOL isUniqueLocation = CCHMapClusterControllerIsUniqueLocation(annotations);
    
    XCTAssertFalse(isUniqueLocation);
}

@end
