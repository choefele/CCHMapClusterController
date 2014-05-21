//
//  CCHMapClusterAnnotationTests.m
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

#import "CCHMapClusterAnnotation.h"

@interface CCHMapClusterAnnotationTests : XCTestCase

@property (nonatomic) CCHMapClusterAnnotation *clusterAnnotation;

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

- (void)testIsUniqueLocation
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = annotation0.coordinate;
    
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0]];
    XCTAssertTrue(self.clusterAnnotation.isUniqueLocation);

    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    XCTAssertTrue(self.clusterAnnotation.isUniqueLocation);
}

- (void)testIsUniqueLocationFalse
{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(50.0, 12.0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(50.1, 12.0);
    self.clusterAnnotation.annotations = [NSSet setWithArray:@[annotation0, annotation1]];
    XCTAssertFalse(self.clusterAnnotation.isUniqueLocation);
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
