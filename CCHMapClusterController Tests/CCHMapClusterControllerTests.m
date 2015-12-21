//
//  CCHMapClusterControllerTests.m
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

#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHFadeInOutMapAnimator.h"
#import "CCHMapClusterControllerUtils.h"

#import <XCTest/XCTest.h>

@interface CCHMapClusterControllerTests : XCTestCase

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) CCHMapClusterController *mapClusterController;

@end

@implementation CCHMapClusterControllerTests

- (void)setUp
{
    [super setUp];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
}

- (void)testAddAnnotationsNil
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:nil withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 0);
}

- (void)testAddAnnotationsSimple
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52.5, 13.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(3, 3));
    self.mapView.region = region;
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[annotation] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 1);
}

- (void)testAddAnnotations
{
    // 3x3 grid
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 100;

    // Grid spanning 51-54 lng, 12-15 lat
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5, 13.5), MKCoordinateSpanMake(3, 3));
    MKMapRect visibleMapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    self.mapView.visibleMapRect = visibleMapRect;

    // Bottom left
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(51.1, 12.1);
    
    // Top right
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
    annotation3.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation4 = [[MKPointAnnotation alloc] init];
    annotation4.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation5 = [[MKPointAnnotation alloc] init];
    annotation5.coordinate = CLLocationCoordinate2DMake(53.9, 14.6);

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    NSArray *annotations = @[annotation0, annotation1, annotation2, annotation3, annotation4, annotation5];
    [self.mapClusterController addAnnotations:annotations withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapClusterController.annotations.count, 6);
    XCTAssertEqual(self.mapView.annotations.count, 2);

    // Origin MKCoordinateRegion -> bottom left, MKMapRect -> top left
    double cellWidth = visibleMapRect.size.width / 3;
    double cellHeight = visibleMapRect.size.height / 3;
    MKMapPoint cellOrigin = visibleMapRect.origin;

    // Check bottom left
    MKMapRect bottomLeftMapRect = MKMapRectMake(cellOrigin.x, cellOrigin.y + 2 * cellHeight, cellWidth, cellHeight);
    NSSet *annotationsInMapRect = [self.mapView annotationsInMapRect:bottomLeftMapRect];
    XCTAssertEqual(annotationsInMapRect.count, 1);
    CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotationsInMapRect.anyObject;
    XCTAssertEqual(clusterAnnotation.annotations.count, 1);

    // Check top right
    MKMapRect topRightMapRect = MKMapRectMake(cellOrigin.x + 2 * cellWidth, cellOrigin.y, cellWidth, cellHeight);
    annotationsInMapRect = [self.mapView annotationsInMapRect:topRightMapRect];
    XCTAssertEqual(annotationsInMapRect.count, 1);
    clusterAnnotation = (CCHMapClusterAnnotation *)annotationsInMapRect.anyObject;
    XCTAssertEqual(clusterAnnotation.annotations.count, 5);

    // Check center
    MKMapRect middleMapRect = MKMapRectMake(cellOrigin.x + cellWidth, cellOrigin.y + cellHeight, cellWidth, cellHeight);
    annotationsInMapRect = [self.mapView annotationsInMapRect:middleMapRect];
    XCTAssertEqual(annotationsInMapRect.count, 0);
}

- (void)testRemoveAnnotations
{
    // 3x3 grid
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 100;
    
    // Grid spanning 51-54 lng, 12-15 lat
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5, 13.5), MKCoordinateSpanMake(3, 3));
    MKMapRect visibleMapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    self.mapView.visibleMapRect = visibleMapRect;
    
    // Bottom left
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(51.1, 12.1);
    
    // Top right
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
    annotation3.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation4 = [[MKPointAnnotation alloc] init];
    annotation4.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation5 = [[MKPointAnnotation alloc] init];
    annotation5.coordinate = CLLocationCoordinate2DMake(53.9, 14.6);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    NSArray *annotations = @[annotation0, annotation1, annotation2, annotation3, annotation4, annotation5];
    [self.mapClusterController addAnnotations:annotations withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapClusterController.annotations.count, annotations.count);
    XCTAssertEqual(self.mapView.annotations.count, 2);

    // Origin MKCoordinateRegion -> bottom left, MKMapRect -> top left
    double cellWidth = visibleMapRect.size.width / 3;
    double cellHeight = visibleMapRect.size.height / 3;
    MKMapPoint cellOrigin = visibleMapRect.origin;
    
    // Remove bottom left
    expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController removeAnnotations:@[annotation0] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapClusterController.annotations.count, 5);
    XCTAssertEqual(self.mapView.annotations.count, 1);

    // Check bottom left
    MKMapRect bottomLeftMapRect = MKMapRectMake(cellOrigin.x, cellOrigin.y + 2 * cellHeight, cellWidth, cellHeight);
    NSSet *annotationsInMapRect = [self.mapView annotationsInMapRect:bottomLeftMapRect];
    XCTAssertEqual(annotationsInMapRect.count, 0);
    
    // Check center
    MKMapRect middleMapRect = MKMapRectMake(cellOrigin.x + cellWidth, cellOrigin.y + cellHeight, cellWidth, cellHeight);
    annotationsInMapRect = [self.mapView annotationsInMapRect:middleMapRect];
    XCTAssertEqual(annotationsInMapRect.count, 0);

    // Remove remaining annotations
    expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController removeAnnotations:annotations withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 0);
    
    // Check visible region
    annotationsInMapRect = [self.mapView annotationsInMapRect:visibleMapRect];
    XCTAssertEqual(annotationsInMapRect.count, 0);
}

- (void)testAddNonClusteredAnnotations
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(52.5, 13.5);

    MKPointAnnotation *nonClusteredAnnotation = [[MKPointAnnotation alloc] init];
    nonClusteredAnnotation.coordinate = coordinate;
    [self.mapView addAnnotation:nonClusteredAnnotation];

    MKPointAnnotation *clusteredAnnotation = [[MKPointAnnotation alloc] init];
    clusteredAnnotation.coordinate = coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMake(clusteredAnnotation.coordinate, MKCoordinateSpanMake(3, 3));
    self.mapView.region = region;

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[clusteredAnnotation] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];

    XCTAssertEqual(self.mapView.annotations.count, 2);
    XCTAssertTrue([self.mapView.annotations containsObject:nonClusteredAnnotation]);

    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    [annotations removeObject:nonClusteredAnnotation];
    XCTAssertTrue([annotations.lastObject isKindOfClass:CCHMapClusterAnnotation.class]);
    CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotations.lastObject;
    XCTAssertTrue([clusterAnnotation.annotations containsObject:clusteredAnnotation]);
}

- (void)testAddAnnotationsWithDifferentControllers
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(52.5, 13.5);
    MKPointAnnotation *clusteredAnnotation = [[MKPointAnnotation alloc] init];
    clusteredAnnotation.coordinate = coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(clusteredAnnotation.coordinate, MKCoordinateSpanMake(3, 3));
    self.mapView.region = region;
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[clusteredAnnotation] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];

    expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    CCHMapClusterController *mapClusterController2 = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    [mapClusterController2 addAnnotations:@[clusteredAnnotation] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    
    XCTAssertEqual(self.mapView.annotations.count, 2);
    
    CCHMapClusterAnnotation *annotation0 = self.mapView.annotations[0];
    XCTAssertTrue([annotation0 isKindOfClass:CCHMapClusterAnnotation.class]);
    XCTAssertTrue([annotation0.annotations containsObject:clusteredAnnotation]);
    CCHMapClusterAnnotation *annotation1 = self.mapView.annotations[1];
    XCTAssertTrue([annotation1 isKindOfClass:CCHMapClusterAnnotation.class]);
    XCTAssertTrue([annotation1.annotations containsObject:clusteredAnnotation]);
}

- (void)testAddAnnotationsMaxZoomLevelEnableClustering
{
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 300;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(10, 10));
    self.mapView.region = region;   // zoomLevel = 5.396910
    self.mapClusterController.maxZoomLevelForClustering = 6;
    
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(0, 0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(0, 1);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(0, 0);

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[annotation0, annotation1, annotation2] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 1);
}

- (void)testAddAnnotationsMaxZoomLevelDisableClustering
{
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 300;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(5, 5));
    self.mapView.region = region;   // zoomLevel = 6.398285
    self.mapClusterController.maxZoomLevelForClustering = 6;
    
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(0, 0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(0, 1);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(0, 0);

    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[annotation0, annotation1, annotation2] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 2);
}

- (void)testAddAnnotationsMinUniqueLocationsEnableClustering
{
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 300;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(5, 5));
    self.mapView.region = region;
    self.mapClusterController.minUniqueLocationsForClustering = 2;
    
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(0, 0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(0, 1.5);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(0, 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[annotation0, annotation1, annotation2] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 1);
}

- (void)testAddAnnotationsMinUniqueLocationsDisableClustering
{
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 300;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0, 0), MKCoordinateSpanMake(5, 5));
    self.mapView.region = region;
    self.mapClusterController.minUniqueLocationsForClustering = 3;
    
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(0, 0);
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(0, 1.5);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(0, 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[annotation0, annotation1, annotation2] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqual(self.mapView.annotations.count, 2);
}

#if TARGET_OS_IPHONE
- (void)testFadeInOut
{
    CCHFadeInOutMapAnimator *animator = [[CCHFadeInOutMapAnimator alloc] init];
    self.mapClusterController.animator = animator;
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52.5, 13.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(3, 3));
    self.mapView.region = region;
    
    // Fade in
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController addAnnotations:@[annotation] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    
    CCHMapClusterAnnotation *clusterAnnotation = [self.mapView.annotations lastObject];
    MKAnnotationView *annotationView = [self.mapView viewForAnnotation:clusterAnnotation];
    XCTAssertEqualWithAccuracy(annotationView.alpha, 1.0, __FLT_EPSILON__);
    
    // Fade Out
    expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.mapClusterController removeAnnotations:@[annotation] withCompletionHandler:^{
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
    XCTAssertEqualWithAccuracy(annotationView.alpha, 0.0, __FLT_EPSILON__);
}
#endif

@end
