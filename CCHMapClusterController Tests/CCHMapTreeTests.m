//
//  CCHMapTreeTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHMapTree.h"

#import "CCHMapClusterControllerUtils.h"

@interface CCHMapTreeTests : XCTestCase

@property (nonatomic, strong) CCHMapTree *mapTree;

@end

@implementation CCHMapTreeTests

- (void)setUp
{
    [super setUp];
    
    self.mapTree = [[CCHMapTree alloc] init];
}

- (void)testDealloc
{
    CCHMapTree *mapTree = [[CCHMapTree alloc] init];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52, 13);
    [mapTree addAnnotations:@[annotation]];
}

- (void)testAnnotationsInMapRectContainsRetain
{
    CCHMapTree *mapTree = [[CCHMapTree alloc] init];
    NSString *title = @"title";
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(52, 13);
    @autoreleasepool {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coordinate;
        annotation.title = title;
        
        [mapTree addAnnotations:@[annotation]];
    }

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSArray *annotations = [mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, 1u, @"Wrong number of annotations");
    if (annotations.count > 0) {
        XCTAssertEqualObjects(title, [annotations[0] title], @"Wrong title");
    }
}

- (void)testAnnotationsInMapRectEmpty
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(52, 13), 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSArray *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, 0u, @"Wrong number of annotations");
}

- (void)testAnnotationsInMapRectContains
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52, 13);
    [self.mapTree addAnnotations:@[annotation]];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSArray *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, 1u, @"Wrong number of annotations");
    if (annotations.count > 0) {
        XCTAssertEqual(annotation, annotations[0], @"Wrong annotation");
    }
}

- (void)testAnnotationsInMapRectContainsSamePosition
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52, 13);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation0.coordinate;
    [self.mapTree addAnnotations:@[annotation0, annotation1]];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation0.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSArray *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, 2u, @"Wrong number of annotations");
    if (annotations.count > 0) {
        XCTAssertTrue([annotations containsObject:annotation0], @"Wrong annotation");
        XCTAssertTrue([annotations containsObject:annotation1], @"Wrong annotation");
    }
}

- (void)testAnnotationsInMapRectDoesNotContain
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52, 13);
    [self.mapTree addAnnotations:@[annotation]];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50, 10);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSArray *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, 0u, @"Wrong number of annotations");
}

- (void)testAnnotationsInMapRectContainsSome
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(52, 13);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(50, 10);
    [self.mapTree addAnnotations:@[annotation0, annotation1]];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation1.coordinate, 1000, 1000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    NSArray *annotations = [self.mapTree annotationsInMapRect:mapRect];
    XCTAssertEqual(annotations.count, 1u, @"Wrong number of annotations");
    if (annotations.count > 0) {
        XCTAssertEqual(annotation1, annotations[0], @"Wrong annotation");
    }
}

@end
